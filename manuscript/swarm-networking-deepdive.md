# SWARM Networking Deep Dive

In this module, we are going to set on a interesting journey of how SWARM netwoking functions under the hood. We will delving deeper in the world of bridges, vxlans, overlays, underlays, kernel ipvs and follow the journey of a packet in a swarm cluster. We will also be looking into how docker leverages iptables and ipvs, both kernel features, to implement the service discovery and load balancing.

## Installing pre reqs

Install bridge utils

```
apt-get install bridge-utils
```

## Examine the networks before setting up Swarm

```
brctl show

```

```
bridge name	bridge id		STP enabled	interfaces

docker0		8000.024268987cd3	no
```


```
docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
896388d51d18        bridge              bridge              local
3e3e8fec9527        host                host                local
385a6e374d9d        none                null                local
```


## Examine the network configurations created by SWARM


List the networks

```
docker network ls

NETWORK ID          NAME                DRIVER              SCOPE
9b3cdad15a64        bridge              bridge              local
71ad6ab6c0fb        docker_gwbridge     bridge              local
6d42f614ce37        host                host                local
lpq3tzoevynh        ingress             overlay             swarm
ce30767f4305        none                null                local
```

where,

docker_gwbridge : bridge network created by swarm to connect containers to host and outside world

ingress: overlay network created by swarm for external service discovery, load balancing with routing mesh

Examine the overlay vxlan inmplemntation


##### Inspect networks


```
docker network inspect docker_gwbridge
```

[output]

```
       "Containers": {
            "ingress-sbox": {
                "Name": "gateway_ingress-sbox",
                "EndpointID": "b735335b753af4222fa253ba8496fe5a9bff10f8ddc698bd938d2b3e10780d54",
                "MacAddress": "02:42:ac:12:00:02",
                "IPv4Address": "172.18.0.2/16",
                "IPv6Address": ""
            }
        },
```

where,
 ingress-sbox : sandbox created with network namespace and configs, purely for service discovery and load balancing

 EndpointID   : endpoing created (veth pair) in ingress-sbox e.g. eth0 inside this network namespace



```
docker network inspect ingress
```

[output]

```
      "Containers": {
            "ingress-sbox": {
                "Name": "ingress-endpoint",
                "EndpointID": "a187751fda1c95b0f9c47bfe5d4104cf5195a839fef588bc7e3b02da5972ca7a",
                "MacAddress": "02:42:0a:ff:00:02",
                "IPv4Address": "10.255.0.2/16",
                "IPv6Address": ""
            }
        },
        "Options": {
            "com.docker.network.driver.overlay.vxlanid_list": "4096"
        },
        "Labels": {},
        "Peers": [
            {
                "Name": "02dddbfc3e9a",
                "IP": "159.65.167.88"
            },
            {
                "Name": "96473fed4b7c",
                "IP": "159.89.42.230"
            },
            {
                "Name": "c92920c69b92",
                "IP": "159.89.41.130"
            }
        ]
    }
```

where,

 ingress-sbox : sandbox created with network namespace and configs, purely for service discovery and load balancing

 EndpointID   : endpoing created (veth pair) in ingress-sbox

 Peers        : nodes participating in this overlay

 4096	      : VXLAN ID

We will look inside the ingress-sbox namespaces as later part of this tutorial.


##### Interfaces and bridges

```
ifconfig
brctl show
```
[output]

```
brctl show
bridge name	bridge id		STP enabled	interfaces
docker0		8000.02425dcabce4	no		veth3850215
docker_gwbridge		8000.0242105642b6	no		veth4dae0de
ov-001000-wo0i1		8000.1e8f6f3278a0	no		vethc978c4b
							vx-001000-wo0i1
```

Note down the vx-001000-wo0i1 id.  To check more information use the following command.   

[ Replace the command with your VXLAN ID ]

```
ip -d link show vx-001000-wo0i1
```

Show forwarding table
```
bridge fdb show dev vx-001000-wo0i1
```

[output]
```
5e:20:18:b1:1d:0e vlan 0 permanent
02:42:0a:ff:00:03 dst 159.89.39.105 self permanent
02:42:0a:ff:00:04 dst 165.227.64.215 self permanent
```

where,

