-- Place this script inside your Weapon (Tool)
-- This script animates the Tool's Handle part ONLY WHEN IT'S NOT EQUIPPED

local tool = script.Parent
local handle = tool:WaitForChild("Handle") -- Tools always have a Handle part

-- Configuration
local floatHeight = 0.5 -- How high it floats above its initial position
local floatSpeed = 1 -- How fast it bobs up and down
local spinSpeed = 30 -- How fast it spins (in degrees per second)

-- Store the original CFrame when the script starts
local originalCFrame = nil
local isEquipped = false

-- Function to start the animation when dropped
local function startAnimation()
	isEquipped = false
	-- Wait a short moment to make sure everything is set
	wait(0.1)
	-- Store current position as the original
	originalCFrame = handle.CFrame
	handle.Anchored = true -- Anchor the handle for the animation
end

-- Function to stop the animation when picked up
local function stopAnimation()
	isEquipped = true
	handle.Anchored = false -- Allow physics when picked up
end

-- Connect to the Equipped event to stop animation when a player picks it up
tool.Equipped:Connect(stopAnimation)
tool.Unequipped:Connect(startAnimation)

-- Start in unequipped state
startAnimation()

-- Main animation loop
while true do
	-- Only animate when not equipped
	if not isEquipped and originalCFrame then
		-- Calculate bobbing motion
		local timeVal = tick() * floatSpeed
		local yOffset = math.sin(timeVal) * 0.2 + floatHeight

		-- Create a new CFrame that preserves original position but adds height and rotation
		local newCFrame = originalCFrame * 
			CFrame.new(0, yOffset, 0) * 
			CFrame.Angles(0, math.rad(spinSpeed) * tick() % (2*math.pi), 0)

		-- Apply the new CFrame
		handle.CFrame = newCFrame
	end

	-- Small wait to prevent script from being too resource-intensive
	wait(0.01)
end