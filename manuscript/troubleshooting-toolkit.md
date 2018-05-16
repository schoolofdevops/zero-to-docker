## Troubleshooting Toolkit

### Netshoot

Learn about netshoot, a swiff army knife troubleshooting utility here https://github.com/nicolaka/netshoot


```
docker pull nicolaka/netshoot

docker container run --name trsh-01 -idt debian bash

docker exec -it trsh-01 bash

```

try running some networking commands

```
ifconfig
ipvsadm
netstat
```


Connect to another container's network with netshoot
```
docker run -it --net container:trsh-01 --privileged nicolaka/netshoot

ifconfig
ipvsadm
netstat

```

Connect to host namespace

```
docker run -it --net host --privileged nicolaka/netshoot
```


Connect to a network namespace using netshoot

```
cd /var/run
sudo ln -s /var/run/docker/netns netns
sudo ip netns
```

[output]

```
f340b46b5428
default
6ce0f3206bb8 (id: 0)

```

Lets enter the namespace **default** using netshoot

```
docker run -it --rm -v /var/run/docker/netns:/netns --privileged=true nicolaka/netshoot nsenter --net=/netns/default sh

```


Try the following with netshoot

  * **iperf**: networking performance between containers/hosts
  * **tcpdump** : packet capture and analysis
  * **netstat**: network configurations, port to pid mapping, connections
  * **nmap**: port scanning
  * **iftop**: network interface top
  * **drill**: name resolution, dns debugging
  * **ip route**:


Network commmands to remember 

```
docker network <commands>
nsenter —net=<net-namespace>
tcpdump -nnvvXXS -i <interface> port <port>
iptables -nvL -t <table>
ipvsadm -L
ip <commands>
bridge <commands>
drill
netstat -tulpn
iperf <commands>
```


### Finding ip routes and ARP neighbours

```
ip route show
```

[replace 172.17.0.4 with the ip address of a actual neighbour and docker0 with the interface ]
```
ip neigh show
ip neigh delete 172.17.0.4 dev docker0
ip neigh show
ping -c 1 172.17.0.4
ip neigh show

```

**Ref**:

 http://lartc.org/howto/lartc.iproute2.arp.html
