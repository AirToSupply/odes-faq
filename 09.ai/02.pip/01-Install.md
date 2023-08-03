# 如何安装？

​		这里假定Anaconda已经安装成功，执行如下命令进行pip安装，在默认情况下Anaconda的bash环境自带pip

```shell
conda install pip && conda update pip
```

# 如何配置镜像加速？

​		配置镜像加速的目的主要为了通过pip install命令下载python依赖时太慢，因为默认状态下采用的是默认官方下载源。

​		可以在【channel URLs】选项中看到当前采用的默认下载源。这里需要配置为清华的Tuna镜像源，执行如下命令：

```shell
mdkir ~/.pip && vim ~/.pip/pip.conf
```

​		然后配置如下命令：

```toml
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
[install]
trusted-host = pypi.tuna.tsinghua.edu.cn
disable-pip-version-check = true
timeout = 6000
```

# 常用指令

（1）安装依赖。

```shell
# 安装依赖
pip install numpy
# 安装指定版本的依赖
pip install matplotlib==3.4.1
# 指定具体镜像源安装依赖
pip install <pkg-name> -i https://pypi.douban.com/simple/
```

（2）卸载依赖。

```shell
pip uninstall <pkg-name>
```

（3）更新依赖。

```shell
# 方法一
pip install --upgrade <pkg-name>
# 方法二
pip install -U <pkg-name>
```

（4）查看某个包的信息。

```shell
pip show -f <pkg-name>
```

（5）下载依赖到指定路径（下载但不安装）。

```shell
pip download <pkg-name> -d <path>
```

（6）从指定路径安装依赖（离线安装）。

```shell
pip install <pkg-name> -f <path>
```

（7）批量离线安装步骤。

```shell
# 步骤一：把所有包名及版本号，重定向到requirements.txt中
pip freeze > requirements.txt
# 步骤二：在有网络的情况下下载到指定目录
# [注意] 这里是两部分内容：一个是打包好的安装包，一个是包的名字和版本号的说明文件requirements.txt
pip download -r requirements.txt -d <pkgs-path>
# 步骤三：将步骤二中的两部分内容拷贝到内网环境下进行安装
pip install --no-index --find-links=<pkgs-path> -r requirements.txt
# 如果是安装某一个包，进入到指定目录下执行如下命令
pip install xxx.whl
```

​		