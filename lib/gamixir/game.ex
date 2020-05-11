defmodule Gamixir.Game do
  alias Gamixir.{Deck, Card}

  @behaviour Access

  defstruct name: nil,
            min_num_of_players: 1,
            max_num_of_players: 20,
            metadata: nil,
            decks: [],
            hands: [],
            started: false

  # Implementing the Access behaviour by delegating to Map
  defdelegate fetch(data, key), to: Map
  defdelegate get_and_update(data, key, fun), to: Map
  defdelegate pop(data, key), to: Map

  @doc """
  Is the game ready to start?
  """
  def startable?(game) do
    n = length(game.hands)
    not game.started and n >= game.min_num_of_players and n <= game.max_num_of_players
  end

  @doc """
  Join a yet to start game, by hand id.
  """
  def join(_, ""), do: {:error, :argument_error}

  def join(%__MODULE__{started: false} = game, hand_id) do
    if length(game.hands) < game.max_num_of_players do
      if Enum.find(game.hands, &(&1.id == hand_id)) do
        {:error, :not_unique}
      else
        hand = %Deck{id: hand_id}
        {:ok, update_in(game.hands, &[hand | &1])}
      end
    else
      {:error, :table_full}
    end
  end

  @doc """
  Start the game.
  """
  def start(%__MODULE__{started: true}), do: {:error, :already_started}

  def start(%__MODULE__{hands: hands, min_num_of_players: n}) when length(hands) < n do
    {:error, :not_enough_players}
  end

  def start(game) do
    game = update_in(game.hands, &Enum.shuffle/1)
    {:ok, Map.put(game, :started, true)}
  end

  @doc """
  Move a card from a deck/hand to a new deck by position.
  """
  def move(game, from_is, from_id, card_id, pos) when is_list(pos) do
    case pop_from(game, from_is, from_id, card_id) do
      {:error, reason} ->
        {:error, reason}

      {:ok, card, game} ->
        game
        |> place([card], pos)
        |> drop_empty_decks()
        |> ok()
    end
  end

  @doc """
  Move entire deck/hand to another deck/hand.
  """
  def move(game, from_is, from_id, to_is, to_id) do
    case get_and_update_in(game, [from_is, id_access(from_id)], fn d ->
           {d.cards, %{d | cards: []}}
         end) do
      {[], _} ->
        {:error, :not_found}

      {[cards], game} ->
        case get_in(game, [to_is, id_access(to_id)]) do
          [] ->
            {:error, :not_found}

          _ ->
            game
            |> update_in([to_is, id_access(to_id)], &Deck.put_cards(&1, cards))
            |> drop_empty_decks()
            |> ok()
        end
    end
  end

  @doc """
  Move a card from a deck/hand to another deck/hand.
  """
  def move(game, from_is, from_id, card_id, to_is, to_id) do
    case get_in(game, [to_is, id_access(to_id)]) do
      [] ->
        {:error, :not_found}

      _ ->
        case pop_from(game, from_is, from_id, card_id) do
          {:error, reason} ->
            {:error, reason}

          {:ok, card, game} ->
            card =
              case to_is do
                :hands -> Map.put(card, :face, true)
                :decks -> card
              end

            game
            |> update_in([to_is, id_access(to_id)], &Deck.put(&1, card))
            |> drop_empty_decks()
            |> ok()
        end
    end
  end

  @doc """
  Move entire deck to a new deck by position.
  """
  def move(game, :decks, deck_id, pos) when is_list(pos) do
    case get_in(game, [:decks, id_access(deck_id)]) do
      [] -> {:error, :not_found}
      _ -> {:ok, update_in(game, [:decks, id_access(deck_id)], &Map.put(&1, :pos, pos))}
    end
  end

  @doc """
  Move entire hand to a new deck by position.
  """
  def move(game, :hands, hand_id, pos) when is_list(pos) do
    case get_and_update_in(game, [:hands, id_access(hand_id)], fn hand ->
           {hand.cards, %{hand | cards: []}}
         end) do
      {[], _} ->
        {:error, :not_found}

      {[cards], game} ->
        game
        |> place(cards, pos)
        |> ok()
    end
  end

  @doc """
  Flip a card in deck/hand.
  """
  def flip(game, where, where_id, card_id) when where in [:decks, :hands] do
    game
    |> update_in([where, id_access(where_id), :cards, id_access(card_id)], &Card.flip/1)
    |> ok()
  end

  @doc """
  Shuffle a deck/hand.
  """
  def shuffle(game, where, where_id) do
    {:ok, update_in(game, [where, id_access(where_id)], &Deck.shuffle/1)}
  end

  @doc """
  Toggle a deck display mode between stack and fan.
  """
  def toggle_deck_display_mode(game, where, where_id) do
    game
    |> update_in([where, id_access(where_id)], &Deck.toggle_display_mode/1)
    |> ok()
  end

  @doc """
  Set all cards in deck to face up.
  """
  def deck_up(game, where, where_id) do
    face = true
    deck_side(game, where, where_id, face)
  end

  @doc """
  Set all cards in deck to face down.
  """
  def deck_down(game, where, where_id) do
    face = false
    deck_side(game, where, where_id, face)
  end

  # Internals

  defp ok(x), do: {:ok, x}

  defp pop_from(game, where, where_id, card_id) do
    case get_and_update_in(game, [where, id_access(where_id)], &Deck.pop_card(&1, card_id)) do
      # When there's no such hand
      {[], _} ->
        {:error, :not_found}

      # When there's no such card
      {[nil], _} ->
        {:error, :not_found}

      {[%Card{} = card], game} ->
        {:ok, card, game}
    end
  end

  defp place(game, cards, pos) do
    deck = %Deck{id: Gamixir.Random.id(8), pos: pos, cards: cards}
    update_in(game.decks, &[deck | &1])
  end

  defp id_access(id) do
    Access.filter(&(&1.id == id))
  end

  defp drop_empty_decks(game) do
    update_in(game.decks, fn decks ->
      Enum.filter(decks, fn d -> not Enum.empty?(d.cards) end)
    end)
  end

  defp deck_side(game, where, where_id, face) do
    game
    |> update_in([where, id_access(where_id)], &Deck.side(&1, face))
    |> ok()
  end
end
