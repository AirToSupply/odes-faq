## 前置准备

### 1.修改hostname

```shell
hostnamectl set-hostname mdw
```

### 2.关闭SELinux

查看状态：

```shell
sestatus
```

如果不是SELinuxstatus: disabled，则需要手动关闭。

```shell
vim /etc/selinux/config
SELINUX=disabled
```

### 3.关闭防火墙

```shell
systemctl stop firewalld
systemctl disable firewalld
systemctl status firewalld
```

### 4.添加hosts解析

```shell
172.16.2.123 2-123
172.16.2.124 2-124
```

### 5.配置免密

#### 使用root用户运行，四个回车OK。

```shell
ssh-keygen -t rsa
```

将本机的公钥复制到远程机器的authorized_keys文件中。

```shell
ssh-copy-id -i ~/.ssh/id_rsa.pub <remote-host>
```

登录到远程机器不用输入密码，第一次需要输入密码：

```shell
ssh <remote-host>
```

### 6.修改内核配置参数

```shell
vim /etc/sysctl.conf
```

配置如下：

```shell
# 执行getconf _PHYS_PAGES获取系统的_PHYS_PAGES
# 配置为：_PHYS_PAGES / 2
kernel.shmall = 8224922
# 执行getconf PAGE_SIZE获取系统的PAGE_SIZE
# 配置为：kernel.shmall * PAGE_SIZE
kernel.shmmax = 33689280512
kernel.shmmni = 4096
vm.overcommit_memory = 2 
vm.overcommit_ratio = 95

net.ipv4.ip_local_port_range = 10000 65535
kernel.sem = 500 2048000 200 4096
kernel.sysrq = 1
kernel.core_uses_pid = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.msgmni = 2048
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.tcp_max_syn_backlog = 4096
net.ipv4.conf.all.arp_filter = 1
net.core.netdev_max_backlog = 10000
net.core.rmem_max = 2097152
net.core.wmem_max = 2097152
vm.swappiness = 10
vm.zone_reclaim_mode = 0
vm.dirty_expire_centisecs = 500
vm.dirty_writeback_centisecs = 100
```

【注意】
对于内存大于64G的机器，增加下面四个配置：
```shell
vm.dirty_background_ratio = 0 
vm.dirty_ratio = 0
vm.dirty_background_bytes = 1610612736
vm.dirty_bytes = 4294967296
```

对于内存小于64G的机器，增加下面两个配置：
```shell
vm.dirty_background_ratio = 3
vm.dirty_ratio = 10
```

```shell
awk 'BEGIN {OFMT = "%.0f";} /MemTotal/ {print "vm.min_free_kbytes =", $2 * .03;}' /proc/meminfo >> /etc/sysctl.conf
```

【注意】该命令谨慎执行，如果出现无法分配内存，则执行如何命令：

```shell
echo 0 > /proc/sys/vm/overcommit_memory
```

使配置生效

```shell
sysctl -p
```

### 7.配置资源限制参数

```shell
vim  /etc/security/limits.conf

* soft nofile 524288
* hard nofile 524288
* soft nproc 131072
* hard nproc 131072
```

### 8.磁盘I/O设置

查看磁盘信息：

```shell
fdisk -l
```

针对每一块磁盘，执行：

```shell
/sbin/blockdev --setra 16384 /dev/磁盘名
```

由于每次重启都需要重新执行上述命令，所以可以将上面的命令添加到/etc/rc.d/rc.local文件中每次开机自动执行添加后赋予一下权限：

```shell
chmod +x /etc/rc.d/rc.local
```

执行下面两条命令以修改磁盘IO调度设置和禁用THP提升性能：

```shell
grubby --update-kernel=ALL --args="elevator=deadline"
grubby --update-kernel=ALL --args="transparent_hugepage=never"
```

执行完成后，重启一下系统以生效！

### 9.IPC Object Removal

```shell
vim /etc/systemd/logind.conf

RemoveIPC=no
```

修改完成后重启logind生效：

```shell
systemctl restart systemd-logind 
```

### 10.SSH连接阈值

```shell
vim /etc/ssh/sshd_config

Max Startups 10:30:200
MaxSessions 200
```

修改完成后重启sshd生效：

```shell
service sshd restart
```

### 11.同步时钟

```shell
yum -y install ntp
```

```shell
vim /etc/ntp.conf

...
#server 0.centos.pool.ntp.org iburst
#server 1.centos.pool.ntp.org iburst
#server 2.centos.pool.ntp.org iburst
#server 3.centos.pool.ntp.org iburst
server 172.16.2.123
...
```
【注意】 这里没有指向公网的时间服务，而且统一指向内网服务器

```shell
systemctl status ntpd
systemctl start ntpd
systemctl enable ntpd
```

### 12.创建用户和用户组

GP每一台都要配置：

```shell
groupadd -r -g 420 gpadmin
useradd -r -u  420 -g gpadmin -m -s /bin/bash gpadmin
echo gpadmin | passwd  gpadmin --stdin
```

输入密码，生成gpadmin的ssh密钥

```shell
su gpadmin
ssh-keygen -t rsa -b 4096
```

一路回车即可，为gpadmin用户授予sudo访问权限，执行如下命令：

```shell
visudo

%wheel        ALL=(ALL)       NOPASSWD: ALL
```

分配gpadmin到此组：

```shell
usermod -aG wheel gpadmin
```


## GP安装

### 部署规划

2-123 mdw   sgement

2-124 smdw  sgement

### 下载链接

下载地址：https://network.pivotal.io/products/vmware-tanzu-greenplum#/releases/743424/file_groups/2801

这里下载的是：greenplum-db-6.11.1-rhel7-x86_64.rpm

### 安装 (分别在所有节点安装)

sudo yum install greenplum-db-6.11.1-rhel7-x86_64.rpm

sudo chown -R gpadmin:gpadmin /usr/local/greenplum*

su - gpadmin

#### 每次节点配置免密
ssh-keygen -t rsa
ssh-copy-id iZey900nxkex9pjisu1xvrZ
ssh iZey900nxkex9pjisu1xvrZ

#### 主节点上应用环境变量
source /usr/local/greenplum-db/greenplum_path.sh

#### 主节点上创建hostlist、standby_seg_hosts、seg_only

mkdir ~/conf

hostlist中填写所有节点的主机别名：
```
2-123
2-124
```

standby_seg_hosts中填写stand by节点和所有Segment的主机别名
```
2-124
```

seg_only中只填写所有Segment的主机别名
```
2-123
2-124
```

#### 使用gpssh-exkeys打通所有服务器

主节点上执行：gpssh-exkeys -f ~/conf/hostlist
这样做的目的是：后续就可以通过gpssh命令在主机上同时远程操控segment机器了


#### 确认安装

