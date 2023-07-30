defmodule GPGTest do
  use GPG.Case, async: true

  @user_email "test@test.com"
  @invalid_email "invalid@test.com"

  # this requires that GPG key exists on the system for @user_email.
  # To do this, simply load iex and run `GPG.generate_key/1` and 
  # don't use a password
  describe "encrypt and decrypt" do
    # I would rather do this, but haven't found a way to yet
    # setup do
    #   # create a new key
    #   GPG.generate_key(@user_email)
    #   on_exit(fn -> 
    #     GPG.delete_key(@user_email) 
    #   end)
    # end

    @tag :integration
    test "encrypt is successful" do
      data = "This data should be encrypted"
      {:ok, cipher} = GPG.encrypt(@user_email, data)
      assert String.contains?(cipher, "-----BEGIN PGP MESSAGE-----")
    end

    @tag :integration
    test "decrypt is successful" do
      data = "This data should be encrypted"
      {:ok, cipher} = GPG.encrypt(@user_email, data)
      assert String.contains?(cipher, "-----BEGIN PGP MESSAGE-----")
      {:ok, decrypted} = GPG.decrypt(cipher)
      assert decrypted == data
    end

    test "handles non-existent key when encrypting" do
      data = "This data should fail to be encrypted"
      cipher = GPG.encrypt(@invalid_email, data)
      assert cipher == {:error, "Not found (gpg error 27)"}
    end

    test "handles invalid data when decrypting" do
      data = "-----BEGIN PGP MESSAGE-----"
      plain_text = GPG.decrypt(data)
      assert plain_text == {:error, "No data (gpg error 58)"}
    end
  end

  @tag :integration
  test "gets gpg version" do
    version = GPG.get_engine_version()
    assert version == "1.17.1"
  end

  test "gets engine info" do
    assert GPG.get_engine_info().directory == "~/.gnupg"
  end

  test "lists gpg keys" do
    keys = GPG.list_keys()
    assert Enum.find(keys, fn k -> k.email == [@user_email] end)
  end

  test "generate key fails for already existing key" do
    assert {:error, msg} = GPG.generate_key(@user_email)
    assert msg =~ "User ID already exists"
  end
end
