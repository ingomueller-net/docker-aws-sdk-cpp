FROM ubuntu:bionic
MAINTAINER Ingo Müller <ingo.mueller@inf.ethz.ch>

# Basics
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        build-essential \
        cmake \
        git \
        libcurl4-openssl-dev \
        libpulse-dev \
        libssl-dev \
        uuid-dev \
        wget \
        xz-utils \
        zlib1g-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Clang+LLVM
RUN mkdir /opt/clang+llvm-7.0.1/ && \
    cd /opt/clang+llvm-7.0.1/ && \
    wget http://releases.llvm.org/7.0.1/clang+llvm-7.0.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz -O - \
         | tar -x -I xz --strip-components=1 && \
    for file in bin/*; \
    do \
        ln -s $PWD/$file /usr/bin/$(basename $file)-7.0; \
    done && \
    cp /opt/clang+llvm-7.0.1/lib/libomp.so /opt/clang+llvm-7.0.1/lib/libomp.so.5

# Build the SDK
RUN mkdir -p /tmp/aws-sdk-cpp && \
    cd /tmp/aws-sdk-cpp && \
    wget https://github.com/aws/aws-sdk-cpp/archive/1.7.138.tar.gz -O - \
        | tar -xz --strip-components=1 && \
    mkdir -p /tmp/aws-sdk-cpp/build && \
    cd /tmp/aws-sdk-cpp/build && \
    CXX=clang++-7.0 CC=clang-7.0 \
        cmake \
            -DBUILD_ONLY="dynamodb;lambda;s3;sqs" \
            -DCMAKE_BUILD_TYPE=Debug \
            -DCPP_STANDARD=17 \
            -DENABLE_TESTING=OFF \
            -DCUSTOM_MEMORY_MANAGEMENT=OFF \
            -DCMAKE_INSTALL_PREFIX=/opt/aws-sdk-cpp-1.7/ \
            -DAWS_DEPS_INSTALL_DIR:STRING=/opt/aws-sdk-cpp-1.7/ \
            .. && \
    make install && \
    rm -rf /tmp/aws-sdk-cpp
