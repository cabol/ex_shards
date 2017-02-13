defmodule ExShards do
  @moduledoc """
  Shards API – This is the equivalent module to `shards`.

  To build match specs for `select` functions, you can use `Ex2ms`
  library – it is included in `ExShards`.

  ## Examples

      # this is required to build match specs for select operations
      > require Ex2ms

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

      > ms = Ex2ms.fun do {_, v} -> v end
      [{{:_, :"$1"}, [], [:"$1"]}]
      > ExShards.select :mytab, ms
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

  @type tab :: atom
  @type key :: term
  @type value :: term
  @type state :: ExShards.State.t

  ## API

  construct :shards, exclude_all: [:start, :stop], exclude: [new: 2]

  @doc false
  def new(tab, opts \\ []), do: :shards.new(tab, opts)

  ## Extended API

  @spec drop(tab, Enumerable.t) :: map
  def drop(tab, keys), do: call(tab, :drop, [tab, keys])

  @spec fetch(tab, key) :: {:ok, value} | :error
  def fetch(tab, key), do: call(tab, :fetch, [tab, key])

  @spec fetch!(tab, key) :: value | no_return
  def fetch!(tab, key), do: call(tab, :fetch!, [tab, key])

  @spec get(tab, key, value) :: value | [value]
  def get(tab, key, default \\ nil), do: call(tab, :get, [tab, key, default])

  @spec get_and_update(tab, key, (value -> {get, update} | :pop)) :: {get, update} when get: term, update: term
  def get_and_update(tab, key, fun) when is_function(fun, 1), do: call(tab, :get_and_update, [tab, key, fun])

  @spec get_and_update!(tab, key, (value -> {get, update} | :pop)) :: {get, update} | no_return when get: term, update: term
  def get_and_update!(tab, key, fun) when is_function(fun, 1), do: call(tab, :get_and_update!, [tab, key, fun])

  @spec has_key?(tab, key) :: boolean
  def has_key?(tab, key), do: call(tab, :has_key?, [tab, key])

  @spec keys(tab) :: [key]
  def keys(tab), do: call(tab, :keys, [tab])

  @spec pop(tab, key, value) :: {tab, value | [value]}
  def pop(tab, key, default \\ nil), do: call(tab, :pop, [tab, key, default])

  @spec put(tab, key, value) :: tab
  def put(tab, key, value), do: call(tab, :put, [tab, key, value])

  @spec put_new(tab, key, value) :: tab
  def put_new(tab, key, value), do: call(tab, :put_new, [tab, key, value])

  @spec remove(tab, key) :: tab
  def remove(tab, key), do: call(tab, :remove, [tab, key])

  @spec set(tab, tuple | [tuple]) :: tab
  def set(tab, obj_or_objs), do: call(tab, :set, [tab, obj_or_objs])

  @spec update(tab, key, value, (value -> value)) :: tab
  def update(tab, key, initial, fun), do: call(tab, :update, [tab, key, initial, fun])

  @spec update!(tab, key, (value -> value)) :: tab | no_return
  def update!(tab, key, fun), do: call(tab, :update!, [tab, key, fun])

  @spec update_elem(tab, key, term) :: tab
  def update_elem(tab, key, element_spec), do: call(tab, :update_elem, [tab, key, element_spec])

  @spec values(tab) :: [value]
  def values(tab), do: call(tab, :values, [tab])

  ## Private functions

  defp call(tab, fun, args) do
    state = ExShards.State.get(tab)
    module = case ExShards.State.module(state) do
      :shards_local -> ExShards.Local
      :shards_dist  -> ExShards.Dist
    end
    apply(module, fun, args ++ [state])
  end
end
