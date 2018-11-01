# Quick Start

require:  
1. docker
2. docker-compose

```
docker network create vnet
docker-compose up -d
```

# Step by Step

## 1. build

build gremlin-server
```
docker image build -t scil/janusgraph .
```

build console
```
docker image build -t scil/janusgraph-console .  --build-arg console=true
```

## 2. run

```
./run.sh 
```
 
two hosts must be given   
```
--add-host hbase-server:192.168.1.110  
--add-host es-server:192.168.1.111 
```  
192.168.1.111 is where you elasticsearch server , ensure `network.host:  0.0.0.0` in  elasticsearch.yml

You can also use -v <conf dir>:/home/janusgraph/janusgraph/conf/gremlin-server to use your own conf files for the JanusGraph server. The following files are used by JanusGraph Server in that directory:
 
     janusgraph-hbase-es-server.properties 
     socket-hbase-es-server.yaml 
     http-hbase-es-server.yaml 
     log4j-server.properties

If you need to adjust the java heap size for the JanusGraph Server Java process, you can use -e to specify the JAVA_OPTIONS like this:  
`-e "JAVA_OPTIONS=-Xms2048m -Xmx2048m"`  
This will assign 2GB for the java heap. 

Thanks to https://hub.docker.com/r/yihongwang/janusgraph-server/ which is about janusgraph and cassandra (not hbase)


## 3. docker compose

use `docker-compose.yml` produced by [docker-hbase](https://github.com/scil/docker-hbase)  and  run   
` docker-compose up janusgraph -d`  
or  
` docker-compose start janusgraph `  

##  Sollution 1: add a service

```
  janusgraph:
    container_name: janusgraph
    networks: ["vnet"]
    hostname: janusgraph
    links:
      - "zookeeper-1:hbase-server"
    extra_hosts:
      # - "hbase-server:172.18.x.xxx"
      - "es-server:192.168.1.111"
    depends_on:
      zookeeper-1:
      elasticsearch:
        - condition: service_healthy
    volumes:
      - /vagrant/vendors/janusgraph-0.3.1-hadoop2/conf/gremlin-server:/home/janusgraph/janusgraph/conf/gremlin-server
    image: scil/janusgraph:latest
    ports: ["8182:8182"]
    environment:
      - JANUSGRAPH_TYPE=http
      - JANUSGRAPH_VERSION=0.3.1
```

192.168.1.111 is where you elasticsearch server , ensure `network.host:  0.0.0.0` in  elasticsearch.yml and `vm.max_map_count=655360` in `/etc/sysctl.conf`. 

##  Sollution 2: use service elasticsearch

See `docker-compose.yml`.

Thanks to [janusgraph-dist-hadoop-2/docker-compose](https://github.com/JanusGraph/janusgraph/blob/d12adfbf083f575fa48860daa37bfbd0e6095369/janusgraph-dist/janusgraph-dist-hadoop-2/docker-compose.yml)

## 4. test

test elasticsearch
```
curl http://localhost:9200
```

test http (ENV JANUSGRAPH_TYPE=http)
```
curl -XPOST -Hcontent-type:application/json -d '{"gremlin":"g.V().values(\"name\")"}' http://localhost:8182
```
