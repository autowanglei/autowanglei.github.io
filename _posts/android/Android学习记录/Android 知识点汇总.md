# Android四大组件、五大存储、六大布局

## Android四大组件

Activity、Service、Content provider、broadcast receiver 

## 五大存储

- SharePreferences： 

  以键值对形式存储在xml文件中，路径为/data/data/<package name>/shared_prefs

- 文件

   openFileInput 和 openFileOuput 方法读取设备上的文件。

- 网络

- SQLite

   SQLite是Android所带的一个标准的数据库，它支持SQL语句，它是一个轻量级的嵌入式数据库。 

- content provider

  提供接口：

  - query（Uri uri, String[] projection, String selection, String[] selectionArgs,String sortOrder）

    通过Uri进行查询，返回一个Cursor。

  - insert（Uri url, ContentValues values）

    将一组数据插入到Uri 指定的地方。

  - update（Uri uri, ContentValues values, String where, String[] selectionArgs）

    更新Uri指定位置的数据。

  - delete（Uri url, String where, String[] selectionArgs）

    删除指定Uri并且符合一定条件的数据。 

## 六大布局

LinerLayout、RelativeLayout、TabLayout、FrameLayout、GridLayout、AbsoluteLayout

# Activity

## 生命周期

![Activity生命周期](https://raw.githubusercontent.com/autowanglei/autowanglei.github.io/master/_posts/android/Android学习记录/activity生命周期.png)

## Activity启动模式

- 默认启动模式standard

  默认模式，每次启动Activity都会创建新实例，并压入栈顶。

- 栈顶复用模式singleTop

  如果栈顶Activity为我们新要创建的Activity，就不会重复创建新的Activity。

- 栈内复用模式singleTask

  如果task栈内存在目标activity，则将目标activity以上的所有activity弹出栈，目标爱activity至于栈顶，获取焦点。

- 全剧唯一模式singleInstance

  为目标Activity创建一个新的task栈，将目标Activity放入栈，并获取焦点，task栈中有且只有一个activity实例。已存在activity不会创建新的实例，而是将以前创建的实例唤醒。

## Activity启动流程

### 总体流程

- 开始请求Activity

  - Activity.startActivity() 

  - Activity.startActivityForResult()  

    requestCode默认-1，小于0不起作用

  - Instrumentation.execStartActivty()

  - ActivityManagerNative.getDefault().startActivityAsUser() 

  - ActivityManagerProxy.startActivity：

    mRemote.transact(START_ACTIVITY_TRANSACTION, data, reply, 0); 开启Binder通信， 通知system_Server进程, 调用ActivityManagerService的startActivity（）

- System_Server进程接收到启动Activity的请求

  - ActivityManagerService.startActivity() 
  - ActvityiManagerService.startActivityAsUser() 
  - ActivityStackSupervisor.startActivityMayWait() 
  - ActivityStackSupervisor.startActivityLocked() 
  - ActivityStackSupervisor.startActivityUncheckedLocked() 对Activity的启动模式和对应的任务栈进行了判断和处理，然后调用了startActivityLocked的重载方法
  - ActivityStackSupervisor.startActivityLocked() 
  - ActivityStackSupervisor.resumeTopActivitiesLocked() 
  - ActivityStackSupervisor.resumeTopActivityInnerLocked() 

- 执行栈顶Activity的onPause方法

  ActivityStack.startPausingLocked() 
  IApplicationThread.schudulePauseActivity() 
  ActivityThread.sendMessage() 
  ActivityThread.H.sendMessage(); 
  ActivityThread.H.handleMessage() 
  ActivityThread.handlePauseActivity() 
  ActivityThread.performPauseActivity() 
  Activity.performPause() 
  Activity.onPause() 
  ActivityManagerNative.getDefault().activityPaused(token) 
  ActivityManagerService.activityPaused() 
  ActivityStack.activityPausedLocked() 
  ActivityStack.completePauseLocked() 
  ActivityStack.resumeTopActivitiesLocked() 
  ActivityStack.resumeTopActivityLocked() 
  ActivityStack.resumeTopActivityInnerLocked() 
  ActivityStack.startSpecificActivityLocked()

- 启动Activity所属进程

  ActivityManagerService.startProcessLocked() 
  Process.start() 
  ActivityThread.main() 
  ActivityThread.attach() 
  ActivityManagerNative.getDefault().attachApplication() 
  ActivityManagerService.attachApplication() 

- 启动Activity

  ActivityStackSupervisor.attachApplicationLocked() 
  ActivityStackSupervisor.realStartActivityLocked() 
  IApplicationThread.scheduleLauncherActivity() 
  ActivityThread.sendMessage() 
  ActivityThread.H.sendMessage() 
  ActivityThread.H.handleMessage() 
  ActivityThread.handleLauncherActivity() 
  ActivityThread.performLauncherActivity() 
  Instrumentation.callActivityOnCreate() 
  Activity.onCreate() 
  ActivityThread.handleResumeActivity() 
  ActivityThread.performResumeActivity() 
  Activity.performResume() 
  Instrumentation.callActivityOnResume() 
  Activity.onResume() 
  ActivityManagerNative.getDefault().activityResumed(token) 

- 栈顶Activity执行onStop方法

  Looper.myQueue().addIdleHandler(new Idler()) 
  Idler.queueIdle() 
  ActivityManagerNative.getDefault().activityIdle() 
  ActivityManagerService.activityIdle() 
  ActivityStackSupervisor.activityIdleInternalLocked() 
  ActivityStack.stopActivityLocked() 
  IApplicationThread.scheduleStopActivity() 
  ActivityThread.scheduleStopActivity() 
  ActivityThread.sendMessage() 
  ActivityThread.H.sendMessage() 
  ActivityThread.H.handleMessage() 
  ActivityThread.handleStopActivity() 
  ActivityThread.performStopActivityInner() 
  ActivityThread.callCallActivityOnSaveInstanceState() 
  Instrumentation.callActivityOnSaveInstanceState() 
  Activity.performSaveInstanceState() 
  Activity.onSaveInstanceState() 
  Activity.performStop() 
  Instrumentation.callActivityOnStop() 
  Activity.onStop() 

# Fragment

## 特点

- Fragment解决activity切换不流畅的问题，轻量切换。
-  可以从 startActivityForResult 中接收到返回结果。
-  只能在 Activity 保存其状态（用户离开 Activity）之前使用 commit() 提交事务。 对于丢失提交无关紧要的情况，请使用 commitAllowingStateLoss()。

## 生命周期

![fragment生命周期](https://raw.githubusercontent.com/autowanglei/autowanglei.github.io/master/_posts/android/Android学习记录/fragment生命周期.png)

## 与Activity通信

在fragment中定义回调接口，activity实现接口。

# Service

 Service通常位于后台运行，它一般不需要与用户交互，因此Service组件没有图形用户界面。Service分为两种工作状态，一种是启动状态，主要用于执行后台计算；另一种是绑定状态，主要用于与其他组件和service交互。

## 生命周期

![service生命周期](https://raw.githubusercontent.com/autowanglei/autowanglei.github.io/master/_posts/android/Android学习记录/service生命周期.webp)

## 启动方式，区别

-  startService()

  调用startService后，会调用onStartCommond()。当服务处于started状态时，其生命周与其他组件无关，可以在后台无期限运行，即使启动服务的组件已被销毁。因此服务在完成任务后要调用stopSelf()，或者由其他组件调用stopService。

- bindService()

  调用者与服务绑定在一起，调用者一旦停止，服务也就终止。

# BroadcastReceiver

广播接收者，可以使用它对外部事件进行过滤，只对感兴趣的做出响应。广播接收者有两种注册方式，动态注册和静态注册。

# Content Provider

多个应用程序共享数据的组件，通过ContentResolver对象实现对ContentProvider的操作，是不同程序间共享数据的唯一方式；使用URI来唯一标识其数据集，这里的URI以content://作为前缀，表示该数据由ContentProvider来管理 。

 **ContentProvider 和 sql 在实现上有什么区别? **

- ContentProvider 屏蔽了数据存储的细节，内部实现透明化，用户只需关心 uri 即可(是否匹配)
- ContentProvider 能实现不同 app 的数据共享，sql 只能是自己程序才能访问
- Contentprovider 还能增删本地的文件,xml等信息

# View

![View](https://raw.githubusercontent.com/autowanglei/autowanglei.github.io/master/_posts/android/Android学习记录/view.png)

 View 的三大流程均是通过 ViewRoot 来完成的，ViewRoot 对应于 ViewRootImpl 类，他是链接WindowManager 和 DecorView（ activity窗口的根视图 ） 的纽带， 在 ActivityThread 中，当 Activity 对象被创建完毕后，会将 DecorView 添加到 Window 中，同时会创建 ViewRootImpl 对象，并将 ViewRootImpl 对象和 DecorView 建立关联。

 View 的整个绘制流程可以分为以下三个阶段： 

- measure： 是用来测量 View 的宽和高  
- layout： layout 是用来确定 View 在父容器中的放置位置 
- draw：  负责将 View 绘制在屏幕上  

## MeasureSpec

 MeasureSpec表示的是一个32位的整形值，它的高2位表示测量模式SpecMode，低30位表示某种测量模式下的规格大小SpecSize。 

## MotionEvent

 `getX/getY` 返回相对于当前View左上角的坐标，`getRawX/getRawY` 返回相对于屏幕左上角的坐标 

## VelocityTracker

 可用于追踪手指在滑动中的速度 

## GestureDetector

  辅助检测用户的单击、滑动、长按、双击等行为。

 如果是监听滑动相关，建议在 `onTouchEvent` 中实现，如果要监听双击，那么就使用 `GestureDectector` 

## Scroller

 弹性滑动对象，用于实现 View 的弹性滑动，**Scroller** 本身无法让 View 弹性滑动，需要和 View 的 `computeScroll` 方法配合使用。`startScroll` 方法是无法让 View 滑动的，`invalidate` 会导致 View 重绘，重回后会在 `draw` 方法中又会去调用 `computeScroll` 方法，`computeScroll` 方法又会去向 Scroller 获取当前的 scrollX 和 scrollY，然后通过 `scrollTo` 方法实现滑动，接着又调用 `postInvalidate` 方法如此反复。 

## View 的滑动

-  scrollTo/scrollBy 

   适合对 View 内容的滑动。`scrollBy` 实际上也是调用了 `scrollTo` 方法 。

-  使用动画 

  操作简单，主要适用于没有交互的 View 和实现复杂的动画效果。

- 改变布局参数 操作稍微复杂，适用于有交互的 View.

## View 的事件分发

参考 

[深入理解Android事件分发机制]: https://www.jianshu.com/p/330003291ca6

场景：

![事件分发场景](https://raw.githubusercontent.com/autowanglei/autowanglei.github.io/master/_posts/android/Android学习记录/事件分发场景.webp)

### 事件分发主要有三个方法处理

- public boolean dispatchTouchEvent(MotionEvent ev) {} 

  事件分发，返回事件是否消耗，消耗会调用当前view的onTouchEvent，否则传递给子view的dispatchTouchEvent，只要事件传递给该view，dispatchTouchEvent是首先要调用方法。

- public boolean onInterceptTouchEvent(MontionEvent ev){}

  是否对分发事件进行拦截，不拦截，继续分发；拦截，onTouchEvent消费事件，返回true，事件传递结束。

- public boolean onTouchEvent(MontionEvent ev)

  处理拦截的事件，处理返回true；不处理返回false，会返回到父控件的onTouchEvent。

### 三个方法之间的关系

```
 public boolean dispatchTouchEvent(MotionEvent ev) {
  boolean isDispatch;
  if(onInterceptTouchEvent(ev)){
     isDispatch=onTouchEvent(ev);
  }else {
     isDispatch=childView.dispatchTouchEvent(ev);
  }
  return isDispatch;
 }
```



# SDK

##  compileSdkVersion, minSdkVersion 和 targetSdkVersion 

-  compileSdkVersion:SDK编译版本

  Gradle会使用哪个版本的sdk编译应用，使用新添加的API，就需要使用对应版本的sdk。修改compileSdkVersion不会影响运行时的行为。建议使用最新版本的sdk进行编译。

- minSdkVersion：最小SDK版本

  应用运行的最低sdk版本，低于最小sdk版本的设备，不能安装应用。

  开发时，使用了低于minSdkVersion版本的API时，lint会警告，避免调用不存在的API的运行问题。

- targetSdkVersion：目标版本号

  targetSdkVersion是Android提供的向前兼容的重要依据，系统认为你在targetSdkVersion版本的设备上做了充分测试，会为你的应用启用一些新的功能和特性。较低的targetSdkVersion应用在较高版本的设备上运行时，新特性不会被启用。

- 三者之间的关系

  minSdkVersion (lowest possible) <= targetSdkVersion == compileSdkVersion （latest SDK）

  用较低的 minSdkVersion 来覆盖最大的人群，用最新的 SDK 设置 targetSdkVersion 和 compileVersion 来获得最好的外观和行为。
  