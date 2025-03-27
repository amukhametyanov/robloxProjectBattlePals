-- Script Name: SpinHoverEffect
-- Location: Shotgun Tool

local tool = script.Parent
local handle = tool:WaitForChild("Handle")

local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService") -- For collision groups later if needed

-- --- Configuration ---
local HOVER_HEIGHT = 1
local SPIN_SPEED = 1

-- --- State Variables ---
local isSpinning = false
local spinCoroutine = nil
local originalCFrame = handle.CFrame
local originalHandleCanCollide = handle.CanCollide -- Store original CanCollide state

-- --- Functions ---

local function startSpinning()
	if isSpinning then return end
	if tool.Parent ~= workspace then return end

	print(tool.Name, "SpinHoverEffect: Starting spin/hover.")
	isSpinning = true
	handle.CanCollide = true -- Ensure collisions are on for workspace presence
	handle.Anchored = true -- Anchor it

	local baseHoverCFrame = originalCFrame * CFrame.new(0, HOVER_HEIGHT, 0)
	local currentRotation = CFrame.new()

	spinCoroutine = coroutine.create(function()
		while isSpinning and tool.Parent == workspace do
			local deltaTime = task.wait()
			if not tool or not tool.Parent or not handle or not handle.Parent then
				isSpinning = false; break
			end
			currentRotation = currentRotation * CFrame.Angles(0, SPIN_SPEED * deltaTime, 0)
			handle.CFrame = baseHoverCFrame * currentRotation
		end
		print(tool.Name, "SpinHoverEffect: Spin loop ended.")
	end)
	coroutine.resume(spinCoroutine)
end

-- Stop spinning loop ONLY, does not change physics properties here
local function stopSpinningLoop()
	if not isSpinning then return end
	print(tool.Name, "SpinHoverEffect: Stopping spin loop flag.")
	isSpinning = false
	spinCoroutine = nil
end

-- --- Event Connections ---

tool.AncestryChanged:Connect(function(child, parent)
	if child == tool then
		if parent == workspace then
			print(tool.Name, "SpinHoverEffect: Tool entered Workspace.")
			task.wait(0.1) -- Settle CFrame
			if not handle or not handle.Parent then return end
			originalCFrame = handle.CFrame
			originalHandleCanCollide = handle.CanCollide -- Re-capture original state in case it changed
			startSpinning() -- Will Anchor and set CanCollide = true
		else
			print(tool.Name, "SpinHoverEffect: Tool left Workspace for:", parent and parent.Name or "nil")
			stopSpinningLoop() -- Stop the loop flag
			-- Physics state (Anchored, CanCollide) will be handled by Equipped/Initial state
		end
	end
end)

tool.Equipped:Connect(function()
	print(tool.Name, "SpinHoverEffect: Tool equipped - Managing physics transition.")
	stopSpinningLoop() -- Ensure loop flag is off

	-- Check if handle exists before proceeding
	if not handle or not handle.Parent then return end

	-- *** CRITICAL PART: Disable collision BEFORE unanchoring ***
	print(" > Disabling Handle collision")
	handle.CanCollide = false

	-- Wait a tiny moment for property change to replicate potentially
	task.wait(0.03)

	-- Unanchor the handle
	print(" > Unanchoring Handle")
	handle.Anchored = false

	-- Wait a bit longer to allow weld to fully form and position to stabilize
	task.wait(0.15) -- Increased wait time

	-- Re-enable collision AFTER weld should be stable
	if handle and handle.Parent then -- Check again, tool might have been unequipped quick
		print(" > Re-enabling Handle collision")
		handle.CanCollide = originalHandleCanCollide -- Restore original state
	end
	print(" > Physics transition complete")
end)


-- --- Initial Setup ---
print(tool.Name, "SpinHoverEffect script loaded.")
originalHandleCanCollide = handle.CanCollide -- Store initial state

if tool.Parent == workspace then
	print(tool.Name, "SpinHoverEffect: Tool initially in Workspace, starting spin effect.")
	originalCFrame = handle.CFrame
	startSpinning() -- This function now ensures CanCollide=true, Anchored=true
else
	-- Ensure handle is not anchored and has original collision if starting elsewhere
	if handle then
		handle.Anchored = false
		handle.CanCollide = originalHandleCanCollide
	end
end

-- Safety cleanup
tool.Destroying:Connect(stopSpinningLoop)

-- Optional: If player unequips, ensure collision state is restored
tool.Unequipped:Connect(function()
	if handle and handle.Parent then
		-- Restore original collision state when unequipped, just in case
		-- 'AncestryChanged' will handle setting CanCollide=true if it enters workspace
		handle.CanCollide = originalHandleCanCollide
	end
end)