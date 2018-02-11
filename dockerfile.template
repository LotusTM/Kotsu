FROM lotustm/nginx

ENV SITENAME $SITENAME

COPY build /var/domains/$SITENAME/www
RUN sed -i "s/example.com/$SITENAME/g" /etc/nginx/sites-enabled/default.conf
