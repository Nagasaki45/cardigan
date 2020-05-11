defmodule Gamixir.GameStore do
  def list() do
    games_dir()
    |> File.ls!()
    |> Enum.map(&get!/1)
  end

  def get_by_name(game_name) do
    game_name
    |> String.replace(" ", "_")
    |> String.downcase()
    |> (fn x -> x <> ".json" end).()
    |> get()
  end

  def get(game_json) do
    games_dir()
    |> Path.join(game_json)
    |> parse()
  end

  def get!(game_json) do
    {:ok, game} = get(game_json)
    game
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
