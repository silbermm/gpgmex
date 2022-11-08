import Config

config :gpgmex,
  include_dir: ["/usr/include/x86_64-linux-gnu", "/usr/include"],
  libs_dir: ["/usr/lib/x86_64-linux-gnu/libgpgme.so"],
  gpg_bin: "/usr/bin/gpg",
  gpg_home: "~/.gnupg",
  native_api: GPG.MockNativeAPI
