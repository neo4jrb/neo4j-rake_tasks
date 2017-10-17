
Rake tasks for managing a Neo4j database with your Ruby project

[![Actively Maintained](https://img.shields.io/badge/Maintenance%20Level-Actively%20Maintained-green.svg)](https://gist.github.com/cheerfulstoic/d107229326a01ff0f333a1d3476e068d)

Rake Tasks
==========

The ``neo4j-rake_tasks`` gem includes some rake tasks which make it easy to install and manage a Neo4j server in the same directory as your Ruby project.

WARNING: NOT FOR PRODUCTION USE!  These rake tasks are intended to make installing and managing a Neo4j server in development and testing easier.  Since authentication is disabled by default, this gem should not be used in production.  If you need Neo4j in production, installation can be as easy as downloading, unzipping, and running the executable.

NOTE: The ``neo4j-rake_tasks`` gem used to be included automatically with the ``neo4j-core`` gem (which is in turn included automatically in the ``neo4j`` gem).  This is no longer the case because not everybody needs these tasks.

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


## neo4j:indexes

### Arguments

``environment``

### Example

``rake neo4j:indexes[development]``

### Description

  Print out the indexes in the database



## neo4j:constraints

### Arguments

``environment``

### Example

``rake neo4j:constraints[development]``

### Description

  Print out the constraints in the database



## neo4j:reset_yes_i_am_sure

### Arguments

``environment``

### Example

``rake neo4j:reset_yes_i_am_sure[development]``

### Description

  - Stop the Neo4j server
  - Deletes all files matching `[db-root]/data/graph.db/*`
  - Deletes all files matching `[db-root]/data/log/*`
  - Start the Neo4j server

