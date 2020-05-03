defmodule Gamixir.TableTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, game} = Gamixir.GameStore.get("one_card")
    table = start_supervised!({Gamixir.Table, {"some_id", game}})
    %{table: table}
  end

  test "get_game", %{table: table} do
    assert %Gamixir.Game{} = Gamixir.Table.get_game(table)
  end
end
