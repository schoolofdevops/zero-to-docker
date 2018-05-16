# Stack/Layer  Based Troubleshooting

## UCP Troubleshooting

[UCP Architecture]
(https://docs.docker.com/datacenter/ucp/2.2/guides/architecture/)

[UCP Node States[(
https://docs.docker.com/ee/ucp/admin/monitor-and-troubleshoot/troubleshoot-node-messages/#ucp-node-states)

[Troubleshooting UCP Cluster Matrix](
https://success.docker.com/article/troubleshooting-a-ucp-22x-cluster)


### Swarm Configurations Troubleshooting

On UCP Node, check the key value cluster health

```
docker exec -it ucp-kv etcdctl \
        --endpoint https://127.0.0.1:2379 \
        --ca-file /etc/docker/ssl/ca.pem \
        --cert-file /etc/docker/ssl/cert.pem \
        --key-file /etc/docker/ssl/key.pem \
        cluster-health
```


### Rethink DB Status


```

NODE_ADDRESS=$(docker info --format '{{.Swarm.NodeAddr}}')
VERSION=$(docker image ls --format '{{.Tag}}' docker/ucp-auth | head -n 1)
docker container run --rm -v ucp-auth-store-certs:/tls docker/ucp-auth:${VERSION} --db-addr=${NODE_ADDRESS}:12383 db-status

```

## DTR Troubleshooting



Health Checks

https://dtr.schoolofdevops.org/_ping
https://dtr.schoolofdevops.org/nginx_status
https://dtr.schoolofdevops.org/api/v0/meta/cluster_status


DTR Overlay and RethinkDB Troubleshooting https://docs.docker.com/ee/dtr/admin/monitor-and-troubleshoot/troubleshoot-with-logs/


## Swarm Troubleshooting


Node Level
```
docker node ls
docker node inspect <node>
docker node update --availability drain <node>
docker node rm <node>
```

Service Level

```
docker service ls
docker service ps <service>
docker service inspect <service>
docker service logs <service>
```

Look for **CreatedAt**,  **UpdatedAt** to corroborate with start of the issue.


Tasks/Containers
```
docker inspect <container>
docker logs <container>

```



### Finding Docker Daemon Logs


  * Ubuntu (old using upstart ) - /var/log/upstart/docker.log
  * Ubuntu (new using systemd ) - sudo journalctl -fu docker.service
  * Boot2Docker - /var/log/docker.log
  * Debian GNU/Linux - /var/log/daemon.log
  * CentOS - /var/log/daemon.log | grep docker
  * CoreOS - journalctl -u docker.service
  * Fedora - journalctl -u docker.service
  * Red Hat Enterprise Linux Server - /var/log/messages | grep docker
  * OpenSuSE - journalctl -u docker.service
  * OSX - ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/log/d‌​ocker.log
  * Windows - Get-EventLog -LogName Application -Source Docker -After (Get-Date).AddMinutes(-5) | Sort-Object Time




## System Troubleshooting


### File Descriptors

```
cat /proc/sys/fs/file-max
```


```
cat /proc/sys/fs/file-nr
```

[output]
```
1632	0	202648
```

where,

1632: currently allocated file descriptors
0: free allocated file descriptors
202648 : max file descriptors


To update the limit
```
ulimit -n 99999
sysctl -w fs.file-max=100000

docker run --ulimit nofile=90000:90000 <image-tag>
```

To check open files
```
lsof

lsof | wc -l

lsof | grep <pid>
```








**References**


Etcd and RethinkDB Troubleshooting: https://docs.docker.com/datacenter/ucp/2.2/guides/admin/monitor-and-troubleshoot/troubleshoot-configurations/#check-the-status-of-the-database



Where are docker daemon logs, stackoverflow discussion https://stackoverflow.com/questions/30969435/where-is-the-docker-daemon-log?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa


File Descriptors: https://www.netadmintools.com/art295.html
