defmodule PlanningPokerWeb.BoardView do
  use PlanningPokerWeb, :view

  def card(card) do
    render("card.html", card: card)
  end
end
