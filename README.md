### Dockerfile for 'Yet another computational EXFOR database' (YacoX4) - version 0.1.0

This repository contains the Dockerfile and
supplementary files for the installation of
the EXFOR library as a MongoDB database,
referred to as *yet another computational EXFOR database* or *YacoX4* in short.

If [Docker](https://www.docker.com) is installed on your system, you can
install this database with the following instructions:
```
git clone https://github.com/gschnabel/compEXFOR-docker.git
docker build -t exfor-mongodb compEXFOR-docker
```
Depending on your Docker configuration, you may need to run the docker
instruction with sudo/administrator priviledges.
Subsequently the database application can be launched by
```
docker run -itd -p 27017:27017 --rm --name exfor-mongodb-cont exfor-mongodb
```
The database can be explored by using the mongo client, which can be started by
`mongo` on the command line if installed.
A more detailed description of the installation process
and simple usage examples can be found in the [manual](manual/build/manual.pdf).

More Dockerfiles related to nuclear data can be found at
[www.nucleardata.com/#dockerimages](http://www.nucleardata.com/#dockerimages).

**Note**:

The company behind MongoDB recently changed their license to the
[Server Side Public License](https://www.mongodb.com/licensing/server-side-public-license)
which is controversial in the open-source community.
Therefore you may want to check out the
[exfor-couchdb-docker](https://github.com/gschnabel/exfor-couchdb-docker)
repository to setup the EXFOR library as a CouchDB database.
