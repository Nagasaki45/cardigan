defmodule CardiganWeb.TableController do
  use CardiganWeb, :controller

  def new(conn, _params) do
    conn
    |> assign(:games, Cardigan.GameStore.list())
    |> assign(:csrf_token, get_csrf_token())
    |> render("new.html")
  end

  def create(conn, %{"file" => %Plug.Upload{path: path}}) do
    {:ok, game} = Cardigan.GameStore.parse(path)
    do_create(conn, game)
  end

  def create(conn, %{"game" => game_name}) do
    {:ok, game} = Cardigan.GameStore.get_by_name(game_name)
    do_create(conn, game)
  end

  defp do_create(conn, game) do
    {:ok, id} = Cardigan.TableManager.new(game)
    redirect(conn, to: Routes.table_path(conn, :show, id))
  end
end
