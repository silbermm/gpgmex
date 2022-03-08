defmodule GPGMEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :gpgmex,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: [docs: "zig_doc"]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:zigler, "~> 0.7.2", runtime: false},
      {:ex_doc, "~> 0.27.1", runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
    ]
  end
end
