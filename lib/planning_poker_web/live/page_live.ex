defmodule PlanningPokerWeb.PageLive do
  use PlanningPokerWeb, :live_view

  @max_room_length Room.max_id_len()

  @impl true
  def render(assigns) do
    assigns = Map.put_new(assigns, :max_len, @max_room_length)
    Phoenix.View.render(PlanningPokerWeb.PageView, "homepage.html", assigns)
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, room_err: nil, errors: [])}
  end

  @impl true
  def handle_event("save", %{"join" => %{"room_id" => room_id}}, socket) do
    with {:ok, valid_room_id} <- PlanningPoker.Validation.validate_string(room_id, max_len: @max_room_length)
    do
      {:noreply, push_redirect(socket, to: Routes.room_path(socket, :index, valid_room_id))}
    else
      {:erorr, :blank} -> {:noreply, assign(socket, errors: [room_id: "Room can't be empty"])}
      {:error, :too_long} -> {:noreply, assign(socket, errors: [room_id: "Room can't be longer than #{@max_room_length} characterrs"])}
    end
  end

  @impl true
  def handle_event("validate", %{"join" => %{"room_id" => room_id}}, socket) do
    with {:ok, _valid_room_id} <- PlanningPoker.Validation.validate_string(room_id, max_len: @max_room_length)
    do
      {:noreply, assign(socket, errors: [])}
    else
      {:error, :blank} -> {:noreply, assign(socket, errors: [room_id: "Room can't be empty"])}
      {:error, :too_long} -> {:noreply, assign(socket, errors: [room_id: "Room can't be longer than #{@max_room_length} characterrs"])}
    end
  end


end
