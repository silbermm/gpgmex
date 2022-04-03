import Config

config :zigler,
  #include: ["/usr/include"],
  #libs: ["/usr/lib/libgpgme.so"]
  include: ["/usr/include/x86_64-linux-gnu", "/usr/include"],
  libs: ["/usr/lib/x86_64-linux-gnu/libgpgme.so"]
