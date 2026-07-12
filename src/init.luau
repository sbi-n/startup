local RunService = game and game:GetService("RunService")

local Startup = {}
Startup.__index = Startup

export type Controller = {
	read onRender: ((deltaTime: number) -> ())?,
}

export type Service = {}

export type Module = (Controller | Service) & {
	read onStart: (() -> ())?,
	read onStep: ((deltaTime: number) -> ())?,
	read [string]: (...any) -> ...any,
}

export type Startup = typeof(setmetatable(
	{} :: {
		modules: { Module },
	},
	Startup
))

function Startup.new(): Startup
	local self = setmetatable({
		modules = {},
	}, Startup)

	return self
end

function Startup.execute(self: Startup, name: string, ...: any)
	for _, module in self.modules do
		local func = module[name]

		if func then
			local success, message = xpcall(func, debug.traceback :: any, ...)

			if not success then
				warn(`error while running "{name}":\n\n{message}`)
			end
		end
	end
end

function Startup.add(self: Startup, module)
	table.insert(self.modules, module :: Module)

	return self
end

function Startup.run(self: Startup)
	self:execute("onStart")

	RunService.Heartbeat:Connect(function(deltaTime: number)
		self:execute("onStep", deltaTime)
	end)

	if RunService:IsClient() then
		RunService.RenderStepped:Connect(function(deltaTime: number)
			self:execute("onRender", deltaTime)
		end)
	end
end

return Startup
