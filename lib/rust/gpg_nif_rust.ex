defmodule GPG.NIF.Rust do
  use Rustler, otp_app: :gpgmex, crate: "gpg_nif_rust"

  def check_version(), do: :erlang.nif_error(:nif_not_loaded)
  def check_openpgp_supported(), do: :erlang.nif_error(:nif_not_loaded)
  def engine_info(_home, _path), do: :erlang.nif_error(:nif_not_loaded)
  def get_filename(_ref), do: :erlang.nif_error(:nif_not_loaded)
  def get_homedir(_ref), do: :erlang.nif_error(:nif_not_loaded)
  def encrypt(_email, _data, _home_dir, _path), do: :erlang.nif_error(:nif_not_loaded)
  def decrypt(_data, _home_dir, _path), do: :erlang.nif_error(:nif_not_loaded)
  def public_key(_email), do: :erlang.nif_error(:nif_not_loaded)
  def generate_key(_reference, _binary), do: :erlang.nif_error(:nif_not_loaded)
  def delete_key(_reference, _binary), do: :erlang.nif_error(:nif_not_loaded)
  def import_key(_binary, _home_dir, _path), do: :erlang.nif_error(:nif_not_loaded)
end
