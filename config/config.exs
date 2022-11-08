import Config

config :gpgmex,
  native_api: GPG.NIF

import_config "#{config_env()}.exs"
