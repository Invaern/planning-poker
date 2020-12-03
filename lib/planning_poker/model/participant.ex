defmodule Participant do
  @enforce_keys [:name, :monitor_ref]
  defstruct [:name, :monitor_ref, type: :player]

  @doc """
  Toggles type :player <-> :spectator

  Returns %Participant{}

  ## Examples

      iex> p = %Participant{name: "Bob", type: :player, monitor_ref: 1}
      ...> Participant.toggle_type(p)
      %Participant{monitor_ref: 1, name: "Bob", type: :spectator}

      iex> p = %Participant{name: "Bob", type: :spectator, monitor_ref: 1}
      ...> Participant.toggle_type(p)
      %Participant{monitor_ref: 1, name: "Bob", type: :player}

  """
  def toggle_type(%Participant{type: :player} = participant) do
    %{participant | type: :spectator}
  end
  def toggle_type(%Participant{type: :spectator} = participant) do
    %{participant | type: :player}
  end

end
