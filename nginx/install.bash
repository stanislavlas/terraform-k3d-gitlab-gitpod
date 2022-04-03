#!/bin/bash

sed "s+<domain>+${DOMAIN}+g" "nginx/default.conf" > /etc/nginx/conf.d/default.conf
/usr/sbin/nginx -s reload
