defmodule RelaxYaml.Encoder do
  @moduledoc """
  Not ready for production, still WIP.
  """

  @doc """
  Encodes data to YAML
  """
  def encode value, opts do
    encode 0, value, opts
  end

  defp encode(_indent, data, _opts) when is_number(data) do
    "#{data}\n"
  end

  defp encode(_indent, data, _opts) when is_boolean(data) do
    value = case data do
      true -> "true"
      _ -> "false"
    end
    ~s(#{value}\n)
  end

  defp encode(_indent, data, opts) when is_binary(data) do
    value = encode_string data, opts
    ~s(#{value}\n)
  end

  defp encode(_indent, data, opts) when is_atom(data) do
    ~s(#{encode_atom(data, opts)}\n)
  end

  defp encode(indent, data, opts) when is_list(data) do
    encode_list indent, "", data, opts
  end

  defp encode(indent, {k, v}, opts) do
    prefix = indent_spaces indent, opts
    value = encode indent, v, opts
    k = if is_atom(k), do: encode_atom(k, opts), else: k
    "#{prefix}#{k}: #{value}"
  end

  defp encode(indent, data, opts) when is_map(data) do
    encode_map indent, "", data, opts
  end

  defp encode_list(indent, s, [head|tail], opts) when is_tuple(head) do
    for {k, v} <- [head|tail],
      do: encode_key_value(indent, {k, v}, opts),
      into: s
  end

  defp encode_list indent, s, [head|tail], opts do
    value = encode_list_item indent, head, opts
    encode_list indent, "#{s}#{value}", tail, opts
  end

  defp encode_list _indent, s, [], _opts do
    s
  end

  defp encode_list_item indent, data, opts do
    value = encode data, opts
    prefix = indent_spaces(indent, opts)
    "#{prefix}- #{value}"
    if is_map(data) || is_list(data) do
      value = encode indent + 1, data, opts
      "#{prefix}-\n#{value}"
    else
      value = encode indent, data, opts
      "#{prefix}- #{value}"
    end
  end

  defp encode_map indent, s, data, opts do
    for {k, v} <- data,
      do: encode_key_value(indent, {k, v}, opts),
      into: s
  end

  defp encode_key_value indent, {k, v}, opts do
    prefix = indent_spaces indent, opts
    k = if is_atom(k), do: encode_atom(k, opts), else: k

    cond do
      is_map(v) ->
        if Enum.any?(v) do
          value = encode indent + 1, v, opts
          "#{prefix}#{k}:\n#{value}"
        else
          "#{prefix}#{k}: {}"
        end
      is_list(v) ->
        if Enum.any?(v) do
          value = encode indent + 1, v, opts
          "#{prefix}#{k}:\n#{value}"
        else
          "#{prefix}#{k}: []\n"
        end
      true ->
        value = encode indent, v, opts
        "#{prefix}#{k}: #{value}"
    end
  end

  defp encode_string data, opts do
    single_quotes = data =~ ~r/'/
    double_quotes = data =~ ~r/"/
    encode_string data, single_quotes, double_quotes, opts
  end

  defp encode_string(data, true, true, _opts) do
    ~s('''#{data}''')
  end

  defp encode_string(data, false, true, _opts) do
    ~s('#{data}')
  end

  defp encode_string(data, _single_quotes, _double_quotes, _opts) do
    ~s("#{data}")
  end

  defp indent_spaces 0, _opts do
    ""
  end

  defp indent_spaces n, _opts do
    for _ <- (0..n-1), do: "  ", into: ""
  end

  def encode_atom(data, opts) do
    if Keyword.get(opts, :atoms, false) do
      ":#{data}"
    else
      to_string(data)
    end
  end
end
