defmodule Airbrakify.ErrorPlug do
  defmacro __using__(_env) do
    quote do
      import Airbrakify.ErrorPlug
      use Plug.ErrorHandler

      defp handle_errors(conn, error_trace) do
        # IO.puts "\n\n\n"
        # IO.inspect conn
        # IO.puts "\n\n\n"
        # IO.inspect error_trace.stack
        # IO.puts "\n\n\n"
        # error_trace
        # |> parse_error(conn)
        # |> IO.inspect
        # IO.puts "\n\n\n"
        # IO.puts "!!! UH OH SPAGHETTIOS !!!"
        #
        # IO.puts "Sending to Errbit"

        project_key = "00c461c614b6a58ea6989dccdacd10fa"
        project_id  = "56f369e5d594004192000001"
        url = "http://localhost:3000/api/v3/projects/" <> project_id <> "/notices?key=" <> project_key
        headers = [{"Content-Type", "application/json"}, {"Accept", "application/json"}]
        payload = conn
          |> parse_error(error_trace)
          |> Poison.encode!

        HTTPoison.post!(url, payload, headers)
      end

      def parse_stacktrace(type, stack) do
        Enum.map(stack, fn line ->
          {module, function, arity, [file: file, line: line]} = line
          %{type: module, message: type, backtrace: %{file: file, line: line, function: "#{function}/#{arity}"}}
        end)
      end

      def parse_error(conn, %{kind: kind, reason: reason, stack: stack}) do
        error_type = reason.__struct__
        %{
          errors: parse_stacktrace(error_type, stack),
          context: %{
            notifier: %{
              name:    "Airbrakify",
              version: "0.0.1",
              url:     "Airbrakify.com"
            },
            environment: System.get_env,
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
