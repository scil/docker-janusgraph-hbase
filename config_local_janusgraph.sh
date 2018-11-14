#!/bin/sh

# JANUSGRAPH_VERSION=0.3.1
# http socket or both
# export JANUSGRAPH_TYPE=both

# JANUSGRAPH_DIR=/opt/janus
# mkdir -p $JANUSGRAPH_DIR
# wget https://github.com/JanusGraph/janusgraph/releases/download/v$JANUSGRAPH_VERSION/janusgraph-$JANUSGRAPH_VERSION-hadoop2.zip -O /tmp/janusgraph-${JANUSGRAPH_VERSION}-hadoop2.zip
# 
# unzip /tmp/janusgraph-${JANUSGRAPH_VERSION}-hadoop2.zip -d $JANUSGRAPH_DIR &&\
# $JANUSGRAPH_LOC=$JANUSGRAPH_DIR/janusgraph 


cd $JANUSGRAPH_LOC

cp conf/janusgraph-hbase-es.properties                                                               conf/gremlin-server/janusgraph-hbase-es-server.properties &&\
sed -E -i '1igremlin.graph=org.janusgraph.core.JanusGraphFactory\'                  conf/gremlin-server/janusgraph-hbase-es-server.properties  &&\
sed -E -i 's/index\.search\.hostname=.*$/index\.search\.hostname=es-server/'    conf/gremlin-server/janusgraph-hbase-es-server.properties

cp conf/gremlin-server/gremlin-server.yaml                                                         conf/gremlin-server/socket-hbase-es-server.yaml &&\
sed -E -i 's/janusgraph-cql-es-server/janusgraph-hbase-es-server/'                     conf/gremlin-server/socket-hbase-es-server.yaml 

cp conf/gremlin-server/gremlin-server.yaml                                                         conf/gremlin-server/http-hbase-es-server.yaml  &&\
sed -E -i 's/janusgraph-cql-es-server/janusgraph-hbase-es-server/'                     conf/gremlin-server/http-hbase-es-server.yaml &&\
sed -E -i 's/channel\.WebSocketChannelizer/channel\.HttpChannelizer/'               conf/gremlin-server/http-hbase-es-server.yaml 

cp conf/gremlin-server/gremlin-server.yaml                                                         conf/gremlin-server/both-hbase-es-server.yaml  &&\
sed -E -i 's/janusgraph-cql-es-server/janusgraph-hbase-es-server/'                     conf/gremlin-server/both-hbase-es-server.yaml &&\
sed -E -i 's/channel\.WebSocketChannelizer/channel\.WsAndHttpChannelizer/'               conf/gremlin-server/both-hbase-es-server.yaml 

#./bin/gremlin-server.sh  ./conf/gremlin-server/${JANUSGRAPH_TYPE}-hbase-es-server.yaml 

