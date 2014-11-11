---
layout: post
title: "Are you flying blind – How to Regain Control of Production Systems with the Help of Situation Awareness?"
author: Lourens
date: 2013-09-03 16:57
comments: true
keywords: operations, situation awareness, process, release, devops
categories: [business,operations, process, release]
---

<figure markdown="1">
  [![](https://farm4.staticflickr.com/3454/3391187126_4e62f6a374_b.jpg)](http://www.flickr.com/photos/robbn1/3391187126/)

<figcaption markdown="1">
Photo by [Robb North](http://www.flickr.com/photos/robbn1/3391187126/)
</figcaption>
</figure>

A few months of work during a sabbatical yielded a product that nailed a problem in the preventative healthcare space. After a freemium window, the product gained good market traction and you spawn a new company with three coworkers. Customers are raving, sales trends are on the up, the engineering team is growing and there are conceptual products in the pipeline.

Three months down the line, there are 4 production applications, hordes of paying customers, a few big contracts with strict SLAs (service-level agreements) and enough resources to spin off a presence in Europe. A new feature that combines these products into a suite is slated for release. Engineering hauled ass for 2 months and sales is super stoked to be able to pitch it to customers.

## Shipping

A few days before the feature release a set of new servers is provisioned to buffer against the upcoming marketing push. Due diligence on various fronts was completed, mostly through static analysis of the current production stack by various individuals. Saturday morning at 1am PST they deploy during a window with a historically low transaction volume. Representatives of a few departments sign off on the release, although admittedly there are still dark corners and the OK is mostly based off a few QA passes. Champagne pops, drinks are being had and everyone calls it a day. But then...

## When things go south

At 9am PST various alerts flood the European operations team - only 25% of the platform's available, support is overwhelmed and stress levels go up across the board. Some public facing pages load intermittently, MySQL read load is sky high and application log streams are blank. This deployment, as with most naive releases, was flying blind. A snapshot of a working system prior to release isn't of much value if it can't be easily reproduced after rollout for comparison.

Based on assumptions about time, space and other variables there was a total lack of **situation awareness** and thus no visibility into expected impact of these changes. Running software that pays the bills is today more important than a flashy new feature. However, one must move forward and there are processes and tools available for mitigating risk.

## What is situation awareness?

Situation awareness can be defined as an engineering team's knowledge of both the internal and external states of their production systems, as well as the environment in which it is operating. Internal states refer to health checks, statistics and other monitoring info. The external environment refers to things we generally can't directly control: Humans and their reactions; hosting providers and their networks; acts of god and other environmental issues.

It's thus *a snapshot in time of system status that provides the primary basis for decision making and operation of complex systems*. Experience with a given system gives team members the ability to remain aware of everything that is happening concurrently and to integrate that sense of awareness into what they're doing at any moment.

## How situation awareness could have helped?

The new feature created a dependency tree between 4 existing applications, a lightweight data synchronization service (Redis) and the new nodes that were spun up. Initial investigation and root cause analysis revealed that the following went wrong:

* The Redis server was configured for only 1024 connections and it tanked over when backends warmed up as the client connection was lazily initialized.
* Initial data synchronization (cache warmup) put excessive load on MySQL and other data stores also used for customer facing reporting.
* The data payloads used for synchronization were often very large for outlier customers, effectively blocking the Redis server's event loop, also causing memory pressure.
* The new nodes were spun up with a wrong Ruby major version and also missed critical packages required for normal operations.
* A new feature that rolls the "logger" utility into some core init scripts piggybacked on this release. A syntax error fubar'ed output redirection and thus there weren't any log streams.

Without much runtime introspection in place, it was very difficult to predict what the release impact would be. Although not everything could be covered ahead of time for this release, even with basic runtime analysis, monitoring and good logging it would have been possible to spot trends and avoid issues bubbling up systematically many hours later.

Another core issue here is the "low traffic" release window. It's often considered good practice to release during such times to minimize fallout for the worst case, however it's sort of akin to commercial Boeing pilots only training on Cessnas. Any residual and overlooked issues tend to also only surface hours later when traffic ramps up again. This divide between cause and effect complicates root cause analysis immensely. You'd want to be able to infer errors from the system state, worst case QA or an employee and most definitely not customers interacting with your product at 9am.

One also cannot overlook the fact that suddenly each team now had a direct link with at least 3 other applications, new (misconfigured) backends and Redis at this point in time. Each team however only still mostly had a mental model of a single isolated application.

## Why situation awareness is so important?

We at Bear Metal have been through a few technology stacks in thriving businesses and noticed a recurring theme and problem. Three boxes become fifty, ad-hoc nodes are spun up for testing, special slaves are provisioned for data analysis, applications are careless with resources and a new service quickly becomes a platform-wide single point of failure. Moving parts increase exponentially and so do potential points of failure.

Engineering, operations and support teams often have no clue what runs where, or what the dependencies are between them. This is especially true for fast growing businesses that reach a  critical mass - teams tend to become more specialized, information silos are common and thus total system visibility is also quite narrow. Having good knowledge of your runtime (or even just a perception) is instrumental in making informed decisions for releases, maintenance, capacity planning and discovering potential problems ahead of time. Prediction only makes sense once there's a good perception of "current state" in place to minimize the rendering of fail whales.

## Web operations and awareness

Operations isn't about individuals, but teams. The goal is to have information exchange between team members and other teams being as passive as possible. Monitoring, alerting and other push based systems help a lot with passive learning about deployments. It's mostly effortless and easy for individuals to build up knowledge and trends over time.

However, when we actively need to search for information, we can only search for what we already know exists. It's impossible to find anything we're not aware of. Given the primary goal of an operations team is platform stability in the face of changes, time to resolution (TTR) is always critical and actively seeking out information when under pressure is a luxury.

Historically a systemwide view has always been the territory of the CTO, operations team and perhaps a handful of platform or integration engineers. Inline with devops culture, we need to acknowledge this disconnect and explore solutions for raising situation awareness of critical systems for all concerned.

## And now

Take a minute and ponder the following :

* How well do you think you know your systems?
* Are developers able to infer potential release risks themselves?
* When things go south, how well informed is your support team and what information can they give customers?
* Are you comfortable releasing at any time?

In our next post, we'll explore some common components, variables and events required for being "on top" of your stack. In the meantime, what causes you the most pain when trying to keep up with your production systems? What would you write a blank cheque for? :-)

[Discuss on Hacker News](https://news.ycombinator.com/item?id=6332734).