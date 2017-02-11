defmodule ExShards.State do
  @moduledoc """
  Shards State.

  Links:
    * [Shards](https://github.com/cabol/shards/blob/master/src/shards_state.erl)
  """

  use ExShards.API

  defapi :shards_state, exclude: [module: 2, n_shards: 2, pick_shard_fun: 2, pick_node_fun: 2]

  def module(state, module) do
    :shards_state.module(module, state)
  end

  def n_shards(state, n_shards) do
    :shards_state.n_shards(n_shards, state)
  end

  def pick_shard_fun(state, pick_shard_fun) do
    :shards_state.pick_shard_fun(pick_shard_fun, state)
  end

  def pick_node_fun(state, pick_node_fun) do
    :shards_state.pick_node_fun(pick_node_fun, state)
  end
end
