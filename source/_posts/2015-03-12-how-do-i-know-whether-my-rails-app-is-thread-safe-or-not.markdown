---
layout: post
title: "How do I know whether my Rails app is thread-safe or not?"
date: 2015-03-12 16:10:58 +0200
comments: true
categories: 
published: false
---

In January [Heroku started promoting](https://devcenter.heroku.com/changelog-items/594) [Puma](http://puma.io) as the preferred web server for Rails apps deployed on its hugely successful platform. Puma – as a threaded app server – can better use the scarce resources available for an app running on Heroku.

This is obviously good for a client since they can now run more concurrent users with a single Dyno. However, it’s also good for Heroku itself since small apps (probably the vast majority of apps deployed on Heroku) will now consume much fewer resources on its servers.

The recommendation comes with a caveat, however. _Your app needs to be thread-safe_. The problem with this is that there is no simple way to say with absolute certainty whether an app as a whole is thread-safe. We can get close, however.

Let’s have a look how.

For the purpose of this issue, an app can be split into three parts:

1. The app code itself.
2. Rails the framework.
3. Any 3rd party gems used by the app.

All three of these need to be thread-safe. Rails and its included gems [have been declared thread-safe since 2.2](http://m.onkey.org/thread-safety-for-your-rails), i.e. since 2008. This alone, however, does *not* automatically make your app as a whole so. Your own app code and all the gems you use need to be thread-safe as well.

## What is and what isn’t thread-safe in Ruby?

**So when is your app code not thread-safe? Simply put, when you share mutable state between threads in your app.**

But what does this even mean?

**None of the core data structures (except for Queue) in Ruby are thread-safe**. The structures are mutable, and when shared between threads, there are no guarantees the threads won’t overwrite each others’ changes. Fortunately, this is rarely the case in Rails apps.

**Any code that is more than a single operation (as in a single Ruby code call implemented in C) is not thread-safe.** The classic example of this is the `+=` operator, which is in fact two operations combined, `=` and `+`. Thus, the final value of the shared variable in the following code is undetermined:

	@n = 0
	3.times do
	  Thread.start { 100.times { @n += 1 } }
	end

However, none of the two above things alone makes code thread-unsafe. It only becomes so when it is mated with shared data. Let’s get back to that in a minute, but first…

## Aside: **But what about GIL?**

More informed readers might object at this point and point out that MRI Ruby uses a GIL, a.k.a. Global Interpreter Lock.

The general wisdom on the street is that GIL is bad because it does not let your threads run in parallel (true, in a sense), but good, because it makes your code thread-safe.

Unfortunately, **GIL _does not_ make your code thread-safe**. It only guarantees that two threads can’t run Ruby code at the same time. Thus it does inhibit parallelism. However, threads can still be paused and resumed at any given point, which means that they absolutely can clobber each others’ data.

GIL does accidentally make some operations (such as `Array#<<`) atomic. However, there are two issues with this:

* It only applies to cases where what you’re doing is truly a single Ruby operation. When what you’re doing is multiple operations, context switches can and will happen, and you won’t be happy.
* It only applies to MRI. JRuby and Rubinius support true parallelism and thus don’t use a GIL. I wouldn’t count on GIL being there forever for MRI either, so relying on it guaranteeing your code being thread-safe is irresponsible at best.

Go read Jesse Storimer’s [Nobody understands the GIL](http://www.jstorimer.com/blogs/workingwithcode/8085491-nobody-understands-the-gil) (also parts [2](http://www.jstorimer.com/blogs/workingwithcode/8100871-nobody-understands-the-gil-part-2-implementation) and [3](http://www.rubyinside.com/does-the-gil-make-your-ruby-code-thread-safe-6051.html)) for much more detail about it (than you can probably even stomach). But for the love of the flying spaghetti monster, _don’t count on it making your app thread-safe_.

## Thread-safety in Rails the framework

A bit of history:

Rails and its dependencies were declared thread-safe already in version 2.2, in 2008. At that point, however, the consensus was that so many third party libraries were not thread-safe that the whole request in Rails was enclosed within a giant mutex lock. This meant that while a request was being processed, no other thread in the same process could be running.

In order to take advantage of threaded execution, you had to declare in your config.rb that you really wanted to ditch the lock:

	config.threadsafe!

However, en route to Rails 4 [Aaron Tenderlove Patterson demonstrated](http://tenderlovemaking.com/2012/06/18/removing-config-threadsafe.html) that what `config.threadsafe!` did was

* effectively irrelevant in multi-process environments (such as Unicorn), where a single process never processed multiple requests concurrently.
* absolutely necessary every time you used a threaded server such as Puma or Passenger Enterprise.

What this meant was that there was no reason for _not_ to have the thread-safe option always on. And that was exactly what was done for Rails 4 in 2012.

**Key takeaway: Rails and its dependencies are thread-safe. You don’t have to do anything to “turn that feature on”.**

## Making your app code thread-safe

Good news: Since Rails uses the [Shared nothing architecture](http://en.wikipedia.org/wiki/Shared_nothing_architecture), Rails apps are by definition very suitable for being thread-safe as well. In general, Rails creates a new controller object of every HTTP request, and everything else flows from there. This isolates most objects in a Rails app from other requests.

Like noted above, built-in Ruby data structures (save for Queue) are not thread-safe. This does not, however, matter, unless you are actually sharing them between threads. Because of the way in which Rails is architectured, this almost never happens in a Rails app.

There are, however, some patterns that can come bite you in the ass when you want to switch to a threaded app server.

### Global variables

Global variables are, well, global. This means that they are shared between threads. If you weren’t convinced about not using global variables by now, here’s another reason to never touch them. If you really want to share something globally across an app, you are more than likely better served by a constant (but see below), anyway.

### Class variables

For the purpose of a discussion about threads, class variables are not much different from global variables. They are shared across threads just the same way.

The problem isn’t so much about using class variables, but about mutating them. And if you are not going to mutate a class variable, in many cases a constant is again a better choice.

### Class instance variables

But maybe you’ve read that you should always use class instance variables instead of class variables in Ruby. Well, maybe you should, but they are just as problematic for threaded programs as class variables.

It’s worth pointing out that both class variables and class instance variables can also be set by class methods. This isn’t such an issue in your own code, but you can easily fall into this trap when calling other apis. Here’s an [example from Pratik Naik](http://m.onkey.org/thread-safety-for-your-rails) where the app developer is getting into thread-unsafe territory by just calling Rails class methods:

	class HomeController < ApplicationController
	  before_filter :set_site
	  
	  def index
	  end
	  
	  private
	  
	  def set_site
	    @site = Site.find_by_subdomain(request.subdomains.first)
	    if @site.layout?
	      self.class.layout(@site.layout_name)
	    else
	      self.class.layout('default_lay')
	    end
	  end
	end

In this case, calling the `layout` method causes Rails to set the class instance variable `@_layout` for the controller class. If two concurrent requests (serve by two threads) hit this code simultaneously, they might end up in a race condition and overwrite each others’ layout.

In this case, the correct way to set the layout is to use a symbol with the layout call:

	class HomeController < ApplicationController
	  before_filter :set_site
	  layout :site_layout
	
	  def index
	  end
	  
	  private
	  
	  def set_site
	    @site = Site.find_by_subdomain(request.subdomains.first)
	  end
	  
	  def site_layout
	    if @site.layout?
	      @site.layout_name
	    else
	      'default_lay'
	    end
	  end
	end

However, this is besides the point. The point is, you might end up using class variables and class instance variables by accident, thus making your app thread-unsafe.

### Memoization

Memorization is a technique where you lazily set a variable if it is not already set. It is a common technique used where the original functionality is at least moderately expensive and the resulting variable is used several times within a request.

A common case would be to set the current user in a controller:

	class SekritController < ApplicationController
	  before_filter :set_user
	  
	  private
	  
	  def set_user
	    @current_user ||= User.find(session[:user_id])
	  end
	end

Memoization can be an issue for thread safety for a couple of reasons:

* It is often used to store data in class variables or class instance variables (see above).
* The `||=` operator is in fact two operations, so there is a potential context switch happening in the middle of it, causing a race condition between threads.

It would be easy to dismiss memoization as the cause of the issue, and tell people just to avoid class variables and class instance variables. However, the issue is more complex than that.

In [this issue](https://github.com/rails/rails/pull/9789), Evan Phoenix squashes a really tricky race condition bug in the Rails codebase caused by calling `super` in a memoization function. So even though you would only be using instance variables, you might end up with race conditions with memoization.

What’s a developer to do, then?

* Make sure memoization makes sense and a difference in your case. In many cases Rails actually caches the result anyway, so that you are not saving a whole lot if any resources with your memoization method.
* Don’t memoize to class variables or class instance variables. If you need to memoize something on the class level, use thread local variables (`Thread.current[:baz]`) instead. If you absolutely think you must be able to share the result across threads, use a mutex to synchronize the memoizing part of your code. Keep in mind, though, that you’re kinda breaking the Shared nothing model of Rails with that. It’s kind of a half-assed sharing method anyway, since it only works across threads, not across processes.
* Use different instance variable names when you use inheritance and `super` in memoization methods.

### Constants

Yes, constants. _You didn’t believe constants are really constant in Ruby, did you?_ Well, they kinda are:

	irb(main):008:0> CON
	=> [1]
	irb(main):009:0> CON = [1,2]
	(irb):9: warning: already initialized constant CON

So you do get a warning when trying to reassign a constant, but the reassignment still goes through. That’s not the real problem, though. The real issue is that the constancy of constants only applies to the object reference, not the referenced object. And if the referenced object can be mutated, you have a problem.

Yeah, you remember right. _All the core data structures in Ruby are mutable_.

	irb(main):010:0> CON
	=> [1, 2]
	irb(main):011:0> CON << 3
	=> [1, 2, 3]
	irb(main):012:0> CON
	=> [1, 2, 3]

Of course, you should never, ever do this. And few will. There’s a catch, however. Since Ruby variable assignments also use references, you might end up mutating a constant by accident.

	irb(main):010:0> CON
	=> [1, 2]
	irb(main):011:0> arr = CON
	=> [1, 2]
	irb(main):012:0> arr << 3
	=> [1, 2, 3]
	irb(main):013:0> CON
	=> [1, 2, 3]

### Environment variables

`ENV` is really just a hash-like construct referenced by a constant. Thus, everything that applies to constants above, also applies to it.

	ENV['version'] = "1.2" # Don't do this

## Making sure 3rd party code is thread-safe

If you want your app to be thread-safe, all the third-party code it uses also needs to be thread-safe in the context of your app.

The first thing you probably should do with any gem is to read through its documentation and Google for whether it is deemed thread-safe. That said, even if it were, there’s no escaping double-checking yourself. Yes, by reading through the source code.

As a general rule, all that I wrote above about making your own code thread-safe applies here as well. However…

**With 3rd party gems and Rails plugins, context matters.**

If the third party code you use is just a library that your own code calls, you’re fairly safe (considering you’re using it in a thread-safe way yourself). It can be thread-unsafe just the same way as `Array` is, but if you don’t share the structures between threads, you’re more or less fine.

However, many Rails plugins actually extend or modify the Rails classes, in which case all bets are off. In this case, you need to scrutinize the library code much, much more thoroughly.

So how do you know which type of the two above a gem or plugin is? Well, you don’t. Until you read the code, that is. But you are reading the code anyway, aren’t you?

### What smells to look for in third party code?

Everything we mentioned above regarding your own code applies.

* Class variables (`@@foo`)
* Class instance variables (`@bar`, trickier to find since they look the same as any old ivar)
* Constants, ENV variables, and potential variables through which they can be mutated.
* Memoization, especially when one of the two above points are involved
* Creation of new threads (`Thread.new`, `Thread.start`). These obviously aren’t smells just by themselves. However, the risks mentioned above only materialize when shared across threads, so you should at least be familiar with in which cases the library is spawning new threads.

Again, context matters. Nothing above alone makes code thread-unsafe. Even sharing data with them doesn’t. But modifying that data does. So pay close attention to whether the libs provide methods that can be used to modify shared data.

## The final bad news

No matter how thoroughly you read through the code in your application and the gems it uses, you cannot be 100% sure that the whole is thread-safe. Heck, even running and profiling the code in a test environment might not reveal lingering thread safety issues.

This is because many race conditions only appear under serious, concurrent load. That’s why you should both try to squash them from the code and keep a close eye on your production environment on a continual basis. Your app being perfectly thread-safe today does not guarantee the same is true a couple of sprints later.

## Recap

To make a Rails app thread-safe, you have to make sure the code is thread-safe on three different levels:

* Rails framework and its dependencies.
* Your app code.
* Any third party code you use.

The first one of these is handled for you, unless you do stupid shit with it (like the memoization example above). The rest is your responsibility.

The main thing to keep in mind is to never mutate data that is shared across threads. Most often this happens through class variables, class instance variables, or by accidentally mutating objects that are referenced by a constant.

There are, however, some pretty esoteric ways an app can end up thread-unsafe, so be prepared to track down and fix the last remaining threading issues while running in production.

Have fun!