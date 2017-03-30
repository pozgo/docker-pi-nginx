FROM polinux/pi-supervisor

ENV \
  NGINX_VERSION=1.11.9 \
  NGINX_GENERATE_DEFAULT_VHOST=false \
  STATUS_PAGE_ALLOWED_IP=127.0.0.1

RUN \
  apk add --update \
    build-base \
    gcc \
    g++ \
    abuild \
    binutils \
    binutils-doc \
    gcc-doc \
    wget \
    unzip \
    openssl \
    openssl-dev \
    shadow \
    pcre \
    pcre-dev \
    inotify-tools \
    zlib \
    zlib-dev && \
  mkdir -p /tmp/nginx && \
  cd /tmp/ && wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
  tar zxf nginx-${NGINX_VERSION}.tar.gz -C /tmp/nginx --strip-components=1 && \
  cd /tmp/nginx && \
  ./configure \
    --user=www \
    --group=www \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --with-http_gzip_static_module \
    --with-http_stub_status_module \
    --with-http_ssl_module \
    --with-pcre \
    --with-http_realip_module \
    --with-http_v2_module \
    --with-debug && \
  make && make install && \
  rm -rf /tmp/nginx && \
  addgroup -g 101 www && \
  adduser -u 101 -G www -h /data/www -s /bin/bash www -D  && \
  rm -rf /etc/nginx/*.d /etc/nginx/*_params && \
  mkdir -p /etc/nginx/ssl && \
  openssl genrsa -out /etc/nginx/ssl/dummy.key 2048 && \
  openssl req -new -key /etc/nginx/ssl/dummy.key -out /etc/nginx/ssl/dummy.csr -subj "/C=GB/L=London/O=Company Ltd/CN=docker" && \
  openssl x509 -req -days 3650 -in /etc/nginx/ssl/dummy.csr -signkey /etc/nginx/ssl/dummy.key -out /etc/nginx/ssl/dummy.crt && \
  apk del \
    abuild \
    binutils \
    binutils-doc \
    gcc-doc \
    unzip \
    openssl-dev \
    pcre-dev \
    zlib-dev && \
  rm -rf /var/cache/apk/*

COPY container-files /

EXPOSE 80 81 443
