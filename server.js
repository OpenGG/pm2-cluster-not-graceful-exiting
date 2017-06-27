'use strict';

var PM2_DISCONNECT = function PM2_DISCONNECT() {
  if (process.connected) {
    process.removeAllListeners('uncaughtException');
    process.removeAllListeners('unhandledRejection');
    process.disconnect();
    delete process.stdout.write;
    delete process.stderr.write;
  } else {
    throw new Error('Already disconnected');
  }
};

var createServer = require('http').createServer;

var port = parseInt(process.argv[2], 10) || 9293;

var dirtyFix = process.argv[3] === '--dirty-fix';

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

  server.close(function () {
    if (dirtyFix) {
      PM2_DISCONNECT();
    }

    process.stdout.write('[' + process.pid + ']Write to stdout: 1234567890');
    process.stderr.write('[' + process.pid + ']Write to stderr: baaaaaaaaaab');
  });

  setTimeout(function () {
    // 300ms later the process kill it self to allow a restart
    console.error('Node.js process not exited, set exit code to 1');

    process.exitCode = 1;
  }, 1000).unref();
});
