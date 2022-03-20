# GPGMEx - Native Elixir bindings for GnuPG
# Copyright (C) 2021  Matt Silbernagel
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

  [GnuPG](https://gnupg.org/) bindings

  ## Getting Started

  In order to use this library, you'll need a few things on your target system
    * A working version of [gpg](https://gnupg.org/) installed
    * [gpgme c library](https://gnupg.org/related_software/gpgme/index.html)

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
  """
  @spec encrypt(String.t(), binary()) :: binary() | {:error, :keynoexist}
  def encrypt(email, data) do
    create_context()
    |> GPG.NIF.encrypt(email, data)
    |> Enum.take_while(&(&1 != 170))
    |> to_string()
  catch
    _e -> {:error, :keynoexist}
  end

  @doc """
  Decrypt the given data. This only works if you have the
  private key available on your system that matches the 
  public key that encrypted it
  """
  @spec decrypt(binary()) :: binary() | :error
  def decrypt(data) do
    create_context()
    |> GPG.NIF.decrypt(data)
    |> Enum.take_while(&(&1 != 170))
    |> to_string()
  catch
    _e -> :error
  end

  @doc """
  Generate a GPG key using the provided email address 
  """
  @spec generate_key(String.t(), boolean()) :: binary() | :error
  def generate_key(email, with_password) do
    create_context()
    |> GPG.NIF.generate_key(email, with_password)
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
