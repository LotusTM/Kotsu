FROM lotustm/nginx

ADD ./build /var/domains/${VHOST_NAME}/www
RUN sed -i "s/example.com/${VHOST_NAME}/g" /etc/nginx/sites-enabled/default.conf