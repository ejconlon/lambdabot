'use strict';

const AWS = require('aws-sdk');
const bodyParser = require('body-parser');
const express = require('express');
const process = require('process');

function createDefaultConfig() {
  const config = {
    region: 'us-west-2',
    firehoseName: 'lambdabot_firehose'
  };
  if (process.env.hasOwnProperty('PROFILE')) {
    config.profile = process.env.PROFILE;
  }
  return config;
};

function createCredentialProvider(config) {
  const iniOptions = {};
  if (config.hasOwnProperty('profile')) {
    iniOptions.profile = config.profile;
  }
  const chain = new AWS.CredentialProviderChain();
  chain.providers.push(new AWS.SharedIniFileCredentials(iniOptions));
  chain.providers.push(new AWS.EC2MetadataCredentials());
  return chain;
}

exports.createApp = function() {
  // const config = createDefaultConfig();
  //
  // const credentialProvider = createCredentialProvider(config);
  //
  // const firehose = new AWS.Firehose({
  //   region: config.region,
  //   credentialProvider
  // });

  const app = express();

  app.use(bodyParser.json());

  app.get('/', function (req, res) {
    res.send('Hello World!');
  });

  app.get('/test', function (req, res) {
    console.log('Invoked test.');
    res.send('Completed test.');
  });

  app.post('/hello', function (req, res) {
    const name = req.body.name;
    const data = JSON.stringify({ name });
    console.log('Writing: ' + data);
    // const params = {
    //   DeliveryStreamName: config.firehoseName,
    //   Record: {
    //     Data: data
    //   }
    // }
    res.sendStatus(200);
    // firehose.putRecord(params, function (err, data) {
    //   if (err) {
    //     console.error(err.stack);
    //     res.sendStatus(500);
    //   } else {
    //     res.sendStatus(200);
    //   }
    // });
  });

  app.use(function (req, res) {
    console.error('Unmatched: ' + req.method + ' ' + req.path);
    res.sendStatus(400);
  });

  app.use(function (err, req, res, next) {
    console.error(err.stack);
    res.sendStatus(500);
  });

  return app;
}
