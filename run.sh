#!/bin/bash

autoremoval() {
  while true; do
    sleep 60
    if [[ $(df -h /etc/opt/kerberosio/capture | tail -1 | awk -F' ' '{ print $5/1 }' | tr ['%'] ["0"]) -gt 90 ]];
    then
      echo "Cleaning disk"
      find /etc/opt/kerberosio/capture/ -type f | sort | head -n 100 | xargs rm;
    fi;
  done
}

#Set web login
if [ -n "$USERNAME" ] && [ -n "$PASSWORD" ];
then
    sed -i "s/.*'installed' => false,.*/'installed'\ \=\>\ true\,/" /var/www/web/config/kerberos.php
    sed -i "s/.*'username' => 'root',.*/'username'\ \=\>\ \'$USERNAME\'\,/" /var/www/web/config/kerberos.php
    sed -i "s/.*'password' => 'root',.*/'password'\ \=\>\ \'$PASSWORD\'\,/" /var/www/web/config/kerberos.php
fi;

# changes for php 7.0
#echo "[www]" > /etc/php/7.0/fpm/pool.d/env.conf
#echo "" >> /etc/php/7.0/fpm/pool.d/env.conf
#env | grep "KERBEROSIO_" | sed "s/\(.*\)=\(.*\)/env[\1]='\2'/" >> /etc/php/7.0/fpm/pool.d/env.conf
#service php7.0-fpm start

copyConfigFiles() {
  # Check if the config dir is empty, this can happen due to mapping
  # an empty filesystem to the volume.
  TEMPLATE_DIR=/etc/opt/kerberosio/template
  CONFIG_DIR=/etc/opt/kerberosio/config
  if [ "$(ls -A $CONFIG_DIR)" ]; then
       echo "Config files are availble"
  else
      cp /etc/opt/kerberosio/config/* /etc/opt/kerberosio/template/
  fi
}

# replace SESSION_COOKIE_NAME
random=$((1+RANDOM%10000))
sed -i -e "s/kerberosio_session/kerberosio_session_$random/" /var/www/web/.env

autoremoval &
copyConfigFiles &

# Add environments vars to php
env | grep "KERBEROSIO_" | sed "s/\(.*\)=\(.*\)/env[\1]='\2'/" >> /etc/php7/php-fpm.d/www.conf

/usr/bin/supervisord -n -c /etc/supervisord.conf
