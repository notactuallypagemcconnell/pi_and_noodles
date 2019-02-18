FROM alpine:3.8

RUN set -xe; \
    addgroup -g 1000 -S lsd; \
    adduser -u 1000 -S -h /lsd -s /bin/sh -G lsd lsd;
RUN set -xe; \
    apk --update add --no-cache --virtual .runtime-deps \
        bash \
        ca-certificates \
        curl \
        ffmpeg \
        git \
        gmp-dev \
        jpeg \
        libressl \
        make \
        py3-pip \
        python3 \
        tar \
        tzdata \
        yaml \
        xz \
        zlib; \
    pip3 install --upgrade pip;

USER lsd

WORKDIR /lsd
