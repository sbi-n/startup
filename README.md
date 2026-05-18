# Startup
A simple knit-like Startup

# Installion
Wally

# Example
On client,
```luau
local Startup = require("path/to/startup")

Startup.add(require("@controllers/hello-controller"))
Startup.add(require("@controllers/world-controller"))

Startup.run()
```

When on server.
```luau
local Startup = require("path/to/startup")

Startup.add(require("@services/hello-service"))

Startup.run()
```