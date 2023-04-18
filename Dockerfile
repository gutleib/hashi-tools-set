FROM golang:1.20.3-bullseye AS builder

LABEL maintainer="Gutleib <gutleib@gmail.com>"

ARG NOMAD_VERSION=v1.5.3
ARG CONSUL_VERSION=v1.15.2
ARG VAULT_VERSION=v1.13.1
ARG NOMAD_PACK_VERSION=nightly
ARG TERRAFORM_VERSION=v1.4.5
ARG WAYPOINT_VERSION=v0.11.0
#ARG BOUNDARY_VERSION=v0.12.2

WORKDIR /build
RUN apt update && apt install git curl make

RUN git clone https://github.com/hashicorp/nomad && cd nomad && git checkout ${NOMAD_VERSION}
RUN git clone https://github.com/hashicorp/consul  && cd consul && git checkout ${CONSUL_VERSION}
RUN git clone https://github.com/hashicorp/vault && cd vault && git checkout ${VAULT_VERSION}
RUN git clone https://github.com/hashicorp/nomad-pack && cd nomad-pack && git checkout ${NOMAD_PACK_VERSION}
RUN git clone https://github.com/hashicorp/terraform && cd terraform && git checkout ${TERRAFORM_VERSION}
RUN git clone https://github.com/hashicorp/waypoint && cd waypoint && git checkout ${WAYPOINT_VERSION}
#RUN git clone https://github.com/hashicorp/boundary && cd boundary && git checkout ${BOUNDARY_VERSION}

RUN mv nomad nomad_src && cd nomad_src && make bootstrap && make dev && cp bin/nomad .. && cd .. && rm -rf nomad_src
RUN mv consul consul_src && cd consul_src && make dev && cp bin/consul .. && cd .. && rm -rf consul_src
RUN mv vault vault_src && cd vault_src && make bootstrap && make dev && cp bin/vault .. && cd .. && rm -rf vault_src
RUN mv nomad-pack nomad-pack_src && cd nomad-pack_src && make bootstrap && make dev && cp bin/nomad-pack .. && cd .. && rm -rf nomad-pack_src
RUN mv terraform terraform_src && cd terraform_src && go install && cp $GOPATH/bin/terraform .. && cd .. && rm -rf terraform_src
RUN mv waypoint waypoint_src && cd waypoint_src && make bin && cp waypoint .. && cd .. && rm -rf waypoint_src
#RUN mv boundary boundary_src && cd boundary_src && make tools && apt update && apt install -y nodejs yarn && make cli && make build && cp bin/boundary .. && cd .. && rm -rf boundary_src


FROM ubuntu:jammy
LABEL maintainer="Gutleib <gutleib@gmail.com>"
COPY --from=builder /build/* /usr/local/sbin/
RUN adduser --disabled-password --gecos "" hashiuser
USER hashiuser
WORKDIR /home/hashiuser/


