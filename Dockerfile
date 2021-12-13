FROM debian:bullseye-slim as builder
LABEL maintainer="alphabet5"

ENV DEBIAN_FRONTEND=noninteractive

RUN \
 apt-get update && \
 apt-get install -y build-essential libffi-dev perl zlib1g-dev wget
RUN \
    wget --content-disposition https://dl.duosecurity.com/duoauthproxy-latest-src.tgz && \
    tar xzf duoauthproxy-*.tgz && \
    cd ./duoauthproxy-*-src/ && \
    make && \
    cp -r ./duoauthproxy-build /duoauthproxy-build

FROM debian:bullseye-slim
WORKDIR /
COPY --from=builder /duoauthproxy-build /duoauthproxy-build
COPY entrypoint.sh /entrypoint.sh

RUN /duoauthproxy-build/install --install-dir=/opt/duoauthproxy --service-user=duo_authproxy_svc --log-group=duo_authproxy_grp --create-init-script=no --silent
RUN chmod +x /entrypoint.sh

USER duo_authproxy_svc
EXPOSE 1812/udp
ENTRYPOINT ["/entrypoint.sh"]
