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
