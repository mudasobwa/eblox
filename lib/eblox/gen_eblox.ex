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
  def static_pages, do: GenServer.call(__MODULE__, :static_pages)

  def get(key \\ nil, type \\ :collection), do:  GenServer.call(__MODULE__, {:get, key, type})

  def content_dir, do: @content

  ##############################################################################

  ## Server Callbacks

  @doc false
  def handle_cast(:reset, _state), do: {:noreply, eblox_init!()}

  @doc """
  Returns map `%{file => %Eblox.Content{}}`
  """
  def handle_call(:collection, _from, state), do: {:reply, state[:collection], state}
  def handle_call(:static_pages, _from, state), do: {:reply, state[:static_pages], state}

  @doc false
  def handle_call({:get, key, type}, _from, state) do
    case content(type, state[type], key) do
      {:new, normalized_key, data} ->
        collection = %{state[type] | normalized_key => data}
        state = Keyword.update!(state, type, fn _ -> collection end)
        {:reply, data, state}
      {:existing, _, data} ->
        {:reply, data, state}
    end
  end

  ##############################################################################

  ## Helpers (initialize)

  defp eblox_init!(initial \\ []) do
    File.mkdir_p!(@cache_dir)

    Keyword.merge(initial, [
      collection: collection_init!(),
      static_pages: static_pages_init!()])
  end

  defp content_init!(filter) do
    @content
    |> File.cd!(&File.ls!/0)
    |> List.delete(@cache)
    |> List.delete(@git)
    |> Enum.filter(filter)
    |> Enum.reduce(%{}, &Map.put(&2, &1, nil))
  end

  defp collection_init! do
    content_init!(fn file ->
      case Eblox.Content.to_date_number(file) do
        {nil, nil} -> false
        _ -> true
      end
    end)
  end

  defp static_pages_init! do
    content_init!(fn file ->
      case Eblox.Content.to_date_number(file) do
        {nil, nil} -> true
        _ -> false
      end
    end)
  end

  defp normalize(key) do
    key # FIXME
  end

  defp sorted_keys(map, mapper) do
    map
    |> Map.keys()
    |> Enum.sort_by(mapper, fn {d1, n1}, {d2, n2} ->
          case Date.compare(d1, d2) do
            :lt -> false
            :gt -> true
            _   -> n1 > n2
          end
    end)
  end

  @type_to_mapper [
    collection:   &Eblox.Content.to_date_number/1,
    static_pages: &Eblox.Content.to_number_text/1
  ]
  defp content(type, map, nil),
    do: content(type, map, map |> sorted_keys(@type_to_mapper[type]) |> List.first())
  defp content(type, map, key) do
    with key <- normalize(key), nil <- map[key] do
      {:new, key, Eblox.Content.new(key, sorted_keys(map, @type_to_mapper[type]))}
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
