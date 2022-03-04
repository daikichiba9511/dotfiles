FROM ubuntu:20.04

# example
ENV LC_ALL="C.UTF-8" LESSCHARSET="utf-8"

WORKDIR /workspace

RUN apt update && apt upgrade -y \
    && DEBIAN_FRONTEND=nointeractivetzdata \
    TZ=Asia/Tokyo \
    apt install -y \
    sudo \
    git \
    make \
    cmake \
    curl \
    wget \
    ninja-build \
    gettext \
    libtool \
    libtool-bin \
    autoconf \
    automake \
    g++ \
    pkg-config \
    doxygen \
    unzip \
    &&curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    &&apt install -y nodejs


COPY ./ ./

RUN sh ./scripts/setup.sh y python
