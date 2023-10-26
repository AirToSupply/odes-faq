# 如何安装

​	下载地址：[release-v14.14.0](https://nodejs.org/download/release/v14.14.0/)

​	解压：

```shell
tar -zxvf /opt/node-v14.14.0-linux-x64.tar.gz -C /usr/local
```

​	配置环境变量：

```shell
> vim ~/.bashrc

# NodeJS
export NODE_HOME=/usr/local/node-v14.14.0-linux-x64
export PATH=$PATH:$NODE_HOME/bin

> source ~/.bashrc
```

​	验证如下命令没有问题则代表安装完成！

```shell
> node -v
v14.14.0
> npm -v
6.14.8
> app npx -v
6.14.8
```

# 镜像加速

​	这里配置淘宝源：

```shell
npm config set registry https://registry.npm.taobao.org
```

​	查询镜像仓库配置：

```shell
npm config get registry
```

​	获取库信息：

```shell
npm info express
```

​	如果想使用cnpm可以进行如下操作：

```shell
npm install -g cnpm --registry=https://registry.npm.taobao.org
cnpm install express 
```

# 如何启动HTTP服务器

​	创建nodejs脚本hello.js：

```js
var http = require("http");
http.createServer(function(request, response) {
 response.writeHead(200, {
 "Content-Type" : "text/plain"
 });
 response.write("Hello World");
 response.end();
}).listen(8100); 
console.log("nodejs start listen 8100 port!");
```

```shell
chmod u+x hello.js && node hello.js &
```

​	通过如下命令进行测试：

```shell
> curl http://localhost:8100
Hello World
```

