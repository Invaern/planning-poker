defmodule PlanningPokerWeb.RoomLive do
  use PlanningPokerWeb, :live_view

  @impl true
  def render(assigns) do
    Phoenix.View.render(PlanningPokerWeb.PageView, "room.html", assigns)
  end

  @impl true
  def mount(%{"id" => room_id} = _params, %{"user_name" => user_name} = _session, socket) do
    with :ok <- Phoenix.PubSub.subscribe(PlanningPoker.PubSub, "room:" <> room_id),
         {:ok, room} <- PlanningPoker.Room.get_room(room_id),
         user <- join_room(room, user_name)
    do
    socket = socket
      |> assign(user_card: nil)
      |> assign(user: user)
      |> assign(errors: [])
      |> assign_room(room)
      |> assign(page_title: "PlanningPoker - #{room.room_id}")
    socket =
      case user do
        nil -> socket
        %Participant{name: name} -> push_event(socket, "set_username", %{user_name:  name})
      end
    {:ok, socket}
    else
      err ->
        :logger.error("Failed to join a room: #{room_id}, reason: #{inspect(err)}")
        {:ok, redirect(socket, to: "/")}
    end
  end

  defp assign_room(socket, room) do
    socket
    |> assign(room_id: room.room_id)
    |> assign(room: room)
    |> assign(cards: Map.values(room.cards))
    |> assign(participants: Map.values(room.participants))
  end

  defp join_room(room, user_name) do
    with {:ok, participant} <- PlanningPoker.Room.add_participant(room.room_id, user_name)
    do
      participant
    else
      _ -> nil
    end
  end

  @impl true
  def handle_event("vote", %{"ref" => val}, socket) do
    value_atom = case val do
      "half" -> :half
      "one" -> :one
      "two" -> :two
      "three" -> :three
      "five" -> :five
      "eight" -> :eight
      "thirteen" -> :thirteen
      "twenty" -> :twenty
      "question" -> :question
    end
    case PlanningPoker.Room.vote(socket.assigns.room_id, socket.assigns.user.name, value_atom) do
      :ok -> nil
      {:error, :voting_finished } -> :logger.warning("Attempt to vote when voting has finished")
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_participant", %{"ref" => name}, socket) do
    PlanningPoker.Room.toggle_participant(socket.assigns.room_id, name)
    {:noreply, socket}
  end

  @impl true
  def handle_event("reveal", _, socket) do
    PlanningPoker.Room.reveal(socket.assigns.room.room_id)
    {:noreply, socket}
  end

  @impl true
  def handle_event("new_draw", _, socket) do
    PlanningPoker.Room.new_draw(socket.assigns.room.room_id)
    {:noreply, socket}
  end

  @impl true
  def handle_event("reestimate", _, socket) do
    PlanningPoker.Room.reestimate(socket.assigns.room.room_id)
    {:noreply, socket}
  end

  @impl true
  def handle_event("log_out", _, socket) do
    room = socket.assigns.room
    user = socket.assigns.user
    :ok = PlanningPoker.Room.leave(room.room_id, user.name)
    socket = assign(socket, user: nil, user_card: nil)
    {:noreply, push_event(socket, "clear_cookies", %{})}
  end

  @impl true
  def handle_info({:joined, user}, socket) do
    user_card = get_user_card(user, socket.assigns.room)
    socket = assign(socket, user: user, user_card: user_card)

    {:noreply, push_event(socket, "set_username", %{user_name:  user.name}) }
  end


  @impl true
  def handle_info({:room_update, room}, socket) do
    cards = case room.state do
      :revealed -> room.cards |> Map.values() |> Card.sort_cards()
      :voting -> room.cards |> Map.values()
    end

    user_card = get_user_card(socket.assigns.user, room)
    user = user_update(socket.assigns.user, room)
    participants = Map.values(room.participants)
    {:noreply, assign(socket, cards: cards, participants: participants, user_card: user_card, room: room, user: user)}
  end

  defp user_update(user, room) do
    with %Participant{name: name} <- user,
         user <- Map.get(room.participants, name)
    do
      user
    else
      _err -> nil
    end
  end

  defp get_user_card(user, room) do
    with %Participant{name: name} <- user,
         %Card{} = card  <- Map.get(room.cards, name)
    do
      Card.reveal(card)
    else
      _err -> nil
    end

  end

end
