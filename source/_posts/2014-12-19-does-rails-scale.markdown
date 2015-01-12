---
layout: post
title: "Does Rails Scale?"
date: 2014-12-19 15:22
comments: true
keywords: ruby, rails, scaling, performance, rails performance
categories: [ruby, rails, scaling, performance, 'rails performance']
author: Jarkko
---

<figure markdown="1">
  <a href="https://www.flickr.com/photos/soctech/43279549/">
    <img src="https://farm1.staticflickr.com/24/43279549_465d50976e_b_d.jpg">
  </a>

  <figcaption>
    <p>
      Photo by <a href="https://www.flickr.com/photos/soctech/43279549/">Soctech</a>
    </p>
  </figcaption>
</figure>

Back when Rails was still not mainstream, a common dismissal by developers using other – more established – technologies was that Rails is cool and stuff, but it will never scale[^marketing]. While the question isn't (compared to Rails' success) as common these days, it still appears in one form or another every once in a while.

Last week on the Ruby on Rails Facebook group, someone asked [this question](https://www.facebook.com/groups/rubyandrails/permalink/10153620823655752/):

> Can Rails stand up to making a social platform like FB with millions of users using it at the same time? 
> 
> If so what are the pro's and the cons?

So in other words, can Rails scale *a lot*?

Just as is customary for a Facebook group, the question got a lot of clueless answers. There were a couple of gems like this:

> Tony if you want to build some thing like FB, you need to learn deeper mountable engine and SOLID anti pattern.

The worst however are answers from people who *don't know* they don't know shit but insist on giving advice that is only bound to either confuse the original poster or lead them astray – and probably both:

> Twitter is not a good example. They stopped using Rails because it couldn't handle millions of request per second. They began using Scala.

This is of course mostly BS with a hint of truth in it, but we'll get back to that in a bit.

The issue with the question itself, is that *it's the wrong question to ask*, and this has nothing to do with Ruby or Rails per se.

Why is it the wrong question? Let's have a look.

Sure, Ruby is slow in raw performance. It has gotten a lot faster during the past decade, but it is still a highly dynamic interpreted scripting language. Its main shtick has always been programmer happiness, and its primary way to attain that goal has definitely not been to return from that test run as fast as possible. The same goes for Rails.

That said, there are two reasons bare Ruby performance doesn't matter *that* much. First, it's only a tiny part of the **perceived app performance** for the user. Rails has gone out of its way to automatically make the frontend of your web app performant. This includes frontend caching, asset pipeline, and more opinionated things like Turbolinks. You can of course screw all that up, but you would be amazed how much actual end-user performance you'd miss if you'd write the same app from scratch – not to mention the time you'd waste building it.

Second, and most important for this discussion: **scaling is not the same thing as performance**. Rails has always been built on the [shared nothing architecture](http://en.wikipedia.org/wiki/Shared_nothing_architecture), where in theory the only thing you need to do to scale out your app is to throw more hardware at it – the app should scale linearly. Of course there are limits to this, but they are by no means specific to Rails or Ruby.

Scaling and performance are two separate things. They are related as terms, but not strictly connected. Your app can be very fast for a couple users but awful for a thousand (didn't scale). Or it can scale at O(1) to a million users but loading a page for even a single concurrent user can take 10 seconds (scales but doesn't perform).

Like stated above, a traditional crud-style app on Rails can be made to scale very well by just adding app server instances, cores, and finally physical app servers serving the app. This is what is meant by scaling out[^vs-up]. Most often the limiting factor here is not Rails but the datastore, which is still often the one shared component in the equation. Scaling the database out is still harder than the appservers, but nevertheless possible. That is way outside the scope of this article, however.

[^vs-up]:Versus scaling up, which means making the single core or thread faster.

## Is this the right tool for the job?

It's clear in hindsight that a Rails app wasn't the right tool for what Twitter became – a juggernaut where millions of people were basically realtime chatting with the whole world.

That doesn't mean that Rails wasn't a valid choice for the original app. Maybe it wasn't the best option even then from the technical perspective, but it for sure made developing Twitter a whole lot faster in its initial stages. You know, twitter wasn't the only contender in the microblogging stage in the late naughties. We finns fondly remember Jaiku. Then there was that other San Fransisco startup using Django that I can't even name anymore.

Anyway, the point is that *reaching a scale where you have to think harder about scalability is a very, very nice problem to have*. Either you built a real business and are making money hand over fist, or you are playing – and winning – the eyeball lotto and have VCs knocking on your door (or, more realistically, have taken on several millions already). The vast majority of businesses *never* reach this stage.

More likely you just fail in the hockeystick game (the VC option), or perhaps build a sustainable business (the old-fashioned *people pay me for helping them kick ass* kind). In any case, you won't have to worry about scaling to millions of concurrent users.

Even at the very profitable, high scale SaaS market there are hoards of examples of apps running on Rails. Kissmetrics runs its frontend on Rails, as does GitHub, not to mention Groupon, Livingsocial[^ok-profitable], and many others.

[^ok-profitable]:OK, the last two might not pass the profitable bit.

However, at certain scale you have to go for a more modular architecture, SOA if I may. You can use a message queue for message passing, a noSQL db for non-relational and ephemeral data, node.js for realtime apps, and so on. *A good tool for every particular sub-task of your app*.

That said, you need to keep in mind what I said above. It is pretty unlikely you will ever reach a state where you really need to scale. Thus, thinking about the architecture at the initial stage too much is a form of premature optimization. As long as you don't do anything extra stupid, you can probably get away with a simple Rails app. Because splitting up your app to lots of components early on makes several things harder and more expensive:

* Complexity of development.
* Operating and deploying a bunch of different apps.
* Keeping track that all apps are up and running.
* Hunting bugs.
* Making changes in a lean development environment where things change rapidly
* Cognitive cost of understanding and learning how the app works. This is especially true when you're expanding your team.

This doesn't mean that at some point you shouldn't do the split. There might be a time where the scale for the points above tips, and a monorail app becomes a burden. But then again, *there might not*. So do what makes sense now, not what makes sense in your imaginary future.

Of *course* Rails alone won't scale to a gazillion users for an app it wasn't really meant for to begin with. Neither is it supposed to. However, it is amazing how far you can get with it, just the same way that the old boring PostgreSQL still beats the shit out of its more "modern" competitors in most common usecases[^special-cases].

## Questions you should be asking

When making a technology decision, instead of “Does is scale?”, here's what you should be asking instead:

* What is the right tool for the jobs of my app?
* How far can I likely get away with a single Rails app?
* Will we ever really reach the scale we claim in our investor prospectus? No need to lie to yourself here.
* What is more important: getting the app up and running and in front of real users fast, or making it scalable in an imaginary future that may never come?

Only after answering those are you equipped to make a decision.

P.S. Reached the point where optimizing Rails and Ruby performance *does* make a difference? We're writing [a series of articles](https://bearmetal.eu/theden/categories/rails-performance/) about just that. Pop your details in the [form ☟ down there](#mc_embed_signup) and we'll keep you posted.

[^special-cases]:There are obviously special cases where a single Rails app doesn't cut it even from the beginning. E.g. computationally intensive apps such as Kissmetrics or Skylight.io obviously won't run their stats aggregation processes on Rails.

[^marketing]:Another good one I heard in EuroOSCON 2005 was that the only thing good about Rails is its marketing.