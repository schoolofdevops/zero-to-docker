# Managing Containers - Learning about Common Container Operations

In the previous chapter, we have learnt about container lifecycle management including how to create, launch, connect to, stop and remove containers. In this chapter, we are going to learn how to launch a container with a pre built app image and how to access the app with published ports. We will also learn about common container operations such as inspecting container information, checking logs and performance stats, renaming and updating the properties of a container, limiting resources etc.  

As part of the tutorial, we are going to setup a shiny new blogging/publishing site. To set it up, we will use a node.js based framework called **ghost**, a simple, fast, and SEO friendly alternative to more sophisticated publishing platforms such as wordpress. However, its purely gives us a blogging platform.  

### Launching a container with a pre built app image  

To launch ghost container run the following command. Don't bother about the new flag **-P** now. We will explain about that flag later in this chapter  
```
docker run -itd -P ghost:0.10.1
```  
[Output]  

```
Unable to find image 'ghost:0.10.1' locally
0.10.1: Pulling from library/ghost

8ad8b3f87b37: Pull complete
751fe39c4d34: Pull complete
3c8031bea3fa: Pull complete
854b52827bb4: Pull complete
f2c2db6ff75a: Pull complete
8e874614dce5: Pull complete
3aa1c5caad55: Pull complete
0cb1edc0454a: Pull complete
6d8ba59589a6: Pull complete
bff20c590458: Pull complete
Digest: sha256:2258f67d3cc513dbf205d5e793e6a9d7359ba28cf16fc5dce08b4e5d2b982245
Status: Downloaded newer image for ghost:0.10.1
3e3b4f0b54dc6d24ee95f24dcbd6472fce541568e1fbb56c982913ca4cb58e15
```
Lets check the status of the container  
```
docker ps
```  
[Output]  

```
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                     NAMES
3e3b4f0b54dc        ghost:0.10.1        "/entrypoint.sh npm s"   7 seconds ago       Up 5 seconds        0.0.0.0:32768->2368/tcp  hungry_lalande
```  

### Renaming the container  
We can rename the container by using following command  
```
docker rename hungry_lalande ghost
```  
We have changed container's automatically generated name to ghost. This new name can be of your choice. The point to understand is this command takes two arguments. The **Old_name followed by New_name**
Run docker ps command to check the effect of changes  
```
docker ps
```  
[Output]  

```
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                     NAMES
3e3b4f0b54dc        ghost:0.10.1        "/entrypoint.sh npm s"   12 minutes ago      Up 12 minutes       0.0.0.0:32768->2368/tcp   ghost
```  
As you can see here, the container is renamed to **ghost**. This makes referencing container in cli very much easier.  

### Ready to experience Ghost?  
Let's see what this **ghost** application does by connecting to that application. For that we need,  
  * Host machine's IP  
  * Container's port which is mapped to a host's port
To find out host machine's IP, we will use **docker machine**. More about this docker orchestration utility will be explained later in the book. The same can be achieved by running a simple ifconfig command in the host machine. But if you understand what docker machine command can do from the starting itself, it will benefit you to understand about this utility quite easily  

```
docker-machine ip default
```  

**TODO:Command is not working - Host does not exist **  

Let's find out the port mapping of container to host. Docker provides subcommand called **port** which does this job  

```
docker port ghost  
```  
[Output]  

```
2368/tcp -> 0.0.0.0:32768
```  
So whatever traffic the host gets in port **2368** will be mapped to container's port **32768**  

Let's connect to http://IP_ADDRESS:PORT to see the actual application  

![ghost-welcome](images/ghost-welcome.png)

### Configure blog and add some content  
Let us set up ghost now. Let log into admin console of ghost by visiting following URL  
```
http://HOST:PORT/ghost
```  
Now follow these instructions  
![setup](images/setup-1.png)  
![setup](images/setup-2.png)  
![setup](images/setup-3.png)  
![setup](images/setup-4.png)  
![setup](images/setup-5.png)  

There you go. Now you have successfully published an article on ghost  
Visit the homepage again to see it  

