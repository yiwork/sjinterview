FROM webhippie/golang:latest

RUN apk update && \
    apk add wget git && \
    mkdir gocode && \
    useradd -u 1000 appuser

WORKDIR gocode
USER appuser
COPY gocode/ .
RUN go build 
RUN cp -R ./go_binary /usr/bin/ && \
    chmod o+x /usr/bin/go_binary

CMD ["/usr/bin/go_binary"]
