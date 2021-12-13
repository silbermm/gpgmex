# GPGMEx - Native Elixir bindings for GnuPG
# Copyright (C) 2021  Matt Silbernagel
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
defmodule GPG do
  @moduledoc """
  GnuPG bindings
  """

  @doc "Get the currently installed GPG version."
  @spec get_engine_version() :: String.t()
  def get_engine_version do
    version = GPG.NIF.check_version()
    to_string(version)
  end

  @doc "Get information about the currently installed GPG service."
  @spec get_engine_info() :: map()
  def get_engine_info() do
    ref = GPG.NIF.engine_info()
    filename = GPG.NIF.get_filename(ref)
    %{filename: to_string(filename)}
  end

  @doc "Creates a context and returns the reference."
  @spec create_context() :: reference()
  def create_context() do
    # must check_version before creating a context
    # TODO: what if check_version fails?
    _version = GPG.NIF.check_version()
    GPG.NIF.create_context()
  end

  @doc "Get the public key for an email"
  @spec get_public_key(binary()) :: binary()
  def get_public_key(email) do
    create_context()
    |> GPG.NIF.public_key(email)
    |> Enum.take_while(&(&1 != 170))
    |> to_string()
  end

  @doc """
  Encrypt data for the requtested email recipient

  ## Examples

      iex> encrypt("myemail@mydomain.com", "data to encrypt")
      "-----BEGIN PGP MESSAGE-----\\n\\nhQIMA1M1Dqrc4va7ARAAtivmEVIg8WAqYgrLBmFbU1iqp2qhfUq9QyPyJLEfmsOg\\nsJm4L7ZG4LKAA9YpEREzmOYr722MfzN2MDy3ssgBJ2/hHBRIXR5fQrlib6dQnyzE\\nkcN2jpUHlmy3p0CTXkH/i1NG3xSRcoapruFvvICCRE+s6zMrtM5qxlEPSV11NHlG\\nEN/wyCfLc66Xu2vGMpLY+9wIeHJmYK7Zpy2K+snHqdnNRnAY2VGZITAcaXjfIjqB\\nKV54ZD1DKebi5P8mJ0pRhgIvCpTVR4+MJk+s5/Rkase6Ckp3jar/Tj5vlbMEPqb7\\nrsp0PoBqE7PNaMXu9sOu/XUwMOLiKsBnpuBojXbrUEHn7/WZ2gd5n1+qax0e9k4X\\nzv+yJ1HV/M6xBsQQfrUB1OoDCHBNjuQPYHcBV7LcQYlBJ80gopgUcsNnZTW9seAN\\nn/6ZUdBeDs7U/CFTinMdOukHp0bqcCd1A69CvCl2zzj/SnNESL01az4wT4AiK3YU\\ntpQ6zznCroxaYd6zJx5xtCBh1xtb4BruRrygvrEI0XpdQ6SU02jr+KqcB3pPhbqI\\nr8woSdHNs2fU+mEGPf2mgPmKAmygnzveE99gpha/dk7NGmnNg3ExQF+jaY4+ADBY\\ndh3Zx9JNurL8EwoNSL/PWw/7suM7vkWy0FaInXVcvEhFfVFu6fRsKPTMJ8+GB9PS\\nSgFHykbYtA3PgISBswfYpI68ynOGRes3jT/Uktu7l4MbDnOere/OAq629awDYG6H\\nFWVc8kcPIRp2LoI8FeYcZz/dj8UJAAP57r58\\n=T/Al\\n-----END PGP MESSAGE-----\\n"

  """
  @spec encrypt(String.t(), binary()) :: binary()
  def encrypt(email, data) do
    create_context()
    |> GPG.NIF.encrypt(email, data)
    |> Enum.take_while(&(&1 != 170))
    |> to_string()
  end

  @doc "Decrypt the given data"
  @spec decrypt(binary()) :: binary()
  def decrypt(data) do
    create_context()
    |> GPG.NIF.decrypt(data)
    |> Enum.take_while(&(&1 != 170))
    |> to_string()
  end
end
