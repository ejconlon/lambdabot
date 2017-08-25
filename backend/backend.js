const express = require('express')

exports.createApp = function() {
  const app = express();

  app.get('/', function (req, res) {
    res.send('Hello World!');
  });

  return app;
}
