defmodule Snowflake do
  @behaviour Ecto.Type

  def type, do: :string

  defguard is_snowflake(term)
           when is_integer(term) and term in 0..0xFFFFFFFFFFFFFFFF

  def dump(str) when is_binary(str) do
    {:ok, str}
  end

  def dump(snowflake) when is_snowflake(snowflake) do
    {:ok, to_string(snowflake)}
  end

  def cast(value)
  def cast(nil), do: {:ok, nil}
  def cast(value) when is_snowflake(value), do: {:ok, value}

  def cast(value) when is_binary(value) do
    case Integer.parse(value) do
      {snowflake, _} ->
        cast(snowflake)

      _ ->
        :error
    end
  end

  def cast(_), do: :error

  def load(term) do
    cast(term)
  end

  def embed_as(_format), do: :self

  def equal?(term, term), do: true
  def equal?(_, _), do: false
end
