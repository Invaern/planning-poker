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
    room = PlanningPoker.Room.get_room(room_id)
    :ok = Phoenix.PubSub.subscribe(PlanningPoker.PubSub, "room:" <> room_id)

    p_socket = socket
      |> assign(user_name: nil)
      |> assign(trigger_submit: false)
      |> assign(errors: [])
      |> assign_room(room)

    {:ok, p_socket}
  end

  defp assign_room(socket, room) do
    socket
    |> assign(room_id: room.room_id)
    |> assign(cards: Map.values(room.cards))
    |> assign(participants: Map.values(room.participants))
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
  def handle_info({:joined, user_name}, socket) do
    IO.puts("user joined")
    IO.inspect(socket.assigns)
    {:noreply, assign(socket, user_name: user_name)}
  end


  @impl true
  def handle_info({:room_update, room}, socket) do
    IO.puts("Room update arrived")
    IO.inspect(room)
    cards = Map.values(room.cards)
    participants = Map.values(room.participants)
    {:noreply, assign(socket, cards: cards, participants: participants)}
  end

  @impl true
  def terminate(_reason, socket) do
    user_name = socket.assigns.user_name
    room_id = socket.assigns.room_id
    if user_name do
      :ok = PlanningPoker.Room.leave(room_id, user_name)
    end
  end

end
