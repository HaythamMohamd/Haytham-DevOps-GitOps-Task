# base image
FROM postman/newman:5.3-alpine
# set environment variable NODE_PATH to value /usr/local/lib/node_modules
ENV NODE_PATH=/usr/local/lib/node_modules
# change dir to /etc/newman
WORKDIR /etc/newman
# update and upgrade packaged to latest
# install curl zip iputils for ping 
# install newman-reporter-csvallinone
# remove the cache
RUN apk update && \
    apk upgrade && \
    apk add --no-cache curl zip iputils && \
    npm install -g newman-reporter-csvallinone && \
    rm -rf /var/cache/apk/*
# set the dns     
RUN printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf
# enttrypoint
ENTRYPOINT ["newman"]
