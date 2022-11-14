defmodule GPG.NIF.Rust do
  use Rustler, otp_app: :gpgmex, crate: "gpg_nif_rust"

  @behaviour GPG.NativeAPI

  @impl true
  def check_version(), do: :erlang.nif_error(:nif_not_loaded)

  @impl true
  def check_openpgp_supported(), do: :erlang.nif_error(:nif_not_loaded)

  @impl true
  def engine_info(), do: :erlang.nif_error(:nif_not_loaded)

  @impl true
  def get_filename(_ref), do: :erlang.nif_error(:nif_not_loaded)

  @impl true
  def get_homedir(_ref), do: :erlang.nif_error(:nif_not_loaded)

  @impl true
  def create_context(), do: :erlang.nif_error(:nif_not_loaded)

  @impl true
  def encrypt(_email, _data), do: :erlang.nif_error(:nif_not_loaded)

  @impl true
  def decrypt(_ref, _data), do: :erlang.nif_error(:nif_not_loaded)

  @impl true
  def public_key(_ref, _email), do: :erlang.nif_error(:nif_not_loaded)

  @impl true
  def generate_key(_reference, _binary), do: :erlang.nif_error(:nif_not_loaded)

  @impl true
  def delete_key(_reference, _binary), do: :erlang.nif_error(:nif_not_loaded)

  @impl true
  def import_key(_reference, _binary), do: :erlang.nif_error(:nif_not_loaded)

end
