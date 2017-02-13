defmodule ExShards.Ext do
  @moduledoc """
  This module extends the Shards API providing some extra functions.

  To use the extended functions you have to do it through any of the modules
  in which these functions are injected: `ExShards.Local` or `ExShards.Dist`.
  Besides, you can use `ExShards` as well, since it is a wrapper on top
  of `ExShards.Local` and `ExShards.Dist` modules.

  ## Examples

      # using ExShards
      iex> ExShards.new :mytab
      :mytab
      iex> ExShards.set :mytab, a: 1, b: 2
      :mytab
      iex> ExShards.get :mytab, :a
      1
      iex> ExShards.fetch :mytab, :c
      :error

      # using ExShards.Local
      iex> ExShards.Local.new :mytab
      :mytab
      iex> ExShards.Local.set :mytab, a: 1, b: 2
      :mytab
      iex> ExShards.Local.get :mytab, :a
      1
      iex> ExShards.Local.fetch :mytab, :c
      :error

      # using ExShards.Dist
      iex> ExShards.Dist.new :mytab
      :mytab
      iex> ExShards.Dist.set :mytab, a: 1, b: 2
      :mytab
      iex> ExShards.Dist.get :mytab, :a
      1
      iex> ExShards.Dist.fetch :mytab, :c
      :error
  """

  @doc false
  defmacro __using__(_opts) do
    quote do
      @behaviour ExShards.Ext

      def drop(tab, keys, state \\ ExShards.State.new) do
        #Enum.each(keys, fn(key) -> delete(tab, key, state) end)
        Enum.each(keys, &(delete(tab, &1, state)))
        tab
      end

      def fetch(tab, key, state \\ ExShards.State.new) do
        case lookup(tab, key, state) do
          [{^key, val} | _] -> {:ok, val}
          []                -> :error
        end
      end

      def fetch!(tab, key, state \\ ExShards.State.new) do
        case fetch(tab, key, state) do
          {:ok, val} -> val
          :error     -> raise KeyError, key: key, term: tab
        end
      end

      def get(tab, key, default \\ nil, state \\ ExShards.State.new) do
        case lookup(tab, key, state) do
          []            -> default
          [{^key, val}] -> val
          [_ | _] = lst -> for {^key, val} <- lst, do: val
        end
      end

      def get_and_update(tab, key, fun, state \\ ExShards.State.new) when is_function(fun, 1) do
        current = case fetch(tab, key, state) do
          {:ok, val} -> val
          :error     -> nil
        end

        case fun.(current) do
          {_, update} = rs ->
            _ = put(tab, key, update, state)
            rs
          :pop ->
            _ = pop(tab, key, nil, state)
            {current, nil}
          other ->
            raise "the given function must return a two-element tuple or :pop, got: #{inspect(other)}"
        end
      end

      def get_and_update!(tab, key, fun, state \\ ExShards.State.new) when is_function(fun, 1) do
        case fetch(tab, key, state) do
          {:ok, value} ->
            case fun.(value) do
              {_, update} = rs ->
                _ = put(tab, key, update, state)
                rs
              :pop ->
                _ = pop(tab, key, nil, state)
                {value, nil}
              other ->
                raise "the given function must return a two-element tuple or :pop, got: #{inspect(other)}"
            end
          :error ->
            raise KeyError, term: tab, key: key
        end
      end

      def has_key?(tab, key, state \\ ExShards.State.new) do
        member(tab, key, state)
      end

      def keys(tab, state \\ ExShards.State.new) do
        ms = [{{:"$1", :_}, [], [:"$1"]}]
        select(tab, ms, state)
      end

      def pop(tab, key, default \\ nil, state \\ ExShards.State.new) do
        case take(tab, key, state) do
          []            -> default
          [{^key, val}] -> val
          [_ | _] = lst -> Enum.map(lst, fn({^key, val}) -> val end)
        end
      end

      def put(tab, key, value, state \\ ExShards.State.new) do
        set(tab, {key, value}, state)
      end

      def put_new(tab, key, value, state \\ ExShards.State.new) do
        _ = insert_new(tab, {key, value}, state)
        tab
      end

      def remove(tab, key, state \\ ExShards.State.new) do
        true = delete(tab, key, state)
        tab
      end

      def set(tab, obj_or_objs, state \\ ExShards.State.new) do
        _ = insert(tab, obj_or_objs, state)
        tab
      end

      def take_and_drop(tab, keys, state \\ ExShards.State.new) do
        Enum.reduce(keys, %{}, fn(key, acc) ->
          case pop(tab, key, nil, state) do
            nil -> acc
            val -> Map.put(acc, key, val)
          end
        end)
      end

      def update(tab, key, initial, fun, state \\ ExShards.State.new) when is_function(fun, 1) do
        case fetch(tab, key, state) do
          {:ok, val} -> update_elem(tab, key, {2, fun.(val)}, state)
          :error     -> put_new(tab, key, initial, state)
        end
      end

      def update!(tab, key, fun, state \\ ExShards.State.new) when is_function(fun, 1) do
        case fetch(tab, key, state) do
          {:ok, val} -> update_elem(tab, key, {2, fun.(val)}, state)
          :error     -> raise KeyError, key: key, term: tab
        end
      end

      def update_elem(tab, key, element_spec, state \\ ExShards.State.new) do
        _ = update_element(tab, key, element_spec, state)
        tab
      end

      def values(tab, state \\ ExShards.State.new) do
        ms = [{{:_, :"$1"}, [], [:"$1"]}]
        select(tab, ms, state)
      end
    end
  end

  @type tab :: atom
  @type key :: term
  @type value :: term
  @type state :: ExShards.State.t

  @doc """
  Drops the given `keys` from `tab`.

  If `keys` contains keys that are not in `tab`, they're simply ignored.

  ## Examples

      iex> ExShards.set(:mytab, a: 1, b: 2, a: 3, c: 4)
      iex> ExShards.drop(:mytab, [:a, :b, :e])
      :mytab
      iex> ExShards.keys(:mytab)
      [:c]
  """
  @callback drop(tab, Enumerable.t, state) :: tab

  @doc """
  Fetches the value for a specific `key` in the given `tab`.

  If `tab` contains the given `key` with value `value`, then `{:ok, value}`
  is returned. If `tab` doesn't contain `key`, `:error` is returned.

  Keep in mind that only one result is returned always, in case of `:bag`
  or `:duplicate bag`, only the first match is returned.

  ## Examples

      iex> ExShards.fetch(:mytab, :a)
      {:ok, 1}
      iex> ExShards.fetch(:mytab, :b)
      :error
  """
  @callback fetch(tab, key, state) :: {:ok, value} | :error

  @doc """
  Fetches the value for a specific `key` in the given `tab`, erroring out if
  `tab` doesn't contain `key`.

  If `tab` contains the given `key`, the corresponding value is returned. If
  `tab` doesn't contain `key`, a `KeyError` exception is raised.

  Keep in mind that only one result is returned always, in case of `:bag`
  or `:duplicate bag`, only the first match is returned.

  ## Examples

      iex> ExShards.fetch!(:mytab, :a)
      1
      iex> ExShards.fetch!(:mytab, :b)
      ** (KeyError) key :b not found in: :mytab
  """
  @callback fetch!(tab, key, state) :: value | no_return

  @doc """
  Gets the value or a list of values for a specific `key` in `tab`.

  Return possibilities:

    * `value` – If `key` is present in `tab` with value `value` (only
      one element matches).
    * `[value]` – In case of multiple elements matches with the key `key`.
      This behaviour is expected when the table is either a `:bag` or
      a `:duplicate_bag`.
    * `default` – If `key` is not present in `tab` (`default` is `nil`
      unless specified otherwise).

  ## Examples

      iex> ExShards.get(:mytab, :a)
      nil
      iex> :mytab |> ExShards.put(:a, 1) |> ExShards.get(:a)
      1
      iex> ExShards.get(:mytab, :b)
      nil
      iex> ExShards.get(:mytab, :b, 3)
      3
      iex> :mytab |> ExShards.set(c: 2, c: 3) |> ExShards.get(:c)
      [2, 3]
  """
  @callback get(tab, key, value, state) :: value | [value]

  @doc """
  Gets the value from `key` and updates it, all in one pass.

  `fun` is called with the current value under `key` in `tab` (or `nil`
  if `key` is not present in `tab`) and must return a two-element tuple:
  the "get" value (the retrieved value, which can be operated on before
  being returned) and the new value to be stored under `key`. `fun` may
  also return `:pop`, which means the current value shall be removed
  from `tab` and returned (making this function behave like
  `pop(tab, key)`.

  The returned value is a tuple with the "get" value returned by
  `fun` and a new map with the updated value under `key`.

  ## Examples

      iex> :mytab |> ExShards.put(:a, 1) |> ExShards.get(:a)
      1

      iex> ExShards.get_and_update(:mytab, :a, fn current_value ->
      ...>   {current_value, "new value!"}
      ...> end)
      {1, "new value!"}

      iex> ExShards.get_and_update(:mytab, :b, fn current_value ->
      ...>   {current_value, "new value!"}
      ...> end)
      {nil, "new value!"}

      iex> ExShards.get_and_update(:mytab, :a, fn _ -> :pop end)
      {"new value!", nil}

      iex> ExShards.get_and_update(:mytab, :b, fn _ -> :pop end)
      {nil, nil}
  """
  @callback get_and_update(tab, key, (value -> {get, update} | :pop), state) ::
            {get, update} when get: term, update: term

  @doc """
  Gets the value from `key` and updates it. Raises if there is no `key`.

  Behaves exactly like `get_and_update/3`, but raises a `KeyError` exception if
  `key` is not present in `map`.

  ## Examples

      iex> :mytab |> ExShards.put(:a, 1) |> ExShards.get(:a)
      1

      iex> ExShards.get_and_update(:mytab, :a, fn current_value ->
      ...>   {current_value, "new value!"}
      ...> end)
      {1, "new value!"}

      iex> ExShards.get_and_update(:mytab, :b, fn current_value ->
      ...>   {current_value, "new value!"}
      ...> end)
      ** (KeyError) key :b not found in: :mytab

      iex> ExShards.get_and_update(:mytab, :a, fn _ -> :pop end)
      {"new value!", nil}
  """
  @callback get_and_update!(tab, key, (value -> {get, update} | :pop), state) ::
            {get, update} | no_return when get: term, update: term

  @doc """
  Returns whether the given `key` exists in the given `tab`.

  ## Examples

      iex> ExShards.has_key?(:mytab, :a)
      true
      iex> ExShards.has_key?(:mytab, :b)
      false
  """
  @callback has_key?(tab, key, state) :: boolean

  @doc """
  Returns all keys from `tab`.

  ## Examples

      iex> ExShards.set(:mytab, a: 1, b: 2, c: 3)
      :mytab
      iex> ExShards.keys(:mytab)
      [:a, :b, :c]

  **WARNING:** This is an expensive operation, try DO NOT USE IT IN PROD.
  """
  @callback keys(tab, state) :: [key]

  @doc """
  Returns and removes the value(s) associated with `key` in `tab`.

  Return possibilities:

    * `{tab, value}` – If `key` is present in `tab` with value `value`.
    * `{tab, [value]}` – In case of multiple matches with the key `key`.
      This behaviour is expected when the table is either a `:bag` or
      a `:duplicate_bag`.
    * `{tab, default}` – If `key` is not present in `tab`.

  ## Examples

      iex> :mytab |> ExShards.set(a: 1, b: 2, a: 2) |> ExShards.pop(:a)
      [1, 2]
      iex> ExShards.pop(:mytab, :b)
      2
      iex> ExShards.pop(:mytab, :c)
      nil
      iex> ExShards.pop(:mytab, :c, 3)
      3
  """
  @callback pop(tab, key, value, state) :: value | [value]

  @doc """
  Puts the given `value` under `key` in `tab`.

  ## Examples

      iex> :mytab |> ExShards.put(:a, 1) |> ExShards.fetch!(:a)
      1
      iex> :mytab |> ExShards.put(:a, 3) |> ExShards.fetch!(:a)
      3
  """
  @callback put(tab, key, value, state) :: tab

  @doc """
  Puts the given `value` under `key` unless the entry `key`
  already exists in `tab`.

  ## Examples

      iex> ExShards.put_new(:mytab, :a, 1) |> ExShards.fetch!(:a)
      1
      iex> ExShards.put_new(:mytab, :a, 3) |> ExShards.fetch!(:a)
      1
  """
  @callback put_new(tab, key, value, state) :: tab

  @doc """
  Removes the entry in `tab` for a specific `key`.

  If the `key` does not exist, returns `tab` unchanged.

  ## Examples

      iex> :mytab |> ExShards.put(:a, 1) |> ExShards.fetch!(:a)
      1
      iex> ExShards.delete(:mytab, :a) |> ExShards.get(:a)
      nil
      iex> ExShards.delete(:mytab, :b) |> ExShards.get(:b)
      nil
  """
  @callback remove(tab, key, state) :: tab

  @doc """
  This function is analogous to `:shards.insert/2,3`, but it returns
  the table name instead of `true`.

  ## Examples

      iex> :mytab |> ExShards.set(a:1, b: 2) |> ExShards.get(:a)
      1
      iex> :mytab |> ExShards.set(b: 3) |> ExShards.get(:b)
      3
  """
  @callback set(tab, tuple | [tuple], state) :: tab

  @doc """
  Drops the given `keys` from `tab` and returns a map with all dropped
  key-value pairs.

  If `keys` contains keys that are not in `tab`, they're simply ignored.

  ## Examples

      iex> ExShards.set(:mytab, a: 1, b: 2, a: 3, c: 4)
      iex> ExShards.take_and_drop(:mytab, [:a, :b, :e])
      %{a: [1, 3], b: 2}
      iex> ExShards.get(:mytab, :a)
      nil
  """
  @callback take_and_drop(tab, Enumerable.t, state) :: map

  @doc """
  Updates the `key` in `tab` with the given function.

  If `key` is present in `tab` with value `value`, `fun` is invoked with
  argument `value` and its result is used as the new value of `key`.
  If `key` is not present in `tab`, `initial` is inserted as the value
  of `key`.

  This functions only works for `:set` or `:ordered_set` tables.

  ## Examples

      iex> :mytab |> ExShards.put(:a, 1) |> ExShards.update(:a, 13, &(&1 * 2)) |> ExShards.get(:a)
      2
      iex> :mytab |> ExShards.update(:b, 11, &(&1 * 2)) |> ExShards.get(:b)
      11
  """
  @callback update(tab, key, value, (value -> value), state) :: tab

  @doc """
  Updates `key` with the given function.

  If `key` is present in `tab` with value `value`, `fun` is invoked with
  argument `value` and its result is used as the new value of `key`.
  If `key` is not present in `tab`, a `KeyError` exception is raised.

  This functions only works for `:set` or `:ordered_set` tables.

  ## Examples

      iex> :mytab |> ExShards.put(:a, 1) |> ExShards.update!(:a, &(&1 * 2)) |> ExShards.get(:a)
      2
      iex> :mytab |> ExShards.update(:b, &(&1 * 2))
      ** (KeyError) key :b not found in: :mytab
  """
  @callback update!(tab, key, (value -> value), state) :: tab | no_return

  @doc """
  This function is analogous to `:shards.update_element/3,4`, but it returns
  the table name instead of `true`.

  This functions only works for `:set` or `:ordered_set` tables.

  ## Examples

      iex> :mytab |> ExShards.put(:a, 1) |> ExShards.update_elem(:a, {2, 11}) |> ExShards.get(:a)
      11
      iex> :mytab |> ExShards.update_elem(:b, {2, 22}) |> ExShards.get(:b)
      nil
  """
  @callback update_elem(tab, key, term, state) :: tab

  @doc """
  Returns all values from `tab`.

  ## Examples

      iex> ExShards.set(:mytab, a: 1, b: 2, c: 3)
      :mytab
      iex> ExShards.values(:mytab)
      [:a, :b, :c]

  **WARNING:** This is an expensive operation, try DO NOT USE IT IN PROD.
  """
  @callback values(tab, state) :: [value]
end
