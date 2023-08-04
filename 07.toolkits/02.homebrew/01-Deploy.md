# 什么是Homebrew？

​		Homebrew是MacOS操作系统下的软件包下载工具，类似于Unbantu系统下的apt-get或者CentOS系统下的yum。

# 如何安装？

​		在MacOS系统中打开终端，执行如下命令下载并安装Homebrew：

```shell
/usr/bin/ruby -e "$(curl -fsSL https://cdn.jsdelivr.net/gh/ineo6/homebrew-install/install)"
```

​		执行如下执行有正常打印则表示安装成功：

```shell
brew --version
```

# 最佳实践

## 镜像加速

​		进入Homebrew的家目录编辑config配置文件：

```shell
cd "$(brew --repo)"
vim .git/config
```

​		这里添加的是阿里云的镜像代理：

```toml
[core]
        repositoryformatversion = 0
        filemode = true
        bare = false
        logallrefupdates = true
        ignorecase = true
        precomposeunicode = true
        autocrlf = false
        symlinks = true
[remote "origin"]
        url = https://mirrors.aliyun.com/homebrew/brew.git
        fetch = +refs/heads/*:refs/remotes/origin/*
[branch "master"]
        remote = origin
        merge = refs/heads/master
[homebrew]
        analyticsmessage = true
        caskanalyticsmessage = true
```

## 关闭下载自更新

​		在默认情况下下载软件包之前Homebrew都会进行对自身的自动更新，这是非常耗时的。需要在系统环境变量添加如下内容：

```shell
export HOMEBREW_NO_AUTO_UPDATE=true
```

# 常用命令

（1）列出当前已经安装的软件包。

```shell
brew list
```

（2）查找软件包。比如这里查找postgresql。

```shell
brew search postgresql
```

（3）下载软件包。比如下载15版本的postgresql。

```shell
brew install postgresql@15
```

（4）查看已经安装的软件包信息。比如查看所安装的spark。

```shell
brew info spark
```

（5）卸载已经安装的软件包。比如卸载kibana和es。

```shell
brew uninstall kibana es --force
```

