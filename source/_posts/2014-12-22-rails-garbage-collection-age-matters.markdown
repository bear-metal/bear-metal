---
layout: post
title: "Rails Garbage Collection: age matters"
author: Lourens
date: 2014-12-22 20:26
comments: true
keywords: ruby, rails, gc, garbage collection, generational gc
categories: [ruby, rails, gc, garbage collection, generational gc]
---

In a previous post [Rails Garbage Collection: naive defaults](https://bearmetal.eu/theden/rails-garbage-collection-naive-defaults/) we stated that Ruby GC defaults for [Ruby on Rails](http://www.rubyonrails.org) applications is not optimal. In this post we'll explore the basics of object age in RGenGC, Ruby 2.1's new *restricted generational garbage collector*.

As a prerequisite of this and subsequent posts, basic understanding of a `mark and sweep`[^marksweep] collector is assumed.

![](/images/gc_mark_sweep.png)

For simplicity we'll break it down as:

* Such a collector traverses the object graph
* It checks which objects are in use (referenced) and which ones are not
* This is called object marking, aka. the **MARK PHASE**
* All unused objects are freed, making their memory available
* This is called sweeping, aka. the **SWEEP PHASE**
* Nothing changes for used objects

A GC cycle prior to Ruby 2.1 works like that. A typical Rails app boots with 300 000 live objects of which all needs to be scanned during the **MARK** phase and usually yields a smaller set to **SWEEP**.

There's a large amount of the graph that's going to be traversed over and over again that will never be reclaimed. This is not only CPU intensive during GC cycles, but also incurs memory overhead for accounting and anticipation for future growth.

## Object references

In this simple example below we create an String array with 3 elements.

```ruby
	irb(main):001:0> require 'objspace'
	=> true
	irb(main):002:0> ObjectSpace.trace_object_allocations_start
	=> nil
	irb(main):003:0> ary = %w(a b c)
	=> ["a", "b", "c"]
```

Very much like a river flowing downstream, the Array has knowledge of (a "reference to") each of it's String elements. On the contrary, the Strings don't have an awareness of (or "references back to") the Array container.

```ruby
	irb(main):004:0> ObjectSpace.dump(ary)
	=> "{\"address\":\"0x007fd24b890fd8\", \"type\":\"ARRAY\", \"class\":\"0x007fd24b872038\", \"length\":3, \"embedded\":true, \"references\":[\"0x007fd24b891050\", \"0x007fd24b891028\", \"0x007fd24b891000\"], \"file\":\"(irb)\", \"line\":3, \"method\":\"irb_binding\", \"generation\":7, \"flags\":{\"wb_protected\":true}}\n"
	irb(main):004:0> ObjectSpace.reachable_objects_from(ary)
	=> [Array, "a", "b", "c"]
	irb(main):006:0> ObjectSpace.reachable_objects_from(ary[1])
	=> [String]
	irb(main):007:0> ObjectSpace.dump(ary[1])
	=> "{\"address\":\"0x007fd24b891028\", \"type\":\"STRING\", \"class\":\"0x007fd24b829658\", \"embedded\":true, \"bytesize\":1, \"value\":\"b\", \"encoding\":\"UTF-8\", \"file\":\"(irb)\", \"line\":3, \"method\":\"irb_binding\", \"generation\":7, \"flags\":{\"wb_protected\":true, \"old\":true, \"marked\":true}}\n"
```

## Old and young objects

The secret sauce for following along and understanding the basis of the new Garbage Collector is:

**MOST OBJECTS DIE YOUNG.**

Objects on the Ruby heap can thus be classified as either **OLD** or **YOUNG**. This segregation now allows the garbage collector to work with 2 distinct generations, with the **OLD** generation much less likely to yield much improvement towards recovering memory.

What generally makes an object old?

* All new objects are considered to be young.
* Old objects survived at least one GC cycle (workable for this first version of the generational collector)
* The collector thus reasons that the object will stick around and not become garbage quickly

For a typical Rails request, some examples of old and new objects would be:

* **Old:** compiled routes, templates, ActiveRecord connections, cached DB column info, classes, modules etc.
* **New:** short lived strings within a partial, a string column value from an ActiveRecord result, a coerced DateTime instance etc.

Young objects are more likely to reference old objects, than old objects referencing young objects. Old objects also frequently references other old objects.

```ruby
  u = User.first
  #<User id: 1, email: "lourens@something.com", encrypted_password: "blahblah...", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 2, current_sign_in_at: "2014-10-31 11:52:30", last_sign_in_at: "2014-10-29 10:04:01", current_sign_in_ip: "127.0.0.1", last_sign_in_ip: "127.0.0.1", created_at: "2014-10-29 10:04:01", updated_at: "2014-11-30 14:07:15", provider: nil, uid: nil, first_name: "dfdsfds", last_name: "dfdsfds", confirmation_token: nil, confirmed_at: "2014-10-30 10:11:42", confirmation_sent_at: nil, unconfirmed_email: nil, onboarded_at: nil>
```

Notice how the transient attribute keys/names reference the long lived columns here:

```ruby
	{"id"=>
	   #<ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::OID::Integer:0x007fbe756d1d30>,
	  "email"=>
	   #<ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::OID::Identity:0x007fbe756d1718>,
	  "encrypted_password"=>
	   #<ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::OID::Identity:0x007fbe756d1718>,
	  "reset_password_token"=>
	   #<ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::OID::Identity:0x007fbe756d1718>,
	  "reset_password_sent_at"=>
	   #<ActiveRecord::AttributeMethods::TimeZoneConversion::Type:0x007fbe741f63c0
	    @column=
	     #<ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::OID::Timestamp:0x007fbe756d0e58>>,
```

Age segregation is also just a classification - old and young objects aren't stored in distinct memory spaces - they're just conceptional buckets. The generation of an object refers to the amount of GC cycles it survived:

```ruby
irb(main):009:0> ObjectSpace.dump([])
=> "{\"address\":\"0x007fd24c007668\", \"type\":\"ARRAY\", \"class\":\"0x007fd24b872038\", \"length\":0, \"file\":\"(irb)\", \"line\":9, \"method\":\"irb_binding\", \"generation\":8, \"flags\":{\"wb_protected\":true}}\n"
irb(main):010:0> GC.count
=> 8
```

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

**Minor GC (or "partial marking"):** This cycle only traverses the young generation and is very fast. Based on the hypothesis that most objects die young, this GC cycle is thus the most effective at reclaiming back a large ratio of memory in proportion to objects traversed.

It runs quite often - 26 times for the GC dump of a booted Rails app above.

**Major GC:** Triggered by out of memory conditions - Ruby heap space needs to be expanded (not OOM killer! :-)) Both old and young objects are traversed and it's thus significantly slower. Generally when there's a significant increase in old objects, a major GC would trigger. Every major GC cycle that an object survived bumps it's current generation.

