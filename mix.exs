defmodule Eblox.Mixfile do
  use Mix.Project

  def project do
    [app: :eblox,
     version: "0.0.3",
     elixir: "~> 1.3",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Eblox, []},
     applications: ~w|phoenix phoenix_pubsub phoenix_html cowboy logger gettext flowex|a]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.3.0"},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_html, "~> 2.6"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:gettext, "~> 0.11"},
     {:cowboy, "~> 1.0"},

     {:edeliver, "~> 1.4.0"},
     {:distillery, "~> 1.0"},

     {:xml_builder, "~> 0.1"},
     {:markright, "~> 0.5"},
     {:flowex, "~> 0.5"},

     # {:ex_debug_toolbar, "~> 0.3"},

     {:credo, "~> 0.8", only: :dev},
     {:ex_doc, "~> 0.11", only: :dev},
   ]
  end
end
