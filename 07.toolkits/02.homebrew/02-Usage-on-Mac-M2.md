# 问题

​	MacOS使用作为类Unix内核运行Python十分方便，在没有推出Apple M系统芯片之前都是采用英特尔芯片，特别是运行基于Python的一些机器学习库非常丝滑。但是推出Apple M芯片之后采用了基于arm架构的芯片，在完成此类工作时就开始陆续出现问题了。例如：经常会遇到运行lightGBM登陆无法加载问题，就像下面这样：

```shell
Referenced from: /opt/homebrew/anaconda3/envs/biligame/lib/python3.8/site-packages/lightgbm/lib_lightgbm.so
Reason: tried: '/usr/local/opt/libomp/lib/libomp.dylib' (no such file), '/usr/local/lib/libomp.dylib' (no such file), '/usr/lib/libomp.dylib' (no such file)
```

​	这里会提示一个libomp库找不到问题，在Linux操作系统上并没有通过测试。但是至少在MacOS操作系统（无论是M芯片还是英特尔芯片）上，需要去安装libomp这个库。通常最快的方式是通过brew工具去进行安装：

```shell
brew install libomp
```

​	安装完毕之后需要在用户的环境变量中配置如下变量来让应用找到libomp库。

```shell
export LDFLAGS="-L/opt/homebrew/opt/libomp/lib"
export CPPFLAGS="-I/opt/homebrew/opt/libomp/include"
```

​	配置完成之后，运行程序就出现本文开始的异常。在/usr/local/opt/libomp/路径下的确找不到libomp库，此时会将/opt/homebrew/opt/libomp目录下的内容软件到/usr/local/opt/libomp/路径下，在运行程序就会发现该库无法兼容x86架构的libomp库。

​	其实一般而言希望原本在基于英特尔芯片下的Mac运行的Python程序迁移到基于M2芯片下的Mac是可以运行的。那么问题是通过brew下载的库自动是M2芯片的依赖。所以我们需要重新安装给予x86的brew工具。

# 步骤

​	【注意】如果在M芯片的MacOS已经安装过brew工具谨慎重装，因为它会覆盖原来的配置文件~/.zshrc，一定要记得保存自己的配置文件。这里我们重装。

​	【步骤一】配置罗赛塔2的环境。你可以理解它是能够让基于M系列芯片的应用转换成x86芯片的转换器。如果不安装罗赛塔组则不能安装默认为Intel芯片的库，否则后面不能使用类似`arch -x86_64 ...`的命令。

```shell
/usr/sbin/softwareupdate --install-rosetta --agree-to-license
```

​	【步骤二】重新安装brew工具。这里注意我们安装一个国内版本的brew，而非Mac官方的brew。

```shell
arch -x86_64 /bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)"
```

​	安装程序会引导brew的安装直至安装完成，这里注意会让你选择brew下载源，默认提供5到6种，推荐选择中科大或者清华源。

​	【步骤三】下载x86架构下安装libomp

```shell
arch -x86_64 brew install libomp
```

​	这里注意`arch -x86_64`命令不能丢，如果直接`brew install`会有如下异常：

```
Error: Cannot install in Homebrew on ARM processor in Intel default prefix (/usr/local)!
Please create a new installation in /opt/homebrew using one of the
"Alternative Installs" from:
  https://docs.brew.sh/Installation
You can migrate your previously installed formula list with:
  brew bundle dump
```

​	因为我们现在用于的是基于x86架构下brew工具，原来的基于M系列brew工具默认在缺省环境变量下不在生效，如果需要使用它则需要家brew全路径执行即可。在基于英特尔下Mac中brew安装路径是在/usr/local下；而基于M系列下的Mac中brew安装路径是在/opt下。

​	如果想区分两个架构下brew可以带上全命令：

```shell
> /opt/homebrew/bin/brew list

> /usr/local/Homebrew/bin/brew list
```

​	此时需要重新配置libomp库的环境变量：

```shell
export LDFLAGS="-L/usr/local/opt/libomp/lib"
export CPPFLAGS="-I/usr/local/opt/libomp/include"
```

​	【步骤四】在python虚拟环境下重新安装lightgbm库运行对应的程序进行验证。

```shell
pip install lightgbm
```

# 参考资料

​	[m1芯片的mac安装Lightgbm库（亲测有效）](https://blog.csdn.net/weixin_45277161/article/details/131236627)

​	[Using x86 libraries and OpenMP on macOS arm64 architecture](https://stackoverflow.com/questions/67386941/using-x86-libraries-and-openmp-on-macos-arm64-architecture)
