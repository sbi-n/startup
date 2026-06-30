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