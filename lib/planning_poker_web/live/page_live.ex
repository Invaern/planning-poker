defmodule PlanningPokerWeb.PageLive do
  use PlanningPokerWeb, :live_view

  @impl true
  def render(assigns) do
    Phoenix.View.render(PlanningPokerWeb.PageView, "homepage.html", assigns)
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, room_err: nil, errors: [])}
  end

  @impl true
  def handle_event("save", %{"join" => %{"room_id" => room_id}}, socket) do
    if is_room_valid(room_id) do
      {:noreply, push_redirect(socket, to: Routes.room_path(socket, :index, room_id))}
    else
      {:noreply, assign(socket, errors: [room_id: "Room can't be empty"])}
    end

  end


  defp is_room_valid(room_id) do
    room_id
    |> String.trim()
    |> String.length()
    |> Kernel.!=(0)

  end

end
