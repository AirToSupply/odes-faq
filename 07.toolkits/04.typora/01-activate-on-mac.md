# 如何下载

​	[Typora下载](https://www.typoraio.cn/)

# 如何激活

​	在【应用程序】文件下找到Typora应用，右击【显示内容包】则跳转到该应用的物理安装目录，找到如下目录中的js文件：

```shell
/Applications/Typora.app/Contents/Resources/TypeMark/page-dist/static/js/LicenseIndex.180dd4c7.54395836.chunk.js
```

​	输入`hasActivated="true"==e.hasActivated`代码改为`hasActivated="true"=="true"`再重新打开即可完成激活。
