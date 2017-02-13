defmodule ExShards.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_shards,
     version: "0.1.0",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     package: package(),
     description: "ExShards – Elixir Wrapper for cabol/shards"]
  end

  def application do
    [applications: [:logger, :shards]]
  end

  defp deps do
    [{:shards, "~> 0.4"},
     {:ex2ms, "~> 1.4"},
     {:ex_doc, ">= 0.0.0", only: :dev}]
  end

  defp package do
    [name: :ex_shards,
     maintainers: ["Carlos A Bolanos"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/cabol/ex_shards"}]
  end
end
