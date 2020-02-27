
## Project : Build a docker image for Facebooc app 

[Facebooc](https://github.com/schoolofdevops/facebooc) is a app written in C. Its a simple, web based social media application clone and used SQLite as a database backend. As a devops engineer, you have been tasked with building an image for facebooc app and publish it to docker hub registry. 


### Approach 1: Building docker image for facebooc app manually


on the host 

```
git clone https://github.com/schoolofdevops/facebooc.git
docker container run -idt --name fb -p 16000:16000 ubuntu bash
docker cp facebooc fb:/opt
docker exec -it fb bash
```

inside the container 

```
cd /opt/facebooc/
apt-get update
apt-get install -yq build-essential make libsqlite3-dev sqlite3
make all
bin/facebooc
```

on the host 

```
docker diff fb 

docker container commit fb <docker_id>/facebooc:v1

docker login 

docker image push <docker_id>/facebooc:v1

```





### Approach 2: Building image with Dockerfile 


Change into facebooc directory which containts the source code.  This assumes you have already cloned the repo. If not, clone it from https://github.com/schoolofdevops/facebooc

```
cd facebooc 
ls

LICENSE  Makefile  README.md  include  src  static  templates

```

Add/create  Dockerfile the the same directory (facebooc) witht the following content, 

```
FROM  ubuntu


WORKDIR /opt/facebooc

RUN  apt-get update &&  \
     apt-get install -yq build-essential make git libsqlite3-dev sqlite3 


COPY . /opt/facebooc

RUN  make all 

EXPOSE 16000

CMD "bin/facebooc"
```

Build image using, 

```
 docker build -t <docker_id>/facebooc:v2 .
```

where, 
  <docker_id> : your docker registry user/namespace. Replace this with the actual user
  
  
validate 

```
docker image ls
docker image history <docker_id>/facebooc:v2
docker container run -idt -P <docker_id>/facebooc:v2
docker ps 
```

Check by connecting to your host:port to validate if facebooc web application shows up. 


Once validated, tag and push 

```
docker image tag <docker_id>/facebooc:v2 <docker_id>/facebooc:latest
docker login
docker push <docker_id>/facebooc
```



