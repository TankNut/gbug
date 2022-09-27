# gbug
A debug library for Garry's Mod

Designed after [GCompute](https://github.com/notcake/gcompute) this library gives you a plain and simple lua console to execute code in, depending on your setup the code may be executed on your own client, other clients, the server or all of the above at the same time with any output being piped back to your console.

## Console Commands

| Command       |                                                                              |
|---------------|------------------------------------------------------------------------------|
| `gbug_reload` | Reloads the UI, you shouldn't have to use this                               |
| `gbug_toggle` | Toggles the UI's visibility, this is the only way to access it at the moment |

## Commands

Commands are ran by typing `:<command>` and execute separately, you cannot use it together with other code.

| Command |                    |
|---------|--------------------|
| `cl`    | Clears the console |

## Modes

Modes are specified by typing `@<mode>:<arg>` either in front of your code or on it's own. The former will use that mode for that run while the latter changes the default.

| Mode             | Commands       |                                                                            |
|------------------|----------------|----------------------------------------------------------------------------|
| `TARGET_SELF`    | `@me, @self`   | Runs the code on your own client                                           |
| `TARGET_CLIENT`  | `@ply:id`      | Runs the code on a specific player, chosen by their userid (from `status`) |
| `TARGET_CLIENTS` | `@cl, @client` | Runs the code on every (human) client                                      |
| `TARGET_SERVER`  | `@sv, @server` | Runs the code on the server                                                |
| `TARGET_SHARED`  | `@sh, @shared` | Runs the code on your own client and the server                            |
| `TARGET_GLOBAL`  | `@g, @global`  | Runs the code on **everyone**                                              |

## Hooks

| Hook             | Arguments    |                                                                                         |
|------------------|--------------|-----------------------------------------------------------------------------------------|
| `gbug.Access`    | `Player ply` | Determines whether or not someone can access/use gbug, defaults to `ply:IsSuperAdmin()` |
| `gbug.CreateEnv` | `Table env`  | Allows you to modify the environment table                                              |

## Environment

Any code running in gbug will have access to a plethora of additional functions or variables to make debugging quick and easy, these effectively act as local vars or functions.

| Var     | Type     |                                        |
|---------|--------- |----------------------------------------|
| `gm`    | `Table`  | `gmod.GetGamemode()`                   |
| `me`    | `Player` | The player that's running the code     |
| `lp`    | `Player` | **(CLIENT)** `LocalPlayer()`           |

| Function                | Returns         |                                                                                                                                                    |
|-------------------------|-----------------|----------------------------------------------------------------------------------------------------------------------------------------------------|
| `NamedEntities(filter)` | `Table\|Entity` | **(SERVER)** Returns a key-value table containing every named entity that matches `filter`, returns the entity directly if there's only one result |
| `Console(str)`          |                 | Runs the given console command in whatever environment it's running in                                                                             |

The following vars all have `LocalPlayer()` equivalents availble on the client which use `l` as a prefix, e.g. `lsid`, `ltr` and `lthis`

| Var     | Type     |                    |
|---------|----------|--------------------|
| `sid`   | `String` | `me:SteamID()`     |
| `here`  | `Vector` | `me:GetPos()`      |
| `eye`   | `Vector` | `me:EyePos()`      |
| `tr`    | `Table`  | `me:GetEyeTrace()` |
| `there` | `Vector` | `tr.HitPos`        |
| `this`  | `Entity` | `tr.Entity`        |