5e:20:18:b1:1d:0e =>  mac of the current host  
02:42:2c:32:94:4e =>   mac id of ingress_box endpoint for ingress network on host with ip 159.89.39.105
02:42:b2:0d:24:f8 =>  mac id of ingress_box endpoint for ingress network on host with ip 165.227.64.215




#### Examine the traffic

Traffic on 2377/tcp : Cluster management communication
```
tcpdump -v -i eth0 port 2377
```

Inter node gossip

```
tcpdump -v -i eth0 port 7946
```

Data plan traffic on overlay

```
tcpdump -v -i eth0 udp and port 4789
```


## Creating overlay networks

```
docker network create -d overlay mynet0
docker network ls
docker network inspect mynet0

```

Examine the options, its missing *encrypted* flag

```
     "ConfigOnly": false,
        "Containers": null,
        "Options": {
            "com.docker.network.driver.overlay.vxlanid_list": "4097"
        },
        "Labels": null
```
where,
  4097 :   vnid of this VXLAN


```
docker network create --opt encrypted -d overlay vote
docker network ls
docker network inspect vote

```

this time, encryption is enabled
```
      "Containers": null,
        "Options": {
            "com.docker.network.driver.overlay.vxlanid_list": "4098",
            "encrypted": ""
        },
        "Labels": null
    }
```

** Try This**

Observe the following by listing networks on all nodes,   

```
docker network ls
```

  * all manager nodes have the new overlay network
  * worker nodes will create it on need basis, only if there is a task running on that node

Lets learn what all is created with this overlay network,

```
ifconfig
brctl show
```



#### Launch Service with overlay network

```
docker service ls
docker service create --name redis --network vote --replicas=2 redis:alpine
```
[output]

```
8mxs1phssydpwi23teifpqcwr
overall progress: 2 out of 2 tasks
1/2: running   [==================================================>]
2/2: running   [==================================================>]
verify: Service converged
```

Check network on all nodes. It would be created only on selective nodes where tasks are scheduled

```
docker network ls
docker network inspect vote
```

docker ps

```
4ea9c75179c3        redis:alpine        "docker-entrypoint.s…"   About a minute ago   Up About a minute   6379/tcp            redis.2.pbyb0o2e60gm1ozwc3wz9f7ou
```

Correlate interfaces and trace it

Inside the container
```
docker exec 4ea9c75179c3 ip link

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
16: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1424 qdisc noqueue state UP
    link/ether 02:42:0a:00:00:07 brd ff:ff:ff:ff:ff:ff
18: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP
    link/ether 02:42:ac:12:00:03 brd ff:ff:ff:ff:ff:ff
```

and on the host
```
root@swarm-01:/var/run# ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether 9e:28:4c:8a:bf:5d brd ff:ff:ff:ff:ff:ff
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN mode DEFAULT group default
    link/ether 02:42:5d:ca:bc:e4 brd ff:ff:ff:ff:ff:ff
7: ov-001000-wo0i1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UP mode DEFAULT group default
    link/ether 1e:8f:6f:32:78:a0 brd ff:ff:ff:ff:ff:ff
8: vx-001000-wo0i1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue master ov-001000-wo0i1 state UNKNOWN mode DEFAULT group default
    link/ether 5e:20:18:b1:1d:0e brd ff:ff:ff:ff:ff:ff
10: vethc978c4b: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue master ov-001000-wo0i1 state UP mode DEFAULT group default
    link/ether 1e:8f:6f:32:78:a0 brd ff:ff:ff:ff:ff:ff
11: docker_gwbridge: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default
    link/ether 02:42:10:56:42:b6 brd ff:ff:ff:ff:ff:ff
13: veth4dae0de: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker_gwbridge state UP mode DEFAULT group default
    link/ether 26:ea:d2:47:25:0d brd ff:ff:ff:ff:ff:ff
14: ov-001001-7672d: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1424 qdisc noqueue state UP mode DEFAULT group default
    link/ether 42:a3:4b:f3:ca:05 brd ff:ff:ff:ff:ff:ff
15: vx-001001-7672d: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1424 qdisc noqueue master ov-001001-7672d state UNKNOWN mode DEFAULT group default
    link/ether 42:a3:4b:f3:ca:05 brd ff:ff:ff:ff:ff:ff
17: veth4dd295a: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1424 qdisc noqueue master ov-001001-7672d state UP mode DEFAULT group default
    link/ether ba:83:a3:3c:73:b1 brd ff:ff:ff:ff:ff:ff
19: veth78165ba: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker_gwbridge state UP mode DEFAULT group default
    link/ether 76:9a:35:13:b3:64 brd ff:ff:ff:ff:ff:ff
```

