defmodule PlanningPokerWeb.RoomLive do
  use PlanningPokerWeb, :live_view

  @impl true
  def render(assigns) do
    Phoenix.View.render(PlanningPokerWeb.PageView, "room.html", assigns)
  end

  @impl true
  def mount(%{"id" => room_id} = params,  session, socket) do
    IO.puts("mounting")
    IO.inspect(params)
    user_name = session["user_name"]

    p_socket = socket
      |> assign(user_name: user_name)
      |> assign(room_id: room_id)

    {:ok, p_socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
  end

  defp apply_action(socket, :log_in, _params) do
    socket
  end
end
