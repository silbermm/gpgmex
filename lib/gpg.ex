# GPGMEx - Native Elixir bindings for GnuPG
# Copyright (C) 2022  Matt Silbernagel
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
defmodule GPG do
  @moduledoc """
  Native [GnuPG](https://gnupg.org/) bindings

  > ### Warning {: .warning}
  >
  > This is still a work in progress and the API is likely to 
  > change. It is not considered producion quality yet.

  > ### Warning {: .error}
  >
  > This has only been tested on Linux - It likely won't work for
  > Mac OSX or Windows yet.

  ## Getting Started

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
  config :zigler,
  include: ["/usr/include/x86_64-linux-gnu", "/usr/include"],
  libs: ["/usr/lib/x86_64-linux-gnu/libgpgme.so"]
  ```

  ### Arch based (Arch, Manjaro, etc)

  **Installing gpg and gpgme**

  ```bash
  $ sudo pacman -Syu gpg gpgme
  ```

  **Configuration**

  Add this to `config.exs` in your app

  ```elixir
  config :zigler,
  include: ["/usr/include"],
  libs: ["/usr/lib/libgpgme.so"]
  ```

  ## Finally

  Add gpgmex to your dependencies
  ```elixir
  defp deps do
    [
      {:gpgmex, github: "silbermm/gpgmex"}
    ]
  end
  ```
  """

  @doc """
  Get the currently installed GPG library version
  """
  @spec get_engine_version() :: String.t() | :error
  def get_engine_version do
    version = GPG.NIF.check_version()
    to_string(version)
  catch
    _e -> :error
  end

  @doc """
  Get information about the currently installed GPG library
  """
  @spec get_engine_info() :: map() | :error
  def get_engine_info() do
    ref = GPG.NIF.engine_info()
    filename = GPG.NIF.get_filename(ref)
    %{filename: to_string(filename)}
  catch
    _e -> :error
  end

  @spec create_context() :: reference() | {:error, any()}
  defp create_context() do
    # must check_version before creating a context
    _version = GPG.NIF.check_version()
    GPG.NIF.create_context()
  catch
    e -> {:error, e}
  end

  @doc """
  Get the public key for an email if the public key is on your system
  """
  @spec get_public_key(binary()) :: binary() | :error
  def get_public_key(email) do
    create_context()
    |> GPG.NIF.public_key(email)
    |> Enum.take_while(&(&1 != 170))
    |> to_string()
  catch
    _e -> :error
  end

  @doc """
  Encrypt data for the requested email recipient

  This works for any public key you have on your system.
  If you don't have the key on your system `{:error, :keynoexist}`
  is returned
  """
  @spec encrypt(String.t(), binary()) :: {:ok, binary()} | {:error, atom()}
  def encrypt(email, data) do
    create_context()
    |> GPG.NIF.encrypt(email, data)
    |> then(fn
      {:ok, result} ->
        data =
          result
          |> Enum.take_while(&(&1 != 170))
          |> to_string()

        {:ok, data}

      {:error, reason} ->
        IO.inspect(reason)
        {:error, :keynoexist}
    end)
  catch
    _e -> {:error, :unknown}
  end

  @doc """
  Decrypt the given data. 

  This only works if you have the
  private key available on your system that matches the 
  public key that encrypted it
  """
  @spec decrypt(binary()) :: {:ok, binary()} | {:error, binary()}
  def decrypt(data) do
    create_context()
    |> GPG.NIF.decrypt(data)
    |> then(fn
      {:ok, result} ->
        data =
          result
          |> Enum.take_while(&(&1 != 170))
          |> to_string()

        {:ok, data}

      e ->
        e
    end)
  catch
    e -> {:error, to_string(e)}
  end

  @doc """
  Generate a GPG key using the provided email address
  """
  @spec generate_key(String.t()) :: binary() | :error
  def generate_key(email) do
    create_context()
    |> GPG.NIF.generate_key(email)
  catch
    _e -> :error
  end

  @doc """
  Delete an existing GPG key
  """
  @spec delete_key(binary()) :: number() | :error
  def delete_key(email) do
    create_context()
    |> GPG.NIF.delete_key(email)
  catch
    _e -> :error
  end
end
