# TrashDuty

First try at a real world project made in `Elixir` and functional programing.  

Used to alert a **Slack** user of a list when it is there turn to take the trash out

[Config example](config/config.exs)

*Usage*:
 - `add` -> add yourself to the list
 - `add [List of user]` ->  add multiple user
 - `remove`
 - `remove [List of user]`
 - `help`: Prints this message
 - `list`: List the cuurent users added
 - `skip`: skip to the next 'take the trash out' user

> Note the list skip to the next user based on the cmp_email fonction [here](https://github.com/Drakirus/trash_duty/blob/e65de79865a63b78c56c5fdc3b40373005e07eee/lib/trash_duty/cycle.ex#L71-L75)
