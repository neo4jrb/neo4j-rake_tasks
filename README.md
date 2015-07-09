
Rake tasks for managing a Neo4j database with your Ruby project


Rake Tasks
==========

The ``neo4j-rake_tasks`` gem (automatically included with the ``neo4j`` gem) includes some rake tasks which make it easy to install and manage a Neo4j server in the same directory as your Ruby project.

## neo4j:install

### Arguments

``version`` and ``environment`` (environment default is `development`)

### Example

``rake neo4j:install[community-latest,development]``

... or to get a specific version

``rake neo4j:install[community-2.2.3,development]``

### Description

  Downloads and installs Neo4j into ``$PROJECT_DIR/db/neo4j/<environment>/``

## neo4j:config

### Arguments

``environment`` and ``port``

### Example

``rake neo4j:config[development,7000]``

### Description

  Configure the port which Neo4j runs on.  This affects the HTTP REST interface and the web console address.


## neo4j:start

### Arguments

``environment``

### Example

``rake neo4j:start[development]``

### Description

  Start the Neo4j server


## neo4j:start_no_wait

### Arguments

``environment``

### Example

``rake neo4j:start_no_wait[development]``

### Description

  Start the Neo4j server with the ``start-no-wait`` command

## neo4j:stop

### Arguments

``environment``

### Example

``rake neo4j:stop[development]``

### Description

  Stop the Neo4j server


