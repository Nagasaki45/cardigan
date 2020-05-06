defmodule Gamixir.Card do
  defstruct id: nil,
            text: nil,
            style: %{},
            front_style: %{},
            back_style: %{},
            face: false

  def flip(%__MODUE__{face: face} = card), do: Map.put(card, :face, not face)
end
