#!/bin/bash

# Install Nginx
sudo yum install -y nginx
sudo service nginx start
sudo chkconfig nginx on