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

    assert [%{id: new_deck_id} = new_deck] = game.decks
    assert new_deck_id != "d1"

    assert new_deck.pos == [200, 200]
    assert "c1" in Gamixir.Deck.get_cards(new_deck)
  end

  test "flip", %{game: game} do
    assert %{decks: [%{id: "d1", cards: [%{id: "c1", face: false}]}]} = game
    assert {:ok, game} = Gamixir.Game.flip(game, :decks, "d1", "c1")
    assert %{decks: [%{id: "d1", cards: [%{id: "c1", face: true}]}]} = game
  end
end
