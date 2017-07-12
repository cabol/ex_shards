defmodule ExShards.Mixfile do
  use Mix.Project

  @version "0.2.1"

  def project do
    [app: :ex_shards,
     version: @version,
     elixir: "~> 1.2",
     deps: deps(),
     package: package(),
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
     description: "ExShards – Elixir Wrapper for cabol/shards"]
  end

  def application do
    [applications: [:shards]]
  end

  defp deps do
    [{:shards, "~> 0.5"},
     {:ex2ms, "~> 1.4"},
     {:ex_doc, ">= 0.0.0", only: :dev},
     {:excoveralls, "~> 0.6.2", only: :test}]
  end

  defp package do
    [name: :ex_shards,
     maintainers: ["Carlos A Bolanos"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/cabol/ex_shards"}]
  end
end
