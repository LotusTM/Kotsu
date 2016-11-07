#!/bin/bash
set -e

PROJECT_NAME=$1
PROJECT_VERSION=$2

rm -rf $PROJECT_NAME
mkdir $PROJECT_NAME
tar xvzf $PROJECT_NAME.tgz --directory $PROJECT_NAME

DOCKER_IMAGE_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]')

docker build --pull=true -t "$DOCKER_IMAGE_NAME:$PROJECT_VERSION" $PROJECT_NAME --build-arg VHOST_NAME=$VHOST_NAME

sudo tee /etc/systemd/system/$PROJECT_NAME.service << EOF
[Unit]
Description=Nginx based application
After=docker.service
Requires=docker.service
[Service]
Restart=always
TimeoutStartSec=5s
ExecStartPre=-/usr/bin/docker kill $PROJECT_NAME
ExecStartPre=-/usr/bin/docker rm $PROJECT_NAME
ExecStart=/usr/bin/docker run --name $PROJECT_NAME -p 80:80 $DOCKER_IMAGE_NAME:$PROJECT_VERSION
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable $PROJECT_NAME.service
sudo systemctl restart $PROJECT_NAME.service