**veth Pairs**

16: eth0  <===>  17: veth4dd295a (Overlay ov-001001-7672d)

18: eth1  <===>  19: veth78165ba (docker_gwbridge)

Show forwarding table for this overlay vtep
```
brctl show
bridge fdb show dev vx-001001-7672d
```

[output]
```
42:a3:4b:f3:ca:05 vlan 0 permanent
02:42:0a:00:00:06 dst 159.89.39.105 self permanent
```


Where, 02:42:0a:00:00:06 should be the mac id of the container on the other hosts

e.g. on swarm-2
```
root@swarm-02:~# docker exec 92ee739ecdca ip lin
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
16: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1424 qdisc noqueue state UP
    link/ether 02:42:0a:00:00:06 brd ff:ff:ff:ff:ff:ff


root@swarm-02:~# ip link
17: veth353ea84: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1424 qdisc noqueue master ov-001001-7672d state UP mode DEFAULT group default
    link/ether 6e:2a:bb:f1:52:2a brd ff:ff:ff:ff:ff:ff

```

Task: Do the same from the other end. Check the fdb for vxlan interface on swarm-02 and correlate it with the mac id of a container running on swarm-01


### Launch worker service in same overlay
```
docker service create --name worker --network vote schoolofdevops/worker
```

Should get launched on the third node  as the default scheduling algorithm is to sread the load evenly.

Now on node1 and node2 check the fdb again, should see a new vtep endpoint

e.g.

[replace vx-001001-7672d with the id of the vxlan interface created for this overlayn/w, get it by using brctl show ]
```

bridge fdb show dev vx-001001-7672d
22:ba:86:43:71:27 vlan 0 permanent
02:42:0a:00:00:07 dst 159.65.161.208 self permanent
02:42:0a:00:00:09 dst 165.227.64.215 self permanent
```




#### Scale redis service

```
docker service scale redis=5
```

Examine the fdb again

```
bridge fdb show dev vx-001001-7672d
42:a3:4b:f3:ca:05 vlan 0 permanent
02:42:0a:00:00:09 vlan 0
02:42:0a:00:00:06 dst 159.89.39.105 self permanent
02:42:0a:00:00:09 dst 165.227.64.215 self permanent
02:42:0a:00:00:0a dst 165.227.64.215 self permanent
02:42:0a:00:00:0b dst 159.89.39.105 self permanent
```

where,

the table shows entries for every other

##### Underlying VXLAN service  and traffic

port 4789 is reservered for vxlan. Packets will have headers with this.

```
netstat -pan | grep  4789

```

To see the packets going through the vxlan interface

```
brctl show
tcpdump -i ov-001001-7672d
```

### Internal Load Balancing

connect to one of the redis instances on one of the nodes
```
docker ps

docker run --rm -it --net container:0b0309771045 --privileged nicolaka/netshoot

```

Verify redirect to ipvs

```
iptables -nvL -t nat
```

```

Chain POSTROUTING (policy ACCEPT 85 packets, 5426 bytes)
 pkts bytes target     prot opt in     out     source               destination
   59  3712 DOCKER_POSTROUTING  all  --  *      *       0.0.0.0/0            127.0.0.11
    3   180 SNAT       all  --  *      *       0.0.0.0/0            10.0.0.0/24          ipvs to:10.0.0.11


```

where,

ipvs to:10.0.0.11 . : is routing the traffic to ipvs, running on the  same container

check the mangle markers

```
iptables -nvL -t mangle
```


```
Chain OUTPUT (policy ACCEPT 864 packets, 62611 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 MARK       all  --  *      *       0.0.0.0/0            10.0.0.5             MARK set 0x100
  168 14112 MARK       all  --  *      *       0.0.0.0/0            10.0.0.8             MARK set 0x101
   26  1757 MARK       all  --  *      *       0.0.0.0/0            10.0.0.13            MARK set 0x103

```

where,
10.0.0.5 is s VIP for service *xyz* . 0x100is a HEX for 256.

to check where this is redirecting, look at the ipvs rules

