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

  def vote(room, owner, value) do
    card = Map.get(room.cards, owner)
    if card do
      card = card |> Card.set_value(value)
      cards = Map.put(room.cards, owner, card)
      {:ok, %{room | cards: cards}}
    else
      {:error, :no_card}
    end
  end



  def add_participant(room, name) do
    if Map.has_key?(room.participants, name) do
      {:error, :name_taken}
    else
      participant = %Participant{name: name}
      participants = Map.put_new(room.participants, name, participant)
      cards = Map.put_new(room.cards, name, %Card{owner: name})
      # new_room = put_in(room.participants, participants)
      new_room = %{room | participants: participants, cards: cards}

      {:ok, new_room}
    end
  end

  def remove_participant(room, name) do
    {_, participants} = Map.pop(room.participants, name)
    card = Map.pop(room.cards, name)
    {_, cards} = if Card.is_empty(card),  do: Map.pop(room.cards, name), else: {nil, room.cards}
    %{room | participants: participants, cards: cards}
  end

  def reveal_cards(room) do
    cards = Map.values(room.cards)
      |> Enum.map(&Card.reveal/1)

    %{room | cards: cards}
  end

end