### Finding Everything about the running  container
This topic discusses about finding metadata of containers. These metadata include various parameters like,  
  * State of the container  
  * Mounts  
  * Configuration  
  * Network, etc.,  

#### Inspecting
Lets try this inspect subcommand in action  

```
docker inspect ghost
```  

[Output]  

```
[
    {
        "Id": "3e3b4f0b54dc6d24ee95f24dcbd6472fce541568e1fbb56c982913ca4cb58e15",
        "Created": "2016-09-15T14:07:10.939365783Z",
        "Path": "/entrypoint.sh",
        "Args": [
            "npm",
            "start"
        ],
        "State": {
            "Status": "running",
            "Running": true,
            "Paused": false,
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 6219,
            "ExitCode": 0,
            "Error": "",
            "StartedAt": "2016-09-15T14:07:11.903893634Z",
            "FinishedAt": "0001-01-01T00:00:00Z"
        },
        "Image": "sha256:b73bd21ec0477e02c853b6b086a67d96af56fd62e0fa3d81b17893fa923d9873",
        "ResolvConfPath": "/var/lib/docker/containers/3e3b4f0b54dc6d24ee95f24dcbd6472fce541568e1fbb56c982913ca4cb58e15/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/3e3b4f0b54dc6d24ee95f24dcbd6472fce541568e1fbb56c982913ca4cb58e15/hostname",
        "HostsPath": "/var/lib/docker/containers/3e3b4f0b54dc6d24ee95f24dcbd6472fce541568e1fbb56c982913ca4cb58e15/hosts",
        "LogPath": "/var/lib/docker/containers/3e3b4f0b54dc6d24ee95f24dcbd6472fce541568e1fbb56c982913ca4cb58e15/3e3b4f0b54dc6d24ee95f24dcbd6472fce            541568e1fbb56c982913ca4cb58e15-json.log",
        "Name": "/ghost",
        "RestartCount": 0,
        "Driver": "devicemapper",
        "MountLabel": "",
        "ProcessLabel": "",
        "AppArmorProfile": "",
        "ExecIDs": null,
        "HostConfig": {
            "Binds": null,
            "ContainerIDFile": "",
            "LogConfig": {
                "Type": "json-file",
                "Config": {}
            },
            "NetworkMode": "default",
            "PortBindings": {},
            "RestartPolicy": {
                "Name": "no",
                "MaximumRetryCount": 0
            },
            "AutoRemove": false,
            "VolumeDriver": "",
            "VolumesFrom": null,
            "CapAdd": null,
            "CapDrop": null,
            "Dns": [],
            "DnsOptions": [],
            "DnsSearch": [],
            "ExtraHosts": null,
            "GroupAdd": null,
            "IpcMode": "",
            "Cgroup": "",
            "Links": null,
            "OomScoreAdj": 0,
            "PidMode": "",
            "Privileged": false,
            "PublishAllPorts": true,
            "ReadonlyRootfs": false,
            "SecurityOpt": null,
            "UTSMode": "",
            "UsernsMode": "",
            "ShmSize": 67108864,
            "Runtime": "runc",
            "ConsoleSize": [
                0,
                0
            ],
            "Isolation": "",
            "CpuShares": 0,
            "Memory": 0,
            "CgroupParent": "",
            "BlkioWeight": 0,
            "BlkioWeightDevice": null,
            "BlkioDeviceReadBps": null,
            "BlkioDeviceWriteBps": null,
            "BlkioDeviceReadIOps": null,
            "BlkioDeviceWriteIOps": null,
            "CpuPeriod": 0,
            "CpuQuota": 0,
            "CpusetCpus": "",
            "CpusetMems": "",
            "Devices": [],
            "DiskQuota": 0,
            "KernelMemory": 0,
            "MemoryReservation": 0,
            "MemorySwap": 0,
            "MemorySwappiness": -1,
            "OomKillDisable": false,
            "PidsLimit": 0,
            "Ulimits": null,
            "CpuCount": 0,
            "CpuPercent": 0,
            "IOMaximumIOps": 0,
            "IOMaximumBandwidth": 0
        },
        "GraphDriver": {
            "Name": "devicemapper",
            "Data": {
                "DeviceId": "23",
                "DeviceName": "docker-253:0-67238294-fcd6f0f0c695b522cc7939f10eb29edd993a348b25573b5f40a4d59bb459f77c",
                "DeviceSize": "10737418240"
            }
        },
        "Mounts": [
            {
                "Name": "d7cdbdaa5b140554769a38d0c77b91720c6e687c5f2f471f03b5b89cd351cf56",
                "Source": "/var/lib/docker/volumes/d7cdbdaa5b140554769a38d0c77b91720c6e687c5f2f471f03b5b89cd351cf56/_data",
                "Destination": "/var/lib/ghost",
                "Driver": "local",
                "Mode": "",
                "RW": true,
                "Propagation": ""
            }
        ],
        "Config": {
            "Hostname": "3e3b4f0b54dc",
            "Domainname": "",
            "User": "",
            "AttachStdin": false,
            "AttachStdout": false,
            "AttachStderr": false,
            "ExposedPorts": {
                "2368/tcp": {}
            },
            "Tty": false,
            "OpenStdin": false,
            "StdinOnce": false,
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "NPM_CONFIG_LOGLEVEL=info",
                "NODE_VERSION=4.5.0",
                "GOSU_VERSION=1.7",
                "GHOST_SOURCE=/usr/src/ghost",
                "GHOST_VERSION=0.10.1",
                "GHOST_CONTENT=/var/lib/ghost"
            ],
            "Cmd": [
                "npm",
                "start"
            ],
            "Image": "ghost:0.10.1",
            "Volumes": {
                "/var/lib/ghost": {}
            },
            "WorkingDir": "/usr/src/ghost",
            "Entrypoint": [
                "/entrypoint.sh"
            ],
            "OnBuild": null,
            "Labels": {}
        },
        "NetworkSettings": {
            "Bridge": "",
            "SandboxID": "434d8142bfbbd63f45c31a18ee2cb9e24b22afad93c964da69de556d531b89dd",
            "HairpinMode": false,
            "LinkLocalIPv6Address": "",
            "LinkLocalIPv6PrefixLen": 0,
            "Ports": {
                "2368/tcp": [
                    {
                        "HostIp": "0.0.0.0",
                        "HostPort": "32768"
                    }
                ]
            },
            "SandboxKey": "/var/run/docker/netns/434d8142bfbb",
            "SecondaryIPAddresses": null,
            "SecondaryIPv6Addresses": null,
            "EndpointID": "1905f7756420f7c4361478b55291d2157f9a5e6a48338b1a6133cef76b45a5a4",
            "Gateway": "172.17.0.1",
            "GlobalIPv6Address": "",
            "GlobalIPv6PrefixLen": 0,
            "IPAddress": "172.17.0.2",
            "IPPrefixLen": 16,
            "IPv6Gateway": "",
            "MacAddress": "02:42:ac:11:00:02",
            "Networks": {
                "bridge": {
                    "IPAMConfig": null,
                    "Links": null,
                    "Aliases": null,
                    "NetworkID": "e4b05962c438ad0741bacd05493668c856d837b4615257136d2ce037f81ce42b",
                    "EndpointID": "1905f7756420f7c4361478b55291d2157f9a5e6a48338b1a6133cef76b45a5a4",
                    "Gateway": "172.17.0.1",
                    "IPAddress": "172.17.0.2",
                    "IPPrefixLen": 16,
                    "IPv6Gateway": "",
                    "GlobalIPv6Address": "",
                    "GlobalIPv6PrefixLen": 0,
                    "MacAddress": "02:42:ac:11:00:02"
                }
            }
        }
    }
]

```  
This data is represented in JSON format which makes filtering these results easier.  

