defmodule Eblox.Content.Nav do
  @moduledoc false

  @typedoc """
  Navigation as by web page navigation.
  """
  @type t :: %__MODULE__{this: String.t, prev: String.t, next: String.t}
  @fields [this: "", prev: nil, next: nil]
  def fields, do: @fields
  defstruct @fields

  @spec new(List.t, String.t, String.t) :: Eblox.Content.Nav.t
  def new(list, key, next \\ nil)
  def new([], _key, _next), do: nil
  def new([key], key, _next), do: nil
  def new([h | _] = list, nil, _next), do: new(list, h)
  def new([key | [prev | _]], key, next) do
    %Eblox.Content.Nav{prev: prev, this: key, next: next}
  end
  def new([next | t], key, _next), do: new(t, key, next)
end

defmodule Eblox.Content do
  @moduledoc false

  @typedoc """
  Content is the whole lazily cached content of the blog.
  """
  @type t :: %__MODULE__{
    type: Atom.t,
    timestamp: Date.t,
    raw: String.t,
    ast: tuple,
    html: String.t,
    meta: List.t,
    nav: Nav.t}

  @fields [type: :unknown, timestamp: Date.utc_today(), raw: nil, ast: {}, html: nil, meta: [], nav: %Eblox.Content.Nav{}]
  def fields, do: @fields
  defstruct @fields

  require Logger

  @spec new(String.t, List.t) :: Eblox.Content.t
  def new(file, list) do
    with {timestamp, _} <- to_date_number(file),
         raw <- File.read!(Path.join(Eblox.GenEblox.content_dir, file)),
         {ast, collected} <- Markright.to_ast(raw, Eblox.Markright.Collector),
         ast <- fuererize(ast, collected[Markright.Collectors.Fuerer]),
         html <- XmlBuilder.generate(ast) do
      %Eblox.Content{
        type: collected[Markright.Collectors.Type],
        raw: raw,
        timestamp: timestamp,
        ast: ast,
        html: html,
        meta: collected,
        nav: Eblox.Content.Nav.new(list, file)}
    else
      _ -> nil
    end
  end

  @spec fuererize({:article, Map.t, List.t}, Keyword.t) :: {:article, Map.t, List.t}
  defp fuererize({:article, %{}, [{:p, %{}, title} | rest]}, {:h2, %{}, title}),
    do: {:article, %{}, [{:h2, %{}, title} | rest]}
  defp fuererize(ast, _), do: ast

  @spec to_date_number(String.t) :: {Date.t, Integer.t}
  @doc """
  Converts any arbitrary file name to a tuple `{Date.t, Integer.t}`.
  Used for sorting the entries as well as for extracting the date from the url.

  ## Examples

      iex> Eblox.Content.to_date_number("2016-9-1")
      {~D[2016-09-01], 1}
      iex> Eblox.Content.to_date_number("2016-9-1-1")
      {~D[2016-09-01], 1}
      iex> Eblox.Content.to_date_number("2016-9-1-2")
      {~D[2016-09-01], 2}
      iex> Eblox.Content.to_date_number("hello-world-2016-9-1-1")
      {~D[2016-09-01], 1}
      iex> Eblox.Content.to_date_number("2016-9-1-1-hello-789-world")
      {~D[2016-09-01], 1}

      iex> input = ~w|2016-9-9-1 2016-9-1-2 2016-9-1-1 2016-10-9-1 2016-1-1-1 2015-9-1-1|
      ...> Enum.map(input, &Eblox.Content.to_date_number/1)
      [{~D[2016-09-09], 1}, {~D[2016-09-01], 2}, {~D[2016-09-01], 1},
       {~D[2016-10-09], 1}, {~D[2016-01-01], 1}, {~D[2015-09-01], 1}]
      iex> Enum.sort_by(input, &Eblox.Content.to_date_number/1, fn {d1, n1}, {d2, n2} ->
      ...>   case Date.compare(d1, d2) do
      ...>     :lt -> false
      ...>     :gt -> true
      ...>     _   -> n1 > n2
      ...>   end
      ...> end)
      ["2016-10-9-1", "2016-9-9-1", "2016-9-1-2", "2016-9-1-1", "2016-1-1-1", "2015-9-1-1"]


  """
  # def to_date_number({file, _}), do: to_date_number(file) # helper for sorting map in GenEblox
  def to_date_number(file) when is_binary(file) do
    case Regex.scan(~r/(\d{4})\D(\d{1,2})\D(\d{1,2})(?:\D(\d{1,}))?/, file, capture: :all_but_first) do
      [] ->
        # not a date
        {nil, nil}
      [[_, _, _] = ymd] ->
        {:ok, timestamp} = ymd
                           |> Enum.map(&String.to_integer/1)
                           |> List.to_tuple()
                           |> Date.from_erl()
        {timestamp, 1}
      [[y, m, d, number]] ->
        {:ok, timestamp} = [y, m, d]
                           |> Enum.map(&String.to_integer/1)
                           |> List.to_tuple()
                           |> Date.from_erl()
        {timestamp, String.to_integer(number)}
    end
  end

  @spec to_number_text(String.t) :: {Integer.t, String.t}
  def to_number_text(file) when is_binary(file) do
    with [[num, text]] <- Regex.scan(~r/\A(\d*)(.*)\z/, file, capture: :all_but_first),
      do: {num, text}
  end
end
