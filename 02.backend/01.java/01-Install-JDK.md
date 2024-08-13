# 安装

（1）解压安装包

```shell
cd /workspace/opt
tar -zxvf /tmp/modules/jdk-8u201-linux-x64.tar.gz -C .
```

（2）配置环境变量

```shell
vim ~/.bashrc
```

配置如下内容：

```shell
export JAVA_HOME=/workspace/opt/jdk1.8.0_201
export PATH=$PATH:$JAVA_HOME/bin
```

（3）配置生效

```shell
source ~/.bashrc
```

（4）验证

```shell
java -version
```



# 附录

​	（1）下载JDK17，可参考：[Java SE 17 Archive Downloads](https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html)。

​	（2）下载JDK8，可参考：[java8 Mac Archive Downloads](https://www.oracle.com/java/technologies/downloads/#java8-mac)。

​	（3）下载其他JDK，可参考：[wlei0618](https://blog.csdn.net/wlei0618/article/details/126861940)。