#### Checking the Stats  
##### Stats command  
This command returns a data stream of resource utilization used by containers. The flag **--no-stream** disables data stream and displays only first result  

```
docker stats --no-stream=true ghost
```  

[Output]  

```
CONTAINER           CPU %               MEM USAGE / LIMIT       MEM %               NET I/O               BLOCK I/O           PIDS
ghost               0.00%               214.8 MiB / 1.797 GiB   11.67%              146.6 kB / 2.168 MB   0 B / 4.375 MB      0

```  

##### Top command  
To display the list of processes and the information about those processes that are running inside the container, we can use **top** command

```
docker top ghost
```  

[Output]  

```
UID                 PID                 PPID                C                   STIME               TTY                 TIME                CMD
vagrant             6219                6211                0                   14:07               ?                   00:00:00            npm
vagrant             6275                6219                0                   14:07               ?                   00:00:00            sh -c node index
vagrant             6276                6275                0                   14:07               ?                   00:00:11            node index

```

### Examine Logs  
Docker **log** command is to print the logs of the application inside the container. In our case we will see the log output of ghost application  

```
docker logs ghost
```  

[Output]  

```
POST /ghost/api/v0.1/posts/?include=tags 422 165.523 ms - 120
GET /ghost/api/v0.1/posts/?page=1&limit=15&status=all&staticPages=all&include=tags 200 66.134 ms - -
GET /ghost/api/v0.1/slugs/post/(Untitled)/ 200 43.748 ms - 31
POST /ghost/api/v0.1/posts/?include=tags 201 73.500 ms - 479
PUT /ghost/api/v0.1/posts/2/?include=tags 200 107.108 ms - 479
PUT /ghost/api/v0.1/posts/2/?include=tags 200 261.262 ms - 607
PUT /ghost/api/v0.1/posts/2/?include=tags 200 92.373 ms - 740
PUT /ghost/api/v0.1/posts/2/?include=tags 200 197.701 ms - 742
PUT /ghost/api/v0.1/posts/2/?include=tags 200 109.857 ms - -
PUT /ghost/api/v0.1/posts/2/?include=tags 200 239.978 ms - 742
PUT /ghost/api/v0.1/posts/2/?include=tags 200 176.895 ms - -
PUT /ghost/api/v0.1/posts/2/?include=tags 200 80.514 ms - -
PUT /ghost/api/v0.1/posts/2/?include=tags 200 127.901 ms - -
PUT /ghost/api/v0.1/posts/2/?include=tags 200 279.284 ms - -
GET /ghost/api/v0.1/posts/?page=1&limit=15&status=all&staticPages=all&include=tags 200 78.747 ms - -
GET /ghost/api/v0.1/posts/?page=1&limit=15&status=all&staticPages=all&include=tags 200 131.023 ms - -
GET /ghost/api/v0.1/posts/2/?status=all&staticPages=all&include=tags 200 76.145 ms - -
PUT /ghost/api/v0.1/posts/2/?include=tags 200 219.867 ms - -
DELETE /ghost/api/v0.1/posts/2/ 204 139.318 ms - -
GET /ghost/api/v0.1/posts/?page=1&limit=15&status=all&staticPages=all&include=tags 200 68.736 ms - -
GET /ghost/api/v0.1/slugs/post/(Untitled)/ 200 110.837 ms - 31
POST /ghost/api/v0.1/posts/?include=tags 201 119.802 ms - 479
PUT /ghost/api/v0.1/posts/3/?include=tags 200 90.819 ms - -
PUT /ghost/api/v0.1/posts/3/?include=tags 200 144.269 ms - -
PUT /ghost/api/v0.1/posts/3/?include=tags 200 207.297 ms - -
GET / 200 102.683 ms - -
GET /ghost/editor/3/ 200 101.009 ms - -
GET /ghost/api/v0.1/settings/?type=blog%2Ctheme%2Cprivate 200 35.038 ms - -
GET /ghost/api/v0.1/users/me/?include=roles&status=all 200 39.853 ms - 726
GET /ghost/api/v0.1/notifications/ 200 30.542 ms - 20
GET /ghost/api/v0.1/posts/3/?status=all&staticPages=all&include=tags 200 39.482 ms - -
GET /ghost/api/v0.1/settings/?type=blog%2Ctheme%2Cprivate 200 21.556 ms - -
GET /ghost/api/v0.1/tags/?limit=all 200 52.398 ms - 426
GET /ghost/api/v0.1/users/?limit=all&include=roles 200 53.609 ms - 817
PUT /ghost/api/v0.1/posts/3/?include=tags 200 81.172 ms - -
PUT /ghost/api/v0.1/posts/3/?include=tags 200 228.299 ms - -
GET / 200 139.860 ms - -

```  