It runs much less frequently - 6 times for the stats dump above.

The following diagram represents a minor GC cycle that identifies and promotes some objects to oldgen.

![](/images/gc_first_minor.png)

A subsequent minor GC cycle ignores old objects during the mark phase.

![](/images/gc_second_minor.png)

Most of the reclaiming efforts are thus focussed on the young generation (new objects). Generally 95% of objects are dead by the first GC. Every major GC cycle that an object survived is it's current generation.

## RGenGC

At a very high level C Ruby 2.1's collector has the following properties:

* High throughput - it can sustain a high rate of allocations / collections due to faster minor GC cycles and very rare major GC cycles
* GC pauses are still long ("stop the world") for major GC cycles
* Generational collectors have much shorter mark cycles as it traverses only the young generation, most of the time.

This is a marked improvement to the C Ruby GC and serves as a base for implementing other advanced features moving forward. Ruby 2.2 supports incremental GC and object ages beyond just old and new definitions. A major GC cycle in 2.1 still runs in a "stop the world" manner, whereas a more involved incremental implementation (Ruby 2.2.) interleaves short steps of mark and sweep cycles between other VM operations.

## References between young and old objects

We stated earlier that:

**Young objects are more likely to reference old objects, than old objects referencing young objects. Old objects also frequently references other old objects.**

HOWEVER it's possible for old objects to reference new objects. What happens when old objects reference new ones?

Old objects with references to new objects are stored in a "remembered set". The remembered set is a container of references from old objects to new objects.

## Implications for Rails

As they say, "Nothing is faster than no code" and the same applies to automatic memory management. Every object allocation also has a variable recycle cost. Allocation generally is low overhead as it happens once, except for the use case where there's no free object slots on the Ruby heap and a major GC is triggered as a result.

A major drawback of this limited segregation of OLD vs YOUNG is that **many transient objects are in fact promoted to oldgen for large contexts like a Rails request**. These long lived objects eventually become unexpected "memory leaks". These transient objects can be conceptually classified as of "medium lifetime" as they need to stick around for the duration of a request. There's however a large probability that a minor GC would run during request lifetime, promoting young objects to oldgen, effectively increasing their lifetime to well beyond the end a request. This situation can only be revisited during a major GC which runs infrequently and sweeps both old and newgen.

**Each generation can be specifically tweaked, with the older generation being particularly important for balancing total process memory use with maintaining a minimal transient object set (young ones) per request. And subsequent too fast promotion from young to old generation.**

*In our next post we will explore how you'd approach tuning the Ruby GC for Rails applications, balancing tradeoffs of speed and memory*

[^marksweep]:See the Ruby Hacking Guide's [GC chapter](https://ruby-hacking-guide.github.io/gc.html) for further context and nitty gritty details. I'd recommended scanning the content below the first few headings, until turned off by C.

