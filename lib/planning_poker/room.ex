defmodule PlanningPoker.Room do
  use GenServer, restart: :transient

  @timeout Application.fetch_env!(:planning_poker, :room_ttl) * 60 * 1_000
  @join_timeout Application.fetch_env!(:planning_poker, :room_join_timeout) * 60 * 1_000

  defp via_tuple(room_id) do
    {:via, Registry, {PlanningPoker.RoomRegistry, room_id}}
  end

  defp start(room_id) do
    result = DynamicSupervisor.start_child(PlanningPoker.RoomSupervisor, {PlanningPoker.Room, room_id: room_id, name: via_tuple(room_id)})
    case result do
     {:ok, _pid}  -> :ok
     {:error, {:already_started, _pid}} -> :ok
     err -> err
    end
  end

  @doc """
  Returns %Room{} with given `room_id`

  Room is retreived from associated `PlanningPoker.Room` process.
  If such process does not exist, it is started first.
  """
  def get_room(room_id) do
    :ok = start(room_id)
    GenServer.cast(via_tuple(room_id), :check_state)
    GenServer.call(via_tuple(room_id), :room)
  end

  @doc """
  Adds player to the room.
  Participant is created as :player by default.

  Returns {:ok, participant} | {:error, reason}
  """
  def add_participant(room_id, name) do
    case GenServer.call(via_tuple(room_id), {:join, name}) do
      {:ok, room, participant} ->
        broadcast_room_update(room)
        {:ok, participant}
      {:error, err} -> {:error, err}
    end
  end

  @doc """
  Removes participant `name` from room `room_id`.

  Returns :ok
  """
  def leave(room_id, name) do
    room = GenServer.call(via_tuple(room_id), {:leave, name})
    :logger.debug("User #{name} left #{room_id}")
    broadcast_msg(room_id, {:room_update, room})
  end


  @doc """
  Toggles participant state in given room.

  When participant changes from spectator to player, then new card is added to the room.
  When participant changes from player to spectator, then his card is removed from the room.
  """
  @spec toggle_participant(String.t(), String.t()) :: :ok
  def toggle_participant(room_id, participant_name) do
    room = GenServer.call(via_tuple(room_id), {:toggle, participant_name})
    broadcast_room_update(room)
  end

  @doc """
  Casts a vote.

  Returns either :ok | {:error, Reason}
  Reason is :no_card | :voting_finished
  """
  def vote(room_id, participant_name, value) do
    result = GenServer.call(via_tuple(room_id), {:vote, participant_name, value})
    case result do
      {:ok, room} ->
        broadcast_room_update(room)
        :ok
      {:error, reason} -> {:error, reason}
    end
  end

  def reveal(room_id) do
    room = GenServer.call(via_tuple(room_id), :reveal)
    broadcast_room_update(room)
  end

  def new_draw(room_id) do
    room = GenServer.call(via_tuple(room_id), :new_draw)
    broadcast_room_update(room)
  end

  defp broadcast_room_update(room) do
    broadcast_msg(room.room_id, {:room_update, room})
  end

  defp broadcast_msg(room_id, msg) do
    Phoenix.PubSub.broadcast!(PlanningPoker.PubSub, "room:" <> room_id, msg)
  end


  def start_link(options) do
    {:ok, room_id} = Keyword.fetch(options, :room_id)
    GenServer.start_link(__MODULE__, %Room{room_id: room_id}, options)
  end

  @impl true
  def init(room) do
    {:ok,  room}
  end

  @impl true
  def handle_call(:room, _from, room) do
    {:reply, room, room, @timeout}
  end

  @impl true
  def handle_call({:join, name}, {pid, _ref}, room) do
    monitor_ref = Process.monitor(pid)
    join_result = Room.add_participant(room, name, monitor_ref)
    case join_result do
      {:ok, room, participant} ->
        :logger.info("User #{name} joined")
        {:reply, {:ok, room, participant} , room, @timeout}
      err -> {:reply, err, room, @timeout}
    end
  end

  @impl true
  def handle_call({:leave, name}, _from, room) do
    room = Room.remove_participant(room, name)
    {:reply, room, room, @timeout}
  end

  @impl true
  def handle_call({:vote, owner, value}, _from, room) do
    result = Room.vote(room, owner, value)
    case result do
      {:ok, new_room} -> {:reply, {:ok, new_room}, new_room, @timeout}
      err -> {:reply, err, room, @timeout}
    end
  end

  @impl true
  def handle_call({:toggle, participant_name}, _from, room) do
    new_room = Room.toggle_participant(room, participant_name)
    {:reply, new_room, new_room, @timeout}
  end

  @impl true
  def handle_call(:reveal, _from, room) do
    new_room = Room.reveal_cards(room)
    {:reply, new_room, new_room, @timeout}
  end

  @impl true
  def handle_call(:new_draw, _from, room) do
    new_room = Room.new_draw(room)
    {:reply, new_room, new_room, @timeout}
  end

  @impl true
  def handle_cast(:check_state, room) do
    if(!is_room_active?(room)) do
      Process.send_after(self(), :check_state, @join_timeout)
    end
    {:noreply, room}
  end

  @impl true
  def handle_info(:check_state, room) do
    if(!is_room_active?(room)) do
      Process.send(self(), :timeout, [])
    end
    {:noreply, room}
  end

  @impl true
  def handle_info(:timeout, room) do
    :logger.info("Timeout reached, closing room #{room.room_id}")
    {:stop, :normal, room}
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, room) do
    user_to_remove = Map.values(room.participants)
      |> Enum.find_value(&(ref == &1.monitor_ref && &1.name))

    new_room = Room.remove_participant(room, user_to_remove)
    broadcast_room_update(new_room)
    :logger.debug("process connected to room #{room.room_id} died")
    if (!is_room_active?(new_room)) do
      :logger.info("Room #{room.room_id} became empty, closing process")
      {:stop, :normal, new_room}
    else
      {:noreply, new_room}
    end
  end

  defp is_room_active?(room) do
    Enum.count(room.participants) > 0 || Enum.count(room.cards) > 0
  end
end