主节点上通过gpadmin执行

```shell
gpssh -f ~/conf/hostlist -e 'ls -l /usr/local/greenplum-db'
```

如果上面步骤都执行正确，此时能够正确登录到各个节点上，并看到安装好的数据库目录。

#### 创建数据存储区

【step-1】在master机器上创建数据存储区

Master不存储user data，仅有system catalog tables和system metadata

在主节点上通过root用户进行如下操作：

```shell
sudo mkdir -p /data/gp/master
sudo chown -R gpadmin:gpadmin /data/gp/master
```
----------------------------------------------------------
【step-2】在stand by机器上创建数据存储区

在主节点上使用gpadmin用户执行如下命令：

```shell
source /usr/local/greenplum-db/greenplum_path.sh 
gpssh -h bigdata04 -e 'sudo mkdir -p /data/gp/master'
gpssh -h bigdata04 -e 'sudo chown gpadmin:gpadmin /data/gp/master'
```

【step-3】)在segment机器上创建数据存储区

在主节点上使用gpadmin用户执行：

```shell
source /usr/local/greenplum-db/greenplum_path.sh 
gpssh -f ~/conf/seg_only -e 'sudo mkdir -p /data/gp/primary'
gpssh -f ~/conf/seg_only -e 'sudo mkdir -p /data/gp/mirror'
gpssh -f ~/conf/seg_only -e 'sudo chown -R gpadmin:gpadmin /data/gp/primary'
gpssh -f ~/conf/seg_only -e 'sudo chown -R gpadmin:gpadmin /data/gp/mirror'
```

【注意】针对一台机器上多segment的部署方式，根据每台机器的segment数量，创建对应的存储目录：
```shell
gpssh -f ~/conf/seg_only -e 'sudo mkdir -p /app/data1/pg/primary; mkdir -p /app/data1/pg/mirror'
gpssh -f ~/conf/seg_only -e 'sudo mkdir -p /app/data2/pg/primary; mkdir -p /app/data2/pg/mirror'
gpssh -f ~/conf/seg_only -e 'sudo chown -R gpadmin:gpadmin /app/data/pg/primary'
gpssh -f ~/conf/seg_only -e 'sudo chown -R gpadmin:gpadmin /app/data/pg/mirror'
gpssh -f ~/conf/seg_only -e 'sudo chown -R gpadmin:gpadmin /app/data1/pg/primary'
gpssh -f ~/conf/seg_only -e 'sudo chown -R gpadmin:gpadmin /app/data1/pg/mirror'
gpssh -f ~/conf/seg_only -e 'sudo chown -R gpadmin:gpadmin /app/data2/pg/primary'
gpssh -f ~/conf/seg_only -e 'sudo chown -R gpadmin:gpadmin /app/data2/pg/mirror'
```

#### 初始化数据库

【step-1】创建初始化配置文件

在主节点上使用gpadmin执行如下命令：

```shell
mkdir ~/gpconfigs
vim ~/gpconfigs/gpinitsystem_config
```

```shell
#数据库代号
ARRAY_NAME="Greenplum Data Platform"
 
#segment前缀
SEG_PREFIX=gpseg
 
#primary segment 起始的端口号
PORT_BASE=40000
 
#指定primary segment的数据目录
declare -a DATA_DIRECTORY=(/data/gp/primary)
#如果每台机器上有多个segment
#declare -a DATA_DIRECTORY=(/data/primary /data1/primary /data2/primary ...)
 
#master所在机器的host name
MASTER_HOSTNAME=2-123
 
#master的数据目录
MASTER_DIRECTORY=/data/gp/master
 
#master的端口
MASTER_PORT=5432
 
#指定bash的版本
TRUSTED_SHELL=ssh
 
#将日志写入磁盘的间隔，每个段文件通常 =16MB < 2 * CHECK_POINT_SEGMENTS + 1
CHECK_POINT_SEGMENTS=8
 
#字符集
ENCODING=UNICODE
 
#mirror segment 起始的端口号
MIRROR_PORT_BASE=50000
 
#mirror的数据目录，和主数据目录对应
declare -a MIRROR_DATA_DIRECTORY=(/data/gp/mirror)
#如果每台机器上有多个segment
#declare -a MIRROR_DATA_DIRECTORY=(/data/mirror /data1/mirror /data2/mirror ...)
 
#segment机器列表
MACHINE_LIST_FILE=/home/gpadmin/conf/seg_only
```

【step-2】执行安装

在主节点上使用gpadmin用户执行如下命令：

如果存在stand by机器，则执行：

```shell
gpinitsystem -c ~/gpconfigs/gpinitsystem_config -h ~/conf/seg_only -s bigdata04
```

如果没有stand by机器，则执行：

```shell
gpinitsystem -c ～/gpconfigs/gpinitsystem_config -h ～/conf/seg_only
```

输出日志大致如下：

