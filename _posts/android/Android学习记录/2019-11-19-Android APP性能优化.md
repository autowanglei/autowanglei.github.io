# 性能优化

- APP使卡顿

  - 不要在主线程进行网络访问/大文件的IO操作
  -  绘制UI时，尽量减少绘制UI层次；减少不必要的view嵌套 
  -  当我们的布局是用的FrameLayout的时候，我们可以把它改成merge,可以避免自己的帧布局和系统的ContentFrameLayout帧布局重叠造成重复计算(measure和layout) 
  -  在view层级相同的情况下，尽量使用 LinerLayout而不是RelativeLayout；因为RelativeLayout在测量的时候会测量二次，而LinerLayout测量一次 。
  -  删除控件中无用的属性; 
  -  布局复用 
  - 尽量减少View的刷新

- 要省电，省流量；

- 内存优化

- 要稳定，不闪退(减少闪退，ANR率)；

  - 提高代码质量。比如开发期间的代码审核，看些代码设计逻辑，业务合理性等。
  - Crash监控，记录或上传崩溃信息，即使处理出现的问题。

- APP包尽量要小

  **res资源优化**
   （1）只使用一套图片，使用高分辨率的图片。
   （2）UI设计时，对图片进行无损压缩。
   （3）删除无用的资源

   **代码优化**
   （1）实现功能模块的逻辑简化
   （2）删除无用的代码。
   （3）移除无用的依赖库。

   **代码混淆。**
   使用proGuard 代码混淆器工具，它包括压缩、优化、混淆等功能。

# 内存优化总体大纲

APP内存优化其实是优化程序的内存使用、空间占用，从以下几个方面入手

1. 内存泄露
2. 内存抖动
3. 图片Bitmap相关
4. 代码质量 & 数量

- 内存泄漏

  - 根本原因

    内存泄漏是指本该回收的对象，因为某些原因不能被回收，从而继续停留在内存中。

    根本原因是持有者的什么周期>被引用者的生命周期。

  - 常见内存泄漏

    - 集合类

      集合类添加元素后，仍引用着集合元素对象，导致该集合元素对象不可被回收，从而致内存泄漏。

      **解决方法**：集合类使用完毕后，清空集合，集合类置为null。

    - static关键字修饰的成员变量

      被Static 关键字修饰的成员变量的生命周期 = 应用程序的生命周期，若使被Static关键字修饰的成员变量引用耗费资源过多的实例（如Context），当引用实例需结束生命周期销毁时，会因静态变量的持有而无法被回收，从而出现内存泄露

      **解决方法**：1.尽量避免Static成员变量引用资源耗费过多的实例（如 Context），ApplicationContext

      ​					2.使用弱引用（WeakReference）代替强引用持有实例

    - 非静态内部类/匿名类

      非静态内部类/匿名类默认持有外部变量的引用，分三种情况：

      1. 非静态内部类实例
      2. 多线程（AsyncTask、实现Runnable接口、继承Thread类）
      3. 消息传递机制（Handler）

      以上三种情况都涉及到静态内部类问题，统一解决方案：

      - 将非静态内部类设置为静态内部类（静态内部类默认不持有外部类的引用）
      - 该内部类抽取出来封装成一个单例
      - 若需使用Context，建议使用 Application 的 Context

      针对多线程：外部对象生命周期结束时，强制停止线程任务。

      针对Handler：外部对象生命周期结束时，清空消息队列或者是静态内部类+弱引用。

    - 资源对象使用后未关闭

      对于资源的使用（如 广播BraodcastReceiver、文件流File、图片资源Bitmap等），若在Activity销毁时无及时关闭 / 注销这些资源，则这些资源将不会被回收，从而造成内存泄漏。即使注销、关闭资源可以解决此类问题。

