defmodule AirbrakeServerTest do
  use ExUnit.Case
  alias Airbrakify.AirbrakeServer

  setup do
    server = AirbrakeServer.start
    fake_conn = %{
      params:  %{"param1" => "foo", "param2" => "bar"},
      private: %{
        plug_session: %{"key" => "value"}
      }
    }
    reason = %TestError{data: "Some Garbage"}
    stacktrace = [
      {:module, :function, 1, [file: "lib/file.ex", line: 102]},
      {:module, :other_function, 2, [file: "lib/other_file.ex", line: 256]},
    ]
    fake_trace = %{kind: nil, reason: reason, stack: stacktrace}
    {:ok, server: server, conn: fake_conn, trace: fake_trace}
  end

  test "init returns :ok" do
    assert {:ok, _} = AirbrakeServer.init(nil)
  end

  test "server is started", %{server: server} do
    assert server
  end

  test "handle_info responds with noreply" do
    assert {:noreply, _} = AirbrakeServer.handle_info(:foo, :bar)
  end

  test "handle_cast responds with noreply", %{conn: conn, trace: trace} do
    assert :ok = AirbrakeServer.notify(conn, trace)
  end

  # def init(_) do
  #   {:ok, nil}
  # end
  #
  # def start do
  #   Application.ensure_all_started(:airbrakify)
  #   GenServer.start(__MODULE__, nil, name: :airbrakify)
  # end
  #
  # def notify(conn, stacktrace) do
  #   GenServer.cast(:airbrakify, {:notify, conn, stacktrace})
  # end
  #
  # def handle_cast({:notify, conn, stacktrace}, _) do
  #   {:noreply, AirbrakeHandler.notify(conn, stacktrace)}
  # end
  #
  # def handle_info(_, state), do: {:noreply, state}
end
