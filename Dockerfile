FROM golang:1.18.2-alpine3.15 as golang-builder

RUN apk update \
    && apk add --virtual build-dependencies git \
    && apk add bash curl jq
RUN go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest


FROM alpine:3.15 as dev

ARG user=arkaitzj
ENV devuser $user

RUN apk add bind-tools curl tcpdump git make vim docker bash

RUN addgroup -S $user && adduser -s /bin/bash -S $user -G $user -G docker


RUN mkdir /workdir && chown -R $user.$user /workdir
RUN ln -s /workdir /home/$user/workdir

USER $user

ENV PATH="${PATH}:/root/usr/bin"
RUN mkdir -p usr/bin

COPY --from=golang-builder /go/bin/grpcurl usr/bin/

USER root
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
