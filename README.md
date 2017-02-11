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
    [{:shards, "~> 0.3.0"}]
  end
  ```

  2. Because `ex_shards` uses `shards`, make sure that `shards` is started before your application:

  ```elixir
  def application do
    [applications: [:shards]]
  end
  ```

## Build

    $ git clone https://github.com/cabol/ex_shards.git
    $ cd shards
    $ mix deps.get && mix compile


## Getting Started!

Start an Elixir console:

    $ iex -S mix

Once into the Elixir console:

```elixir
> require ExShards
nil

# create a table with default options
> ExShards.new :mytab, []
{:mytab,
 {:state, :shards_local, 8, &:shards_local.pick/3, &:shards_local.pick/3}}

> ExShards.insert :mytab, [k1: 1, k2: 2, k3: 3]
true

> for k <- [:k1, :k2, :k3] do        
  [{_, v}] = ExShards.lookup(:mytab, k)
  v
end
[1, 2, 3]

> ExShards.delete :mytab, :k3
true
> ExShards.lookup :mytab, :k3
[]

# let's create another table
> ExShards.new :mytab2, [{:n_shards, 5}]
{:mytab2,
 {:state, :shards_local, 5, &:shards_local.pick/3, &:shards_local.pick/3}}

# start the observer so you can see how shards looks like
> :observer.start
:ok
```

As you might have noticed, it's extremely easy, such as you were using **ETS** API directly.

By default, all **ExShards** functions are mapped to use **Shards** module, but if you want to use
**ETS** instead, you only have to do a little change in the config:

```elixir
config :ex_shards,
  adapter: :ets
```

Previous config, changes the adapter/module to use, from `shards` to `ets`.

For more information about `shards` you can go to these links:

 * [shards](https://github.com/cabol/shards): Original Erlang project.
 * [Blog Post about Shards](http://cabol.github.io/posts/2016/04/14/sharding-support-for-ets.html).


## Copyright and License

Copyright (c) 2016 Carlos Andres Bolaños R.A.

**ExShards** source code is licensed under the [MIT License](LICENSE.md).
