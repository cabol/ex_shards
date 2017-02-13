<img src="http://38.media.tumblr.com/db32471b7c8870cbb0b2cc173af283bb/tumblr_inline_nm9x9u6u261rw7ney_540.gif" height="170" width="100%" />


# ExShards

This is a wrapper on top of [ETS](http://erlang.org/doc/man/ets.html) and [Shards](https://github.com/cabol/shards).

[Shards](https://github.com/cabol/shards) is a simple library to scale-out ETS tables, which implements the same ETS API.
Taking advantage of this, what **ExShards** does is provides a wrapper to use either `ets` or
`shards` totally transparent.


## Installation and Usage

To start playing with `ex_shards` you just have to follow these simple steps:

  1. Add ex_shards to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [{:ex_shards, "~> 0.1"}]
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
> ExShards.new :mytab
:mytab

> ExShards.insert :mytab, [k1: 1, k2: 2, k3: 3]
true

> for k <- [:k1, :k2, :k3] do
[{_, v}] = ExShards.lookup(:mytab, k)
v
end
[1, 2, 3]

# let's query all values using select
# we need to require Ex2ms to build match specs
> require Ex2ms
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
```

As you might have noticed, it's extremely easy, such as you were using **ETS** API directly.


## Extended API



## Distributed ExShards

Let's see how **ExShards** works in distributed fashion.

**1.** Let's start 3 Elixir consoles running ExShards:

Node `a`:

```
$ iex --sname a@localhost -S mix
```

Node `b`:

```
$ iex --sname b@localhost -S mix
```

Node `c`:

```
$ iex --sname c@localhost -S mix
```

**2.** Create a table with global scope (`scope: :g`) on each node and then join them.

```elixir
> ExShards.new :mytab, scope: :g, nodes: [:b@localhost, :c@localhost]
:mytab

> ExShards.get_nodes :mytab
[:a@localhost, :b@localhost, :c@localhost]
```

**3.** Now **ExShards** cluster is ready, let's do some basic operations:

From node `a`:

```elixir
> ExShards.insert :mytab, k1: 1, k2: 2
true
```

From node `b`:

```elixir
> ExShards.insert :mytab, k3: 3, k4: 4
true
```

From node `c`:

```elixir
> ExShards.insert :mytab, k5: 5, k6: 6
true
```

Now, from any of previous nodes:

```elixir
> for k <- [:k1, :k2, :k3, :k4, :k5, :k6] do
[{_, v}] = ExShards.lookup(:mytab, k)
v
end
[1, 2, 3, 4, 5, 6]
```

All nodes should return the same result.

Let's do some deletions, from any node:

```elixir
> ExShards.delete :mytab, :k6
true
```

From any node:

```elixir
> ExShards.lookup :mytab, :k6
[]
```

Let's check again all:

```elixir
> for k <- [:k1, :k2, :k3, :k4, :k5] do
[{_, v}] = ExShards.lookup(:mytab, k)
v
end
[1, 2, 3, 4, 5]
```


## References

For more information about `shards` you can go to these links:

 * [shards](https://github.com/cabol/shards): Original Erlang project.
 * [API Reference](http://cabol.github.io/shards): Shards API Reference.
 * [Blog Post about Shards](http://cabol.github.io/posts/2016/04/14/sharding-support-for-ets.html).


## Copyright and License

Copyright (c) 2016 Carlos Andres Bolaños R.A.

**ExShards** source code is licensed under the [MIT License](LICENSE.md).
