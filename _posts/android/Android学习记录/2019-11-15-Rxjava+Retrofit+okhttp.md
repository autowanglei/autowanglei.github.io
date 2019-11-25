<center><font size="7" ><b>RxJava+Retrofit+okhttp</b></font> </center>

# RxJava

Rxjava是基于观察者模式实现的，提供异步操作，保持代码简洁的开源库。

## RxJava 的观察者模式

 RxJava 有四个基本概念：

- Observable(可观察者，即被观察者)
- Observer(观察者)
- subscribe(订阅)、事件。Observable和 `Observer通过 `subscribe()方法实现订阅关系，从而 Observable可以在需要的时候发出事件来通知 `Observer。 

与传统观察者模式不同， RxJava 的事件回调方法除了普通事件 onNext() （相当于 onClick()/ onEvent()）之外，还定义了两个特殊的事件：onCompleted() 和 onError()。

- onCompleted(): 事件队列完结。RxJava 不仅把每个事件单独处理，还会把它们看做一个队列。RxJava 规定，当不会再有新的 onNext() 发出时，需要触发 onCompleted() 方法作为标志。
- onError(): 事件队列异常。在事件处理过程中出异常时，onError() 会被触发，同时队列自动终止，不允许再有事件发出。
- 在一个正确运行的事件序列中, onCompleted() 和onError() 有且只有一个，并且是事件序列中的最后一个。需要注意的是，onCompleted()和onError() 二者也是互斥的，即在队列中调用了其中一个，就不应该再调用另一个。

## 基本实现

 基于以上的概念， RxJava 的基本实现主要有三点：

1. 创建Observer

    Observer 即观察者，它决定事件触发的时候将有怎样的行为。

    RxJava提供了Observer接口和Subscriber（对Observer接口进行了一些扩展）两种方式创建观察者。两者基本使用方式一样，实质上，在 RxJava 的 subscribe 过程中，Observer 也总是会先被转换成一个 Subscriber 再使用。所以如果你只想使用基本功能，选择 Observer和Subscriber是完全一样的。它们的区别对于使用者来说主要有两点：

   - onStart()

      subscribe 刚开始，而事件还未发送之前被调用，不能在指定线程，故不能做UI刷新相关的工作，可使用 doOnSubscribe()，在指定线程做准备工作。

   - unsubscribe()

     取消订阅。释放资源，避免内存泄漏。

2. 创建Observable

   Observable 即被观察者，它决定什么时候触发事件以及触发怎样的事件。 RxJava 使用 create()方法来创建一个 Observable ，并为它定义事件触发规则： 

   ```java
   Observable observable = Observable.create(new Observable.OnSubscribe<String>() {
       @Override
       public void call(Subscriber<? super String> subscriber) {
           subscriber.onNext("Hello");
           subscriber.onNext("Hi");
           subscriber.onNext("Aloha");
           subscriber.onCompleted();
       }
   });
   ```

   可以看到，这里传入了一个OnSubscribe对象作为参数。OnSubscribe会被存储在返回的 Observable对象中，它的作用相当于一个计划表，当 Observable被订阅的时候，OnSubscribe的call()方法会自动被调用，事件序列就会依照设定依次触发（对于上面的代码，就是观察者Subscriber将会被调用三次 onNext()和一次 onCompleted()）。这样，由被观察者调用了观察者的回调方法，就实现了由被观察者向观察者的事件传递，即观察者模式。

   也可以通过  just(T...)的例子和 from(T[])创建Observable。

3. Subcribe（订阅）

   创建了 Observable 和 Observer之后，再用 subscribe()方法将它们联结起来，整条链子就可以工作了。 

   ```java
   //被观察者订阅观察者
   observable.subscribe(observer);
   // 或者：
   observable.subscribe(subscriber);
   ```

    Observable.subscribe(Subscriber)的内部实现是这样的（仅核心代码）： 

   ```java
   // 注意：这不是 subscribe() 的源码，而是将源码中与性能、兼容性、扩展性有关的代码剔除后的核心代码。
   // 如果需要看源码，可以去 RxJava 的 GitHub 仓库下载。
   public Subscription subscribe(Subscriber subscriber) {
       subscriber.onStart();
       onSubscribe.call(subscriber);
       return subscriber;
   }
   ```

   可以看到，subscriber() 做了3件事：

   1. 调用 Subscriber.onStart() 。这个方法在前面已经介绍过，是一个可选的准备方法。
   2. 调用 Observable中的 OnSubscribe.call(Subscriber) 。在这里，事件发送的逻辑开始运行。从这也可以看出，在 RxJava 中， Observable 并不是在创建的时候就立即开始发送事件，而是在它被订阅的时候，即当 subscribe()方法执行的时候。
   3. 将传入的 Subscriber 作为 Subscription` 返回。这是为了方便 `unsubscribe().

