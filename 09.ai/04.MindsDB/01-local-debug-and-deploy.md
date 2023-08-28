# 前置说明

​		本小节主要探寻如何在MacOS操作系统下通过**源码编译**的方式启动MindsDB服务，已经能够更好的观察该服务的在机器学习中的核心运作流程。

​		关于源码编译部分可以参考：[Setup for Source Code via pip](https://docs.mindsdb.com/setup/self-hosted/pip/source)

​		实验MindsDB版本为：`v23.8.3.0`

# 前置准备

​		【步骤一】安装`Anaconda`环境。（略）

​		【步骤二】安装`pip`环境。（略）

​		【步骤】安装libomp依赖并配置。

```shell
> brew install libomp
> vim ~/.basb_profile

export LDFLAGS="-L/usr/local/opt/libomp/lib"
export CPPFLAGS="-I/usr/local/opt/libomp/include"

> source ~/.basb_profile
```

​		【步骤四】安装libmagic依赖。

```shell
pip install python-magic-bin
brew install libmagic
```

# 源码编译

​		【步骤一】创建虚拟环境。

```shell
conda create -n mindsdb python==3.10.9
conda activate create
```

​		【步骤二】拉取源码。

```shell
git clone https://github.com/mindsdb/mindsdb.git
cd mindsdb
git tag
git checkout v23.8.3.0
```

​		【步骤三】安装相关依赖。

```shell
pip install -r requirements/requirements.txt
pip install --upgrade pip setuptools wheel
python setup.py develop
```

# 安装部署

```shell
export MINDSDB_STORAGE_DIR=/tmp/mindsdb && python -m mindsdb --api http,postgres
```

​		MINDSDB_STORAGE_DIR为指定MindsDB的存储路径，更多的配置参数可以参考：[Environment Variables](https://docs.mindsdb.com/setup/environment-vars)。

​        --api参数指定对外服务暴露的方式，这里指定http代表会打开web控制台，指定postgres则可以通过psql客户端工具进行访问。

​		成功启动之后，可以访问`http://127.0.0.1:47334/`进入MindsDB控制台。

​		另外一方面，可以通过数据库客户端连接服务端：

```shell
> psql -h localhost -p 55432 -d mindsdb -U mindsdb

mindsdb=> select version();
 version
---------
 8.0.17
(1 row)

mindsdb=> show databases;
      Database
--------------------
 information_schema
 mindsdb
 files
 web
(4 rows)

mindsdb=> show full databases;
      Database      |  TYPE   | ENGINE
--------------------+---------+--------
 information_schema | system  |
 mindsdb            | project |
 files              | data    | files
 web                | data    | web
(4 rows)
```

​		至此安装部署成功！