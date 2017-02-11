defmodule ExShardsTest do
  use ExUnit.Case
  doctest ExShards

  test "shards api" do
    ex_shards = ExShards.definitions
    shards = :exports
    |> :shards.module_info
    |> Keyword.drop([:module_info, :start, :stop])
    assert length(ex_shards) == length(shards)
    assert :lists.usort(ex_shards) == :lists.usort(shards)
  end

  test "shards_local api" do
    local = ExShards.Local.definitions
    shards_local = :exports
    |> :shards_local.module_info
    |> Keyword.drop([:module_info])
    assert length(local) == length(shards_local)
    assert :lists.usort(local) == :lists.usort(shards_local)
  end

  test "shards_dist api" do
    dist = ExShards.Dist.definitions
    shards_dist = :exports
    |> :shards_dist.module_info
    |> Keyword.drop([:module_info])
    assert length(dist) == length(shards_dist)
    assert :lists.usort(dist) == :lists.usort(shards_dist)
  end

  test "shards_state api" do
    state = ExShards.State.definitions
    shards_state = :exports
    |> :shards_state.module_info
    |> Keyword.drop([:module_info])
    assert length(state) == length(shards_state)
    assert :lists.usort(state) == :lists.usort(shards_state)
  end

  test "shards_state getters and setters" do
    fun = fn(x, y, z) -> :erlang.phash2({x, y, z}, 4) end

    expected = :shards_state.module(:shards_dist,
      :shards_state.n_shards(4,
        :shards_state.pick_shard_fun(fun,
          :shards_state.pick_node_fun(fun,
            :shards_state.new()))))

    new_state = ExShards.State.new
    |> ExShards.State.module(:shards_dist)
    |> ExShards.State.n_shards(4)
    |> ExShards.State.pick_shard_fun(fun)
    |> ExShards.State.pick_node_fun(fun)

    assert expected == new_state
  end
end