```log
20220612:00:01:11:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Checking configuration parameters, please wait...
20220612:00:01:11:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Reading Greenplum configuration file /home/gpadmin/gpconfigs/gpinitsystem_config
20220612:00:01:11:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Locale has not been set in /home/gpadmin/gpconfigs/gpinitsystem_config, will set to default value
20220612:00:01:11:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Locale set to en_US.utf8
20220612:00:01:12:065290 gpinitsystem:2-123:gpadmin-[INFO]:-No DATABASE_NAME set, will exit following template1 updates
20220612:00:01:12:065290 gpinitsystem:2-123:gpadmin-[INFO]:-MASTER_MAX_CONNECT not set, will set to default value 250
20220612:00:01:12:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Checking configuration parameters, Completed
20220612:00:01:12:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Commencing multi-home checks, please wait...
..
20220612:00:01:13:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Configuring build for standard array
20220612:00:01:13:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Commencing multi-home checks, Completed
20220612:00:01:13:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Building primary segment instance array, please wait...
..
20220612:00:01:14:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Building group mirror array type , please wait...
..
20220612:00:01:16:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Checking Master host
20220612:00:01:16:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Checking new segment hosts, please wait...
....
20220612:00:01:22:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Checking new segment hosts, Completed
20220612:00:01:22:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Greenplum Database Creation Parameters
20220612:00:01:22:065290 gpinitsystem:2-123:gpadmin-[INFO]:---------------------------------------
20220612:00:01:22:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Master Configuration
20220612:00:01:22:065290 gpinitsystem:2-123:gpadmin-[INFO]:---------------------------------------
20220612:00:01:22:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Master instance name       = Greenplum Data Platform
20220612:00:01:22:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Master hostname            = 2-123
20220612:00:01:22:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Master port                = 5432
20220612:00:01:22:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Master instance dir        = /data/pg/master/gpseg-1
20220612:00:01:22:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Master LOCALE              = en_US.utf8
20220612:00:01:22:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Greenplum segment prefix   = gpseg
20220612:00:01:22:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Master Database            =
20220612:00:01:22:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Master connections         = 250
20220612:00:01:22:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Master buffers             = 128000kB
20220612:00:01:22:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Segment connections        = 750
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Segment buffers            = 128000kB
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Checkpoint segments        = 8
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Encoding                   = UNICODE
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Postgres param file        = Off
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Initdb to be used          = /usr/local/greenplum-db-6.11.1/bin/initdb
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-GP_LIBRARY_PATH is         = /usr/local/greenplum-db-6.11.1/lib
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-HEAP_CHECKSUM is           = on
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-HBA_HOSTNAMES is           = 0
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Ulimit check               = Passed
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Array host connect type    = Single hostname per node
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Master IP address [1]      = ::1
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Master IP address [2]      = 172.16.2.123
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Master IP address [3]      = 172.17.0.1
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Master IP address [4]      = 172.30.10.1
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Master IP address [5]      = 192.168.122.1
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Master IP address [6]      = 192.168.242.192
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Master IP address [7]      = fe80::1425:37ff:fe13:80fc
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Master IP address [8]      = fe80::3014:8ff:fee1:a308
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Master IP address [9]      = fe80::3885:96a1:836c:1578
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Master IP address [10]      = fe80::40e0:55ff:fefe:791d
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Master IP address [11]      = fe80::42:1bff:fec7:a207
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Master IP address [12]      = fe80::42:ddff:fe55:e56d
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Master IP address [13]      = fe80::a002:41ff:fe25:f34d
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Master IP address [14]      = fe80::a043:6bff:fe3a:9eb5
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Master IP address [15]      = fe80::b00c:64ff:feac:7f25
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Master IP address [16]      = fe80::c877:c8ff:fecc:9029
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Master IP address [17]      = fe80::ecee:eeff:feee:eeee
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Master IP address [18]      = fe80::f4b3:9aff:fe16:27e7
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Standby Master             = 2-124
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Number of primary segments = 1
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Standby IP address         = ::1
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Standby IP address         = 172.16.2.124
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Standby IP address         = 172.17.0.1
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Standby IP address         = 192.168.122.1
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Standby IP address         = 192.168.3.0
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Standby IP address         = fe80::7a63:74af:8e0f:7f56
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Standby IP address         = fe80::ecee:eeff:feee:eeee
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Total Database segments    = 2
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Trusted shell              = ssh
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Number segment hosts       = 2
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Mirror port base           = 50000
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Number of mirror segments  = 1
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Mirroring config           = ON
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Mirroring type             = Group
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:----------------------------------------
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Greenplum Primary Segment Configuration
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:----------------------------------------
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-2-123       40000   2-123   /data/pg/primary/gpseg0         2
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-2-124       40000   2-124   /data/pg/primary/gpseg1         3
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:---------------------------------------
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Greenplum Mirror Segment Configuration
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:---------------------------------------
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-2-124       50000   2-124   /data/pg/mirror/gpseg0  4
20220612:00:01:23:065290 gpinitsystem:2-123:gpadmin-[INFO]:-2-123       50000   2-123   /data/pg/mirror/gpseg1  5

Continue with Greenplum creation Yy|Nn (default=N):
> y
20220612:00:01:39:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Building the Master instance database, please wait...
20220612:00:01:48:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Starting the Master in admin mode
20220612:00:01:50:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Commencing parallel build of primary segment instances
20220612:00:01:50:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Spawning parallel processes    batch [1], please wait...
..
20220612:00:01:50:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Waiting for parallel processes batch [1], please wait...
.........................................
20220612:00:02:32:065290 gpinitsystem:2-123:gpadmin-[INFO]:------------------------------------------------
20220612:00:02:32:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Parallel process exit status
20220612:00:02:32:065290 gpinitsystem:2-123:gpadmin-[INFO]:------------------------------------------------
20220612:00:02:32:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Total processes marked as completed           = 2
20220612:00:02:32:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Total processes marked as killed              = 0
20220612:00:02:32:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Total processes marked as failed              = 0
20220612:00:02:32:065290 gpinitsystem:2-123:gpadmin-[INFO]:------------------------------------------------
20220612:00:02:32:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Deleting distributed backout files
20220612:00:02:32:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Removing back out file
20220612:00:02:32:065290 gpinitsystem:2-123:gpadmin-[INFO]:-No errors generated from parallel processes
20220612:00:02:32:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Restarting the Greenplum instance in production mode
20220612:00:02:32:079127 gpstop:2-123:gpadmin-[INFO]:-Starting gpstop with args: -a -l /home/gpadmin/gpAdminLogs -m -d /data/pg/master/gpseg-1
20220612:00:02:32:079127 gpstop:2-123:gpadmin-[INFO]:-Gathering information and validating the environment...
20220612:00:02:32:079127 gpstop:2-123:gpadmin-[INFO]:-Obtaining Greenplum Master catalog information
20220612:00:02:32:079127 gpstop:2-123:gpadmin-[INFO]:-Obtaining Segment details from master...
20220612:00:02:32:079127 gpstop:2-123:gpadmin-[INFO]:-Greenplum Version: 'postgres (Greenplum Database) 6.11.1 build commit:df5f06d6fecffb4de64ab4ed2a1deb3a45efa37c'
20220612:00:02:32:079127 gpstop:2-123:gpadmin-[INFO]:-Commencing Master instance shutdown with mode='smart'
20220612:00:02:32:079127 gpstop:2-123:gpadmin-[INFO]:-Master segment instance directory=/data/pg/master/gpseg-1
20220612:00:02:32:079127 gpstop:2-123:gpadmin-[INFO]:-Stopping master segment and waiting for user connections to finish ...
server shutting down
20220612:00:02:33:079127 gpstop:2-123:gpadmin-[INFO]:-Attempting forceful termination of any leftover master process
20220612:00:02:33:079127 gpstop:2-123:gpadmin-[INFO]:-Terminating processes for segment /data/pg/master/gpseg-1
20220612:00:02:33:079127 gpstop:2-123:gpadmin-[ERROR]:-Failed to kill processes for segment /data/pg/master/gpseg-1: ([Errno 3] No such process)
20220612:00:02:33:079186 gpstart:2-123:gpadmin-[INFO]:-Starting gpstart with args: -a -l /home/gpadmin/gpAdminLogs -d /data/pg/master/gpseg-1
20220612:00:02:33:079186 gpstart:2-123:gpadmin-[INFO]:-Gathering information and validating the environment...
20220612:00:02:33:079186 gpstart:2-123:gpadmin-[INFO]:-Greenplum Binary Version: 'postgres (Greenplum Database) 6.11.1 build commit:df5f06d6fecffb4de64ab4ed2a1deb3a45efa37c'
20220612:00:02:33:079186 gpstart:2-123:gpadmin-[INFO]:-Greenplum Catalog Version: '301908232'
20220612:00:02:33:079186 gpstart:2-123:gpadmin-[INFO]:-Starting Master instance in admin mode
20220612:00:02:34:079186 gpstart:2-123:gpadmin-[INFO]:-Obtaining Greenplum Master catalog information
20220612:00:02:34:079186 gpstart:2-123:gpadmin-[INFO]:-Obtaining Segment details from master...
20220612:00:02:34:079186 gpstart:2-123:gpadmin-[INFO]:-Setting new master era
20220612:00:02:34:079186 gpstart:2-123:gpadmin-[INFO]:-Master Started...
20220612:00:02:34:079186 gpstart:2-123:gpadmin-[INFO]:-Shutting down master
20220612:00:02:34:079186 gpstart:2-123:gpadmin-[INFO]:-Commencing parallel segment instance startup, please wait...
.
20220612:00:02:36:079186 gpstart:2-123:gpadmin-[INFO]:-Process results...
20220612:00:02:36:079186 gpstart:2-123:gpadmin-[INFO]:-----------------------------------------------------
20220612:00:02:36:079186 gpstart:2-123:gpadmin-[INFO]:-   Successful segment starts                                            = 2
20220612:00:02:36:079186 gpstart:2-123:gpadmin-[INFO]:-   Failed segment starts                                                = 0
20220612:00:02:36:079186 gpstart:2-123:gpadmin-[INFO]:-   Skipped segment starts (segments are marked down in configuration)   = 0
20220612:00:02:36:079186 gpstart:2-123:gpadmin-[INFO]:-----------------------------------------------------
20220612:00:02:36:079186 gpstart:2-123:gpadmin-[INFO]:-Successfully started 2 of 2 segment instances
20220612:00:02:36:079186 gpstart:2-123:gpadmin-[INFO]:-----------------------------------------------------
20220612:00:02:36:079186 gpstart:2-123:gpadmin-[INFO]:-Starting Master instance 2-123 directory /data/pg/master/gpseg-1
20220612:00:02:36:079186 gpstart:2-123:gpadmin-[INFO]:-Command pg_ctl reports Master 2-123 instance active
20220612:00:02:36:079186 gpstart:2-123:gpadmin-[INFO]:-Connecting to dbname='template1' connect_timeout=15
20220612:00:02:36:079186 gpstart:2-123:gpadmin-[INFO]:-No standby master configured.  skipping...
20220612:00:02:36:079186 gpstart:2-123:gpadmin-[INFO]:-Database successfully started
20220612:00:02:36:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Completed restart of Greenplum instance in production mode
20220612:00:02:37:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Commencing parallel build of mirror segment instances
20220612:00:02:37:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Spawning parallel processes    batch [1], please wait...
..
20220612:00:02:37:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Waiting for parallel processes batch [1], please wait...
.......
20220612:00:02:44:065290 gpinitsystem:2-123:gpadmin-[INFO]:------------------------------------------------
20220612:00:02:44:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Parallel process exit status
20220612:00:02:44:065290 gpinitsystem:2-123:gpadmin-[INFO]:------------------------------------------------
20220612:00:02:44:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Total processes marked as completed           = 2
20220612:00:02:44:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Total processes marked as killed              = 0
20220612:00:02:44:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Total processes marked as failed              = 0
20220612:00:02:44:065290 gpinitsystem:2-123:gpadmin-[INFO]:------------------------------------------------
20220612:00:02:44:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Starting initialization of standby master 2-124
20220612:00:02:44:080854 gpinitstandby:2-123:gpadmin-[INFO]:-Validating environment and parameters for standby initialization...
20220612:00:02:45:080854 gpinitstandby:2-123:gpadmin-[INFO]:-Checking for data directory /data/pg/master/gpseg-1 on 2-124
20220612:00:02:45:080854 gpinitstandby:2-123:gpadmin-[INFO]:------------------------------------------------------
20220612:00:02:45:080854 gpinitstandby:2-123:gpadmin-[INFO]:-Greenplum standby master initialization parameters
20220612:00:02:45:080854 gpinitstandby:2-123:gpadmin-[INFO]:------------------------------------------------------
20220612:00:02:45:080854 gpinitstandby:2-123:gpadmin-[INFO]:-Greenplum master hostname               = 2-123
20220612:00:02:45:080854 gpinitstandby:2-123:gpadmin-[INFO]:-Greenplum master data directory         = /data/pg/master/gpseg-1
20220612:00:02:45:080854 gpinitstandby:2-123:gpadmin-[INFO]:-Greenplum master port                   = 5432
20220612:00:02:45:080854 gpinitstandby:2-123:gpadmin-[INFO]:-Greenplum standby master hostname       = 2-124
20220612:00:02:45:080854 gpinitstandby:2-123:gpadmin-[INFO]:-Greenplum standby master port           = 5432
20220612:00:02:45:080854 gpinitstandby:2-123:gpadmin-[INFO]:-Greenplum standby master data directory = /data/pg/master/gpseg-1
20220612:00:02:45:080854 gpinitstandby:2-123:gpadmin-[INFO]:-Greenplum update system catalog         = On
20220612:00:02:45:080854 gpinitstandby:2-123:gpadmin-[INFO]:-Syncing Greenplum Database extensions to standby
20220612:00:02:46:080854 gpinitstandby:2-123:gpadmin-[INFO]:-The packages on 2-124 are consistent.
20220612:00:02:46:080854 gpinitstandby:2-123:gpadmin-[INFO]:-Adding standby master to catalog...
20220612:00:02:46:080854 gpinitstandby:2-123:gpadmin-[INFO]:-Database catalog updated successfully.
20220612:00:02:46:080854 gpinitstandby:2-123:gpadmin-[INFO]:-Updating pg_hba.conf file...
20220612:00:02:47:080854 gpinitstandby:2-123:gpadmin-[INFO]:-pg_hba.conf files updated successfully.

20220612:00:02:50:080854 gpinitstandby:2-123:gpadmin-[INFO]:-Starting standby master
20220612:00:02:50:080854 gpinitstandby:2-123:gpadmin-[INFO]:-Checking if standby master is running on host: 2-124  in directory: /data/pg/master/gpseg-1
20220612:00:02:54:080854 gpinitstandby:2-123:gpadmin-[INFO]:-Cleaning up pg_hba.conf backup files...
20220612:00:02:54:080854 gpinitstandby:2-123:gpadmin-[INFO]:-Backup files of pg_hba.conf cleaned up successfully.
20220612:00:02:54:080854 gpinitstandby:2-123:gpadmin-[INFO]:-Successfully created standby master on 2-124
20220612:00:02:54:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Successfully completed standby master initialization
20220612:00:02:54:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Scanning utility log file for any warning messages
20220612:00:02:54:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Log file scan check passed
20220612:00:02:54:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Greenplum Database instance successfully created
20220612:00:02:54:065290 gpinitsystem:2-123:gpadmin-[INFO]:-------------------------------------------------------
20220612:00:02:54:065290 gpinitsystem:2-123:gpadmin-[INFO]:-To complete the environment configuration, please
20220612:00:02:54:065290 gpinitsystem:2-123:gpadmin-[INFO]:-update gpadmin .bashrc file with the following
20220612:00:02:54:065290 gpinitsystem:2-123:gpadmin-[INFO]:-1. Ensure that the greenplum_path.sh file is sourced
20220612:00:02:54:065290 gpinitsystem:2-123:gpadmin-[INFO]:-2. Add "export MASTER_DATA_DIRECTORY=/data/pg/master/gpseg-1"
20220612:00:02:54:065290 gpinitsystem:2-123:gpadmin-[INFO]:-   to access the Greenplum scripts for this instance:
20220612:00:02:54:065290 gpinitsystem:2-123:gpadmin-[INFO]:-   or, use -d /data/pg/master/gpseg-1 option for the Greenplum scripts
20220612:00:02:54:065290 gpinitsystem:2-123:gpadmin-[INFO]:-   Example gpstate -d /data/pg/master/gpseg-1
20220612:00:02:54:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Script log file = /home/gpadmin/gpAdminLogs/gpinitsystem_20220612.log
20220612:00:02:54:065290 gpinitsystem:2-123:gpadmin-[INFO]:-To remove instance, run gpdeletesystem utility
20220612:00:02:54:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Standby Master 2-124 has been configured
20220612:00:02:54:065290 gpinitsystem:2-123:gpadmin-[INFO]:-To activate the Standby Master Segment in the event of Master
20220612:00:02:54:065290 gpinitsystem:2-123:gpadmin-[INFO]:-failure review options for gpactivatestandby
20220612:00:02:54:065290 gpinitsystem:2-123:gpadmin-[INFO]:-------------------------------------------------------
20220612:00:02:55:065290 gpinitsystem:2-123:gpadmin-[INFO]:-The Master /data/pg/master/gpseg-1/pg_hba.conf post gpinitsystem
20220612:00:02:55:065290 gpinitsystem:2-123:gpadmin-[INFO]:-has been configured to allow all hosts within this new
20220612:00:02:55:065290 gpinitsystem:2-123:gpadmin-[INFO]:-array to intercommunicate. Any hosts external to this
20220612:00:02:55:065290 gpinitsystem:2-123:gpadmin-[INFO]:-new array must be explicitly added to this file
20220612:00:02:55:065290 gpinitsystem:2-123:gpadmin-[INFO]:-Refer to the Greenplum Admin support guide which is
20220612:00:02:55:065290 gpinitsystem:2-123:gpadmin-[INFO]:-located in the /usr/local/greenplum-db-6.11.1/docs directory
20220612:00:02:55:065290 gpinitsystem:2-123:gpadmin-[INFO]:-------------------------------------------------------
```

