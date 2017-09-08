## 问题 ##
Scrollview里面使用了自定义控件，打开Scrollview所在页面时，Scrollview默认显示位置不是顶部。

## 原因 ##
在Activity计算窗口的高度时，自定义控件还未加载，所以ScrollView就会按照layout中定义的默认高度计算。

## 解决方法 ##
该问题有三种解决方法：


1. 设置ScrollView上方控件或其最顶层子控件焦点，有两种方式：

	- XML文件对应控件添加属性

			android:focusable="true"
			android:focusableInTouchMode="true"
	- 代码中获取焦点

			progressbar.setFocusable(true); 
			progressbar.setFocusableInTouchMode(true); 
			progressbar.requestFocus(); 

2. 使用fullScrol()

	scrollView.fullScroll(ScrollView.FOCUS_DOWN);滚动到底部

	scrollView.fullScroll(ScrollView.FOCUS_UP);滚动到顶部

	需要注意的是，该方法不能直接被调用 ，因为Android很多函数都是基于消息队列来同步，addView完之后，不等于马上就会显示，而是在队列中等待处理，虽然很快，但是如果立即调用fullScroll， view可能还没有显示出来，可能会失败，应该通过handler.post(runnable)调用。

		scrollView.post(new Runnable() {
            @Override
            public void run() {

                scrollView.fullScroll(ScrollView.FOCUS_UP);
            }
        });
3. 使用scrollTo/smoothScrollTo

	同上一种方法，scrollTo/smoothScrollTo，也应该通过handler.post(runnable)调用。

		scrollView.post(new Runnable() {
            @Override
            public void run() {
                scrollView.scrollTo(0， 0);
				//或scrollView.smoothScrollTo(0, 0);
            }
        });
	smoothScrollTo类似于scrollTo，但是滚动的时候是平缓的而不是立即滚动到某处。另外，smoothScrollTo()方法可以打断滑动动画。


	
## 需要说明两点： ##


- handler.post(runnable);并不是新开线程，只是让UI主线程去并发执行run()方法
- fullScroll/scrollTo/smoothScrollTo之所以放在handler里，是为了保证View都已经绘制完成后，再执行。不然，你放在resume()中执行，应该也可以的。
