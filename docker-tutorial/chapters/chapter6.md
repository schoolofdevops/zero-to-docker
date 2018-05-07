#Dockerizing your Applications : Building Images and Working with Registries

In the previous session, we have learnt about various container operations such as running containers from
pre built images, port mapping, inspecting and updating containers, limiting resources etc., In this
chapter, we are going to learn about how to build containers for your individual applications, as well
as how to work with docker hub registry to host and distribute the images.  


### Registering with the Registry : Creating an Account on DockerHub
Since we are going to start working with the registry, build and push images to it later, its essential to have our own account on the registry. For the purpose of this tutorial, we are going to use the hosted registry i.e. Dockerhub.  

Steps to create Dockerhub account  
#### Step 1:  
Visit the following link and sign up with your email id  
  **https://hub.docker.com/**

  ![hub](images/chp6/hub1.png)  

#### Step 2:  
Check your email inbox and check the activation email sent by docker team  

#### Step 3:  
After clicking on the activation link, you will be redirected to a log in page. Enter your credentials and log in  

  ![hub](images/chp6/hub2.png)  

You will be launched to Dockerhub main page. Now the registration process is complete and you have account in Dockerhub!  

  ![hub](images/chp6/hub3.png)  

### Building Docker Images - A manual approach

Before we start building automated images, we are going to create a docker image by hand. We have already used the pre built image from the registry in the last session. In this session, however, we are going to create our own image with ghost installed. Since Ghost is a node.js based application, we will base our work on existing offical image for **node**  

##### Types of Images  

  * Slim  
  * Complete  

To search an image from the registry we could use,  

```
docker search node
```  

[Output]  

```
NAME                      DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
node                      Node.js is a JavaScript-based platform for...   2815      [OK]
strongloop/node           StrongLoop, Node.js, and tools.                 31                   [OK]
nodered/node-red-docker   Node-RED Docker images.                         24                   [OK]
bitnami/node              Bitnami Node.js Docker Image                    16                   [OK]
siomiz/node-opencv        _/node + node-opencv                            8                    [OK]
calico/node                                                               8                    [OK]
dahlb/alpine-node         small node for gitlab ci runner                 7                    [OK]
cusspvz/node              🌐 Super small Node.js container (~15MB)...      5                    [OK]
anigeo/node-forever       Daily build node.js with forever                4                    [OK]
azukiapp/node             Docker image to run Node.js by Azuki - htt...   4                    [OK]
tutum/node                Run a Tutum node inside a container             3                    [OK]
seegno/node               A node docker base image.                       2                    [OK]
starefossen/ruby-node     Docker Image with Ruby and Node.js installed    2                    [OK]
wallarm/node              Wallarm Node                                    2                    [OK]
urbanmassage/node         Some handy (read, better) docker node images    1                    [OK]
joxit/node                Slim node docker with some utils for dev        1                    [OK]
tectoro/node-compass      Node JS minimal version with compass and b...   1                    [OK]
centralping/node          Bare bones CentOS 7 NodeJS container.           1                    [OK]
redjack/node              Node + Nave                                     1                    [OK]
xataz/node                very light node image                           1                    [OK]
robbertkl/node            Docker container running Node.js                0                    [OK]
instructure/node          Instructure node images                         0                    [OK]
c4tech/node               NodeJS images, aimed at generated single-p...   0                    [OK]
codexsystems/node         Node.js for Development and Production          0                    [OK]
watsco/node               node:6                                          0                    [OK]

```

You could find the same results when you search using the UI

TODO: Add a screenshot which shows searching for node image on docker hub

Lets launch a intermediate container using the image above. We will use this container to install and configure ghost and its dependencies.  

```
docker run -idt --name intermediate node:4-slim bash
```

[Output]  

```   
  Unable to find image 'node:4-slim' locally
  4-slim: Pulling from library/node

  8ad8b3f87b37: Pull complete
  751fe39c4d34: Pull complete
  3c8031bea3fa: Pull complete
  854b52827bb4: Pull complete
  Digest: sha256:52d18a901cf295f5035cc98ad23473ee3f0acffa2f49683e921cf27c343ae774
  Status: Downloaded newer image for node:4-slim
  root@5a9d73b026e8:/#
```  

