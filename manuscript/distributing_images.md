
# Distributing Docker Images and Advanced Image Operations

  * Using public registry (Docker Hub)
    * Public Repos
    * Private Repos
    * Automated Builds

  * Using Private Registry
    * VMWare Harbor

  * Offline Distribution
    * docker image save
    * docker image load  

  * Flatten Images
    * docker container export
    * docker image import



By now, you would  have already  learnt how to use  Docker Hub as a public registry to distribute images, with public repositories. In addition to the public repos, you could also create private repo on Docker Hub and share access with specific group of people.




### Offline distribution of images

```
docker image pull schoolofdevops/vote

docker image save schoolofdevops/vote -o schoolofdevops_vote.tar

docker image rm schoolofdevops/vote

docker image ls

docker image load -i schoolofdevops_vote.tar

```


### Flattening Images

```
docker image history schoolofdevops/vote

docker container run -idt -P --name vote schoolofdevops/vote

docker container  export vote -o schoolofdevops_vote_exported.tar

docker image import schoolofdevops_vote_exported.tar schoolofdevops/vote:imported

docker image history schoolofdevops/vote:imported


```
