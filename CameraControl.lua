-- Script Name: CameraControl
-- Location: Shotgun Tool (LocalScript)
-- Purpose: Enables mouse-look and character turning when the tool is equipped.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local tool = script.Parent
local player = Players.LocalPlayer

-- Variables to store character parts and state
local character = nil
local humanoid = nil
local rootPart = nil
local camera = workspace.CurrentCamera

-- Variables to store original settings
local originalMouseBehavior = UserInputService.MouseBehavior
local originalCameraMode = player.CameraMode

-- Connection for the RenderStepped loop
local renderSteppedConnection = nil
local isControlActive = false -- Flag to track if control is active

-- Function to update character rotation
local function onRenderStepped()
	-- Check if character and parts are still valid and humanoid is alive
	if not isControlActive or not character or not rootPart or not rootPart.Parent or not humanoid or humanoid.Health <= 0 then
		-- If invalid state, attempt to cleanup and stop loop
		if renderSteppedConnection then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end
		-- Try to restore settings if unexpectedly stopped
		if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
			UserInputService.MouseBehavior = originalMouseBehavior
		end
		if player.CameraMode == Enum.CameraMode.LockFirstPerson then
			player.CameraMode = originalCameraMode
		end
		isControlActive = false
		return
	end

	-- Make the character face the direction the camera is looking horizontally
	local cameraLookVector = camera.CFrame.LookVector
	local horizontalLookVector = Vector3.new(cameraLookVector.X, 0, cameraLookVector.Z).Unit -- Ignore vertical component

	-- Prevent errors if vector is zero
	if horizontalLookVector.Magnitude > 0.1 then
		-- Create new CFrame looking in the horizontal direction, keeping the root part's position
		local targetCFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + horizontalLookVector)
		-- Only set CFrame if significantly different to avoid potential physics jitter
		-- (Optional, but can sometimes help) - Adjust threshold if needed
		-- if (targetCFrame.LookVector - rootPart.CFrame.LookVector).Magnitude > 0.01 then
		rootPart.CFrame = targetCFrame
		-- end
	end
end

-- Function to enable mouse-look and character turning
local function enableMouseLook()
	if isControlActive then return end -- Already active

	character = player.Character
	if not character then return end -- Character not loaded yet

	humanoid = character:FindFirstChildOfClass("Humanoid")
	rootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoid or not rootPart then return end -- Essential parts missing

	print("CameraControl: Enabling Mouse Look")
	isControlActive = true

	-- Store original settings just before changing
	originalMouseBehavior = UserInputService.MouseBehavior
	originalCameraMode = player.CameraMode

	-- Set desired modes
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter -- Lock cursor to center
	player.CameraMode = Enum.CameraMode.LockFirstPerson -- Force first-person (optional, change if you prefer 3rd)

	-- Connect the RenderStepped loop
	renderSteppedConnection = RunService.RenderStepped:Connect(onRenderStepped)
end

-- Function to disable mouse-look and character turning
local function disableMouseLook()
	if not isControlActive then return end -- Already inactive

	print("CameraControl: Disabling Mouse Look")
	isControlActive = false

	-- Disconnect the RenderStepped loop
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	-- Restore original settings
	UserInputService.MouseBehavior = originalMouseBehavior
	player.CameraMode = originalCameraMode -- Restore original camera mode

	-- Clear character references
	character = nil
	humanoid = nil
	rootPart = nil
end

-- Connect to Tool events
tool.Equipped:Connect(enableMouseLook)
tool.Unequipped:Connect(disableMouseLook)

-- Handle potential case where character is added after script starts listening
player.CharacterAdded:Connect(function(newCharacter)
	-- If tool is currently equipped when character respawns/loads
	if tool.Parent == player.Character or tool.Parent == player.Backpack and player.Character and player.Character:FindFirstChild(tool.Name) == tool then
		-- A small delay might be needed for character parts to fully load after CharacterAdded
		task.wait(0.1)
		enableMouseLook()
	end
end)

-- Initial check in case the character already exists when script runs
if player.Character then
	-- If tool is already equipped when script runs (less common, but possible)
	if tool.Parent == player.Character then
		enableMouseLook()
	end
end

-- Cleanup if the script itself is destroyed
script.Destroying:Connect(disableMouseLook)

print("CameraControl LocalScript loaded for Shotgun.")