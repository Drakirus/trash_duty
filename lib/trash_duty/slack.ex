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
        { :help, _ } ->
          Formatter.help_message()
          |> send_message(message.channel, slack)

        { :add, users } ->
          old_cycle = Store.get_users
          profiles_available = Slack.Web.Users.list(%{token: slack.token})
          new_cycle = Cycle.add_users(users, profiles_available, old_cycle)

          if Map.equal?(old_cycle, new_cycle) do

            send_message(Formatter.nothing_change_message, message.channel, slack)
          else

            broadcast_users(
              "#{Formatter.inline_list_user(users)} `joined` to the cycle",
              Map.put_new(new_cycle, message.user, ""),
              slack)

              if Store.get_next == "" do
                Store.set_next(List.first(users))
              end

              Store.set_users(new_cycle)
          end


        { :remove, users } ->
          [old_cycle, trash_du] = Store.get
          new_cycle = Cycle.remove_user(users, old_cycle)

          if Map.equal?(old_cycle, new_cycle) do

            send_message(Formatter.nothing_change_message, message.channel, slack)
          else

            msgGlobal = "#{Formatter.inline_list_user(users)} `quitted` to the cycle :wave:"
            msgNext = ""

            # skip to the next user if remove users in next to take out
            if Enum.member?(users, trash_du) do
              {id, _} = [old_cycle, trash_du]
                        |> Cycle.next_on_list

              msgNext = "#{Formatter.format_user(id)} is now on duty :gift:"
              Store.set_next(id)
            end

            # send to all uesrs msg
            broadcast_users(
              "#{msgGlobal}\n#{msgNext}",
              Map.put_new(old_cycle, message.user, ""),
              slack
            )

            # if no one on list no next
            if Enum.empty?(new_cycle) do
              Store.set_next("")
            end

            # write new cycle
            Store.set_users(new_cycle)
          end

        { :list, _ } ->
          Store.get
          |> Formatter.list_message()
          |> send_message(message.channel, slack)

        { :skip, _ } ->
          [user_list, trash_du] = Store.get
          {id, _} = [user_list, trash_du]
                    |> Cycle.next_on_list
                    Store.set_next(id)

          broadcast_users(
            "#{Formatter.format_user(message.user)} `skiped` the turn of #{Formatter.format_user(trash_du)}.\n #{Formatter.format_user(id)} is now on duty :gift:",
            Map.put_new(user_list, message.user, ""),
            slack
          )

        { :not_a_command, _ } ->
          Formatter.not_a_command_message
          |> send_message(message.channel, slack)
      end

    end

    {:ok, state}
  end
  def handle_event(_, _, state), do: {:ok, state}

  def handle_info({:message_user, text, user}, slack, state) do

    channel_user = slack.ims
    |> Enum.filter(
      fn({_, im}) ->
        im.user == user
      end
    )
    |> List.first
    |> elem(1)
    |> Map.get(:id)

    send_message(text,  channel_user, slack)

    {:ok, state}
  end

  def handle_info(_, _, state), do: {:ok, state}

  defp broadcast_users(message, users, slack) do

    # current_im = Slack.Web.Im.list(%{token: slack.token})
                 # |> Map.get("ims")
                 # |> Enum.map(fn elem ->  elem["user"]  end)
    # IO.inspect (users |> Map.keys) -- current_im
    # Slack.Web.Im.list(%{token: slack.token}) |> IO.inspect
    # # open channel im
    # (users |> Map.keys) -- current_im
    # |> Enum.each(
      # fn(user) ->
        # Slack.Web.Im.open(user, %{token: slack.token})
      # end
    # )

    slack.ims
    |> Enum.filter(
      fn({_, im}) ->
        Map.has_key?(users, im.user)
      end
    )
    |> Enum.each(
      fn({_, im}) ->
        send_message(":loudspeaker: " <> message, im.id, slack)
      end
    )
  end


  defp is_direct_message?(%{channel: channel}, slack), do: Map.has_key? slack.ims, channel

end
