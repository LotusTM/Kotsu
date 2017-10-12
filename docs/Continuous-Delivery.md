# Continuous Delivery with Wercker Docker and CoreOS

1. [Docker Hub](https://hub.docker.com)  
  a) Register an account  
  b) Create an organization (ex. LotusTM)  
  c) Create a repo (ex. Kotsu) (Note: you must have owner rights on repo)  
2. [Wercker](http://wercker.com)  
  a) Register an account  
  b) Create an app  
  c) Go to Settings and set following **protected** environment variables in `Pipeline` section:
    * `DOCKER_USER` - your username on hub.docker.com
    * `DOCKER_PASSWORD` - your password...
    * `DOCKER_EMAIL` - your email...
    * `DOCKER_IMAGE_NAME` - image name in following format org/repo (Note: you should not specify sha fingerprint here)

  d) Generate new SSH Key pair in `SSH keys` section and save the public key
3. [Digital Ocean](https://digitalocean.com)  
  a) Register an account  
  b) Add SSH public key from step 2.d in `SSH Keys` section  
  c) Create a Droplet with CoreOS (stable or beta channel) (Note: you should select public key from step 3.b)  
4. Configure Deploy step in Wercker  
  a) Create a `Custom deploy` target in `Deploy targets` section (ex. Kotsu)  
  b) Add following **protected** environment variables to `Deploy pipeline`
    * `DEPLOY_SERVER` - put IP address of server from step 3.c
    * `SERVER_KEY` - select SSH key from step 2.d

  c) Enable auto deploy for production or master branch
5. Add to the project `Dockerfile` with next content:
```
FROM dockerfile/nginx
ADD ./build/ /var/www/html
```
6. Add next steps to the end of **build section** in your wercker.yml:
```
    - script:
        name: update docker
        code: curl -sSL https://get.docker.io/ubuntu/ | sudo sh
    - script:
        name: build image
        code: sudo docker build -t $DOCKER_IMAGE_NAME:$WERCKER_GIT_COMMIT .
    - script:
        name: login to docker hub
        code: sudo docker login -u $DOCKER_USER -p $DOCKER_PASSWORD -e $DOCKER_EMAIL
    - script:
        name: push image
        code: sudo docker push $DOCKER_IMAGE_NAME:$WERCKER_GIT_COMMIT
```
7. Add **deploy section** to your wercker.yml:
```
deploy:
  steps:
    - add-ssh-key:
        keyname: SERVER_KEY
    - add-to-known_hosts:
        hostname: $DEPLOY_SERVER
    - mktemp:
        name: temp service file
        envvar: SERVICE_PATH
    - create-file:
        name: service file
        filename: $SERVICE_PATH
        overwrite: true
        content: |
          [Unit]
          Description=Nginx based application
          After=docker.service
          Requires=docker.service
          [Service]
          Restart=always
          TimeoutStartSec=5s
          ExecStartPre=-/usr/bin/docker kill $WERCKER_APPLICATION_NAME
          ExecStartPre=-/usr/bin/docker rm $WERCKER_APPLICATION_NAME
          ExecStart=/usr/bin/docker run --name $WERCKER_APPLICATION_NAME -p 80:80 $DOCKER_IMAGE_NAME:$WERCKER_GIT_COMMIT
          [Install]
          WantedBy=multi-user.target
    - script:
        name: copy service file
        code: scp $SERVICE_PATH core@$DEPLOY_SERVER:/home/core/$WERCKER_APPLICATION_NAME.service
    - script:
        name: login to docker hub
        code: ssh core@$DEPLOY_SERVER docker login -u $DOCKER_USER -p $DOCKER_PASSWORD -e $DOCKER_EMAIL
    - script:
        name: download image
        code: ssh core@$DEPLOY_SERVER docker pull $DOCKER_IMAGE_NAME:$WERCKER_GIT_COMMIT
    - script:
        name: link service file
        code: ssh core@$DEPLOY_SERVER sudo mv /home/core/$WERCKER_APPLICATION_NAME.service /etc/systemd/system/$WERCKER_APPLICATION_NAME.service
    - script:
        name: reload systemd
        code: ssh core@$DEPLOY_SERVER sudo systemctl daemon-reload
    - script:
        name: enable service
        code: ssh core@$DEPLOY_SERVER sudo systemctl enable $WERCKER_APPLICATION_NAME.service
    - script:
        name: restart service
        code: ssh core@$DEPLOY_SERVER sudo systemctl restart $WERCKER_APPLICATION_NAME.service
```