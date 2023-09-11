# 如何下载？

## 标准下载

​		Anaconda官方下载地址为：https://www.anaconda.com/。

​		如果你的Mac是M1芯片点击【Download for Mac（**M1/M2**）】下载，如果是英特尔芯片则点击【Download for Mac（**Intel**）】。下载之后是一个.pkg后缀名的压缩包。

## 扩展下载

​		如果需要扩展下载则点击【[Get Additional Installers](https://www.anaconda.com/download#downloads)】。同样的，如果你的Mac是M1芯片点击带有“64-Bit(M1)”字样的连接下载，否则点击不带有“64-Bit(M1)”字样的连接下载。



【注意】

​		1⃣️ 带有“Graphical Installer”字样的是图形化安装包，其文件名后缀为.pkg。

​		2⃣️ 带有“Command Line Installer”字样的是命令行安装包，其文件名后缀为.sh。



​		这里主要为了后续交互方便，选择图形化安装包。

# 如何安装？

​		双击.pkg压缩文件，一路继续，在【安装类型】这个步骤点击在【在特定的磁盘上安装】->【选取文件夹】可以将应用安装到指定的目录中，然后点击【继续】->【安装】。安装过程较慢，因为Anaconda需要进行一些初始化的配置，以及运行一些软件包脚本，直至完全安装完毕。

​		此时通过MacOS的启动台就可以看到“Anaconda-Navigator”图标，此时如果打开命令行终端，会在命令提示符前面看到类似“**(base)**”字样，这是因为Anaconda安装完毕之后会默认激活base环境。可以通过如下命令如果正常显示则代表安装完成：

```shell
> conda --version

conda 23.5.2
```

​		此时也可以查看当前环境下的Python版本：

```shell
> python -V

Python 3.11.3
```



# 如何配置镜像加速？

​		配置镜像加速的目的主要为了通过conda install命令下载python依赖时太慢，因为默认状态下采用的是默认官方下载源。可以通过conda info命令可以查看当前conda的基本信息：

```shell
> conda info

     active environment : base
    active env location : /Users/ll/soft/Anaconda/anaconda3
            shell level : 1
       user config file : /Users/ll/.condarc
 populated config files : /Users/ll/.condarc
          conda version : 23.5.2
    conda-build version : 3.25.0
         python version : 3.11.3.final.0
       virtual packages : __archspec=1=x86_64
                          __osx=10.16=0
                          __unix=0=0
       base environment : /Users/ll/soft/Anaconda/anaconda3  (writable)
      conda av data dir : /Users/ll/soft/Anaconda/anaconda3/etc/conda
  conda av metadata url : None
           channel URLs : https://repo.anaconda.com/pkgs/main/osx-64
                          https://repo.anaconda.com/pkgs/main/noarch
                          https://repo.anaconda.com/pkgs/r/osx-64
                          https://repo.anaconda.com/pkgs/r/noarch
          package cache : /Users/ll/soft/Anaconda/anaconda3/pkgs
                          /Users/ll/.conda/pkgs
       envs directories : /Users/ll/soft/Anaconda/anaconda3/envs
                          /Users/ll/.conda/envs
               platform : osx-64
             user-agent : conda/23.5.2 requests/2.29.0 CPython/3.11.3 Darwin/21.5.0 OSX/10.16
                UID:GID : 501:20
             netrc file : None
           offline mode : False
```

​		可以在【channel URLs】选项中看到当前采用的默认下载源。这里需要配置为清华的Tuna镜像源，执行如下命令：

```shell
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/msys2/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
conda config --set show_channel_urls yes
```

​		再次查看并验证配置镜像源成功。

```shell
> conda info

           ...
           channel URLs : https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/osx-64
                          https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/noarch
                          https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/osx-64
                          https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/noarch
                          https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/msys2/osx-64
                          https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/msys2/noarch
                          https://repo.anaconda.com/pkgs/main/osx-64
                          https://repo.anaconda.com/pkgs/main/noarch
                          https://repo.anaconda.com/pkgs/r/osx-64
                          https://repo.anaconda.com/pkgs/r/noarch
          ...
```

​		除了通过命令的方式配置镜像加速，也可以在当前用户的家目录下添加.condarc文件进行配置。

```shell
> touch ~/.condarc
> vim ~/.condarc

channels:
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/msys2/
  - defaults
show_channel_urls: true
```

# 常用指令

（1）查看当前虚拟环境所有python依赖和版本。

```shell
# 查看当前虚拟环境所有python依赖和版本
conda list
# 查看当前虚拟环境指定赖和版本
conda list <pkg-name>
```

（2）查看所有虚拟环境。

```shell
> conda env list


# conda environments:
#
base                     /Users/ll/soft/Anaconda/anaconda3
dev                   *  /Users/ll/soft/Anaconda/anaconda3/envs/dev
```

（3）创建虚拟环境。例如：常见一个基于python3.7版本的名称为dev的虚拟环境。

```shell
conda create -n dev python=3.8
```

（4）激活虚拟环境。例如：激活名称为dev的虚拟环境，激活之后会看到命令提示符变为“(dev)”。

```shell
conda activate dev
```

（5）退出当前虚拟环境。

```shell
conda deactivate
```

（6）删除虚拟环境。例如：删除名称为dev的虚拟环境。

```shell
conda remove -n dev --all
```

（7）升级相关依赖。

```shell
# 更新conda
conda update conda
# 更新所有安装包
conda update --all
# 升级python
conda update python
# 升级指定以来包
conda update <pkg-name>
```

（8）安装依赖。

```shell
# 安装依赖
conda install numpy
# 安装指定版本的依赖
conda install python=3.7.12
```

