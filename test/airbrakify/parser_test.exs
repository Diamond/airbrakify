defmodule ParserTest do
  use ExUnit.Case
  alias Airbrakify.Parser
  alias TestError

  setup do
    environment_variables = System.get_env
    {:ok, app_version}    = :application.get_key(:airbrakify, :vsn)
    reason                = %TestError{data: "Some Garbage"}
    type                  = "TestError"
    message               = inspect(reason)
    stacktrace = [
      {:module, :function, 1, [file: "lib/file.ex", line: 102]},
      {:module, :other_function, 2, [file: "lib/other_file.ex", line: 256]},
    ]
    {:ok, environment_variables: environment_variables, app_version: app_version, reason: reason, type: type, message: message, stacktrace: stacktrace}
  end

  test "environment_variables returns current list of environment variables", %{environment_variables: environment_variables} do
    assert Parser.environment_variables == environment_variables
  end

  test "app_version returns the current application version", %{app_version: app_version} do
    assert Parser.app_version == app_version
  end

  test "parse_reason parses an error struct", %{reason: reason} do
    assert Parser.parse_reason(reason) == %{type: "TestError", message: inspect(reason)}
  end

  test "parse_reason parses a tuple of error structs and additional data" do
    reason = {%TestError{data: "Some Garbage"}, {:error, "Some other garbage happened too"}}
    {struct, data} = reason
    assert Parser.parse_reason(reason) == %{type: "TestError", message: inspect(struct) <> "//" <> inspect(data)}
  end

  test "parse_stacktrace parses out an error_handler stacktrace", %{type: type, message: message, stacktrace: stacktrace} do
    expected_stacktrace = [
      %{file: "lib/file.ex", line: 102, function: "(module) function/1"},
      %{file: "lib/other_file.ex", line: 256, function: "(module) other_function/2"},
    ]
    expected_result = %{
      type:      type,
      message:   message,
      backtrace: expected_stacktrace
    }
    assert Parser.parse_stacktrace(type, message, stacktrace) == expected_result
  end

  test "parse_error returns the current Airbrake expected format", %{reason: reason, type: type, message: message, stacktrace: stacktrace, environment_variables: environment_variables, app_version: app_version} do
    fake_conn = %{
      params: %{"param1" => "foo", "param2" => "bar"},
      private: %{
        plug_session: %{"key" => "value"}
      }
    }
    expected_stacktrace = [
      %{file: "lib/file.ex", line: 102, function: "(module) function/1"},
      %{file: "lib/other_file.ex", line: 256, function: "(module) other_function/2"},
    ]
    expected_errors = %{
      type:      type,
      message:   message,
      backtrace: expected_stacktrace
    }
    expected_result = %{
      errors: [expected_errors],
      context: %{
        notifier: %{
          name:    "Airbrakify",
          version: app_version,
          url:     "https://github.com/Diamond/airbrakify"
        },
        environment: Mix.env,
        language: "Elixir #{System.version}",
        rootDirectory: System.cwd
      },
      environment: environment_variables,
      session: fake_conn.private.plug_session,
      params: fake_conn.params
    }
    assert Parser.parse_error(fake_conn, %{kind: nil, reason: reason, stack: stacktrace}) == expected_result
  end
end
