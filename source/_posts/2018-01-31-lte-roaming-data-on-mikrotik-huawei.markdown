---
layout: post
title: "Enable LTE roaming on a Mikrotik router with Huawei ME909u-521 modem"
date: 2018-01-31 11:00:00 +0700
comments: true
author: Erkki
keywords: networking, mikrotik, huawei
categories: [networking, mikrotik, huawei]
published: true
---

MikroTik by default doesn't enable roaming when used with a non-local sim card. This puzzled us as everything seemed to be configured correctly but the LTE interface wasn't getting any ip addresses. This is how to log in to your router and enable roaming.

Log in to the MikroTik box. We're using the command-line interface via ssh but you could use the web UI too.
If you haven't done this before, check out <a href="https://wiki.mikrotik.com/wiki/Manual:First_time_startup">First_time_startup</a>

{% blockquote %}
Every router is factory pre-configured with the IP address 192.168.88.1/24 on the ether1 port. The default username is admin with no password.
{% endblockquote %}

```bash
➜ ssh admin@192.168.88.1
  MMM      MMM       KKK                          TTTTTTTTTTT      KKK
  MMMM    MMMM       KKK                          TTTTTTTTTTT      KKK
  MMM MMMM MMM  III  KKK  KKK  RRRRRR     OOOOOO      TTT     III  KKK  KKK
  MMM  MM  MMM  III  KKKKK     RRR  RRR  OOO  OOO     TTT     III  KKKKK
  MMM      MMM  III  KKK KKK   RRRRRR    OOO  OOO     TTT     III  KKK KKK
  MMM      MMM  III  KKK  KKK  RRR  RRR   OOOOOO      TTT     III  KKK  KKK

  MikroTik RouterOS 6.39.2 (c) 1999-2017       http://www.mikrotik.com/

[?]             Gives the list of available commands
command [?]     Gives help on the command and list of arguments

[Tab]           Completes the command/word. If the input is ambiguous,
                a second [Tab] gives possible options

/               Move up to base level
..              Move up one level
/command        Use command at the base level
  
[admin@MikroTik] > 
```

We checked the LTE interface and realized it is not joining any networks. If you can't see the LTE interface/modem at all, you need to enable the mini-PCIe interface.
```bash
[admin@MikroTik] /interface lte info lte1 once
     pin-status: no password required
  functionality: full
   manufacturer: Huawei Technologies Co., Ltd.
          model: ME909u-521
       revision: 12.636.12.01.00
           imei: <redacted>
           imsi: <redacted>
           uicc: <redacted>
```

With the help of the <a href="http://download-c.huawei.com/download/downloadCenter?downloadId=29741&version=72288&siteCode=">AT Command Interface Specification for the HUAWEI ME906s LTE M.2 Module</a> we can see roaming status is queried and set using the `AT^SYSCFGEX` command.

To check existing roaming status, we need to look at the third parameter returned. Notice that we're escaping the question mark `?` with the backslash character `\`. This is because the command line interface interprets `?` as the help command.

```bash
[admin@MikroTik] > /interface lte at-chat lte1 input="AT^SYSCFGEX\?"
  output: ^SYSCFGEX: "00",3FFFFFFF,0,1,7FFFFFFFFFFFFFFF

OK
```

| `AT^SYSCFGEX=?` |
| ------------- |
| Possible Response(s) |
| `<CR><LF>^SYSCFGEX`: (list of supported `<acqorder>`s),(list of supported (`<band>`,`<band_name>`)s),(list of supported `<roam>`s),(list of supported `<srvdomain>`s),(list of supported (`<lteband>`,`<lteband_name>`)s)`<CR><LF><CR><LF>OK<CR><LF>` |

 
| `<roam>`: indicates whether roaming is supported. |
| ------------- |
| 0 Not supported |
| 1 Supported |
| 2 No change |


`0` here means roaming not enabled. Lets set it to `1` instead (notice that we're keeping all the rest of the parameters unchanged from the output of the previous command).

```bash
[admin@MikroTik] > /interface lte at-chat lte1 input="AT^SYSCFGEX=\"00\",3FFFFFFF,1,1,7FFFFFFFFFFFFFFF,,"
  output: OK
```

Query the status again.
```bash
[admin@MikroTik] > /interface lte at-chat lte1 input="AT^SYSCFGEX\?"
  output: ^SYSCFGEX: "00",3FFFFFFF,1,1,7FFFFFFFFFFFFFFF
```

Boom, roaming enbled. Verify with ```lte info``` to make sure we're registered to a network.

```bash
[admin@MikroTik] /interface lte info lte1 once
         pin-status: no password required
      functionality: full
       manufacturer: Huawei Technologies Co., Ltd.
              model: ME909u-521
           revision: 12.636.12.01.00
   current-operator: EE Elisa
                lac: 24
     current-cellid: 256268822
  access-technology: Evolved 3G (LTE)
     session-uptime: 1m10s
               imei: <redacted>
               imsi: <redacted>
               uicc: <redacted>
               rssi: -80dBm
               rsrp: -106dBm
               rsrq: -7dB
               sinr: 18dB
```