require 'semantic-ui/dist/semantic.css'
require './styles/price.styl'

require! <[d3 classnames]>
Promise = require 'bluebird'
$ = require 'jquery'
React = require 'react'
ReactDOM = require 'react-dom'

$a = React.DOM.a
{div, input, svg} = React.DOM
Main = React.createFactory React.createClass do
  getInitialState: ->
    choose: {} item: [] price: {}
  handleView: ({choose, item, price}) ->
    # example:
    # singal line: http://bl.ocks.org/mbostock/3883245
    # multiple line: http://bl.ocks.org/mbostock/3884955
    time-format = d3.locale do
      decimal: '.'
      thousands: ','
      grouping: [3]
      currency: ['TWD' '']
      dateTime: '%a %b %e %X %Y'
      date: '%Y/%-m/%-d'
      time: '%H:%M:%S'
      periods: <[上午 下午]>
      days: <[星期日 星期一 星期二 星期三 星期四 星期五 星期六]>
      shortDays: <[星期日 星期一 星期二 星期三 星期四 星期五 星期六]>
      months:
        <[一月 二月 三月 四月 五月 六月 七月 八月 九月 十月 十一月 十二月]>
      shortMonths:
        <[一月 二月 三月 四月 五月 六月 七月 八月 九月 十月 十一月 十二月]>
    .time-format.multi [
      [".%L"   (d) -> d.getMilliseconds!]
      [":%S"   (d) -> d.getSeconds!]
      ["%I:%M" (d) -> d.getMinutes!]
      ["%p %I" (d) -> d.getHours! ]
      ["%a %d" (d) -> d.getDay! && d.getDate! != 1 ]
      ["%b %d" (d) -> d.getDate! != 1 ]
      ["%B"    (d) -> d.getMonth! ]
      ["%Y"    (d) -> true ]
    ]
    format = d3.time.format.iso
    currency = d3.format ',.2f'
    bisect = d3.bisector (.date) .left
    data = <[amazon new]>.map (type) ->
      price.filter(-> it.name == choose.name).map ->
        price: it[type]
        date: format.parse it.recorded_time
      .filter (.price)
    margin = top: 40 right: 80 bottom: 30 left: 80
    width = 960 - margin.left - margin.right
    height = 500 - margin.top - margin.bottom
    data-y = data.0 ++ data.1
    x = d3.time.scale! .range [0, width]  .domain d3.extent data.0, (.date)
    y = d3.scale.linear!range [height, 0] .domain d3.extent data-y, (.price)
    x-axis = d3.svg.axis!scale x .orient 'bottom' .tick-format time-format
    y-axis = d3.svg.axis!scale y .orient 'left' .tick-size -width
      .tick-padding 8
      .tick-format -> "$ #{currency it}"
    line = d3.svg.line!
    .x -> x it.date
    .y -> y it.price
    elem = ReactDOM.findDOMNode @refs.price
    d3.select elem
    .select-all '*'
    .remove!
    svg = d3.select elem
    .attr 'width', width + margin.left + margin.right
    .attr 'height', height + margin.top + margin.bottom
    .append 'g'
    .attr 'transform', "translate(#{margin.left},#{margin.top})"
    svg
    .append 'g'
    .attr 'class', 'x axis'
    .attr 'transform', "translate(0,#height)"
    .call x-axis
    svg
    .append 'g'
    .attr 'class', 'y axis'
    .call y-axis
    .append 'text'
    .text '價格(美元)'
    .attr 'y', -10
    svg
    .append 'path'
    .datum data.1
    .attr 'class', 'green line'
    .attr 'd', line
    svg
    .append 'path'
    .datum data.0
    .attr 'class', 'line'
    .attr 'd', line
    svg
    .append 'path'
    .attr 'class', 'mouse-line'
    .style 'opacity', 0
    focus = data.map ->
      tip = svg
      .append 'g'
      .attr 'class', 'focus'
      .style 'display', 'none'
      tip
      .append 'circle'
      .attr 'r', 4.5
      tip
      .append 'text'
      .attr 'x', 9
      .attr 'dy', '-.35em'
      tip
    svg
    .append 'rect'
    .attr 'width', width
    .attr 'height', height
    .attr 'fill', 'none'
    .attr 'pointer-events', 'all'
    .on 'mouseover' ->
      d3.select '.mouse-line'
      .style 'opacity', '1'
      focus.for-each -> it.style 'display', null
    .on 'mouseout' ->
      d3.select '.mouse-line'
      .style 'opacity', '0'
      focus.for-each -> it.style 'display', 'none'
    .on 'mousemove' ->
      d3.select '.mouse-line'
      .attr 'd' ->
        [y0, y1] = y.range!
        x0 = d3.mouse @ .0
        date = x.invert x0
        data.for-each (path, i) ->
          index = bisect path, date, 1
          prev = path[index - 1]
          next = path[index]
          item = if date - prev.date < next.date - date then prev else next
          focus[i].attr 'transform', "translate(#{x item.date},#{y item.price})"
          focus[i].select 'text' .text "$ #{currency item.price}"
        "M#{x0},#{y0}L#{x0},#{y1}"
  componentDidMount: ->
    var item
    Promise.resolve $.get '/item'
    .then ->
      item := it
      Promise.resolve $.get '/price'
    .then (price) ~>
      if @isMounted!
        console.log price
        choose = @state.choose
        if Object.keys @state.choose .length == 0
          if !item.0 then return
          choose = item.0
        @handleView {choose, item, price}
        @setState {choose, item, price}
  handleItem: (choose) ->
    @setState {choose}
    @handleView {choose} <<< @state{item, price}
  render: ->
    div {},
      div {className: 'ui grid'},
        div {className: 'three wide column'},
          div {className: 'ui hidden divider'}
          div {className: 'ui secondary vertical pointing fluid menu'},
            @state.item.map ~>
              $a {
                className: classnames 'item', active: it == @state.choose
                onClick:   @handleItem.bind @, it
                key:       it.id # f
              }, it.desc
        div {className: 'thirdteen wide column'},
          svg {ref: 'price'}
ReactDOM.render Main!, document.getElementById 'app'
