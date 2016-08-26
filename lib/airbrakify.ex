defmodule Airbrakify do
  alias Airbrakify.AirbrakeServer

  def notify(%{type: _type, message: _message}=message) do
    do_notification(message)
  end

  def notify(message) when is_binary(message) do
    do_notification(%{type: "Custom", message: message})
  end

  def notify(message) do
    do_notification(%{type: "Custom", message: inspect(message)})
  end

  defp do_notification(message) do
    AirbrakeServer.start
    AirbrakeServer.notify(message)
  end
end
