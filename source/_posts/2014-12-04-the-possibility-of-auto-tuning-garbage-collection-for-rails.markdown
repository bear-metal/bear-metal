---
layout: post
title: The possibility of auto-tuning Garbage Collection for Rails
author: Lourens
date: 2014-12-04 17:27
comments: true
keywords: ruby, rails, gc, garbage collection
categories: [ruby, rails, gc, garbage collection]
---

The vast majority of Ruby and Rails applications deploy to production with the vanilla Ruby GC configuration. A conservative combination of growth factors and accounting that "works" for a demographic from IRB sessions (still my preferred calculator) to massive monolithic Rails apps (the fate of most successful ones). But does it work well?

Let's context switch to a hypothetical scenario most of us can better relate to. *Household chores.* Your ability and frequency of hosting dinners at home are limited by four things (takeaways and paper plates aside):

* Quantity of available ingredients
* How many seats you have
* How many sets of clean cutlery, plates and other utensils are available
* Willingness to clean up and do dishes

There's other indirect factors too, like quality of ingredients (if it sucks, dinners won't be recurring), if your friends mind standing while eating and off course eating almost everything by hand in some cultures.

This is what you have to work with:

* 4 chairs and a table
* 12 plates and equivalent utensils
* 83 friends (60 from Facebook, 20 at work, your 2 brothers and then there's Jim)
* 3 wine glasses and a beer mug
* 1 bottle of wine and 24 beers. because if there's promotions, you buy.
* 3 awesome steaks and a piece of tofu
* Fresh local produce

Some of your friends are vegetarian. They're a brady bunch with a very very wide emotional range.

#### IRB scenario

You've invited and subsequently prepared dinner and the table for 4. 4 seats, 4 plates and cutlery sets, popped open your bottle of wine and fired up the grill. Only 1 friend arrives quite late, you're grilling steak number 3, yet he's the vegetarian. And only drinks beer. And even then doesn't talk very much.

You consume the bottle of wine and the 3 steaks. Life's good again. Plenty to cleanup and pack away still.

#### Rails scenario

17 guests show up at your door. Half is heavily intoxicated because Dylan invited the rest of his wine tasting group too. Only one eats any of your food, yet breaks 4 plates. Beer disappeared in 3 minutes. They reveal 7 new bottles of wine, makes your dog drink one and he kernel panics as a result.

You were not f*cking prepared. At all. Marinated steak's now ruined, there's less inventory and 30+ bottles to recycle. You're hungry and now there's no plates left!

#### On being a better host

In both of these scenarios, from the perspective of your friends it mostly worked out just fine. It wasn't optimal for you or your environment though. It was difficult to pull off, but what's important is that you learned a few things. To be a better host and that generally catering is hard. A barbeque for 17 in your one bedroom flat with a George Foreman grill doesn't scale well. Neither does throwing a big bash without any friends.

Next time it's easier to execute optimally, but there may still be a party and some broken plates. And that's OK.

Dinner. Next week. Our place (The Bear Den).
