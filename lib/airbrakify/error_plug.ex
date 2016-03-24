defmodule Airbrakify.ErrorPlug do
  defmacro __using__(_env) do
    quote do
      import Airbrakify.ErrorPlug
      use Plug.ErrorHandler

      defp handle_errors(conn, error_trace) do
        Application.ensure_all_started(:airbrakify)

        project_key = "d1b4e219dc036ea93f6e255960483c79"
        project_id  = "56f300d1d53cc8fadd00000c"
        url = "http://localhost:3000/api/v3/projects/#{project_id}/notices?key=#{project_key}"
        headers = [{"Content-Type", "application/json"}, {"Accept", "application/json"}]
        payload = conn
          |> parse_error(error_trace)
          |> Poison.encode!

        IO.inspect HTTPoison.post!(url, payload, headers)
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

      def parse_reason(reason) do
        case reason do
          {struct, data} ->
            %{type: inspect(struct.__struct__), message: inspect(struct) <> inspect(data)}
          struct ->
            %{type: inspect(struct.__struct__), message: inspect(struct)}
        end
      end

      def parse_error(conn, %{kind: kind, reason: reason, stack: stack}) do
        %{type: error_type, message: error_message} = parse_reason(reason)
        %{
          errors: [parse_stacktrace(error_type, error_message, stack)],
          context: %{
            notifier: %{
              name:    "Airbrakify",
              version: "0.0.1",
              url:     "Airbrakify.com"
            },
            environment: Mix.env,
            language: "Elixir #{System.version}",
            rootDirectory: System.cwd
          },
          environment: environment_variables,
          session: conn.private[:plug_session],
          params: conn.params
        }
      end

      def environment_variables do
        System.get_env
      end
    end
  end
end