If you want to **follow** the log in real-time, use **-f** flag  

```
docker logs -f ghost
```  

[Output]  

```
POST /ghost/api/v0.1/posts/?include=tags 422 165.523 ms - 120
GET /ghost/api/v0.1/posts/?page=1&limit=15&status=all&staticPages=all&include=tags 200 66.134 ms - -
GET /ghost/api/v0.1/slugs/post/(Untitled)/ 200 43.748 ms - 31
POST /ghost/api/v0.1/posts/?include=tags 201 73.500 ms - 479
PUT /ghost/api/v0.1/posts/2/?include=tags 200 107.108 ms - 479
PUT /ghost/api/v0.1/posts/2/?include=tags 200 261.262 ms - 607
PUT /ghost/api/v0.1/posts/2/?include=tags 200 92.373 ms - 740
PUT /ghost/api/v0.1/posts/2/?include=tags 200 197.701 ms - 742
PUT /ghost/api/v0.1/posts/2/?include=tags 200 109.857 ms - -
PUT /ghost/api/v0.1/posts/2/?include=tags 200 239.978 ms - 742
PUT /ghost/api/v0.1/posts/2/?include=tags 200 176.895 ms - -
PUT /ghost/api/v0.1/posts/2/?include=tags 200 80.514 ms - -
PUT /ghost/api/v0.1/posts/2/?include=tags 200 127.901 ms - -
PUT /ghost/api/v0.1/posts/2/?include=tags 200 279.284 ms - -
GET /ghost/api/v0.1/posts/?page=1&limit=15&status=all&staticPages=all&include=tags 200 78.747 ms - -
GET /ghost/api/v0.1/posts/?page=1&limit=15&status=all&staticPages=all&include=tags 200 131.023 ms - -
GET /ghost/api/v0.1/posts/2/?status=all&staticPages=all&include=tags 200 76.145 ms - -
PUT /ghost/api/v0.1/posts/2/?include=tags 200 219.867 ms - -
DELETE /ghost/api/v0.1/posts/2/ 204 139.318 ms - -
GET /ghost/api/v0.1/posts/?page=1&limit=15&status=all&staticPages=all&include=tags 200 68.736 ms - -
GET /ghost/api/v0.1/slugs/post/(Untitled)/ 200 110.837 ms - 31
POST /ghost/api/v0.1/posts/?include=tags 201 119.802 ms - 479
PUT /ghost/api/v0.1/posts/3/?include=tags 200 90.819 ms - -
PUT /ghost/api/v0.1/posts/3/?include=tags 200 144.269 ms - -
PUT /ghost/api/v0.1/posts/3/?include=tags 200 207.297 ms - -
GET / 200 102.683 ms - -
GET /ghost/editor/3/ 200 101.009 ms - -
GET /ghost/api/v0.1/settings/?type=blog%2Ctheme%2Cprivate 200 35.038 ms - -
GET /ghost/api/v0.1/users/me/?include=roles&status=all 200 39.853 ms - 726
GET /ghost/api/v0.1/notifications/ 200 30.542 ms - 20
GET /ghost/api/v0.1/posts/3/?status=all&staticPages=all&include=tags 200 39.482 ms - -
GET /ghost/api/v0.1/settings/?type=blog%2Ctheme%2Cprivate 200 21.556 ms - -
GET /ghost/api/v0.1/tags/?limit=all 200 52.398 ms - 426
GET /ghost/api/v0.1/users/?limit=all&include=roles 200 53.609 ms - 817
PUT /ghost/api/v0.1/posts/3/?include=tags 200 81.172 ms - -
PUT /ghost/api/v0.1/posts/3/?include=tags 200 228.299 ms - -
GET / 200 139.860 ms - -
GET / 304 67.779 ms - -
GET /assets/css/screen.css?v=5799f9cac6 304 2.539 ms - -
GET /assets/js/jquery.fitvids.js?v=5799f9cac6 304 4.560 ms - -
GET /assets/js/index.js?v=5799f9cac6 304 3.353 ms - -
GET /assets/fonts/casper-icons.woff?v=1 304 0.889 ms - -
GET /favicon.ico 200 0.134 ms - -
GET /hi-there/ 200 131.892 ms - -

```  
Now try to read the articles available in our blog and see the log output gets updated in real-time. Hit **ctrl+c** to break the stream  

