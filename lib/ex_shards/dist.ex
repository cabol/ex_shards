defmodule ExShards.Dist do
  @moduledoc """
  Distributed Shards API – This is the equivalent module to `shards_dist`.

  Despite we have the `ExShards.Dist` module, it is not recomended to
  use it directly. The idea is to use the `ExShards` wrapper instead.
  This module is used internaly by `ExShards` when you create a table
  with global scope (`scope: :g`) – let's see the example below.

  ## Example

  **1.** Let's start 3 Elixir consoles running ExShards:

  Node `a`:

      $ iex --sname a@localhost -S mix

  Node `b`:

      $ iex --sname b@localhost -S mix

  Node `c`:

      $ iex --sname c@localhost -S mix

  **2.** Create a table with global scope (`scope: :g`) on each node and then join them.

      iex> ExShards.new :mytab, scope: :g, nodes: [:b@localhost, :c@localhost]
      :mytab

      iex> ExShards.get_nodes :mytab
      [:a@localhost, :b@localhost, :c@localhost]

  **3.** Now **ExShards** cluster is ready, let's do some basic operations:

  From node `a`:

      iex> ExShards.insert :mytab, k1: 1, k2: 2
      true

  From node `b`:

      iex> ExShards.insert :mytab, k3: 3, k4: 4
      true

  From node `c`:

      iex> ExShards.insert :mytab, k5: 5, k6: 6
      true

  Now, from any of previous nodes:

      iex> for k <- [:k1, :k2, :k3, :k4, :k5, :k6] do
      [{_, v}] = ExShards.lookup(:mytab, k)
      v
      end
      [1, 2, 3, 4, 5, 6]

  All nodes should return the same result.

  Let's do some deletions, from any node:

      iex> ExShards.delete :mytab, :k6
      true

  From any node:

      iex> ExShards.lookup :mytab, :k6
      []

  Let's check again all:

      iex> for k <- [:k1, :k2, :k3, :k4, :k5] do
      [{_, v}] = ExShards.lookup(:mytab, k)
      v
      end
      [1, 2, 3, 4, 5]

  ## Links:

    * [shards_dist](https://github.com/cabol/shards/blob/master/src/shards_dist.erl)
    * [API Reference](http://cabol.github.io/shards)
    * `ExShards.Ext` – Extended API
  """

  use ExShards.Construct
  use ExShards.Ext

  inject :shards_dist, except: [new: 2]

  @doc false
  def new(tab, opts \\ []), do: :shards_dist.new(tab, opts)
end
