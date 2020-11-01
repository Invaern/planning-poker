defmodule PlanningPokerWeb.SessionController do
  use PlanningPokerWeb, :controller

  def sign_in(conn, params) do
    IO.inspect(params)
    conn |> redirect(to: "/")
  end

end
