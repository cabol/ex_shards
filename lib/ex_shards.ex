defmodule ExShards do
  @moduledoc """
  Shards API – This is the equivalent module to `shards`.

  ## Examples

      # create a table with default options
      > ExShards.new :mytab
      :mytab

      > ExShards.insert :mytab, [k1: 1, k2: 2, k3: 3]
      true

      > for k <- [:k1, :k2, :k3] do
      [{_, v}] = ExShards.lookup(:mytab, k)
      v
      end
      [1, 2, 3]

      > ExShards.delete :mytab, :k3
      true
      > ExShards.lookup :mytab, :k3
      []

      # let's create another table
      > ExShards.new :mytab2, [{:n_shards, 4}]
      :mytab2

      # start the observer so you can see how shards behaves
      > :observer.start
      :ok

  ## Links:

    * [Shards](https://github.com/cabol/shards)
    * [API Reference](http://cabol.github.io/shards)
  """

  use ExShards.API

  defapi :shards, exclude_all: [:start, :stop], exclude: [new: 2]

  def new(tab, opts \\ []), do: :shards.new(tab, opts)
end
