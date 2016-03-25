defmodule Airbrakify.ErrorPlug do
  defmacro __using__(_env) do
    quote do
      import Airbrakify.ErrorPlug
      alias Airbrakify.AirbrakeServer
      use Plug.ErrorHandler

      defp handle_errors(conn, error_trace) do
        AirbrakeServer.start
        AirbrakeServer.notify(conn, error_trace)
      end
    end
  end
end
