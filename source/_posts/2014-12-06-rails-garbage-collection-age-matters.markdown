---
layout: post
title: "Rails Garbage Collection: age matters"
author: Lourens
date: 2014-12-06 20:26
comments: true
keywords: ruby, rails, gc, garbage collection, generational gc
categories: [ruby, rails, gc, garbage collection, generational gc]
---

In a previous post [Rails Garbage Collection: naive defaults](http://www.bear-metal.eu) we stated that Ruby GC defaults for [Ruby on Rails](http://www.rubyonrails.org) applications is not optimal. In this post we'll explore the basics of object generations in RGenGC, Ruby 2.1's new *restricted generational garbage collector*.

As a prerequisite of this and subsequent posts, basic understanding of a [Mark and Sweep](https://ruby-hacking-guide.github.io/gc.html) collector is assumed. I'd recommended scanning the content below the first few headings, until turned off by C.

## Generations

The secret sauce for following along and understanding the basis of the new Garbage Collector is:

MOST OBJECTS DIE YOUNG.

Objects on the Ruby heap can thus be classified as either OLD or YOUNG.

Young objects are more likely to reference old objects, than old objects referencing young objects.
HOWEVER it's possible for old objects to reference new objects.

What generally makes an object old?

* All new objects are considered to be young.
* Old objects survived at least one GC cycle (workable for this first version of the generational collector)
* The collector thus reasons that the object will stick around and not become garbage quickly

What happens when old objects references new ones?

Old objects with references to new objects are stored in a "remembered set". The remembered set is thus a container of references 

There's other rules such as the remembered set and write barriers that also govern promotion to the older generation, but it's beyond the scope for what we're covering here.

Generations are also just classifications - old and young objects aren't stored in distinct memory spaces.

## What the heck is major and minor GC?

You may have heard, read about or noticed in GC.stat output the terms "minor" and "major" GC.

```ruby
	irb(main):003:0> pp GC.stat
	{:count=>32,
	 :heap_used=>1181,
	 :heap_length=>1233,
	 :heap_increment=>50,
	 :heap_live_slot=>325148,
	 :heap_free_slot=>156231,
	 :heap_final_slot=>0,
	 :heap_swept_slot=>163121,
	 :heap_eden_page_length=>1171,
	 :heap_tomb_page_length=>10,
	 :total_allocated_object=>2050551,
	 :total_freed_object=>1725403,
	 :malloc_increase=>1462784,
	 :malloc_limit=>24750208,
	 :minor_gc_count=>26,
	 :major_gc_count=>6,
	 :remembered_shady_object=>3877,
	 :remembered_shady_object_limit=>4042,
	 :old_object=>304270,
	 :old_object_limit=>259974,
	 :oldmalloc_increase=>23639792,
	 :oldmalloc_limit=>24159190}
```

Minor GC: This cycle only traverses the young generation and is very fast. Based on the hypothesis that most objects die young, this GC cycle is thus the most effective at reclaiming back a large ratio of memory in proportion to objects traversed.

It runs quite often - 26 times for the GC dump of a booted Rails app above.

Major GC: Triggered by out of memory conditions - Ruby heap space needs to be expanded (not OOM killer! :-)) Both old and young generations are traversed and it's thus significantly slower.

It runs much less frequently - 6 times for the stats dump above.

Most of the reclaiming efforts are thus focussed on the young generation (new objects). Generally 95% of objects are dead by the first GC

## Attributes of a generational collector

At a very high level C Ruby 2.1's collector has the following properties:

* High throughput - it can sustain a high rate of allocations / collections due to faster minor GC cycles and very rare major GC cycles
* GC pauses are still long ("stop the world") for major GC cycles
* Generational collectors have much shorter mark cycles as it traverses only the young generation, most of the time.

This is a marked improvement to the C Ruby GC and serves as a base for implementing other advanced features moving forward. Ruby 2.2 supports incremental GC and a object ages beyond just old and new definitions. A major GC cycle in 2.1 still runs in a "stop the world" manner, whereas a more involved incremental implementation interleaves short steps of mark and sweep cycles between other VM operations.

## Implications for Rails

As they say, "Nothing is faster than no code" and the same applies to automatic memory management. Every object allocation also has a variable recycle cost. Allocation generally is low overhead as it happens once, except for the use case where there's no free object slots on the Ruby heap and a major GC is triggered as a result.

A major drawback of this limited segregation of OLD vs YOUNG is that many transient objects are in act promoted to oldgen for large contexts like a Rails request. These long lived objects eventually become unexpected "memory leaks".
