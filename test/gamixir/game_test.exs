defmodule Gamixir.GameTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, game} = Gamixir.GameStore.get("one_card")
    %{game: game}
  end

  test "join", %{game: game} do
    # max_num_of_players == 2
    assert {:ok, game} = Gamixir.Game.join(game, "John")
    assert {:ok, game} = Gamixir.Game.join(game, "Jane")
    assert {:error, :table_full} = Gamixir.Game.join(game, "Jack")
  end

  test "move from deck to pos", %{game: game} do
    assert {:ok, game} = Gamixir.Game.move(game, :decks, "d1", "c1", [200, 200])

    assert [%{id: new_deck_id}] = game.decks
    assert new_deck_id != "d1"

    deck = Gamixir.Game.get_deck(game, new_deck_id)
    assert deck.pos == [200, 200]
    assert "c1" in Gamixir.Deck.get_cards(deck)
  end

  test "flip", %{game: game} do
    assert (Gamixir.Game.get_deck(game, "d1") |> Gamixir.Deck.get_card("c1")).face == false
    assert {:ok, game} = Gamixir.Game.flip(game, :decks, "d1", "c1")
    assert (Gamixir.Game.get_deck(game, "d1") |> Gamixir.Deck.get_card("c1")).face == true
  end
end