【step-3】配置环境变量

在主节点上使用gpadmin用户执行如下命令：

```shell
vim ~/.bashrc


source /usr/local/greenplum-db/greenplum_path.sh
export MASTER_DATA_DIRECTORY=/app/data/pg/master/gpseg-1
#默认登录使用的端口号
export PGPORT=5432
#默认登录使用的用户
export PGUSER=gpadmin
#默认登录使用的数据库
export PGDATABASE=postgres
#如果服务器使用的系统是RHEL 7或CentOS 7，需要增加下面的配置
export LD_PRELOAD=/lib64/libz.so.1 ps

source ~/.bashrc
```

【注意】 如果存在standby机器，需将配置文件复制到stand by机器！

【step-4】允许客户端连接

在主节点上使用gpadmin用户执行如下命令：

```shell
psql
```

如果前面的配置正确，则会免密登录到Greenplum数据库！

另外可以修改一下gpadmin的密码：

```sql
alter role gpadmin with password 'gpadmin';
```

退出数据库，在主节点上使用gpadmin用户执行如下命令：

```shell
vim $MASTER_DATA_DIRECTORY/pg_hba.conf
```

末尾添加一行：

```
#ADDRESS可以根据实际情况修改成对应的ip段
#连接方式 连接的数据库 连接的用户  连接的主机IP  认证方式
host     all       gpadmin    all         md5
```

