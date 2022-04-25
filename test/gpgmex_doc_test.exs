defmodule GPGDocTest do
  use GPG.Case
  doctest GPG

  import Mox


  setup do
    ref = make_ref()
    ctx = make_ref()
    expect(GPG.MockNativeAPI, :check_version, fn -> "1.17.1" end)
    expect(GPG.MockNativeAPI, :engine_info, fn -> ref end)
    expect(GPG.MockNativeAPI, :get_filename, fn ^ref -> "/usr/bin/gpg" end)
    expect(GPG.MockNativeAPI, :get_homedir, fn ^ref -> "/home/user/.gpg" end)
    expect(GPG.MockNativeAPI, :create_context, fn -> ctx end)

    expect(GPG.MockNativeAPI, :public_key, fn ^ctx, "matt@silbernagel.dev" -> 
      [52, 114, 90, 83, 115, 76, 86, 104, 114, 115, 49, 74, 67, 80, 116, 82, 87, 109,
 85, 108, 49, 70, 50, 113, 50, 83, 53, 43, 77, 113, 66, 106, 84, 67, 89, 107,
 83, 50, 82, 107, 10, 112, 104, 117, 111, 54, 117, 52, 88, 81]
    end)

    expect(GPG.MockNativeAPI, :encrypt, fn ^ctx, "matt@silbernagel.dev", _txt ->
      {:ok,  [45, 45, 45, 45, 45, 66, 69, 71, 73, 78, 32, 80, 71, 80, 32, 77, 69, 83, 83,
  65, 71, 69, 45, 45, 45, 45, 45, 10, 10, 104, 81, 73, 77, 65, 49, 77, 49, 68,
  113, 114, 99, 52, 118, 97, 55, 65, 81, 47]}
    end)

    expect(GPG.MockNativeAPI, :encrypt, fn ^ctx, "noton@mysystem.com", _txt ->
      {:error, :any_reason}
    end)

    expect(GPG.MockNativeAPI, :decrypt, fn ^ctx, _data ->
    {:ok,  [100, 97, 116, 97, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170]}
    end)


    expect(GPG.MockNativeAPI, :generate_key, fn ^ctx, _email ->
      :ok
    end)

    :ok
  end
end
