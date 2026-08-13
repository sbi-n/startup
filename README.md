# Startup
A simple knit-like Startup

# Installion
Wally

# Example
On client,
```luau
local Startup = require("path/to/startup")

local app = Startup.new()

app:add(require("@controllers/hello-controller"))
app:add(require("@controllers/world-controller"))

app:run()
```

When on server.
```luau
local Startup = require("path/to/startup")

local app = Startup.new()

app:add(require("@services/hello-service"))

app:run()
```

# Extend
```luau
local app = Startup.new()

app:add({
    onPlayerAdded = function(player: Player)
    end
}) -- the example of required module

local function playerAdded(player: Player)
    app:execute("onPlayerAdded", player)
end

for _, player in Players:GetPlayers() do
    task.spawn(playerAdded, player)
end
Players.PlayerAdded:Connect(playerAdded)

```

# Exception
```luau
local app = Startup.new()

app:except(function(err: unknown) -- the promise error handler, single.
    print(err)
end)
```