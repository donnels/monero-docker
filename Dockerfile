FROM debian:bullseye-slim as monerobase
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /opt/app
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git build-essential cmake libuv1-dev \
        libmicrohttpd-dev \
        software-properties-common \
        aptitude
RUN git clone https://github.com/xmrig/xmrig-nvidia.git

FROM monerobase as monerobuildprep
# got to https://qa.debian.org/madison.php to query what packages are available in which versions for arm64
RUN apt-add-repository non-free \
    && apt-add-repository contrib \
    && apt-get update
RUN apt-get install -y --no-install-recommends \
       nvidia-cuda-dev nvidia-cuda-toolkit libssl-dev
RUN mkdir -p /opt/app/xmrig-nvidia/build
WORKDIR /opt/app/xmrig-nvidia/build

FROM monerobuildprep as monerbuild
RUN cmake .. -DCUDA_ARCH="20;30;50"
RUN make

FROM monerobuild
CMD ["/bin/bash"]