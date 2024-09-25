#!/bin/bash

# Update/Install required OS packages
yum update -y
yum install -y httpd wget php-fpm php-mysqli php-json php php-devel telnet tree git
amazon-linux-extras install -y php7.2 epel
yum install -y mysql php-mtdowling-jmespath-php php-xml

# Deploy PHP app
cd /tmp
git clone https://github.com/kledsonhugo/app-notifier
cp /tmp/app-notifier/*.php /var/www/html/
rm -rf /tmp/app-notifier

# Config Apache WebServer
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
