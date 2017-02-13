defmodule ExShardsTest do
  use ExUnit.Case

  @exclude_list [
    new: 1,
    drop: 2, drop: 3,
    fetch: 2, fetch: 3,
    fetch!: 2, fetch!: 3,
    get: 2, get: 3, get: 4,
    get_and_update: 3, get_and_update: 4,
    get_and_update!: 3, get_and_update!: 4,
    has_key?: 2, has_key?: 3,
    keys: 1, keys: 2,
    pop: 2, pop: 3, pop: 4,
    put: 3, put: 4,
    put_new: 3, put_new: 4,
    remove: 2, remove: 3,
    set: 2, set: 3,
    update: 4, update: 5,
    update!: 3, update!: 4,
    update_elem: 3, update_elem: 4,
    values: 1, values: 2]

  test "shards api" do
    ex_shards = ExShards.definitions -- @exclude_list
    shards = :exports
    |> :shards.module_info
    |> Keyword.drop([:module_info, :start, :stop])
    assert length(ex_shards) == length(shards)
    assert :lists.usort(ex_shards) == :lists.usort(shards)
  end

  test "shards_local api" do
    local = ExShards.Local.definitions -- @exclude_list
    shards_local = :exports
    |> :shards_local.module_info
    |> Keyword.drop([:module_info])
    assert length(local) == length(shards_local)
    assert :lists.usort(local) == :lists.usort(shards_local)
  end

  test "shards_dist api" do
    dist = ExShards.Dist.definitions -- @exclude_list
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
