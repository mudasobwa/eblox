defmodule Eblox.Content do

  defmodule Nav do
    @typedoc """
    Navigation as by web page navigation.
    """
    @type t :: %__MODULE__{this: String.t, prev: String.t, next: String.t}
    @fields [this: "", prev: nil, next: nil]
    def fields, do: @fields
    defstruct @fields
  end

  @typedoc """
  Content is the whole lazily cached content of the blog.
  """
  @type t :: %__MODULE__{
    type: Atom.t,
    raw: String.t,
    ast: tuple,
    html: String.t,
    meta: List.t,
    nav: Nav.t}

  @fields [type: :unknown, raw: nil, ast: {}, html: nil, meta: [], nav: %Nav{}]
  def fields, do: @fields
  defstruct @fields

  def produce(file) do

  end

  defp aliases(file) do
     
  end
end
