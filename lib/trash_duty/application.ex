defmodule TrashDuty.Application do

  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    config = Application.get_env(:trash_duty, TrashDuty.Slack)
    slack_token = config[:token_bot]

    Logger.debug "token is #{slack_token}"

    slack_spec = %{
      id: Slack.Bot,
      start: {Slack.Bot, :start_link, [TrashDuty.Slack, [], slack_token]}
    }

    # Define workers and child supervisors to be supervised
    children = [
      worker(TrashDuty.Store, [TrashDuty.Cycle.empty]),
      slack_spec,
    ]

    opts = [strategy: :one_for_one, name: TrashDuty.Supervisor]


    Supervisor.start_link(children, opts)

  end

end
