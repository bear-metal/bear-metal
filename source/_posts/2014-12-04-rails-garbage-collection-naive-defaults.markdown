---
layout: post
title: "Rails Garbage Collection: naive defaults"
author: Lourens
date: 2014-12-04 17:27
comments: true
keywords: ruby, rails, gc, garbage collection
categories: [ruby, rails, gc, garbage collection]
---



[![](https://farm8.staticflickr.com/7036/13349077375_36fc92ecce_k_d.jpg)](https://www.flickr.com/photos/x1klima/13349077375/in/photolist-mkBvCt-9F5bop-psoHyh-6pkzNo-9uDMLx-85EMnZ-ibSsrK-iog9vf-JtxCJ-iohdxP-ibS242-7RtfVT-k1H87W-jNAG6M-oxaFaw-cR3ow7-gEqUsd-6z6KY5-e1m1pQ-diRWXG-i5md69-iogg32-ibSVHi-ibStrn-ibSVUy-n8CpB1-67QKGw-p3qtEX-4THpny-ebLNCE-nycgpC-6U69md-4yXv5b-pTDf3R-861fmQ-6zABJu-3FKVM-nwzafz-6pgrY2-9ejbm6-QuSM-hvn32M-aomUMi-9eebae-b15Lpi-8tBhZj-6o1Xmn-6z3YKz-5s868-61WvU1)

<small>Photo by [martin](https://www.flickr.com/photos/x1klima/13349077375/in/photolist-mkBvCt-9F5bop-psoHyh-6pkzNo-9uDMLx-85EMnZ-ibSsrK-iog9vf-JtxCJ-iohdxP-ibS242-7RtfVT-k1H87W-jNAG6M-oxaFaw-cR3ow7-gEqUsd-6z6KY5-e1m1pQ-diRWXG-i5md69-iogg32-ibSVHi-ibStrn-ibSVUy-n8CpB1-67QKGw-p3qtEX-4THpny-ebLNCE-nycgpC-6U69md-4yXv5b-pTDf3R-861fmQ-6zABJu-3FKVM-nwzafz-6pgrY2-9ejbm6-QuSM-hvn32M-aomUMi-9eebae-b15Lpi-8tBhZj-6o1Xmn-6z3YKz-5s868-61WvU1), used under the Creative Commons license.</small>

The vast majority of [Ruby on Rails](http://www.rubyonrails.org) applications deploy to production with the vanilla Ruby GC configuration. A conservative combination of growth factors and accounting that "works" for a demographic from IRB sessions (still my preferred calculator) to massive monolithic Rails apps (the fate of most successful ones). In practice this doesn't work very well, however. It produces:

* Too aggressive growth of Ruby heap slots and pages when thresholds are reached.
* A large ratio of short and medium lived objects in relation to long lived ones for Rails applications.
* Too many intermittent major GC cycles during the request / response cycle.
* Heap fragmentation.

Let's use a metaphor most of us can better relate to: *dreaded household chores.* Your ability and frequency of hosting dinners at home are limited by four things (takeaways and paper plates aside):

* How many seats and tables you have
* How many sets of clean cutlery, plates and glasses are available
* Overhead preparing a particular choice of cuisine
* Willingness to clean up and do dishes after

This is what you have to work with at home:

* 4 chairs and a table
* 12 plates and equivalent utensils
* 83 friends (60 from Facebook, 20 at work, your 2 brothers and then there's Jim)
* 3 wine glasses and a beer mug
* 1 bottle of wine and 24 beers[^promotions]
* 3 awesome steaks and a piece of tofu
* Fresh local produce

[^promotions]:Because if there's a promotion, you buy.

Some of your friends are also vegetarian.

Let's have a look at two different scenarios.

#### IRB scenario

You've invited and subsequently prepared dinner and the table—seats, plates and cutlery sets—for four, popped open your bottle of wine and fired up the grill. However, only one friend arrives, quite late. You're grilling steak number three, yet he's the vegetarian…and only drinks beer. And even then doesn't talk very much.

In the end, you down the whole bottle of wine and the three steaks. Life's good again. There's plenty to clean up and pack away, still.

#### Rails scenario

17 guests show up at your door. Half of them are heavily intoxicated because Dylan invited the rest of his wine tasting group, too. Only one eats any of your food, yet breaks four plates. Beer disappeared in three minutes. The group members reveal seven new bottles of wine, make your dog drink one and he kernel panics as a result.

You were not f*cking prepared. At all. Marinated steak's now ruined, there's less inventory and 30+ bottles to recycle. You're hungry and now there are no plates left!

In both of these scenarios, from the perspective of your friends it mostly worked out just fine. It wasn't optimal for you or your environment, though. What's important is that you learned a few things:
	* Next time it's easier to execute optimally, but there may still be a party and some broken plates.
	* A barbeque for 17 in your one bedroom flat with a George Foreman grill doesn't scale well.

## Cooking with Ruby

In the same manner, different use cases for the Ruby runtime require different preparations. Let's tie the dinner metaphor back to Ruby land and its memory model.

#### Home environment

The Ruby runtime, with everything else inside. Pages, objects and auxilary object data.

#### Guest count

The number of major features and facets you need to support. Gems and engines are good candidates along with individual models, controllers, views etc. These "seats" are also connected - different guests mingle together.

#### Guest distribution

Rails provides a framework for building applications, thus should be considered as part of the guest list too. Like some family members that make their way to gettogethers. First and second tier cousins you may hear of once a year and never talk with - they're present (consume memory), yet don't always add much value to the ambient.

#### Food and drink

The amount and distribution of objects required to make a feature or facet work. A mix bag of small entrees (embedded objects like 2-char strings), main dishes (a Rails request and all its context) to cocktails and tequila shots (threads!).

#### Plates and glasses 

An object slot on the Ruby heap. One String, Array, Hash or any other object. Keep in mind that they can overflow and be recycled too - a wine glass is good for multiple servings. For buffets, a single plate can go very far too :-)

#### Tables

Ruby pages - containers for objects. All of the plates and glasses on a given table. They're mostly prepared in advance, but you can "construct" and improvise as needed to.

#### Type of cuisine

Some dishes incur a lot of work to prepare *and* to clean up. Cooked basmati rice will leave a very very different footprint in your kitchen than a paella or salmon option would.

The GC defaults for most Rails applications assume a reasonable sized home environment, a well defined guest list and just enough food and drinks for each. Everyone can sit at the same table, wine and dine on fine dishes, all with a minimal cleanup burden.

*In reality, it's a frat party. Gone seriously wrong.*

*In the next part of this series, we're going to take a look at how the Ruby runtime can better host Rails applications. And what you can optimize for.*
