defmodule {{SCHEMA_APP_NAME_CAMEL}}.MixProject do
  use Mix.Project

  def project do
    [
      app: :{{SCHEMA_APP_NAME}},
      version: "0.1.0",
      elixir: "~> 1.14",
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_json_schema, "~> 0.11"},
      {:jason, "~> 1.4"}
    ]
  end
end