### Stream events from a container  
Docker **events** serves us with the stream of events or interactions that are happening with the docker daemon. This does not stream the log data of application inside the container. That is done by **docker logs** command. Let us see how this command works  
Open an another terminal *(git bash)* from *vagrant parent directory* and ssh into your Docker host. Now you should have two terminals for  the same machine **(Docker host)**. Let us call the old terminal as **Terminal 1** and the newer one as **Terminal 2**.

From Terminal 1, execute **docker events**. Now you are getting the data stream from docker daemon  

```
docker events
```  

To understand how this command actually works, let us run a container from Terminal 2  

```
docker run -ti alpine:3.4 sh  
```  

If you see, in Terminal 1, the interaction with docker daemon, while running that container will be printed  

[Output - **Terminal 1**]  

```
2016-09-16T13:00:20.189028004Z container create 816fcc5e9c8dca13c76f3ff4546a7769bed497c4f4153b20ec34459c88f7b923 (image=alpine:3.4, name=tiny_franklin)
2016-09-16T13:00:20.190190470Z container attach 816fcc5e9c8dca13c76f3ff4546a7769bed497c4f4153b20ec34459c88f7b923 (image=alpine:3.4, name=tiny_franklin)
2016-09-16T13:00:20.257068692Z network connect c0237b5406920749b87460597b8935adf958bae1ce997afd827921a0dbc97cdc (container=816fcc5e9c8dca13c76f3ff4546a7769bed497c4f4153b20ec34459c88f7b923, name=bridge, type=bridge)
2016-09-16T13:00:20.346533821Z container start 816fcc5e9c8dca13c76f3ff4546a7769bed497c4f4153b20ec34459c88f7b923 (image=alpine:3.4, name=tiny_franklin)
2016-09-16T13:00:20.347811877Z container resize 816fcc5e9c8dca13c76f3ff4546a7769bed497c4f4153b20ec34459c88f7b923 (height=41, image=alpine:3.4, name=tiny_franklin, width=126)
```  

