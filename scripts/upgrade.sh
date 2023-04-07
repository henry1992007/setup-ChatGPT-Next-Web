#!/bin/bash

# kill existing
pid=$(ps aux | grep 'ChatGPT-Next-Web' | grep -v 'grep' | head -n 1 | awk '{print $2}')

if [[ -n "$pid" ]]; then
	kill $pid
fi

cd /home/ubuntu/ChatGPT-Next-Web/
git pull origin main
yarn install
yarn build
bash /home/ubuntu/launchGpt.sh
