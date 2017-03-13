defmodule Eblox.GenEblox do
  @moduledoc false

  use GenServer
  require Logger

  @content "content"

  @git ".git"
  # @git_dir Path.join @content, @git
  @cache ".eblox"
  @cache_dir Path.join @content, @cache

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

  def collection, do: GenServer.call(__MODULE__, :collection)

  def get(key \\ nil), do:  GenServer.call(__MODULE__, {:get, key})

  def content_dir, do: @content

  ##############################################################################

  ## Server Callbacks

  @doc false
  def handle_cast(:reset, _state), do: {:noreply, eblox_init!()}

  @doc """
  Returns map `%{file => %Eblox.Content{}}`
  """
  def handle_call(:collection, _from, state), do: {:reply, state[:collection], state}

  @doc false
  def handle_call({:get, key}, _from, state) do
    case content(state[:collection], key) do
      {:new, normalized_key, data} ->
        collection = %{state[:collection] | normalized_key => data}
        state = Keyword.update!(state, :collection, fn _ -> collection end)
        {:reply, data, state}
      {:existing, _, data} ->
        {:reply, data, state}
    end
  end

  ##############################################################################

  ## Helpers (initialize)

  defp eblox_init!(initial \\ []) do
    File.mkdir_p!(@cache_dir)

    initial
    |> Keyword.merge([collection: collection_init!()])
  end

  defp collection_init! do
    @content
    |> File.cd!(&File.ls!/0)
    |> Enum.reduce(%{}, &Map.put(&2, &1, nil))
    |> Map.delete(@cache)
    |> Map.delete(@git)
#    |> Enum.sort(fn {k1, _}, {k2, _} -> k2 <= k1 end)
#    |> Enum.into(%{})
  end

  # FIXME CACHE!!!

  defp normalize(key) do
    key # FIXME
  end

  defp sorted_keys(map) do
    map
    |> Map.keys()
    |> Enum.sort_by(&Eblox.Content.to_date_number/1, fn {d1, n1}, {d2, n2} ->
          case Date.compare(d1, d2) do
            :lt -> false
            :gt -> true
            _   -> n1 > n2
          end
    end)
  end
  defp content(map, nil), do: content(map, map |> sorted_keys() |> List.first())
  defp content(map, key) do
    with key <- normalize(key), nil <- map[key] do
      {:new, key, Eblox.Content.new(key, sorted_keys(map))}
    else
      data -> {:existing, key, data}
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
