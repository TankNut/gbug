# gbug
A debug library for Garry's Mod

## Commands

| Command     | Function                                                                     |
|-------------|------------------------------------------------------------------------------|
| gbug_reload | Reloads the UI, you shouldn't have to use this                               |
| gbug_toggle | Toggles the UI's visibility, this is the only way to access it at the moment |

## Modes

Modes are specified by typing `@<mode>:<arg>` either in front of your command or on it's own. The former will use that mode for that command while the latter changes the default.

| Mode           | Commands       | Function                                                                   |
|----------------|----------------|----------------------------------------------------------------------------|
| TARGET_SELF    | `@me, @self`   | Runs the code on your own client                                           |
| TARGET_CLIENT  | `@ply:id`      | Runs the code on a specific player, chosen by their userid (from `status`) |
| TARGET_CLIENTS | `@cl, @client` | Runs the code on every (human) client                                      |
| TARGET_SERVER  | `@sv, @server` | Runs the code on the server                                                |
| TARGET_SHARED  | `@sh, @shared` | Runs the code on your own client and the server                            |
| TARGET_GLOBAL  | `@g, @global`  | Runs the code on **everyone**                                              |
