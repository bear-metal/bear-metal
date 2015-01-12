---
layout: post
title: "Help! My Rails App Is Melting under the Launch Day Load"
date: 2015-01-12 13:39
comments: true
author: Jarkko
published: true
keywords: ruby, rails, rails performance
categories: [ruby, rails, gc, 'rails performance']
---

<figure markdown="1">
  <a href="https://www.flickr.com/photos/pasukaru76/4484360302">
    <img src="https://farm5.staticflickr.com/4065/4484360302_70ac4b6a8d_o_d.jpg">
  </a>

  <figcaption>
    <p>
      Photo by <a href="https://www.flickr.com/photos/pasukaru76/4484360302">Pascal</a>
    </p>
  </figcaption>
</figure>

It was to be our day. The Finnish championship relay in orienteering was about to be held close to us, in a terrain type we knew inside and out. We had a great team, with both young guns and old champions. My friend Samuli had been fourth in the individual middle distance championships the day before. My only job was to handle the first leg securely and pass the baton to the more experienced and tougher guys who would then take care of our success. And I failed miserably.

My legs were like dough from the beginning. I was supposed to be in good shape, but I couldn't keep up with anyone. I was supposed to take it easy and orienteer cleanly, but I ran like a headless chicken, making a mistake after another. Although I wouldn't learn the term until years later, this was my crash course to [ego depletion](http://en.wikipedia.org/wiki/Ego_depletion).

---

The day before the relay we organized the middle distance Finnish champs in my old hometown Parainen. For obvious reasons, I was the de facto webmaster of our club pages, which also hosted the result service. The site was running on OpenACS, a system running on TCL I had a year or so of work experience with. I was supposed to know it.

After the race was over, I headed back to my friend's place, opened up my laptop… only to find out that the local orienteering forums were ablaze with complaints about our results page being down. Crap.

After hours or hunting down the issue, getting help on the OpenACS IRC channel, serving the results from a static page meanwhile, I finally managed to fix the issue. The app wasn't running enough server processes to keep up with the load. And the most embarrassing thing was that *the load wasn't even that high* – from high dozens to hundreds of simultaneous users. I headed to bed with my head spinning, hoping to scramble up my self confidence for the next day's race (with well-known results).

What does this have to do with Ruby or Rails? Nothing, really. And yet everything. The point is that most of us have a similar story to share. It's much more common to have a meltdown story with a reasonably low number of users than actually have a slashdotting/hackernewsing/daring fireball hit your app. If you aren't old enough to have gone through something like this, you probably will. But you don't have to.

---

During the dozen or so years since the aforementioned episode, I've gone through some serious loads. Some of them we have handled badly, but most – including the [Facebook terms of service vote campaign](http://wildfireapp.blogspot.fi/2009/04/wildfire-runs-facebook-site-governance.html) – with at least reasonable grace. This series of articles about Rails performance builds upon those war stories.

We have already posted a couple of articles to start off the series.

1. [Rails Garbage Collection: Naive Defaults](/theden/rails-garbage-collection-naive-defaults/)
2. [Does Rails Scale?](/theden/does-rails-scale/)
3. [Rails Garbage Collection: Age Matters](/theden/rails-garbage-collection-age-matters/)

This article will serve as kind of a belated intro to the series, introducing our high level principles regarding the subject but without going more to the details.

## The Bear Metal ironclad rules of Rails performance

### Scalability is not the same as performance

As I already noted in [Does Rails Scale?](/theden/does-rails-scale/), it's worth pointing out that performance is not the same thing as scalability. They are related for sure. But you can perform similarly poorly from your first to your millionth user and be “scalable”. There is also the difference that performance is right here and now. If your app scales well, you can just throw more hardware (virtual or real) at the problem and solve it by that.

The good news is that Rails scales quite well out of the box for the vast majority of real-world needs. You probably won't be the next Twitter or even Basecamp. In your dreams and VC prospectus maybe, but let's be honest, the odds are stacked against you. So don't sweat about that too much.

Meanwhile, you do want your app to perform well enough for your initial wave of users.

### Perceived performance is what matters

There are basically three different layers of performance for any web app: the server level (I'm bundling everything from the data store to the frontend server here), browser rendering and the performance perceived by the user. The two latter ones are very close to each other but not exactly the same. You can tweak the perceived performance with tricks on the UI level, something that often isn't even considered performance.

The most important lesson here is that the perceived performance is what matters. It makes no difference what your synthetic performance tests on your server say if the UI of the app feels sluggish. There is no panacea to solve this, but make no mistake, it is what matters when the chicken come home to roost.

### Start with quick, large, and obvious wins

The fact is that even a modest amount of users can make your app painfully slow. The good thing is that you can probably fix that just with hitting the low-hanging fruit. You won't believe how many Rails apps reveal that they're running in the development mode even in production by – when an error occurs – leaking the whole error trace out to the end user.

Other examples of issues that are fairly easy to spot and fix are N+1 query issues with ActiveRecord associations, missing database indeces, and running a single, non-concurrent app server instance, where any longer-running action will block the whole app from other users.

### YAGNI

Once you have squashed all the low-hanging fruit with your metal-reinforced bat, relax. Tuning app performance shouldn't be your top priority at the moment – unless it is, but in that case you will know for sure. What you should be focusing on is how to get paying customers and how you can make them kick ass. If you have clear performance issues, by all means fix them. However…

### Don't assume, measure

You probably don't have any idea how many users your app needs to support from the get go. That's fine. The reality will teach you. As long as you don't royally fuck up the share nothing (and 12 factor if you're on a cloud platform such as Heroku) architecture, you should be able to react to issues quickly.

That said, you probably do want to do some baseline load testing with your app if you're opening for a much larger private group or the public. The good news is that it is very cheap to spin up a virtual server instance just for a couple of hours and hit your app hard with it. Heck, you can handle the baseline from your laptop if needed. With that you should be able to get over the initial, frightening launch.

Once your app is up and running under load from real users, your tuning work starts for real. Only now will you be able to measure where the real hot paths and bottlenecks in your app are, based on real usage data, not just assumptions. At this point you'll have a plethora of tools at your disposal, from the good old [request log analyzer](https://github.com/wvanbergen/request-log-analyzer) to commercial offerings such as [Skylight](https://www.skylight.io), and [New Relic](http://newrelic.com).

On the frontend most browsers have nowadays developer tools to optimize end-user performance, from Chrome and Safari's built-in developer tools to [Firebug](http://getfirebug.com) for Firefox.

## Wrap-up

In this introductory article to building performant Rails (or any, for that matter) web apps, we took a look at five basic rules of performance optimization:

1. Scalability is not the same as performance.
2. Perceived performance is what matters.
3. Start with the low-hanging fruit.
4. YAGNI
5. Don't assume, measure.

We will get (much) more in the details of Rails performance optimization in later articles. At that point we'll enter a territory where one size does not fit all anymore. However, whatever your particular performance problem is, you should keep the five rules above at the top your mind.