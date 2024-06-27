http-echo
=========
HTTP Echo is a small go web server that serves the contents it was started with
as an HTML page.

The default port is 5678, but this is configurable via the `-listen` flag:

```
http-echo -listen=:8080 -text="hello world"
```

Then visit http://localhost:8080/ in your browser.


# Building an Image

First you will need to build a binary of the application. You can do that by running the following command

`OS=linux ARCH=amd64 make bin`

You can replace the `OS` and the `ARCH` variables according to the binary you want to build.

After that, build your docker image by running: 

`docker buildx build --platform linux/<arch> -f <location of docker file> .`

Dont forget to change the <arch> and <location of docker file> to the appropriate values. 

Then tag and push your image by running the following values

`docker tag <image ID> findhotelamsterdam/icp-http-echo:<tag>`

`docker push findhotelamsterdam/icp-http-echo:<image tag>` 