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

      case Parser.parse(message) do
        { :help, _ } -> Formatter.help_message(message.user)
                         |> send_message(message.channel, slack)

        { :add, users } ->
          current_cycle = Store.get
          profiles_available = Slack.Web.Users.list(%{token: slack.token})
          new_cycle = Cycle.add_user(users, profiles_available, current_cycle)
          Store.set(new_cycle)

        { :list, _ } -> Store.get |> Formatter.list_message() |> send_message(message.channel, slack)

        { :not_a_command, _ } -> Formatter.not_a_command_message
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

  defp is_direct_message?(%{channel: channel}, slack), do: Map.has_key? slack.ims, channel

end


# iex(2)> Supervisor.which_children(TrashDuty.Supervisor)
# [{Slack.Bot, #PID<0.188.0>, :worker, [Slack.Bot]}]
# iex(3)> send(IEx.Helpers.pid("0.188.0"), {:message, "External message", "#trash"})
# Sending your message, captain!
# {:message, "External message", "#trash"}


# {:ok, rtm} = Slack.Bot.start_link(Slack, [], "xoxb-242502268980-Y7LsDz3Przax1FdxIsehIFL2")
# send rtm, {:message, "External message", "#trash"}

# Slack.Web.Users.info("U74H4MAKX",%{token: "xoxb-242502268980-Y7LsDz3Przax1FdxIsehIFL2"})

# names = Slack.Web.Users.list(%{token: "xoxb-242502268980-Y7LsDz3Przax1FdxIsehIFL2"})
# names |> Map.get("members") |> Enum.map(fn(m) -> m["real_name"]end)
# names |> Map.get("members") |> Enum.map(fn(m) -> {m["id"], m["real_name"]} end) |> Map.new


# Slack.Web.Channels.list(%{token: "xoxb-242502268980-Y7LsDz3Przax1FdxIsehIFL2"}) |> Map.get("channels") |> Enum.filter(fn(chan) -> chan["name"] == "trash" end) |> Enum.map(fn(chan) -> {chan["id"], chan["members"]} end) |> Map.new

# Slack.Web.Channels.kick("C74B102BV", "U74H4MAKX", %{token: "xoxp-242442904978-242582724677-243018339858-7c7b65ab3574a4e7addf1cc24798d3d8"})


# Slack.Web.Channels.create("testPierre", %{token: "xoxp-242442904978-242582724677-243018339858-7c7b65ab3574a4e7addf1cc24798d3d8"})
