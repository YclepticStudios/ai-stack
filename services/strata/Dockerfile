# Note: Much of this dockerfile is from Strata's upstream example

# Build stage
FROM nvidia/cuda:13.0.0-devel-ubuntu24.04 AS build

ARG STRATA_REF=257727d58ff85a9aef6f314f9a95f75e4fc330d2
ARG CUDA_ARCHITECTURES=120
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        build-essential \
        ca-certificates \
        git \
        libgomp1 \
        python3 \
        python3-venv \
    && rm -rf /var/lib/apt/lists/*
RUN mkdir /opt/strata && cd /opt/strata \
    && git init \
    && git remote add origin https://github.com/sergqwer/strata-nvfp4 \
    && git fetch --depth 1 origin ${STRATA_REF} \
    && git checkout FETCH_HEAD
WORKDIR /opt/strata
RUN python3 -m venv .venv \
    && .venv/bin/pip install --no-cache-dir --upgrade pip \
    && .venv/bin/pip install --no-cache-dir -r requirements.txt

# docker build gets no GPU, so the card is passed instead of probed; "cpu" is
# the image encoder setup.py's NVFP4 path always builds
RUN .venv/bin/python -c "import os, setup; \
    a = [int(x) for x in os.environ['CUDA_ARCHITECTURES'].split(';')]; \
    gpu = {'arch': a[0], 'archs': a}; \
    setup.build_engine(gpu, 'cpu', True, setup.get_llama_cpp(), toolkit=13)"
RUN rm -rf build build-vision .git third_party

# Runtime stage
FROM nvidia/cuda:13.0.0-runtime-ubuntu24.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        ca-certificates \
        libgomp1 \
        python3 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /opt/strata /opt/strata
COPY strata.json /opt/strata/strata.json

ENV PYTHONUNBUFFERED=1
WORKDIR /opt/strata
EXPOSE 9931

# Serve profile; server.py is PID 1 so SIGTERM reaches the engine
CMD ["/opt/strata/.venv/bin/python", "/opt/strata/serve/server.py", \
     "--engine", "strata", \
     "--config", "/opt/strata/strata.json", \
     "--host", "0.0.0.0", \
     "--port", "9931"]
