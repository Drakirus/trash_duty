defmodule TrashDuty.Parser do
  @user_regex ~r/<@(\w+)>/

  def parse(%{text: message, user: user}) do

    command = cond do
      message =~ ~r/^\s*(add)\s*/ -> :add
      message =~ ~r/^\s*(remove)\s*/ -> :remove
      message =~ ~r/^\s*(list)\s*$/ -> :list
      message =~ ~r/^\s*(help)\s*$/ -> :help
      message =~ ~r/^\s*(skip)\s*$/ -> :skip
      true -> :not_a_command
    end

    case provided_user(message) do
       # if not use current user for cmd
       [] -> {command, [user]}
       users -> {command, users}
    end

  end

  defp provided_user(message) do
    Regex.scan(@user_regex, message, capture: :all_but_first)
    |> List.flatten
  end

end