```
docker ps  
```  

[Output]  

```  
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
5e8153390e17        node:4-slim         "bash"              7 seconds ago       Up 5 seconds                            intermediate
```  

```
docker exec -it intermediate bash
```  

[Output]  

```
docker exec -it intermediate bash
root@5e8153390e17:/#
```  

##### Install and Configure Ghost on a Debian/Ubuntu system  

Install pre-requisites  

```
apt-get update && apt-get install -y gcc make python unzip vim

```  

Download and install ghost  

```  
mkdir /usr/src/ghost
cd /usr/src/ghost/
wget -c https://ghost.org/archives/ghost-0.10.1.zip  

```  

[Output]  

```
wget -c https://ghost.org/archives/ghost-0.10.1.zip
converted 'https://ghost.org/archives/ghost-0.10.1.zip' (ANSI_X3.4-1968) -> 'https://ghost.org/archives/ghost-0.10.1.zip' (UTF-8)
--2016-09-18 17:20:16--  https://ghost.org/archives/ghost-0.10.1.zip
Resolving ghost.org (ghost.org)... 104.16.83.186, 104.16.85.186, 104.16.81.186, ...
Connecting to ghost.org (ghost.org)|104.16.83.186|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 3988064 (3.8M) [application/zip]
Saving to: 'ghost-0.10.1.zip'

ghost-0.10.1.zip                           100%[========================================================================================>]   3.80M  30.9KB/s   in 2m 12s

2016-09-18 17:22:34 (29.5 KB/s) - 'ghost-0.10.1.zip' saved [3988064/3988064]
```  

```
unzip ghost-0.10.1.zip  
```  

[Output]  

```
Archive:  ghost-0.10.1.zip
  inflating: config.example.js
   creating: content/
   creating: content/apps/
  inflating: content/apps/README.md
   creating: content/data/
  inflating: content/data/README.md
   creating: content/images/
  inflating: content/images/README.md
   creating: content/themes/
   creating: content/themes/casper/
   creating: content/themes/casper/assets/
   creating: content/themes/casper/assets/css/
  inflating: content/themes/casper/assets/css/screen.css
   creating: content/themes/casper/assets/fonts/
  inflating: content/themes/casper/assets/fonts/casper-icons.eot
  inflating: content/themes/casper/assets/fonts/casper-icons.svg
  inflating: content/themes/casper/assets/fonts/casper-icons.ttf
  inflating: content/themes/casper/assets/fonts/casper-icons.woff
   creating: content/themes/casper/assets/js/
```  

```  
npm install --production
```  

[Output]  

```
npm info installOne string_decoder@0.10.31
npm info installOne core-util-is@1.0.2
npm info postinstall fs.realpath@1.0.0
npm info install boolbase@1.0.0 into /usr/src/ghost/node_modules/cheerio/node_modules/css-select
npm info install css-what@2.1.0 into /usr/src/ghost/node_modules/cheerio/node_modules/css-select
npm info install nth-check@1.0.1 into /usr/src/ghost/node_modules/cheerio/node_modules/css-select
npm info install domutils@1.5.1 into /usr/src/ghost/node_modules/cheerio/node_modules/css-select
npm info installOne boolbase@1.0.0
npm info installOne css-what@2.1.0
npm info installOne nth-check@1.0.1
npm info installOne domutils@1.5.1

```  
Create configuration for ghost  

```
cd /usr/src/ghost; mv config.example.js config.js  

```  

Edit config.js  

```
vim config.js

```  

Scroll to development block and change the server config to use 0.0.0.0 instead of 127.0.0.1  
E.g.  
```
            host: '0.0.0.0',
```

Cleanup  

```
apt-get purge -y --auto-remove gcc make python unzip vim
rm -rf /var/lib/apt/lists/*
rm ghost-0.10.1.zip
npm cache clean

```

[Output]  

