defmodule ExShards.State do
  @moduledoc """
  Shards State.

  This module overrides the original `shards_state` getter and setter
  functions in order to make them more pipe-operator friendly.

  ## Examples

      state = ExShards.State.new
      |> ExShards.State.module(:shards_dist)
      |> ExShards.State.n_shards(4)
      |> ExShards.State.pick_shard_fun(fun)
      |> ExShards.State.pick_node_fun(fun)

  ## Links:

    * [Shards](https://github.com/cabol/shards/blob/master/src/shards_state.erl)
  """

  use ExShards.API

  require Record

  @type op :: :r | :w | :d
  @type key :: term
  @type range :: integer
  @type pick_fun :: (key, range, op -> integer | :any)

  @n_shards System.schedulers_online()

  Record.defrecord :state, [
    module: :shards_local,
    n_shards: @n_shards,
    pick_shard_fun: &:shards_local.pick/3,
    pick_node_fun: &:shards_local.pick/3]

  @type t :: record(:state, [
    module: module,
    n_shards: integer,
    pick_shard_fun: pick_fun,
    pick_node_fun: pick_fun])

  construct :shards_state,
    exclude: [
      module: 2,
      n_shards: 2,
      pick_shard_fun: 2,
      pick_node_fun: 2]

  @doc false
  def module(state, module) do
    :shards_state.module(module, state)
  end

  @doc false
  def n_shards(state, n_shards) do
    :shards_state.n_shards(n_shards, state)
  end

  @doc false
  def pick_shard_fun(state, pick_shard_fun) do
    :shards_state.pick_shard_fun(pick_shard_fun, state)
  end

  @doc false
  def pick_node_fun(state, pick_node_fun) do
    :shards_state.pick_node_fun(pick_node_fun, state)
  end
end
