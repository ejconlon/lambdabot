'use strict';

const lambdabot = require('./lambdabot.js');

const app = lambdabot.createApp();

app.listen(3000, function () {
  console.log('Example app listening on port 3000!');
});
