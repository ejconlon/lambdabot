'use strict';

const lambdabot = require('./lambdabot.js');
const awsServerlessExpress = require('aws-serverless-express');

const app = lambdabot.createApp();
const server = awsServerlessExpress.createServer(app);

exports.handler = function (event, context) {
  awsServerlessExpress.proxy(server, event.requestContext, context);
}