```
npm info it worked if it ends with ok
npm info using npm@2.15.9
npm info using node@v4.5.0
npm info ok

```

```
rm -rf /tmp/npm*

```  

Exit from the container.  

Note down the container id for the container you just modified and exited from.  

```
docker ps -l

```

[Output]  

```
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
ea2d0ac8476e        node:4-slim         "bash"              50 minutes ago      Up 50 minutes                           intermediate
```  

To create a image by taking a snasnapshot of the container use the following command,

```
docker commit -a "Firstname Lastname" -m "commit message" CONTAINER HUB_USERNAME/REPO:TAG  

E.g. docker commit -a "John Doe" -m "creating custom ghost image" c082972f66d6 mydockerhubid/ghost:0.1.0

```  

[Output]  

```
docker commit -a "John Doe" -m "committing the changes" ea2d0ac8476e johmdoe/ghost:0.1.0
sha256:b514e85c275ea6a864987f9a055b3bca817f763868c6c168589179c42cee580c
```  

To launch a container with the above images in a development mode, use


```
docker run -d -w /usr/src/ghost  -p 2368 mydockerhubid/ghost:0.1.0 npm start

```  

[Output]  

```
docker run -d -w /usr/src/ghost  -p 2368 venkatsudharsanam/ghost:0.1.0 npm start
34f4da3403d81329855a52c13ecb0e49a0eee257800be83ddc7dfda569095469
```

Find out the port mapping, connect to http://host:port and validate your image.


### Dockerfiles - Automating Image Builds

Earlier, we created image by launching a intermediate container and manually installing and configuring ghost app. This time we are going to use a Dockerfile, write the specification to build image, and use it to automate the process of building image.  


#### Setting up a ghostapp repo on github  

We are going to setup a git repository where we create the configurations to automate the build process of our image. Later in this chapter, we will also integrate it with Dockerhub to create automated builds. For this purpose, its essential to have a github account.  

  * Create and Account on github, if you do not already have it  
  * Fork the ghostapp repo  
    **https://github.com/schoolofdevops/ghostapp**  
  * Clone the forked repo  
Install git on VM first  
```
yum install git  
```  
Clone the repository  
```
git clone https://github.com/YOUR_GITHUB_ID/ghostapp.git
```  

[Output]  

```
Cloning into 'ghostapp'...
remote: Counting objects: 12, done.
remote: Compressing objects: 100% (9/9), done.
remote: Total 12 (delta 3), reused 12 (delta 3), pack-reused 0
Unpacking objects: 100% (12/12), done.
```  
Change the current working directory  

```  
cd ghostapp
```  

Examine  Dockerfile in ghostapp directory.  

```
ls  
```  

[Output]  

```
config.js  docker-entrypoint.sh  Dockerfile  Dockerfile.inef  install_ghost.sh  LICENSE
```  

#### Building and Image with Dockerfile  
Let us build the docker image from the Dockerfile that we have inside the ghostapp directory  

[Syntax]  

```
docker build -t USERNAME/REPO:TAG  .   
```  
Example:  

```
docker build -t mydockerhubid/ghost:0.2.0 .
```  

Replace mydockerhubid with your DockerHub ID  

[Output]  

