defmodule PlanningPokerWeb.BoardView do
  use PlanningPokerWeb, :view


  def card(card, show_prev \\ false)
  def card(card, show_prev) do
    {color, value} = get_color_value(card.type)
    owner = card.owner
    {prev_color, prev_val} = get_prev_color_value(card)
    render("card.html", owner: owner, color: color, value: value,
                        show_prev: show_prev && card.prev_val,
                        prev_val: prev_val, prev_color: prev_color)
  end

  def deck_card(card_value) do
    {color, value} = get_color_value({:visible, card_value})
    render("deck_card.html", color: color, value: value, value_atom: card_value)
  end

  def cards_animation(:voting), do: "visible opacity-100"
  def cards_animation(:revealed), do: "invisible opacity-0"

  defp get_color_value(:empty), do: {"text-gray-200", "?"}
  defp get_color_value({:hidden, _}), do: {"text-lime-500", "!"}

  defp get_color_value({:visible, value}) do
    case value do
      :half -> {"text-blue-600", "½"}
      :one -> {"text-lightBlue-500", "1"}
      :two -> {"text-teal-500", "2"}
      :three -> {"text-lime-500", "3"}
      :five -> {"text-yellow-400", "5"}
      :eight -> {"text-orange-500", "8"}
      :thirteen -> {"text-red-600", "13"}
      :twenty -> {"text-orange-800", "20"}
      :question -> {"text-purple-800", "?"}
    end
  end

  defp get_prev_color_value(%Card{prev_val: nil}), do: get_color_value(:empty)
  defp get_prev_color_value(%Card{prev_val: value}), do: get_color_value({:visible, value})

end
