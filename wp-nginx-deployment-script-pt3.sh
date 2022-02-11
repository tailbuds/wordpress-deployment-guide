#!/bin/bash

wget http://nginx.org/download/nginx-1.19.10.tar.gz
tar -xzvf nginx-1.19.10.tar.gz

cd nginx-1.19.10

sudo mkdir modules-thirdparty
cd modules-thirdparty

sudo apt install brotli libbrotli-dev

sudo wget -O 'ngx_brotli-1.0.0.tar.gz' https://github.com/google/ngx_brotli/archive/refs/tags/v1.0.0rc.tar.gz
sudo tar -xzvf ngx_brotli-1.0.0.tar.gz

sudo wget -O 'ngx_cache_purge-2.3.0.tar.gz' https://github.com/FRiCKLE/ngx_cache_purge/archive/refs/tags/2.3.tar.gz
sudo tar -xzvf ngx_cache_purge-2.3.0.tar.gz

sudo apt install libmaxminddb-dev libgeoip-dev -y

sudo wget -O 'ngx_http_geoip2_module-3.3.0.tar.gz' https://github.com/leev/ngx_http_geoip2_module/archive/refs/tags/3.3.tar.gz
sudo tar -xzvf ngx_http_geoip2_module-3.3.0.tar.gz

sudo add-apt-repository -y ppa:maxmind/ppa
sudo apt-get update
sudo apt-get install -y libmaxminddb-dev

sudo apt-get install -y geoipupdate

sudo nano /etc/GeoIP.conf

sudo echo '30 0 * * 6 root /usr/bin/geoipupdate -v
' | sudo tee -a /etc/cron.d/geoipupdate

sudo geoipupdate -v

sudo apt install build-essential zlib1g-dev libpcre3 libpcre3-dev unzip uuid-dev -y

sudo wget -O 'incubator-pagespeed-ngx-1.13.35.tar.gz' https://github.com/apache/incubator-pagespeed-ngx/archive/refs/tags/v1.13.35.2-stable.tar.gz
sudo tar -xzvf incubator-pagespeed-ngx-1.13.35.tar.gz

cd incubator-pagespeed-ngx-1.13.35.2-stable/
sudo wget https://dl.google.com/dl/page-speed/psol/1.13.35.2-x64.tar.gz
sudo tar -xzvf 1.13.35.2-x64.tar.gz

cd

sudo apt-get install libjpeg-dev libpng-dev libtiff-dev libgif-dev

sudo wget -O 'libwebp-1.2.0.tar.gz' https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-1.2.0.tar.gz
sudo tar -xzvf libwebp-1.2.0.tar.gz

cd libwebp-1.2.0/
sudo ./configure
sudo make
sudo make install

cd ../nginx-1.19.10/modules-thirdparty/

sudo wget -O 'ngx_webp.zip' https://github.com/vladbondarenko/ngx_webp/archive/refs/heads/master.zip

sudo unzip ngx_webp.zip

sudo nano ngx_webp-master/src/ngx_http_webp_module.c

cd ..

sudo ./configure --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/etc/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=www-data \
    --group=www-data \
    --with-file-aio \
    --with-threads \
    --with-http_xslt_module=dynamic \
    --with-http_image_filter_module=dynamic \
    --with-http_geoip_module=dynamic \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-mail \
    --with-mail_ssl_module \
    --without-mail_pop3_module \
    --with-stream \
    --with-stream_realip_module \
    --with-stream_ssl_module \
    --with-stream_geoip_module=dynamic \
    --with-stream_ssl_preread_module \
    --with-pcre=../pcre-8.44 \
    --with-pcre-jit \
    --with-zlib=../zlib-1.2.11 \
    --with-compat \
    --add-module=./modules-thirdparty/ngx_webp-master \
    --add-dynamic-module=./modules-thirdparty/ngx_brotli-1.0.0rc \
    --add-dynamic-module=./modules-thirdparty/ngx_cache_purge-2.3 \
    --add-dynamic-module=./modules-thirdparty/ngx_http_geoip2_module-3.3 \
    --add-dynamic-module=./modules-thirdparty/incubator-pagespeed-ngx-1.13.35.2-stable \
    --with-cc=/usr/bin/gcc \
    --with-cc-opt='-g -O2 -fPIE -fstack-protector-strong -Wformat -Werror=format-security -fPIC -Wdate-time -D_FORTIFY_SOURCE=2' \
    --with-ld-opt='-Wl,-Bsymbolic-functions -fPIE -pie -Wl,-z,relro -Wl,-z,now -fPIC -static-libstdc++'

sudo make

sudo make install

cd /usr/sbin
sudo ln -s /usr/share/nginx/sbin/nginx nginx
sudo mkdir /usr/share/nginx/
cd /usr/share/nginx/
sudo ln -s /etc/nginx/modules modules
sudo mkdir -p /var/lib/nginx/body

echo '
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/usr/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
' | sudo tee -a /lib/systemd/system/nginx.service

sudo apt install software-properties-common -y
sudo add-apt-repository ppa:ondrej/php -y
sudo add-apt-repository ppa:ondrej/nginx-mainline -y
sudo apt update -y
sudo apt install php8.0 -y
sudo apt install php8.0-fpm php8.0-common php8.0-cli php8.0-dev php8.0-imap php8.0-soap php8.0-redis php8.0-xmlrpc php8.0-pdo php8.0-mysql php8.0-zip php8.0-mbstring php8.0-curl php8.0-xml php8.0-bcmath php8.0-imagick php8.0-gd -y
sudo nano /etc/php/8.0/fpm/pool.d/www.conf