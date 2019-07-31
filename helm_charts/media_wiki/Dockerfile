FROM php:7.4.0beta1-zts-alpine

WORKDIR /media-wiki

RUN apk add wget tar mariadb nginx && \
    wget https://releases.wikimedia.org/mediawiki/1.33/mediawiki-1.33.0.tar.gz && \
    tar -xzf mediawiki-1.33.0.tar.gz && \
    rm -rf mediawiki-1.33.0.tar.gz && \
    mkdir /run/nginx
ADD configs/nginx.conf /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]