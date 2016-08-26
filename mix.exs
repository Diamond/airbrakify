defmodule Airbrakify.Mixfile do
  use Mix.Project

  def project do
    [
      app: :airbrakify,
      version: "0.0.2",
      elixir: "~> 1.2",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps,
      description: description,
      package: package
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpoison]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:httpoison, ">= 0.8.2"},
      {:poison,    ">= 1.5.2"},
      {:plug,      ">= 1.1.1"},
      {:ex_doc,    ">= 0.0.0", only: [:dev]}
    ]
  end

  defp description do
    """
    A simple Airbrake/Errbit library for Elixir/Phoenix projects. Currently only
    supports error/exception notifications via a Plug.
    """
  end

  defp package do
    [
      files: ["lib", "config", "test", "README.md", "mix.exs", "license"],
      maintainers: ["Brandon Richey"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/Diamond/airbrakify"}
    ]
  end
end
