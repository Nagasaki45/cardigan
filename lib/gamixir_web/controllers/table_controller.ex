defmodule GamixirWeb.TableController do
  use GamixirWeb, :controller

  def new(conn, _params) do
    conn
    |> assign(:games, Gamixir.GameStore.list_names())
    |> assign(:csrf_token, get_csrf_token())
    |> render("new.html")
  end

  def create(conn, %{"game" => game_name}) do
    {:ok, game} = Gamixir.GameStore.get(game_name)
    {:ok, id} = Gamixir.TableManager.new(game)
    redirect(conn, to: Routes.table_path(conn, :show, id))
  end
end
