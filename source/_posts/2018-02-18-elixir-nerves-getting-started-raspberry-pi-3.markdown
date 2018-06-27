---
layout: post
title: "Elixir Nerves project getting started on Raspberry Pi 3"
date: 2018-02-22 12:00:00 +0700
comments: true
author: Erkki
keywords: embedded, elixir, nerves, raspberrypi
categories: [embedded, elixir, nerves, raspberrypi]
published: false
---

A few weeks ago we checked out <a href="https://mender.io">mender</a> (see [Hosted Mender Getting Started on OSX and Raspberry Pi 3](/theden/hosted-mender-getting-started-on-osx-and-raspberry-pi-3)). Now it's time to do the same with the <a href="https://nerves-project.org/">nerves project</a>. This is how the project describes itself:

{% blockquote %}
Craft and deploy bulletproof embedded software in <a href="https://elixir-lang.org">Elixir</a>

Pack your whole application into as little as 12MB and have it start in seconds by booting a lean cross-compiled Linux directly to the battle-hardened Erlang VM.
{% endblockquote %}

Nerves focuses on getting an Elixir project running on embedded hardware (or more recently on a generic x86_64 vm -- expect more on this in the future). It handles cross-compiling, firmware updates, and deployment for you in a nice way.

To get started:

 * you will need a Raspberry Pi 3 with a SD card. Optionally a screen and a keyboard attached to the RPi3.
 * install nerves & dependencies https://hexdocs.pm/nerves/installation.html
 * although we'll repeat the steps, skim through https://hexdocs.pm/nerves/getting-started.html

Initialize a new nerves project with the `nerves.new` mix task and export the `MIX_TARGET` environment variable as `rpi3`. This will tell nerves that we want to build our code for Raspberry Pi 3.

```bash
mix nerves.new hello_nerves
cd hello_nerves
export MIX_TARGET=rpi3
```
To get "over-the-air" firmware upgrades we will have to add support for networking and ssh.
We will also want a way to access logs remotely instead of having to stare at the screen the RPi3 is attached to.

Add the following dependencies to `mix.exs`.

Notice that we have multiple `deps` methods here, with dependencies spread around. This is so that we could run more general code (including `mix test`) on the host side and limit the embedded hardware specific dependencies to the target.
```elixir
  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nerves, "~> 0.11", runtime: false},
      {:mdns, "~> 0.1"},
      {:ring_logger, "~> 0.4"}
    ] ++ deps(@target)
  end

  # Specify target specific dependencies
  defp deps("host"),  do: []

  defp deps(target) do
    [
      {:shoehorn, "~> 0.2"},
      {:nerves_runtime, "~> 0.5"},
      {:nerves_network, "~> 0.3"},
      {:nerves_firmware_ssh, "~> 0.3"}
    ] ++ system(target)
  end
```

- <a href="https://github.com/nerves-project/nerves_network">nerves_network</a> is used to add support for networking on the RPi3 side.
- <a href="https://github.com/nerves-project/nerves_firmware_ssh">nerves_firmware_ssh</a> is used to deploy firmware using ssh. It also provides remote console access for debugging.
- <a href="https://github.com/NationalAssociationOfRealtors/mdns">mdns</a> so we could support <a href="https://en.wikipedia.org/wiki/Multicast_DNS">Multicast DNS</a>. This means we can refer to the RPi3 using a host name instead of having to know which ip address it is using.
- <a href="https://github.com/nerves-project/ring_logger">ring_logger</a> to be able to access logs via ssh, no need to have the RPi3 attached to a screen

Add the following configuration to `config/config.exs`.

```elixir
config :logger, level: :debug, backends: [RingLogger]
config :nerves_network, :default,
  eth0: [
    ipv4_address_method: :dhcp
  ]
config :nerves_firmware_ssh,
  authorized_keys: [
    "<your ssh pubkey>",
  ]
```

I'm using wired networking on `eth0` and `dhcp` to connect to my network, in case you want to use wireless networking or configure static ip addresses, check out the <a href="https://github.com/nerves-project/nerves_network">documentation</a> for `nerves_network`.
For `authorized_keys` I had to use a RSA public key, ed25519 didn't work. Should investigate this more.

One more thing, we want to be able to update firmware even if the main app crashes (or we push bad code). In order to do this, we have to configure <a href="https://github.com/nerves-project/shoehorn">shoehorn</a> to start `nerves_network`, `mdns` and `nerves_firmware_ssh` separately from the main app.

```elixir
config :shoehorn,
  init: [:nerves_runtime, :nerves_network, :mdns, :nerves_firmware_ssh],
  app: Mix.Project.config()[:app]
```

For service discovery to work, we need to advertise our ip with mDNS. Perfect opportunity to play with <a href="https://hexdocs.pm/elixir/Supervisor.html">supervisor trees</a>. We'll be using the new `child_spec/1` syntax introduced in Elixir 1.5.

Let's implement a new module that registers to dhcp callbacks and configures mDNS with the correct ip address.
```elixir
defmodule HelloNerves.Application do
  use Application
  require Logger

  def start(_type, _args) do
    children = [
      HelloNerves.Application.MdnsWorker
    ]
    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

  defmodule MdnsWorker do
    use GenServer

    def start_link(state) do
      GenServer.start_link(__MODULE__, state, name: __MODULE__)
    end

    def init(initial_data) do
      ifname = "eth0"
      {:ok, _} = Registry.register(Nerves.Udhcpc, ifname, [])
      Mdns.Server.add_service(%Mdns.Server.Service{domain: "nerves.local", data: :ip, ttl: 60, type: :a})
      {:ok, initial_data}
    end

    def handle_info({Nerves.Udhcpc, :bound, info}, state) do
      Logger.debug("mdns dhcp bound #{inspect info}")
      setup_mdns(info)
      {:noreply, state}
    end
    def handle_info({Nerves.Udhcpc, :renew, info}, state) do
      Logger.debug("mdns dhcp renew #{inspect info}")
      setup_mdns(info)
      {:noreply, state}
    end

    def setup_mdns(info) do
      {:ok, ip} = :inet.parse_address(to_charlist(info[:ipv4_address]))
      Mdns.Server.set_ip(ip)
      Mdns.Server.start
    end
  end
end
```

At last, time to build the firmware and burn it to the SD card.
```bash
mix deps.get
mix firmware
mix firmware.burn
```

`mix firmware.burn` will try to detect your SD card automatically, make sure it's the right one. You can use the `-d` parameter to specify a device.
Boot the RPi3. You should end up at an IEX prompt.

Let's see if we can now push firmware using ssh. If mDNS is working, you should be able to resolve `nerves.local`
```bash
mix firmware.push nerves.local
```

```bash
Nerves environment
  MIX_TARGET:   rpi3
  MIX_ENV:      dev

Running fwup...
fwup: Upgrading partition B
|====================================| 100% (29.61 / 29.61) MB
Success!
Elapsed time: 6.607s
Rebooting...
```

`nerves_firmware_ssh` exposes Eshell over ssh port 8989. From there we can run an IEX console and check the logs, see which processes are running, etc.
```bash
ssh nerves.local -p 8989
Eshell V9.2  (abort with ^G)
1> 'Elixir.IEx':start().
<0.464.0>
Interactive Elixir (1.6.1) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> RingLogger.attach
:ok
iex(2)> RingLogger.tail
00:00:05.946 [info]  Start Network Interface Worker
<truncated list of logs>
```

Code in this post is available at <a href="https://github.com/erkki/hello_nerves">https://github.com/erkki/hello_nerves</a>.