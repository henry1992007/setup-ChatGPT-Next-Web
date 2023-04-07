#!/bin/bash

# upgrade
cd /home/ubuntu/ChatGPT-Next-Web/
git pull origin main
yarn install
yarn build

# kill existing
pid=$(ps aux | grep '/home/ubuntu/ChatGPT-Next-Web/node_modules/.bin/next start' | grep -v 'grep' | head -n 1 | awk '{print $2}')
if [[ -n "$pid" ]]; then
	sudo kill $pid
fi

# restart
bash /home/ubuntu/launchGpt.sh

# end
