defmodule TrashDuty.Cycle do

  require Logger

  def empty(), do: %{}

  def add_user(users, %{"members" => profiles_available}, changes) do

    ok_profiles = profiles_available
    |> Enum.filter( fn(profile) -> Enum.member?(users, profile["id"]) end)

    add_user_loop(ok_profiles, changes)
  end

  def add_user_loop([user | tail], changes) do
    add_user_loop(tail, changes)
    add_user(user, changes)
  end

  def add_user_loop([], changes), do: changes

  def add_user(%{"id" => id, "profile" => %{"email" => email}}, changes) do
    Map.put_new(changes, id, email)
  end

  def remove_user(users_list, current_cycle) do
    Map.drop(current_cycle, users_list)
  end

  def add_user(user, changes) do
    Logger.warn("User not complete (maybe a bot) #{inspect(user["real_name"])}")
    changes
  end

end
