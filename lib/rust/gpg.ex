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
defmodule GPG.Rust.GPG do
  @moduledoc """
  The module that calls into the actual NIF
  """
  @behaviour GPG.NativeAPI

  @gpg_bin Application.compile_env(:gpgmex, :gpg_bin, "/usr/bin/gpg")
  @gpg_home Application.compile_env(:gpgmex, :gpg_home, "~/.gnupg")

  alias GPG.Rust.NIF

  @impl true
  def check_version(), do: NIF.check_version()

  @impl true
  def check_openpgp_supported(), do: NIF.check_openpgp_supported()

  @impl true
  def engine_info(), do: NIF.engine_info(@gpg_home, @gpg_bin)

  @impl true
  def get_filename(), do: engine_info().path()

  @impl true
  def get_homedir(), do: engine_info().directory

  @impl true
  def encrypt(email, data), do: NIF.encrypt(email, data, @gpg_home, @gpg_bin)

  @impl true
  def decrypt(data), do: NIF.decrypt(data, @gpg_home, @gpg_bin)

  @impl true
  def public_key(email), do: NIF.public_key(email, @gpg_home, @gpg_bin)

  @impl true
  def generate_key(_binary), do: :erlang.nif_error(:nif_not_loaded)

  @impl true
  def delete_key(_binary), do: :erlang.nif_error(:nif_not_loaded)

  @impl true
  def import_key(data), do: NIF.import_key(data, @gpg_home, @gpg_bin)

  @impl true
  def key_info(public_key), do: NIF.key_info(public_key, @gpg_home, @gpg_bin)
end
