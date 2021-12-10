defmodule GPGTest do
  use ExUnit.Case
  doctest GPG

  @user_email "matt@silbernagel.dev"

  test "gets gpg version" do
    version = GPG.get_engine_version()
    assert version == "1.16.0"
  end

  test "checks if openpgp supported" do
    assert GPG.check_openpgp_supported()
  end

  test "gets engine info" do
    assert GPG.get_engine_info().filename == "/usr/bin/gpg"
  end

  test "encrypt/decrypt" do
    data = "This data should be encrypted"
    ctx = GPG.context()
    cipher = GPG.encrypt_for(ctx, @user_email, data)
    assert cipher =~ "-----BEGIN PGP MESSAGE-----"

    plain_text = GPG.decrypt_data(ctx, cipher)
    assert plain_text == data
  end
end
