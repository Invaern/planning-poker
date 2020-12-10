defmodule Card do

  @enforce_keys [:owner]
  defstruct [:owner, type: :empty]

  @values_order [half: 0.5, one: 1, two: 2, three: 3, five: 5, eight: 8, thirteen: 13, twenty: 20, question: 100]

  def set_value(%Card{type: {:visible, _}} = card, _value), do: card

  def set_value(card, value) do
    %{card | type: {:hidden, value}}
  end

  def reveal(%Card{type: {:hidden, value}} = card), do: %{card | type: {:visible, value}}
  def reveal(card), do: card

  def is_empty(%Card{type: :empty}), do: true
  def is_empty(_), do: false

  def sort_cards(cards) do
    Enum.sort(cards, &is_smaller/2)
  end

  defp is_smaller(_, %Card{type: :empty}), do: true
  defp is_smaller(%Card{type: :empty}, _), do: false
  defp is_smaller(%Card{type: {:visible, v1}}, %Card{type: {:visible, v2}}) do
    Keyword.fetch!(@values_order, v1) <= Keyword.fetch!(@values_order, v2)
  end



end
