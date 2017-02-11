defmodule ExShards.API do
  @moduledoc """
  This module allows to generate API functions.
  """

  @doc false
  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)
      import unquote(__MODULE__)
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      @public_defs Module.definitions_in(__MODULE__, :def)

      def definitions, do: @public_defs
    end
  end

  @doc false
  defmacro defapi(mod, opts \\ []) do
    # build public function list
    public_defs = opts
    |> Keyword.get(:exclude, [])
    |> :lists.merge(Keyword.get(opts, :exclude_all, []))
    |> :lists.append([:module_info])
    |> Enum.reduce(mod.module_info(:exports), fn
      ({k, v}, acc) -> Keyword.delete(acc, k, v)
      (k, acc)      -> Keyword.delete(acc, k)
    end)

    # generate definitions
    for {fun, arity} <- public_defs do
      args = if arity > 0 do
        1..arity
        |> Enum.map(&(Module.concat(["arg#{&1}"])))
        |> Enum.map(fn(x) -> {x, [], __MODULE__} end)
      else
        []
      end
      quote do
        def unquote(fun)(unquote_splicing(args)) do
          unquote(mod).unquote(fun)(unquote_splicing(args))
        end
      end
    end
  end
end
