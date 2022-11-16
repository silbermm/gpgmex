# NIF for Elixir.GPG.NIF.Rust

## To build the NIF module:

- Your NIF will now build along with your project.

## To load the NIF:

```elixir
defmodule GPG.NIF.Rust do
  use Rustler, otp_app: :gpgmex, crate: "gpg_nif_rust"

  # When your NIF is loaded, it will override this function.
  def add(_a, _b), do: :erlang.nif_error(:nif_not_loaded)
end
```

## Examples

[This](https://github.com/rusterlium/NifIo) is a complete example of a NIF written in Rust.
