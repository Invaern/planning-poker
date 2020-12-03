defmodule RoomTest do
  use ExUnit.Case

  test "add participants" do
    room = Room.create("test")
    {:ok, room, _} = Room.add_participant(room, "Bob", nil)
    {:ok, room, _} = Room.add_participant(room, "Alice", nil)
    assert true == Map.has_key?(room.participants, "Bob")
    assert true == Map.has_key?(room.participants, "Alice")
    assert 2 == Enum.count(room.participants)
  end

  test "new participant is a player" do
    {:ok, room, p} = Room.create("test") |> Room.add_participant("Bob", nil)
    assert :player == p.type
    assert true == Map.has_key?(room.cards, p.name)
  end

  test "turning player into spectator removes his card" do
    {:ok, room, p} = Room.create("test") |> Room.add_participant("Bob", nil)
    room = Room.toggle_participant(room, p.name)
    assert false == Map.has_key?(room.cards, p.name)
    assert {:ok, %Participant{type: :spectator}} = Map.fetch(room.participants, p.name)
  end

  test "toggling player twice has no effect" do
    {:ok, room, p} = Room.create("test") |> Room.add_participant("Bob", nil)
    new_room = room |> Room.toggle_participant(p.name) |> Room.toggle_participant(p.name)
    assert new_room == room
  end

end
