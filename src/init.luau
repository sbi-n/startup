local RunService = game:GetService("RunService")

local Startup = {}

export type Module = {
	onStart: () -> ()?,
	onStep: (deltaTime: number) -> ()?,
	onRender: (deltaTime: number) -> ()?,
	[string]: (...any) -> ...any,
}

local Modules: { Module } = {}

local function execute(modules: { Module }, name: string, ...: any)
	for _, module in modules do
		local func = module[name]

		if func then
			task.spawn(func, ...)
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
