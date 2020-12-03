defmodule PlanningPokerWeb.RoomLive.UserFormComponent do
  use PlanningPokerWeb, :live_component

  @impl true
  @spec render(map) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    assigns = Map.put_new(assigns, :user_input, "")
    ~L"""
    <div class="w-full flex justify-center items-center">
    <%= f = form_for :join, "#", [phx_submit: :save, phx_target: @myself,  class: "w-1/2 flex flex-col"]  %>
    <div class="flex border-b border-blue-500 py-1">
        <%= text_input f, :user_name, placeholder: "Name", value: @user_input,
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
    IO.puts("user form submit")
    # IO.inspect(payload)

    if is_username_valid(user_name) do
      case PlanningPoker.Room.add_participant(room_id, user_name) do
        {:ok, particpant} ->
          send(self(), {:joined, particpant})
          {:noreply, assign(socket, errors: [], user_input: "")}
        {:error, :name_taken} -> {:noreply, assign(socket, user_input: user_name, errors: [user_name: "Name already taken"])}
      end
    else
      {:noreply, assign(socket, errors: [user_name: "Name can't be blank"])}
    end
  end

  defp is_username_valid(user_name) do
    user_name
    |> String.trim()
    |> String.length()
    |> Kernel.>(0)
  end

end
