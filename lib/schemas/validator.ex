defmodule {{SCHEMA_APP_NAME_CAMEL}}.Validator do
  @moduledoc """
  Schema validator for {{SCHEMA_NAME}} messages.

  Load schemas from lib/schemas/*.schema.json and validate JSON payloads.
  """

  require Logger

  @doc """
  Validate a JSON payload against a schema.

  Returns {:ok, data} if valid, {:error, reason} otherwise.
  """
  def validate(schema_name, payload) do
    with {:ok, schema} <- load_schema(schema_name),
         {:ok, data} <- Jason.decode(payload) do
      case ExJsonSchema.Validator.validate(schema, data) do
        :ok -> {:ok, data}
        {:error, errors} -> {:error, format_errors(errors)}
      end
    end
  end

  @doc """
  Validate a map directly (already parsed).
  """
  def validate_map(schema_name, data) when is_map(data) do
    case load_schema(schema_name) do
      {:ok, schema} ->
        case ExJsonSchema.Validator.validate(schema, data) do
          :ok -> {:ok, data}
          {:error, errors} -> {:error, format_errors(errors)}
        end

      error ->
        error
    end
  end

  defp load_schema(schema_name) do
    schema_path = Path.join([__DIR__, "schemas", "#{schema_name}.schema.json"])

    case File.read(schema_path) do
      {:ok, content} ->
        case Jason.decode(content) do
          {:ok, schema} -> {:ok, schema}
          {:error, reason} -> {:error, "Failed to parse schema: #{reason}"}
        end

      {:error, reason} ->
        {:error, "Schema not found (#{schema_name}): #{reason}"}
    end
  end

  defp format_errors(errors) do
    errors
    |> Enum.map(&error_message/1)
    |> Enum.join("; ")
  end

  defp error_message({path, [{:type_mismatch, _}]}), do: "Invalid type at #{path}"
  defp error_message({path, [{:required, field}]}), do: "Missing required field: #{field} at #{path}"
  defp error_message({path, errors}), do: "Error at #{path}: #{inspect(errors)}"
end