```
# ipvsadm
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
FWM  256 rr
  -> redis.1.m911y2nt3wy0qo5x8i9p Masq    1      0          0
  -> redis.2.pbyb0o2e60gm1ozwc3wz Masq    1      0          0
  -> e89fbe75fb1a.vote:0          Masq    1      0          0
  -> 0b0309771045:0               Masq    1      0          0
  -> redis.5.oag34plamnmptoby9b0y Masq    1      0          0
FWM  257 rr
  -> worker.1.lhxvgjgn5k6soaksifz Masq    1      0          0
FWM  259 rr
  -> vote.1.hhv9l10vb5yocxmkbzzdv Masq    1      0          0
  -> vote.2.h1iwvk5t8hr9pc6mpqsxk Masq    1      0          0
```

here the following is doing a RR load balancing across 5 nodes

```
FWM  256 rr
  -> redis.1.m911y2nt3wy0qo5x8i9p Masq    1      0          0
  -> redis.2.pbyb0o2e60gm1ozwc3wz Masq    1      0          0
  -> e89fbe75fb1a.vote:0          Masq    1      0          0
  -> 0b0309771045:0               Masq    1      0          0
  -> redis.5.oag34plamnmptoby9b0y Masq    1      0          0
```




## Port Publishing, Routing Mesh, Ingress Network and External Service Discovery

```
docker network ls
docker network inspect ingress
```

where,

 Peers : shows all the hosts which are part of this ingress (note the peers and corraborate)
 Containers : shows ingress-sbox namespace (its not a containers, just a namespace, has one interface in gwbridge, another ingress)


#### Examine the ingress-sbox namespace

 Learn about netshoot utility at https://github.com/nicolaka/netshoot

 Launch **netshoot** container, and connect to **ingress-sbox** using nsenter.

 ```
 docker run -it --rm -v /var/run/docker/netns:/netns --privileged=true nicolaka/netshoot nsenter --net=/netns/ingress_sbox sh
 ```

 From inside netshoot container,
 ```
 ifconfig
 ip link show

 ```
 [output]
 ```
 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default
     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
 9: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UP mode DEFAULT group default
     link/ether 02:42:0a:ff:00:02 brd ff:ff:ff:ff:ff:ff
 12: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default
     link/ether 02:42:ac:12:00:02 brd ff:ff:ff:ff:ff:ff
 ```

 On the host

 ```
 ip link show
 ```
 [output]
 ```
 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default
     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
     link/ether 92:20:8a:88:b6:e8 brd ff:ff:ff:ff:ff:ff
 3: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default
     link/ether 02:42:68:98:7c:d3 brd ff:ff:ff:ff:ff:ff
 7: ov-001000-lpq3t: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UP mode DEFAULT group default
     link/ether 8a:17:46:93:46:94 brd ff:ff:ff:ff:ff:ff
 8: vx-001000-lpq3t: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue master ov-001000-lpq3t state UNKNOWN mode DEFAULT group default
     link/ether 8a:17:46:93:46:94 brd ff:ff:ff:ff:ff:ff
 10: veth28c87ba: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue master ov-001000-lpq3t state UP mode DEFAULT group default
     link/ether 8a:24:17:29:46:a7 brd ff:ff:ff:ff:ff:ff
 11: docker_gwbridge: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default
     link/ether 02:42:a0:ca:1d:96 brd ff:ff:ff:ff:ff:ff
 13: veth0740008: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker_gwbridge state UP mode DEFAULT group default
     link/ether aa:b8:35:c2:97:74 brd ff:ff:ff:ff:ff:ff
 19: veth97a403d: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP mode DEFAULT group default
     link/ether 8a:80:a4:17:3b:2d brd ff:ff:ff:ff:ff:ff
 ```

 If you compare two  outputs above,

 9  <=====> 10   : ingress network

 12 <=====> 13   : docker_gwbridge network



These are then further bridged. Examine the bridges in the next part.


**********

Create a container which is part of this ingress


```
docker service create --name vote --network vote --publish 80 --replicas=2 schoolofdevops/vote
```

docker ps

