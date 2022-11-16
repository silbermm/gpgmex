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
defmodule GPG.Rust.NIF do
  use Rustler, otp_app: :gpgmex, crate: "gpg_rust_nif"

  def check_version(), do: :erlang.nif_error(:nif_not_loaded)
  def check_openpgp_supported(), do: :erlang.nif_error(:nif_not_loaded)
  def engine_info(_home, _path), do: :erlang.nif_error(:nif_not_loaded)
  def get_filename(_ref), do: :erlang.nif_error(:nif_not_loaded)
  def get_homedir(_ref), do: :erlang.nif_error(:nif_not_loaded)
  def encrypt(_email, _data, _home_dir, _path), do: :erlang.nif_error(:nif_not_loaded)
  def decrypt(_data, _home_dir, _path), do: :erlang.nif_error(:nif_not_loaded)
  def public_key(_email, _home_dir, _path), do: :erlang.nif_error(:nif_not_loaded)
  def generate_key(_reference, _binary), do: :erlang.nif_error(:nif_not_loaded)
  def delete_key(_reference, _binary), do: :erlang.nif_error(:nif_not_loaded)
  def import_key(_binary, _home_dir, _path), do: :erlang.nif_error(:nif_not_loaded)
end
