#!/bin/sh

# first try to remove old items 
sudo sed -i -E 's/^.+vnet (hmaster|regionserver)-1$//' /etc/hosts
#sudo sed -i -E 's/^.*elasticsearch$//' /etc/hosts &&  sudo sed -i -E 's/^.*es-server$//' /etc/hosts

# delete blank lines
sudo sed -i '/^$/d' /etc/hosts

# add hmaster-1 and regionserver-1 to avoid error like `java.net.UnknownHostException: hmaster-1.vnet`
IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' regionserver-1` &&  echo $IP  regionserver-1.vnet regionserver-1 | sudo tee -a /etc/hosts
IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' hmaster-1` &&  echo $IP hmaster-1.vnet hmaster-1 | sudo tee -a /etc/hosts

# necessary?
# IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' zookeeper-1` &&  echo $IP  zookeeper-1.vnet zookeeper-1 | sudo tee -a /etc/hosts

# IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' elasticsearch` &&  echo $IP  elasticsearch.vnet elasticsearch| sudo tee -a /etc/hosts
# IP=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' elasticsearch` &&  echo $IP  es-server| sudo tee -a /etc/hosts

