defmodule Participant do
  @enforce_keys [:name]
  defstruct [:name, type: :player]

end
