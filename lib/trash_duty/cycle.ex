defmodule TrashDuty.Cycle do

  require Logger

  @spec empty() :: [%{} | <<>>]
  def empty(), do: [%{}, ""]
  # default data type

  @spec add_users([String], %{required(String) => %{}}, %{} ) :: %{}
  def add_users(users, %{"members" => profiles_available}, current_users) do

    # find the user profile in `profiles_available` to get data from id to email and more
    ok_profiles = profiles_available
    |> Enum.filter( fn(profile) -> Enum.member?(users, profile["id"]) end)

    add_user_loop(ok_profiles, current_users)
  end

  @spec add_user(%{}, %{}) :: %{}
  def add_user(%{"id" => id, "profile" => %{"email" => email}}, current_users) do
    # add a user in a map
    Map.put_new(current_users, id, email)
  end

  def add_user(user, current_users) do
    Logger.warn("User not complete (maybe a bot) #{inspect(user["real_name"])}")
    current_users
  end

  @spec add_user_loop([String.t], %{}) :: %{}
  def add_user_loop([user | tail], current_users) do
    # TODO use Enum.into/3
    # adding user in map
    changes = add_user_loop(tail, current_users)
    add_user(user, changes)
  end

  def add_user_loop([], current_users), do: current_users

  @spec remove_user([%{}], %{}) :: %{}
  def remove_user(users_list, current_cycle) do
    # delete a user from a map
    Map.drop(current_cycle, users_list)
  end

  def next_on_list([users_list, current]) do

    # find the current user in the user_list map
    current = Map.get(users_list, current)

    # from a map of %{"JKLJK" => "email@email.com"} get only a array of email sorted
    sorted_user = get_email_sorted(users_list)

    # get the current user id
    index_current = Enum.find_index(sorted_user, fn(user) -> current == user end)

    # get the next usr id
    next_email = Enum.at(sorted_user, rem((index_current + 1), length(sorted_user)) )

    # get the first next user on the list
    List.first Enum.filter(users_list, fn {_id, user_email} -> user_email == next_email end)
  end

  @spec get_email_sorted(%{required(String.t) => String.t}) :: [String.t]
  def get_email_sorted(users_list) do
    users_list
    |> Map.values
    |> Enum.sort(&cmp_email(&1, &2))
  end

  @spec cmp_email(String.t, String.t) :: boolean()
  def cmp_email(email1, email2) do
    # skip the first 2 char of email (p.champion@edialog.fr)
    String.slice(email1, 2..-1) < String.slice(email2, 2..-1)
  end

end
