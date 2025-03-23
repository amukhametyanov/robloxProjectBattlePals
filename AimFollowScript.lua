-- Instant Camera-Character Synchronization System
-- Place this as a LocalScript in StarterGui/StarterPack
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local tool = script.Parent.Parent
local camera = workspace.CurrentCamera

-- Configuration
local CAMERA_DISTANCE = 20
local MOUSE_SENSITIVITY = 1.5
local BASE_FOV = 70
local MAX_PITCH = math.rad(80)
local COLLISION_OFFSET = 1.0

-- Runtime variables
local cameraYaw = 0
local cameraPitch = math.rad(15)
local originalCameraType = camera.CameraType

-- Instant rotation system
local function updateCharacterRotation()
	if not character:FindFirstChild("HumanoidRootPart") then return end
	local hrp = character.HumanoidRootPart

	-- Direct instant rotation using CFrame
	hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, cameraYaw, 0)
end

-- Fixed camera collision detection with proper RaycastParams
local function updateCamera()
	if not character:FindFirstChild("HumanoidRootPart") then return end
	local hrp = character.HumanoidRootPart

	-- Get mouse input
	local delta = UserInputService:GetMouseDelta()

	-- Update rotation angles
	cameraYaw = cameraYaw - delta.X * MOUSE_SENSITIVITY * 0.01
	cameraPitch = cameraPitch + delta.Y * MOUSE_SENSITIVITY * 0.01
	cameraPitch = math.clamp(cameraPitch, -MAX_PITCH, MAX_PITCH)

	-- Instant character rotation
	updateCharacterRotation()

	-- Calculate camera position with collision
	local idealOffset = Vector3.new(
		math.sin(cameraYaw) * math.cos(cameraPitch) * CAMERA_DISTANCE,
		math.sin(cameraPitch) * CAMERA_DISTANCE + 1.5,
		math.cos(cameraYaw) * math.cos(cameraPitch) * CAMERA_DISTANCE
	)

	-- Create proper RaycastParams
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {character}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

	-- Camera collision detection
	local cameraPos = hrp.Position + idealOffset
	local direction = (cameraPos - hrp.Position).Unit
	local raycastResult = workspace:Raycast(
		hrp.Position + Vector3.new(0, 1, 0),
		direction * (CAMERA_DISTANCE + COLLISION_OFFSET),
		raycastParams  -- Pass the params object here
	)

	-- Adjust camera position if needed
	if raycastResult then
		cameraPos = raycastResult.Position - (direction * COLLISION_OFFSET)
	end

	-- Update camera
	camera.CFrame = CFrame.new(cameraPos, hrp.Position + Vector3.new(0, 1.5, 0))
end

local function onEquipped()
	originalCameraType = camera.CameraType
	camera.CameraType = Enum.CameraType.Scriptable
	humanoid.AutoRotate = false
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	RunService:BindToRenderStep("CameraControl", Enum.RenderPriority.First.Value, updateCamera)
end

local function onUnequipped()
	camera.CameraType = originalCameraType
	humanoid.AutoRotate = true
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	RunService:UnbindFromRenderStep("CameraControl")
end

tool.Equipped:Connect(onEquipped)
tool.Unequipped:Connect(onUnequipped)

player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoid = character:WaitForChild("Humanoid")
end)