或者：
```
host all gpadmin 0.0.0.0/0 md5
```

执行命令使配置生效：
```shell
gpstop -u
```

验证gp是否安装成功
```sql
select * from gp_segment_configuration;
```

【step-5】如果master故障，激活standby节点
模拟master1 down
```shell
 pg_ctl stop -s -m fast -D /data/gp/master/gpseg-1
```
在standby节点上执行命令
```shell
gpactivatestandby -d /data/gp/master/gpseg-1
```
验证是否切换成功
```shell
gpstate -s
```
将故障master节点重新加入集群，作为standby节点
先备份之前的主节点数据
```shell
mv  /data/gp/master/gpseg-1   /data/gp/master/gpseg-1_bak
```
将节点作为standby加入集群（在目前master节点执行）
```shell
gpinitstandby -s  故障节点主机名
```
验证节点是否作为standby加入集群（在目前master节点执行）
```shell
gpstate -f
```





### GP如何开启资源组
【**步骤-1**】查看资源是资源队列还是资源组

```shell
gpconfig -s gp_resource_manager
```

【**步骤-2**】必须先要开启os cgroups

https://blog.csdn.net/song_quan_/article/details/116653011

a.安装cgroup工具
```shell
yum install libcgroup-tools
```

b.配置gpdb使用硬件信息
```shell
vim /etc/cgconfig.d/gpdb.conf
```

```shell
group gpdb {
    perm {
        task {
            uid = gpadmin;
            gid = gpadmin;
        }
        admin {
            uid = gpadmin;
            gid = gpadmin;
        }
    }
    cpu {
    }
    cpuacct {
    }
    cpuset {
    }
    memory {
    }
}
```

c.执行cgroup配置
```shell
cgconfigparser -l /etc/cgconfig.d/gpdb.conf
```

d.启动cgroup
```shell
systemctl start cgconfig.service
systemctl enable cgconfig.service

systemctl status cgconfig.service
```

e.验证
```shell
grep cgroup /proc/mounts
```

