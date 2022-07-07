import Config

config :genex,
  include_dir: ["/usr/include/x86_64-linux-gnu", "/usr/include"],
  lib_dir: ["/usr/lib/x86_64-linux-gnu/libgpgme.so"]

config :gpgmex, :native_api, GPG.MockNativeAPI
