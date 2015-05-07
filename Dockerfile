FROM lotustm/nginx

ADD ./build /var/www/kotsu.2bad.me/www
RUN /etc/nginx/bin/set-vhost-name.sh kotsu.2bad.me