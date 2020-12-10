defmodule Room do
  @enforce_keys [:room_id]
  defstruct [:room_id, state: :voting, cards: %{}, participants: %{}]


  def create(id), do: %Room{room_id: id}

  def new_draw(room) do
    cards = for %Participant{type: :player, name: owner} <- Map.values(room.participants),
            into: %{},
            do: {owner, %Card{owner: owner}}

    %{room | state: :voting, cards: cards}
  end

  def vote(%Room{state: :revealed}, _owner, _value), do: {:error, :voting_finished}

  def vote(room, owner_name, value) do
    card = Map.get(room.cards, owner_name)
    if card do
      card = card |> Card.set_value(value)
      cards = Map.put(room.cards, owner_name, card)
      {:ok, %{room | cards: cards}}
    else
      {:error, :no_card}
    end
  end



  def add_participant(room, name, monitor_ref) do
    if Map.has_key?(room.participants, name) do
      {:error, :name_taken}
    else
      participant = %Participant{name: name, monitor_ref: monitor_ref}
      participants = Map.put(room.participants, name, participant)
      cards = Map.put_new(room.cards, name, %Card{owner: name})
      new_room = %{room | participants: participants, cards: cards}

      {:ok, new_room, participant}
    end
  end

  def remove_participant(room, name) do
    participants = Map.delete(room.participants, name)
    {card, other_cards} = Map.pop(room.cards, name)
    cards = if Card.is_empty(card),  do: other_cards, else: room.cards
    %{room | participants: participants, cards: cards}
  end

  def toggle_participant(room, name) do
    with {:ok, participant} <- Map.fetch(room.participants, name),
         toggled_participant <- Participant.toggle_type(participant),
         participants <- Map.put(room.participants, name, toggled_participant),
         cards <- update_cards(room, toggled_participant)
    do
      %{room | participants: participants, cards: cards}
    else
      err ->
        :logger.warning("Failed to toggle participant: #{name} for room: #{inspect(room, pretty: true)}. Reason: #{inspect(err, pretty: true)}")
        room
    end
  end


  defp update_cards(room, %Participant{name: name, type: :player}) do
    Map.put_new(room.cards, name, %Card{owner: name})
  end
  defp update_cards(room, %Participant{name: name, type: :spectator}) do
    Map.delete(room.cards, name)
  end

  def reveal_cards(room) do
    cards = Map.new(room.cards, fn {k, v} -> {k, Card.reveal(v)} end)
    %{room | cards: cards, state: :revealed}
  end

end
