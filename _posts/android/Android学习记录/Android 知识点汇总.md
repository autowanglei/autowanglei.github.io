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

 老板（Activity） 

 经理（RootView） 

 组长（ViewGroup） 

 程序员（View1） 

 扫地阿姨（View2） 

- 场景一：老板询问App项目进度，事件经过每个领导传递到达程序员处，程序员完成了项目（点击事件被View1消费了） 
-  场景二 ：老板异想天开，想造宇宙飞船，事件经过每个领导传递到达程序员处，程序员表示做不了，反馈给老板（事件没有被消费） 
-  场景三：老板询问技术部本月表现，只需要组长汇报就行，不需要通知程序员（ViewGroup 拦截并消费了事件） 

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

- 结合这段伪代码和前面的例子的场景三，我们可以发现ViewGroup的事件分发规则是这样的，事件传递到ViewGroup首先调用它的dispatchTouchEvent方法，接下来是调用onInterceptTouchEvent方法，如果该方法返回true，则说明当前ViewGroup要拦截该事件，拦截之后则调用当前ViewGroup的onTouchEvent方法；如果不进行拦截，则调用子View的dispatchTouchEvent方法，结合场景二，如果到最后事件都没有被消费掉，则最后返回Activity，Activity不处理则事件消失。
- 结合场景一、场景二，View接收到事件，如果进行处理，则直接在onTouchEvent进行处理返回true就表示事件被消费了，不进行处理则调用父类onTouchEvent方法或者返回false表示不消费该事件，然后事件再原路返回向上传递。

### 事件传递流程

```undefined
Activity －> PhoneWindow －> DecorView －> ViewGroup －> ... －> View
```

-  总结一下每个传递者具有的方法 

  |   类型   |       相关方法        | Activity | ViewGroup | View |
  | :------: | :-------------------: | :------: | :-------: | :--: |
  | 事件分发 |  dispatchTouchEvent   |    有    |    有     |  有  |
  | 事件拦截 | onInterceptTouchEvent |    无    |    有     |  无  |
  | 事件消费 |     onTouchEvent      |    有    |    有     |  有  |

-  点击事件分发原则 

  - onInterceptTouchEvent拦截事件，该View的onTouchEvent方法才会被调用，只有onTouchEvent返回true才表示该事件被消费，否则回传到上层View的onTouchEvent方法。
  - 如果事件一直不被消费，则最终回传给Activity，Activity不消费则事件消失。
  - 事件是否被消费是根据返回值，true表示消费，false表示不消费。

### view相关事件调度优先顺序

 onTouchListener>onTouchEvent > onLongClickListener > onClickListener 

### 核心总结

- 正常情况下触摸一次屏幕触发事件序列为ACTION_DOWN-->ACTION_UP
- 当一个View决定拦截，那么这一个事件序列只能由这个View来处理，onInterceptTouchEvent方法并不是每次产生动作都会被调用到。
- 一个View开始处理事件，但是它不消耗ACTION_DOWN，也就是onTouchEvent返回false，则这个事件会交由他的父元素的onTouchEvent方法来进行处理，而这个事件序列的其他剩余ACACTION_MOVE，ACTION_UP也不会再给该View来处理。
- View没有onInterceptTouchEvent方法，View一旦接收到事件就调用onTouchEvent方法
- ViewGroup默认不拦截任何事件（onInterceptTouchEvent方法默认返回false）。
- View的onTouchEvent方法默认是处理点击事件的，除非他是不可点击的（clickable和longClickable同时为false）
- 事件分发机制的核心原理就是责任链模式，事件层层传递，直到被消费。

## 在 Activity 中获取某个 View 的宽高

-  Activity/View#onWindowFocusChanged 

  ```java
  // 此时View已经初始化完毕
  // 当Activity的窗口得到焦点和失去焦点时均会被调用一次
  // 如果频繁地进行onResume和onPause，那么onWindowFocusChanged也会被频繁地调用
  public void onWindowFocusChanged(boolean hasFocus) {
      super.onWindowFocusChanged(hasFocus);
      if (hasFocus) {
          int width = view.getMeasureWidth();
          int height = view.getMeasuredHeight();
      }
  }
  ```

## Draw 的基本流程

```java
// 绘制基本上可以分为六个步骤
public void draw(Canvas canvas) {
    ...
    // 步骤一：绘制View的背景
    drawBackground(canvas);
    ...
    // 步骤二：如果需要的话，保持canvas的图层，为fading做准备
    saveCount = canvas.getSaveCount();
    ...
    canvas.saveLayer(left, top, right, top + length, null, flags);
    ...
    // 步骤三：绘制View的内容
    onDraw(canvas);
    ...
    // 步骤四：绘制View的子View
    dispatchDraw(canvas);
    ...
    // 步骤五：如果需要的话，绘制View的fading边缘并恢复图层
    canvas.drawRect(left, top, right, top + length, p);
    ...
    canvas.restoreToCount(saveCount);
    ...
    // 步骤六：绘制View的装饰(例如滚动条等等)
    onDrawForeground(canvas)
}
```

## 自定义 View

- 继承 View 重写 `onDraw` 方法

  主要用于实现一些不规则的效果，静态或者动态地显示一些不规则的图形，即重写 `onDraw` 方法。采用这种方式需要自己支持 wrap_content，并且 padding 也需要自己处理。

- 继承 ViewGroup 派生特殊的 Layout

  主要用于实现自定义布局，采用这种方式需要合适地处理 ViewGroup 的测量、布局两个过程，并同时处理子元素的测量和布局过程。

- 继承特定的 View

  用于扩张某种已有的View的功能

- 继承特定的 ViewGroup

  用于扩张某种已有的ViewGroup的功能

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
  