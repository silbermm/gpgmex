defmodule GPG.Zig.Support do
  @moduledoc false

  @include Application.compile_env(:gpgmex, :include_dir, ["/usr/include"])
  @libs Application.compile_env(:gpgmex, :libs_dir, ["/usr/lib/libgpgme.so"])

  defmacro __using__(_) do
    quote do
      use Zig,
        libs: unquote(@libs),
        include: unquote(@include),
        link_libc: true
    end
  end
end
