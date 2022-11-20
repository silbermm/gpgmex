import Config

config :gpgmex,
  native_api: GPG.Rust.GPG


import_config "#{config_env()}.exs"
