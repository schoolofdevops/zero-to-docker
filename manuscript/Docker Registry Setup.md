# Docker Registry  
The Registry is a stateless, highly scalable server side application that stores and lets you distribute Docker images.

### Setting up the Docker Registry  
```
docker run -d -p 5000:5000 --name registry registry:2
```  
This pulls the registry:2 image from the docker hub and runs the docker container. The name of the container is Registry.  
```
docker pull ubuntu && docker tag ubuntu localhost:5000/myfirstimage
```

This pulls the ubuntu image from the docker hub. And we tag the image to localhost:5000/myfirstimage  
```
docker push localhost:5000/myfirstimage
```  
When we try to push the image, it locally saves in the host file system. This we call as the **Docker Registry**  
To stop the Registry we use  
```
docker stop registry
```  
To remove Registry with all the data  
```
docker rm -v registry
```

### Docker Private Registry  
Docker Private Registry is to deploy the docker images present in one VM or host to another VM or Host.  
Create a file system like given below in the host computer  
```
.
├── Docker
│   └── Vagrantfile
└── Docker-Client
    └── Vagrantfile
```  
Both vagrant file bringing up the same Vagrant Box file.

Change the ip in the both the Vagrentfile as "192.168.33.10" and "192.168.33.11"

Now bring up the VM in the Docker directory.  

```
vagrant up; vagrant ssh
```

Once both the machines are up add an entry in `/etc/hosts`

```
<Machine IP> myregistrydomain.com
```

*Note: Replace `<Machine IP>` with the respective vagrant machine IP's*

We need to install Docker Compose first.  

```
yum install python-pip
pip install docker-compose
```  

### Setting Docker Registry  
After isntalling Docker Compose, its time to setup the .yml file for the Docker Compose.  
Since we need a place to store the list of users who can access our Registry we need a place to store it. So we are going to install httpd-tools which contains the package called as **htpasswd**  
```
yum install httpd-tools
mkdir ~/docker-registry && cd $_
mkdir data
```  
In the docker-registry, we create the .yml file for compose.  
```
vim docker-compose.yml
```  
Now add the following contents contents  
```
registry:
  image: registry:2
  ports:
    - 127.0.0.1:5000:5000
  environment:
    REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY: /data
  volumes:
    - ./data:/data
```  
Now save the file. And run docker compose.  
```
docker-compose up -d
```  
Now to stop and remove the container that have been created  
```
docker-compose stop  
docker-compose rm
```  

### Setting Nginx container  
Edit docker compose file so that we can add the configurations for Nginx.  
```
vim docker-compose.yml
```  
Add the contents  
```
nginx:
  image: "nginx:1.9"
  ports:
    - 5043:443
  links:
    - registry:registry
  volumes:
    - ./nginx/:/etc/nginx/conf.d:ro
```  
The full docker-compose.yml looks like  
```
nginx:
  image: "nginx:1.9"
  ports:
    - 5043:443
  links:
    - registry:registry
  volumes:
    - ./nginx/:/etc/nginx/conf.d
registry:
  image: registry:2
  ports:
    - 127.0.0.1:5000:5000
  environment:
    REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY: /data
  volumes:
    - ./data:/data
```  
Now we going to  edit the registry configurations for the SSL certification  
```
mkdir -p ~/docker-registry/nginx/
vim ~/docker-registry/nginx/registry.conf
```  
Add the following contents  
```
  upstream docker-registry {
  server registry:5000;
}

server {
  listen 443;
  server_name myregistrydomain.com;

  # SSL
  # ssl on;
  # ssl_certificate /etc/nginx/conf.d/domain.crt;
  # ssl_certificate_key /etc/nginx/conf.d/domain.key;

  # disable any limits to avoid HTTP 413 for large image uploads
  client_max_body_size 0;

  # required to avoid HTTP 411: see Issue #1486 (https://github.com/docker/docker/issues/1486)
  chunked_transfer_encoding on;

  location /v2/ {
    # Do not allow connections from docker 1.5 and earlier
    # docker pre-1.6.0 did not properly set the user agent on ping, catch "Go *" user agents
    if ($http_user_agent ~ "^(docker\/1\.(3|4|5(?!\.[0-9]-dev))|Go ).*$" ) {
      return 404;
    }

    # To add basic authentication to v2 use auth_basic setting plus add_header
    # auth_basic "registry.localhost";
    # auth_basic_user_file /etc/nginx/conf.d/registry.password;
    # add_header 'Docker-Distribution-Api-Version' 'registry/2.0' always;

    proxy_pass                          http://docker-registry;
    proxy_set_header  Host              $http_host;   # required for docker client's sake
    proxy_set_header  X-Real-IP         $remote_addr; # pass on real client's IP
    proxy_set_header  X-Forwarded-For   $proxy_add_x_forwarded_for;
    proxy_set_header  X-Forwarded-Proto $scheme;
    proxy_read_timeout                  900;
  }
}
```  
Save the file and exit  
Now again start the docker compose.  
```
docker-compose up -d
```  
To check whether Docker Registry is working or not try the following command  
```
curl http://localhost:5000/v2/
```  
The output will be **{}**  
And also try  
```
curl http://localhost:5043/v2/
```  
The output will be **{}**  
Now to stop and remove the container that have been created  
```
docker-compose stop  
docker-compose rm
```  
Next we going to create user and  their password who can login and access our Docker Registry

(Replace USERNAME with your *username*)

