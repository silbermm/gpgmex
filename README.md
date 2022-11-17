# GPGMEx

Native Elixir bindings for GnuPG.

**This is in early stages of development and should be thought of as Alpha software.**

## Getting Started

> This has only been tested on Linux

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
  gpg_home: "~/.gnupg",    # where your gpg home path is
  gpg_path: "/usr/bin/gpg" # where your gpg binary lives
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
  gpg_home: "~/.gnupg",    # where your gpg home path is
  gpg_path: "/usr/bin/gpg" # where your gpg binary lives
```

### Finally

Add gpgmex to your dependencies
```elixir
  defp deps do
    [
      {:gpgmex, "~> 0.0.7"}
    ]
  end
```

## Usage


