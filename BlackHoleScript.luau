-- Black Hole Gravity Script
-- Pulls all non-anchored objects and players into the black hole

local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

-- Black hole configuration
local BLACK_HOLE_NAME = "BlackHole"
local GRAVITY_STRENGTH = 100 -- Strength of the pull
local DESTROY_DISTANCE = 5 -- Distance at which objects are destroyed
local CHECK_INTERVAL = 0.1 -- How often to update (seconds)
local GROWTH_RATE = 0.5 -- How much the black hole grows per second (studs)
local MAX_SIZE = 100 -- Maximum size the black hole can reach

-- Find the black hole part
local blackHole = Workspace:FindFirstChild(BLACK_HOLE_NAME)
if not blackHole then
    warn("Black hole not found! Please create a part named '" .. BLACK_HOLE_NAME .. "'")
    return
end

-- Track objects being pulled to avoid duplicate processing
local trackedObjects = {}

-- Black hole growth system
local function startBlackHoleGrowth()
    task.spawn(function()
        while blackHole and blackHole.Parent do
            local currentSize = blackHole.Size.X
            
            -- Only grow if below maximum size
            if currentSize < MAX_SIZE then
                local newSize = math.min(currentSize + GROWTH_RATE * CHECK_INTERVAL, MAX_SIZE)
                blackHole.Size = Vector3.new(newSize, newSize, newSize)
            end
            
            task.wait(CHECK_INTERVAL)
        end
    end)
end

-- Start the black hole growth
startBlackHoleGrowth()

-- Check if an object should be affected by the black hole
local function shouldAffectObject(object)
    -- Must be a BasePart
    if not object:IsA("BasePart") then
        return false
    end
    
    -- Skip the black hole itself
    if object == blackHole then
        return false
    end
    
    -- Skip anchored parts
    if object.Anchored then
        return false
    end
    
    -- Skip parts that are already being destroyed
    if trackedObjects[object] then
        return false
    end
    
    return true
end

-- Apply gravitational force to an object
local function applyGravity(object)
    if not shouldAffectObject(object) then
        return
    end
    
    trackedObjects[object] = true
    
    -- Main gravity loop for this object
    task.spawn(function()
        while object and object.Parent do
            -- Calculate direction to black hole
            local blackHolePosition = blackHole.Position
            local objectPosition = object.Position
            local direction = (blackHolePosition - objectPosition).Unit
            local distance = (blackHolePosition - objectPosition).Magnitude
            
            -- Check if object should be destroyed
            if distance < DESTROY_DISTANCE then
                -- Check if it's a player character
                local character = object.Parent
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                
                if humanoid then
                    -- Kill the player
                    humanoid.Health = 0
                end
                
                -- Destroy the object
                object.Parent = nil
                trackedObjects[object] = nil
                break
            end
            
            -- Apply gravitational force (stronger when closer)
            local forceMagnitude = GRAVITY_STRENGTH * (1 + (10 / (distance + 1)))
            local velocity = direction * forceMagnitude
            
            -- Apply velocity to the object
            object.AssemblyLinearVelocity = object.AssemblyLinearVelocity + velocity * CHECK_INTERVAL
            
            -- Also rotate objects toward the black hole for visual effect
            object.AssemblyAngularVelocity = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
            
            task.wait(CHECK_INTERVAL)
        end
        
        -- Clean up tracking when object is gone
        trackedObjects[object] = nil
    end)
end

-- Handle player characters specifically
local function onCharacterAdded(character)
    -- Wait for the character to be fully loaded
    task.wait(0.5)
    
    -- Apply gravity to all parts in the character
    for _, part in character:GetDescendants() do
        if part:IsA("BasePart") and not part.Anchored then
            applyGravity(part)
        end
    end
end

-- Handle new players joining
local Players = game:GetService("Players")
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(onCharacterAdded)
    
    -- If player already has a character
    if player.Character then
        onCharacterAdded(player.Character)
    end
end)

-- Handle players already in the game
for _, player in Players:GetPlayers() do
    player.CharacterAdded:Connect(onCharacterAdded)
    if player.Character then
        onCharacterAdded(player.Character)
    end
end

-- Handle existing non-anchored parts in the workspace
for _, descendant in Workspace:GetDescendants() do
    if shouldAffectObject(descendant) then
        applyGravity(descendant)
    end
end

-- Handle new parts added to the workspace
Workspace.DescendantAdded:Connect(function(descendant)
    if shouldAffectObject(descendant) then
        applyGravity(descendant)
    end
end)

print("Black hole gravity system initialized!")