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
    curl \
    && rm -rf /var/lib/apt/lists/*

# Make python3.12 the default python3
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

# Install pip for Python 3.12
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12

# Install PyTorch with CUDA 12.4 support (compatible with CUDA 12.6 runtime)
RUN python3 -m pip install --no-cache-dir \
    torch torchaudio --index-url https://download.pytorch.org/whl/cu124

# Install demucs-inference from pinned commit (alpha software, pin for stability)
RUN python3 -m pip install --no-cache-dir \
    git+https://github.com/Ryan5453/demucs.git@8654fa473940d3c38255c4e493444d9a75da0be3

# Verify installation
RUN demucs --help

VOLUME /data/input
VOLUME /data/output
VOLUME /data/models

# Keep container running for docker exec
ENTRYPOINT ["tail", "-f", "/dev/null"]
