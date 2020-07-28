defmodule Cardigan.GameStoreTest do
  use ExUnit.Case, async: true

  test "get" do
    assert {:ok, game} = Cardigan.GameStore.get("standard_deck.json")
    assert game.name == "Standard deck"
    assert length(game.decks) == 1
    assert game.decks |> hd |> Map.get(:cards) |> length == 52
  end
end
