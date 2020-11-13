defmodule PlanningPokerWeb.PageLive do
  use PlanningPokerWeb, :live_view

  @impl true
  def render(assigns) do
    Phoenix.View.render(PlanningPokerWeb.PageView, "homepage.html", assigns)
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, room_err: nil, errors: [])}
  end

  @impl true
  def handle_event("save", %{"join" => %{"room_id" => room_id}}, socket) do
    IO.puts("received form submit")
    # IO.inspect(payload)
    if is_room_valid(room_id) do
      {:noreply, push_redirect(socket, to: Routes.room_path(socket, :index, room_id))}
    else
      {:noreply, assign(socket, errors: [room_id: "Room can't be empty"])}
    end

  end

  @impl true
  def handle_event("validate", %{"join" => %{"room_id" => room_id}}, socket) do
    IO.puts("received form submit")
    # IO.inspect(payload)

    if !is_room_valid(room_id) do
      {:noreply, assign(socket, errors: [room_id: "Room can't be empty"])}
    else
      {:noreply, assign(socket, errors: [])}
    end
  end

  defp is_room_valid(room_id) do
    room_id
    |> String.trim()
    |> String.length()
    |> Kernel.!=(0)

  end

  # @impl true
  # def handle_event("suggest", %{"q" => query}, socket) do
  #   {:noreply, assign(socket, results: search(query), query: query)}
  # end

  # @impl true
  # def handle_event("search", %{"q" => query}, socket) do
  #   case search(query) do
  #     %{^query => vsn} ->
  #       {:noreply, redirect(socket, external: "https://hexdocs.pm/#{query}/#{vsn}")}

  #     _ ->
  #       {:noreply,
  #        socket
  #        |> put_flash(:error, "No dependencies found matching \"#{query}\"")
  #        |> assign(results: %{}, query: query)}
  #   end
  # end

  # defp search(query) do
  #   if not PlanningPokerWeb.Endpoint.config(:code_reloader) do
  #     raise "action disabled when not in development"
  #   end

  #   for {app, desc, vsn} <- Application.started_applications(),
  #       app = to_string(app),
  #       String.starts_with?(app, query) and not List.starts_with?(desc, ~c"ERTS"),
  #       into: %{},
  #       do: {app, vsn}
  # end
end
