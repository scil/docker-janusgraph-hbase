FROM openjdk:8

ENV JANUSGRAPH_VERSION=0.3.1
ENV JANUSGRAPH_TYPE=socket


# https://github.com/yhwang/docker-janusgraph/blob/034176944e1bfa2dbd44c14cd20473a35419321c/janusgraph/Dockerfile it also compile janusgraph
RUN \
    groupadd --gid 1000 janusgraph &&\
    useradd --uid 1000 --gid janusgraph --shell /bin/bash --create-home janusgraph  
#    && wget https://github.com/JanusGraph/janusgraph/releases/download/v$JANUSGRAPH_VERSION/janusgraph-$JANUSGRAPH_VERSION-hadoop2.zip -O /tmp/janusgraph-${JANUSGRAPH_VERSION}-hadoop2.zip


COPY janusgraph-${JANUSGRAPH_VERSION}-hadoop2.zip  /tmp/janusgraph-${JANUSGRAPH_VERSION}-hadoop2.zip

# https://github.com/channelit/docker-images/blob/master/janusgraph/Dockerfile
# https://blog.yiz96.com/janusgraph-setup/
RUN \
	mkdir -p /home/janusgraph &&\
	cd /home/janusgraph &&\
	unzip /tmp/janusgraph-${JANUSGRAPH_VERSION}-hadoop2.zip -d /home/janusgraph &&\
	rm /tmp/janusgraph-${JANUSGRAPH_VERSION}-hadoop2.zip &&\
	ln -s /home/janusgraph/janusgraph-${JANUSGRAPH_VERSION}-hadoop2 /home/janusgraph/janusgraph  &&\
       cd janusgraph 

WORKDIR /home/janusgraph/janusgraph

RUN \
	cd /home/janusgraph/janusgraph &&\
       cp conf/janusgraph-hbase-es.properties                                                               conf/gremlin-server/janusgraph-hbase-es-server.properties &&\
       sed -E -i '1igremlin.graph=org.janusgraph.core.JanusGraphFactory\'                 conf/gremlin-server/janusgraph-hbase-es-server.properties  &&\
        sed -E -i 's/storage\.hostname=.*$/storage\.hostname=hbase-server/'               conf/gremlin-server/janusgraph-hbase-es-server.properties &&\
        sed -E -i 's/index\.search\.hostname=.*$/index\.search\.hostname=es-server/'    conf/gremlin-server/janusgraph-hbase-es-server.properties &&\
        cp conf/gremlin-server/gremlin-server.yaml                                                         conf/gremlin-server/socket-hbase-es-server.yaml &&\
        sed -E -i 's/janusgraph-cql-es-server/janusgraph-hbase-es-server/'                     conf/gremlin-server/socket-hbase-es-server.yaml &&\
        cp conf/gremlin-server/gremlin-server.yaml                                                         conf/gremlin-server/http-hbase-es-server.yaml  &&\
        sed -E -i 's/janusgraph-cql-es-server/janusgraph-hbase-es-server/'                     conf/gremlin-server/http-hbase-es-server.yaml &&\
        sed -E -i 's/channel\.WebSocketChannelizer/channel\.HttpChannelizer/'               conf/gremlin-server/http-hbase-es-server.yaml 


EXPOSE 8182

VOLUME /home/janusgraph/janusgraph/conf/gremlin-server
VOLUME /home/janusgraph/janusgraph/scripts

# How can I use a variable inside a Dockerfile CMD? https://stackoverflow.com/questions/40454470/how-can-i-use-a-variable-inside-a-dockerfile-cmd
# Dockerfile if else condition with external arguments https://stackoverflow.com/questions/43654656/dockerfile-if-else-condition-with-external-arguments
CMD  if [ "x$JANUSGRAPH_TYPE" = "console" ] ; then  bin/gremlin.sh ; else   ./bin/gremlin-server.sh  ./conf/gremlin-server/${JANUSGRAPH_TYPE}-hbase-es-server.yaml  ; fi

