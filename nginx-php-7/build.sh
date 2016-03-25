#!/bin/bash
docker build -t keytec/drupal-nginx-php:php-7.0 .
docker push keytec/drupal-nginx-php:php-7.0