返回结果；
```shell
tmpfs /sys/fs/cgroup tmpfs ro,nosuid,nodev,noexec,mode=755 0 0
cgroup /sys/fs/cgroup/systemd cgroup rw,nosuid,nodev,noexec,relatime,xattr,release_agent=/usr/lib/systemd/systemd-cgroups-agent,name=systemd 0 0
cgroup /sys/fs/cgroup/memory cgroup rw,nosuid,nodev,noexec,relatime,memory 0 0
cgroup /sys/fs/cgroup/freezer cgroup rw,nosuid,nodev,noexec,relatime,freezer 0 0
cgroup /sys/fs/cgroup/cpu,cpuacct cgroup rw,nosuid,nodev,noexec,relatime,cpuacct,cpu 0 0
cgroup /sys/fs/cgroup/hugetlb cgroup rw,nosuid,nodev,noexec,relatime,hugetlb 0 0
cgroup /sys/fs/cgroup/cpuset cgroup rw,nosuid,nodev,noexec,relatime,cpuset 0 0
cgroup /sys/fs/cgroup/net_cls,net_prio cgroup rw,nosuid,nodev,noexec,relatime,net_prio,net_cls 0 0
cgroup /sys/fs/cgroup/blkio cgroup rw,nosuid,nodev,noexec,relatime,blkio 0 0
cgroup /sys/fs/cgroup/devices cgroup rw,nosuid,nodev,noexec,relatime,devices 0 0
cgroup /sys/fs/cgroup/perf_event cgroup rw,nosuid,nodev,noexec,relatime,perf_event 0 0
cgroup /sys/fs/cgroup/pids cgroup rw,nosuid,nodev,noexec,relatime,pids 0 0
```

```shell
ls -l /sys/fs/cgroup/cpu/gpdb
```

返回结果：
```shell
drwx------ 2 gpadmin gpadmin 0 6月  12 18:02 16386
drwx------ 2 gpadmin gpadmin 0 6月  12 17:35 6437
drwx------ 2 gpadmin gpadmin 0 6月  12 17:35 6438
-rw-rw-r-- 1 gpadmin gpadmin 0 6月  12 17:23 cgroup.clone_children
--w--w---- 1 gpadmin gpadmin 0 6月  12 17:23 cgroup.event_control
-rw-rw-r-- 1 gpadmin gpadmin 0 6月  12 17:23 cgroup.procs
-r--r--r-- 1 gpadmin gpadmin 0 6月  12 17:23 cpuacct.stat
-rw-rw-r-- 1 gpadmin gpadmin 0 6月  12 17:23 cpuacct.usage
-r--r--r-- 1 gpadmin gpadmin 0 6月  12 17:23 cpuacct.usage_percpu
-rw-rw-r-- 1 gpadmin gpadmin 0 6月  12 17:23 cpu.cfs_period_us
-rw-rw-r-- 1 gpadmin gpadmin 0 6月  12 17:23 cpu.cfs_quota_us
-rw-rw-r-- 1 gpadmin gpadmin 0 6月  12 17:23 cpu.rt_period_us
-rw-rw-r-- 1 gpadmin gpadmin 0 6月  12 17:23 cpu.rt_runtime_us
-rw-rw-r-- 1 gpadmin gpadmin 0 6月  12 17:23 cpu.shares
-r--r--r-- 1 gpadmin gpadmin 0 6月  12 17:23 cpu.stat
-rw-rw-r-- 1 gpadmin gpadmin 0 6月  12 17:23 notify_on_release
-rw-rw-r-T 1 gpadmin gpadmin 0 6月  12 17:23 tasks
```

【**步骤-3**】GP开启资源组

a.查看资源是资源队列还是资源组
```shell
gpconfig -s gp_resource_manager
```
b.修改为资源组
```shell
gpconfig -c gp_resource_manager -v "group"
```

```shell
gpstop

gpstart

gpconfig -s gp_resource_manager
```



### 资源隔离演练
0.修改默认资源组所占资源
```sql
ALTER RESOURCE GROUP default_group SET cpu_rate_limit 20;
ALTER RESOURCE GROUP default_group SET memory_limit 20;
```

1.创建资源组
```sql
# 创建资源组rgroup1
CREATE RESOURCE GROUP rgroup1 WITH (CPU_RATE_LIMIT=70, MEMORY_LIMIT=70, CONCURRENCY=10);

# 查看所有资源组的限制
SELECT * FROM gp_toolkit.gp_resgroup_config;
```

2.创建用户组
```sql
# 创建dev用户组
CREATE ROLE dev CREATEROLE CREATEDB;
```

3.创建用户
```
# 创建p1用户 
CREATE ROLE p1;	
ALTER  ROLE p1 WITH PASSWORD 'Abc@1234';					
ALTER  ROLE p1 LOGIN;	
# 创建t1用户
CREATE ROLE t1;	
ALTER  ROLE t1 WITH PASSWORD 'Abc@1234';					
ALTER  ROLE t1 LOGIN;								
```

4.将用户加入至用户组
```sql
# 将p1加入用户组dev
GRANT dev TO p1;
# 将t1加入用户组dev
GRANT dev TO t1;
```

5.给用户组相关访问权限
```sql
# 创建数据库
create database poc;
# 给dev可以访问poc权限
GRANT ALL ON DATABASE poc TO dev;
```

6.将用户加入至资源组
```sql
# 将p1加入资源组
ALTER ROLE p1 RESOURCE GROUP rgroup1;

ALTER ROLE gpadmin RESOURCE GROUP rgroup1;
```
```sql
SELECT rolname, rsgname FROM pg_roles, pg_resgroup WHERE pg_roles.rolresgroup=pg_resgroup.oid;
```

7.用户加入远程联建
```shell
echo "local all p1 md5">> $MASTER_DATA_DIRECTORY/pg_hba.conf
echo "local all t1 md5">> $MASTER_DATA_DIRECTORY/pg_hba.conf


gpstop
gpstart
```

8.用户登录poc数据库
```shell
psql -U p1
```

```sql
\c poc p1;
```

9.执行测试语句
```sql
select pg_sleep(100);
```

10.查看资源组消耗情况
```sql
SELECT * FROM gp_toolkit.gp_resgroup_status_per_segment;
```


11.用户登录poc数据库
```shell
psql -U t1
```

```sql
\c poc t1;
```

12.执行测试语句
```sql
select pg_sleep(100);
```

13.查看资源组消耗情况
```sql
SELECT * FROM gp_toolkit.gp_resgroup_status_per_segment;
```








###########################################################
### PXF第三方插件安装
###########################################################
##### 默认情况下Greenplum没有初始化PXF。PXF安装步骤如下：

1.给集群所有节点安装JDK（略）