Try to do various docker operations (start, stop, rm, etc.,) and see the output in Terminal 1  

### Attach to the container  
Normally, when we run a container, we use **-d** flag to run that container in detached mode. But sometimes you might require to make some changes inside that container. In those kind of situations, we can use **attach** command. This command attaches to the tty of docker container. So it will stream the output of the application. In our case, we will see the output of ghost application  

```
docker attach ghost
```  
Hit our blogs url several times to see the output  

[Output]  

```
POST /ghost/api/v0.1/authentication/token 200 418.439 ms - -
GET /ghost/api/v0.1/settings/?type=blog%2Ctheme%2Cprivate 200 69.950 ms - -
GET /ghost/img/invite-placeholder.png 200 1.279 ms - 7860
GET /ghost/img/users.png 200 4.739 ms - 49253
GET /ghost/api/v0.1/users/me/?include=roles&status=all 200 64.548 ms - 726
GET /ghost/api/v0.1/notifications/ 200 43.159 ms - 513
GET /ghost/api/v0.1/posts/?page=1&limit=15&status=all&staticPages=all&include=tags 200 61.997 ms - -
GET /ghost/img/ghosticon.jpg 200 2.592 ms - 2499

```  

You can detach from the tty by pressing **ctrl-p + ctrl-q** in sequence. If you haven't started your container with ** -itd ** flag, then it is not possible to get your host's terminal back. In that case, If you haven't started the container with **-itd** option, then you have to use **--sig-proxy=false** falg with the attach command.  Then you will be able to detach from the container by using **ctrl-c**  
It is possible to override these keys too. For that we have to add --detach-keys flag to the command. To learn more, click on the following URL  

