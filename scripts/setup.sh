#!/bin/bash

while getopts ":k:" opt; do
  case $opt in
    k)
      OPENAI_API_KEY="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [ -z "$OPENAI_API_KEY" ]; then
  echo "Error: Option -k is required." >&2
  exit 1
fi

# update
sudo apt update;
sudo apt-get update;

# prepare visit
# nginx
echo 'y' | sudo apt install nginx
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default_bak
sudo chmod 777 /etc/nginx/sites-available/default
sudo echo -e "server { \n listen 80; \n\n  location / {\n proxy_pass http://127.0.0.1:3000; \n client_body_timeout 60s; \n send_timeout 60s; \n keepalive_timeout 60s;  \n proxy_buffering off; \n proxy_request_buffering off; \n proxy_http_version 1.1; \n chunked_transfer_encoding on; \n proxy_connect_timeout 300s; \n proxy_send_timeout 300s; \n proxy_read_timeout 300s; \n}  \n }" > /etc/nginx/sites-available/default
sudo systemctl enable nginx
sudo systemctl restart nginx

# ufw
sudo ufw allow 'Nginx Full'
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp

# prepare req
echo 'y' | sudo apt-get install git
echo 'y' | sudo apt install npm
sudo npm install -g yarn

# mvn, node
git clone https://github.com/nvm-sh/nvm.git /home/ubuntu/.nvm
echo 'export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm' >> /home/ubuntu/.bashrc
source /home/ubuntu/.nvm/nvm.sh
nvm install 18.15.0
nvm use 18.15.0

# install project
cd /home/ubuntu
git clone https://github.com/henry1992007/ChatGPT-Next-Web.git
cd ChatGPT-Next-Web
echo "OPENAI_API_KEY=$OPENAI_API_KEY" > .env.local
yarn install
yarn build

# setup auto start
cd /home/ubuntu
sudo echo -e '[Unit]\nDescription=Launch ChatGTP Service\n\n[Service]\nExecStart=/bin/bash -c '\''source /home/ubuntu/.nvm/nvm.sh && nvm use 18.15.0 && yarn start > launch.log 2>&1'\''\nRestart=always\nUser=ubuntu\nWorkingDirectory=/home/ubuntu/ChatGPT-Next-Web\n\n[Install]\nWantedBy=multi-user.target' > chat.service
sudo mv chat.service /etc/systemd/system/
chmod 777 /etc/systemd/system/chat.service
sudo systemctl daemon-reload
sudo systemctl start chat.service
sudo systemctl enable chat.service