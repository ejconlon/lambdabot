'use strict';

const backend = require('./backend.js');
const awsServerlessExpress = require('aws-serverless-express');

const app = backend.createApp();
const server = awsServerlessExpress.createServer(app);

exports.handler = function (event, context) {
  awsServerlessExpress.proxy(server, event.requestContext, context);
}
