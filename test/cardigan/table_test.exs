defmodule Cardigan.TableTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, game} = Cardigan.GameStore.get("standard_deck.json")
    table = start_supervised!({Cardigan.Table, {"some_id", game}})
    %{table: table}
  end

  test "get_game", %{table: table} do
    assert %Cardigan.Game{name: "Standard deck"} = Cardigan.Table.get_game(table)
  end

  test "get_id", %{table: table} do
    id = Cardigan.Table.get_id(table)
    assert is_binary(id)
  end

  @tag capture_log: true
  test "broken modifier doesn't crash the table", %{table: table} do
    args = []
    {:error, :server_error} = GenServer.call(table, {:modifier, :no_such_game_function, args})
    assert Process.alive?(table)
  end

  # I don't mind not testing the client side API for the modifiers:
  # 1. These will be called a lot, so should be quite OK.
  # 2. If something is broken it will crash the clients (the liveview). No much harm done.
end
