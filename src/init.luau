local RunService = game and game:GetService("RunService")

local Promise = require(script.Parent:WaitForChild("typed-promise")) :: any

local Startup = {}
Startup.__index = Startup

export type Controller = {
	read onRender: ((deltaTime: number) -> ())?,
}

export type Service = {}

export type Module = (Controller | Service) & {
	read onStart: (() -> ())?,
	read onStep: ((deltaTime: number) -> ())?,
	read onLoaded: (() -> ())?,
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

function Startup.execute<TArgs...>(self: Startup, name: string, ...: TArgs...): Promise.TypedPromise<{ unknown }>
	local promises = {} :: { Promise.TypedPromise<unknown> }

	for _, module in self.modules do
		local func = module[name]

		if func then
			local promise = Promise.try(func, ...) :: Promise.TypedPromise<unknown>

			table.insert(promises, promise)
		end
	end

	return Promise.all(promises)
end

function Startup.add(self: Startup, module: any): Startup
	table.insert(self.modules, module :: Module)

	return self
end

function Startup.run(self: Startup)
	self:execute("onStart"):andThenCall(function()
		self:execute("onLoaded")
	end)

	RunService.Heartbeat:Connect(function(deltaTime: number)
		self:execute("onStep", deltaTime)
	end)

	if RunService:IsClient() then
		RunService.PreRender:Connect(function(deltaTime: number)
			self:execute("onRender", deltaTime)
		end)
	end
end

return Startup
