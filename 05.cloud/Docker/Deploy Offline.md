## 一.前置准备

```shell
# 解压
tar -zxvf docker-20.10.9.tgz
# 拷贝文件至系统系统目录下
cp docker/* /usr/bin/
# 创建docker运行时数据文件
mkdir -p /data/docker/
# 关闭SELINUX
setenforce 0
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
```

## 二.注册服务

​	将Docker注册为操作系统service服务，在/etc/systemd/system目录下创建docker.service文件，并配置如下：

```shell
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target
[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd --data-root='/data/docker'
ExecReload=/bin/kill -s HUP $MAINPID
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
# Uncomment TasksMax if your systemd version supports it.
# Only systemd 226 and above support this version.
#TasksMax=infinity
TimeoutStartSec=0
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process
# restart the docker process if it exits prematurely
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s
 
[Install]
WantedBy=multi-user.target
```

​	 给定可执行权限：

```shell
chmod +x /etc/systemd/system/docker.service
```

## 三.启动服务

```shell
# 重载unit配置文件
systemctl daemon-reload
# 启动服务
systemctl start docker.service
# 设置开机自启
systemctl enable docker.service
```

## 四.验证服务

```shell
# 查看Docker状态为Running代表服务启动成功
systemctl status docker
# 查看Docker版本
docker -v
```

## 五.运行容器

```shell
> docker pull hello-world

> docker image ls

REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
hello-world         latest              feb5d9fea6a5        19 months ago       13.3kB

> docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

