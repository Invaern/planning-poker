defmodule PlanningPoker.Room do
  use GenServer, restart: :transient

  @timeout 3_600_000

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
  It is possible for this function to fail if spawning process fails.
  """
  def get_room(room_id) do
    :ok = start(room_id)
    GenServer.call(via_tuple(room_id), :room)
  end

  def add_participant(room_id, name) do
    case GenServer.call(via_tuple(room_id), {:join, name}) do
      {:ok, room} ->
        broadcast_msg(room_id, {:room_update, room})
        :ok
      {:error, err} -> {:error, err}
    end
  end

  @doc """
  Removes participant `name` from room `room_id`.

  New room state is broadcasted to topic `room:<room_id>` as `{:room_update, room}`

  Returns :ok
  """
  def leave(room_id, name) do
    room = GenServer.call(via_tuple(room_id), {:leave, name})
    :logger.debug("User #{name} left #{room_id}")
    IO.inspect(room)
    broadcast_msg(room_id, {:room_update, room})
  end

  defp broadcast_msg(room_id, msg) do
    Phoenix.PubSub.broadcast!(PlanningPoker.PubSub, "room:" <> room_id, msg)
  end


  def start_link(options) do
    :logger.info("starting room process")
    {:ok, room_id} = Keyword.fetch(options, :room_id)
    IO.inspect(options)
    GenServer.start_link(__MODULE__, %Room{room_id: room_id}, options)
  end

  @impl true
  def init(room) do
    {:ok, room}
  end

  @impl true
  def handle_call(:room, _from, room) do
    {:reply, room, room, @timeout}
  end

  @impl true
  def handle_call({:join, name}, _from, room) do
    join_result = Room.add_participant(room, name)
    case join_result do
      {:ok, room} ->
        :logger.info("User #{name} joined")
        {:reply, {:ok, room} , room, @timeout}
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
      {:ok, room} -> {:reply, :ok, room, @timeout}
      err -> {:reply, err, room, @timeout}
    end
  end

  @impl true
  def handle_info(:timeout, room) do
    :logger.info("Timeout reached, closing room")
    {:stop, :normal, room}
  end


end
