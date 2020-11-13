defmodule Card do

  @enforce_keys [:owner]
  defstruct [:owner, type: :empty]

  def set_value(%Card{type: {:visible, _}} = card, _value), do: card

  def set_value(card, value) do
    %{card | type: {:hidden, value}}
  end

  def reveal(%Card{type: {:hidden, value}} = card), do: %{card | type: {:visible, value}}
  def reveal(card), do: card

  def is_empty(%Card{type: :empty}), do: true
  def is_empty(_), do: false

end
