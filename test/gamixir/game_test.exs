defmodule Gamixir.GameTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, game} = Gamixir.GameStore.get("one_card")
    %{game: game}
  end

  test "join", %{game: game} do
    # max_num_of_players == 2
    assert {:ok, game} = Gamixir.Game.join(game, "John")
    assert %{hands: [%{id: "John"}]} = game

    assert {:ok, game} = Gamixir.Game.join(game, "Jane")
    assert %{hands: [%{id: "Jane"}, %{id: "John"}]} = game

    assert {:error, :table_full} = Gamixir.Game.join(game, "Jack")
  end

  test "join fail if hand_id empty", %{game: game} do
    assert {:error, :argument_error} = Gamixir.Game.join(game, "")
  end

  test "join fail if hand_id not unique", %{game: game} do
    assert {:ok, game} = Gamixir.Game.join(game, "John")
    assert {:error, :not_unique} = Gamixir.Game.join(game, "John")
  end

  test "start", %{game: game} do
    assert {:ok, game} = Gamixir.Game.join(game, "John")
    assert {:ok, %Gamixir.Game{started: true}} = Gamixir.Game.start(game)
  end

  test "start fail if not enough players", %{game: game} do
    assert {:error, :not_enough_players} = Gamixir.Game.start(game)
  end

  test "start fail if already started", %{game: game} do
    assert {:ok, game} = Gamixir.Game.join(game, "John")
    assert {:ok, game} = Gamixir.Game.start(game)
    assert {:error, :already_started} = Gamixir.Game.start(game)
  end

  test "start shuffles the hands order", %{game: game} do
    assert {:ok, game} = Gamixir.Game.join(game, "John")
    assert {:ok, game} = Gamixir.Game.join(game, "Jane")

    permutations =
      1..10
      |> Stream.map(fn _ -> Gamixir.Game.start(game) end)
      |> Enum.map(fn {:ok, g} -> Enum.map(g.hands, & &1.id) end)

    all_equal = Enum.all?(permutations, &(&1 == hd(permutations)))
    assert not all_equal
  end

  test "move to pos", %{game: game} do
    pos = [123, 456]
    assert {:ok, game} = Gamixir.Game.move(game, :decks, "d1", "c1", pos)

    assert [%{id: new_deck_id, pos: ^pos, cards: [%{id: "c1"}]}] = game.decks
    assert new_deck_id != "d1"
  end

  test "move fail if no deck", %{game: game} do
    pos = [123, 456]
    assert {:error, :not_found} = Gamixir.Game.move(game, :decks, "xxx", "c1", pos)
  end

  test "move fail if no card", %{game: game} do
    pos = [123, 456]
    assert {:error, :not_found} = Gamixir.Game.move(game, :decks, "d1", "xxx", pos)
  end

  test "move to hand", %{game: game} do
    assert {:ok, game} = Gamixir.Game.join(game, "John")
    assert {:ok, game} = Gamixir.Game.move(game, :decks, "d1", "c1", :hands, "John")
    assert %{decks: [], hands: [%{id: "John", cards: [%{id: "c1"}]}]} = game
  end

  test "move fail if no target deck", %{game: game} do
    assert {:error, :not_found} = Gamixir.Game.move(game, :decks, "d1", "c1", :hands, "xxx")
  end

  test "move to hand put card face up", %{game: game} do
    assert {:ok, game} = Gamixir.Game.join(game, "John")
    assert {:ok, g1} = Gamixir.Game.move(game, :decks, "d1", "c1", :hands, "John")
    assert %{hands: [%{id: "John", cards: [%{id: "c1", face: true}]}]} = g1

    assert {:ok, g2} = Gamixir.Game.flip(game, :decks, "d1", "c1")
    assert {:ok, g2} = Gamixir.Game.move(g2, :decks, "d1", "c1", :hands, "John")
    assert %{hands: [%{id: "John", cards: [%{id: "c1", face: true}]}]} = g2
  end

  test "flip", %{game: game} do
    assert %{decks: [%{id: "d1", cards: [%{id: "c1", face: false}]}]} = game
    assert {:ok, game} = Gamixir.Game.flip(game, :decks, "d1", "c1")
    assert %{decks: [%{id: "d1", cards: [%{id: "c1", face: true}]}]} = game
  end
end
