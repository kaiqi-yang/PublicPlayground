'use strict'

const axios = require("axios");

exports.handler = function (event, context, callback) {

  const url = 'https://afterpay.com'

  
  axios.interceptors.request.use((config) => {
      config.headers['request-startTime'] = process.hrtime()
      return config
  })
  
  axios.interceptors.response.use((response) => {
      const start = response.config.headers['request-startTime']
      const end = process.hrtime(start)
      const milliseconds = Math.round((end[0] * 1000) + (end[1] / 1000000))
      response.headers['request-duration'] = milliseconds
      return response
  })
  
  var latency;

  axios.get(url).then((response) => {
      latency = response.headers['request-duration']
      console.error(response.headers['request-duration'])

      var response = {
        statusCode: 200,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin' : '*',
          'Access-Control-Allow-Credentials' : true
        },
        body: '{ "latency": ' + latency + ', "logo": "https://site-assets.afterpay.com/assets/afterpay_logo_small-c21f624e13e513b83e729c61fa161b4d75643a4e62d4dcd3df62e1c5d3ed7326.svg"}'
      }

      callback(null, response)

  }).catch((error) => {
      console.error(`Error`)
  })
}
