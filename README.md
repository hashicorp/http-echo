http-echo
=========
HTTP Echo is a small go web server that serves the contents it was started with
as an HTML page.

The default port is 5678, but this is configurable via the `-listen` flag:

```
http-echo -listen=:8080 -text="hello world"
```

Then visit http://localhost:8080/ in your browser.

Step by Step Guid For Setting up A CI/CD Pipeline That Deploys <br /> 
This Application To A Kubernetes Cluster <br /> 
Using Helm
==========
## Desciption
This documentation covers the steps for deploying this application to a kubernetes cluster using helm chart, before walking down the steps I will go over listing out the DevOps tools used in carrying out this project.

Prequesite
==========

- AWS-EC2 intance
- Docker
- Minikube
- Git
- Helm
- Go
- Linux
- Git
- Docker Desktop

Lets devlve straight into the steps took to accomplishing this project. note that we're going to run alot of command to accomplish this task as such I am strickly just going to be walking us through those steps of deploying our application a kubernetes cluster using helm, additionally I would be using Github Action Workflow setting up my pipelines.

## 1. Step 

Clone the project repository to your pc using the command & cd into it open it with your fovorite code editor, I used vscode in my case.

```
git clone https://github.com/Awodi-Emmanuel/http-echo.git
cd http-echo
```

## 2. Step 

This step now is to test our Go application locally to see if it's working before we can go ahead and dockerise it, make sure that you have your Go setup in place and run the command provided with documentation to test the application.

follow link to see how to installl Go on your OS https://go.dev/doc/tutorial/getting-started#install

The default port is 5678, but this is configurable via the `-listen` flag:

```
http-echo -listen=:8080 -text="hello world"
```

Then visit http://localhost:8080/ in your browser.

## 3. Step
Time to dockerise our Go application, I like to write my docker file, create a file named `Dockerfile` in your http-echo app root directory. Make sure you have your Docker Destop up and running in my case I have wsl enabled from my docker destop to enable me use my wsl terminal. 

Follow link to install Docker Destop on you PC https://docs.docker.com/desktop/install/windows-install/

Then build docker image by running

```
docker build -t img-http-echo .
```
I am not going to delve into explaining much on building go dockers image follow link for context https://docs.docker.com/language/golang/build-images/

## 4. Step

Lets run our docker container from our project root directory like as we did for our image mount our port to the container entry port like this:

```
docker run -d -p 8080:5678 --name img-http-echo htttp-echo-container
```

https://github.com/Awodi-Emmanuel/http-echo/blob/22009921b20049993d09b01434bef068aa46447f/Dockerfile