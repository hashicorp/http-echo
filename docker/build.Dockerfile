FROM scratch
MAINTAINER Seth Vargo <seth@hashicorp.com> (@sethvargo)

EXPOSE 5678
ADD "./pkg/linux_amd64/http-echo" "/"
ENTRYPOINT ["/http-echo"]