[output]
```
CONTAINER ID        IMAGE                        COMMAND                  CREATED             STATUS              PORTS               NAMES
85642d7fa2f4        schoolofdevops/vote:latest   "gunicorn app:app -b�"   28 seconds ago      Up 27 seconds       80/tcp              vote.1.hhv9l10vb5yocxmkbzzdvtmj2
64f05b29e559        redis:alpine                 "docker-entrypoint.s�"   29 minutes ago      Up 29 minutes       6379/tcp            redis.5.oag34plamnmptoby9b0yuaooi
4ea9c75179c3        redis:alpine                 "docker-entrypoint.s�"   About an hour ago   Up About an hour    6379/tcp            redis.2.pbyb0o2e60gm1ozwc3wz9f7ou
```

Connect to container and examine

```
docker exec 85642d7fa2f4 ifconfig

docker exec 85642d7fa2f4 ip link show

docker exec 85642d7fa2f4 netstat -nr

```

Correlate it with the host veth pair
```
ip link show
brctl show
docker network ls
```

eth0 => ingress
eth1 => gwbridge

eth2 => overlay for apps


## Service Networking and Routing Mesh

For external facing ingress connnetiion, service routing works this way,

ingress ==> gwbridge ==> ingress-sbox (its just a n/w namespae not a container) ==> ipvs ==> underlay


  * Check iptable rules on the host

```
iptables -nvL -t nat
```

[output]
```
...
Chain DOCKER-INGRESS (2 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 DNAT       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:30000 to:172.18.0.2:30000
   31  1744 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0
```

where,

tcp dpt:30000 to:172.18.0.2:30000 => is forwarding  the traffic received on 30000 port to 172.18.0.2:30000. Here 172.18.0.2 belongs to **ingress_sbox** so whatever happens next is inside there...


  * Connecting to ingress-sbox

```
docker run -it --rm -v /var/run/docker/netns:/var/run/docker/netns --privileged=true nicolaka/netshoot

nsenter --net=/var/run/docker/netns/ingress_sbox sh

```
alternately
```
docker run -it --rm -v /var/run/docker/netns:/netns --privileged=true nicolaka/netshoot nsenter --net=/netns/ingress_sbox sh

```
and then

```
iptables -nvL -t mangle
```

```
Chain PREROUTING (policy ACCEPT 16 packets, 1888 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 MARK       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:30000 MARK set 0x102

```
where,

iptables is setting MARK to 0x102 for anything that comes in on 30000 port. 0x102 is hex value and can be translated into integer from here https://www.binaryhexconverter.com/hex-to-decimal-converter

e.g.  0x102 = 258

  * Now check the rules for above mark with ipvs




```
ipvsadm

```

[output]
```
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
FWM  258 rr
  -> 10.255.0.6:0                 Masq    1      0          0
  -> 10.255.0.7:0                 Masq    1      0          0
```

This is where the decision is made as to where this packet goes. Since ipvs uses round robin algorithm, one of these ips are selected and then packet is sent over the **ingress** overlay network.


Finally,

To see the traffic on ingress network

on node2
```

tcpdump -i eth0 udp and port 4789
tcpdump -i eth0 esp

```


-----------------------

### Additional Commands

```
tail -f syslog
tcpdump -i eth0 udp and port 4789
tcpdump -i eth0 esp
ip addr
ip link
iptables -t nat -nvL

```
  * To see namespaces on the docker host

cd /var/run
ln -s /var/run/docker/netns netns
ip netns

docker network ls
[company network and ns ids]




**References**


CNM and Libnetwork
https://github.com/docker/libnetwork/blob/master/docs/design.md


How VXLANs work ?
https://youtu.be/Jqm_4TMmQz8?t=32s  (watch from 00.32 to xx.xx)
https://www.youtube.com/watch?v=YNqKDI_bnPM

Overlay Tutorial
https://neuvector.com/network-security/docker-swarm-container-networking/

Docker Networking Tutorial - Learning by Practicing
https://www.securitynik.com/2016/12/docker-networking-internals-container.html

Swarm networks
https://docs.docker.com/v17.09/engine/swarm/networking/


Ip cheatsheet
https://access.redhat.com/sites/default/files/attachments/rh_ip_command_cheatsheet_1214_jcs_print.pdf


Overlay issues
https://github.com/moby/moby/issues/30820


Network Troubleshooting
https://success.docker.com/article/troubleshooting-container-networking


Connect Service to Multiple Networks: https://www.slideshare.net/SreenivasMakam/docker-networking-common-issues-and-troubleshooting-techniques
