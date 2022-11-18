defmodule GPGDocTest do
  use GPG.Case, async: true
  doctest GPG

  import Mox

  setup do
    expect(GPG.MockNativeAPI, :check_version, fn -> "1.17.1" end)

    expect(GPG.MockNativeAPI, :engine_info, fn ->
      %{bin: "/usr/bin/gpg", directory: "~/.gnupg"}
    end)

    expect(GPG.MockNativeAPI, :get_filename, fn -> "/usr/bin/gpg" end)
    expect(GPG.MockNativeAPI, :get_homedir, fn -> "/home/user/.gpg" end)

    expect(GPG.MockNativeAPI, :public_key, fn "matt@silbernagel.dev" ->
      {:ok, "80C8F7AE64E589449FB0A03974DB6708422DD33B"}
    end)

    expect(GPG.MockNativeAPI, :encrypt, fn "matt@silbernagel.dev", _txt ->
      {:ok, "-----BEGIN PGP MESSAGE-----\n\nhQIMA1M1Dqrc4va7AQ/"}
    end)

    expect(GPG.MockNativeAPI, :encrypt, fn "noton@mysystem.com", _txt ->
      {:error, :any_reason}
    end)

    expect(GPG.MockNativeAPI, :decrypt, fn _data ->
      {:ok, "data"}
    end)

    expect(GPG.MockNativeAPI, :generate_key, fn _email ->
      :ok
    end)

    :ok
  end
end
