## 修改包名


1. 如下图去掉Compat Empty Middle packages的勾：
![](http://i.imgur.com/cEY9joL.png)



1. studio 代码包结构目录编程如下：

![](http://i.imgur.com/kbnpt8w.png)




右击想要修改包名的包——Refactor——Rename，即可修改包名。

## 使用本地gradle

使用本地gradle可解决长时间gradle build run的问题。下载grdle的前提下（可参照[该文档下载](http://anforen.com/wp/2016/08/dev_install_andorid_studio_gradle_eclipse/)），修改以下配置可解决：


1. C:\Users\你的用户名\.gradle目录下新建一个文件名为gradle.properties的文件，内容为:

	org.gradle.daemon=true
1. 按如下修改studio配置。


    ![](https://i.imgur.com/a2mPFzV.png)


1. 修改工程配置文件

    配置文件(一般位于项目目录\gradle\wrapper\gradle-wrapper.propertes)中distributionUrl一般指向http网址，可以修改为本地gradle的zip包，像这样
    distributionUrl=file\:/C:/Users/ueser/.gradle/wrapper/dists/gradle-4.0-all/ac27o8rbd0ic8ih41or9l32mv/gradle-4.0-all.zip

Android 开发环境配置可参考：[http://anforen.com/wp/2016/08/dev_install_andorid_studio_gradle_eclipse/](http://anforen.com/wp/2016/08/dev_install_andorid_studio_gradle_eclipse/)