# syntax=docker/dockerfile:1
# Base image with CUDA 12.6 support (also works on CPU)
FROM nvidia/cuda:12.6.2-base-ubuntu22.04

USER root
ENV TORCH_HOME=/data/models
ENV OMP_NUM_THREADS=1
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install Python 3.12 and required tools
RUN apt update && apt install -y --no-install-recommends \
    software-properties-common \
    && add-apt-repository -y ppa:deadsnakes/ppa \
    && apt update && apt install -y --no-install-recommends \
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    python3-pip \
    ffmpeg \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Make python3.12 the default python3
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

# Install pip for Python 3.12
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12

# Install PyTorch with CUDA 12.4 support (compatible with CUDA 12.6 runtime)
# Cache persists in /var/lib/docker/buildkit/ between builds
RUN --mount=type=cache,target=/root/.cache/pip \
    python3 -m pip install --resume-retries 999999 \
    torch torchaudio --index-url https://download.pytorch.org/whl/cu124

# Install demucs-inference (clone manually to fix readme.md case issue)
RUN --mount=type=cache,target=/root/.cache/pip \
    git clone --depth 1 https://github.com/Ryan5453/demucs.git /tmp/demucs \
    && cd /tmp/demucs \
    && mv readme.md README.md \
    && python3 -m pip install --resume-retries 999999 . \
    && rm -rf /tmp/demucs

# Verify installation
RUN demucs --help

VOLUME /data/input
VOLUME /data/output
VOLUME /data/models

# Output init message for dockerutil (delay ensures attach is connected first)
# Then keep container running for docker exec
ENTRYPOINT ["/bin/sh", "-c", "sleep 0.75 && echo 'langkit-demucs' && exec tail -f /dev/null"]
