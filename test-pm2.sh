#!/usr/bin/env bash

echo "Test with pm2"

mkdir -p ./tmp

echo "Flush pm2 logs"

pm2 flush

echo "Starting server"

pm2 start pm2.config.js

echo "Wait 1s before checking server status"
sleep 1

echo "Send hello world request"

response=$(curl -s http://localhost:9876)

echo "Checking response"

if [ "${response}" != "hello world" ]; then
  echo "Server responding '${response}' instead of 'hello world'"

  pm2 delete pm2.config.js

  exit 3
fi

echo "Graceful stopping server with pm2 gracefulReload"

pm2 gracefulReload pm2.config.js

stdout=$(pm2 logs all --nostream --lines 10000)

echo "Flush pm2 logs"
pm2 flush

pm2 delete pm2.config.js

echo -e "\n\pm2 logs:"
echo -e "--- pm2 logs starts ---"
echo "${stdout}"
echo -e "--- pm2 logs ends ---\n\n"

if [[ "${stdout}" == *"Node.js process not exited, set exit code to 1"* ]]; then
  echo "Test fail"

  echo "Error: SIGINT did not stop server, pm2 sent SIGKILL signals after waiting 1600ms"

  exit 4
fi

echo "Test success"
