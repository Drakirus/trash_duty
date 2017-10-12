defmodule TrashDuty.Formatter do


  def help_message() do
    """
    *Usage*:
      - `add` -> add yourself to the list
      - `add [List of user]` ->  add multiple user
      - `remove`
      - `remove [List of user]`
      - `help`: Prints this message
      - `list`: List the cuurent users added
      - `skip`: skip to the next 'take the trash out' user
    """
  end

  def notify_trash_out_msg() do
    """
    :grey_exclamation: it's your turn to `take the trash out` :poop:
    """
  end

  def not_a_command_message do
    """
    :thinking_face: command not found, type `help`
    """
  end

  def list_message([list, current]) do
    if Enum.empty?(list) do
      "*No User* :sweat_smile:"
    else
      """
      *Users*
      #{
        list
        |> Enum.map(
          fn({id, email}) ->
            [email, id]
          end
        )
        |> Enum.sort(&TrashDuty.Cycle.cmp_email(hd(&1), hd(&2)))
        |> Enum.map(
          fn([_, id]) ->
            "  • #{format_user(id)} #{if id == current, do: ":poop:"}\n"
          end
        )
      }
      """
    end
  end

  def inline_list_user(users) do
    Enum.map_join(users, ", ", fn(user) -> "#{format_user(user)}"end)

  end

  def nothing_change_message() do
    ":thinking_face: nothing changes"
  end

  def format_user(user) do
    "<@#{user}>"
  end

end
