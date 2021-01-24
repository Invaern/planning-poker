defmodule PlanningPokerWeb.RoomLive.UserFormComponent do
  use PlanningPokerWeb, :live_component

  @max_name_length 15

  @impl true
  def render(assigns) do
    assigns = assigns
    |> Map.put_new(:user_input, "")
    |> Map.put_new(:max_len, @max_name_length)
    ~L"""
    <div class="w-full flex justify-center items-center">
    <%= f = form_for :join, "#", [phx_submit: :save, phx_change: :validate, phx_target: @myself,  class: "w-1/3 flex flex-col"]  %>
    <div class="flex border-b border-blue-500 py-1">
        <%= text_input f, :user_name, placeholder: "Name", value: @user_input,
            "phx-debounce": "200",
            "phx-hook": "NotBlank",
            maxlength: @max_len,
            class: "appearance-none w-full py-2 px-3 bg-gray-50 text-gray-700 leading-tight focus:outline-none"  %>
        <%= hidden_input f, :room_id, value: @room_id %>
        <%= submit "enter", class: "transition-colors bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded" %>
    </div>
        <%= error_tag f, @errors, :user_name %>
    </form>
    </div>
    """
  end


  @impl true
  def handle_event("save", %{"join" => %{"user_name" => user_name, "room_id" => room_id}}, socket) do
    with {:ok, valid_name} <- PlanningPoker.Validation.validate_string(user_name, max_len: @max_name_length),
         {:ok, participant} <- PlanningPoker.Room.add_participant(room_id, valid_name)
    do
      send(self(), {:joined, participant})
      {:noreply, assign(socket, errors: [], user_input: "")}
    else
      {:error, :blank} ->
        {:noreply, assign(socket, errors: [user_name: "Name can't be blank"],
                                  user_input: user_name)}
      {:error, :too_long} ->
        {:noreply, assign(socket, errors: [user_name: "Name can't be be longer than 15 characters"],
                                  user_input: user_name)}
      {:error, :name_taken} ->
        {:noreply, assign(socket, errors: [user_name: "Name already taken"],
                                  user_input: user_name)}
    end
  end

  @impl true
  def handle_event("validate", %{"join" => %{"user_name" => user_name}}, socket) do
    with {:ok, valid_name} <- PlanningPoker.Validation.validate_string(user_name, max_len: @max_name_length)
    do
      {:noreply, assign(socket, errors: [], user_input: valid_name)}
    else
      {:error, :blank} ->
        {:noreply, assign(socket, errors: [user_name: "Name can't be blank"],
                                  user_input: user_name)}
      {:error, :too_long} ->
        {:noreply, assign(socket, errors: [user_name: "Name can't be be longer than #{@max_name_length} characters"],
                                  user_input: user_name)}
    end
  end


end
