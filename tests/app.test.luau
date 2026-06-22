local Test = require("@std/test")

local Startup = require("../src")

Test.suite("App", function(suite)
    suite:case("Create", function(assert)
        local app = Startup.new()

        assert.neq(app, nil :: any)
    end)

    suite:case("Add", function(assert)
        local app = Startup.new()
        local module = {}

        app:add(module)

        assert.eq(app.modules[1], module)
    end)

    suite:case("Execute", function(assert)
        local executed = false

        local app = Startup.new()
        local module = {}

        function module.onStart()
            executed = true
        end

        app:add(module)
        app:execute("onStart")

        assert.eq(executed, true)
    end)
end)