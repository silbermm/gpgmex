# GPGMEx

Native Elixir bindings for GnuPG.

**This is in early stages of development and should be thought of as Alpha software.**

## Getting Started

> This has only been tested on Linux - It likely won't work for
> Mac OSX or Windows yet.

You'll need:
  * a working version of [gpg](https://gnupg.org/) installed
  * [gpgme c library](https://gnupg.org/related_software/gpgme/index.html)
  * configuration added to `config.exs` 

### Debian based (ubuntu, pop-os, etc)

**Installing gpg and gpgme**

```bash
$ sudo apt install gpg libgpgme-dev
```

**Configuration**

Add this to `config.exs` in your app

```elixir
config :gpgmex,
  include_dir: ["/usr/include/x86_64-linux-gnu", "/usr/include"],
  lib_dir: ["/usr/lib/x86_64-linux-gnu/libgpgme.so"]
```

### Arch based (Arch, Manjaro, etc)

**Installing gpg and gpgme**

```bash
$ sudo pacman -Syu gpg gpgme
```

**Configuration**

Add this to `config.exs` in your app

```elixir
config :gpgmex,
  include_dir: ["/usr/include"],
  lib_dir: ["/usr/lib/libgpgme.so"]
```

### Finally

Add gpgmex to your dependencies
```elixir
  defp deps do
    [
      {:gpgmex, github: "silbermm/gpgmex"}
    ]
  end
```

## Usage


