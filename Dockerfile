FROM debian
 
MAINTAINER weiliang <xzx.weiliang@gmail.com>
 
ENV FASTDFS_PATH=/opt/fdfs \
    FASTDFS_BASE_PATH=/opt/fdfs \
    PORT= \
    GROUP_NAME= \
    TRACKER_SERVER=
    
#install all the dependences
RUN apt install -y net-tools wget gcc g++
 
#create the dirs to store the files downloaded from internet
RUN mkdir -p ${FASTDFS_PATH} \
    && mkdir -p ${FASTDFS_PATH}/client \
    && mkdir -p ${FASTDFS_PATH}/files \
    && mkdir -p ${FASTDFS_PATH}/tracker \
    && mkdir -p ${FASTDFS_PATH}/nginx_mod
    
WORKDIR /work/tmp

# compile libfastcommon
RUN wget https://github.com/happyfish100/libfastcommon/archive/refs/tags/V1.0.66.tar.gz && \
    tar zxvf V1.0.66.tar.gz && \
    cd libfastcommon-1.0.66 && \
    ./make.sh && ./make.sh install

# compile libserverframe
RUN wget https://github.com/happyfish100/libserverframe/archive/refs/tags/V1.1.25.tar.gz && \
    tar zxvf V1.1.25.tar.gz && \
    cd libserverframe-1.1.25 && \
    ./make.sh && ./make.sh install
   
# compile fastdfs
RUN wget https://github.com/happyfish100/fastdfs/archive/refs/tags/V6.9.4.tar.gz && \
    tar zxvf V6.9.4.tar.gz && \
    cd fastdfs-6.9.4 && \
    ./make.sh && ./make.sh install

