FROM golang:alpine as gosrc

FROM jenkins/jnlp-slave:alpine

USER root

RUN apk --update add sudo git curl make gcc musl-dev g++
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing cloudfoundry-cli
RUN rm -rf /var/cache/apk/* 

USER jenkins

ARG GO_BASE_PATH=/usr/local/go

COPY --from=gosrc ${GO_BASE_PATH} ${GO_BASE_PATH}
COPY --from=gosrc /go ${HOME}/go

ENV GOPATH ${HOME}/go
ENV PATH "${GOPATH}/bin:${GO_BASE_PATH}/bin:${PATH}"
ENV CGO_ENABLED 0

# Install some test helpers

RUN go get gotest.tools/gotestsum
RUN go get github.com/tebeka/go2xunit
RUN go get github.com/axw/gocov/gocov
RUN go get github.com/AlekSi/gocov-xml
RUN go get github.com/matm/gocov-html

# Test binaries

RUN make --version

RUN curl --version

RUN cf version

RUN go version

RUN gotestsum --version
RUN go2xunit -version
RUN which gocov
RUN which gocov-xml
RUN which gocov-html

WORKDIR ${HOME}

LABEL maintainer="thomas.liebeskind@gmail.com"