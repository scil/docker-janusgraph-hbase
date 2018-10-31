#!/bin/sh

docker run \
    -d \
    -p 8182:8182  \
    --add-host hbase-server:192.168.1.111  \
    --add-host es-server:192.168.1.111 \
      -e "JANUSGRAPH_TYPE=http"  \
     -e "JANUSGRAPH_VERSION=0.3.1"  \
    scil/janusgraph:latest
#    --add-host regionserver-1.vnet:192.168.1.111 \
#     --add-host regionserver-1:192.168.1.111 \
