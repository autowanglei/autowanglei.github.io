

## 1. ButterKnife是什么 ##

ButterKnife是一个开源的 Android 系统的 View 注入框架，通过注解的方式来绑定 View 的属性或方法，大量减少了类似 findViewById() 以及 setOnClickListener() 等代码，提升开发效率。

butterknife官方博客：[http://jakewharton.github.io/butterknife/](http://jakewharton.github.io/butterknife/)

## 2. ButterKnife使用 ##
### 2.1导入ButterKnife框架 ###
1. Eclipse,可以去官网下载jar包。
2. AndroidStudio可以直接 File->Project Structure->Dependencies->Library dependency 搜索butterknife即可。

### 2.2 编码前需了解  ###
1.Activity ButterKnife.bind(this);必须在setContentView();之后，且父类bind绑定后，子类不需要再bind。

2.Fragment ButterKnife.bind(this, mRootView)。

3.属性布局不能用private or static 修饰，否则会报错。

4.setContentView()不能通过注解实现。

### 2.3 常见使用方法 ###
1. 绑定Activity

        public abstract class BaseActivity extends Activity {  
            public abstract int getContentViewId();  
         
            @Override  
            protected void onCreate(Bundle savedInstanceState) {  
                super.onCreate(savedInstanceState);  
                setContentView(getContentViewId());  
                ButterKnife.bind(this);  
                initAllMembersView(savedInstanceState);  
            }  
         
            protected abstract void initAllMembersView(Bundle savedInstanceState);  
         
            @Override  
            protected void onDestroy() {  
                super.onDestroy();  
                ButterKnife.unbind(this);//解除绑定，官方文档只对fragment做了解绑  
            }  
        }  

2. 绑定Fragment

        public abstract class BaseFragment extends Fragment {  
            public abstract int getContentViewId();  
            protected Context context;  
            protected View mRootView;  
         
            @Nullable  
            @Override  
            public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {  
                mRootView =inflater.inflate(getContentViewId(),container,false);  
                ButterKnife.bind(this,mRootView);//绑定framgent  
                this.context = getActivity();  
                initAllMembersView(savedInstanceState);  
                return mRootView;  
            }  
         
            protected abstract void initAllMembersView(Bundle savedInstanceState);  
         
            @Override  
            public void onDestroyView() {  
                super.onDestroyView();  
                ButterKnife.unbind(this);//解绑  
            }  
        } 

3. 绑定view

        @BindView(R.id.hello_world)  
        TextView mHelloWorldTextView;  
        @BindView(R.id.app_name)  
        TextView mAppNameTextView;//view  

4. 绑定资源

        @BindString(R.string.app_name)  
        String appName;//sting  
        @BindColor(R.color.red)  
        int textColor;//颜色  
        @BindDrawable(R.mipmap.ic_launcher)  
        Drawable drawable;//drawble  
        @Bind(R.id.imageview)  
        ImageView mImageView;  
        @Bind(R.id.checkbox)  
        CheckBox mCheckBox;  
        @BindDrawable(R.drawable.selector_image)  
        Drawable selector;  

5. Adapter ViewHolder 绑定

    ![](https://i.imgur.com/6jsqYzp.png)

6. 点击事件的绑定

    不用声明view，不用setOnClickLisener（）就可以绑定点击事件。
    ​    
    - 直接绑定一个方法，参数是可选的，也定义一个特定类型，它将自动被转换

        ![](https://i.imgur.com/7iSIISD.png)
    - 多个view统一处理同一个点击事件

       ![](https://i.imgur.com/qHITUjy.png)
    - 自定义view可以绑定自己的监听，不指定id

      ![](https://i.imgur.com/RqlHmAP.png)
    - 给EditText加addTextChangedListener（即添加多回调方法的监听的使用方法），利用指定回调，实现想回调的方法即可

      ![](https://i.imgur.com/SvX63VI.png)

7. 对一组View进行统一操作 
    ​      
    a. 装入一个list

      ![](https://i.imgur.com/VsSCiVz.png)

    b. 设置统一处理

      ![](https://i.imgur.com/SFu0JLr.png)

    c.统一操作处理，例如设置是否可点，属性等 

      ![](https://i.imgur.com/gQnHBdy.png)

8. 可选绑定
  默认情况下，“绑定”和“监听”绑定都是必需的。如果不能找到目标视图，则将抛出异常，所以做空处理。

  ![](https://i.imgur.com/riZTKBR.png)


### 2.4 代码混淆 ###

    -keep class butterknife.** { *; }  
    -dontwarn butterknife.internal.**  
    -keep class **$$ViewBinder { *; }  
      
    -keepclasseswithmembernames class * {  
        @butterknife.* <fields>;  
    }  
      
    -keepclasseswithmembernames class * {  
        @butterknife.* <methods>;  
    }  

### 2.5 Zelezny插件的使用 ###
AndroidStudio->File->Settings->Plugins->搜索Zelezny下载添加 ，可以快速生成对应组件的实例对象，不用手动写。使用时，在要导入注解的Activity 或 Fragment 或 ViewHolder的layout资源代码上，右键——>Generate——Generate ButterKnife Injections，然后就出现如图的选择框。

   ![](http://img.blog.csdn.net/20160324150702240)


PS:随着框架的改变，对于Android ButterKnife Zelezny插件就不再兼容，因此就算成功安装了这个插件也无法显示出Generate ButterKnife Injections的选项,Android ButterKnife Zelezny插件能兼容的ButterKnife版本是7.0.1，修改ButterKnife版本，可解决该问题。



## 3. ButterKnife工作流程 ##
- 编译阶段

  编译Android工程时，ButterKnife工程中ButterKnifeProcessor类的process()方法会执行以下操作：
  首先扫描Java代码中所有的ButterKnife注解@Bind/@BindView、@OnClick、@OnItemClicked等 
  当发现一个类中含有任何一个注解时，ButterKnifeProcessor会帮你生成一个Java类，名字类似$$ViewBinder.java/_ViewBinding.java，这个新生成的类实现了ViewBinder接口。这个ViewBinder类中包含了所有对应的代码，比如@BindView注解对应findViewById(), @OnClick对应了view.setOnClickListener()等等。

  如下：

    ![](https://i.imgur.com/GEE6iKt.png)

- 执行阶段

    执行bind方法时，会调用ButterKnife.bind(this)： ButterKnife会调用findViewBinderForClass(targetClass)加载MainActivity$$ViewBinder.java类。然后调用ViewBinder的bind方法，动态注入MainActivity类中所有的View属性。 
    如果Activity中有@OnClick注解的方法，ButterKnife会在ViewBinder类中给View设置onClickListener，并且将@OnClick注解的方法传入其中。

    在上面的过程中可以看到，为什么用@Bind/@BindView、@OnClick等注解标注的属性或方法必须是public或protected的，因为ButterKnife是通过Activity.this.XXX来注入View或方法的。如果把View设置成private，那么框架必须通过反射来注入View，不管现在手机的CPU处理器变得多快，如果有些操作会影响性能，那么是肯定要避免的，这就是ButterKnife与其他注入框架的不同。

## 4. ButterKnife 利弊  ##


- 优势：


    1. 强大的View绑定和Click事件处理功能，简化代码，提升开发效率。
    3. 运行时不会影响APP性能，使用配置方便。
    
        Instead of slow reflection, code is generated to perform the view look-ups.（摘自[butterknife官方博客](http://jakewharton.github.io/butterknife/)）。
    
    4. 代码清晰，可读性强（至于代码可读性好坏因人而异）。


- 弊端


    1. library工程无法使用butterKnife进行注入（此问题8.4.0后已解决）。
    2. 方法数更多了，更容易触及65536上限；增加安装包的大小。
    4. 增加新人的学习成本。

## 5. 7.0.1升级8.8.1 ##
Error:Error: Expected resource of type color [ResourceType]   https://github.com/JakeWharton/butterknife/issues/338


1.在整个工程的gradle文件中加入  classpath 'com.neenbedankt.gradle.plugins:android-apt:1.8' 

    dependencies {
        classpath 'com.android.tools.build:gradle:2.0.0'
        classpath 'com.neenbedankt.gradle.plugins:android-apt:1.8'
        // NOTE: Do not place your application dependencies here; they belong
        // in the individual module build.gradle files
    }

2.Module的gradle文件中加入

apply plugin: 'com.neenbedankt.android-apt'
apt 'com.jakewharton:butterknife-compiler:8.8.1'

关于butterknife框架有一篇介绍更详细的的博客：[https://zhuanlan.zhihu.com/p/21628698](https://zhuanlan.zhihu.com/p/21628698 "【腾讯Bugly干货分享】深入理解 ButterKnife，让你的程序学会写代码")


## 6. 延伸 ##
### 6.1 反射对性能的影响 ###

Method.invoke()本身要用数组包装参数；而且每次调用都必须检查方法的可见性（在Method.invoke()里），也必须检查每个实际参数与形式参数的类型匹配性（在NativeMethodAccessorImpl.invoke0()里或者生成的Java版MethodAccessor.invoke()里）；而且Method.invoke()就像是个独木桥一样，各处的反射调用都要挤过去，在调用点上收集到的类型信息就会很乱，影响内联程序的判断，使得Method.invoke()自身难以被内联到调用方。


### 6.2 APT ###
APT(Annotation processing tool) 是一种处理注释的工具,它对源代码文件进行检测找出其中的Annotation，使用Annotation进行额外的处理。
Annotation处理器在处理Annotation时可以根据源文件中的Annotation生成额外的源文件和其它的文件(文件具体内容由Annotation处理器的编写者决定),APT还会编译生成的源文件和原来的源文件，将它们一起生成class文件.使用APT主要的目的是简化开发者的工作量。
因为APT可以编译程序源代码的同时，生成一些附属文件(比如源文件类文件程序发布描述文件等)，这些附属文件的内容也都是与源代码相关的，换句话说，使用APT可以代替传统的对代码信息和附属文件的维护工作。




