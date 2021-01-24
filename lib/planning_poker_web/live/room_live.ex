defmodule PlanningPokerWeb.RoomLive do
  use PlanningPokerWeb, :live_view

  @impl true
  def render(assigns) do
    Phoenix.View.render(PlanningPokerWeb.PageView, "room.html", assigns)
  end

  @impl true
  def mount(%{"id" => room_id} = _params,  _session, socket) do
    with {:ok, valid_room_id} <- PlanningPoker.Validation.validate_string(room_id, max_len: Room.max_id_len()),
         room <- PlanningPoker.Room.get_room(valid_room_id),
         :ok <- Phoenix.PubSub.subscribe(PlanningPoker.PubSub, "room:" <> room.room_id)
    do
    p_socket = socket
      |> assign(user_card: nil)
      |> assign(user: nil)
      |> assign(trigger_submit: false)
      |> assign(errors: [])
      |> assign_room(room)
      |> assign(page_title: "PlanningPoker - #{room.room_id}")
    {:ok, p_socket}
    else
      err ->
        :logger.warning("Failed to open a room: #{inspect(err)}")
        {:ok, push_redirect(socket, to: "/")}
    end
  end

  defp assign_room(socket, room) do
    socket
    |> assign(room_id: room.room_id)
    |> assign(room: room)
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
  def handle_info({:joined, user}, socket) do
    user_card = get_user_card(user, socket.assigns.room)

    {:noreply, assign(socket, user: user, user_card: user_card)}
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
