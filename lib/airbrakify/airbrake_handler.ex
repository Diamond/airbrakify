defmodule Airbrakify.AirbrakeHandler do
  alias Airbrakify.Parser

  def notify(conn, error_trace) do
    HTTPoison.post(url, payload(conn, error_trace), headers)
  end

  def notify(%{type: type, message: message}=notification) do
    HTTPoison.post(url, payload(notification), headers)
  end

  def payload(conn, error_trace) do
    conn
    |> Parser.parse_error(error_trace)
    |> Poison.encode!
  end

  def payload(%{type: type, message: message}) do
    Parser.parse_message(type, message)
    |> Poison.encode!
  end

  def headers,     do: [{"Content-Type", "application/json"}, {"Accept", "application/json"}]
  def project_key, do: Application.fetch_env!(:airbrakify, :project_key)
  def project_id,  do: Application.fetch_env!(:airbrakify, :project_id)
  def host,        do: Application.fetch_env!(:airbrakify, :host)
  def api_version do
    case Application.fetch_env(:airbrakify, :api_version) do
      {:ok, api_version} -> api_version
      :error -> "v3"
    end
  end
  def url, do: "#{host}/api/#{api_version}/projects/#{project_id}/notices?key=#{project_key}"
end
