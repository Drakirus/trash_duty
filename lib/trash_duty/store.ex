defmodule TrashDuty.Store do

  use GenServer

  @db_file :trash_cycle_db

  def start_link(cycle), do: GenServer.start_link(__MODULE__, cycle, name: __MODULE__)

  def get_users, do: GenServer.call __MODULE__, :get_users
  def get_next, do: GenServer.call __MODULE__, :get_next

  def get, do: GenServer.call __MODULE__, :get


  def set_users(new_cycle), do: GenServer.cast __MODULE__, {:set_users, new_cycle}

  def set_next(user), do: GenServer.cast __MODULE__, {:set_next, user}

  def init(initial_cycle) do
    {:ok, table} = :dets.open_file(@db_file, [type: :set])
    cycle = case :dets.lookup(table, :cycle) do
      [cycle: found_cycle] -> found_cycle
      [] -> initial_cycle
    end

    {:ok, cycle}
  end

  def handle_call(:get_users, _from, state), do: {:reply, hd(state), state}
  def handle_call(:get_next, _from, state), do: {:reply, List.last(state), state}

  def handle_call(:get, _from, state), do: {:reply, state, state}

  def handle_cast({:set_users, new_list}, [_old_list, current_user]) do
    data = [ new_list, current_user ]
    sync(data)
    {:noreply, data}
  end

  def handle_cast({:set_next, next}, [user_list, _old]) do
    data = [ user_list, next ]
    sync(data)
    {:noreply, data}
  end

  defp sync(data) do
    :dets.insert(@db_file, {:cycle, data})
    :dets.sync(@db_file)
  end

  def terminate(_reason, _state) do
    :dets.close(@db_file)
  end
end
