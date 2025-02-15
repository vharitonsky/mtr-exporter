##
## -- runtime environment
##

FROM    golang:1.18.4-alpine3.16 AS build-env

#       https://github.com/docker-library/official-images#multiple-architectures
#       https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope
ARG     TARGETPLATFORM
ARG     TARGETOS
ARG     TARGETARCH

ARG     VERSION=latest

ADD     . /src/mtr-exporter
RUN     apk add -U --no-cache make git
RUN     make -C /src/mtr-exporter bin/mtr-exporter-$VERSION.$TARGETOS.$TARGETARCH

##
## -- runtime environment
##

FROM    alpine:3.16 AS rt-env

RUN     apk add -U --no-cache mtr
COPY    --from=build-env /src/mtr-exporter/bin/* /usr/bin/mtr-exporter

EXPOSE  8080
ENTRYPOINT ["/usr/bin/mtr-exporter"]
