local tool = script.Parent
-- No need for Handle reference if we aren't changing it
-- local handle = tool:WaitForChild("Handle")
local visualPart = tool:WaitForChild("Part")
local mesh = visualPart:WaitForChild("Mesh") -- Get the SpecialMesh inside Part

-- --- Define Target Scale (Scale 1) ---
-- Mesh Scale for the 'Part' when tool is equipped (Scale 1)
-- You confirmed this is the correct smaller scale
local targetMeshScale = Vector3.new(1.2, 1.2, 1.2)

-- --- Store Initial Scale (Scale 2) ---
-- Read the starting Scale 2 Mesh Scale directly from the mesh
local initialMeshScale = mesh.Scale

-- Function to set only the mesh scale
local function setMeshScale(mScale)
	if mesh then
		-- Only change if the target scale is different from the current scale
		if mScale ~= mesh.Scale then
			print(" > Setting Mesh Scale TO:", mScale)
			mesh.Scale = mScale
			-- else print(" > Mesh scale unchanged.") -- Optional: uncomment for more detailed logs
		end
	else
		warn("ResizeOnEquip: Mesh not found in Part.")
	end
end

-- When the tool is equipped by a player
tool.Equipped:Connect(function()
	print("Tool Equipped:", tool.Name, "- Setting Mesh Scale to Scale 1")
	setMeshScale(targetMeshScale) -- Set to NORMAL scale
end)

-- When the tool is unequipped (returns to backpack or dropped)
tool.Unequipped:Connect(function()
	print("Tool Unequipped:", tool.Name, "- Setting Mesh Scale back to Initial (Scale 2)")
	setMeshScale(initialMeshScale) -- Set back to the LARGE scale
end)

-- Optional but recommended: Handle the case where the tool is dropped directly into Workspace
tool.AncestryChanged:Connect(function(child, parent)
	-- Check if the tool itself was moved and its new parent is workspace
	if child == tool and parent == workspace then
		print("Tool dropped into Workspace:", tool.Name, "- Ensuring Mesh Scale is Initial (Scale 2)")
		setMeshScale(initialMeshScale) -- Ensure it's the LARGE scale
	end
end)

print(tool.Name, "Resize script loaded. Initial Mesh Scale (Scale 2):", initialMeshScale)