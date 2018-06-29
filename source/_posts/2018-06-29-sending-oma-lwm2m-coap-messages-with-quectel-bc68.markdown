---
layout: post
title: "Sending OMA LwM2M CoAP messages with Quectel BC68"
date: 2018-06-29 17:00:00 +0300
comments: true
author: Erkki
keywords: lwm2m, coap, quectel, bc68, iot, nb-iot
categories: [iot, nb-iot]
published: true
---

One of the projects we're currently working on is a battery powered sensor that needs to send small amounts of data, infrequently, and have a battery-life measured in years.
We spent quite a bit of time researching <a href="https://en.wikipedia.org/wiki/LoRa">LoRa</a> for this, but have recently settled on <a href="https://en.wikipedia.org/wiki/Narrowband_IoT">Narrowband IoT (NB-Iot)</a> instead.

{% blockquote %}
Narrowband IoT (NB-IoT) is a Low Power Wide Area Network (LPWAN) radio technology standard developed by 3GPP to enable a wide range of cellular devices and services. The specification was frozen in 3GPP Release 13 (LTE Advanced Pro), in June 2016. Other 3GPP IoT technologies include eMTC (enhanced Machine-Type Communication) and EC-GSM-IoT.

NB-IoT focuses specifically on indoor coverage, low cost, long battery life, and high connection density. NB-IoT uses a subset of the LTE standard, but limits the bandwidth to a single narrow-band of 200kHz. It uses OFDM modulation for downlink communication and SC-FDMA for uplink communications.
{% endblockquote %}

We managed to source a <a href="https://www.quectel.com/product/bc68.htm">Quectel LTE BC68 NB-IoT Module</a> and started to work on data integration, soon realizing that these Neul (which is a company Huawei acquired in 2014) based NB-Iot modems require you to use special <a href="https://en.wikipedia.org/wiki/Hayes_command_set">AT commands</a> to communicate with the outside world (as opposed to "normal" modems which would require the host to call in using <a href="https://en.wikipedia.org/wiki/Point-to-Point_Protocol">PPP</a>).

Okay, let's scan the <a href="http://www.quectel.com/UploadImage/Downlad/Quectel_BC95-G&BC68_AT_Commands_Manual_V1.1.pdf">Quectel BC95-G&BC68 AT Commands Manual</a>. There's a command for creating UDP sockets, great. Another one for TCP sockets, too. Awesome! And then there's something mysteriously referred to as the "Huawei IoT Platform". Wait, what?!?

In TELCO speech it's called a `CDP` (which stands for Connected Device Platform). It's  a fancy way to describe a gateway that accepts messages from a mobile device and routes them to your application server. There's a few flavours around, such as:

- <a href="http://developer.huawei.com/ict/en/site-oceanconnect/article/ocean-connect-overview">Huawei OceanConnect</a>
- <a href="https://networks.nokia.com/solutions/connected-device-platform">Nokia IMPACT/Connected Device Platform</a>