2.初始化PXF
```shell
PXF_CONF=$GPHOME/pxf/pxf_conf $GPHOME/pxf/bin/pxf cluster init
```
返回结果
```
Initializing PXF on master host and 1 segment host...
PXF initialized successfully on 2 out of 2 hosts
```
3.启动PXF
```shell
source /usr/local/greenplum-db/greenplum_path.sh
$GPHOME/pxf/bin/pxf cluster start
```
4.给数据库安装pxf扩展
```shell
\c poc 

create extension pxf;
```
5.授权
```shell
GRANT SELECT ON PROTOCOL pxf TO gpadmin;

GRANT insert ON PROTOCOL pxf TO gpadmin;
```
6.将相关文件放入pxf路径下
```shell
cd /usr/local/greenplum-db/pxf/pxf_conf/servers/default
```

7.下载hive依赖
```shell
# sudo yum -y install hadoop-client hive hbase
```

8.同步配置并启动服务
```shell
$GPHOME/pxf/bin/pxf cluster sync
$GPHOME/pxf/bin/pxf cluster stop
$GPHOME/pxf/bin/pxf cluster start
```



























##############################################################################
## FAQ
##############################################################################

### 基础操作

（1）进入终端：

    psql -d gp_sydb -U gpadmin

（2）创建数据库

    createdb -h localhost -p 5432 -U gpadmin testdb

（3）退出

    \q

（4）查询库

    \l

（5）查看当前数据库的表和视图

    \d

（6）切换数据库

    \c [db]

（7）查看表的结构

    \d [tb]

（8）查看表内容

    select * from uid_name;

（9）查看某个表在各个节点的情况

    select gp_segment_id,count(*) from name_table group by gp_segment_id; 

（10）列出当前数据库连接的信息

    select datname,pid,application_name,state from pg_stat_activity;

（11） 节点维护列表

    select * from gp_segment_configuration;

（12）创建用户并设置密码

    create user testdb with password 'testdb';

（13）创建数据

    create database testdb;

（14）授权数据库

    grant all on database testdb to testdb;

（15）删除用户

    drop user testdb;


### 如何查看集群状态

```shell
gpstate -e #查看mirror的状态
gpstate -f #查看standby master的状态
gpstate -s #查看整个GP群集的状态
gpstate -i #查看GP的版本
gpstate --help #帮助文档，可以查看gpstate更多用法
```

### 如何启停集群
```shell
# gpstop -M fast
# gpstart -a
```

### GP外部表

结合GP并行文件分配程序（gpfdist）。非为两种外部表：
（1）可读外部表：数据装载，不可以修改
（2）可写外部表：数据卸载，只可以insert

### GP装载数据

如何装载：
（1）通过gpload可以实现并行装载，需要配置一个yaml文件来说明控制文件。
（2）可以通过postgresql原生的copy实现，但是无法实现并行。

装载协议：
（1）gpfdist
（2）gpfdists：gpfdist的安全版本
（3）file：外部文件必须放置在segment主机上
（4）gphdfs

### 如何使用gpfdist？

启动服务：

```shell
gpfdist -d /var/load_files -p 8081 -l /home/gpadmin/log &
```

【注意】-d 参数代表外部文件所存放的本地路径

停止服务

```shell
# 方法一：
ps -e | grep gpfdist
kill -9 <pid>

# 方法二：
=# select pg_cancel_backend(1234);
```

如何验证GP集群的连接性：

```shell
wget http://gpfdist_hostname:port/filename
```

如使用gpfdist协议创建外部表？

a.创建单文件服务可读外表，文件格式为竖线分割

```sql
create external table tb_ext_gf01 (
id int,
name text
)
location ('gpfdist://<gpfdist_hostname>:<port>/*.txt')
format 'TEXT' (DELIMITER '|' NULL '');
```

b.创建多个文件服务可读外表，文件格式为竖线分割

```sql
create external table tb_ext_gf02 (
id int,
name text
)
location ('gpfdist://<gpfdist_hostname>:<port>/*.txt', 'gpfdist://<gpfdist_hostname2>:<port2>/*.txt')
format 'TEXT' (DELIMITER '|' NULL '');
```

c.带有错误数据日志的多文件服务

```sql
create external table tb_ext_gf03 (
id int,
name text,
amount float4
)
location ('gpfdist://<gpfdist_hostname>:<port>/*.csv', 'gpfdist://<gpfdist_hostname2>:<port2>/*.csv')
format 'CSV' (DELIMITER ',')
LOG ERRORS INTO err_customer SEGMENT REJECT LIMIT 2;
```

【注意】这里的REJECT LIMIT 2 表示：在装载过程中如果有失败的数据会被记录到err_customer表中，如果失败的数据条数超过2条则装载过程会失败中断！

d.创建可写外部表

```sql
create WRITABLE table tb_ext_gf04 (LIKE tb_cp_02)
location ('gpfdist://<gpfdist_hostname>:<port>/tb_cp_02.out')
format 'TEXT' (DELIMITER '|' NULL '')
DISTRIBUTED BY (id);

insert into tb_ext_gf04 select * from tb_cp_02;
```

### 如何使用gphdfs协议？

### 如何使用WEB外部表？

WEB表有两种定义方式：

（1）WEB URL
（2）OS命令

【注意】查询优化器是不允许重复扫描WEB表的数据，因为数据可能是动态变化的。

a.定义OS命令类型的WEB外表

【注意】命令必须放置在所有segment主机上，而且是从数据库执行不是从登录shell去执行。

```sql
create external WEB table tb_ext_web01 (output text)
execute 'hostname'
format 'TEXT';
```

【注意】execute用于指定命令或者一个脚本。


b.定义URL型WEB外表

```sql
create external WEB table tb_ext_web02 (
name text,
date date,
amount float4,
category text,
descciption text)
location (
 'http://<domin>/.../file.csv',
 'http://<domin>/.../file2.csv',
)
format 'CSV' (HEADER);
```

### GP数据倾斜

如何检查？

（1）使用gp_toolkit.gp_shew_* 视图查看数据倾斜情况

```sql
-- 注意观察skccoeff_numeric 越大代表偏斜程度越大
select * from p_toolkit.gp_shew_coefficients where skcrelname = 'tb_cp_02';

-- 注意观察siffraction_numeric>0 代表存在偏斜
select * from p_toolkit.gp_shew_idle_fractions where sifrelname = 'tb_cp_02';
```

（2）查看数据分布明细：

```sql
select gp_segment_id, count(1) 
  from tb_cp_02
 group by 1
 order by 1;
```

重新平衡数据

（1）如果分布键合理，直接重分布数据

```sql
alter table tb_cp_o2 set with (reorganize=true);
```

（2）否则重新调整分布键

```sql
alter table tb_cp_o2 set distributed by (id, date);
```

#### GP系统参数

重点参数：

max_connection
share_buff
work_mem

参数位置：
master：       /data/master/gpseg-1/postgresql.conf
segment local：/data/primary/gpseg0/postgresql.conf
/data/primary/gpseg1/postgresql.conf

