## gremlin-python

install plugin python
```
# china
https_proxy=192.168.1.108:8580

# janusgraph 0.3.1 goes with tinkerpop 3.3.3
#  -i works， new version tinkerpop's  install not working
bin/gremlin-server.sh -i org.apache. tinkerpop gremlin-python 3.3.3


https_proxy=
```

edit yaml
```
scriptEngines: {
  gremlin-groovy: {
    imports: [java.lang.Math],
    staticImports: [java.lang.Math.PI],
    scripts: [scripts/empty-sample.groovy]},
  gremlin-jython: {},
  gremlin-python: {}
}


# for ipython-gremlin , add this line to processors:
# https://github.com/davebshow/ipython-gremlin/issues/1
  - { className: org.apache.tinkerpop.gremlin.server.op.standard.StandardOpProcessor, config: { maxParameters: 64 }}
```

start server
```
docker-compose up -d

# wait services
sleep 1m

#  alias jserver="$JANUSGRAPH_LOC/bin/gremlin-server.sh  $JANUSGRAPH_LOC/conf/gremlin-server/${JANUSGRAPH_TYPE}-hbase-es-server.yaml"
jserver
```


python
```
# pip install gremlinpython==3.3.3
# pipenv
pipenv install gremlinpython==3.3.3

# ipython-gremlin https://ipython-gremlin.readthedocs.io/en/latest/
pipenv install ipython-gremlin 
pipenv pandas networkx matplotlib 
pipenv run jupyter notebook --ip=0.0.0.0

```

python console or notebook
```
from gremlin_python import statics
from gremlin_python.structure.graph import Graph
from gremlin_python.process.graph_traversal import __
from gremlin_python.process.strategies import *
from gremlin_python.driver.driver_remote_connection import DriverRemoteConnection
graph = Graph()
g = graph.traversal().withRemote(DriverRemoteConnection('ws://192.168.1.111:8182/gremlin','g'))
print(g)
g.V().count().next()
12
g.addV('god').property('name', 'mars').property('age', 3500).next()
g.V().count().next()
```

using ipython-gremlin in python notebook 
```
%reload_ext gremlin
%gremlin.connection.set_current ws://192.168.1.111:8182/gremlin
verts = %gremlin g.V()
df = verts.get_dataframe()

import matplotlib.pyplot as plt
plt.rcParams['figure.figsize'] = (18, 12)

# first run codes in this script: https://github.com/davebshow/ipython-gremlin/blob/master/draw_graph.py
draw_simple_graph( verts.get_graph(),
                  node_type_attr='label',
                  edge_label_attr='',
                  show_edge_labels=False,
                  label_attrs=['name'],
                  k=0.005)

```
