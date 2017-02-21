<img src="http://38.media.tumblr.com/db32471b7c8870cbb0b2cc173af283bb/tumblr_inline_nm9x9u6u261rw7ney_540.gif" height="170" width="100%" />


# ExShards [![Build Status](https://travis-ci.org/cabol/ex_shards.svg?branch=master)](https://travis-ci.org/cabol/ex_shards)

This is a wrapper on top of [ETS](http://erlang.org/doc/man/ets.html) and [Shards](https://github.com/cabol/shards).

[Shards](https://github.com/cabol/shards) is a simple library to scale-out ETS tables, which implements the same ETS API.
Taking advantage of this, what **ExShards** does is provides a wrapper to use either `ets` or
`shards` totally transparent.

Additionally, `ExShards` provides an extended API, with a fresh and fluent interface – more Elixir-friendly.
For more information, check out the [<i class="icon-upload"></i> Extended API](#extended-api) section.

## Installation and Usage

To start playing with `ex_shards` you just have to follow these simple steps:

  1. Add ex_shards to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [{:ex_shards, "~> 0.2"}]
  end
  ```

  2. Since `ex_shards` uses `shards`, make sure that `shards` is started before your application:

  ```elixir
  def application do
    [applications: [:shards]]
  end
  ```

## Build

    $ git clone https://github.com/cabol/ex_shards.git
    $ cd ex_shards
    $ mix deps.get && mix compile


## Getting Started!

Start an Elixir console:

    $ iex -S mix

Once into the Elixir console:

```elixir
# create a table with default options
iex> ExShards.new :mytab
:mytab

iex> ExShards.insert :mytab, [k1: 1, k2: 2, k3: 3]
true

iex> for k <- [:k1, :k2, :k3] do
       [{_, v}] = ExShards.lookup(:mytab, k)
       v
     end
[1, 2, 3]

# let's query all values using select
# we need to require Ex2ms to build match specs
iex> require Ex2ms
Ex2ms
iex> ms = Ex2ms.fun do {_, v} -> v end
[{{:_, :"$1"}, [], [:"$1"]}]
iex> ExShards.select :mytab, ms
[1, 2, 3]

iex> ExShards.delete :mytab, :k3
true
iex> ExShards.lookup :mytab, :k3
[]

# let's create another table
iex> ExShards.new :mytab2, [{:n_shards, 4}]
:mytab2

# start the observer so you can see how shards behaves
iex> :observer.start
:ok
```

As you might have noticed, it's extremely easy, such as you were using **ETS** API directly.


## Extended API

As you probably have noticed, most of the Elixir APIs are designed to be [Fluent](https://en.wikipedia.org/wiki/Fluent_interface),
they allow us to take advantage of the pipe operator, making the code more readable
and elegant of course.

Because `shards` implements the same `ets` API, most of the functions follows
the old-traditional Erlang-style, so it is not possible to pipe them. Here is
where the extended API comes in!

[ExShards.Ext](lib/ex_shards/ext.ex) is the module that implements the extended API,
and provides a fluent API with a set of nicer and fresh functions, based on the
`Elixir.Map` API. No more words, let's play a bit:

```elixir
iex> :t |> ExShards.new |> ExShards.set(a: 1, b: 2) |> ExShards.put(:c, 3) |> ExShards.update!(:a, &(&1 * 2))
:t

iex> for k <- [:a, :b, :c, :d], do: ExShards.get(:t, k)
[2, 2, 3, nil]

iex> :t |> ExShards.remove(:c) |> ExShards.fetch!(:c)
** (KeyError) key :c not found in: :t

iex> :t |> ExShards.drop([:a, :b, :x]) |> ExShards.put(:y, "new!") |> ExShards.keys
[:y]
```

`ExShards.Ext` is well documented, and you can find the documentation in the next links:

 * [ExShards.Ext](https://hexdocs.pm/ex_shards/ExShards.Ext.html)
 * [API Reference](https://hexdocs.pm/ex_shards/api-reference.html)

## Distributed ExShards

Let's see how **ExShards** works in distributed fashion.

**1.** Let's start 3 Elixir consoles running ExShards:

Node `a`:

```
$ iex --name a@127.0.0.1 -S mix
```

Node `b`:

```
$ iex --name b@127.0.0.1 -S mix
```

Node `c`:

```
$ iex --name c@127.0.0.1 -S mix
```

**2.** Create a table with global scope (`scope: :g`) on each node and then join them.

```elixir
iex> ExShards.new :mytab, scope: :g, nodes: [:b@127.0.0.1, :c@127.0.0.1]
:mytab

iex> ExShards.get_nodes :mytab
[:a@127.0.0.1, :b@127.0.0.1, :c@127.0.0.1]
```

**3.** Now **ExShards** cluster is ready, let's do some basic operations:

From node `a`:

```elixir
iex> ExShards.insert :mytab, k1: 1, k2: 2
true
```

From node `b`:

```elixir
iex> ExShards.insert :mytab, k3: 3, k4: 4
true
```

From node `c`:

```elixir
iex> ExShards.insert :mytab, k5: 5, k6: 6
true
```

Now, from any of previous nodes:

```elixir
iex> for k <- [:k1, :k2, :k3, :k4, :k5, :k6] do
       [{_, v}] = ExShards.lookup(:mytab, k)
       v
     end
[1, 2, 3, 4, 5, 6]
```

All nodes should return the same result.

Let's do some deletions, from any node:

```elixir
iex> ExShards.delete :mytab, :k6
true
```

From any node:

```elixir
iex> ExShards.lookup :mytab, :k6
[]
```

Let's check again all:

```elixir
iex> for k <- [:k1, :k2, :k3, :k4, :k5] do
       [{_, v}] = ExShards.lookup(:mytab, k)
       v
     end
[1, 2, 3, 4, 5]
```


## References

 * [ExShards API Reference](https://hexdocs.pm/ex_shards/api-reference.html): ExShards Docs.
 * [Shards](https://github.com/cabol/shards): Original Erlang project.
 * [Shards API Reference](http://cabol.github.io/shards): Shards API Reference.
 * [Blog Post about Shards](http://cabol.github.io/posts/2016/04/14/sharding-support-for-ets.html).


## Copyright and License

Copyright (c) 2016 Carlos Andres Bolaños R.A.

**ExShards** source code is licensed under the [MIT License](LICENSE.md).
