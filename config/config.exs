use Mix.Config

# EXAMPLe
config :trash_duty, TrashDuty.Slack,
  token_bot: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# https://my.slack.com/services/new/bot

config :trash_duty, TrashDuty.Scheduler,
  timezone: "Europe/Paris",
  jobs: [

    # Set the notification date
    # https://crontab.guru/

    # At 17:00 on Tuesday.
    {"0 17 * * 2",      {TrashDuty.Application, :notify_user_take_trash_out, []}},
    # At 17:00 on Friday.
    {"0 17 * * 5",      {TrashDuty.Application, :notify_user_take_trash_out, []}},

    # every 10 seconds // debug
    # {{:extended, "*/10 * * * *"}, {TrashDuty.Application, :notify_user_take_trash_out, []}},

  ]