设置本地化配置参数

【注意】必须修改所有的postgresql.conf文件才能生效

```shell
gpconfig -c gp_vmem_protect_limit -v 4096
```

重启gp生效

```shell
gpstop -rfa
```

设置master配置参数

【注意】 需要在master实例上设置

（1）在系统级别设置

a.编辑$MASTER_DATA_DIRECTORY/postgresql.conf文件

b.对需要修改的参数去掉注释，设置新的值，并保存文件

c.对于会话级别参数，不需要重启，执行如下命令生效： gpstop -u

d.对于需要重启的参数，重启数据库，执行：gpstop -rfa

（2）数据库级别进行设置

```sql
alter database <db> set search_path=<db>.<schema>;
```

（3）角色级别设置参数

```sql
alter role <r> set search_path to <db>.<schema>;
```

（4）会话级别设置参数

```sql
set work_mem=200;
reset work_mem;
```

如何查看配置参数设置；

```shell
psql -c 'show all'
```

查看整个系统特定参数

```shell
gpconfig -s max_connections;
```

### GP资源管理

资源组：设置gp_resource_manager='group'
资源组和资源资源队列只能选择其中一个使用，资源组需要用到linux的cgroups

资源队列：设置gp_resource_manager='queue'
数据库默认开启和使用资源队列，不需要依赖外部工具。

### 角色

默认不给login权限就认为是组

```sql
create role dylan;
```

给组用户登录权限

```sql
alter role dylan login;
```

创建新的组角色

CREATEROLE 确定是否允许角色创建和管理其他角色。 默认值是NOCREATEROLE。

```
CREATE ROLE admin CREATEROLE CREATEDB;
```

可以使用GRANT和REVOKE命令，来添加和删除成员

```sql
GRANT admin TO john, sally;
REVOKE admin FROM bob;
```

为了管理对象权限，您只能为组级角色授予适当的权限。然后，成员用户角色将继承组角色的对象权限

```sql
GRANT ALL ON TABLE mytable TO admin;
GRANT ALL ON SCHEMA myschema TO admin;
GRANT ALL ON DATABASE mydb TO admin;
```

使用GRANT此SQL命令为对象赋予指定的角色权限。

例如，要授予名为jsmith的角色在名为mytable的表上插入权限

```sql
GRANT INSERT ON mytable TO jsmith;
```

授予jsmith仅为名为table2表中的名为col1的查询权限

```sql
GRANT SELECT (col1) on TABLE table2 TO jsmith;
```

要撤消权限，使用REVOKE命令

```sql
REVOKE ALL 权限 ON mytable FROM jsmith;
```

也可以使用DROP OWNED和REASSIGN OWNED命令 用于管理已弃用角色所拥有的对象（注意：只有对象的所有者或超级用户才能删除对象或重新分配所有权）

```sql
REASSIGN OWNED BY sally TO bob;
DROP OWNED BY visitor;
```

获取管理属性

```sql
set role admin;
```

segment 启动失败
```log
20221208:17:57:56:1324772 gpstart:2-123:gpadmin-[INFO]:-Commencing parallel primary and mirror segment instance startup, please wait...
.
20221208:17:57:57:1324772 gpstart:2-123:gpadmin-[INFO]:-Process results...
20221208:17:57:57:1324772 gpstart:2-123:gpadmin-[INFO]:-----------------------------------------------------
20221208:17:57:57:1324772 gpstart:2-123:gpadmin-[INFO]:-   Successful segment starts                                            = 2
20221208:17:57:57:1324772 gpstart:2-123:gpadmin-[INFO]:-   Failed segment starts                                                = 0
20221208:17:57:57:1324772 gpstart:2-123:gpadmin-[WARNING]:-Skipped segment starts (segments are marked down in configuration)   = 2   <<<<<<<<
20221208:17:57:58:1324772 gpstart:2-123:gpadmin-[INFO]:-----------------------------------------------------
20221208:17:57:58:1324772 gpstart:2-123:gpadmin-[INFO]:-Successfully started 2 of 2 segment instances, skipped 2 other segments 
20221208:17:57:58:1324772 gpstart:2-123:gpadmin-[INFO]:-----------------------------------------------------
20221208:17:57:58:1324772 gpstart:2-123:gpadmin-[WARNING]:-****************************************************************************
20221208:17:57:58:1324772 gpstart:2-123:gpadmin-[WARNING]:-There are 2 segment(s) marked down in the database
20221208:17:57:58:1324772 gpstart:2-123:gpadmin-[WARNING]:-To recover from this current state, review usage of the gprecoverseg
20221208:17:57:58:1324772 gpstart:2-123:gpadmin-[WARNING]:-management utility which will recover failed segment instance databases.
20221208:17:57:58:1324772 gpstart:2-123:gpadmin-[WARNING]:-****************************************************************************
20221208:17:57:58:1324772 gpstart:2-123:gpadmin-[INFO]:-Starting Master instance 2-123 directory /data/pg/master/gpseg-1 
20221208:17:57:58:1324772 gpstart:2-123:gpadmin-[INFO]:-Command pg_ctl reports Master 2-123 instance active
20221208:17:57:58:1324772 gpstart:2-123:gpadmin-[INFO]:-Connecting to dbname='template1' connect_timeout=15
20221208:17:57:59:1324772 gpstart:2-123:gpadmin-[INFO]:-Starting standby master
20221208:17:57:59:1324772 gpstart:2-123:gpadmin-[INFO]:-Checking if standby master is running on host: 2-124  in directory: /data/pg/master/gpseg-1
20221208:17:58:02:1324772 gpstart:2-123:gpadmin-[WARNING]:-Number of segments not attempted to start: 2
20221208:17:58:02:1324772 gpstart:2-123:gpadmin-[INFO]:-Check status of database with gpstate utility
```
当mirror或primary某个seg是down的状态时，通过gprecoverseg -o 文件名称 生成恢复配置文件，使用gprecoverseg -i ./文件名称 进行恢复
```shell
gprecoverseg -o recov 

gprecoverseg -i ./recov
```










# 参考文档
https://cloud.tencent.com/developer/article/1647213




#### 参考资料
https://www.bilibili.com/video/BV1uZ4y167Sh?spm_id_from=333.337.search-card.all.click&vd_source=e2dcdb9599d6740aa309486bffdf04b5
https://www.bilibili.com/video/BV1vz4y197VK?spm_id_from=333.337.search-card.all.click&vd_source=e2dcdb9599d6740aa309486bffdf04b5

#### 参考文献

https://blog.51cto.com/feko/2738318

https://www.jianshu.com/p/929fd603ce0d

https://blog.csdn.net/qq_29120661/article/details/120976844

