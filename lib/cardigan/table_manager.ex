defmodule Cardigan.TableManager do
  def new(game) do
    id = Cardigan.Random.id(8)

    child_spec = %{
      id: Cardigan.Table,
      start:
        {Cardigan.Table, :start_link,
         [{id, game}, [name: {:via, Registry, {Cardigan.TableRegistry, id}}]]}
    }

    {:ok, _pid} = DynamicSupervisor.start_child(Cardigan.TableSupervisor, child_spec)
    {:ok, id}
  end

  def lookup(id) do
    case Registry.lookup(Cardigan.TableRegistry, id) do
      [{pid, _}] -> {:ok, pid}
      [] -> {:error, :not_found}
    end
  end
end
