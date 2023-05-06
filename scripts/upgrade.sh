#!/bin/bash

# upgrade
cd /home/ubuntu/ChatGPT-Next-Web/
git pull origin main
yarn install
yarn build

# restart
sudo systemctl restart chat.service