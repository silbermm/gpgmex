defmodule GPGTest do
  use ExUnit.Case
  doctest GPG

  test "gets gpg version" do
    version = GPG.check_version()
    assert version != []
    assert version != ''
    assert version != nil
    assert to_string(version) == "1.16.0"
  end

  test "checks if openpgp supported" do
    assert GPG.check_openpgp_supported()
  end

  test "gets engine info" do
    assert GPG.engine_info().filename == "/usr/bin/gpg"
  end
end
