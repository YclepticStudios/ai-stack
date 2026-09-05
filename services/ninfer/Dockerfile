# Note: Much of this dockerfile is from NInfer's upstream example

# Build stage
FROM nvidia/cuda:13.1.2-devel-ubuntu24.04 AS build

ARG NINFER_REF=ad0f3d384b5cbcec4a48a3951c287b4e9831443e
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        git \
        cmake \
        libavcodec-dev \
        libavformat-dev \
        libavutil-dev \
        libcurl4-openssl-dev \
        libswscale-dev \
        ninja-build \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*
RUN mkdir /src && cd /src \
    && git init \
    && git remote add origin https://github.com/Neroued/ninfer \
    && git fetch --depth 1 origin ${NINFER_REF} \
    && git checkout FETCH_HEAD
WORKDIR /src
RUN cmake -S . -B /build -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DNINFER_BUILD_APPS=ON \
        -DBUILD_TESTING=OFF \
        -DNINFER_BUILD_BENCHMARKS=OFF \
    && cmake --build /build --parallel --target ninfer ninfer-serve

# Runtime stage
FROM nvidia/cuda:13.1.2-runtime-ubuntu24.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        ca-certificates \
        libavcodec60 \
        libavformat60 \
        libavutil58 \
        libcurl4t64 \
        libswscale7 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /build/apps/ninfer /usr/local/bin/ninfer
COPY --from=build /build/apps/ninfer-serve /usr/local/bin/ninfer-serve

WORKDIR /workspace
EXPOSE 9931
STOPSIGNAL SIGTERM

# Serve profile
CMD ["ninfer-serve", \
     "/models/qwen3_8_27b_nvfp4.ninfer", \
     "--host", "0.0.0.0", \
     "--port", "9931", \
     "--max-context", "240000", \
     "--kv-capacity", "240000", \
     "--max-concurrency", "2", \
     "--kv-dtype", "fp8", \
     "--device-state-slots", "2", \
     "--host-state-slots", "8", \
     "--host-kv-mib", "8192", \
     "--spec", "mtp", \
     "--draft-tokens", "3", \
     "--lm-head-draft", \
     "--preserve-thinking"]
