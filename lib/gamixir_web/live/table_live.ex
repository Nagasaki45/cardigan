defmodule GamixirWeb.TableLive do
  use GamixirWeb, :live_view

  @impl true
  def mount(%{"table_id" => table_id} = params, _session, socket) do
    {:ok, table} = Gamixir.TableManager.lookup(table_id)

    if connected?(socket), do: Gamixir.Table.subscribe(table_id)

    socket
    |> assign(:table, table)
    |> assign(:table_url, Routes.table_url(GamixirWeb.Endpoint, :show, table_id))
    |> assign(:game, Gamixir.Table.get_game(table))
    |> assign(:hand_id, Map.get(params, "hand_id"))
    |> (fn socket -> {:ok, socket} end).()
  end

  @impl true
  def handle_event("submit", %{"hand" => %{"id" => hand_id}}, socket) do
    {:ok, _} = Gamixir.Table.join(socket.assigns.table, hand_id)
    table_id = Gamixir.Table.get_id(socket.assigns.table)
    {:noreply, push_redirect(socket, to: Routes.table_path(socket, :show, table_id, hand_id))}
  end

  @impl true
  def handle_event("start", _params, socket) do
    {:ok, _} = Gamixir.Table.start(socket.assigns.table)
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "move",
        %{
          "from_is" => from_is,
          "from_id" => from_id,
          "card_id" => card_id,
          "to_is" => "play_area",
          "x" => x,
          "y" => y
        },
        socket
      ) do
    from_is = String.to_existing_atom(from_is)
    {:ok, _} = Gamixir.Table.move(socket.assigns.table, from_is, from_id, card_id, [x, y])
    {:noreply, socket}
  end

  def handle_event(
        "move",
        %{
          "from_is" => from_is,
          "from_id" => from_id,
          "to_is" => to_is,
          "to_id" => to_id,
          "card_id" => card_id
        },
        socket
      ) do
    from_is = String.to_existing_atom(from_is)
    to_is = String.to_existing_atom(to_is)
    {:ok, _} = Gamixir.Table.move(socket.assigns.table, from_is, from_id, card_id, to_is, to_id)
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "key",
        %{
          "key" => "f",
          "from_is" => from_is,
          "from_id" => from_id,
          "card_id" => card_id
        },
        socket
      ) do
    from_is = String.to_existing_atom(from_is)
    {:ok, _} = Gamixir.Table.flip(socket.assigns.table, from_is, from_id, card_id)
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "key",
        %{
          "key" => "p",
          "from_is" => "decks",
          "from_id" => deck_id,
          "card_id" => card_id
        },
        socket
      ) do
    {:ok, _} = Gamixir.Table.move(socket.assigns.table, :decks, deck_id, card_id, :hands, socket.assigns.hand_id)
    {:noreply, socket}
  end

  @impl true
  def handle_event(
    "key",
    %{
      "key" => "s",
      "from_is" => "decks",
      "from_id" => deck_id,
    },
    socket
  ) do
    {:ok, _} = Gamixir.Table.shuffle(socket.assigns.table, :decks, deck_id)
    {:noreply, socket}
  end

  @impl true
  def handle_event("key", _args, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info(:table_updated, socket) do
    socket = assign(socket, :game, Gamixir.Table.get_game(socket.assigns.table))
    {:noreply, socket}
  end
end
