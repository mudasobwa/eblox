defmodule Eblox.Markright.Collector do
  @moduledoc false
  use Markright.Collector, collectors: [
    Markright.Collectors.Fuerer,
    Markright.Collectors.OgpTwitter,
    Markright.Collectors.Type,
    Markright.Collectors.Tag]
end
