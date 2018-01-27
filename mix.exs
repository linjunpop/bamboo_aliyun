defmodule Bamboo.Aliyun.Mixfile do
  use Mix.Project

  @version "0.1.0"
  @project_url "https://github.com/linjunpop/bamboo_aliyun"

  def project do
    [
      app: :bamboo_aliyun,
      version: @version,
      elixir: "~> 1.4",
      source_url: @project_url,
      homepage_url: @project_url,
      name: "Bamboo Aliyun Adapter",
      description: "A Bamboo adapter for Aliyun",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      preferred_cli_env: [
        vcr: :test,
        "vcr.delete": :test,
        "vcr.check": :test,
        "vcr.show": :test
      ]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:bamboo, "~> 0.5"},
      {:hackney, "~> 1.6"},
      {:cowboy, "~> 1.0", only: [:test, :dev]},
      {:ex_doc, "~> 0.16", only: :dev},
      {:credo, "~> 0.8", only: [:dev, :test]},
      {:exvcr, "~> 0.9", only: :test}
    ]
  end

  defp package do
    [
      maintainers: ["Jun Lin"],
      licenses: ["MIT"],
      links: %{"GitHub" => @project_url}
    ]
  end
end
