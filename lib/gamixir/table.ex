defmodule Gamixir.Table do
  use GenServer, restart: :temporary

  @timer 24 * 60 * 60 * 1000

  # Public API

  @doc """
  Start a new table.
  """
  def start_link(state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def subscribe(id) do
    Phoenix.PubSub.subscribe(Gamixir.PubSub, id)
  end

  def get_id(pid) do
    GenServer.call(pid, {:get_id})
  end

  def get_game(pid) do
    GenServer.call(pid, {:get_game})
  end

  def join(pid, hand_id) do
    GenServer.call(pid, {:modifier, :join, [hand_id]})
  end

  def start(pid) do
    GenServer.call(pid, {:modifier, :start})
  end

  def move(pid, from_is, from_id, card_id, pos) do
    GenServer.call(pid, {:modifier, :move, [from_is, from_id, card_id, pos]})
  end

  def move(pid, from_is, from_id, card_id, to_is, to_id) do
    GenServer.call(pid, {:modifier, :move, [from_is, from_id, card_id, to_is, to_id]})
  end

  def flip(pid, where, where_id, card_id) do
    GenServer.call(pid, {:modifier, :flip, [where, where_id, card_id]})
  end

  def shuffle(pid, where, where_id) do
    GenServer.call(pid, {:modifier, :shuffle, [where, where_id]})
  end

  # GenServer Callbacks

  @impl true
  def init({id, %Gamixir.Game{} = game}) when is_binary(id) do
    Process.send_after(self(), :game_timeout, @timer)
    {:ok, {id, game}}
  end

  @impl true
  def handle_info(:game_timeout, state) do
    {:stop, :normal, state}
  end

  @impl true
  def handle_call({:get_id}, _from, {id, _} = state) do
    {:reply, id, state}
  end

  @impl true
  def handle_call({:get_game}, _from, {_, game} = state) do
    {:reply, game, state}
  end

  @impl true
  def handle_call({:modifier, func}, _from, state) do
    do_modification(func, [], state)
  end

  @impl true
  def handle_call({:modifier, func, args}, _from, state) do
    do_modification(func, args, state)
  end

  defp do_modification(func, args, {id, game}) do
    case apply(Gamixir.Game, func, [game | args]) do
      {:ok, game} ->
        Phoenix.PubSub.broadcast(Gamixir.PubSub, id, :table_updated)
        {:reply, {:ok, :success}, {id, game}}

      {:error, reason} ->
        {:reply, {:error, reason}, {id, game}}
    end
  end
end
