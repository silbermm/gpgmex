defmodule GPGMEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :gpgmex,
      version: "0.1.1",
      elixir: "~> 1.12",
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      description: "GPG Bindings",
      licenses: ["GPL-3.0-or-later"],
      files: [
        "lib",
        "native/gpg_rust_nif/Cargo.toml",
        "native/gpg_rust_nif/src",
        "mix.exs",
        "README.md",
        "CHANGELOG.md",
        "COPYING*"
      ],
      maintainers: ["Matt Silbernagel"],
      links: %{:GitHub => "https://github.com/silbermm/gpgmex", "GPG" => "https://gnupg.org/"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:ci), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:rustler, "~> 0.28.0"},
      {:ex_doc, "~> 0.29.0", runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :devci], runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test, :ci], runtime: false},
      {:mox, "~> 1.0", only: [:test, :ci], runtime: false}
    ]
  end

  defp docs do
    [
      main: "GPG",
      api_reference: false,
      extras: [
        "README.md": [filename: "introduction", title: "Introduction"],
        "CHANGELOG.md": [filename: "changelog", title: "Changelog"],
        LICENSE: [filename: "COPYING", title: "License"]
      ],
      authors: ["Matt Silbernagel"]
    ]
  end
end
