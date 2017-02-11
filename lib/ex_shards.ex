defmodule ExShards do
  @moduledoc """
  ETS/Shards API.

  Links:
    * [Shards](https://github.com/cabol/shards)
  """

  use ExShards.API

  defapi :shards, exclude_all: [:start, :stop]
end
