defmodule GPGMEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :gpgmex,
      version: "0.0.1",
      elixir: "~> 1.12",
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: [docs: "zig_doc"],
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
      licenses: ["GPL-3.0-or-later"],
      files: ["lib", "mix.exs", "README.md", "CHANGELOG.md", "COPYING*"],
      maintainers: ["Matt Silbernagel"],
      links: %{:GitHub => "https://github.com/silbermm/gpgmex"}
    ]
  end

  defp deps do
    [
      # {:zigler, "~> 0.8.1", runtime: false},
      {:zigler, path: "./zigler", runtime: false},
      # {:zigler_format, "~> 0.1.0"},
      {:ex_doc, "~> 0.27.1", runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
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
