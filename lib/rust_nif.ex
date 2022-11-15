defmodule GPG.RustNif do
  @moduledoc """
  The module that calls into the actual NIF
  """
  @behaviour GPG.NativeAPI

  @gpg_bin Application.compile_env(:gpgmex, :gpg_bin, "/usr/bin/gpg")
  @gpg_home Application.compile_env(:gpgmex, :gpg_home, "~/.gnupg")

  alias GPG.NIF.Rust

  @impl true
  def create_context() do 
    # this isn't required for the rust implementation, so we'll just
    # create an empty ref
    make_ref()
  end

  @impl true
  def check_version(), do: Rust.check_version()

  @impl true
  def check_openpgp_supported(), do: Rust.check_openpgp_supported()

  @impl true
  def engine_info(), do: Rust.engine_info(@gpg_home, @gpg_bin)

  @impl true
  def get_filename(_ref), do: engine_info().path()

  @impl true
  def get_homedir(_ref), do: engine_info().directory

  @impl true
  def encrypt(_ref, email, data), do: GPG.NIF.Rust.encrypt(email, data, @gpg_home, @gpg_bin)

  @impl true
  def decrypt(_ref, data), do: GPG.NIF.Rust.decrypt(data, @gpg_home, @gpg_bin)

  @impl true
  def public_key(_ref, _email), do: :erlang.nif_error(:nif_not_loaded)

  @impl true
  def generate_key(_reference, _binary), do: :erlang.nif_error(:nif_not_loaded)

  @impl true
  def delete_key(_reference, _binary), do: :erlang.nif_error(:nif_not_loaded)

  @impl true
  def import_key(_reference, data), do: GPG.NIF.Rust.import_key(data, @gpg_home, @gpg_bin)
end
