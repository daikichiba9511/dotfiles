FROM ubuntu:20.04

# example
ENV LC_ALL="C.UTF-8" LESSCHARSET="utf-8"

WORKDIR /workspace/working

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
    g++ \
    unzip \
    &&curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    &&apt install -y nodejs


COPY ./ ./

RUN bash ./setup.sh
