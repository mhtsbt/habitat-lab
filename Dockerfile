# Base image
FROM nvidia/cudagl:10.1-devel-ubuntu16.04

# Setup basic packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    vim \
    ca-certificates \
    libjpeg-dev \
    libpng-dev \
    libglfw3-dev \
    libglm-dev \
    libx11-dev \
    libomp-dev \
    libegl1-mesa-dev \
    pkg-config \
    wget \
    zip \
    unzip &&\
    rm -rf /var/lib/apt/lists/*

# Install conda
RUN curl -L -o ~/miniconda.sh -O  https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh  &&\
    chmod +x ~/miniconda.sh &&\
    ~/miniconda.sh -b -p /opt/conda &&\
    rm ~/miniconda.sh &&\
    /opt/conda/bin/conda install numpy pyyaml scipy ipython mkl mkl-include &&\
    /opt/conda/bin/conda clean -ya
ENV PATH /opt/conda/bin:$PATH

# Install cmake
RUN wget https://github.com/Kitware/CMake/releases/download/v3.14.0/cmake-3.14.0-Linux-x86_64.sh
RUN mkdir /opt/cmake
RUN sh /cmake-3.14.0-Linux-x86_64.sh --prefix=/opt/cmake --skip-license
RUN ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake
RUN cmake --version

# Conda environment
RUN conda create -n habitat python=3.9 cmake=3.14.0

# Setup habitat-sim
RUN git clone --branch stable https://github.com/facebookresearch/habitat-sim.git
RUN /bin/bash -c ". activate habitat; cd habitat-sim; pip install -r requirements.txt; python setup.py install --headless --with-cuda"

# Install challenge specific habitat-lab
COPY ./habitat-lab/requirements.txt /habitat-lab/habitat-lab/requirements.txt
RUN /bin/bash -c ". activate habitat; cd /habitat-lab/habitat-lab; pip install -r requirements.txt"

RUN /bin/bash -c ". activate habitat; cd /habitat-lab/habitat-lab; pip install moviepy>=1.0.1 torch>=1.3.1 protobuf==3.20.1 tensorboard==2.8.0"

RUN rm -r -f /cmake-3.14.0-Linux-x86_64.sh

COPY ./README.md /habitat-lab/README.md
COPY ./habitat-lab/ /habitat-lab/habitat-lab
COPY ./habitat-baselines /habitat-lab/habitat-baselines

RUN /bin/bash -c ". activate habitat; cd /habitat-lab/habitat-lab; pip install -e ."

RUN /bin/bash -c ". activate habitat; cd /habitat-lab/habitat-baselines; pip install -e ."

# Silence habitat-sim logs
#ENV GLOG_minloglevel=2
#ENV MAGNUM_LOG="quiet"

WORKDIR /habitat-lab
