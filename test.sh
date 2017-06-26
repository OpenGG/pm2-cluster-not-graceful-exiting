#!/usr/bin/env bash

echo "Test without pm2"

mkdir -p ./tmp

echo "Starting server"

(node server.js 9877 >./tmp/server.out 2>./tmp/server.err) &

pid=$!

echo "${pid}">./tmp/server.pid

echo "Wait 1s before checking server status"
sleep 1

echo "Send hello world request"

response=$(curl -s http://localhost:9877)

echo "Checking response"

if [ "${response}" != "hello world" ]; then
  echo "Server responding '${response}' instead of 'hello world'"
  exit 3
fi

echo "Graceful stopping server with SIGINT"

kill -INT "${pid}"

wait "${pid}"

code=$?

echo "Server exit code: ${code}"

echo "${code}">./tmp/server.code

echo -e "\n\nServer stdout:"
echo "--- stdout starts ---"
cat ./tmp/server.out
echo -e "--- stdout ends ---\n\n"

echo -e "\n\nServer stderr:"
echo "--- stderr starts ---"
cat ./tmp/server.err
echo -e "--- stderr ends ---\n\n"

if [ "${code}" != "0" ]; then
  echo "Error: exit code not zero: ${code}"
  exit 4
fi

echo "Test success"
