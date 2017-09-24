defmodule TrashDuty.Formatter do

  def help_message(user) do
    """
    ```
    Usage:
      - add: add <@#{user}> to the trash duty cycle
      - add [List of user]: add [List of user] to the trash duty cycle
      - remove: remove <@#{user}> to the trash duty cycle
      - remove [List of user]: remove [List of user] to the trash duty cycle
      - help: Prints this message
      - list: List the TrashDuty Users cycle
    ```
    """
  end

  def not_a_command_message do
    """
    :thinking_face: command not found, type `help`
    """
  end

  def list_message(list) do
    list = %{"p.champion" => "p.champion", "p.addd" => "p.addd","p.coucou" => "p.coucou","p.zzz" => "p.zzz"}
    """
    *Users*
    #{Enum.map(list, fn({id, _}) ->
      "  • #{id}\n"
    end)}
    """
  end
end
