defmodule Eblox.Content.Nav do
  @typedoc """
  Navigation as by web page navigation.
  """
  @type t :: %__MODULE__{this: String.t, prev: String.t, next: String.t}
  @fields [this: "", prev: nil, next: nil]
  def fields, do: @fields
  defstruct @fields

  def new(list, key, acc \\ nil)
  def new([], _key, _acc), do: nil
  def new([h | _] = list, nil, _acc), do: new(list, h)
  def new([h | t], key, acc) do
    case h do
      ^key ->
        next = case t do
                 [] -> nil
                 [th | _] -> th
               end
        %Eblox.Content.Nav{prev: acc, this: key, next: next}
      prev -> new(t, key, prev)
    end
  end
end

defmodule Eblox.Content do
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

  def new(file, list) do
    with {timestamp, _} <- to_date_number(file),
         raw <- File.read!(Path.join(Eblox.GenEblox.content_dir, file)),
         {ast, collected} <- Markright.to_ast(raw, Eblox.Markright.Collector),
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
  def to_date_number(file) do
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
end
