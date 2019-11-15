# Android架构

## Android系统架构

[Android 系统架构]: http://dy.163.com/v2/article/detail/ECGDON2O0511FQO9.html

<img src="https://raw.githubusercontent.com/autowanglei/autowanglei.github.io/master/_posts/android/Android学习记录/Android系统架构.jpg" alt="Android系统架构图" style="zoom: 50%;" /> 

Android系统启动过程：由Boot Loader引导开机，然后一次进入kernel->HAL->Native&Android Runtime->Framework->App

### Boot Loader

​	系统启动引导程序，主要是检查RAM，初始化硬件参数。

### Linux内核

​	kernel是Android系统的基础，Android虚拟机最终调用linux内核来执行功能。Linux内核的安全机制为Android系统提供保证，也允许硬件厂商为内核开发硬件驱动程序。内核层做初始化进程管理、内存管理、加载驱动等工作。

### Hardware Abstraction Layer

​	硬件抽象层统一规范各硬件厂商的驱动接口，提供给系统库和Android Runtime层。

### Android Runtime和Native Libraries

​	Android运行库和C/C++库。

​	每个应用都在自己的进程中运行，都有自己的虚拟机实例。Android虚拟机通过执行DEX字节码格式文件，在设备上运行多个虚拟机

### Framework

​	系统框架层，提供Android API接口。

### Applications

​	应用程序。

# Android App的设计架构

## 架构的目的

​	 通过设计使程序模块化，做到模块内部高聚合，模块之间低耦合。使开发人员在开发过程中，只需专注一点，提高开发效率。根据工程的量级，做合适的设计，切勿为了架构而架构。

- **解耦**
- **复用**
- **可读性**
- **健壮性**
- **提高并行开发效率**

## MVC设计架构

### MCV简介

![MVC](https://raw.githubusercontent.com/autowanglei/autowanglei.github.io/master/_posts/android/Android学习记录/MVC.png)

​	View层持有Controller，把事件传递给Controller，Controller由此去触发Model层的事件，Model层更新完数据（网络或本地数据）之后触发View层更新数据。

​	用一种界面、逻辑、数据分离的的方法组织代码，在修改界面的同时，不需要修改业务逻辑，降低耦合。

Model层处理数据，业务逻辑等；View层处理界面的显示结果；Controller层起到桥梁的作用，用来控制M层和V层通信，达到分离界面展示和业务逻辑层。

### Android中的MVC

- 视图层（view）

  一般使用XML描述界面，方便引入，便于界面修改。逻辑中与界面对应的id不变化，则不用需改代码，大大增强了代码的可维护性。

- 控制层（controller）

  Android中控制层主要包括activity、fragment等，不要在activity层写逻辑代码，要通过activity传递给model层，activity中不适合做耗时操作（5S），否则程序容易被回收。

- 模型层（model）

  针对业务模型建立数据结构和相关的类，可以理解为Android APP的model，model与view无关，与业务有关。对文件、数据库、网络的操作以及业务的计算操作都应该放到model层。

### MVC代码实例

