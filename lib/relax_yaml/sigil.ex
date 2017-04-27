defmodule RelaxYaml.Sigil do
  def sigil_y(string, [?a]),
    do: RelaxYaml.Decoder.read_from_string(string, atoms: true)

  def sigil_y(string, []),
    do: RelaxYaml.Decoder.read_from_string(string)
end
