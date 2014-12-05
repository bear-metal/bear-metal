---
layout: post
title: "Rails Garbage Collection: junk food"
author: Lourens
date: 2014-12-04 17:27
comments: true
keywords: ruby, rails, gc, garbage collection
categories: [ruby, rails, gc, garbage collection]
---

The vast majority of Ruby and Rails applications deploy to production with the vanilla Ruby GC configuration. A conservative combination of growth factors and accounting that "works" for a demographic from IRB sessions (still my preferred calculator) to massive monolithic Rails apps (the fate of most successful ones). Except in practice this doesn't work very well:

* Too aggressive growth of Ruby heap slots and pages when thresholds are reached
* A large ratio of short and medium lived objects in relation to long lived ones for Rails applications
* Too many intermittent major GC cycles during the request / response cycle
* Heap fragmentation

Let's context switch to a metaphor most of us can better relate to. *Dreaded household chores.* Your ability and frequency of hosting dinners at home are limited by four things (takeaways and paper plates aside):

* Quantity of available ingredients
* How many seats you have
* How many sets of clean cutlery, plates and other utensils are available
* Willingness to clean up and do dishes

This is what you have to work with at home:

* 4 chairs and a table
* 12 plates and equivalent utensils
* 83 friends (60 from Facebook, 20 at work, your 2 brothers and then there's Jim)
* 3 wine glasses and a beer mug
* 1 bottle of wine and 24 beers. because if there's promotions, you buy.
* 3 awesome steaks and a piece of tofu
* Fresh local produce

Some of your friends are vegetarian.

#### IRB scenario

You've invited and subsequently prepared dinner and the table for 4. 4 seats, 4 plates and cutlery sets, popped open your bottle of wine and fired up the grill. Only 1 friend arrives quite late, you're grilling steak number 3, yet he's the vegetarian. And only drinks beer. And even then doesn't talk very much.

You consume the bottle of wine and the 3 steaks. Life's good again. Plenty to cleanup and pack away still.

#### Rails scenario

17 guests show up at your door. Half is heavily intoxicated because Dylan invited the rest of his wine tasting group too. Only one eats any of your food, yet breaks 4 plates. Beer disappeared in 3 minutes. They reveal 7 new bottles of wine, makes your dog drink one and he kernel panics as a result.

You were not f*cking prepared. At all. Marinated steak's now ruined, there's less inventory and 30+ bottles to recycle. You're hungry and now there's no plates left!

#### On being a better host

In both of these scenarios, from the perspective of your friends it mostly worked out just fine. It wasn't optimal for you or your environment though. What's important is that you learned a few things. Next time it's easier to execute optimally, but there may still be a party and some broken plates. And a barbeque for 17 in your one bedroom flat with a George Foreman grill doesn't scale well.

## Cooking with Ruby

In the same manner, different use cases for the Ruby runtime require different preparations. We can easily tie the dinner metaphor back to Ruby land and it's memory model.

#### Home environment

The Ruby runtime, with everything else inside. Pages, objects and auxilary object data.

#### Guest count

The number of major features and facets you need to support. Gems and engines are good candidates along with individual models, controllers, views etc. These "seats" are also connected - different guests mingle together.

#### Guest distribution

Rails provides a framework for building applications, thus should be considered as part of the guest list too. Like some family members that make their way to get togehers. First and second tier cousins you may hear of once a year and never talk with - they're present (consume memory), yet doesn't always add much value to the ambient.

#### Food and drink

The amount and distribution of objects required to make a feature or facet work. A mix bag of small entrees (embedded objects like 2 char strings), main dishes (a Rails request and all it's context) to cocktails and tequilla shots (threads!).

#### Plates and glasses 

An object slot on the Ruby heap. One String, Array, Hash or any other object. Keep in mind that they can overflow and be recycled too - a wine glass is good for multiple servings. For buffets, a single plate can go very far too :-)

#### Tables

Ruby pages - containers for objects. All of the plates and glasses on a given table. They're mostly prepared in advance, but you can "construct" and improvise as needed to.

#### Type of food

Some dishes incur a lot of work to prepare AND to clean up. Cooked basmati rice will leave a very very different footprint in your kitchen than a paella or salmon option would.

*In the next part of this series, we're going to take a look at how the Ruby runtime can better host Rails applications. And what you can optimize for.*
