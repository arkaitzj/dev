FROM golang:1.18.2-alpine3.15 as golang-builder

RUN apk update \
    && apk add --virtual build-dependencies git \
    && apk add bash curl jq
RUN go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest


FROM alpine:3.15 as dev

ARG user=arkaitzj
ENV devuser $user

RUN apk add bind-tools curl tcpdump git make vim docker bash sudo
RUN echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel 

RUN addgroup -S $user && adduser -s /bin/bash -S $user -G $user -G docker -G wheel

RUN mkdir /workdir && chown -R $user.$user /workdir
RUN ln -s /workdir /home/$user/workdir

USER $user
WORKDIR /home/$user/
SHELL ["/bin/bash", "-c"]

ENV PATH="${PATH}:/root/usr/bin"
RUN mkdir -p usr/bin
RUN echo 'export PS1="'$devuser'/dev:\w\$ "' > ~/.bashrc

COPY --from=golang-builder /go/bin/grpcurl usr/bin/

RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --depth 1 --branch v0.10.2 && \
    echo '. $HOME/.asdf/asdf.sh' >> ~/.bashrc && \
    echo '. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc

COPY .gitconfig .gitconfig

USER root
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
