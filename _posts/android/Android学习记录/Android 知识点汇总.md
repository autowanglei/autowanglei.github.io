# Android四大组件、五大存储、六大布局

## Android四大组件

Activity、Service、Content provider、broadcast receiver 

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
  