import * as echarts from 'echarts';

var chartDom = document.getElementById('main');
var myChart = echarts.init(chartDom, 'dark');
var option;

option = {
  title: {
    text: '[select_random_ranges] (QPS)'
  },
  legend: {
    data: ['PostgreSQL', 'PostgreSQL(Proxied)']
  },
  xAxis: {
    type: 'category',
    data: ['1', '4', '8']
  },
  yAxis: {
    type: 'value'
  },
  series: [
    {
      name: 'PostgreSQL',
      data: [40.93, 947.14, 999.43],
      type: 'line',
      smooth: true,
      color: '#5470C6'
    },
    {
      name: 'PostgreSQL(Proxied)',
      data: [340.16, 172.01, 180.67],
      type: 'line',
      smooth: true,
      color: '#EE6666'
    }
  ]
};

option && myChart.setOption(option);
