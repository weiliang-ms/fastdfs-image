FROM debian
 
MAINTAINER weiliang <xzx.weiliang@gmail.com>
 
ENV FASTDFS_PATH=/opt/fdfs \
    FASTDFS_BASE_PATH=/opt/fdfs \
    PORT= \
    GROUP_NAME= \
    TRACKER_SERVER=
    
#install all the dependences
RUN apt update -y && \
    apt install -y net-tools wget gcc g++ make libpcre3 libpcre3-dev zlib1g-dev
 
#create the dirs to store the files downloaded from internet
RUN mkdir -p ${FASTDFS_PATH} \
    && mkdir -p ${FASTDFS_PATH}/client \
    && mkdir -p ${FASTDFS_PATH}/files \
    && mkdir -p ${FASTDFS_PATH}/logs \
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
    
RUN wget http://nginx.org/download/nginx-1.22.1.tar.gz \
    && wget https://github.com/happyfish100/fastdfs-nginx-module/archive/refs/tags/V1.23.tar.gz \
    && tar zxvf V1.23.tar.gz \
    && tar zxvf nginx-1.22.1.tar.gz \
    && cd nginx-1.22.1 \
    && ./configure --prefix=/usr/local/nginx --add-module=../fastdfs-nginx-module-1.23/src/ \
    && make \
    && make install
    
COPY nginx.conf /usr/local/nginx/conf/nginx.conf

RUN sed -i 's#base_path = /home/yuqing/fastdfs#base_path=/opt/fdfs/client#g' /etc/fdfs/client.conf && \
sed -i "s#tracker_server=192.168.0.197:22122#tracker_server=0.0.0.0:22122#g" /etc/fdfs/client.conf && \
sed -i 's#base_path = /home/yuqing/fastdfs#base_path=/opt/fdfs/tracker#g' /etc/fdfs/tracker.conf && \
set -i "s#thread_stack_size = 64KB#thread_stack_size = 128KB#g" /etc/fdfs/tracker.conf && \
sed -i 's#base_path = /home/yuqing/fastdfs#base_path=/opt/fdfs/storage#g' /etc/fdfs/storage.conf  && \
sed -i 's#store_path0 = /home/yuqing/fastdfs#store_path0=/opt/fdfs/storage#g' /etc/fdfs/storage.conf && \
sed -i "s#thread_stack_size=512KB#thread_stack_size=1024KB#g" /etc/fdfs/storage.conf

RUN rm -rf /work/tmp

# 默认nginx端口
ENV IP="localhost"
# 默认fastdfs端口
EXPOSE 22122 23000 8080 8888 80

VOLUME ["$FASTDFS_BASE_PATH", "/etc/fdfs"]

COPY start.sh /usr/bin/

#make the start.sh executable
RUN chmod 777 /usr/bin/start.sh

ENTRYPOINT ["/usr/bin/start.sh"]
CMD ["tracker"]


