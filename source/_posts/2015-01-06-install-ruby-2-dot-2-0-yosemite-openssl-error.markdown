---
layout: post
title: "How to install Ruby 2.2.0 on OS X Yosemite with Homebrew and rbenv"
date: 2015-01-06 16:15
comments: true
author: Jarkko
keywords: ruby, rails, troubleshooting
categories: [ruby, rails, troubleshooting]
---

When trying to install Ruby 2.2.0 on Yosemite with [rbenv](https://github.com/sstephenson/rbenv) and [Homebrew](http://brew.sh), I got a weird error:

```
➜  ~ ✗ rbenv install 2.2.0
Downloading ruby-2.2.0.tar.gz...
-> http://dqw8nmjcqpjn7.cloudfront.net/7671e394abfb5d262fbcd3b27a71bf78737c7e9347fa21c39e58b0bb9c4840fc
Installing ruby-2.2.0...

BUILD FAILED (OS X 10.10.1 using ruby-build 20141225)

Inspect or clean up the working tree at /var/folders/s_/_zh3skrd0qz2933nns5y425r0000gn/T/ruby-build.20150106151200.81466
Results logged to /var/folders/s_/_zh3skrd0qz2933nns5y425r0000gn/T/ruby-build.20150106151200.81466.log

Last 10 log lines:
make[2]: *** Waiting for unfinished jobs....
compiling raddrinfo.c
compiling ifaddr.c
make[1]: *** [ext/openssl/all] Error 2
make[1]: *** Waiting for unfinished jobs....
linking shared-object zlib.bundle
linking shared-object socket.bundle
linking shared-object date_core.bundle
linking shared-object ripper.bundle
make: *** [build-ext] Error 2
```

When I opened up the log file mentioned in the output above, I could see the actual cause of the error:

```
ossl_ssl.c:125:5: error: use of undeclared identifier 'TLSv1_2_method'
    OSSL_SSL_METHOD_ENTRY(TLSv1_2),
    ^
ossl_ssl.c:119:69: note: expanded from macro 'OSSL_SSL_METHOD_ENTRY'
#define OSSL_SSL_METHOD_ENTRY(name) { #name, (SSL_METHOD *(*)(void))name##_method }
                                                                    ^
<scratch space>:148:1: note: expanded from here
TLSv1_2_method
^
ossl_ssl.c:126:5: error: use of undeclared identifier 'TLSv1_2_server_method'
    OSSL_SSL_METHOD_ENTRY(TLSv1_2_server),
    ^
ossl_ssl.c:119:69: note: expanded from macro 'OSSL_SSL_METHOD_ENTRY'
#define OSSL_SSL_METHOD_ENTRY(name) { #name, (SSL_METHOD *(*)(void))name##_method }
                                                                    ^
<scratch space>:148:1: note: expanded from here
TLSv1_2_server_method
^
ossl_ssl.c:127:5: error: use of undeclared identifier 'TLSv1_2_client_method'
    OSSL_SSL_METHOD_ENTRY(TLSv1_2_client),
    ^
ossl_ssl.c:119:69: note: expanded from macro 'OSSL_SSL_METHOD_ENTRY'
#define OSSL_SSL_METHOD_ENTRY(name) { #name, (SSL_METHOD *(*)(void))name##_method }
                                                                    ^
<scratch space>:148:1: note: expanded from here
TLSv1_2_client_method
^
ossl_ssl.c:131:5: error: use of undeclared identifier 'TLSv1_1_method'
    OSSL_SSL_METHOD_ENTRY(TLSv1_1),
    ^
ossl_ssl.c:119:69: note: expanded from macro 'OSSL_SSL_METHOD_ENTRY'
#define OSSL_SSL_METHOD_ENTRY(name) { #name, (SSL_METHOD *(*)(void))name##_method }
                                                                    ^
<scratch space>:148:1: note: expanded from here
TLSv1_1_method
^
ossl_ssl.c:132:5: error: use of undeclared identifier 'TLSv1_1_server_method'
    OSSL_SSL_METHOD_ENTRY(TLSv1_1_server),
    ^
ossl_ssl.c:119:69: note: expanded from macro 'OSSL_SSL_METHOD_ENTRY'
#define OSSL_SSL_METHOD_ENTRY(name) { #name, (SSL_METHOD *(*)(void))name##_method }
                                                                    ^
<scratch space>:148:1: note: expanded from here
TLSv1_1_server_method
^
ossl_ssl.c:133:5: error: use of undeclared identifier 'TLSv1_1_client_method'
    OSSL_SSL_METHOD_ENTRY(TLSv1_1_client),
    ^
ossl_ssl.c:119:69: note: expanded from macro 'OSSL_SSL_METHOD_ENTRY'
#define OSSL_SSL_METHOD_ENTRY(name) { #name, (SSL_METHOD *(*)(void))name##_method }
                                                                    ^
<scratch space>:148:1: note: expanded from here
TLSv1_1_client_method
^
ossl_ssl.c:210:21: error: invalid application of 'sizeof' to an incomplete type 'const struct <anonymous struct at ossl_ssl.c:115:14> []'
    for (i = 0; i < numberof(ossl_ssl_method_tab); i++) {
                    ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ossl_ssl.c:19:35: note: expanded from macro 'numberof'
#define numberof(ary) (int)(sizeof(ary)/sizeof((ary)[0]))
                                  ^~~~~
ossl_ssl.c:1127:13: warning: using the result of an assignment as a condition without parentheses [-Wparentheses]
            if (rc = SSL_shutdown(ssl))
                ~~~^~~~~~~~~~~~~~~~~~~
ossl_ssl.c:1127:13: note: place parentheses around the assignment to silence this warning
            if (rc = SSL_shutdown(ssl))
                   ^
                (                     )
ossl_ssl.c:1127:13: note: use '==' to turn this assignment into an equality comparison
            if (rc = SSL_shutdown(ssl))
                   ^
                   ==
ossl_ssl.c:2194:23: error: invalid application of 'sizeof' to an incomplete type 'const struct <anonymous struct at ossl_ssl.c:115:14> []'
    ary = rb_ary_new2(numberof(ossl_ssl_method_tab));
                      ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ossl_ssl.c:19:35: note: expanded from macro 'numberof'
#define numberof(ary) (int)(sizeof(ary)/sizeof((ary)[0]))
                                  ^~~~~
ossl_ssl.c:2195:21: error: invalid application of 'sizeof' to an incomplete type 'const struct <anonymous struct at ossl_ssl.c:115:14> []'
    for (i = 0; i < numberof(ossl_ssl_method_tab); i++) {
                    ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ossl_ssl.c:19:35: note: expanded from macro 'numberof'
#define numberof(ary) (int)(sizeof(ary)/sizeof((ary)[0]))
                                  ^~~~~
1 warning and 9 errors generated.
make[2]: *** [ossl_ssl.o] Error 1
make[2]: *** Waiting for unfinished jobs....
compiling raddrinfo.c
compiling ifaddr.c
make[1]: *** [ext/openssl/all] Error 2
make[1]: *** Waiting for unfinished jobs....
linking shared-object zlib.bundle
linking shared-object socket.bundle
linking shared-object date_core.bundle
linking shared-object ripper.bundle
make: *** [build-ext] Error 2
```

The weird thing here is that I did not get the usual 'Missing the OpenSSL lib?' warning. The lib *was* found but somehow the headers were fucked up. It also did not happen with older rbenv Rubies.

Thanks to [Tarmo](https://bearmetal.eu/team/tarmo/) I found the solution [here](https://issues.apache.org/jira/browse/THRIFT-2515?focusedCommentId=14012758&page=com.atlassian.jira.plugin.system.issuetabpanels:comment-tabpanel#comment-14012758).

What I had to do was this:

```
➜  ~  brew update
➜  ~  brew install openssl
➜  ~  /usr/local/opt/openssl/bin/c_rehash
```

Now make sure that your new binary is in your PATH before the system one.

```
➜  ~  ln -s /usr/local/opt/openssl/bin/openssl /usr/local/bin/openssl
➜  ~ which openssl
/usr/bin/openssl
➜  ~ echo $PATH
/usr/local/heroku/bin:/Users/jarkko/.rbenv/shims:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin
```

That's no good. Let's fix our PATH. I'm using zsh, so for me it's set in `~/.zshrc`. Your particular file depends on the shell you're using (for bash it would be `~/.bashrc` or `~/.bash_profile`, but see the caveat [here](http://www.joshstaiger.org/archives/2005/07/bash_profile_vs.html)).

```
➜  ~ vim ~/.zshrc
# Change the line that sets PATH so that /usr/local/bin
# comes BEFORE /usr/bin. For me, it looks like this:
# export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
```

Open up a new terminal window and check that the PATH is correct:

```
➜  ~  echo $PATH
/usr/local/heroku/bin:/Users/jarkko/.rbenv/shims:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
➜  ~  which openssl
/usr/local/bin/openssl
```

Better. Now, let's make sure that homebrew libs symlink to the newer openssl.

```
➜  ~  brew unlink openssl
➜  ~  brew link --overwrite --force openssl
➜  ~  openssl version -a

OpenSSL 1.0.1j 15 Oct 2014
built on: Sun Dec  7 02:14:31 GMT 2014
platform: darwin64-x86_64-cc
options:  bn(64,64) rc4(ptr,char) des(idx,cisc,16,int) idea(int) blowfish(idx) 
compiler: clang -fPIC -fno-common -DOPENSSL_PIC -DZLIB_SHARED -DZLIB -DOPENSSL_THREADS -D_REENTRANT -DDSO_DLFCN -DHAVE_DLFCN_H -arch x86_64 -O3 -DL_ENDIAN -Wall -DOPENSSL_IA32_SSE2 -DOPENSSL_BN_ASM_MONT -DOPENSSL_BN_ASM_MONT5 -DOPENSSL_BN_ASM_GF2m -DSHA1_ASM -DSHA256_ASM -DSHA512_ASM -DMD5_ASM -DAES_ASM -DVPAES_ASM -DBSAES_ASM -DWHIRLPOOL_ASM -DGHASH_ASM
OPENSSLDIR: "/usr/local/etc/openssl"
```

Splendid.

After that, Ruby 2.2.0 installed cleanly without any specific parameters needed:

```
➜  ~  rbenv install 2.2.0
Downloading ruby-2.2.0.tar.gz...
-> http://dqw8nmjcqpjn7.cloudfront.net/7671e394abfb5d262fbcd3b27a71bf78737c7e9347fa21c39e58b0bb9c4840fc
Installing ruby-2.2.0...
Installed ruby-2.2.0 to /Users/jarkko/.rbenv/versions/2.2.0
```

**[UPDATE 1, Jan 7]** The original version of this post told you to `rm /usr/bin/openssl`, based on the link above. As James Tucker pointed out, this is a horrible idea. I fixed the article so that we now fix the `$PATH` instead.
