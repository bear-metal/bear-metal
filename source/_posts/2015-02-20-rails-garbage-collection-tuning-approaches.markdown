---
layout: post
title: "Rails Garbage Collection: Tuning Approaches"
date: 2015-02-20 09:19:02 +0200
comments: true
author: Lourens
keywords: ruby, rails, gc, garbage collection, generational gc, rails performance
categories: [ruby, rails, gc, garbage collection, generational gc, 'rails performance']
published: false
---

MRI maintainers have put a tremendous amount of work into improving the garbage collector in Ruby 2.0 through 2.2. The engine has thus gained a lot more horsepower. However, it's still not trivial to get the most out of it. In this post we're going to gain a better understanding of how and what to tune for.

Koichi Sasada (_ko1, Ruby MRI maintainer) famously mentioned in a [presentation (slide 89)](http://www.atdot.net/~ko1/activities/2014_rubyconf_ph_pub.pdf):

>  **Try GC parameters**
>
>  * There is no silver bullet
>    * No one answer for all applications
>    * You should not believe other applications settings easily
>  * Try and try and try!

This is true in theory but a *whole lot harder* to pull off in practice due to three primary problems:

* Interpreter GC semantics and configuration change over time.
* One GC config isn't optimal for all app runtime contexts: tests, requests, background jobs, rake tasks, etc.
* During the lifetime and development cycles of a project, it's very likely that existing GC settings are invalidated quickly.

### An evolving Garbage Collector

The garbage collector has frequently changed in the latest MRI Ruby releases. The changes have also broken many existing assumptions and environment variables that tune the GC. Compare <code>GC.stat</code> on Ruby 2.1:

```ruby
{ :count=>7, :heap_used=>66, :heap_length=>66, :heap_increment=>0,
  :heap_live_slot=>26397, :heap_free_slot=>507, :heap_final_slot=>0,
  :heap_swept_slot=>10698, :heap_eden_page_length=>66, :heap_tomb_page_length=>0,
  :total_allocated_object=>75494, :total_freed_object=>49097,
  :malloc_increase=>465840, :malloc_limit=>16777216, :minor_gc_count=>5,
  :major_gc_count=>2, :remembered_shady_object=>175,
  :remembered_shady_object_limit=>322, :old_object=>9109, :old_object_limit=>15116,
  :oldmalloc_increase=>1136080, :oldmalloc_limit=>16777216 }
```

…with Ruby 2.2:

```ruby
{ :count=>6, :heap_allocated_pages=>74, :heap_sorted_length=>75,
  :heap_allocatable_pages=>0, :heap_available_slots=>30162, :heap_live_slots=>29729,
  :heap_free_slots=>433, :heap_final_slots=>0, :heap_marked_slots=>14752,
  :heap_swept_slots=>11520, :heap_eden_pages=>74, :heap_tomb_pages=>0,
  :total_allocated_pages=>74, :total_freed_pages=>0,
  :total_allocated_objects=>76976, :total_freed_objects=>47247,
  :malloc_increase_bytes=>449520, :malloc_increase_bytes_limit=>16777216,
  :minor_gc_count=>4, :major_gc_count=>2, :remembered_wb_unprotected_objects=>169,
  :remembered_wb_unprotected_objects_limit=>278, :old_objects=>9337,
  :old_objects_limit=>10806, :oldmalloc_increase_bytes=>1147760,
  :oldmalloc_increase_bytes_limit=>16777216 }
```

In Ruby 2.2 we can see a lot more to introspect and tune, but this also comes with a steep learning curve which is (and should be) out of scope for most developers.

### One codebase, different roles

A modern Rails application is typically used day to day in different contexts:

* Running tests
* rake tasks
* database migrations
* background jobs

They all start pretty much the same way with the VM compiling code to instruction sequences. Different roles affect the Ruby heap and the garbage collector in very different ways, however.

This job typically runs for 13 minutes, triggers 133 GC cycles and allocates a metric ton of objects. Allocations are very bursty and in batches.

```ruby
class CartCleanupJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    Cart.cleanup(Time.now)
  end
end
```

This controller action allocates 24 555 objects. Allocator throughput isn't very variable.

```ruby
class CartsController < ApplicationController
  def show
    @cart = Cart.find(params[:id])
  end
end
```

Our test case contributes 175 objects to the heap. Test cases generally are very variable and bursty in allocation patterns.

```ruby
def test_add_to_cart
  cart = carts(:empty)
  cart << products(:butter)
  assert_equal 1, cart.items.size
end
```

The default GC behavior isn't optimal for all of these execution paths within the same project and neither is [throwing](http://www.reddit.com/r/ruby/comments/2m663d/ruby_21_gc_settings) a single set of `RUBY_GC_*` environment variables at it.

We'd like to refer to processing in these different contexts as "units of work".

### Fast development cycles

During the lifetime and development cycle of a project, it's very likely that garbage collector settings that were valid yesterday aren't optimal anymore after the next two sprints. Changes to your Gemfile, rolling out new features, and bumping the Ruby interpreter all affect the garbage collector.

```ruby
source 'https://rubygems.org'

ruby '2.2.0' # Invalidates most existing RUBY_GC_* variables

gem 'mail' # slots galore
```

## Process lifecycle events

Let's have a look at a few events that are important during the lifetime of a process. They help the tuner to gain valuable insights into how well the garbage collector is working and how to further optimize it. They all hint at how the heap changes and what triggered a GC cycle.

How many mutations happened for example while

* processing a request
* between booting the app and processing a request
* during the lifetime of the application?

### When it booted

*When the application is ready to start doing work.* For Rails application, this is typically when the app has been fully loaded in production, ready to serve requests, ready to accept background work, etc. All source files have been loaded and most resources acquired.

### When processing started

*At the start of a unit of work.* Typically the start of an HTTP request, when a background job has been popped off a queue, the start of a test case or any other type of processing that is the primary purpose of running the process.

### When processing ended

*At the end of a unit of work.* Typically the end of a HTTP request, when a background job has been popped off a queue, the end of a test case or any other type of processing that is the primary purpose of running the process.

### When it terminated

Triggered when the application terminates.

## Knowing when and why GC happens

Tracking GC cycles interleaved with the aforementioned application events yield insights into why a particular GC cycle happens. The progression from BOOTED to TERMINATED and everything else is important because mutations that happen during the fifth HTTP request of a new Rails process also contribute to a GC cycle during request number eight.

## On tuning

Primarily the garbage collector exposes tuning variables in these three categories:

* Heap slot values: where Ruby objects live
* Malloc limits: off heap storage for large strings, arrays and other structures
* Growth factors: by how much to grow slots, malloc limits etc.

Tuning GC parameters is generally a tradeoff between tuning for speed (thus using more memory) and tuning for low memory usage while giving up speed. We think it's possible to infer a reasonable set of defaults from observing the application at runtime that's conservative with memory, yet maintain reasonable throughput.

## A solution

We've been working on a product, [TuneMyGC](https://tunemygc.com) for a few weeks that attempts to do just that. Our goals and objectives are:

* A repeatable and systematic tuning process that respects fast development cycles
* It should have awareness of runtime profiles being different for HTTP requests, background job processing etc.
* It should support current mainline Ruby versions without developers having to keep up to date with changes
* Deliver reasonable memory footprints with better runtime performance
* Provide better insights into GC characteristics both for app owners and possibly also ruby-core

Here's an example of [Discourse](http://www.discourse.org) being automatically tuned for better 99th percentile throughput. Response times in milliseconds, 200 requests:

| *Controller*  | *[GC defaults](https://tunemygc.com/configs/c5214cfa00b3bf429badd2161c4b6a08)* | *[Tuned GC](https://tunemygc.com/configs/e129791f94159a8c75bef3a636c05798)* |
| ----------- | ------------ | -------------- |
| categories  |     227      |    160         |
| home        |     163      |    113         |
| topic       |     55       |    40          |
| user        |     92       |    76          |

#### [GC defaults](https://tunemygc.com/configs/c5214cfa00b3bf429badd2161c4b6a08):

```bash
$ RUBY_GC_TUNE=1 RUBY_GC_TOKEN=a5a672761b25265ec62a1140e21fc81f ruby script/bench.rb -m -i 200
```

Raw GC stats from Discourse's bench.rb script:

```bash 
GC STATS:
count: 106
heap_allocated_pages: 2447
heap_sorted_length: 2455
heap_allocatable_pages: 95
heap_available_slots: 997407
heap_live_slots: 464541
heap_free_slots: 532866
heap_final_slots: 0
heap_marked_slots: 464530
heap_swept_slots: 532876
heap_eden_pages: 2352
heap_tomb_pages: 95
total_allocated_pages: 2447
total_freed_pages: 0
total_allocated_objects: 27169276
total_freed_objects: 26704735
malloc_increase_bytes: 4352
malloc_increase_bytes_limit: 16777216
minor_gc_count: 91
major_gc_count: 15
remembered_wb_unprotected_objects: 11669
remembered_wb_unprotected_objects_limit: 23338
old_objects: 435435
old_objects_limit: 870870
oldmalloc_increase_bytes: 4736
oldmalloc_increase_bytes_limit: 30286118 

```

### [TuneMyGC recommendations](https://tunemygc.com/configs/e129791f94159a8c75bef3a636c05798)

```bash
$ RUBY_GC_TUNE=1 RUBY_GC_TOKEN=a5a672761b25265ec62a1140e21fc81f RUBY_GC_HEAP_INIT_SLOTS=997339 RUBY_GC_HEAP_FREE_SLOTS=626600 RUBY_GC_HEAP_GROWTH_FACTOR=1.03 RUBY_GC_HEAP_GROWTH_MAX_SLOTS=88792 RUBY_GC_HEAP_OLDOBJECT_LIMIT_FACTOR=2.4 RUBY_GC_MALLOC_LIMIT=34393793 RUBY_GC_MALLOC_LIMIT_MAX=41272552 RUBY_GC_MALLOC_LIMIT_GROWTH_FACTOR=1.32 RUBY_GC_OLDMALLOC_LIMIT=39339204 RUBY_GC_OLDMALLOC_LIMIT_MAX=47207045 RUBY_GC_OLDMALLOC_LIMIT_GROWTH_FACTOR=1.2 ruby script/bench.rb -m -i 200
```

Raw GC stats from Discourse's bench.rb script:

```bash
GC STATS:
count: 44
heap_allocated_pages: 2893
heap_sorted_length: 2953
heap_allocatable_pages: 161
heap_available_slots: 1179182
heap_live_slots: 460935
heap_free_slots: 718247
heap_final_slots: 0
heap_marked_slots: 460925
heap_swept_slots: 718277
heap_eden_pages: 2732
heap_tomb_pages: 161
total_allocated_pages: 2893
total_freed_pages: 0
total_allocated_objects: 27167493
total_freed_objects: 26706558
malloc_increase_bytes: 4352
malloc_increase_bytes_limit: 34393793
minor_gc_count: 34
major_gc_count: 10
remembered_wb_unprotected_objects: 11659
remembered_wb_unprotected_objects_limit: 27981
old_objects: 431838
old_objects_limit: 1036411
oldmalloc_increase_bytes: 4736
oldmalloc_increase_bytes_limit: 39339204
```

We can see a couple of interesting points here:

* There is much less GC activity – only 44 rounds instead of 106.
* Slot buffers are still decent for high throughput. (TODO: explain what this means and what data reveals it)
* Malloc limits and growth factors are in line with actual app usage (TODO: what does this mean, how do you know they are inline?)

Now it's your turn.

## Feel free to take your Rails app for a spin too!

### 1. Add to your Gemfile.

```bash
gem 'tunemygc'
```

### 2. Register your Rails application.
```bash
$ bundle exec tunemygc -r email@yourdomain.com
      Application registered. Use RUBY_GC_TOKEN=08de9e8822c847244b31290cedfc1d51 in your environment.
```
### 3. Boot your app. We recommend an optimal GC configuration when it ends
```bash
$ RUBY_GC_TOKEN=08de9e8822c847244b31290cedfc1d51 RUBY_GC_TUNE=1 bundle exec rails s
```