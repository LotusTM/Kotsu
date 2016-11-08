FROM lotustm/nginx

ENV VHOST_NAME $VHOST_NAME

ADD ./build /var/domains/$VHOST_NAME/www
RUN sed -i "s/example.com/$VHOST_NAME/g" /etc/nginx/sites-enabled/default.conf
RUN echo /etc/nginx/sites-enabled/default.conf
RUN tree /var/domains/