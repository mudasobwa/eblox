defmodule Eblox.Markright.Collector do
  use Markright.Collector, collectors: [
    Markright.Collectors.OgpTwitter,
    Markright.Collectors.Tag]
end
