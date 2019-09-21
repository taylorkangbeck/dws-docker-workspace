# ML Project Base image w/ cuda support

FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu16.04

# Install basic tools
RUN apt-get update && apt-get install -y --no-install-recommends \
         build-essential \
         cmake \
         git \
         curl \
         ca-certificates \
         wget \
         vim \
         less \
    && rm -rf /var/lib/apt/lists/*

# Install conda
RUN curl -o /tmp/miniconda.sh -O  https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh  && \
     chmod +x /tmp/miniconda.sh && \
     /tmp/miniconda.sh -b -p /opt/conda && \
     rm /tmp/miniconda.sh && \
     /opt/conda/bin/conda clean -ya
ENV PATH /opt/conda/bin:$PATH

# Conda env setup
ADD environment.yml /tmp/environment.yml
RUN conda env create -f /tmp/environment.yml
# Pull the environment name out of the environment.yml
RUN echo "source activate $(head -1 /tmp/environment.yml | cut -d' ' -f2)" >> ~/.bashrc
ENV PATH /opt/conda/envs/$(head -1 /tmp/environment.yml | cut -d' ' -f2)/bin:$PATH
