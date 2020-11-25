defmodule Participant do
  @enforce_keys [:name, :monitor_ref]
  defstruct [:name, :monitor_ref, type: :player]

end
