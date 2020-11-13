defmodule PlanningPokerWeb.RoomLive do
  use PlanningPokerWeb, :live_view

  @impl true
  def render(assigns) do
    Phoenix.View.render(PlanningPokerWeb.PageView, "room.html", assigns)
  end

  @impl true
  def mount(%{"id" => room_id} = _params,  _session, socket) do
    IO.puts("mounting")
    # IO.inspect(params)
    # IO.inspect(session)
    :ok = PlanningPoker.Room.start(room_id)
    :ok = Phoenix.PubSub.subscribe(PlanningPoker.PubSub, "room:" <> room_id)

    p_socket = socket
      |> assign(user_name: nil)
      |> assign(trigger_submit: false)
      |> assign(errors: [])
      |> assign(room_id: room_id)

    {:ok, p_socket}
  end

  @impl true
  def handle_info({:joined, user_name}, socket) do
    {:noreply, assign(socket, user_name: user_name)}
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

  @impl true
  def handle_info({:room_update, room}, socket) do
    IO.puts("Room update arrived")
    IO.inspect(room)
    cards = Map.values(room.cards)
    participants = Map.values(room.participants)
    {:noreply, assign(socket, cards: cards, participants: participants)}
  end

end
