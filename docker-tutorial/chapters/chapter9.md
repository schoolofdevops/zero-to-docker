### Docker Swarm Quick Dive
#### With Swarm Mode ( Docker version 1.12)

```

docker-machine create -d virtualbox master

docker-machine create -d virtualbox node1

docker-machine create -d virtualbox node2

```

##### In window 1

```
docker-machine env master

[execute the command to setup env ]

docker swarm init --advertise-addr <IP_ADDRESS_OF_MASTER>

docker node ls
```

##### In window 2

```
docker-machine env node1

docker swarm join \
    --token <TOKEN> \
    <IP_ADDRESS_OF_MASTER>
```

##### In window 3

```
docker-machine env node1

docker swarm join \
    --token <TOKEN> \
    <IP_ADDRESS_OF_MASTER>
```

### In window 1

```
docker node ls

docker service create --replicas 1 --name helloworld alpine ping docker.com

docker service ls

docker service inspect --pretty helloworld

docker service scale helloworld=5


docker service ps helloworld

docker node ps node1


docker service rm helloworld
```
