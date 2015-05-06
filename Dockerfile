FROM lotustm/nginx

ADD ./build /var/www/kotsu.2bad.me/www
RUN /etc/nginx/bin/update-site-name.sh