defmodule Gamixir.Card do
  defstruct id: nil,
            text: nil,
            text_color: "black",
            front_background_color: "white",
            back_background_color: "black",
            face: false

  def flip(%__MODUE__{face: face} = card), do: Map.put(card, :face, not face)
end