```
Sending build context to Docker daemon 79.87 kB
Step 1 : FROM node:4-slim
4-slim: Pulling from library/node

8ad8b3f87b37: Pull complete
751fe39c4d34: Pull complete
3c8031bea3fa: Pull complete
854b52827bb4: Pull complete
Digest: sha256:52d18a901cf295f5035cc98ad23473ee3f0acffa2f49683e921cf27c343ae774
Status: Downloaded newer image for node:4-slim
 ---> 48f7a334e4da
Step 2 : RUN groupadd user && useradd --create-home --home-dir /home/user -g user user
 ---> Running in 0e270a5b9941
 ---> a687627e462e
Removing intermediate container 0e270a5b9941
Step 3 : ENV GOSU_VERSION 1.7
 ---> Running in 9955ac3c391a
 ---> 3f3d9d60c5bb
Removing intermediate container 9955ac3c391a
Step 4 : RUN set -x     && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)"         && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc"         && export GNUPGHOME="$(mktemp -d)"      && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4        && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu     && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc   && chmod +x /usr/local/bin/gosu   && gosu nobody true
 ---> Running in e73ed282a080
+ dpkg --print-architecture
+ wget -O /usr/local/bin/gosu https://github.com/tianon/gosu/releases/download/1.7/gosu-amd64
converted 'https://github.com/tianon/gosu/releases/download/1.7/gosu-amd64' (ANSI_X3.4-1968) -> 'https://github.com/tianon/gosu/releases/download/1.7/gosu-amd64' (UTF-8)
--2016-09-18 17:32:22--  https://github.com/tianon/gosu/releases/download/1.7/gosu-amd64
Resolving github.com (github.com)... 192.30.253.112
Connecting to github.com (github.com)|192.30.253.112|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://github-cloud.s3.amazonaws.com/releases/19708981/40d1b00c-8619-11e5-8953-d0122dcf07b9?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAISTNZFOVBIJMK3TQ%2F20160918%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20160918T173223Z&X-Amz-Expires=300&X-Amz-Signature=3f340343a6f1b4d568a1d4ecb2af06c1e766e006ff5ea2c2d354d45c148d163b&X-Amz-SignedHeaders=host&actor_id=0&response-content-disposition=attachment%3B%20filename%3Dgosu-amd64&response-content-type=application%2Foctet-stream [following]
converted 'https://github-cloud.s3.amazonaws.com/releases/19708981/40d1b00c-8619-11e5-8953-d0122dcf07b9?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAISTNZFOVBIJMK3TQ%2F20160918%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20160918T173223Z&X-Amz-Expires=300&X-Amz-Signature=3f340343a6f1b4d568a1d4ecb2af06c1e766e006ff5ea2c2d354d45c148d163b&X-Amz-SignedHeaders=host&actor_id=0&response-content-disposition=attachment%3B%20filename%3Dgosu-amd64&response-content-type=application%2Foctet-stream' (ANSI_X3.4-1968) -> 'https://github-cloud.s3.amazonaws.com/releases/19708981/40d1b00c-8619-11e5-8953-d0122dcf07b9?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAISTNZFOVBIJMK3TQ/20160918/us-east-1/s3/aws4_request&X-Amz-Date=20160918T173223Z&X-Amz-Expires=300&X-Amz-Signature=3f340343a6f1b4d568a1d4ecb2af06c1e766e006ff5ea2c2d354d45c148d163b&X-Amz-SignedHeaders=host&actor_id=0&response-content-disposition=attachment; filename=gosu-amd64&response-content-type=application/octet-stream' (UTF-8)
--2016-09-18 17:32:24--  https://github-cloud.s3.amazonaws.com/releases/19708981/40d1b00c-8619-11e5-8953-d0122dcf07b9?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAISTNZFOVBIJMK3TQ/20160918/us-east-1/s3/aws4_request&X-Amz-Date=20160918T173223Z&X-Amz-Expires=300&X-Amz-Signature=3f340343a6f1b4d568a1d4ecb2af06c1e766e006ff5ea2c2d354d45c148d163b&X-Amz-SignedHeaders=host&actor_id=0&response-content-disposition=attachment;%20filename=gosu-amd64&response-content-type=application/octet-stream
Resolving github-cloud.s3.amazonaws.com (github-cloud.s3.amazonaws.com)... 54.231.18.1
Connecting to github-cloud.s3.amazonaws.com (github-cloud.s3.amazonaws.com)|54.231.18.1|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 2698808 (2.6M) [application/octet-stream]
Saving to: '/usr/local/bin/gosu'

     0K .......... .......... .......... .......... ..........  1% 74.7K 35s
    50K .......... .......... .......... .......... ..........  3%  111K 28s
   100K .......... .......... .......... .......... ..........  5%  115K 26s
   150K .......... .......... .......... .......... ..........  7%  121K 24s
   200K .......... .......... .......... .......... ..........  9%  116K 23s
   250K .......... .......... .......... .......... .......... 11%  118K 22s
   300K .......... .......... .......... .......... .......... 13%  116K 21s
   350K .......... .......... .......... .......... .......... 15%  110K 21s
   400K .......... .......... .......... .......... .......... 17%  126K 20s
   450K .......... .......... .......... .......... .......... 18%  116K 19s
   500K .......... .......... .......... .......... .......... 20%  119K 19s
   550K .......... .......... .......... .......... .......... 22%  112K 18s
   600K .......... .......... .......... .......... .......... 24%  118K 18s
   650K .......... .......... .......... .......... .......... 26%  119K 17s
   700K .......... .......... .......... .......... .......... 28%  114K 17s
   750K .......... .......... .......... .......... .......... 30%  117K 16s
   800K .......... .......... .......... .......... .......... 32%  178K 16s
   850K .......... .......... .......... .......... .......... 34%  118K 15s
   900K .......... .......... .......... .......... .......... 36%  116K 15s
   950K .......... .......... .......... .......... .......... 37%  119K 14s
                      [...]
                      [...]

Step 9 : ENV GHOST_CONTENT /var/lib/ghost
---> Running in 61156b2cb537
---> b4d0a9e54b19
Removing intermediate container 61156b2cb537
Step 10 : RUN mkdir -p "$GHOST_CONTENT" && chown -R user:user "$GHOST_CONTENT"
---> Running in 49683136928e
---> 681806385936
Removing intermediate container 49683136928e
Step 11 : VOLUME $GHOST_CONTENT
---> Running in d0b7478efbda
---> 176ce970d008
Removing intermediate container d0b7478efbda
Step 12 : COPY docker-entrypoint.sh /entrypoint.sh
---> df254620db94
Removing intermediate container fb8a57cf6f9b
Step 13 : ENTRYPOINT /entrypoint.sh
---> Running in ef5ac64665fc
---> e309f1dc79d2
Removing intermediate container ef5ac64665fc
Step 14 : EXPOSE 2368
---> Running in 49ce8d5c291d
---> d7e9bacd0ed2
Removing intermediate container 49ce8d5c291d
Step 15 : CMD npm start
---> Running in 9852f53a50b6
---> 370a54dfe27f
Removing intermediate container 9852f53a50b6
Successfully built 370a54dfe27f
                [...]
```  

