local RunService = game and game:GetService("RunService")

local Promise = require("./packages/roblox/typed-promise")

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
		exception: ((err: unknown) -> ())?,
	},
	Startup
))

function Startup.new(): Startup
	local self = setmetatable({
		modules = {},
		exception = nil :: any,
	}, Startup)

	return self
end

function Startup.execute<TArgs...>(self: Startup, name: string, ...: TArgs...): Promise.TypedPromise<{ Promise.Status }>
	local promises = {} :: { Promise.TypedPromise<unknown> }

	for _, module in self.modules do
		local func = module[name]

		if func then
			local promise: Promise.TypedPromise<unknown> = if self.exception
				then Promise.try(func, ...):catch(self.exception)
				else Promise.try(func, ...)

			table.insert(promises, promise)
		end
	end

	return Promise.allSettled(promises)
end

function Startup.except(self: Startup, func: (err: unknown) -> ())
	assert(not self.exception, "Exception is already exist.")

	self.exception = func
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
