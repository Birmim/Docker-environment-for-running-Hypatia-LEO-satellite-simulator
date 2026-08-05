# System base
FROM ubuntu:18.04 

# Prevents apt from hanging on interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Update packages and install basic tools, always answer yes to any question
RUN apt-get update && apt-get install -y \
        git \
        curl \
        wget \
        nano \
        unzip \
        screen \
        build-essential \
        software-properties-common
        # build-essential: needed to compile C++ (gcc, g++, make)
        # software-properties-common: enables us to add new repositories
        # unzip: needed by ns-3's build.sh to unpack the ns-3 source archive
        # screen: needed by exputilpy to manage background simulation runs

# Add new repository
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update &&  \
    apt-get install -y \
    python3.7          \
    python3.7-dev      \
    python3-pip
    # python3.7-dev: needed for Numpy and other libraries that compile C code

# Ubuntu 18.04 ships Python 3.6 by default; Hypatia needs 3.7+
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 1

# Some Hypatia scripts call "python" directly (not "python3") — map it too
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.7 1

# Ubuntu's apt pip3 is too old to understand modern build requirements (PEP 517/518),
# so we replace it with an up-to-date pip tied specifically to python3.7
RUN curl -sS https://bootstrap.pypa.io/pip/3.7/get-pip.py -o get-pip.py && \
    python3.7 get-pip.py

### Based on "hypatia_install_dependencies.sh"

# System dependencies
RUN apt-get install -y \
    libproj-dev        \
    proj-data          \
    proj-bin           \
    libgeos-dev        \
    openmpi-bin        \
    openmpi-common     \
    openmpi-doc        \
    libopenmpi-dev     \
    lcov               \
    gnuplot

# Python dependencies
RUN pip3 install numpy astropy ephem networkx sgp4 geopy matplotlib statsmodels

# Git libraries
RUN pip3 install git+https://github.com/snkas/exputilpy.git@v1.6
# Owner library, not on PyPI

# Shapely 2.0+ removed the "lgeos" interface that Cartopy 0.18.0 expects,
# and Ubuntu 18.04's GEOS (3.6.2) is too old for newer Cartopy versions anyway
RUN pip3 install "shapely<2.0"

# Pinned to 0.18.0: newer Cartopy versions require GEOS 3.7.2+,
# but Ubuntu 18.04's libgeos-dev only provides 3.6.2
RUN pip3 install cartopy==0.18.0

###

# Download Hypatia
WORKDIR /root
RUN git clone https://github.com/snkas/hypatia.git

# Download all the submodules
WORKDIR /root/hypatia
RUN git submodule update --init --recursive

# Compile ns-3
RUN bash hypatia_build.sh

# Start container
CMD ["/bin/bash"]
