defmodule GPG.NativeAPI do
  @moduledoc false

  @doc "Returns the version of GPG on the users system"
  @callback check_version :: any()

  @doc "Is OpenPGP supported on the users system"
  @callback check_openpgp_supported() :: any()

  @doc "Returns info about PGP on the users system"
  @callback engine_info() :: any()

  @doc "Return the filename from engine_info"
  @callback get_filename(reference()) :: any()

  @doc "Return the homedir from engine_info"
  @callback get_homedir(reference()) :: any()

  @doc "Creates a reference to the GPG context"
  @callback create_context() :: any()

  @doc "Encrypt some text"
  @callback encrypt(reference(), binary(), binary()) :: any()

  @doc "Decrypt some encrypted text"
  @callback decrypt(reference(), binary()) :: any()

  @doc "Get your public key"
  @callback public_key(reference(), binary()) :: any()

  @doc "Generate a key"
  @callback generate_key(reference(), binary()) :: any()

  @doc "Delete a key"
  @callback delete_key(reference(), binary()) :: any()

  @doc "Import a key"
  @callback import_key(reference(), binary()) :: any() 

  defp impl, do: Application.get_env(:gpgmex, :native_api, GPG.NIF)

  def check_version(), do: impl().check_version()
  def check_openpgp_supported(), do: impl().check_openpgp_supported()
  def engine_info(), do: impl().engine_info()
  def get_filename(ref), do: impl().get_filename(ref)
  def get_homedir(ref), do: impl().get_homedir(ref)
  def create_context(), do: impl().create_context()
  def encrypt(ref, email, text), do: impl().encrypt(ref, email, text)
  def decrypt(ref, text), do: impl().decrypt(ref, text)
  def public_key(ref, email), do: impl().public_key(ref, email)
  def generate_key(ref, email), do: impl().generate_key(ref, email)
  def delete_key(ref, email), do: impl().delete_key(ref, email)
  def import_key(ref, data), do: impl().import_key(ref, data)
end
