# postgres 12 编译安装指南(ubuntu)

## 一、下载离线安装包

[PostgreSQL: File Browser](https://www.postgresql.org/ftp/source/)

下载：postgresql-12.12.tar.gz



## 二、安装

#### 1、安装依赖包

```shell
apt-cache search readline
apt-get install libreadline-dev
apt-get install zlib1g
apt-get install zlib1g.dev
```



#### 2、把postgresql安装包放到/data/tools/modules目录下进行解压：

```shell
tar -zxvf /data/tools/modules/postgresql-12.12.tar.gz
```



#### 3、切换到解压目录下，执行安装命令：

```shell
cd /data/tools/modules/postgresql-12.12/

./configure --prefix=/opt/postgresql-12.12
```

```shell
......
config.status: src/include/pg_config_ext.h is unchanged
config.status: creating src/interfaces/ecpg/include/ecpg_config.h
config.status: src/interfaces/ecpg/include/ecpg_config.h is unchanged
config.status: linking src/backend/port/tas/dummy.s to src/backend/port/tas.s
config.status: linking src/backend/port/posix_sema.c to src/backend/port/pg_sema.c
config.status: linking src/backend/port/sysv_shmem.c to src/backend/port/pg_shmem.c
config.status: linking src/include/port/linux.h to src/include/pg_config_os.h
config.status: linking src/makefiles/Makefile.linux to src/Makefile.port
```



#### 4、postgresql安装完成。

进行编译：

执行命令：`make`

```shell
......
make[1]: Leaving directory '/data/tools/modules/postgresql-12.12/src'
make -C config all
make[1]: Entering directory '/data/tools/modules/postgresql-12.12/config'
make[1]: Nothing to be done for 'all'.
make[1]: Leaving directory '/data/tools/modules/postgresql-12.12/config'
All of PostgreSQL successfully made. Ready to install.
```

执行命令：`make install`

```shell
......
make[1]: Leaving directory '/data/tools/modules/postgresql-12.12/src'
make -C config install
make[1]: Entering directory '/data/tools/modules/postgresql-12.12/config'
/usr/bin/mkdir -p '/data/software/postgresql/lib/pgxs/config'
/usr/bin/install -c -m 755 ./install-sh '/data/software/postgresql/lib/pgxs/config/install-sh'
/usr/bin/install -c -m 755 ./missing '/data/software/postgresql/lib/pgxs/config/missing'
make[1]: Leaving directory '/data/tools/modules/postgresql-12.12/config'
PostgreSQL installation complete.
```



## 三、配置

#### 1、创建postgresql用户

root用户不能启动postgresql，所以需要创建一个普通用户来启动数据库

创建用户：useradd postgres
设置密码：passwd postgres

用户名：postgres
密码：postgres



#### 2、 创建目录 和 log

创建目录 data(数据库存储) 和 log(日志存储)
将postgresql的目录权限全部赋予给postgres用户

```shell
mkdir -p /data/postgresql-12.12/data

mkdir -p /data/postgresql-12.12/log

chown -R postgres:postgres /opt/postgresql-12.12/

chown -R postgres:postgres /data/postgresql-12.12/
```



#### 3、配置环境变量

```shell
su - postgres

vim ~/.bashrc
```

配置内容如下：

```shell
export PGDATA=/data/postgresql-12.12/data
export PGHOME=/opt/postgresql-12.12
export PATH=$PATH:$PGHOME/bin
```

使配置生效：

```shell
source ~/.bashrc
```



#### 4、数据库初始化操作

**postgres初始化编码指定中文**

在postgres用户下使用

`initdb -D /data/postgresql-12.12/data -E UTF8 --locale=zh_CN.UTF-8 -U postgres -W`

- `-D /data/postgresql-12.12/data`    数据库存储目录

- `-E UTF8 --locale=zh_CN.UTF-8`    指定的是编码以及排序等，

  默认使用本地locale,可以敲locale查看，在执行初始化之前，使用`locale -a`查看本地locale 编码语言是否存在 zh_CN 的 locale 支持 并 使用`env` 查看系统编码 `LANG`。如果本地locale 编码语言不是中文支持，则添加中文编码支持。本地locale添加中文支持参考文档：[04 Add Chinese environment.md](../../../06.devops/01.linux/04 Add Chinese environment.md)


- `-U postgres  `    指的是创建超级用户 postgres

- `-W`    指的是为超级用户创建密码



初始化操作如下：


```shell
su - postgres
cd /opt/postgresql-12.12
initdb -D /data/postgresql-12.12/data -E UTF8 --locale=zh_CN.UTF-8 -U postgres -W
```

```shell
postgres@hcdb-nn1:/opt/postgresql-12.12$ initdb -D /data/postgresql-12.12/data -E UTF8 --locale=zh_CN.UTF-8 -U postgres -W
......
initdb: warning: enabling "trust" authentication for local connections
You can change this by editing pg_hba.conf or using the option -A, or
--auth-local and --auth-host, the next time you run initdb.

Success. You can now start the database server using:

    pg_ctl -D /data/postgresql-12.12/data -l logfile start

postgres@hcdb-nn1:/opt/postgresql-12.12$ 
```



其中**启动命令**如下：

```shell
pg_ctl -D /data/postgresql-12.12/data -l logfile start
```



#### 5、配置数据库

切换到postgresql下data目录下：

1. 编辑pg_hba.conf 配置文件：

```shell
vim pg_hba.conf
```

```shell
......
# "local" is for Unix domain socket connections only
local   all             all                                     trust
# IPv4 local connections:
#host    all             all             127.0.0.1/32            trust
host    all             all             0.0.0.0/0            md5
# IPv6 local connections:
host    all             all             ::1/128                 trust
# Allow replication connections from localhost, by a user with the
# replication privilege.
#local   replication     all                                     trust
#host    replication     all             127.0.0.1/32            trust
#host    replication     all             ::1/128                 trust
host    replication     postgres      0.0.0.0/0       md5
host    all             all           0.0.0.0/0       trust
```



2. 编辑postgresql.conf 配置文件：

```shell
vim postgresql.conf
```

```shell
......
listen_addresses = '*'          # what IP address(es) to listen on;
                                        # comma-separated list of addresses;
                                        # defaults to 'localhost'; use '*' for all
                                        # (change requires restart)
port = 5432                            # (change requires restart)
max_connections = 1000                  # (change requires restart)
#superuser_reserved_connections = 3     # (change requires restart)
....

# - TCP settings -
# see "man 7 tcp" for details

tcp_keepalives_idle = 7200              # TCP_KEEPIDLE, in seconds;
                                        # 0 selects the system default
tcp_keepalives_interval = 75            # TCP_KEEPINTVL, in seconds;
                                        # 0 selects the system default
tcp_keepalives_count = 9                # TCP_KEEPCNT;
                                        # 0 selects the system default
#tcp_user_timeout = 0                   # TCP_USER_TIMEOUT, in milliseconds;
                                        # 0 selects the system default

# - Authentication -

#authentication_timeout = 1min          # 1s-600s
password_encryption = on                # md5 or scram-sha-256
#db_user_namespace = off

......


#------------------------------------------------------------------------------
# REPLICATION
#------------------------------------------------------------------------------

# - Sending Server(s) -

# Set these on the master and on any standby that will send replication data.

max_wal_senders = 20            # max number of walsender processes
                                # (change requires restart)
#wal_keep_segments = 0          # in logfile segments, 16MB each; 0 disables
#wal_sender_timeout = 60s       # in milliseconds; 0 disables

max_replication_slots = 20      # max number of replication slots
......

#------------------------------------------------------------------------------
# REPORTING AND LOGGING
#------------------------------------------------------------------------------

# - Where to Log -

#log_destination = 'stderr'             # Valid values are combinations of
                                        # stderr, csvlog, syslog, and eventlog,
                                        # depending on platform.  csvlog
                                        # requires logging_collector to be on.

# This is used when logging to stderr:
logging_collector = on          # Enable capturing of stderr and csvlog
                                        # into log files. Required to be on for
                                        # csvlogs.
                                        # (change requires restart)

# These are only used if logging_collector is on:
log_directory = 'pg_log'                # directory where log files are written,
                                        # can be absolute or relative to PGDATA
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log' # log file name pattern,
                                        # can include strftime() escapes
log_file_mode = 0600                    # creation mode for log files,
                                        # begin with 0 to use octal notation
log_truncate_on_rotation = off          # If on, an existing log file with the
                                        # same name as the new log file will be
                                        # truncated rather than appended to.
                                        # But such truncation only occurs on
                                        # time-driven rotation, not on restarts
                                        # or size-driven rotation.  Default is
                                        # off, meaning append to existing files
                                        # in all cases.
log_rotation_age = 1d                   # Automatic rotation of logfiles will
                                        # happen after that time.  0 disables.
log_rotation_size = 10MB                # Automatic rotation of logfiles will
                                        # happen after that much log output.
......
# - What to Log -

#debug_print_parse = off
#debug_print_rewritten = off
#debug_print_plan = off
#debug_pretty_print = on
#log_checkpoints = off
#log_connections = off
#log_disconnections = off
#log_duration = off
#log_error_verbosity = default          # terse, default, or verbose messages
#log_hostname = off
#log_line_prefix = ''                   # special values:
                                        #   %a = application name
                                        #   %u = user name
                                        #   %d = database name
                                        #   %r = remote host and port
                                        #   %h = remote host
                                        #   %p = process ID
                                        #   %t = timestamp without milliseconds
                                        #   %m = timestamp with milliseconds
                                        #   %n = timestamp with milliseconds (as a Unix epoch)
                                        #   %i = command tag
                                        #   %e = SQL state
                                        #   %c = session ID
                                        #   %l = session line number
                                        #   %s = session start timestamp
                                        #   %v = virtual transaction ID
                                        #   %x = transaction ID (0 if none)
                                        #   %q = stop here in non-session
                                        #        processes
                                        #   %% = '%'
                                        # e.g. '<%u%%%d> '
#log_lock_waits = off                   # log lock waits >= deadlock_timeout
log_statement = 'all'                   # none, ddl, mod, all
#log_replication_commands = off
#log_temp_files = -1                    # log temporary files equal or larger
                                        # than the specified size in kilobytes;
                                        # -1 disables, 0 logs all temp files
log_timezone = 'PRC'
......
# - Locale and Formatting -

datestyle = 'iso, ymd'
#intervalstyle = 'postgres'
timezone = 'PRC'
#timezone_abbreviations = 'Default'     # Select the set of available time zone
                                        # abbreviations.  Currently, there are
                                        #   Def:ault
                                        #   Australia (historical usage)
                                        #   India
                                        # You can create your own file in
                                        # share/timezonesets/.
#extra_float_digits = 0                 # min -15, max 3
#client_encoding = sql_ascii            # actually, defaults to database
                                        # encoding

# These settings are initialized by initdb, but they can be changed.
lc_messages = 'zh_CN.UTF-8'                     # locale for system error message
                                        # strings
lc_monetary = 'zh_CN.UTF-8'                     # locale for monetary formatting
lc_numeric = 'zh_CN.UTF-8'                      # locale for number formatting
lc_time = 'zh_CN.UTF-8'                         # locale for time formatting

# default configuration for text search
default_text_search_config = 'pg_catalog.simple'
.....
```



#### 6、关闭防火墙

1.查看防火墙当前状态

```shell
root@hcdb-nn1:/data/postgresql-12.12/data# sudo ufw status
Status: inactive
root@hcdb-nn1:/data/postgresql-12.12/data#
```

2.开启防火墙

```shell
sudo ufw enable
```

3.关闭防火墙

```shell
root@hcdb-nn1:/data/postgresql-12.12/data# sudo ufw disable
Firewall stopped and disabled on system startup
root@hcdb-nn1:/data/postgresql-12.12/data# 
```

4.查看防火墙版本

```shell
root@hcdb-nn1:/data/postgresql-12.12/data# sudo ufw version
ufw 0.36.1
Copyright 2008-2021 Canonical Ltd.
root@hcdb-nn1:/data/postgresql-12.12/data#
```

5.默认允许外部访问本机

```shell
sudo ufw default allow
```

6.默认拒绝外部访问主机

```shell
sudo ufw default deny
```

7.允许外部访问5342端口

```shell
sudo ufw allow 5342
```

8.拒绝外部访问53端口

```shell
sudo ufw deny 53
```

9.允许某个IP地址访问本机所有端口

```shell
sudo ufw allow from 192.168.0.1
```



#### 7、配置开机自启系统服务(root用户)

首先进入postgresql的解压目录(本文为 `/data/tools/modules/postgresql-12.12` )，

执行命令` cp contrib/start-scripts/linux /etc/init.d/postgresql`，

然后 ` vim /etc/init.d/postgresql`，进行配置修改：

```shell
root@hcdb-nn1:/data/tools/modules/postgresql-12.12# cp contrib/start-scripts/linux /etc/init.d/postgresql
root@hcdb-nn1:/data/tools/modules/postgresql-12.12# 
root@hcdb-nn1:/data/tools/modules/postgresql-12.12# vim /etc/init.d/postgresql
......
# Original author:  Ryan Kirkpatrick <pgsql@rkirkpat.net>

# contrib/start-scripts/linux

## EDIT FROM HERE

# Installation prefix
prefix=/opt/postgresql-12.12

# Data directory
PGDATA="/data/postgresql-12.12/data"

# Who to run the postmaster as, usually "postgres".  (NOT "root")
PGUSER=postgres

# Where to keep a log file
PGLOG="/data/postgresql-12.12/log"
```

然后使用命令 `chmod +x /etc/init.d/postgresql`，赋予该文件执行权限。

另外，还可以使用命令` chkconfig --add postgresql`，设置服务开机自启。

注：在Ubuntu上没有` chkconfig`, 我们可以使用sysv-rc-conf。

```shell
sudo apt install sysv-rc-conf
```

安装完成sysv-rc-conf之后，我们把他换成chkconfig。毕竟这个命令太难记住了。

```shell
sudo cp /usr/sbin/sysv-rc-conf /usr/sbin/chkconfig
```

接下来执行下列命令，把服务设置成自动启动即可。

```shell
sudo chkconfig postgresql-12. on
sudo chkconfig --list | grep postgres
```

[Ubuntu 16.04设置PostgreSQL开机启动的方法](https://cloud.tencent.com/developer/article/1721610)

[Ubuntu下安装sysv-rc-conf报错：“E: Unable to locate package sysv-rc-conf“](https://blog.csdn.net/willingtolove/article/details/107494719)



#### 8、启动及连接数据库

1、启停服务

```shell
root@hcdb-nn1:/data/tools/modules/postgresql-12.12# su - postgres
postgres@hcdb-nn1:~$ pg_ctl -D /data/postgresql-12.12/data  start
```

pg_ctl status  #查看状态
pg_ctl start    #启动
pg_ctl stop     #停止
pg_ctl restart  #重启

可以通过 ps -ef|grep postgres，查看postgres相关进程。



#### 9、编辑PostgreSQL的脚本

编辑PostgreSQL 启动、停止、重启、查看状态的脚本：

```shell
vim pgServer.sh

$PGHOME/bin/pg_ctl -D /data/postgresql-12.12/data $1
```





## FAQ:

#### 1、修改密码psql登录

```SQL
psql -h 192.168.3.111 -p 5432 -U postgres -d postgres

ALTER USER postgres WITH PASSWORD 'postgres';

\q
```

[postgresql 安装使用修改密码psql登录](https://blog.csdn.net/qq_17693195/article/details/125504783)



#### 2、解决每次切换为postgres用户都需要` source ~/.bashrc`文件的问题:

```shell
vim ~/.bash_profile
```

在文件内部输入

```shell
# Get the aliases and functions
if test -f ~/.bashrc ; then
   source ~/.bashrc
fi
```

[解决.bashrc文件每次打开终端都需要source的问题](https://blog.csdn.net/qq_32146369/article/details/108839865)



#### 3、Flink CDC 连接 postgresql

1、更改 postgresql.conf

```shell
# 更改wal日志方式为logical
wal_level = logical            # minimal, replica, or logical
# 更改solts最大数量（默认值为10），flink-cdc默认一张表占用一个
max_replication_slots = 20           # max number of replication slots
# 更改wal发送最大进程数（默认值为10），这个值和上面的solts设置一样
max_wal_senders = 20    # max number of walsender processes
```


参考案例：[Flink CDC 连接 postgresql 遇到的问题](https://blog.csdn.net/H_X_P_/article/details/124036783)