Let us verify the image has been created or not  
```
docker images

```  

[Output]  

```
REPOSITORY            TAG                 IMAGE ID            CREATED             SIZE
mydockerhubid/ghost   0.2.0               370a54dfe27f        4 minutes ago       389.6 MB
node                  4-slim              48f7a334e4da        2 weeks ago         207.1 MB
```  

Validate the image is working by launching it  

```
docker run --name ghost2 -P  -itd mydockerhubid/ghost:0.2.0
```  

[Output]  

```
163118dad446505dc6539ad07e489e604c666f7158c72c4d19d76f00094b293a
```
Let us check the status of the container  
```
docker ps
```  

[Output]  

```
CONTAINER ID        IMAGE                       COMMAND                  CREATED              STATUS              PORTS                     NAMES
163118dad446        mydockerhubid/ghost:0.2.0   "/entrypoint.sh npm s"   About a minute ago   Up About a minute   0.0.0.0:32768->2368/tcp   ghost2
```  

```
docker port ghost2
```  

[Output]  

```
2368/tcp -> 0.0.0.0:32768
```

Let us verify the application by visiting, **http://HOST:PORT** which shows up ghost page.


### Dockerfile Primer  


| INSTRUCTION     | DESCRIPTION    |
| :------------- | :------------- |
| FROM       | The base image to use in the build. This is mandatory and must be the first command in the file      |
| MAINTAINER       | An optional value for the maintainer of the script      |
| RUN       | Executes a command and save the result as a new layer      |
| LABEL       | Adds metadata to an image      |
| ENV       | 	Sets an environment variable in the new container      |
| COPY       | Copies a file from the host system onto the container      |
| ADD       | 	Copies a file from the host system onto the container(Advanced than COPY)      |
| VOLUME       | Creates a shared volume that can be shared among containers or by the host machine      |
| USER       | Sets the user name or UID to use when running the image      |
| CMD       | 	The command that runs when the container starts      |
| ENTRYPOINT       | The command that runs when the container starts and takes runtime parameters      |
| ONBUILD       | 	A command that is triggered when the image in the Dcokerfile is used as a base for another image      |
| STOPSIGNAL       | Sets the system call signal that will be sent to the container to exit      |
| HEALTHCHECK       | Tells Docker how to test a container to check that it is still working      |
| SHELL       | Allows the default shell used for the shell form of commands to be overridden      |
| WORKDIR       | 	Set the default working directory for the container      |
| ARG | Defines a variable that users can pass at build-time to the builder with the docker build command using the --build-arg <varname>=<value> flag |


