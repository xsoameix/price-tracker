require './styles/price.styl'

require! <[d3]>
Promise = require 'bluebird'
$ = require 'jquery'
React = require 'react'
ReactDOM = require 'react-dom'

{div, input} = React.DOM
Main = React.createFactory React.createClass do
  getInitialState: ->
    {+'switch', price: {}}
  _toggle: ->
    @setState switch: !@state.switch
  componentDidMount: ->
    Promise.resolve $.get '/price'
    .then (price) ~>
      if @isMounted!
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
        data = price['B0090UEQ8I'].map ->
          price: it.amazon
          date: format.parse it.created_time
        console.log data
        elem = ReactDOM.findDOMNode @
        margin = top: 40 right: 20 bottom: 30 left: 50
        width = 960 - margin.left - margin.right
        height = 500 - margin.top - margin.bottom
        x = d3.time.scale! .range [0, width]  .domain d3.extent data, (.date)
        y = d3.scale.linear!range [height, 0] .domain d3.extent data, (.price)
        x-axis = d3.svg.axis!scale x .orient 'bottom' .tick-format time-format
        y-axis = d3.svg.axis!scale y .orient 'left'
        line = d3.svg.line!
        .x -> x it.date
        .y -> y it.price
        svg = d3.select elem
        .append 'svg'
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
        .text '金額'
        svg
        .append 'path'
        .datum data
        .attr 'class', 'line'
        .attr 'd', line
        @setState {price}
  render: ->
    div {}
ReactDOM.render Main!, document.getElementById 'app'
