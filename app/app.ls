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
      ["%I %p" (d) -> d.getHours! ]
      ["%a %d" (d) -> d.getDay! && d.getDate! != 1 ]
      ["%b %d" (d) -> d.getDate! != 1 ]
      ["%B"    (d) -> d.getMonth! ]
      ["%Y"    (d) -> true ]
    ]
    format = d3.time.format.iso
    data = price[choose.id].map ->
      price: it.amazon
      date: format.parse it.created_time
    margin = top: 40 right: 20 bottom: 30 left: 80
    width = 960 - margin.left - margin.right
    height = 500 - margin.top - margin.bottom
    x = d3.time.scale! .range [0, width]  .domain d3.extent data, (.date)
    y = d3.scale.linear!range [height, 0] .domain d3.extent data, (.price)
    x-axis = d3.svg.axis!scale x .orient 'bottom' .tick-format time-format
    y-axis = d3.svg.axis!scale y .orient 'left'
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
    svg
    .append 'path'
    .datum data
    .attr 'class', 'line'
    .attr 'd', line
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
