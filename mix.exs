defmodule ExShards.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_shards,
     version: "0.2.0",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
     package: package(),
     description: "ExShards – Elixir Wrapper for cabol/shards"]
  end

  def application do
    [applications: [:shards]]
  end

  defp deps do
    [{:shards, "~> 0.4"},
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
