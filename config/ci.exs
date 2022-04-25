import Config

config :zigler,
  include: ["/usr/include/x86_64-linux-gnu", "/usr/include"],
  libs: ["/usr/lib/x86_64-linux-gnu/libgpgme.so"]

config :gpgmex, :native_api, GPG.MockNativeAPI
