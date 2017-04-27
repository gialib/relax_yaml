defmodule RelaxYaml do
  def decode!(str, opts \\ []) do
    RelaxYaml.Decoder.read_from_string(str, opts)
  end

  def encode!(data, opts \\ []) do
    RelaxYaml.Encoder.encode(data, opts)
  end
end