- 图片Bitmap相关

  Android系统给每个应用分配的内存是有限的，而图片资源非常消耗内存（即Bitmap），对Bitmap的使用和内存管理稍有不慎就会引发内存溢出，最终导致OOM。

  ![bitmap优化总结](https://raw.githubusercontent.com/autowanglei/autowanglei.github.io/master/_posts/android/Android学习记录/bitmap优化总结.jpg)

  

  ## 代码质量&数量

  ### 优化原因

  ​	代码本身的质量（如数据结构、数据类型等）和数量（代码量的大小），可能会导致大量的内存问题，如占用内存大、内存利用率低。

  ### 优化方案

  - 减少不必要类、对象和第三方库。

  - 使用占用内存小的数据类型，避免使用枚举，比int多使用两倍的内存。

  - 数据引用对象

    根据不同的场景，选用不同数据引用类型（强、软、弱）

  ​      强引用：不希望被垃圾回收器回收。

  ​	  软引用：缓存机制。

  ​      弱引用：防护内存泄漏，保证内存被虚拟机回收。

- 内存抖动

  频繁创建大量、临时的小对象，会使程序频繁的分配内存，GC频繁回收内存，导致内存抖动。

  内存抖动会引起内存碎片化，分配内存时，虽然总体上还有剩余内存分配，但由于内存不连续，导致不能分配，系统则视为内存不够，故导致OOM。

  优化方案：尽量避免频繁创建大量、临时的小内存。

- 代码质量&数量

  - 减少不必要类、对象和第三方库。

  - 使用占用内存小的数据类型，避免使用枚举，比int多使用两倍的内存。

    

# 内存优化

## 定义

 优化处理应用程序的**内存使用、空间占用** 

## 作用

避免因不正确使用内存 & 缺乏管理，从而出现 **内存泄露`（ML）`、内存溢出`（OOM）`、内存空间占用过大** 等问题，最终导致应用程序崩溃（`Crash`） 

## 储备知识：Android 内存管理机制

## 常见的内存问题 & 优化方案

- 常见的内存问题如下
  1. 内存泄露
  2. 内存抖动
  3. 图片`Bitmap`相关
  4. 代码质量 & 数量
- 下面，我将详细分析每项的内存问题 & 给出优化方案

### 内存泄露

#### 内存泄漏根本原因：

内存泄漏是指本该回收的对象，因为某些原因不能被回收，从而继续停留在内存中。

根本原因是持有者的什么周期>被引用者的生命周期。

####  常见内存泄露

- 集合类
- static关键字修饰的成员变量
- 非静态内部类/匿名类
- 资源对象使用后未关闭

#### 优化方案

##### 集合类

- 内存泄露原因
  集合类添加元素后，仍引用着集合元素对象，导致该集合元素对象不可被回收，从而 致内存泄漏

- 实例演示

  ```java
  // 通过 循环申请Object 对象 & 将申请的对象逐个放入到集合List
  List<Object> objectList = new ArrayList<>();        
         for (int i = 0; i < 10; i++) {
              Object o = new Object();
              objectList.add(o);
              o = null;
          }
  // 虽释放了集合元素引用的本身：o=null）
  // 但集合List 仍然引用该对象，故垃圾回收器GC 依然不可回收该对象
  
  ```

-  解决方案
  集合类添加集合元素对象后，在使用后必须从集合中删除

   由于1个集合中有许多元素，故最简单的方法 = 清空集合对象 & 设置为`null` 

  ```java
   // 释放objectList
   objectList.clear();
   objectList=null;
  
  ```

#####  Static 关键字修饰的成员变量

- 储备知识
  被Static 关键字修饰的成员变量的生命周期 = 应用程序的生命周期

- 泄露原因
  若使被Static关键字修饰的成员变量引用耗费资源过多的实例（如Context），则容易出现该成员变量的生命周期 > 引用实例生命周期的情况，当引用实例需结束生命周期销毁时，会因静态变量的持有而无法被回收，从而出现内存泄露

-  实例讲解 

  ```java
  public class ClassName {
   // 定义1个静态变量
   private static Context mContext;
   //...
  // 引用的是Activity的context
   mContext = context; 
  
  // 当Activity需销毁时，由于mContext = 静态 & 生命周期 = 应用程序的生命周期，故 Activity无法被回收，从而出现内存泄露
  
  }
  ```

- 解决方案

1. 尽量避免Static成员变量引用资源耗费过多的实例（如 `Context`）

   若需引用 `Context`，则尽量使用`Applicaiton`的`Context`

2. 使用弱引用`（WeakReference）` 代替强引用持有实例

**注：静态成员变量有个非常典型的例子 = 单例模式**

- 储备知识
  单例模式 由于其静态特性，其生命周期的长度 = 应用程序的生命周期

- 泄露原因
  若1个对象已不需再使用 而单例对象还持有该对象的引用，那么该对象将不能被正常回收 从而 导致内存泄漏

- 实例演示

  ```java
  // 创建单例时，需传入一个Context
  // 若传入的是Activity的Context，此时单例 则持有该Activity的引用
  // 由于单例一直持有该Activity的引用（直到整个应用生命周期结束），即使该Activity退出，该Activity的内存也不会被回收
  // 特别是一些庞大的Activity，此处非常容易导致OOM
  
  public class SingleInstanceClass {    
      private static SingleInstanceClass instance;    
      private Context mContext;    
      private SingleInstanceClass(Context context) {        
          this.mContext = context; // 传递的是Activity的context
      }  
  
      public SingleInstanceClass getInstance(Context context) {        
          if (instance == null) {
              instance = new SingleInstanceClass(context);
          }        
          return instance;
      }
  }
  ```

- 解决方案
  单例模式引用的对象的生命周期 = 应用的生命周期
  如上述实例，应传递Application的Context，因Application的生命周期 = 整个应用的生命周期

  ```java
  public class SingleInstanceClass {    
      private static SingleInstanceClass instance;    
      private Context mContext;    
      private SingleInstanceClass(Context context) {        
          this.mContext = context.getApplicationContext(); // 传递的是Application 的context
      }    
  
      public SingleInstanceClass getInstance(Context context) {        
          if (instance == null) {
              instance = new SingleInstanceClass(context);
          }        
          return instance;
      }
  
  }
  ```

##### 非静态内部类 / 匿名类

- 储备知识
  非静态内部类 / 匿名类默认持有外部类的引用；而静态内部类则不会
- 常见情况
  3种，分别是：非静态内部类的实例 = 静态变量、多线程、消息传递机制（Handler）

##### 非静态内部类的实例 = 静态

- 泄露原因
  若非静态内部类所创建的实例 = 静态变量（其生命周期 = 应用的生命周期），会因非静态内部类默认持有外部类的引用而导致外部类无法释放，最终造成内存泄露。
  
- 实例演示

  ```java
  /* 背景：
     a. 在启动频繁的Activity中，为了避免重复创建相同的数据资源，会在Activity内部创建一个非静态内部类的单例
     b. 每次启动Activity时都会使用该单例的数据*/
  
  public class TestActivity extends AppCompatActivity {  
      
      // 非静态内部类的实例的引用
      // 注：设置为静态  
      public static InnerClass innerClass = null; 
     
      @Override
      protected void onCreate(@Nullable Bundle savedInstanceState) {        
          super.onCreate(savedInstanceState);   
  
          // 保证非静态内部类的实例只有1个
          if (innerClass == null)
              innerClass = new InnerClass();
      }
  
      // 非静态内部类的定义    
      private class InnerClass {        
          //...
      }
  }
  
  // 造成内存泄露的原因：
  	// a. 当TestActivity销毁时，因非静态内部类单例的引用（innerClass）的生命周期 = 应用App的生命周期、持有外部类TestActivity的引用
  	// b. 故 TestActivity无法被GC回收，从而导致内存泄漏
  
  ```

- 解决方案
  - 将非静态内部类设置为静态内部类（静态内部类默认不持有外部类的引用）
  - 该内部类抽取出来封装成一个单例
  - 若需使用Context，建议使用 Application 的 Context

##### 多线程：AsyncTask、实现Runnable接口、继承Thread类

- 储备知识
  多线程的使用方法 = 非静态内部类 / 匿名类；即线程类属于非静态内部类 / 匿名类

- 泄露原因
  当工作线程正在处理任务 & 外部类需销毁时，由工作线程实例持有外部类引用，将使得外部类无法被垃圾回收器（GC）回收，从而造成内存泄露。
  
- 优化方案
  
  - 静态内部类实现多线程
  - 外部对象生命周期结束时，停止线程任务。

- 实例演示

  ```java
     /** 
       * 方式1：新建Thread子类（内部类）
       */  
          public class MainActivity extends AppCompatActivity {
  
          public static final String TAG = "carson：";
          @Override
          public void onCreate(Bundle savedInstanceState) {
              super.onCreate(savedInstanceState);
              setContentView(R.layout.activity_main);
  
              // 通过创建的内部类 实现多线程
              new MyThread().start();
  
          }
          // 自定义的Thread子类
          private class MyThread extends Thread{
              @Override
              public void run() {
                  try {
                      Thread.sleep(5000);
                      Log.d(TAG, "执行了多线程");
                  } catch (InterruptedException e) {
                      e.printStackTrace();
                  }
              }
          }
      }
  
     /** 
       * 方式2：匿名Thread内部类
       */ 
       public class MainActivity extends AppCompatActivity {
  
      public static final String TAG = "carson：";
  
      @Override
      public void onCreate(Bundle savedInstanceState) {
          super.onCreate(savedInstanceState);
          setContentView(R.layout.activity_main);
  
          // 通过匿名内部类 实现多线程
          new Thread() {
              @Override
              public void run() {
                  try {
                      Thread.sleep(5000);
                      Log.d(TAG, "执行了多线程");
                  } catch (InterruptedException e) {
                      e.printStackTrace();
                  }
  
              }
          }.start();
      }
  }
  
  
  /** 
    * 分析：内存泄露原因
    */ 
    // 工作线程Thread类属于非静态内部类 / 匿名内部类，运行时默认持有外部类的引用
    // 当工作线程运行时，若外部类MainActivity需销毁
    // 由于此时工作线程类实例持有外部类的引用，将使得外部类无法被垃圾回收器（GC）回收，从而造成 内存泄露
  ```

- 解决方案
  从上面可看出，造成内存泄露的原因有2个关键条件：

  1. 存在 ”工作线程实例持有外部类引用“ 的引用关系
2. 工作线程实例的生命周期 > 外部类的生命周期，即工作线程仍在运行而外部类需销毁



**解决方案的思路 = 使得上述任1条件不成立即可。**

```java
// 共有2个解决方案：静态内部类 & 当外部类结束生命周期时，强制结束线程
// 具体描述如下

   /** 
     * 解决方式1：静态内部类
     * 原理：静态内部类默认不持有外部类的引用，从而使得 “工作线程实例持有外部类引用” 的引用关系不复存在
     * 具体实现：将Thread的子类设置成静态内部类
     */  
        public class MainActivity extends AppCompatActivity {

        public static final String TAG = "carson：";
        @Override
        public void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            setContentView(R.layout.activity_main);

            // 通过创建的内部类 实现多线程
            new MyThread().start();

        }
        // 分析1：自定义Thread子类
        // 设置为：静态内部类
        private static class MyThread extends Thread{
            @Override
            public void run() {
                try {
                    Thread.sleep(5000);
                    Log.d(TAG, "执行了多线程");
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }
    }

   /** 
     * 解决方案2：当外部类结束生命周期时，强制结束线程
     * 原理：使得工作线程实例的生命周期与外部类的生命周期 同步
     * 具体实现：当外部类（此处以Activity为例） 结束生命周期时（此时系统会调用onDestroy（）），强制结束线程（调用stop（））
     */ 
     @Override
    protected void onDestroy() {
        super.onDestroy();
        Thread.stop();
        // 外部类Activity生命周期结束时，强制结束线程
    }
```

##### 消息传递机制：Handler

###### 问题描述

-  Handler的一般用法 = 新建Handler子类（内部类）、匿名Handler内部类 

  ```java
     /** 
       * 方式1：新建Handler子类（内部类）
       */  
      public class MainActivity extends AppCompatActivity {
  
              public static final String TAG = "carson：";
              private Handler showhandler;
  
              // 主线程创建时便自动创建Looper & 对应的MessageQueue
              // 之后执行Loop()进入消息循环
              @Override
              protected void onCreate(Bundle savedInstanceState) {
                  super.onCreate(savedInstanceState);
                  setContentView(R.layout.activity_main);
  
                  //1. 实例化自定义的Handler类对象->>分析1
                  //注：此处并无指定Looper，故自动绑定当前线程(主线程)的Looper、MessageQueue
                  showhandler = new FHandler();
  
                  // 2. 启动子线程1
                  new Thread() {
                      @Override
                      public void run() {
                          try {
                              Thread.sleep(1000);
                          } catch (InterruptedException e) {
                              e.printStackTrace();
                          }
                          // a. 定义要发送的消息
                          Message msg = Message.obtain();
                          msg.what = 1;// 消息标识
                          msg.obj = "AA";// 消息存放
                          // b. 传入主线程的Handler & 向其MessageQueue发送消息
                          showhandler.sendMessage(msg);
                      }
                  }.start();
  
                  // 3. 启动子线程2
                  new Thread() {
                      @Override
                      public void run() {
                          try {
                              Thread.sleep(5000);
                          } catch (InterruptedException e) {
                              e.printStackTrace();
                          }
                          // a. 定义要发送的消息
                          Message msg = Message.obtain();
                          msg.what = 2;// 消息标识
                          msg.obj = "BB";// 消息存放
                          // b. 传入主线程的Handler & 向其MessageQueue发送消息
                          showhandler.sendMessage(msg);
                      }
                  }.start();
  
              }
  
              // 分析1：自定义Handler子类
              class FHandler extends Handler {
  
                  // 通过复写handlerMessage() 从而确定更新UI的操作
                  @Override
                  public void handleMessage(Message msg) {
                      switch (msg.what) {
                          case 1:
                              Log.d(TAG, "收到线程1的消息");
                              break;
                          case 2:
                              Log.d(TAG, " 收到线程2的消息");
                              break;
  
  
                      }
                  }
              }
          }
  
     /** 
       * 方式2：匿名Handler内部类
       */ 
       public class MainActivity extends AppCompatActivity {
  
          public static final String TAG = "carson：";
          private Handler showhandler;
  
          // 主线程创建时便自动创建Looper & 对应的MessageQueue
          // 之后执行Loop()进入消息循环
          @Override
          protected void onCreate(Bundle savedInstanceState) {
              super.onCreate(savedInstanceState);
              setContentView(R.layout.activity_main);
  
              //1. 通过匿名内部类实例化的Handler类对象
              //注：此处并无指定Looper，故自动绑定当前线程(主线程)的Looper、MessageQueue
              showhandler = new  Handler(){
                  // 通过复写handlerMessage()从而确定更新UI的操作
                  @Override
                  public void handleMessage(Message msg) {
                          switch (msg.what) {
                              case 1:
                                  Log.d(TAG, "收到线程1的消息");
                                  break;
                              case 2:
                                  Log.d(TAG, " 收到线程2的消息");
                                  break;
                          }
                      }
              };
  
              // 2. 启动子线程1
              new Thread() {
                  @Override
                  public void run() {
                      try {
                          Thread.sleep(1000);
                      } catch (InterruptedException e) {
                          e.printStackTrace();
                      }
                      // a. 定义要发送的消息
                      Message msg = Message.obtain();
                      msg.what = 1;// 消息标识
                      msg.obj = "AA";// 消息存放
                      // b. 传入主线程的Handler & 向其MessageQueue发送消息
                      showhandler.sendMessage(msg);
                  }
              }.start();
  
              // 3. 启动子线程2
              new Thread() {
                  @Override
                  public void run() {
                      try {
                          Thread.sleep(5000);
                      } catch (InterruptedException e) {
                          e.printStackTrace();
                      }
                      // a. 定义要发送的消息
                      Message msg = Message.obtain();
                      msg.what = 2;// 消息标识
                      msg.obj = "BB";// 消息存放
                      // b. 传入主线程的Handler & 向其MessageQueue发送消息
                      showhandler.sendMessage(msg);
                  }
              }.start();
  
          }
  }
  ```

- 上述例子虽可运行成功，但代码会出现严重警告：

> 1. 警告的原因 = 该`Handler`类由于无设置为 静态类，从而**导致了内存泄露**
> 2. 最终的内存泄露发生在`Handler`类的外部类：`MainActivity`类

###### 原因讲解

1. **储备知识**

   - 主线程的`Looper`对象的生命周期 = 该应用程序的生命周期
   - 在`Java`中，**非静态内部类** & **匿名内部类**都默认持有外部类的引用

2. **泄露原因描述**

   从上述示例代码可知：

- 上述的`Handler`实例的消息队列有2个分别来自线程1、2的消息（分别 为延迟`1s`、`6s`）
- **在`Handler`消息队列 还有未处理的消息 / 正在处理消息时，消息队列中的`Message`持有`Handler`实例的引用**
- 由于`Handler` = 非静态内部类 / 匿名内部类（2种使用方式），故又默认持有外部类的引用（即`MainActivity`实例），引用关系如下图

> 上述的引用关系会一直保持，直到`Handler`消息队列中的所有消息被处理完毕

![img](https://upload-images.jianshu.io/upload_images/944365-05300414b4aeaa8e.png?imageMogr2/auto-orient/strip|imageView2/2/w/470/format/webp)

- 在`Handler`消息队列 还有未处理的消息 / 正在处理消息时，此时若需销毁外部类`MainActivity`，但由于上述引用关系，垃圾回收器`（GC）`无法回收`MainActivity`，从而造成内存泄漏。如下图：

![img](https:////upload-images.jianshu.io/upload_images/944365-fb0840209b472094.png?imageMogr2/auto-orient/strip|imageView2/2/w/770/format/webp)

3. **总结**

- 当`Handler`消息队列 还有未处理的消息 / 正在处理消息时，存在引用关系： **“未被处理 / 正处理的消息 -> `Handler`实例 -> 外部类”** 
- 若出现 `Handler`的生命周期 > 外部类的生命周期 时（**即 `Handler`消息队列 还有未处理的消息 / 正在处理消息 而 外部类需销毁时**），将使得外部类无法被垃圾回收器`（GC）`回收，从而造成 内存泄露

###### 解决方案

从上面可看出，造成内存泄露的原因有2个关键条件：

1. 存在“未被处理 / 正处理的消息 -> `Handler`实例 -> 外部类” 的引用关系
2.  `Handler`的生命周期 > 外部类的生命周期

> 即 `Handler`消息队列 还有未处理的消息 / 正在处理消息 而 外部类需销毁

**解决方案的思路 = 使得上述任1条件不成立 即可。**

**解决方案1：静态内部类+弱引用**

- 原理
   静态内部类不默认持有外部类的引用，从而使得 “未被处理 / 正处理的消息 -> `Handler`实例 -> 外部类” 的引用关系 的引用关系 不复存在。
- 具体方案
   将`Handler`的子类设置成 静态内部类

> - 同时，还可加上 **使用WeakReference弱引用持有Activity实例** 
> - 原因：弱引用的对象拥有短暂的生命周期。在垃圾回收器线程扫描时，一旦发现了只具有弱引用的对象，不管当前内存空间足够与否，都会回收它的内存

- 解决代码

  ```java
  public class MainActivity extends AppCompatActivity {
  
      public static final String TAG = "carson：";
      private Handler showhandler;
  
      // 主线程创建时便自动创建Looper & 对应的MessageQueue
      // 之后执行Loop()进入消息循环
      @Override
      protected void onCreate(Bundle savedInstanceState) {
          super.onCreate(savedInstanceState);
          setContentView(R.layout.activity_main);
  
          //1. 实例化自定义的Handler类对象->>分析1
          //注：
              // a. 此处并无指定Looper，故自动绑定当前线程(主线程)的Looper、MessageQueue；
              // b. 定义时需传入持有的Activity实例（弱引用）
          showhandler = new FHandler(this);
  
          // 2. 启动子线程1
          new Thread() {
              @Override
              public void run() {
                  try {
                      Thread.sleep(1000);
                  } catch (InterruptedException e) {
                      e.printStackTrace();
                  }
                  // a. 定义要发送的消息
                  Message msg = Message.obtain();
                  msg.what = 1;// 消息标识
                  msg.obj = "AA";// 消息存放
                  // b. 传入主线程的Handler & 向其MessageQueue发送消息
                  showhandler.sendMessage(msg);
              }
          }.start();
  
          // 3. 启动子线程2
          new Thread() {
              @Override
              public void run() {
                  try {
                      Thread.sleep(5000);
                  } catch (InterruptedException e) {
                      e.printStackTrace();
                  }
                  // a. 定义要发送的消息
                  Message msg = Message.obtain();
                  msg.what = 2;// 消息标识
                  msg.obj = "BB";// 消息存放
                  // b. 传入主线程的Handler & 向其MessageQueue发送消息
                  showhandler.sendMessage(msg);
              }
          }.start();
  
      }
  
      // 分析1：自定义Handler子类
      // 设置为：静态内部类
      private static class FHandler extends Handler{
  
          // 定义 弱引用实例
          private WeakReference<Activity> reference;
  
          // 在构造方法中传入需持有的Activity实例
          public FHandler(Activity activity) {
              // 使用WeakReference弱引用持有Activity实例
              reference = new WeakReference<Activity>(activity); }
  
          // 通过复写handlerMessage() 从而确定更新UI的操作
          @Override
          public void handleMessage(Message msg) {
              switch (msg.what) {
                  case 1:
                      Log.d(TAG, "收到线程1的消息");
                      break;
                  case 2:
                      Log.d(TAG, " 收到线程2的消息");
                      break;
  
  
              }
          }
      }
  }
  ```

  **解决方案2：当外部类结束生命周期时，清空Handler内消息队列**

  - 原理
     不仅使得 “未被处理 / 正处理的消息 -> `Handler`实例 -> 外部类” 的引用关系 不复存在，同时 使得  `Handler`的生命周期（即 消息存在的时期） 与 外部类的生命周期 同步

  - 具体方案
     当 外部类（此处以`Activity`为例） 结束生命周期时（此时系统会调用`onDestroy（）`），清除 `Handler`消息队列里的所有消息（调用`removeCallbacksAndMessages(null)`）

  - 具体代码

    ```java
    @Override
        protected void onDestroy() {
            super.onDestroy();
            mHandler.removeCallbacksAndMessages(null);
            // 外部类Activity生命周期结束时，同时清空消息队列 & 结束Handler生命周期
        }
    ```

###### 使用建议

为了保证Handler中消息队列中的所有消息都能被执行，此处推荐使用解决方案1解决内存泄露问题，即 **静态内部类 + 弱引用的方式**

##### 资源对象使用后未关闭

- 泄露原因
  对于资源的使用（如 广播BraodcastReceiver、文件流File、数据库游标Cursor、图片资源Bitmap等），若在Activity销毁时无及时关闭 / 注销这些资源，则这些资源将不会被回收，从而造成内存泄漏

- 解决方案
  在Activity销毁时 及时关闭 / 注销资源

  ```java
  // 对于 广播BraodcastReceiver：注销注册
  unregisterReceiver()
  
  // 对于 文件流File：关闭流
  InputStream / OutputStream.close()
  
  // 对于数据库游标cursor：使用后关闭游标
  cursor.close（）
  
  // 对于 图片资源Bitmap：Android分配给图片的内存只有8M，若1个Bitmap对象占内存较多，当它不再被使用时，应调用recycle()回收此对象的像素所占用的内存；最后再赋为null 
  Bitmap.recycle()；
  Bitmap = null;
  
  // 对于动画（属性动画）
  // 将动画设置成无限循环播放repeatCount = “infinite”后
  // 在Activity退出时记得停止动画
  ```

### 图片资源Bitmap相关

#### 优化原因

Android系统给每个应用分配的内存是有限的，而图片资源非常消耗内存（即Bitmap），对Bitmap的使用和内存管理稍有不慎就会引发内存溢出，最终导致OOM。

#### 优化方向

**使用完毕后释放资源、根据分辨率适配缩放图片、根据需求选择合适的解码方式、设置图片缓存**

- 使用完毕后释放图片资源

  - 优化原因

    使用完毕后若不释放图片资源，容易造成**内存泄露，从而导致内存溢出** 

  -  优化方案 

    a. 在 `Android2.3.3（API 10）`前，调用 `Bitmap.recycle()`方法
    b. 在 `Android2.3.3（API 10）`后，采用软引用`（SoftReference）` 

  -  具体描述
    在 `Android2.3.3（API 10）`前、后，Bitmap对象 & 其像素数据 的存储位置不同，从而导致释放图片资源的方式不同。

- 根据分辨率适配&缩放图片

  - 优化原因

     若 `Bitmap` 与 当前设备的分辨率不匹配，则会拉伸`Bitmap`，而`Bitmap`分辨率增加后，所占用的内存也会相应增加 。

  - 优化方案

    1. 设置多套资源图片（设置支持最大分辨率的一套资源图片），将图片放到不同的资源文件夹中。
    2. BitmapFacyory.decodeResource()，对bitmap根据当前设备分辨率进行缩放适配，在占用最小内存的前提下，达到最佳显示效果。
    3. BitmapFactory.inSampleSize，设置图片缩放比例，避免不必要的大图载入

- 按需选择合适的解码方式

  - 优化原因

    不同的图片解码方式对应的内存占用大小相差很大。

    ![解码方式](https://raw.githubusercontent.com/autowanglei/autowanglei.github.io/master/_posts/android/Android学习记录/bitmap解码方式.jpg)

  - 优化方案

     根据需求选择合适的解码方式：

    1. 使用参数：BitmapFactory.inPreferredConfig 设置
    2. 默认使用解码方式：ARGB_8888

- 设置图片缓存

  - 优化原因
    重复加载图片资源耗费太多资源（`CPU`、内存 & 流量）

  - 优化方案

    ![bitmap缓存](https://raw.githubusercontent.com/autowanglei/autowanglei.github.io/master/_posts/android/Android学习记录/bitmap缓存.jpg)

#### 总结

![bitmap优化总结](https://raw.githubusercontent.com/autowanglei/autowanglei.github.io/master/_posts/android/Android学习记录/bitmap优化总结.jpg)

### 内存抖动

#### 简介

- 定义

  内存大小不断浮动

- 原因

  程序频繁的分配内存，GC频繁回收内存。

  深层次原因：大量、临时的小对象频繁创建

- 导致的后果

  内存碎片化，分配内存时，虽然总体上还有剩余内存分配，但由于内存不连续，导致不能分配，系统则视为内存不够，故导致OOM。

#### 优化方案

尽量避免频繁创建大量、临时的小内存。

### 代码质量&数量

#### 优化原因

​	代码本身的质量（如数据结构、数据类型等）和数量（代码量的大小），可能会导致大量的内存问题，如占用内存大、内存利用率低。

#### 优化方案

- 减少不必要类、对象和第三方库。

- 使用占用内存小的数据类型，避免使用枚举，比int多使用两倍的内存。

- 数据引用对象

  根据不同的场景，选用不同数据引用类型（强、软、弱）

​      强引用：不希望被垃圾回收器回收。

​	  软引用：缓存机制。

​      弱引用：防护内存泄漏，保证内存被虚拟机回收。

# 弱引用软引用

- WeakReference

   WeakReference<T>：弱引用-->随时可能会被垃圾回收器回收，不一定要等到虚拟机内存不足时才强制回收。

  ```
   WeakReference sr = new` `WeakReference(new User());
  ```

  防止内存泄漏，要保证内存被虚拟机回收。

- SoftReference

   SoftReference<T>：软引用-->当虚拟机内存不足时，将会回收它指向的对象。

  ```java
  SoftReference<Drawable> softReference = mImageCache.get(imageUrl);  
  ```

   多用作来实现缓存机制(cache) 。