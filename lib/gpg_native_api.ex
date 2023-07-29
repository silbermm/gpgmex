defmodule GPG.NativeAPI do
  @moduledoc false

  @doc "Returns the version of GPG on the users system"
  @callback check_version :: any()

  @doc "Is OpenPGP supported on the users system"
  @callback check_openpgp_supported() :: any()

  @doc "Returns info about PGP on the users system"
  @callback engine_info() :: any()

  @doc "Return the filename from engine_info"
  @callback get_filename() :: any()

  @doc "Return the homedir from engine_info"
  @callback get_homedir() :: any()

  @doc "Encrypt some text"
  @callback encrypt(binary(), binary()) :: any()

  @doc "Decrypt some encrypted text"
  @callback decrypt(binary()) :: any()

  @doc "Clear sign some data"
  @callback clear_sign(binary()) :: any()

  @doc "Verify some clear signed text"
  @callback verify_clear(binary()) :: any()

  @doc "Get your public key"
  @callback public_key(binary()) :: any()

  @doc "Generate a key"
  @callback generate_key(binary()) :: any()

  @doc "Delete a key"
  @callback delete_key(binary()) :: any()

  @doc "Import a key"
  @callback import_key(binary()) :: any()

  @doc """
  Get information about the passed in public key
  """
  @callback key_info(binary()) :: any()

  @doc "List local keys"
  @callback list_keys() :: any()

  defp impl, do: Application.get_env(:gpgmex, :native_api, GPG.Rust.GPG)

  def check_version(), do: impl().check_version()
  def check_openpgp_supported(), do: impl().check_openpgp_supported()
  def engine_info(), do: impl().engine_info()
  def get_filename(), do: impl().get_filename()
  def get_homedir(), do: impl().get_homedir()
  def encrypt(email, text), do: impl().encrypt(email, text)
  def decrypt(text), do: impl().decrypt(text)
  def clear_sign(text), do: impl().clear_sign(text)
  def verify_clear(text), do: impl().verify_clear(text)
  def public_key(email), do: impl().public_key(email)
  def generate_key(email), do: impl().generate_key(email)
  def delete_key(email), do: impl().delete_key(email)
  def import_key(data), do: impl().import_key(data)
  def key_info(public_key), do: impl().key_info(public_key)
  def list_keys(), do: impl().list_keys()
end
