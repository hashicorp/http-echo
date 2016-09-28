FROM scratch
MAINTAINER Seth Vargo <seth@hashicorp.com> (@sethvargo)

ADD "./pkg/linux_amd64/http-echo" "/"
ENTRYPOINT ["/http-echo"]
