# Quick Start

require:  
1. docker
2. docker-compose

```
docker network create vnet

#  If you'd like a websocket server, just set env: `JANUSGRAPH_TYPE=socket`.
docker-compose up -d

```

wait enough time and test
```
curl -XPOST -Hcontent-type:application/json -d '{"gremlin":"g.V().values(\"name\")"}' http://localhost:8182
# response looks like :
#	curl: (56) Recv failure: Connection reset by peer
# after enough time:
#	{"requestId":"fd1abb80-7684-4a95-ae77-77c9c4b1be6d","status":{"message":"","code":200,"attributes":{"@type":"g:Map","@value":[]}},"result":{"data":{"@type":"g:List","@value":[]},"meta":{"@type":"g:Map","@value":[]}}}
```

If something goes wrong
```
#ensure /etc/hosts is right
cat /etc/hosts  && echo hmaster-1-IP, regionserver-1-IP = `docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' hmaster-1 regionserver-1` 

docker-compose ps

docker logs [service-name]

```

Try ` docker-compose stop && docker-compose rm && docker-compose up -d`  [How to rebuild docker container in docker-compose.yml?](https://stackoverflow.com/questions/36884991/how-to-rebuild-docker-container-in-docker-compose-yml)  
if logs contain 
```
regionserver-1     | 2018-11-02 08:28:22,414 WARN  [regionserver/regionserver-1.vnet/172.18.0.7:16020.logRoller] wal.FSHLog: Too many consecutive RollWriter requests, it's a sign of the total number of live datanodes is lower than the tolerable replicas.
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

## 2. edit run.sh and execute it 

```
./run.sh 
```
 
two hosts must be given   
```
--add-host hbase-server:192.168.1.110  
--add-host es-server:192.168.1.111 
```  
192.168.1.111 is where you elasticsearch server , ensure `network.host:  0.0.0.0` in  elasticsearch.yml

If can download janusgraph-${JANUSGRAPH_VERSION}-hadoop2.zip to here, otherwise Dockerfile will use wget.

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

test socket( ENV JANUSGRAPH_TYPE=socket)
```
# bin/gremlin.sh
# https://docs.janusgraph.org/0.3.1/server.html
:remote connect tinkerpop.server conf/remote.yaml session
:> g.V().values('name')
```

# if not using service janusgraph

```
JANUSGRAPH_VERSION=0.3.1
# both, http or socket
JANUSGRAPH_TYPE=both
JANUSGRAPH_DIR=/opt/janus

mkdir -p $JANUSGRAPH_DIR
wget https://github.com/JanusGraph/janusgraph/releases/download/v$JANUSGRAPH_VERSION/janusgraph-$JANUSGRAPH_VERSION-hadoop2.zip -O /tmp/janusgraph-${JANUSGRAPH_VERSION}-hadoop2.zip
unzip /tmp/janusgraph-${JANUSGRAPH_VERSION}-hadoop2.zip -d $JANUSGRAPH_DIR &&\
cd $JANUSGRAPH_DIR/janusgraph &&\

cp conf/janusgraph-hbase-es.properties                                                               conf/gremlin-server/janusgraph-hbase-es-server.properties &&\
sed -E -i '1igremlin.graph=org.janusgraph.core.JanusGraphFactory\'                  conf/gremlin-server/janusgraph-hbase-es-server.properties  &&\
sed -E -i 's/storage\.hostname=.*$/storage\.hostname=hbase-server/'               conf/gremlin-server/janusgraph-hbase-es-server.properties &&\
sed -E -i 's/index\.search\.hostname=.*$/index\.search\.hostname=es-server/'    conf/gremlin-server/janusgraph-hbase-es-server.properties

cp conf/gremlin-server/gremlin-server.yaml                                                         conf/gremlin-server/socket-hbase-es-server.yaml &&\
sed -E -i 's/janusgraph-cql-es-server/janusgraph-hbase-es-server/'                     conf/gremlin-server/socket-hbase-es-server.yaml 

cp conf/gremlin-server/gremlin-server.yaml                                                         conf/gremlin-server/http-hbase-es-server.yaml  &&\
sed -E -i 's/janusgraph-cql-es-server/janusgraph-hbase-es-server/'                     conf/gremlin-server/http-hbase-es-server.yaml &&\
sed -E -i 's/channel\.WebSocketChannelizer/channel\.HttpChannelizer/'               conf/gremlin-server/http-hbase-es-server.yaml 

cp conf/gremlin-server/gremlin-server.yaml                                                         conf/gremlin-server/both-hbase-es-server.yaml  &&\
sed -E -i 's/janusgraph-cql-es-server/janusgraph-hbase-es-server/'                     conf/gremlin-server/both-hbase-es-server.yaml &&\
sed -E -i 's/channel\.WebSocketChannelizer/channel\.WsAndHttpChannelizer/'               conf/gremlin-server/both-hbase-es-server.yaml 

./bin/gremlin-server.sh  ./conf/gremlin-server/${JANUSGRAPH_TYPE}-hbase-es-server.yaml 

```