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

  ## Add to your Dependencies

  Add gpgmex to your dependencies
  ```elixir
  defp deps do
    [
      {:gpgmex, "~> 0.0.7"}
    ]
  end
  ```
  """

  @doc """
  Get the currently installed GPG library version

  ## Examples

      iex> GPG.get_engine_version()
      "1.17.1"
  """
  @spec get_engine_version() :: String.t() | :error
  def get_engine_version do
    version = GPG.NativeAPI.check_version()
    to_string(version)
  catch
    _e -> :error
  end

  @doc """
  Get information about the currently installed GPG library

  ## Examples

      iex> GPG.get_engine_info()
      %{bin: "/usr/bin/gpg", directory: "~/.gnupg"}
  """
  @spec get_engine_info() :: map() | :error
  def get_engine_info() do
    GPG.NativeAPI.engine_info()
  catch
    _e -> :error
  end

  @doc """
  Get the fingerprint of the public key for an email if the public key is on your system

  ## Examples

      iex> GPG.get_public_key("matt@silbernagel.dev")
      {:ok, "80C8F7AE64E589449FB0A03974DB6708422DD33B"}
  """
  @spec get_public_key(binary()) :: {:ok, binary()} | :error
  def get_public_key(email) do
    GPG.NativeAPI.public_key(email)
  catch
    _e -> :error
  end

  @doc """
  Encrypt data for the requested email recipient

  This works for any public key you have on your system.
  If you don't have the key on your system `{:error, :keynoexist}`
  is returned

  ## Examples

      iex> GPG.encrypt("matt@silbernagel.dev", "encrypt this text")
      {:ok, "-----BEGIN PGP MESSAGE-----\\n\\nhQIMA1M1Dqrc4va7AQ/"}
  """
  @spec encrypt(String.t(), binary()) :: {:ok, binary()} | {:error, atom()}
  def encrypt(email, data) do
    GPG.NativeAPI.encrypt(email, data)
  catch
    _e -> {:error, :unknown}
  end

  @doc """
  Decrypt the given data.

  This only works if you have the
  private key available on your system that matches the 
  public key that encrypted it

  ## Examples

      iex> GPG.decrypt("-----BEGIN PGP MESSAGE-----\\n\\nww8K2o8JL1ejKjJSOte0RmhLl6V7M6KW7p9D4Y1zHobTxVnGlmW64wxuWJx03Xs5\\nqymK+m7aUrAO0HL3vri3R2z1SisrUAeAtI/4v3GUWA00g4Q0rPzibDe3m53VkY7/\\nlyAzJSXL29LL93IJezx53GRK9+RYSBULYWLI3NPX10zidwKbnz+8jo41TIOx0SNh\\nt6aAyErC4pnepy7xq7IdWzSe/7v+lrcYpyGT35jyeR+e4N7N7SJV/+WQ+RxBQ/TS\\nPwHkMaec6aIgfLTt/lCryJFPEv02C5v0JQg8jJ7SjSH2FOk1y4HPIOJC/qatlLZq\\ntDiu13SA0+UBilW1j4AhXA==\\n=CXnG\\n-----END PGP MESSAGE-----\\n")
      {:ok, "data"}
  """
  @spec decrypt(binary()) :: {:ok, binary()} | {:error, binary()}
  def decrypt(data) do
    GPG.NativeAPI.decrypt(data)
  catch
    e -> {:error, to_string(e)}
  end

  @doc """
  Generate a GPG key using the provided email address.

  This generates a new GPG using rsa3072 encryption. It will
  use the system prompt to ask for a password.

  ## Examples

      iex> GPG.generate_key("my_new@email.com")
      :ok
  """
  @spec generate_key(String.t()) :: :ok | :error
  def generate_key(email) do
    GPG.NativeAPI.generate_key(email)
  catch
    _e -> :error
  end

  @doc """
  Delete an existing GPG key
  """
  @spec delete_key(binary()) :: number() | :error
  def delete_key(email) do
    GPG.NativeAPI.delete_key(email)
  catch
    _e -> :error
  end

  @doc """
  Import a public key
  """
  @spec import_key(binary()) :: :ok | {:error, binary()}
  def import_key(data) do
    GPG.NativeAPI.import_key(data)
  end

  @doc """
  Gets data about a public key
  """
  @spec key_info(binary()) :: map() | {:error, binary()}
  def key_info(public_key) do
    GPG.NativeAPI.key_info(public_key)
  end
end
