FROM node:10.15.3-alpine as builder

ENV NODE_ENV=production \
    VERDACCIO_BUILD_REGISTRY=http://192.168.1.100:4873

RUN apk --no-cache add \
        openssl \
        ca-certificates \
        wget \
    && \
    apk --no-cache add \
        g++ \
        gcc \
        libgcc \
        libstdc++ \
        linux-headers \
        make \
        python \
    && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.25-r0/glibc-2.25-r0.apk && \
    apk add glibc-2.25-r0.apk

WORKDIR /opt/verdaccio-build

COPY package.json yarn.lock ./

RUN set -ex && \
    npm config set registry $VERDACCIO_BUILD_REGISTRY && \
    npm config set puppeteer_skip_chromium_download true && \
    npm install --production=false --no-lockfile --verbose && \
    yarn cache clean

COPY . .

RUN yarn code:docker-build




FROM node:10.15.3-alpine
LABEL maintainer="https://github.com/verdaccio/verdaccio"

ENV NODE_ENV=production \
    VERDACCIO_BUILD_REGISTRY=http://192.168.1.100:4873
ENV VERDACCIO_APPDIR=/opt/verdaccio \
    VERDACCIO_USER_NAME=node \
    VERDACCIO_USER_UID=1000 \
    VERDACCIO_PORT=4873 \
    VERDACCIO_PROTOCOL=http
ENV PATH=$VERDACCIO_APPDIR/docker-bin:$PATH \
    HOME=$VERDACCIO_APPDIR

WORKDIR $VERDACCIO_APPDIR

RUN adduser \
	-u $VERDACCIO_USER_UID \
        -SDh $VERDACCIO_APPDIR \
        -g "$VERDACCIO_USER_NAME user" \
        -s /sbin/nologin \
        $VERDACCIO_USER_NAME \
        || echo OK \
    && \
    apk --no-cache add openssl dumb-init && \
    mkdir -p /verdaccio/storage /verdaccio/plugins /verdaccio/conf

COPY package.json yarn.lock ./

RUN set -ex && \
    npm config set registry $VERDACCIO_BUILD_REGISTRY && \
    npm config set puppeteer_skip_chromium_download true && \
    yarn install --production=true --no-lockfile && \
    yarn cache clean

ADD conf/docker.yaml /verdaccio/conf/config.yaml

COPY --chown=$VERDACCIO_USER_NAME --from=builder /opt/verdaccio-build .

RUN chmod -R +x ./bin ./docker-bin && \
    chown -R $VERDACCIO_USER_UID:root /verdaccio/storage && \
    chmod -R g=u /verdaccio/storage /etc/passwd

USER $VERDACCIO_USER_UID

EXPOSE $VERDACCIO_PORT

VOLUME /verdaccio/storage

ENTRYPOINT ["uid_entrypoint"]

RUN ls -la .

CMD $VERDACCIO_APPDIR/bin/verdaccio \
        --config /verdaccio/conf/config.yaml \
        --listen $VERDACCIO_PROTOCOL://0.0.0.0:$VERDACCIO_PORT

