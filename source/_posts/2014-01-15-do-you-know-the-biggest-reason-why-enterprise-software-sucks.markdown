---
layout: post
title: Do you know the biggest reason for why enterprise software sucks?
author: Jarkko
date: 2014-01-15 11:43
comments: true
keywords: software, business, craftsmanship, philosophy
categories: [software, business, craftsmanship, philosophy]
---

*We all know the story. Your company was going to get this big new shiny ERP software. It was going to replace a third of the workforce in the company, cut the costs in half and make everyone happy. In reality the project went two years over schedule, cost three times as much as envisioned, and the end result was a steaming pile of shit.*

[![](https://farm9.staticflickr.com/8453/8043877054_883963cf80_c.jpg)](http://www.flickr.com/photos/53326337@N00/8043877054/)

<small>Photo by [Quinn Dombrowski](http://www.flickr.com/photos/53326337@N00/8043877054/), used under the Creative Commons license.</small>

At this point started the blame-throwing. The provider duped the client with waterfall and exorbitant change fees. The buyer didn't know how to act as a client in an information system project. The specs weren't good/detailed/strict/loose enough. The consultants just weren't that good in the first place. On and on and on.

While one or more of the above invariably are true in failed software projects, there's one issue that almost each and every failed enterprise software project has in common: *the buyers were not (going to be) the users of the software*.

This simple fact has huge implications. Ever heard that “the client didn't really know what they wanted”? Well, that's because they didn't. Thus, most such software projects are built with something completely different than the end user in mind. Be it the ego of the CTO, his debt to his mason brothers who happen to be in the software business[^many-horses], or just the cheapest initial bid[^nevermind]. In any case, it's in the software provider's best interest to appeal to the decisionmaker, not the people actually using the system.

Of course, not every software buyer is as bad as described above. Many truly care about the success of the system and even its users. If for no other reason, at least because it has a direct effect on the company's bottom line. But even then, they just don't have the first-hand experience of working in the daily churn. They simply can't know what's best for the users. Of course, this gets even worse in the design-by-committee, big-spec-upfront projects.

Since it's not very likely that we could change the process of making large software project purchases any time soon, what can we as software vendors do? One word: *empathy*. If you just take a spec and implement it with no questions asked, shame on you. You deserve all the blame. Your job is not to implement what the spec says. Heck, your job isn't even to create what the client wants. Your job is to build what the client – no, the end users – need. For this – no matter how blasphemous it might sound to an engineer – you have to actually *talk* to the people that will be using your software.

This is why it's so important to put the software developers to actually do what the end-users would. **If you're building call-center software, make the developers work in the call center a day or a week. If you're building web apps, make the developers and designers work the support queue, don't just outsource it to India.**

There is no better way to understand the needs for software you're building than to talk directly to its users or use it yourself for real, in a real-life situation. While there aren't that many opportunities to dog-fooding when building (perhaps internal) enterprise software for a client, there's nothing preventing you from sending your people to the actual cost center. Nothing will give as much insight to the needs and pains of the actual users. No spec will ever give you as broad a picture. No technical brilliance will ever make up for lacking domain knowledge. And no client will ever love you as much as the one in the project where you threw yourself (even without being asked) on the line of fire. That's what we here at Bear Metal insist on doing at the start of every project. I think you should, too.

---

*We at Bear Metal have some availability open for short and mid-term projects. If you're looking for help building, running, scaling or marketing your web app,  [get in touch](mailto:info@bearmetal.eu).*

[^many-horses]:It's surprising how often the same people actually represent both the buyer and the seller. This happens all the time e.g. in the patient care systems projects.

[^nevermind]:Nevermind that the cheapest initial bid almost always balloons to something completely different in the end.