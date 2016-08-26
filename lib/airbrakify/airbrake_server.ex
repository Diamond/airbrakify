defmodule Airbrakify.AirbrakeServer do
  use GenServer
  alias Airbrakify.AirbrakeHandler

  def init(_) do
    {:ok, nil}
  end

  def start do
    Application.ensure_all_started(:airbrakify)
    GenServer.start(__MODULE__, nil, name: :airbrakify)
  end

  def notify(conn, stacktrace) do
    GenServer.cast(:airbrakify, {:notify, conn, stacktrace})
  end

  def notify(%{type: _type, message: _message}=notification) do
    GenServer.cast(:airbrakify, {:notify, notification})
  end

  def handle_cast({:notify, conn, stacktrace}, _) do
    {:noreply, AirbrakeHandler.notify(conn, stacktrace)}
  end

  def handle_cast({:notify, message}, _) do
    {:noreply, AirbrakeHandler.notify(message)}
  end

  def handle_info(_, state), do: {:noreply, state}
end
