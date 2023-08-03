# 构建Python环境

​		**步骤一**：安装conda。参考：[Install-on-MacOS](../../09.ai/01.Anaconda/01-Install-on-MacOS.md)

​		**步骤二**：安装pip。参考：[Install-pip](../../09.ai/02.pip/01-Install.md)

​		**步骤三**：创建python虚拟环境。比如：创建一个python 3.7的环境：

```shell
conda create -n dev python=3.7
```

# 构建Python IDE集成开发环境（MacOS）

​		推荐下载PyCharm社区版本，因为免费，官方链接如下：https://www.jetbrains.com/pycharm/download/?section=mac

​		如果Apple M1芯片点击.dmg(Apple Silicon)。下载之后双击即可启动IDE。

​		在通过PyCharm创建Python项目之前，需要根据需求创建当前虚拟环境，比如：我们希望有一个python3.7的环境，假设环境的名称为dev：

```shell
conda create -n dev python=3.7
```

​		虚拟环境创建完毕之后，则可以通过PyCharm创建Python项目，点击【New Project】之后在面板的【Location】填写Python项目的路径，勾选【Previously configured interpreter】-> 【Add Interpreter】添加Python解释器弹出【Add Python Interpreter】面板。

​		因为希望IDE使用Conda所创建的虚拟环境，所以选择【Conda Enviroment】。然后在【Conda Executable】选择conda的二进制命令的所在路径，一般会在Anaconda家目录的bin目录的conda。接着点击【Load Enviroment】勾选【Use existing enviroment】->在【Use existing enviroment】选择所创建的Python虚拟环境，点击【OK】->【Create】即可。

​		在生成的Python项目下会自动创建一个main.py脚本，大致如下：

```python
import platform

def print_hi(name):
    print(f'Hi, {name}')


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    print("Python 版本号：" + platform.python_version())
    print_hi('PyCharm')
```

​		选择`if __name__ == '__main__':`左侧的小三角，点击【Run 'main'】即可运行，运行结果如下：

```shell
Python 版本号：3.7.12
Hi, PyCharm
```

​		这里可以看到打印的Python版本和之前通过conda创建的虚拟环境中的python是一致的，即可证明创建Python项目完成。

