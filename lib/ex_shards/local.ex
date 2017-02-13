defmodule ExShards.Local do
  @moduledoc """
  Local Shards API – This is the equivalent module to `shards_local`.

  ## Examples

      # create a table with default options
      > ExShards.Local.new :mytab
      :mytab

      > ExShards.Local.insert :mytab, [k1: 1, k2: 2, k3: 3]
      true

      > for k <- [:k1, :k2, :k3] do
      [{_, v}] = ExShards.Local.lookup(:mytab, k)
      v
      end
      [1, 2, 3]

      > ExShards.Local.delete :mytab, :k3
      true
      > ExShards.Local.lookup :mytab, :k3
      []

      # let's create another table
      > ExShards.Local.new :mytab2, [{:n_shards, 4}]
      :mytab2

  ## Links:

    * [shards_local](https://github.com/cabol/shards/blob/master/src/shards_local.erl)
    * [API Reference](http://cabol.github.io/shards)
  """

  use ExShards.API
  use ExShards.API.Ext

  construct :shards_local, exclude: [new: 2]

  def new(tab, opts \\ []), do: :shards_local.new(tab, opts)
end
