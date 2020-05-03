defmodule Gamixir.TableManager do
  def new(game) do
    id = Gamixir.Random.id(8)

    child_spec = %{
      id: Gamixir.Table,
      start:
        {Gamixir.Table, :start_link,
         [{id, game}, [name: {:via, Registry, {Gamixir.TableRegistry, id}}]]}
    }

    {:ok, _pid} = DynamicSupervisor.start_child(Gamixir.TableSupervisor, child_spec)
    {:ok, id}
  end

  def lookup(id) do
    case Registry.lookup(Gamixir.TableRegistry, id) do
      [{pid, _}] -> {:ok, pid}
      [] -> {:error, :not_found}
    end
  end
end
