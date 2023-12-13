defmodule Cardigan.Card do
  defstruct id: nil,
            text: nil,
            tooltip: nil,
            style: %{},
            front_style: %{},
            back_style: %{},
            face: false

  def flip(%__MODULE__{face: face} = card), do: Map.put(card, :face, not face)
end
