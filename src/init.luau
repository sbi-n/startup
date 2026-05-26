local RunService = game:GetService("RunService")

local Startup = {}

export type Controller = {
	onRender: (deltaTime: number) -> ()?,
}

export type Service = {}

export type Module = (Controller | Service) & {
	onStart: () -> ()?,
	onStep: (deltaTime: number) -> ()?,
	[string]: (...any) -> ...any,
}

local Modules: { Module } = {}

local function execute(modules: { Module }, name: string, ...: any)
	for _, module in modules do
		local func = rawget(module, name)

		if func then
			local success, message = xpcall(func, debug.traceback, ...)

			if not success then
				warn(`error while running "{name}":\n\n{message}`)
			end
		end
	end
end

function Startup.add(module: Module)
	table.insert(Modules, module)
end

function Startup.run()
	execute(Modules, "onStart")

	RunService.Heartbeat:Connect(function(deltaTime: number)
		execute(Modules, "onStep", deltaTime)
	end)

	if RunService:IsClient() then
		RunService.RenderStepped:Connect(function(deltaTime: number)
			execute(Modules, "onRender", deltaTime)
		end)
	end
end

return Startup