But what if we want to use our own server? For various reasons, including cost and effeciency, or the fact that the Huawei partner signup website was broken for two weeks. (Actually turns out it just can't accept `Ü` as a character in the company name. But I digress.) And Nokia CDP is only available in the U.S.

Scanning the manual further, there's hints as to what the protocol might be. To set the ip address of the `CDP` platform, there's a specific AT command for it.

{% blockquote %}
6.1. AT+NCDP Configure and Query CDP Server Settings
The command is used to set and query the server IP address and port for the CDP server. It is used when there is a HiSilicon CDP or Huawei’s IoT platform acting as gateway to network server applications. The values assigned are persistent across reboots.
{% endblockquote %}

And the default port for it is 5683. That's the port for <a href="https://en.wikipedia.org/wiki/Constrained_Application_Protocol">CoAP</a>:
{% blockquote %}
Constrained Application Protocol (CoAP) is a specialized Internet Application Protocol for constrained devices, as defined in RFC 7252. It enables those constrained devices called "nodes" to communicate with the wider Internet using similar protocols. CoAP is designed for use between devices on the same constrained network (e.g., low-power, lossy networks), between devices and general nodes on the Internet, and between devices on different constrained networks both joined by an internet. CoAP is also being used via other mechanisms, such as SMS on mobile communication networks.
{% endblockquote %}

Furthermore, another command confirms <a href="https://en.wikipedia.org/wiki/Constrained_Application_Protocol">CoAP</a> and adds <a href="https://en.wikipedia.org/wiki/OMA_LWM2M">OMA LwM2M</a>:
{% blockquote %}
6.5. AT+QLWULDATA Send Data
The command is used to send data to Huawei’s IoT platform with LWM2M protocol. It will give an <err> code and description as an intermediate message if the message cannot be sent. Before the module registered to the IoT platform, executing the command will trigger register operation and discard the data. Please refer to Chapter 7 for possible <err> values.
{% endblockquote %}

<a href="https://en.wikipedia.org/wiki/OMA_LWM2M">OMA LwM2M</a> is a protocol that builds on top of <a href="https://en.wikipedia.org/wiki/Constrained_Application_Protocol">CoAP</a>
{% blockquote %}
OMA Lightweight M2M is a protocol from the Open Mobile Alliance for M2M or IoT device management. Lightweight M2M enabler defines the application layer communication protocol between a LWM2M Server and a LWM2M Client, which is located in a LWM2M Device. The OMA Lightweight M2M enabler includes device management and service enablement for LWM2M Devices. The target LWM2M Devices for this enabler are mainly resource constrained devices. Therefore, this enabler makes use of a light and compact protocol as well as an efficient resource data model. It provides a choice for the M2M Service Provider to deploy a M2M system to provide service to the M2M User. It is frequently used with CoAP
{% endblockquote %}

With this we're ready for experimentation. Let's fire up the modem, attach it to the network, make it use our own server as the `CDP` and connect it to <a href="https://www.eclipse.org/wakaama/">Eclipse Wakaama</a> running on the server.

```
Boot: Unsigned
Security B.. Verified
Protocol A.. Verified
Apps A...... Verified
REBOOT_CAUSE_SECURITY_RESET_PIN
Neul 
OK
AT+CFUN=0
OK
AT+NCDP=198.51.100.1
OK
AT+CFUN=1
OK
AT+CGDCONT=1,"IP","APN"
OK
AT+CSCON=1
OK
AT+CEREG=1
OK
AT+CGATT=1
OK
+CEREG:2
+CSCON:1
+CEREG:1
AT+NPING=198.51.100.1
OK
+NPING:198.51.100.1,54,962
```

Once the modem boots up, we

- disable the radio `AT+CFUN=0`
- set the CDP to our server `AT+NCDP=198.51.100.1`
- re-enable the radio again `AT+CFUN=1`
- configure the APN (value depends on your provider) `AT+CGDCONT=1,"IP","APN"`
- enable `AT+CSCON=1` and `AT+CEREG=1` to monitor network connection and registration status
- attach to the network `AT+CGATT=1`
- once we see `+CSCON:1` and `+CEREG:1` we can send a test ping with `AT+NPING=198.51.100.1`

```sh
AT+QLWSREGIND=0
OK
+CSCON:1
+QLWEVTIND:0
```

Sending `AT+QLWSREGIND=0` initiates the registration process and receiving `+QLWEVTIND:0` means registration was successful. We can observe this with `tcpdump` and `lwm2mserver` included in `wakaama`.

```
20:32:00.417221 IP 198.51.100.2.19000 > 198.51.100.1.5683: UDP, length 119
	0x0000:  4500 0093 0013 0000 fa11 0c0f 92ff b496  E...............
	0x0010:  b99e b303 4a38 1633 007f 137c 4402 2862  ....J8.3...|D.(b
	0x0020:  2862 a813 b272 6411 2839 6c77 6d32 6d3d  (b...rd.(9lwm2m=
	0x0030:  312e 300d 0565 703d 3836 3737 3233 3033  1.0..ep=86772303
	0x0040:  3030 3035 3635 3503 623d 5508 6c74 3d38  0005655.b=U.lt=8
	0x0050:  3634 3030 ff3c 2f3e 3b72 743d 226f 6d61  6400.</>;rt="oma
	0x0060:  2e6c 776d 326d 222c 3c2f 312f 303e 2c3c  .lwm2m",</1/0>,<
	0x0070:  2f33 2f30 3e2c 3c2f 342f 303e 2c3c 2f31  /3/0>,</4/0>,</1
	0x0080:  392f 303e 2c3c 2f35 2f30 3e2c 3c2f 3230  9/0>,</5/0>,</20
	0x0090:  2f30 3e                                  /0>
20:32:00.417622 IP 198.51.100.1.5683 > 198.51.100.2.19000: UDP, length 13
	0x0000:  4500 0029 7ae4 4000 4011 0ba8 b99e b303  E..)z.@.@.......
	0x0010:  92ff b496 1633 4a38 0015 b45e 6441 2862  .....3J8...^dA(b
	0x0020:  2862 a813 8272 6401 30                   (b...rd.0
```

```
~/wakaama# ./lwm2mserver 
119 bytes received from [::ffff:198.51.100.2]:19000
44 02 28 62  28 62 A8 13  B2 72 64 11  28 39 6C 77   D.(b(b...rd.(9lw
6D 32 6D 3D  31 2E 30 0D  05 65 70 3D  38 36 37 37   m2m=1.0..ep=8677
32 33 30 33  30 30 30 35  36 35 35 03  62 3D 55 08   23030005655.b=U.
6C 74 3D 38  36 34 30 30  FF 3C 2F 3E  3B 72 74 3D   lt=86400.</>;rt=
22 6F 6D 61  2E 6C 77 6D  32 6D 22 2C  3C 2F 31 2F   "oma.lwm2m",</1/
30 3E 2C 3C  2F 33 2F 30  3E 2C 3C 2F  34 2F 30 3E   0>,</3/0>,</4/0>
2C 3C 2F 31  39 2F 30 3E  2C 3C 2F 35  2F 30 3E 2C   ,</19/0>,</5/0>,
3C 2F 32 30  2F 30 3E                                </20/0>

New client #0 registered.
Client #0:
	name: "867723030005655"
	binding: "UDP"
	lifetime: 86400 sec
	objects: /1/0, /3/0, /4/0, /5/0, /19/0, /20/0, 
```

Great! We've registered the modem. Let's try sending data with `AT+QLWULDATA`

```
AT+QLWULDATA=4,DEADBEEF
ERROR
+CSCON:1
+QLWEVTIND:0
```

This is a failure. Not only does it error out, it actually triggers a new registration process. Something is missing. Scanning the docs again, there's a reference to `+QLWEVTIND:3` being sent when:

{% blockquote %}
//IoT platform has observed the data object 19. When the module reports this message, the customer can send data to the IoT platform.
{% endblockquote %}

This took me a while to figure out, but became clear after reading more about <a href="https://en.wikipedia.org/wiki/OMA_LWM2M">OMA LwM2M</a>. More specifically, `object 19` as specified in <a href="http://www.openmobilealliance.org/wp/OMNA/LwM2M/LwM2MRegistry.html">OMA LightweightM2M (LwM2M) Object and Resource Registry</a> means `LwM2M APPDATA`:

{% blockquote %}
This LwM2M object provides the application service data related to a LwM2M Server, eg. Water meter data.
{% endblockquote %}

Things are getting clearer now. For the modem to send out data, it tunnels the data inside object 19 and the server has to subscribe to receiving messages on that object. In `lwm2mserver` there's a command for it:

```
> observe 0 /19/0/0
OK
```

Observe request and ACK in tcpdump:
```
20:44:03.122190 IP 198.51.100.1.5683 > 198.51.100.2.61500: UDP, length 19
	0x0000:  4500 002f b3fa 4000 4011 d289 b99e b303  E../..@.@.......
	0x0010:  92ff b498 1633 f03c 001b b466 4401 f4a6  .....3.<...fD...
	0x0020:  0000 0000 6052 3139 0130 0130 622d 16    ....`R19.0.0b-.
20:44:04.232286 IP 198.51.100.2.61500 > 198.51.100.1.5683: UDP, length 10
	0x0000:  4500 0026 0016 0000 fa11 0c77 92ff b498  E..&.......w....
	0x0010:  b99e b303 f03c 1633 0012 8bd3 6445 f4a6  .....<.3....dE..
	0x0020:  0000 0000 6060 0000 0000 0000 0000       ....``........
```

Meanwhile on the modem side, we've received the `+QLWEVTIND:3` message and can send data now:

```
+QLWEVTIND:3
AT+QLWULDATA=3,AA34BB
OK
+CSCON:1
```

On the `lwm2mserver` side we can see data coming in
```
15 bytes received from [::ffff:198.51.100.2]:61500
54 45 28 66  00 00 00 00  C1 2A FF DE  AD BE EF  TE(f.....*.....
```

Yay! We can now successfully receive data from the modem. In follow-up posts, let's try to figure out the differences in between `AT+QLWULDATA` and `AT+NMGS`, look at receiving data from the server and maybe write our own LwM2M server to forward data to MQTT.
