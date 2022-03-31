# GPGMEx

Native Elixir bindings for GnuPG.

**This is in early stages of development and should be thought of as Alpha software.**

## Installation

This has currently only been tested on Linux.

You'll need:
* Elixir
* gpgme (A C library wrapper for GnuPG) version 1.16.0
    * libgpgme.so is expected to be in `/usr/lib/`

Add gpgmex to your dependencies
```elixir
  defp deps do
    [
      {:gpgmex, github: "silbermm/gpgmex"}
    ]
  end
```
