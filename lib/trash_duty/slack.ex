defmodule TrashDuty.Slack do
  @moduledoc false

  use Slack

  alias TrashDuty.{Parser, Formatter,Cycle, Store}

  require Logger

  def handle_connect(slack, state) do
    Logger.debug "Connected as #{slack.me.name}"

    {:ok, state}
  end

  def handle_event(_message = %{type: "message", subtype: _}, _slack, state), do: {:ok, state}
  def handle_event(_message = %{type: "message", reply_to: _}, _slack, state), do: {:ok, state}

  def handle_event(message = %{type: "message"}, slack, state) do
    if is_direct_message?(message, slack) do

      # send_message("coucou", "#trash", slack)
      IO.inspect slack

      case Parser.parse(message) do
        { :help, _ } ->
          Formatter.help_message(message.user)
          |> send_message(message.channel, slack)

        { :add, users } ->
          current_cycle = Store.get
          profiles_available = Slack.Web.Users.list(%{token: slack.token})
          new_cycle = Cycle.add_user(users, profiles_available, current_cycle)

          send_message(":loudspeaker: <@#{message.user}> has `joined` to the cycle", message.channel, slack)

          Store.set(new_cycle)

        { :remove, users } ->
          current_cycle = Store.get
          new_cycle = Cycle.remove_user(users, current_cycle)
          Store.set(new_cycle)

          send_message(":loudspeaker: <@#{message.user}> has `quit` to the cycle :wave:", message.channel, slack)

        { :list, _ } ->
          Store.get
          # |> ids_to_users_names(slack)
          |> Formatter.list_message()
          |> send_message(message.channel, slack)

        { :not_a_command, _ } ->
          Formatter.not_a_command_message
          |> send_message(message.channel, slack)
      end

    end

    {:ok, state}
  end
  def handle_event(_, _, state), do: {:ok, state}

  def handle_info({:message, text, channel}, slack, state) do
    IO.puts "Sending your message, captain!"

    send_message(text, channel, slack)
    {:ok, state}
  end

  def handle_info(_, _, state), do: {:ok, state}

  defp ids_to_users_names(list, slack) do
    Slack.Web.Users.list(%{token: slack.token})
    |> Map.get("members")
    |> Enum.filter(&user_in_list?(list, &1))
    |> Enum.map(&get_display_name(&1))
  end

  defp user_in_list?(list, user), do: Map.has_key?(list, user["id"])

  defp get_display_name(users_list) do
    users_list["profile"]["display_name"]
  end

  defp is_direct_message?(%{channel: channel}, slack), do: Map.has_key? slack.ims, channel

end


# iex(2)> Supervisor.which_children(TrashDuty.Supervisor)
# [{Slack.Bot, #PID<0.188.0>, :worker, [Slack.Bot]}]
# iex(3)> send(IEx.Helpers.pid("0.193.0"), {:message, "External message", "C74B102BV"})
# Sending your message, captain!
# {:message, "External message", "#trash"}


# {:ok, rtm} = Slack.Bot.start_link(Slack, [], "xoxb-242502268980-Y7LsDz3Przax1FdxIsehIFL2")
# send rtm, {:message, "External message", "#trash"}
