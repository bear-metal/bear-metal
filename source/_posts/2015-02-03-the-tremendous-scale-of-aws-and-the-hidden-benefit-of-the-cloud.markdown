---
layout: post
title: "The Tremendous Scale of AWS and the Hidden Benefit of the Cloud"
date: 2015-02-03 15:14:35 +0200
comments: true
categories: [amazon, cloud, devops, deployment, business]
description: "A sad tale of vendor lock-in, and a hopeful future."
author: Jarkko
---

<figure markdown="1">
  <a href="https://www.flickr.com/photos/infomastern/14852324010/">
    <img src="https://farm4.staticflickr.com/3918/14852324010_9a0d2d1887_b.jpg">
  </a>

  <figcaption>
    <p>
      Photo by <a href="https://www.flickr.com/photos/infomastern/14852324010/">Susanne Nilsson</a>, used under a Creative Commons license.
    </p>
  </figcaption>
</figure>

Finland, 2013. Vantaa, the second largest municipality in Finland buys a new web form for welfare applications from CGI (née Logica, née WM-Data) for a whopping €1.9 million. The story doesn't end there, though. A month later it turns out, that Helsinki has bought the exact same form from CGI as well, for €1.85 million.

Now, you can argue about what is a fair value for a single web form, especially when it has to be integrated to an existing information system. What is clear though, that it is not almost 2 million Euros, twice.

“How on earth was that possible,” I hear you ask. Surely someone would have offered to do that form for, say, 1 million a pop. Heck, even the Finnish law for public procurements mandates public competitive bidding for such projects.

Vendor lock-in. CGI was administering the information system on which the form was to be built. And since they held the key, they could pretty much ask for as much as the municipalities could potentially pay for the form.

Now hold that thought.

---

Over at [High Scalability](http://highscalability.com/blog/2015/1/12/the-stunning-scale-of-aws-and-what-it-means-for-the-future-o.html), Todd Hoff writes about James Hamilton's talk at the AWS re:Invent conference last November. It reveals how gigantic the scale of Amazon Web Services really is:

> Every day, AWS adds enough new server capacity to support all of Amazon’s global infrastructure when it was a $7B annual revenue enterprise (in 2004).

This also means that AWS is leaps and bounds above its competitors when it comes to capacity:

> All 14 other cloud providers combined have 1/5th the aggregate capacity of AWS (estimate by Gartner)

This of course gives AWS a huge benefit compared to its competitors. It can run larger datacenters both close and far from each others; they can get sweetheart deals and custom-made components from Intel for servers, just like Apple does with laptops and desktops. And they can afford to design their own network gear, the one field where the progress hasn't followed the Moore's law. There the only other companies who do the same are other internet giants like Google and Facebook, but they're not in the same business as AWS[^1].

All this is leading to a situation where **AWS is becoming the IBM of the 21st century**, for better or for worse. Just like no one ever got fired for buying IBM in the 80's, few will likely get fired for choosing AWS in the years to come. This will be a tough, tough nut to crack for Amazon's customers.

So far the situation doesn't seem to have slowed down Amazon's rate of innovation, and perhaps they have learned the lessons of the big blue. Only future will tell.

From a customer's perspective, a cloud platform like AWS brings lots and lots of benefits – well listed in the article above – but of course also downsides. Computing power is still much cheaper when bought in physical servers. You can rent a monster Xeon server with basically unlimited bandwidth for less than €100/month. AWS or platforms built on it such as Heroku can't compete with that on price. So if you're very constrained on cash and have the sysadmin chops to operate the server, you will get a better deal.

Of course we're comparing apples and oranges here. You won't get similar redundancy and flexibility with physical servers as you can with AWS for any money – except when you do. The second group where using a commercial cloud platform doesn't make sense is when your scale merits a cloud platform of your own. Open source software for such platforms – such as Docker and Flynn – are slowly at a point where you can rent your own servers and basically build your own AWS on them[^2]. Of course this will take a lot more knowledge from your operations team, especially if you want to attain similar redundancy and high availability that you can with AWS Availability Zones.

There is – however – one hidden benefit of going with a commercial cloud platform such as AWS, that you might not have thought about: _going with AWS will lessen your vendor lock-in a lot_. Of course you can still shoot yourself in the foot by handing off the intellectual property rights of the software to your vendor or some other braindead move. But given that you won't, hosting is another huge lock-in mechanism large IT houses use to screw their clients. It not only effectively locks the client to the vendor, but it also massively slows down any modifications made by other projects that need to integrate with the existing system, since everything needs to be handled through the vendor. They can, and will, block any progress you could make yourself.

With AWS, you can skip all of that. You are not tied to a particular vendor to develop, operate, and extend your system. While running apps on PaaS platforms requires some specific knowledge, it is widely available and standard. If you want to take your systems to another provider, you can. If you want to build your own cloud platform, you can do it and move your system over bit by bit.

It is thus no wonder that large IT consultancies are racing to build their own platforms, to hit all the necessary buzzword checkboxes. However, I would be very wary of their offerings. I'm fairly certain the savings they get from better utilization of their servers by virtualization are not passed on to the customer. And even if some of them are, the lock-in is still there. They have absolutely no incentive to make their platform compatible with the existing ones, quite the contrary. Lock-in is on their side. It is not on your side. Beware.

[^1]:	Apart from Google Computing Engine, but even it doesn't provide a similar generic cloud platform that AWS does.

[^2]:	If you’re at such a state, we can [help](https://bearmetal.eu/services/), by the way. The same goes for building a server environment on AWS, of course.