```
cd ~/docker-registry/nginx
htpasswd -c registry.password USERNAME
```  
For the first time when we run the command we use the option -c so that it creates the file. After that we dont need to use that option when we create Username  
Now in the registry.conf which we created we are going to make some changes  
```
vim ~/docker-registry/nginx/registry.conf
```  
Delete the below lines and  
```
# To add basic authentication to v2 use auth_basic setting plus add_header
# auth_basic "registry.localhost";
# auth_basic_user_file /etc/nginx/conf.d/registry.password;
# add_header 'Docker-Distribution-Api-Version' 'registry/2.0' always;
```  
And add the following lines  
```
# To add basic authentication to v2 use auth_basic setting plus add_header
auth_basic "registry.localhost";
auth_basic_user_file /etc/nginx/conf.d/registry.password;
add_header 'Docker-Distribution-Api-Version' 'registry/2.0' always;
```  
Now we are going to start the Docker Compose to see the changes  that we have done in the configuration file.  
```
cd ~/docker-registry
docker-compose up -d
```  
Now check the in the command line  
```
curl http://localhost:5043/v2/
```  
[Output]  
```
<html>
<head><title>401 Authorization Required</title></head>
<body bgcolor="white">
<center><h1>401 Authorization Required</h1></center>
<hr><center>nginx/1.9.7</center>
</body>
</html>
```  
This is because we we have given the registry.password file for the authentication.  
Now try the below command to check  
```
curl http://USERNAME:PASSWORD@localhost:5043/v2/
```  
Now to stop and remove the container that have been created  
```
docker-compose stop  
docker-compose rm
```  

### Setitng the ssl certificates  
For SSL certificate go to the registry.conf files and do the following changes  
```
nano ~/docker-registry/nginx/registry.conf
```  
Delete the following lines of code  
```
server {
listen 443;
server_name myregistrydomain.com;
# SSL
# ssl on;
# ssl_certificate /etc/nginx/conf.d/domain.crt;
# ssl_certificate_key /etc/nginx/conf.d/domain.key;
```  
And add these lines  
```
# SSL
ssl on;
ssl_certificate /etc/nginx/conf.d/domain.crt;
ssl_certificate_key /etc/nginx/conf.d/domain.key;
```  
Save and exit the file.  

### Creating and Signing the Certificates  

Now we are going to create and sign the SSL certificate.  

```
cd ~/docker-registry/nginx
```  

Generating the root key:  
```
openssl genrsa -out devdockerCA.key 2048
```  

Generating the root certificate(Press Enter whenever it prompts):

```
openssl req -x509 -new -nodes -key devdockerCA.key -days 10000 -out devdockerCA.crt
``` 

Generating the key for the server:  

```
openssl genrsa -out domain.key 2048
```  

Now we are going to send a certificate signing request.

Press Enter whenever it prompts and When it asks for the **"Common Name (eg, your name or your server's hostname) []:"** type the ip of the machine or the server address (Which you have given in registry.conf near server_name)

**Don't create a challenging password**

```
openssl req -new -key domain.key -out dev-docker-registry.com.csr
```  

Now we are going to sign the certificates request  

```
openssl x509 -req -in dev-docker-registry.com.csr -CA devdockerCA.crt -CAkey devdockerCA.key -CAcreateserial -out domain.crt -days 10000
```  

Since the certificates are signed by ourself not by the Certificate Authority we have to tell the docker client that we have the authorized certificates. Now we are going to do that locally by running the following commands,

```
update-ca-trust force-enable
cp devdockerCA.crt /etc/pki/ca-trust/source/anchors/
update-ca-trust extract
```  

Restart the docker service and run the docker compose file.  
```
sudo service docker restart
cd ~/docker-registry
docker-compose up -d
```  
To check the output:  
```
curl https://USERNAME:PASSWORD@[YOUR-DOMAIN]:5043/v2/
```  
To stop and remove the container that have been created  
```
docker-compose stop  
docker-compose rm
```  
Changing the ports of the Nginx from 5043 to 443 in docker-compose.yml  
Change it from  
```
    - 5043:443
```  
to  
```
    - 443:443
```  
Save and exit  
Run the compose file  
```
docker-compose up -d
```  
To check the output:  
```
curl https://<YOURUSERNAME>:<YOURPASSWORD>@YOUR-DOMAIN/v2/
```  

### Accessing Your Docker Registry from a Client Machine  
Now we have to copy the devdockerCA file from the Registry VM to the Client VM so that we can access the Docker Registry.  
```
sudo cat /docker-registry/nginx/devdockerCA.crt
```  
Copy the above data in the file  

#### ON CLIENT MACHINE:  
Paste the data present in the devdockerCA.crt in the below file  
```
vim /etc/pki/ca-trust/source/anchors/debdockerCA.crt
```  
Now update the certificates and restart the docker service  
```
update-ca-trust extract
service docker restart
```  
Now we can access the Docker Registry that is present in the Other VM by  
```
docker login https://YOUR-DOMAIN
```  
```
Username: USERNAME

Password: PASSWORD
```  
After entering the correct username and their password we must get the following output  
```
"Login Succeeded"
```  
Now lets just pull and run ubuntu images. Do some changes in it and try pushing it to the docker registry.  
```
docker run -t -i ubuntu /bin/bash
touch initcron
exit
docker commit $(docker ps -lq) test-image
```  
Now lets login to the registry and push the changes that we made in the ubuntu container.  
```
docker login https://YOUR-DOMAIN
```  
```
Username: USERNAME

Password: PASSWORD
```  
```
docker tag test-image [YOUR-DOMAIN]/test-image
docker push [YOUR-DOMAIN]/test-image
```  

[Output]  
```
latest: digest: sha256:5ea1cfb425544011a3198757f9c6b283fa209a928caabe56063f85f3402363b4 size: 8008
```  
Now check it we can go back to the server and follow the steps  
```
docker pull [YOUR-DOMAIN]/test-images
docker run -t -i [YOUR-DOMAIN]/test-images /bin/bash
ls
```  
Now here we can see that the file which we created "initcron" is available.  
The Docker Private Registry is successfully configured.  
