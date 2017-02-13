defmodule ExShards.Construct do
  @moduledoc """
  This is an utility module, which provides a set of macros to
  inject functions from Erlang modules.
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

  @doc """
  Injects exported functions from an Erlang module.

  By default, it injects all functions from the given module:

      inject :lists

  Alternatively, it allows you to pass pairs of name/arities to `:except`
  as a fine grained control on what to inject (or not):

      inject :lists, except: [append: 1]

  Besides, it allows you to pass only the name of the fuction(s) to `:except`,
  in order to exclude all function that matches with that name – no matter
  the arity. E.g.:

      inject :lists, except: [:append]

  This will exclude either `:lists.append/1` and `:lists.append/2`.

  ## Example

      defmodule Utils do
        use ExShards.Construct

        # injects all exported functions in module `:lists`
        inject :lists

        # injects all exported functions in module `:maps` except:
        # `:maps.get/2`, `:maps.get/3` and `:maps.find/2`.
        inject :maps, except: [:get, find: 2]
      end
  """
  defmacro inject(mod, opts \\ []) do
    # build public function list
    public_defs = opts
    |> Keyword.get(:except, [])
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
