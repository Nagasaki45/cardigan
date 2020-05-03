defmodule Gamixir.Random do
  def id(size) do
    alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    numbers = "0123456789"
    vals = (alphabets <> String.downcase(alphabets) <> numbers) |> String.split("")

    1..size
    |> Enum.map(fn _ -> Enum.random(vals) end)
    |> Enum.join("")
  end
end
