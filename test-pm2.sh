#!/usr/bin/env bash

dirtyFix="$1"

echo "Test with pm2: ${dirtyFix}"

mkdir -p ./tmp

echo "Flush pm2 logs"

pm2 flush

config="pm2.config.js"

port="9876"

if [ "${dirtyFix}" != "" ]; then
  config="pm2.dirty-fix.config.js"

  port="9875"
fi

echo "Starting server with config: ${config}"

pm2 start "${config}"

echo "Wait 1s before checking server status"
sleep 1

echo "Send hello world request"

response=$(curl -s http://localhost:${port})

echo "Checking response"

if [ "${response}" != "hello world" ]; then
  echo "Server responding '${response}' instead of 'hello world'"

  pm2 delete "${config}"

  exit 3
fi

echo "Graceful stopping server with pm2 gracefulReload"

pm2 reload "${config}"

stdout=$(pm2 logs all --nostream --lines 10000)

echo "Flush pm2 logs"
pm2 flush

pm2 delete "${config}"

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
