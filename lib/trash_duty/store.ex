defmodule TrashDuty.Store do

  use GenServer

  @db_file :trash_cycle_db

  def start_link(cycle), do: GenServer.start_link(__MODULE__, cycle, name: __MODULE__)

  def get, do: GenServer.call __MODULE__, :get

  def set(new_cycle), do: GenServer.cast __MODULE__, {:set, new_cycle}

  def init(initial_cycle) do
    {:ok, table} = :dets.open_file(@db_file, [type: :set])
    cycle = case :dets.lookup(table, :cycle) do
      [cycle: found_cycle] -> found_cycle
      [] -> initial_cycle
    end

    {:ok, cycle}
  end

  def handle_call(:get, _from, state), do: {:reply, state, state}

  def handle_cast({:set, new_cycle}, _current_cycle) do
    :dets.insert(@db_file, {:cycle, new_cycle})
    :dets.sync(@db_file)
    {:noreply, new_cycle}
  end

  def terminate(_reason, _state) do
    :dets.close(@db_file)
  end
end
