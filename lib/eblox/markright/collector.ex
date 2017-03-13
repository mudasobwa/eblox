defmodule Eblox.Markright.Collector do
  use Markright.Collector, collectors: [
    Markright.Collectors.OgpTwitter,
    Markright.Collectors.Type,
    Markright.Collectors.Tag]
end
