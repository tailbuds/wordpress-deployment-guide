#!/bin/bash

sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https

sudo ufw enable -y

sudo apt install fail2ban -y

sudo systemctl enable fail2ban
sudo systemctl start fail2ban

sudo apt install libxml2 libxslt-dev libgd-dev libbz2-dev libreadline-dev build-essential checkinstall autotools-dev git libpcre3-dev zlib1g-dev libssl-dev libxslt1-dev ca-certificates -y

echo "ca_directory=/etc/ssl/certs" | sudo tee -a /etc/wgetrc

#PCRE
wget https://ftp.pcre.org/pub/pcre/pcre-8.44.tar.gz
tar -zxf pcre-8.44.tar.gz
cd pcre-8.44
./configure --prefix=/usr \
--docdir=/usr/share/doc/pcre-8.44 \
--enable-unicode-properties \
--enable-pcre16 \
--enable-pcre32 \
--enable-pcregrep-libz \
--enable-pcregrep-libbz2 \
--enable-pcretest-libreadline \
--enable-jit \
--disable-static &&
    make
sudo make install
cd ..

#Z-lib
wget http://zlib.net/zlib-1.2.11.tar.gz
tar -zxf zlib-1.2.11.tar.gz
cd zlib-1.2.11
./configure
make
sudo make install
cd ..

#
wget https://www.openssl.org/source/openssl-1.1.1k.tar.gz
tar -zxf openssl-1.1.1k.tar.gz
cd openssl-1.1.1k
./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl shared zlib
make
make test
sudo make install
cd ..
echo '/usr/local/ssl/lib' | sudo tee -a /etc/ld.so.conf.d/openssl-1.1.1k.conf
sudo ldconfig -v
sudo mv /usr/bin/c_rehash /usr/bin/c_rehash.BEKUP
sudo mv /usr/bin/openssl /usr/bin/openssl.BEKUP
echo ':/usr/local/ssl/lib' | sudo tee -a /etc/environment
