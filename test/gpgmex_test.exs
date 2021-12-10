defmodule GPGTest do
  use ExUnit.Case
  doctest GPG

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
end
