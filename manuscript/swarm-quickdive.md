# Lab: Docker SWARM Quick Dive





Create a 5 nodes (3 masters, 2nodes) swarm cluster using http://play-with-docker.com


### Launch a Visualizer on Master (SWARM Manager)


```
docker run -itd -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock schoolofdevops/visualizer

```


## Deploying Service with swarm - The imperative way

```sh
docker service create --name vote schoolofdevops/vote
```


```sh
docker service ls
docker service inspect

```

```
docker service  update --publish-add 80:80 vote
```

Try accessing port 80 on any of the nodes in the swarm cluster to validate.



#### Scaling a service
```
docker service scale vote=4
docker service  ls
docker service scale vote=2
```

#### Cleaning Up

```
docker service rm vote
```

## Orchestrating Applications with Stack Deploy

file: stack.yml

```
version: "3"

networks:
  nw01:
    driver: overlay

volumes:
  db-data:

services:
  vote:
    image: schoolofdevops/vote:v1
    ports:
      - 80
    networks:
      - nw01
    depends_on:
      - redis
    deploy:
      replicas: 8
      update_config:
        parallelism: 2
        delay: 20s
      restart_policy:
        condition: on-failure  

  redis:
    image: redis:alpine
    networks:
      - nw01

  worker:
    image: schoolofdevops/vote-worker
    networks:
      - nw01
    depends_on:
      - redis
      - db

  db:
    image: postgres:9.4
    networks:
      - nw01
    volumes:
      - db-data:/var/lib/postgresql/data

  result:
    image: schoolofdevops/vote-result
    ports:
      - 5001:80
    networks:
      - nw01
    depends_on:
      - db

```

You could also copy the above file using the followinng command,
```
wget -chttps://gist.githubusercontent.com/initcron/8a5ebd534df74ab2a83e96218b56137d/raw/9e748637aed121b67ceddeca8678750596c81ab7/stack.yml
```



Deploy a stack

```
docker stack deploy --compose-file stack.yml instavote

```

Validate

```
docker stack ls

docker stack services instavote

docker service ls

docker service scale instavote_vote=4
```

###  Deploying a new version

Update stack.yml with the new version of the image

```
....
services:
  vote:
    image: schoolofdevops/vote:v2
  .....

    deploy:
      replicas: 8
      update_config:
        parallelism: 2
        delay: 20s
      restart_policy:
        condition: on-failure  
...
```

Deploy  using  the same command as earlier,

```
docker stack deploy --compose-file stack.yml instavote
```

### Fault Tolerance

  * Delete a node
  * Observe the node being removed from cluster
  * Observe tasks getting rescheduled automatically on available nodes
