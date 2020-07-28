defmodule Cardigan.CardTest do
  use ExUnit.Case, async: true

  test "flip" do
    card = %Cardigan.Card{face: false}
    card = Cardigan.Card.flip(card)
    assert card.face == true
  end
end
