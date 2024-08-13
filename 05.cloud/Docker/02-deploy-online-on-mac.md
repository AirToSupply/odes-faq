# 如何安装

​	参考：[Mac下安装docker的三种方法](https://zhuanlan.zhihu.com/p/91116621)

# 如何配置镜像加速

​	点击工具栏图标下的【Settings】->【Docker Engine】在json中配置镜像加速。

​	这里采用阿里云提供的镜像加速，登陆阿里云账号点击右上角【控制台】搜索“容器镜像服务”，点击左侧工具栏【镜像工具】->【镜像加速器】，在“2. 配置镜像加速器”中会有如何配置。

​	配置之后大致如下：

```json
{
  "builder": {
    "gc": {
      "defaultKeepStorage": "20GB",
      "enabled": true
    }
  },
  "experimental": false,
  "registry-mirrors": [
    "https://xxyyzz.mirror.aliyuncs.com"
  ]
}
```

​	配置完毕之后点击【Apply & restart】重启Docker引擎即可。

​	【TIPS】上述JSON配置文件位于：~/.docker/daemon.json；还有一个重要的配置文件在：~/.docker/config.json。

# FAQ

​	（1）执行`docker login`登录自己的docker hub账号输入密码，报错如下异常：

```shell
Error saving credentials: error storing credentials - err: exit status 1, out: `error storing credentials - err: exit status 1, out: `User interaction is not allowed.``
```

​	出现这个问题主要是当前用户不被允许访问Docker，直接在终端输入如下命令：

```shell
security unlock-keychain
password to unlock default: 
```

​	`password to unlock default`处输入自己Mac登录密码即可。

​	（2）通过Docker Desktop登入自己的docker hub账号输入密码，UI提示：

```shell
Post "https://login.docker.com/oauth/token": context deadline exceeded
```

​	暂未解决，可能需要搭载梯子。

​	（3）Docker镜像如何加速？

​	这里以阿里云为例，主要使用阿里云的`容器镜像服务 ACR`。进入`管理控制台`之后点击【镜像工具】->【镜像加速器】，将`加速器地址`配置到~/.docker/daemon.json文件的registry-mirrors字段即可。

​	关于其他的方法还有很多，可以参考：[Docker 镜像库国内加速的几种方法](https://www.cnblogs.com/east4ming/p/17691684.html)。

​	（4）拉取Docker镜像总是受阻？

​	可以配置不止一个镜像，主要由于某些原因，Docker Hub官方仓库在国内已经无法拉取，如果是国内网络环境，可配置国内镜像使用，从而解决Docker镜像拉取失败或缓慢问题。笔者目前的配置顺序是这样的：

```shell
"registry-mirrors": [
  // 阿里云镜像
  "https://xxyyzz.mirror.aliyuncs.com",
  "https://docker.m.daocloud.io",
  "https://dockerproxy.com",
  "https://docker.mirrors.ustc.edu.cn",
  "https://docker.nju.edu.cn"
]
```

​	更加具体的方案可以参考[这篇博客](https://www.cnblogs.com/rainbond/p/18260539)。
