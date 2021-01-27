defmodule RoomTest do
  use ExUnit.Case

  test "add participants" do
    {:ok, room} = Room.create("test")
    {:ok, room, _} = Room.add_participant(room, "Bob", nil)
    {:ok, room, _} = Room.add_participant(room, "Alice", nil)
    assert true == Map.has_key?(room.participants, "Bob")
    assert true == Map.has_key?(room.participants, "Alice")
    assert 2 == Enum.count(room.participants)
  end

  test "new participant is a player" do
    {:ok, room} = Room.create("test")
    {:ok, room, p} = Room.add_participant(room, "Bob", nil)
    assert :player == p.type
    assert true == Map.has_key?(room.cards, p.name)
  end

  test "turning player into spectator removes his card" do
    {:ok, room} = Room.create("test")
    {:ok, room, p} = Room.add_participant(room, "Bob", nil)
    room = Room.toggle_participant(room, p.name)
    assert false == Map.has_key?(room.cards, p.name)
    assert {:ok, %Participant{type: :spectator}} = Map.fetch(room.participants, p.name)
  end

  test "toggling player twice has no effect" do
    {:ok, room} = Room.create("test")
    {:ok, room, p} = Room.add_participant(room, "Bob", nil)
    new_room = room |> Room.toggle_participant(p.name) |> Room.toggle_participant(p.name)
    assert new_room == room
  end

  test "non empty card remains after player is removed" do
    {:ok, room} = Room.create("test")
    {:ok, room, p} = Room.add_participant(room, "Bob", nil)
    {:ok, room } = Room.vote(room, p.name, :two)
    room = Room.remove_participant(room, p.name)
    assert true == Map.has_key?(room.cards, p.name)
  end

  test "can't create too long room_id" do
    long_id = String.pad_leading("", Room.max_id_len() + 1, ["x"])
    assert {:error, :too_long} == Room.create(long_id)
  end

  test "can't create room with blank id" do
    assert {:error, :blank} == Room.create("  ")
  end

  test "can't create room with non string id" do
    assert {:error, :invalid_type} == Room.create(42)
  end

  test "reestimation should copy values" do
    {:ok, room} = Room.create("test")
    {:ok, room, p1} = Room.add_participant(room, "Bob", nil)
    {:ok, room, p2} = Room.add_participant(room, "Alice", nil)
    {:ok, room} = Room.vote(room, p1.name, :one)
    {:ok, room} = Room.vote(room, p2.name, :two)
    room = Room.reestimate(room)
    %Card{type: :empty, prev_val: v1} = Map.get(room.cards, p1.name)
    %Card{type: :empty, prev_val: v2} = Map.get(room.cards, p2.name)

    assert :one == v1
    assert :two == v2
  end
end
