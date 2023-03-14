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

    expect(GPG.MockNativeAPI, :clear_sign, fn _data ->
      {:ok,
       "-----BEGIN PGP SIGNED MESSAGE-----\nHash: SHA512\n\ndata\n-----BEGIN PGP SIGNATURE-----\n\niQIzBAEBCgAdFiEEgMj3rmTliUSfsKA5dNtnCEIt0zsFAmQPzq0ACgkQdNtnCEIt\n0zvsmw/+JZWfHhbHgqy9lw11QuagovqV0HQdk9C/wrzbrmeAP8g+AvkDDbo2GTP7\neHOfOaWJDCD6qWvSt//JIs8khQfnQ3faBhPunQt+iPze1N9JSKTbJway3fJKr5dQ\nyFAjFDt/AHFCGUzE37eld/TE+ehsj3H7fTxAe9GdPWM3r3n9MpggzCb5YQYSk7yy\nYdWOWIhbyVt7RTk4hzuNh4wWaprQvuU38saDMMkZbHUxR0oIIoomfgsywLdb0HZA\n8iGvex7uqyWPHCY2NMpdSJ4E0xBNURwarlHE32/sRZrISAMfW/nWY4tTWFHN8Spz\ncBDclyzFkwjihMz/+9Dl4VfTN7UQuFh3/4Z12dl0RS9d1sz45bVcNy5DapArviOj\nmaAzvYyodWQ8qthWZDT+ZAPCIky61gVLkcxqXArTamoxQbxBsLkGrNx2Up8caYBK\nPH6o8XuIXTb640jzpOgPSL63qfn3HgvZr/9nyyhrZv3ASroSOCcLgvBaxl4MZ0pN\nKnKJnklhCKdKcz2as+KPpWGXA7WKY5s/7JQdZDdSA2zYHwirNI0qaZ5UFgkyJWzJ\ncu+v/ZjVgeidPKCD65Yn3UIY2wXWTqDcI5sSWXFTHnVljEeC16yjuzYWXgvYLDrM\n0ypPbndz7WBckg5UKukAWPwQl0P61zBmywx13UZ1/9cww7Gp9Jw=\n=MgoU\n-----END PGP SIGNATURE-----\n"}
    end)

    expect(GPG.MockNativeAPI, :generate_key, fn _email ->
      :ok
    end)

    :ok
  end
end
