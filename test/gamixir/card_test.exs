defmodule Gamixir.CardTest do
  use ExUnit.Case, async: true

  test "flip" do
    card = %Gamixir.Card{face: false}
    card = Gamixir.Card.flip(card)
    assert card.face == true
  end
end
