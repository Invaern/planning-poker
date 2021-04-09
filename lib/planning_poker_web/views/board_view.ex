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

  def action_buttons(:voting) do
    assigns = %{:__changed__ => nil}
    ~L"""
    <button class="w-1/2 flex items-center justify-center
    bg-blue-500 hover:bg-blue-700 text-white focus:outline-none
    lg:text-sm xl:text-base
    transition-colors font-bold py-2 px-4 rounded"
    phx-click="reveal"
    type="submit">Reveal</button>
    """
  end
  def action_buttons(:revealed) do
    assigns = %{:__changed__ => nil}
    ~L"""
    <button class="w-1/2 flex items-center justify-center
    bg-green-600 hover:bg-green-700 text-white focus:outline-none
    lg:text-sm xl:text-base
    transition-colors font-bold py-2 px-4 rounded"
    phx-click="new_draw"
    type="button">New</button>
    <button class="w-1/2 flex items-center justify-center
    text-green-600 hover:text-green-700 focus:outline-none
    lg:text-sm xl:text-base
    transition-color font-bold py-2 px-4 rounded"
    phx-click="reestimate"
    type="button">Reestimate</button>
    """
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
