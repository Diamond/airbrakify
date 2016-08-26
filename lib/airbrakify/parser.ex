defmodule Airbrakify.Parser do
  def parse_error(conn, %{kind: _kind, reason: reason, stack: stack}) do
    %{type: error_type, message: error_message} = parse_reason(reason)
    %{
      errors: [parse_stacktrace(error_type, error_message, stack)],
      context: %{
        notifier: %{
          name:    "Airbrakify",
          version: app_version,
          url:     "https://github.com/Diamond/airbrakify"
        },
        environment: "Elixir",
        language: "Elixir #{System.version}",
        rootDirectory: System.cwd
      },
      environment: environment_variables,
      session: conn.private[:plug_session],
      params: conn.params
    }
  end

  def parse_stacktrace(type, message, stack) do
    %{
      type: type,
      message: message,
      backtrace: Enum.map(stack, fn line ->
        {module, function, arity, [file: file, line: line]} = line
        %{file: to_string(file), line: line, function: "(#{module}) #{function}/#{arity}"}
      end)
    }
  end

  def parse_message(type, message) do
    %{
      errors: [%{
        type: type,
        message: message
      }],
      context: %{
        notifier: %{
          name:    "Airbrakify",
          version: app_version,
          url:     "https://github.com/Diamond/airbrakify"
        },
        environment: "Elixir",
        language: "Elixir #{System.version}",
        rootDirectory: System.cwd
      },
      environment: environment_variables
    }
  end

  def parse_reason(reason) do
    case reason do
      {struct, data} ->
        %{type: inspect(struct.__struct__), message: inspect(struct) <> "//" <> inspect(data)}
      struct ->
        %{type: inspect(struct.__struct__), message: inspect(struct)}
    end
  end

  def app_version do
    case :application.get_key(:airbrakify, :vsn) do
      {:ok, version} -> version
      _ -> "n/a"
    end
  end

  def environment_variables do
    System.get_env
  end
end
