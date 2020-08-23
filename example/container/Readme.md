# Running a Polaris webserver in a Linux container

The following guide gets you a PowerShell Polaris webserver running in a Linux container on Azure kubernetes Services (AKS).
At the end of this guide we will have the following resources:

1. a PSHTML website
2. a Polaris docker container
3. an AKS cluster
4. a Polaris website running on AKS

## Creating the website

### Introduction

The website folder contains the Polaris website.
The website is fairly static and contains 3 pages.

- Home page
- A kubernetes pages
- A PowerShell page



To highlight the PowerShell language capabilities, the html is abstracted away using another PowerShell project named PSHTML.
[PSHTML](https://github.com/Stephanevg/PSHTML) is a [PowerSHell DSL (Domain Specific language)](https://en.wikipedia.org/wiki/Domain-specific_language) for HTML 5 maintained by [Stephane Van Gulick](https://github.com/Stephanevg).

More info About PowerShell DSL's can be found on the [PowerShell DSL RFC](https://github.com/PowerShell/PowerShell-RFC/blob/master/3-Experimental/RFC0017-Domain-Specific-Language-Specifications.md) and [Kevin Marquette has an excellent intro guide](https://kevinmarquette.github.io/2017-02-26-Powershell-DSL-intro-to-domain-specific-languages-part-1/).


### Run locally


## Dockerize the website

### Build


### Tag and Push

Once our container is build, we should tag it properly and push it to our container registry.
Tagging is a concept to add aliases to the ID of your image.
the aliases help in identifying your image version and link it to a certain repository.

More info about docker tags can be found [here](https://docs.docker.com/engine/reference/commandline/tag/)

an example would be:

``` PowerShell
docker tag 673430dw stijnc/polaris:0.1
```
The above command tags the image with ID '673430dw' for the docker hub repository 'stijnc' with name 'polaris' and version '0.1'



## Deploy and run on AKS

### Deploy your AKS cluster

### Deploy the dockerized website


## Up next

In the end we have a fairly simple PowerShell 'static' site up and running on AKS, but a lot can still be improved.
Below you can find some links to additional resources to enhance both the website and the AKS deployment.

### Polaris and PSHTML

Find below some additional examples on both Polaris and PSHTML.

- polaris
- Chen v dynamic reloads without javascript
- ...
- PSHTML examples
- Polaris and https

### Kubernetes
find below some additional resources on how to manage and deploy applications more securely on AKS
- Azure kubernetes service (AKS
- Setting up an Azure container registry
- securing your website with SSL