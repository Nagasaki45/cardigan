defmodule Cardigan.GameTest do
  use ExUnit.Case, async: true

  setup do
    game = %Cardigan.Game{
      name: "one_card",
      max_num_of_players: 2,
      decks: [
        %Cardigan.Deck{
          id: "d1",
          cards: [
            %Cardigan.Card{
              id: "c1",
              text: "X"
            }
          ]
        }
      ]
    }

    %{game: game}
  end

  test "join", %{game: game} do
    # max_num_of_players == 2
    assert {:ok, game} = Cardigan.Game.join(game, "John")
    assert %{hands: [%{id: "John"}]} = game

    assert {:ok, game} = Cardigan.Game.join(game, "Jane")
    assert %{hands: [%{id: "Jane"}, %{id: "John"}]} = game

    assert {:error, :table_full} = Cardigan.Game.join(game, "Jack")
  end

  test "join fail if hand_id empty", %{game: game} do
    assert {:error, :argument_error} = Cardigan.Game.join(game, "")
  end

  test "join fail if hand_id not unique", %{game: game} do
    assert {:ok, game} = Cardigan.Game.join(game, "John")
    assert {:error, :not_unique} = Cardigan.Game.join(game, "John")
  end

  test "start", %{game: game} do
    assert {:ok, game} = Cardigan.Game.join(game, "John")
    assert {:ok, %Cardigan.Game{started: true}} = Cardigan.Game.start(game)
  end

  test "start fail if not enough players", %{game: game} do
    assert {:error, :not_enough_players} = Cardigan.Game.start(game)
  end

  test "start fail if already started", %{game: game} do
    assert {:ok, game} = Cardigan.Game.join(game, "John")
    assert {:ok, game} = Cardigan.Game.start(game)
    assert {:error, :already_started} = Cardigan.Game.start(game)
  end

  test "start shuffles the hands order", %{game: game} do
    assert {:ok, game} = Cardigan.Game.join(game, "John")
    assert {:ok, game} = Cardigan.Game.join(game, "Jane")

    permutations =
      1..10
      |> Stream.map(fn _ -> Cardigan.Game.start(game) end)
      |> Enum.map(fn {:ok, g} -> Enum.map(g.hands, & &1.id) end)

    all_equal = Enum.all?(permutations, &(&1 == hd(permutations)))
    assert not all_equal
  end

  test "move to pos", %{game: game} do
    pos = [123, 456]
    assert {:ok, game} = Cardigan.Game.move(game, :decks, "d1", "c1", pos)

    assert [%{id: new_deck_id, pos: ^pos, cards: [%{id: "c1"}]}] = game.decks
    assert new_deck_id != "d1"
  end

  test "move fail if no deck", %{game: game} do
    pos = [123, 456]
    assert {:error, :not_found} = Cardigan.Game.move(game, :decks, "xxx", "c1", pos)
  end

  test "move fail if no card", %{game: game} do
    pos = [123, 456]
    assert {:error, :not_found} = Cardigan.Game.move(game, :decks, "d1", "xxx", pos)
  end

  test "move to hand", %{game: game} do
    assert {:ok, game} = Cardigan.Game.join(game, "John")
    assert {:ok, game} = Cardigan.Game.move(game, :decks, "d1", "c1", :hands, "John")
    assert %{decks: [], hands: [%{id: "John", cards: [%{id: "c1"}]}]} = game
  end

  test "move fail if no target deck", %{game: game} do
    assert {:error, :not_found} = Cardigan.Game.move(game, :decks, "d1", "c1", :hands, "xxx")
  end

  test "move to hand put card face up", %{game: game} do
    assert {:ok, game} = Cardigan.Game.join(game, "John")
    assert {:ok, g1} = Cardigan.Game.move(game, :decks, "d1", "c1", :hands, "John")
    assert %{hands: [%{id: "John", cards: [%{id: "c1", face: true}]}]} = g1

    assert {:ok, g2} = Cardigan.Game.flip(game, :decks, "d1", "c1")
    assert {:ok, g2} = Cardigan.Game.move(g2, :decks, "d1", "c1", :hands, "John")
    assert %{hands: [%{id: "John", cards: [%{id: "c1", face: true}]}]} = g2
  end

  test "move deck to pos", %{game: game} do
    assert {:ok, game} = Cardigan.Game.move(game, :decks, "d1", [123, 456])
    assert game.decks |> hd |> Map.get(:pos) == [123, 456]
  end

  test "move deck to position fail if no deck", %{game: game} do
    assert {:error, :not_found} = Cardigan.Game.move(game, :decks, "xxx", [123, 456])
  end

  test "move deck to target deck", %{game: game} do
    another_deck = %Cardigan.Deck{id: "d2", cards: [%Cardigan.Card{id: "c2"}]}
    game = update_in(game.decks, &[another_deck | &1])
    assert {:ok, game} = Cardigan.Game.move(game, :decks, "d1", :decks, "d2")
    assert %{decks: [%{id: "d2", cards: [%{id: "c1"}, %{id: "c2"}]}]} = game
  end

  test "move deck to target hand", %{game: game} do
    assert {:ok, game} = Cardigan.Game.join(game, "John")
    assert {:ok, game} = Cardigan.Game.move(game, :decks, "d1", :hands, "John")
    assert %{decks: [], hands: [%{id: "John", cards: [%{id: "c1"}]}]} = game
  end

  test "move deck to target deck fail if no deck", %{game: game} do
    assert {:error, :not_found} = Cardigan.Game.move(game, :decks, "xxx", :decks, "d1")
  end

  test "move deck fail if no target deck", %{game: game} do
    assert {:error, :not_found} = Cardigan.Game.move(game, :decks, "d1", :decks, "xxx")
  end

  test "move hand to pos", %{game: game} do
    assert {:ok, game} = Cardigan.Game.join(game, "John")
    assert {:ok, game} = Cardigan.Game.move(game, :decks, "d1", "c1", :hands, "John")
    assert {:ok, game} = Cardigan.Game.move(game, :hands, "John", [123, 456])
  end

  test "move hand fail if no hand", %{game: game} do
    assert {:error, :not_found} = Cardigan.Game.move(game, :hands, "John", [123, 456])
  end

  test "flip", %{game: game} do
    assert %{decks: [%{id: "d1", cards: [%{id: "c1", face: false}]}]} = game
    assert {:ok, game} = Cardigan.Game.flip(game, :decks, "d1", "c1")
    assert %{decks: [%{id: "d1", cards: [%{id: "c1", face: true}]}]} = game
  end

  test "toggle deck display mode", %{game: game} do
    assert %{decks: [%{id: "d1", fan: false}]} = game
    assert {:ok, game} = Cardigan.Game.toggle_deck_display_mode(game, :decks, "d1")
    assert %{decks: [%{id: "d1", fan: true}]} = game
  end

  test "deck up and down", %{game: game} do
    assert Enum.all?(game.decks |> hd |> Map.get(:cards), &(not &1.face))
    assert {:ok, game} = Cardigan.Game.deck_up(game, :decks, "d1")
    assert Enum.all?(game.decks |> hd |> Map.get(:cards), & &1.face)

    assert {:ok, game} = Cardigan.Game.deck_down(game, :decks, "d1")
    assert Enum.all?(game.decks |> hd |> Map.get(:cards), &(not &1.face))
  end
end
