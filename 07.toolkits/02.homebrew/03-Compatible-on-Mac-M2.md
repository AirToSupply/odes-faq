# 问题

​	有通常需要在基于M系列（基于arm架构）芯片的MacOS上安装x86系列的程序，虽然在基于arm架构芯片上运行x86架构的依赖库是非常痛苦的，但是有时候在极端情况下不得已而为之。这个时候希望在M2芯片MacOS操作系统下安装brew工具来下载基于x86架构的依赖，同时原生的brew工具也希望能继续使用。

# 步骤

【步骤一】配置**Rosetta 2**。

​	你可以理解它是能够让基于M系列芯片的应用转换成x86芯片的转换器。如果不安装罗赛塔组则不能安装默认为Intel芯片的库，否则后面不能使用类似`arch -x86_64 ...`的命令。

```shell
/usr/sbin/softwareupdate --install-rosetta --agree-to-license
```

【步骤二】安装原生Homebrew。

​	这里的原生Homebrew是指在MacOS M2芯片下正常安装，可参考：[Deploy](./01-Deploy.md) 。

【步骤三】安装x86版本Homebrew。

​	这里注意我们安装一个国内版本的Homebrew，而非Mac官方的brew，因为的确是好用。

```shell
arch -x86_64 /bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)"
```

​	安装程序会引导进行安装直至安装完成，需要注意的是会让选择brew下载源，默认提供5到6种，推荐选择**中科大**或者**清华源**。

【步骤四】配置兼容两种架构的Homebrew。

​	在~/.zshrc配置文件中配置brew重新定义：

```shell
# compatible brew with (arm or x86)
ARM_HOMEBREW_BIN=/opt/homebrew/bin/brew
X86_HOMEBREW_BIN=/usr/local/bin/brew
alias abrew='arch -arm64  $ARM_HOMEBREW_BIN'
alias ibrew='arch -x86_64 $X86_HOMEBREW_BIN'
```

​	如果通过基于arm架构下的brew下载软件包，如下：

```shell
abrew install wget
```

​	如果通过基于x86架构下的brew下载软件包，如下：

```shell
ibrew install wget
```

# 参考资料

​	[Homebrew的多版本（x86和arm）自动切换方案](https://blog.csdn.net/liuqqdo2008/article/details/132679898)
