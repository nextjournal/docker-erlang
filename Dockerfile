FROM alpine:3.4
MAINTAINER Holger Amann <holger@nextjournal.com>

ARG ERLANG_VERSION=19.2.1
ARG TEST_SERVER_VERSION=3.1.1

LABEL name="erlang" version=$ERLANG_VERSION

ARG DISABLED_APPS='megaco wx debugger jinterface orber reltool observer gs et'
ARG ERLANG_DOWNLOAD_URL="https://github.com/erlang/otp/archive/OTP-${ERLANG_VERSION}.tar.gz"
ARG TEST_SERVER_URL="http://erlang.org/download/test_server/test_server-${TEST_SERVER_VERSION}.tar.gz"

RUN set -xe \
    && apk --update add --virtual build-dependencies curl ca-certificates build-base autoconf perl ncurses-dev openssl-dev unixodbc-dev tar ncurses openssl unixodbc \
    && curl -fSL -o otp-src.tar.gz "$ERLANG_DOWNLOAD_URL" \
    && curl -fSL -o test-server.tar.gz "$TEST_SERVER_URL" \
    && mkdir -p /usr/src/otp-src \
    && tar -xzf otp-src.tar.gz -C /usr/src/otp-src --strip-components=1 \
    && tar -xzf test-server.tar.gz -C /usr/src/otp-src \
    && rm otp-src.tar.gz \
    && rm test-server.tar.gz \
    && cd /usr/src/otp-src \
    && for lib in ${DISABLED_APPS} ; do touch lib/${lib}/SKIP ; done \
    && ./otp_build autoconf \
    && ./configure \
        --enable-smp-support \
        --enable-m64-build \
        --disable-native-libs \
        --enable-sctp \
        --enable-threads \
        --enable-kernel-poll \
        --disable-hipe \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && find /usr/local -name examples | xargs rm -rf \
    && apk del build-dependencies \
    && ls -d /usr/local/lib/erlang/lib/*/src | xargs rm -rf \
    && rm -rf \
      /opt \
      /var/cache/apk/* \
      /tmp/* \
      /usr/src
