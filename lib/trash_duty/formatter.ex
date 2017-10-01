defmodule TrashDuty.Formatter do

  def help_message(user) do
    """
    *Usage*:
      - `add` -> add yourself to the list
      - `add [List of user]` ->  add multiple user
      - `remove`
      - `remove [List of user]`
      - `help`: Prints this message
      - `list`: List the cuurent users added
    """
  end

  def not_a_command_message do
    """
    :thinking_face: command not found, type `help`
    """
  end

  def list_message([]) do
    "*No User* :sweat_smile:"
  end

  def list_message(list) do
    """
    *Users*
    #{Enum.map(list, fn({id, _}) ->
      "  • <@#{id}>\n"
    end)}
    """
  end

end
