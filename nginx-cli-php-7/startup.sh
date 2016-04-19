#!/bin/bash

ENV_CONF=/etc/php/7.0/fpm/pool.d/env.conf

echo "Configuring Nginx and PHP7-FPM with environment variables"

# Update php7-fpm with access to Docker environment variables
echo '[www]' > $ENV_CONF
for var in $(env | awk -F= '{print $1}')
do
	echo "Adding variable {$var}"
	if [ ! -z "${!var}" ]; then
	    echo "env[${var}] = \"${!var}\"" >> $ENV_CONF
	fi;
done