### Inefficient RUN Instructions  

As used in the reference Dockerfile, you have built the ghost image, its useful to combine multiple commands into a single RUN instruction. This is because each of the instructions are going to create a layer.

Lets see what happens if you have inefficient RUN instructions.

In the app directory that you downloaded earlier, examine Dockerfile.inef, and see if you could spot the difference between this and previous Dockerfile that you used.

Now, lets attempt building an image with Dockerfile.inef.

```
docker build -t mydockerhubid/ghost:inef -f Dockerfile.inef .
```

Now examine the difference between the images created with two different Dockerfiles

docker images | grep ghost  

### Tagging Images  
We can tag image with desired repository. This can be achieved by following the below syntax  

```
docker tag IMAGE HUB_USERNAME/REPO:TAG

```

e.g.

```
docker tag 20ebdc62d89b mydockerhubid/ghost:latest  

```  
Replace #mydockerhubid with your docker hub id  

Let us validate the tagged image is in the list of no

#### Exercise:  
Find out the id of 0.2.0 image you build with dockerfile and tag it as latest.  


### Pushing Images to Registry  
We can use DockerHub registry to save our images. These images can either be private or be public. First log in to DockerHub by running,   

```
docker login
```  

[Output]  

```
Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.
Username: YOUR_DOCKERHUB_ID
Password: YOUR_DOCKERHUB_PASSWORD
Login Succeeded
```  

Let us push the ghost image that we have created using Dockerfile  

```
docker push mydockerhubid/ghost:0.2.0
docker push mydockerhubid/ghost:latest
```  

[Output]  

```
The push refers to a repository [docker.io/dialectpython/ghost]
1ebb83d1c095: Pushed
85db16821dc0: Pushed
dae3fd4d8f65: Pushed
183fa3b0a41b: Pushed
a5ae0cdecf97: Pushed
d8a2dd69eab2: Pushed
063d700495d9: Pushed
b5606c271900: Pushed
17587239b3df: Pushed
9e63c5bce458: Pushed
latest: digest: sha256:664be48340de2f3a201869ec7a5faa4c721b6758b0ab94063753a15b9efa16e1 size: 2413  

```  
Let us validate whether this image has been uploaded to our Dockerhub registry or not  

![hub](images/chp6/hub4.png)  

### Create Automated Builds  

After having published our images to Dockerhub, we are also going to setup a process to create automated builds.  

#### Step 1  

![hub](images/chp6/hub5.png)  

#### Step 2  

![hub](images/chp6/hub6.png)  

#### Step 3  

![hub](images/chp6/hub7.png)  

#### Step 4  

![hub](images/chp6/hub8.png)  

#### Step 5  

![hub](images/chp6/hub8.png)  

#### Step 6  

Authorize DockerHub application on Github  

#### Step 7  

Again go back to DockerHub dashboard and click on the following link  

![hub](images/chp6/hub5.png)  

#### Step 8  

![hub](images/chp6/hub9.png)  

#### Step 10  

![hub](images/chp6/hub10.png)  

#### Step 11  

![hub](images/chp6/hub11.png)  

#### Step 12  

![hub](images/chp6/hub12.png)  

There you go... You have created an automated build on DockerHub
