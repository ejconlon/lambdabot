'use strict';

const backend = require('backend.js');

const app = backend.createApp();

app.listen(3000, function () {
  console.log('Example app listening on port 3000!');
}
