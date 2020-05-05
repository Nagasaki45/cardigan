defmodule Gamixir.GameStore do
  def list_names() do
    games_dir()
    |> File.ls!()
    |> Enum.map(fn s -> s |> String.replace(".json", "") end)
  end

  def get(game_name) do
    games_dir()
    |> Path.join(game_name <> ".json")
    |> parse()
  end

  defp games_dir() do
    Application.app_dir(:gamixir, ["priv", "games"])
  end

  def parse(filepath) do
    structure = %Gamixir.Game{decks: [%Gamixir.Deck{cards: [%Gamixir.Card{}]}]}

    with {:ok, content} <- File.read(filepath),
         {:ok, decoded} <- Poison.decode(content, as: structure),
         do: {:ok, decoded}
  end
end
