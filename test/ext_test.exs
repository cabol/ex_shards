defmodule ExShards.API.ExtTest do
  use ExUnit.Case

  @modules [{ExShards, []}, {ExShards.Local, []}]

  test "fetch" do
    for {mod, args} <- @modules do
      :t |> mod.new(args) |> mod.set(a: 1, b: 2)
      assert mod.fetch(:t, :a) == {:ok, 1}
      assert mod.fetch(:t, :b) == {:ok, 2}
      assert mod.fetch(:t, :c) == :error
      assert mod.delete(:t)
    end
  end

  test "fetch!" do
    for {mod, args} <- @modules do
      :t |> mod.new(args) |> mod.set(a: 1, b: 2)
      assert mod.fetch!(:t, :a) == 1
      assert mod.fetch!(:t, :b) == 2
      assert_raise KeyError, fn ->
        mod.fetch!(:t, :c)
      end
      assert mod.delete(:t)
    end
  end

  test "get" do
    for {mod, args} <- @modules do
      :t |> mod.new(args) |> mod.set(a: 1, b: 2)
      assert mod.get(:t, :a) == 1
      assert mod.get(:t, :b) == 2
      assert mod.get(:t, :c) == nil
      assert mod.get(:t, :c, 3) == 3
      assert mod.delete(:t)
    end
  end

  test "get with duplicate bag" do
    for {mod, args} <- @modules do
      :t |> mod.new([:duplicate_bag | args]) |> mod.set(a: 1, b: 2, a: 2, a: 1, b: 3, x: 1)
      assert mod.get(:t, :a) |> :lists.sort == [1, 1, 2]
      assert mod.get(:t, :b) |> :lists.sort == [2, 3]
      assert mod.get(:t, :c) == nil
      assert mod.get(:t, :c, 3) == 3
      assert mod.get(:t, :x) == 1
      assert mod.delete(:t)
    end
  end

  test "get_and_update" do
    for {mod, args} <- @modules do
      :t |> mod.new(args) |> mod.set(a: 1, b: 2)
      assert mod.get_and_update(:t, :a, fn v -> {v, 5} end) == {1, 5}
      assert mod.get_and_update(:t, :c, fn v -> {v, 6} end) == {nil, 6}
      assert mod.get_and_update(:t, :a, fn _ -> :pop end) == {5, nil}
      assert mod.get(:t, :a) == nil
      assert mod.get_and_update(:t, :a, fn _ -> :pop end) == {nil, nil}
      assert mod.delete(:t)
    end
  end

  test "get_and_update!" do
    for {mod, args} <- @modules do
      :t |> mod.new(args) |> mod.set(a: 1, b: 2)
      assert mod.get_and_update!(:t, :a, fn v -> {v, 5} end) == {1, 5}
      assert_raise KeyError, fn ->
        mod.get_and_update!(:t, :c, fn v -> {v, 6} end)
      end
      assert mod.get_and_update!(:t, :a, fn _ -> :pop end) == {5, nil}
      assert mod.get(:t, :a) == nil
      assert_raise KeyError, fn ->
        mod.get_and_update!(:t, :a, fn _ -> :pop end)
      end
      assert mod.delete(:t)
    end
  end

  test "has_key?" do
    for {mod, args} <- @modules do
      :t |> mod.new(args) |> mod.set(a: 1, b: 2)
      assert mod.has_key?(:t, :a)
      assert mod.has_key?(:t, :b)
      refute mod.has_key?(:t, :c)
      assert mod.delete(:t)
    end
  end

  test "keys" do
    for {mod, args} <- @modules do
      :t |> mod.new(args) |> mod.set(a: 1, b: 2, c: 3)
      assert mod.keys(:t) == [:a, :b, :c]
      assert mod.delete(:t)
    end
  end

  test "pop" do
    for {mod, args} <- @modules do
      :t |> mod.new(args) |> mod.set(a: 1, b: 2)
      assert mod.pop(:t, :a) == 1
      assert mod.get(:t, :a) == nil
      assert mod.pop(:t, :b) == 2
      assert mod.get(:t, :b) == nil
      assert mod.pop(:t, :c) == nil
      assert mod.pop(:t, :c, 3) == 3
      assert mod.delete(:t)
    end
  end

  test "pop with duplicate bag" do
    for {mod, args} <- @modules do
      :t |> mod.new([:duplicate_bag | args]) |> mod.set(a: 1, b: 2, a: 2)
      assert mod.pop(:t, :a) == [1, 2]
      assert mod.get(:t, :a) == nil
      assert mod.pop(:t, :b) == 2
      assert mod.get(:t, :b) == nil
      assert mod.pop(:t, :c) == nil
      assert mod.pop(:t, :c, 3) == 3
      assert mod.delete(:t)
    end
  end

  test "put" do
    for {mod, args} <- @modules do
      :t |> mod.new(args)
      assert mod.put(:t, :a, 1) |> mod.fetch!(:a) == 1
      assert mod.put(:t, :a, 3) |> mod.fetch!(:a) == 3
      assert mod.delete(:t)
    end
  end

  test "put_new" do
    for {mod, args} <- @modules do
      :t |> mod.new(args)
      assert mod.put_new(:t, :a, 1) |> mod.fetch!(:a) == 1
      assert mod.put_new(:t, :a, 3) |> mod.fetch!(:a) == 1
      assert mod.delete(:t)
    end
  end

  test "remove" do
    for {mod, args} <- @modules do
      :t |> mod.new(args) |> mod.set(a: 1, b: 2)
      assert mod.remove(:t, :a) |> mod.get(:a) == nil
      assert mod.remove(:t, :b) |> mod.get(:b) == nil
      assert mod.remove(:t, :c) |> mod.get(:c) == nil
      assert mod.delete(:t)
    end
  end

  test "set" do
    for {mod, args} <- @modules do
      :t |> mod.new(args) |> mod.set(a: 1, b: 2)
      assert mod.get(:t, :a) == 1
      assert mod.get(:t, :b) == 2
      assert mod.get(:t, :c) == nil
      assert mod.set(:t, a: 11) |> mod.get(:a) == 11
      assert mod.delete(:t)
    end
  end

  test "drop" do
    for {mod, args} <- @modules do
      :t |> mod.new(args) |> mod.set(a: 1, b: 2, c: 3)
      assert mod.drop(:t, [:a, :b, :d]) == %{a: 1, b: 2}
      assert mod.get(:t, :a) == nil
      assert mod.get(:t, :b) == nil
      assert mod.get(:t, :c) == 3
      assert mod.drop(:t, [:c]) == %{c: 3}
      assert mod.get(:t, :c) == nil
      assert mod.drop(:t, [:d]) == %{}
      assert mod.delete(:t)
    end
  end

  test "drop with duplicate bag" do
    for {mod, args} <- @modules do
      :t |> mod.new([:duplicate_bag | args]) |> mod.set(a: 1, b: 2, c: 3, a: 2)
      assert mod.drop(:t, [:a, :b, :d]) == %{a: [1, 2], b: 2}
      assert mod.get(:t, :a) == nil
      assert mod.get(:t, :b) == nil
      assert mod.get(:t, :c) == 3
      assert mod.drop(:t, [:c]) == %{c: 3}
      assert mod.get(:t, :c) == nil
      assert mod.drop(:t, [:d]) == %{}
      assert mod.delete(:t)
    end
  end

  test "update" do
    for {mod, args} <- @modules do
      :t |> mod.new(args) |> mod.set(a: 1)
      assert mod.update(:t, :a, 13, &(&1 * 2)) |> mod.get(:a) == 2
      assert mod.update(:t, :b, 11, &(&1 * 2)) |> mod.get(:b) == 11
      assert mod.delete(:t)
    end
  end

  test "update!" do
    for {mod, args} <- @modules do
      :t |> mod.new(args) |> mod.set(a: 1)
      assert mod.update!(:t, :a, &(&1 * 2)) |> mod.get(:a) == 2
      assert_raise KeyError, fn ->
        mod.update!(:t, :b, &(&1 * 2))
      end
      assert mod.delete(:t)
    end
  end

  test "update_elem" do
    for {mod, args} <- @modules do
      :t |> mod.new(args) |> mod.set(a: 1)
      assert mod.update_elem(:t, :a, {2, 11}) |> mod.get(:a) == 11
      assert mod.update_elem(:t, :b, {2, 22}) |> mod.get(:b) == nil
      assert mod.delete(:t)
    end
  end

  test "values" do
    for {mod, args} <- @modules do
      :t |> mod.new(args) |> mod.set(a: 1, b: 2, c: 3)
      assert mod.values(:t) == [1, 2, 3]
      assert mod.delete(:t)
    end
  end
end
