defmodule PlanningPokerWeb.RedirectController do
  use PlanningPokerWeb, :controller

  def redirect_home(conn, _params) do
    redirect(conn, to: "/")
  end
end
