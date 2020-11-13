defmodule PlanningPokerWeb.SessionController do
  use PlanningPokerWeb, :controller

  def sign_in(conn, %{"join" => %{"user_name" => user_name, "room_id" => room_id}}) do
    conn
    |> put_session(:user_name, user_name)
    |> redirect(to: Routes.room_path(conn, :index, room_id))
  end

end
