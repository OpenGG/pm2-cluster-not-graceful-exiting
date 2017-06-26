'use strict';

var createServer = require('http').createServer;

var port = parseInt(process.argv[2], 10) || 9293;

console.log('Creating server');

var server = createServer(function (req, res) {
  res.end('hello world');
});

console.log('Listening on port ' + port);

server.listen(port);

process.on('SIGINT', function () {
  // My process has received a SIGINT signal
  // Meaning PM2 is now trying to stop the process

  // So I can clean some stuff before the final stop
  console.log('Receiving SIGINT, closing server');

  server.close();

  setTimeout(function () {
    // 300ms later the process kill it self to allow a restart
    console.error('Node.js process not exited, set exit code to 1');

    process.exitCode = 1;
  }, 1000).unref();
});