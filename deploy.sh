#!/bin/bash
set -e

PROJECT_NAME=$(echo "$1" | tr '[:upper:]' '[:lower:]')
PROJECT_VERSION=$2

rm -rf $PROJECT_NAME
mkdir $PROJECT_NAME
tar xvzf build.tgz --directory $PROJECT_NAME

docker build --pull=true -t "$PROJECT_NAME:$PROJECT_VERSION" $PROJECT_NAME

sudo tee /etc/systemd/system/$PROJECT_NAME.service << EOF
[Unit]
Description=$PROJECT_NAME-nginx
After=docker.service
Requires=docker.service
[Service]
Restart=always
TimeoutStartSec=5s
ExecStartPre=-/usr/bin/docker kill $PROJECT_NAME
ExecStartPre=-/usr/bin/docker rm $PROJECT_NAME
ExecStart=/usr/bin/docker run --name $PROJECT_NAME -p 80:80 $PROJECT_NAME:$PROJECT_VERSION
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable $PROJECT_NAME.service
sudo systemctl restart $PROJECT_NAME.service