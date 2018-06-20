defmodule Bamboo.Aliyun.Mixfile do
  use Mix.Project

  @version "0.2.0"
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

  defp deps do
    [
      {:bamboo, "~> 1.0"},
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