https://docs.docker.com/engine/reference/commandline/attach/  

### Copying files between container and client host  

We can copy files/directories form host to container and vice-versa    
Let us create a file on the host  
```
touch testfile
```  

To copy the testfile **from host machine to ghsot contanier**, try  
```
docker cp testfile ghost:/opt  
```  
This command will copy testfile to ghost container's **/opt** directory  and will not give any output. To verify the file has been copies or not, let us log into container by running,  

```
docker exec -it ghost bash
```  
Change directory into /opt and list the files  

```
cd /opt  
ls
```  

[Output]  

```
testfile
```  

There you can see that file has been successfully copied. Now exit the container  

Now you may try to cp some files **from the container to the host machine**  
Before that you have to change host machine's current working directory to **/vagrant**. This has to be done, because the CentOS VM is **mounted** that directory only.  

```
cd /vagrant  
docker cp ghost:/usr/src/ghost .  
ls  
```  
You might get some protocol errors. The reason for this is, it tries to create a symlink to a file on host machine, which does not exist.  

### Rename a  container  
When you want to rename a container, we can use use **rename** command. Let us change our **ghost** container's name to **ghostapp**. Try *docker ps* to see the changes,

 ```
 docker rename ghost ghostapp  
 docker ps  
 ```  

 [Output]  

 ```
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                     NAMES
b28efeef41f8        ghost:0.10.1        "/entrypoint.sh npm s"   20 hours ago        Up 2 minutes        0.0.0.0:32768->2368/tcp   ghostapp
 ```

### Controlling Resources  
Docker provides us the granularity to control each container's **resource utilization**. We have several commands in the inventory to achieve this  

#### Putting limits on Running Containers  
First, let us see the memory utilization of our ghostapp container, by trying

```
docker inspect ghostapp | grep -i memory  
```  

[Output]  

```
"Memory": 0,
"KernelMemory": 0,
"MemoryReservation": 0,
"MemorySwap": 0,
"MemorySwappiness": -1,
```  

You can see that **Memory** attribute has **0** as its value. 0 means unlimited usage of host's RAM. We can put a cap on that by using **update** command  

```
docker update -m 400M ghostapp  
```  

[Output]  

```
ghostapp
```  
Let us check whether the change has taken effect or not  

```
docker inspect ghostapp | grep -i memory
```  

[Output]  

```
"Memory": 419430400,
"KernelMemory": 0,
"MemoryReservation": 0,
"MemorySwap": 0,
"MemorySwappiness": -1,

```  
As you can see, the memory utilization of the container is changed from 0 (unlimited) to 400 mb  

#### Limiting Resources while launching new containers  
The following resources can be limited using the *update* command  
  * CPU
  * Memory
  * Disk IO
  * Capabilities  

Open two terminals, lets call them T1, and T2  
In T1, start monitoring the stats  

```
docker stats
```  

[Output]  
```
CONTAINER           CPU %               MEM USAGE / LIMIT     MM %               NET I/O             BLOCK I/O             PIDS
b28efeef41f8        0.16%               190.1 MiB / 400 MiB   47.51%              1.296 kB / 648 B    86.02 kB / 45.06 kB   0
CONTAINER           CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O             PIDS
b28efeef41f8        0.01%               190.1 MiB / 400 MiB   47.51%              1.296 kB / 648 B    86.02 kB / 45.06 kB   0
```

From T2, launch two containers with different CPU shares. Default CPU shares are set to 1024. This is a relative weight.  

```
docker run -d --name st-01  schoolofdevops/stresstest stress --cpu 1

docker run -d --name st-02 -c 512  schoolofdevops/stresstest stress --cpu 1

```  
When you launch the first container, it will use the full quota of CPU, i.e., 100%  

[Output - **After first container launch**]  

```
CONTAINER           CPU %               MEM USAGE / LIMIT       MEM %               NET I/O             BLOCK I/O             PIDS
b28efeef41f8        0.01%               190.1 MiB / 400 MiB     47.51%              1.944 kB / 648 B    86.02 kB / 45.06 kB   0
764f158d6523        102.73%             2.945 MiB / 1.797 GiB   0.16%               648 B / 648 B       3.118 MB / 0 B        0
```  

