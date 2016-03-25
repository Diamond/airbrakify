# Airbrakify

**Aibrakify** is the beginning of an Airbrake/Errbit library for Elixir/Phoenix projects. Right now, it's aimed as a Phoenix Plug to help you catch exceptions and report them to Errbit appropriately.

This library currently has been tested and works with Errbit v0.5.0 and v0.6.0.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add airbrakify to your list of dependencies in `mix.exs`:

        def deps do
          [{:airbrakify, "~> 0.0.1"}]
        end

  2. Ensure airbrakify is started before your application:

        def application do
          [applications: [:airbrakify]]
        end
