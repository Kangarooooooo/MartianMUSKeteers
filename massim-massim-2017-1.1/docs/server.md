# MASSim Server Documentation

The MASSim server software is located in the `server` directory.

## Running the server
You can run the server directly through the file
`server-[version]-jar-with-dependencies.jar` without the need for additional
shell scripts.

The standard command for that would be

`java -jar server-[version]-jar-with-dependencies.jar`

Make sure that the `conf` folder is located in your current working directory,
when you execute that command.

You may also directly pass a configuration file to the java command with the
`-conf [conf-file]` parameter. Also, you can pass a complete configuration
string value to the command with the `-confString [conf-string]` option.

To enable the web monitor (to view what's happening), you need to call the
server with the `--monitor` option.
The monitor will be available at [http://localhost:8000/](http://localhost:8000/) by default.

## Terminology
* __Simulation__: one round of the respective scenario lasting a predefined
number of steps
* __Match__: a number of simulations played by the same teams
* __Tournament__: a number of matches

## Configuration
The MASSim server reads its configuration from JSON files. The file to use can
be directly given as an argument to the java command. Otherwise, the server
looks for a "conf" directory in the current working directory.

If possible, the server uses default values if no correct value is provided in the configuration file.

Below is the structure of a sample configuration file. The individual parts are
explained in the following.

```JSON
{
  "server" : {},
  "manual-mode" : [],
  "match" : [],
  "teams" : {}
}
```

#### server block
The server block contains information about the server in general, which will hold for all simulations.

```JSON
"server" : {
    "tournamentMode" : "round-robin",
    "teamsPerMatch" : 3,
    "teamSize" : 6,
    "launch" : "key",
    "port" : 12300,
    "backlog" : 10000,
    "agentTimeout" : 4000,
    "resultPath" : "results",
    "logLevel" : "normal",
    "logPath" : "logs",
    "replayPath" : "replays",
    "maxPacketLength" : 65536
  }
```
* __tournamentMode__: The tournament mode specifies, which teams play against each other in which order. Available modes are:
 1. `round-robin`: Each unique combination of teams will play the set of
simulations.
 * `manual`: This indicates that the actual matches will be manually
configured in a separate vonfiguration block.
 * `random`: For each match, the participating teams are picked randomly
until enough teams to play the match have been determined. This is repeated
until the server is terminated manually.


* __teamsPerMatch__: How many teams play simultaneously in one simulation

* __teamSize__: How many agents a team contains

* __launch__: How the start of the matches is delayed
 * `key`: The server will wait for the ENTER key to start.
 * `[Int]s`": The server will start after [Int] seconds (e.g. 60s).
 * `HH:mm`: The server will start at the time indicated by HH:mm
(e.g. 12:00).


* __port__: The port on which to listen for incoming connections (see [protocol.md](protocol.md) for information about what to send)

* __backlog__: The backlog parameter for the Java ServerSocket

* __agentTimeout__: The time (in ms) after which an agent has to have sent an action

* __resultPath__: Where to store the result of a match

* __logLevel__: The level at which to print log messages; available levels include `debug`, `normal`, `error` and `critical`

* __logPath__: Every log message that is printed can also be written to file. This is where the log files will be saved. One log file per server run is written.

* __replayPath__: The simulation state can be saved to disk after each step. This is where these files will be saved. Those replay files can be used again e.g. with the web monitor.

* __maxPacketLength__: The maximum number of bytes of an XML message that will be processed by the server. Bytes beyond that limit will be immediately discarded.

#### manual-mode block
This block specifies the manual-mode configuration. It is used (and required) if the __tournamentMode__ is set to `manual-mode`.

```JSON
"manual-mode" : [
  ["A", "B", "C"],
  ["B", "C", "D"],
  ["C", "D", "E"]
]
```

The block is an array of arrays. Each internal array specifies the teams participating in one match.
In this example, the teams A, B and C play in the first match against each other.

#### match block
This block describes exactly how each simulation will be set up and is mostly scenario dependent. One object in the match array represents one simulation.
Always required are the fields

```JSON
"match" : [
  {
    "id" : "2017-Sim-1of1",
    "scenarioClass" : "city.CitySimulation",
    "steps" : 1000
  }
]
```
where
* __id__ is an identifier for the simulation,
* __scenarioClass__ is the path of the scenario's main class, and
* __steps__ is the number of steps the simulation will last.

For the remaining scenario-dependent items we refer to [scenario.md](scenario.md).

#### teams block
The teams block describes the teams and their credentials. The teams listed here can always connect to the server - however, they will of course only receive percepts when they are participating in the current simulation.

```JSON
"teams" : {
    [
      ["agentA1", "1"],
      ["agentA2", "1"],
      ["agentA3", "1"],
      ["agentA4", "1"],
      ["agentA5", "1"],
      ["agentA6", "1"]
    ],
    "B" : "$(teams/B.json)",
    "C" : "$(teams/C.json)",
    "D" : "$(teams/D.json)",
    "E" : "$(teams/E.json)"
  }
```

Each key in the ```teams``` JSON object is the name of a team. It points to an array of single agent accounts. Each account is represented by an array, where the fist entry is the agent's username, and the second its password.

Here, for teams B to E we used a custom JSON include mechanism that will be explained in the next section.

#### JSON include mechanism
As it is often required to use e.g. the same team in different configuration files, each value can be stored in a separate file. The syntax to include external JSON elements is ```"$(path/to/include.json)"```.

Before configuration files are parsed, all such occurrences will be replaced with the content of the file found at that location. Those files may in turn reference other files. The paths are always interpreted relative to the referencing file.

## Commands
After the server has been started, it is listening for user input. The following commands are always accepted:

* __pause__: The server pauses before the next step is executed (the current step is finished first).
* __continue__: If the simulation is paused, the server continues its execution. Otherwise, nothing happens.

Commands are buffered during simulation steps and executed at a specific point between simulation steps. It is recommended to use the __pause__ command first and type further commands while the server is paused. If the command queue is emtpy, commands are immediately executed during the pause.

There is also a number of commands specific to the scenario. These are explained in [scenario.md](scenario.md).