[Output - **After second container lauch**]  

```
CONTAINER           CPU %               MEM USAGE / LIMIT       MEM %               NET I/O             BLOCK I/O             PIDS
b28efeef41f8        0.00%               190.1 MiB / 400 MiB     47.51%              2.592 kB / 648 B    86.02 kB / 45.06 kB   0
764f158d6523        66.97%              2.945 MiB / 1.797 GiB   0.16%               1.296 kB / 648 B    3.118 MB / 0 B        0
a13f98995ade        33.36%              2.945 MiB / 1.797 GiB   0.16%               648 B / 648 B       3.118 MB / 0 B        0
```  

Observe stats in T1
Launch a couple more nodes with different cpu shares, observe how T2 stats change  

```
docker run -d --name st-03 -c 512  schoolofdevops/stresstest stress --cpu 1

docker run -d --name st-04  schoolofdevops/stresstest stress --cpu 1

```  

[Output - **After all containers are launched**]  

```
CONTAINER           CPU %               MEM USAGE / LIMIT       MEM %               NET I/O             BLOCK I/O             PIDS
b28efeef41f8        0.00%               190.1 MiB / 400 MiB     47.51%              3.888 kB / 648 B    86.02 kB / 45.06 kB   0
764f158d6523        32.09%              2.945 MiB / 1.797 GiB   0.16%               2.592 kB / 648 B    3.118 MB / 0 B        0
a13f98995ade        16.02%              2.945 MiB / 1.797 GiB   0.16%               1.944 kB / 648 B    3.118 MB / 0 B        0
f04e9ea5627c        16.37%              2.949 MiB / 1.797 GiB   0.16%               1.296 kB / 648 B    3.118 MB / 0 B        0
abeab389a873        31.71%              2.949 MiB / 1.797 GiB   0.16%               648 B / 648 B       3.118 MB / 0 B        0
```  
Close the T2 terminal  

#### Exercises  
Try to these exercises, to get a better understanding  
  * Put a memory limit
  * Set disk iops

### Launching Containers with Elevated  Privileges  
When the operator executes docker run --privileged, Docker will enable to access to all devices on the host as well as set some configuration in AppArmor or SELinux to allow the container nearly all the same access to the host as processes running outside containers on the host.

#### Example:  
##### Running a sysdig container to monitor docker  
Sysdig tool allows us to monitor the processes that are going on in the other containers. It is more like running a top command from one container on behalf of others.  

```
docker run -itd --name=sysdig --privileged=true \
           --volume=/var/run/docker.sock:/host/var/run/docker.sock \
           --volume=/dev:/host/dev \
           --volume=/proc:/host/proc:ro \
           --volume=/boot:/host/boot:ro \
           --volume=/lib/modules:/host/lib/modules:ro \
           --volume=/usr:/host/usr:ro \
           sysdig/sysdig:0.11.0 sysdig
```  
[Output]  
```
Unable to find image 'sysdig/sysdig:0.11.0' locally
0.11.0: Pulling from sysdig/sysdig

0f409b0f5b3d: Pull complete
64965da77fc6: Pull complete
588eeb0d4c30: Pull complete
9aa18e35b362: Pull complete
cc036f2dca14: Pull complete
33400f3af946: Pull complete
b39ed90e36fd: Pull complete
1fca16436380: Pull complete
Digest: sha256:ee9d66a07308c5aef91f070cce5c9fb891e4fefb5da4d417e590662e34846664
Status: Downloaded newer image for sysdig/sysdig:0.11.0
6ba17cf2af7b87621b3380517af45c5785dc8cda75111f0f8c36bb83e163a120
```

```
docker exec -it sysdig bash
csysdig
```  

[Output]  

![sysdig](images/sysdig.png)  

After this, press f2 and select **containers** tab  
Now check what are the processes are running in other containers  

![sysdig](images/sysdig2.png)  


##### References

[Resource Management in Docker by Marek Goldmann] (https://goldmann.pl/blog/2014/09/11/resource-management-in-docker/)
