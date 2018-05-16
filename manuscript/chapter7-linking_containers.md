# Building Application Stacks - Defining and Running Multi Container Apps


## Lab: Creating a Docker Compose Stack for the Vote Application


Lets first launch redis and vote independently  and see if they automatically connect.

```
docker container run -idt --name redis redis:alpine

docker container  run -idt  --name vote -P  schoolofdevops/vote

```

Try registering a vote with the voteapp UI.  Does it work?

You could also try if **vote** is able to discover **redis** by running

```
docker exec vote ping redis

```


### Linking services

Remove vote container created above if any, and re launch it with the link.

```
docker container rm -f vote

docker container  run -idt  --name vote --link redis:redis -P  schoolofdevops/vote
```

Launch worker app as well with the link

```

docker container  run -idt  --name worker --link redis:redis -P  schoolofdevops/vote-worker


docker logs worker
```

### Launching inter linked services with Compose spec

Lets now create a docker-compose spec and launch the services with docker-compose utility.


Create a directory to keep the compose files. Lets say **stack**

```
mkdir stack
cd stack
```

file: docker-compose.yml
```
vote:
  image: schoolofdevops/vote
  links:
    - redis:redis
  ports:
    - 80   

redis:
  image: redis:alpine

worker:
  image: schoolofdevops/vote-worker
  links:
    - redis:redis

```


Syntax check

```
docker-compose config
```



Now launch it with

```
docker-compose up -d

docker-compose ps

```

file: docker-compose-v3.yml

```
version: "3"

networks:
  vote:
    driver: bridge

services:
  vote:
    image: schoolofdevops/vote
    ports:
      - 80
    networks:
      - vote
    depends_on:
      - redis

  redis:
    image: redis:alpine
    networks:
      - vote

  worker:
    image: schoolofdevops/vote-worker
    networks:
      - vote
    depends_on:
      - redis
```


Launch the new stack with,

```
docker-compose -f docker-compose-v3.yml up -d


docker-compose -f docker-compose-v3.yml ps


docker-compose -f docker-compose-v3.yml down
```
