defmodule TrashDuty.Application do

  @moduledoc false

  @slackBotName :slack_bot

  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    config = Application.get_env(:trash_duty, TrashDuty.Slack)
    slack_token = config[:token_bot]

    Logger.debug "token is #{slack_token}"

    # Define workers and child supervisors to be supervised
    children = [
      worker(TrashDuty.Store, [TrashDuty.Cycle.empty]),
      worker(Slack.Bot, [TrashDuty.Slack, [], slack_token], [id: @slackBotName]),
      worker(TrashDuty.Scheduler, []),
    ]

    opts = [strategy: :one_for_one, name: TrashDuty.Supervisor]


    Supervisor.start_link(children, opts)

  end

  def get_slack_bot_pid do
    Supervisor.which_children(TrashDuty.Supervisor)
    |> Enum.filter(fn(x) -> elem(x,0) == @slackBotName end)
    |> List.first
    |> elem(1)
  end

  def notify_user_take_trash_out do
    case TrashDuty.Store.get_next do

       "" -> Logger.error "No user has to take the trash out (No one on list)"

      next ->
        send(
          get_slack_bot_pid(),
          {:message_user, TrashDuty.Formatter.notify_trash_out_msg(), next}
        )

    end
  end

end
