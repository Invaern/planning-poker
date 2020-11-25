defmodule PlanningPokerWeb.BoardView do
  use PlanningPokerWeb, :view

  def card(card) do
    {color, value} = get_color_value(card.type)
    owner = card.owner
    render("card.html", owner: owner, color: color, value: value)
  end

  def deck_card(card_value) do
    {color, value} = get_color_value({:visible, card_value})
    render("deck_card.html", color: color, value: value, value_atom: card_value)
  end

  defp get_color_value(:empty), do: {"text-gray-200", "?"}
  defp get_color_value({:hidden, _}), do: {"text-yellow-400", "!"}

  defp get_color_value({:visible, value}) do
    case value do
      :half -> {"text-blue-600", "½"}
      :one -> {"text-lightBlue-500", "1"}
      :two -> {"text-teal-500", "2"}
      :three -> {"text-lime-500", "3"}
      :five -> {"text-yellow-400", "5"}
      :eight -> {"text-orange-500", "8"}
      :thirteen -> {"text-orange-800", "13"}
      :twenty -> {"text-red-600", "20"}
      :question -> {"text-purple-800", "?"}
    end
  end

end
