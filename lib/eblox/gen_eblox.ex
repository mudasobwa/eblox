defmodule Eblox.GenEblox do
  @moduledoc false

  use GenServer
  require Logger

  @content "content"

  @cache Path.join @content, ".eblox"
  @collections Path.join @cache, "collections"

  # FIXME FIXME FIXME CACHE CACHE CACHE
  @everything Path.join @collections, "everything"

  ##############################################################################
  ### GenStage stuff
  ##############################################################################

  ## Callbacks

  @doc false
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc false
  def init(state), do: {:ok, eblox_init!(state)}

  def reset, do:  GenServer.cast(__MODULE__, :reset)

  def get(key \\ nil),
    do:  GenServer.call(__MODULE__, {:get, key})

  ##############################################################################

  ## Server Callbacks

  @doc false
  def handle_cast(:reset, _state), do: {:noreply, eblox_init!()}

  @doc false
  def handle_call({:get, key}, _from, state) do
    {:reply, prev_this_next(state[:everything], key), state}
  end

  ##############################################################################

  ## Helpers (initialize)

  defp eblox_init!(initial \\ []) do
    File.mkdir_p!(@cache)

    initial
    |> Keyword.merge([everything: everything()])
  end

  defp everything do
    @content
    |> File.cd!(&File.ls!/0)
    |> Enum.sort
    |> :lists.reverse
  end

  # FIXME CACHE!!!
  defp prev_this_next(list, key, acc \\ nil)
  defp prev_this_next([], _key, _acc), do: nil
  defp prev_this_next([h | _] = list, nil, _acc), do: prev_this_next(list, h)
  defp prev_this_next([h | t], key, acc) do
    case h do
      ^key ->
        next = case t do
                 [] -> nil
                 [th | _] -> th
               end
        [prev: acc, this: key, next: next, path: Path.join(@content, key)]
      prev -> prev_this_next(t, key, prev)
    end
  end

  ## Helpers (read cache)

  # defp collections do
  #   File.mkdir_p!(@collections)

  #   @collections
  #   |> File.cd!(fn ->
  #     File.ls!
  #     |> Enum.map(fn name ->
  #       {name,  name |> File.read! |> String.split("\n")}
  #     end)
  #   end)
  # end
end
