Use the Dockerfile to setup your i686 cross compiler enviroment, use something like:
```
docker run -it --rm -v ./src:/root/src <tag>
```
to load into the build enviroment, then 'make all' to build the iso. :)