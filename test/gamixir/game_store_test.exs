defmodule Gamixir.GameStoreTest do
  use ExUnit.Case, async: true

  test "get" do
    assert {:ok, game} = Gamixir.GameStore.get("standard_deck")
    assert game.name == "standard deck"
    assert length(game.decks) == 1
    assert game.decks |> hd |> Map.get(:cards) |> length == 52
  end
end
