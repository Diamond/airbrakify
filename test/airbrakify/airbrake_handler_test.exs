defmodule AirbrakifyHandlerTest do
  use ExUnit.Case
  alias Airbrakify.AirbrakeHandler
  alias Airbrakify.Parser

  @project_key "ABCDEF"
  @project_id  "DEADBEEF"
  @host        "localhost:3000"
  @api_version "v4"

  setup do
    Application.put_env(:airbrakify, :project_key, @project_key)
    Application.put_env(:airbrakify, :project_id,  @project_id)
    Application.put_env(:airbrakify, :host,        @host)
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
    {:ok, conn: fake_conn, trace: fake_trace}
  end

  test "notify returns a truthy value", %{conn: conn, trace: trace} do
    assert AirbrakeHandler.notify(conn, trace)
  end

  test "payload returns a parsed and encoded JSON payload", %{conn: conn, trace: trace} do
    assert AirbrakeHandler.payload(conn, trace) == Poison.encode!(Parser.parse_error(conn, trace))
  end

  test "headers returns the JSON content type headers" do
    assert AirbrakeHandler.headers == [{"Content-Type", "application/json"}, {"Accept", "application/json"}]
  end

  test "project_key returns the Airbrake project key from the environment" do
    assert AirbrakeHandler.project_key == @project_key
  end

  test "project_id returns the Airbrake project id from the environment" do
    assert AirbrakeHandler.project_id == @project_id
  end

  test "host returns the Airbrake host from the environment" do
    assert AirbrakeHandler.host == @host
  end

  test "api_version returns the Airbrake api_version from the environment" do
    Application.put_env(:airbrakify, :api_version, @api_version)
    assert AirbrakeHandler.api_version == @api_version
  end

  test "api_version when nil" do
    Application.delete_env(:airbrakify, :api_version)
    assert AirbrakeHandler.api_version == "v3"
  end

  test "url returns the assembled URL to post to Airbrake" do
    Application.put_env(:airbrakify, :api_version, @api_version)
    assert AirbrakeHandler.url == "#{@host}/api/v4/projects/#{@project_id}/notices?key=#{@project_key}"
  end
end
