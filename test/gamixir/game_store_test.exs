defmodule Gamixir.GameStoreTest do
  use ExUnit.Case, async: true

  test "get" do
    assert {:ok, game} = Gamixir.GameStore.get("one_card")
    assert game.name == "one_card"
    assert length(game.decks) == 1
    assert game.decks |> hd |> Map.get(:cards) |> length == 1
    assert game.decks |> hd |> Map.get(:cards) |> hd |> Map.get(:id) == "c1"
  end
end
