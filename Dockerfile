FROM nginx:alpine AS builder

ENV NGINX_VERSION 1.20.0
ENV SOURCE=http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz


RUN apk --update add openssl-dev pcre-dev zlib-dev wget build-base && \
    wget $SOURCE && \
    tar -zxvf nginx-${NGINX_VERSION}.tar.gz && \
    cd nginx-${NGINX_VERSION} && \
    ./configure \
        --with-http_ssl_module \
        --with-http_gzip_static_module \
        --prefix=/etc/nginx \
        --http-log-path=/var/log/nginx/access.log \
        --error-log-path=/var/log/nginx/error.log \
        --sbin-path=/usr/local/sbin/nginx && \
    make && \
    make install

FROM nginx:alpine

RUN apk --update add openssl && \
    openssl req -x509 -nodes -days 365 \
    -subj  "/C=BL/ST=RF/O=Company Inc/CN=palmapalermo-test.com" \
     -newkey rsa:2048 -keyout /etc/nginx/palmapalermo-test.com.key \
     -out /etc/nginx/palmapalermo-test.com.crt;

COPY --from=builder /usr/local/bin  /usr/local/bin
COPY nginx.conf /etc/nginx/nginx.conf
RUN chown -R nginx: /etc/nginx /var/cache/nginx
RUN chmod 777 /etc/nginx /var/cache/nginx /var/run

EXPOSE 80:443

USER nginx

CMD ["nginx", "-g", "daemon off;"]


