defmodule Gamixir.Table do
  require Logger

  use GenServer, restart: :temporary

  @timer 24 * 60 * 60 * 1000

  # Public API

  @doc """
  Start a new table with `id` and `game`.
  """
  def start_link({id, %Gamixir.Game{} = game}, opts \\ []) when is_binary(id) do
    GenServer.start_link(__MODULE__, {id, game}, opts)
  end

  @doc """
  Subscribe to update from the table by `id`.
  """
  def subscribe(id) do
    Phoenix.PubSub.subscribe(Gamixir.PubSub, id)
  end

  @doc """
  Get the table id.
  """
  def get_id(pid) do
    GenServer.call(pid, {:get_id})
  end

  @doc """
  Get the game.
  """
  def get_game(pid) do
    GenServer.call(pid, {:get_game})
  end

  # Modifiers mimic `Gamixir.Game` functions.

  def join(pid, hand_id) do
    GenServer.call(pid, {:modifier, :join, [hand_id]})
  end

  def start(pid) do
    GenServer.call(pid, {:modifier, :start, []})
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
  def init(state) do
    Process.send_after(self(), :game_timeout, @timer)
    {:ok, state}
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
  def handle_call({:modifier, func, args}, _from, {id, game}) do
    try do
      apply(Gamixir.Game, func, [game | args])
    rescue
      e ->
        Logger.error("#{inspect e}")
      {:error, :server_error}
    end
    |> case do
         {:ok, game} ->
           Phoenix.PubSub.broadcast(Gamixir.PubSub, id, :table_updated)
           {:reply, {:ok, :success}, {id, game}}

         {:error, reason} ->
           {:reply, {:error, reason}, {id, game}}
       end
  end
end
