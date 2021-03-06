　Linux下大部分系统默认自带python2.x的版本，最常见的是python2.6或python2.7版本，默认的python被系统很多程序所依赖，比如centos下的yum就是python2写的，所以默认版本不要轻易删除，否则会有一些问题，如果需要使用最新的Python3那么我们可以编译安装源码包到独立目录，这和系统默认环境之间是没有任何影响的，python3和python2两个环境并存即可

　　首先去python官网下载python3的源码包，网址：https://www.python.org/

　　进去之后点击导航栏的Downloads，也可以鼠标放到Downloads上弹出菜单选择Source code，表示源码包，这里选择最新版本3.5.1，当然下面也有很多其他历史版本，点进去之后页面下方可以看到下载链接，包括源码包、Mac OSX安装包、Windows安装包

　　![img](https://images2015.cnblogs.com/blog/734555/201602/734555-20160204152757772-228746966.png)

　　这里选择第一个下载即可，下载的就是源码包：Python-3.5.1.tgz，下载好之后上传到linux系统，准备安装

　　python安装之前需要一些必要的模块，比如openssl，readline等，如果没有这些模块后来使用会出现一些问题，比如没有openssl则不支持ssl相关的功能，并且pip3在安装模块的时候会直接报错；没有readline则python交互式界面删除键和方向键都无法正常使用，至于需要什么模块在make完之后python会给出提示，通过提示进行安装即可装全， 另外感谢园友的Glory_Lion的回复；下面是需要提前预装的依赖：

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
yum -y install zlib zlib-devel
yum -y install bzip2 bzip2-devel
yum -y install ncurses ncurses-devel
yum -y install readline readline-devel
yum -y install openssl openssl-devel
yum -y install openssl-static
yum -y install xz lzma xz-devel
yum -y install sqlite sqlite-devel
yum -y install gdbm gdbm-devel
yum -y install tk tk-devel
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

​       安装上面这些python内置模块基本上就比较全了，如果后续有其他必要的模块，会继续补充的，接下来可以安装python了，编译过程中会自动包含这些依赖.

　　释放文件：

```
tar -xvzf Python-3.5.1.tgz
```

　　进入目录：

```
cd Python-3.5.1/
```

​	配置编译，因为上面依赖包是用yum安装而不是自己编译的，所以都是安装在系统默认目录下，因此各种选项不用加默认即可生效：

```
./configure --prefix=/usr/python --enable-shared CFLAGS=-fPIC  --with-ssl
```

​      补充一下：这里加上--enable-shared和-fPIC之后可以将python3的动态链接库编译出来，默认情况编译完lib下面只有python3.xm.a这样的文件，python本身可以正常使用，但是如果编译第三方库需要python接口的比如caffe等，则会报错；所以这里建议按照上面的方式配置



\#修改Setup文件
vi /usr/software/Python-2.7.5/Modules/Setup
\#修改结果如下：
\# Socket module helper for socket(2)
_socket socketmodule.c timemodule.c

\# Socket module helper for SSL support; you must comment out the other
\# socket line above, and possibly edit the SSL variable:
\#SSL=/usr/local/ssl
_ssl _ssl.c \
-DUSE_SSL -I$(SSL)/include -I$(SSL)/include/openssl \
-L$(SSL)/lib -lssl -lcrypto



​	接下来编译源码：

```
make
```

　　执行安装：

```
make install
```

　　整个过程大约5-10分钟，安装成功之后，安装目录就在/usr/python

​        #cd /etc/ld.so.conf.d

​	#vim python3.conf

​	将编译后的python/lib地址加入conf文件

​	#ldconfig

　　系统中原来的python在/usr/bin/python，通过ls -l可以看到，python是一个软链接，链接到本目录下的python2.7

　　我们可以不用把这个删除，不对原来默认的环境做任何修改，只新建一个python3的软链接即可，只是需要执行python3代码时python要改成python3，或者python脚本头部解释器要改为#!/usr/bin/python3

　　这里建立有关的软链接如下：

```
ln -s /usr/python/bin/python3 /usr/bin/python3
ln -s /usr/python/bin/pip3 /usr/bin/pip3
```

　　这样就建立好了，以后直接执行python3命令就可以调用python3了，执行pip3可以安装需要的python3模块；另外如果仔细看python安装目录下的bin目录，实际上python3也是个软链接，链接到python3.5.1，这样多次链接也是为了多个版本的管理更加方便，

　　python3新版本的安装就是这些，因为我们之前安装了完整的依赖，所以下面问题不存在了，忽略即可，其中的python readline模块也早已经停止更新了，会出现崩溃问题；这里基础环境都是使用系统的依赖，更稳定.