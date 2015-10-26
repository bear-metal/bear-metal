---
layout: post
title: "Getting Vagrant VMware plugin installed on OS X El Capitan and Homebrew"
date: 2015-10-26 11:18:37 +0200
comments: true
author: Jarkko
keywords: ruby, rails, osx, vagrant, vmware, homebrew, openssl, rubygems
categories: [ruby, rails, osx, vagrant, vmware, homebrew, openssl, rubygems]
published: true
---

I finally decided to bite the bullet this morning and install VMware Fusion 8 and the corresponding Vagrant plugin.

Both were paid upgrades (41.42€ + $39 from Fusion 7), which was a bit bitter given I had only had the previous versions for a couple of months. Yet, the word on the street was that the new version would be much more stable and less cpu-hungry than the previous generation. So what the heck, maybe I’d again be able to get more than a couple hours of productive work done without draining the battery.

The purchase process itself was painless, as was installing VMware itself. But when I started installing the plugin, an ugly yak raised its hairy head.

The first thing I tried was to just use the old plugin with the new VMware version. Would it perhaps work?

```bash
	➜  ~ vagrant suspend
	This provider only works with VMware Fusion 5.x, 6.x, or 7.x. You have
	Fusion '8.0.1'. Please install the proper version of VMware
	Fusion and try again.
```

That sounds like a resounding “No”.

So onwards: bought a license for the plugin as well and tried to install it.

```bash
	➜  ~ vagrant plugin install vagrant-vmware-fusion
	Installing the 'vagrant-vmware-fusion' plugin. This can take a few minutes...
	Bundler, the underlying system Vagrant uses to install plugins,
	reported an error. The error is shown below. These errors are usually
	caused by misconfigured plugin installations or transient network
	issues. The error from Bundler is:
	
	An error occurred while installing hitimes (1.2.3), and Bundler cannot continue.
	Make sure that `gem install hitimes -v '1.2.3'` succeeds before bundling.
	
	Gem::Installer::ExtensionBuildError: ERROR: Failed to build gem native extension.
	
	    /opt/vagrant/embedded/bin/ruby extconf.rb 
	creating Makefile
	
	make "DESTDIR="
	
	
	Agreeing to the Xcode/iOS license requires admin privileges, please re-run as root via sudo.
```

No biggie, a little Googling revealed what I suspected – I don’t actually need to run this as root, I just need to accept the EULA of the latest XCode version before running the install process again. I popped up XCode, YOLOed the agreement, and was back to the terminal.

```bash
	➜  ~ vagrant plugin install vagrant-vmware-fusion
	Installing the 'vagrant-vmware-fusion' plugin. This can take a few minutes...
	Bundler, the underlying system Vagrant uses to install plugins,
	reported an error. The error is shown below. These errors are usually
	caused by misconfigured plugin installations or transient network
	issues. The error from Bundler is:
	
	An error occurred while installing eventmachine (1.0.8), and Bundler cannot continue.
	Make sure that `gem install eventmachine -v '1.0.8'` succeeds before bundling.
	
	Gem::Installer::ExtensionBuildError: ERROR: Failed to build gem native extension.
	
	[LOTS OF CRUFT REMOVED FOR BREVITY]
	
	make "DESTDIR="
	compiling binder.cpp
	warning: unknown warning option '-Werror=unused-command-line-argument-hard-error-in-future'; did you mean '-Werror=unused-command-line-argument'? [-Wunknown-warning-option]
	In file included from binder.cpp:20:
	./project.h:116:10: fatal error: 'openssl/ssl.h' file not found
	#include <openssl/ssl.h>
	         ^
	1 warning and 1 error generated.
	make: *** [binder.o] Error 1
	
	
	Gem files will remain installed in /Users/jarkko/.vagrant.d/gems/gems/eventmachine-1.0.8 for inspection.
	Results logged to /Users/jarkko/.vagrant.d/gems/gems/eventmachine-1.0.8/ext/gem_make.out
```

Again, the reason is clear: I need to build the gem against proper openssl libs – in this case, `-I/usr/local/opt/openssl/include`. Thus:

```bash
	➜  ~  gem install eventmachine -v '1.0.8' -- --with-cppflags=-I/usr/local/opt/openssl/include
	Fetching: eventmachine-1.0.8.gem (100%)
	Building native extensions with: '--with-cppflags=-I/usr/local/opt/openssl/include'
	This could take a while...
	Successfully installed eventmachine-1.0.8
	Parsing documentation for eventmachine-1.0.8
	Installing ri documentation for eventmachine-1.0.8
	Done installing documentation for eventmachine after 6 seconds
	1 gem installed
```

Perfect. So I tried to install the Vagrant plugin again – and got the same error. Crap.

It turns out that Vagrant uses its own gem folder, so it’s not picking up what’s installed in one’s primary gem directory. The issue was, how do I tell Vagrant to use the correct cpp flags in its build process?

Fortunately I didn’t have to figure that out, because the end of the error message above gave me enough of a pointer towards a solution: if I only managed to install the eventmachine gem by hand to the correct location with the proper cpp flags, I should be fine. But how?

I dug up to `gem -h` and the defaults at the end gave the correct option away: with the `--install-dir` option I could install the gem to wherever I wanted to. Thus:

```bash
	~  gem install eventmachine -v '1.0.8' --install-dir /Users/jarkko/.vagrant.d/gems  -- --with-cppflags=-I/usr/local/opt/openssl/include
	Fetching: eventmachine-1.0.8.gem (100%)
	Building native extensions with: '--with-cppflags=-I/usr/local/opt/openssl/include'
	This could take a while...
	Successfully installed eventmachine-1.0.8
	Parsing documentation for eventmachine-1.0.8
	Installing ri documentation for eventmachine-1.0.8
	Done installing documentation for eventmachine after 5 seconds
	1 gem installed
```

Et voilá. Now one more try:

```bash
	➜    vagrant plugin install vagrant-vmware-fusion
	…
	Installed the plugin 'vagrant-vmware-fusion (4.0.2)'!
```

…and we’re off to the races!

…well, at least almost.

```bash
	➜  ~ vagrant up
	Bringing machine 'default' up with 'vmware_fusion' provider...
	==> default: Verifying vmnet devices are healthy...
	==> default: Preparing network adapters...
	==> default: Starting the VMware VM...
	An error occurred while executing `vmrun`, a utility for controlling
	VMware machines. The command and output are below:
	
	Command: ["start", "/Users/jarkko/vmware/955a09a5-f7f6-451e-b565-22f41c8fced0/packer-ubuntu-14.04-amd64.vmx", "nogui", {:notify=>[:stdout, :stderr], :timeout=>45}]
	
	Stdout: 2015-10-26T11:10:45.943| ServiceImpl_Opener: PID 84443
	Error: The operation was canceled
	
	Stderr: 
```

Oh well, that wasn’t very helpful. So I tried the proven trick #1: I killed the VMware app on OS X and even its menubar daemon just to be certain, and sure enough, it did the trick. The vagrant VM is now back on track.