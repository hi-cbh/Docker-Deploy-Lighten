#!/bin/bash

# 镜像不存在时创建镜像
if ! docker images | grep lighten; then
    echo 'The docker image does not exist,'
    echo 'Now creating image <lighten>...'
    docker build -t lighten $(pwd)
fi

# 镜像存在时，检查容器是否存在
if docker ps -a | grep -i lighten; then
    # 容器存在时则删除容器
    echo 'The docker container <lighten> already exist, deleting it...'
    docker rm -f webapp-lighten
    # 启动容器
    docker run -itd \
               --link mysql:mysql \
               -v /root/git_repo/Lighten/:/home/docker/code/Lighten \
               --name webapp-lighten \
               -p 8000:80 \
           lighten
else
    # 第一次创建容器时需要更新数据库
    docker run -itd \
               --link mysql:mysql \
               -v /root/git_repo/Lighten/:/home/docker/code/Lighten \
               --name webapp-lighten \
               -p 8000:80 \
           lighten \
           sh -c 'python /home/docker/code/Lighten/manage.py migrate && supervisord -n'
fi
