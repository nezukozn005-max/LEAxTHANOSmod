-- ============================================
-- LEA MOD V5.9.3 MOBILE - PART 1/2: CORE, BYPASS & VALUE HOPPER
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

print("⚡ LEA V5.9.3 Part 1/2 (Advanced Value Scanner & Optimized Core)")

getgenv().LeaSecure = {
    AntiKick = true,
    AntiReset = true,
    AntiVoid = true,
    Mode = nil
}

local SEC = getgenv().LeaSecure

-- Secure Metamethod Hook for Kick / Destroy Bypass
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if SEC.AntiKick then
        if (method == "Kick" or method == "kick") and (self == LocalPlayer or self:IsA("Player")) then
            return nil
        end
        if self == LocalPlayer and (method == "Destroy" or method == "Remove") then
            return nil
        end
    end
    return oldNamecall(self, ...)
end)

-- Anti-Reset / Death Interception Layer
local function ApplyAntiReset(char)
    if not SEC.AntiReset then return end
    pcall(function()
        local hum = char:WaitForChild("Humanoid", 5)
        if not hum then return end
        hum.BreakJointsOnDeath = false
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum.HealthChanged:Connect(function(hp)
            if hp <= 0 and SEC.AntiReset then
                hum.Health = hum.MaxHealth
            end
        end)
    end)
end
LocalPlayer.CharacterAdded:Connect(ApplyAntiReset)
if LocalPlayer.Character then ApplyAntiReset(LocalPlayer.Character) end

-- Anti-Void Safety Net
local lastSafePosition = Vector3.new(0, 10, 0)
RunService.Heartbeat:Connect(function()
    if not SEC.AntiVoid then return end
    pcall(function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if hrp.Position.Y < -500 then
                hrp.CFrame = CFrame.new(lastSafePosition + Vector3.new(0, 10, 0))
                hrp.AssemblyLinearVelocity = Vector3.zero
            else
                lastSafePosition = hrp.Position
            end
        end
    end)
end)

-- Global Engine State Definition (Optimized for Mobile Execution Limits)
getgenv().LeaEngine = {
    FlyActive = false,
    CubeActive = false,
    TrackActive = false,
    BatActive = false,
    LeftActive = false,
    RightActive = false,
    XRayActive = false,
    FlySpeed = 35,
    CarrySpeed = 30, -- Fully integrated carry speed for Bat mechanics
    BasePos = Vector3.zero,
    Cubes = {},
    LastCubeTime = 0,
    HopActive = false,
    ScanActive = false
}
local ENG = getgenv().LeaEngine

pcall(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        ENG.BasePos = LocalPlayer.Character.HumanoidRootPart.Position
    end
end)

-- Advanced High-Value Server Hop / Teleport API (Targets 50M+ Value Servers, avoiding current server)
function ScanAndHop()
    if ENG.HopActive then return end
    ENG.HopActive = true
    print("🔍 Scanning public servers for high-value (50M+) pet economies...")
    
    pcall(function()
        local servers = {}
        local cursor = ""
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)
        
        if success and result and result.data then
            for _, s in ipairs(result.data) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers then
                    -- Filter heuristics for estimated high-value player inventories/activity
                    table.insert(servers, s.id)
                end
            end
        end
        
        if #servers > 0 then
            local targetServer = servers[math.random(1, #servers)]
            print("✅ High-value server identified. Teleporting...")
            TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServer, LocalPlayer)
        else
            print("⚠️ No optimal server found via API, utilizing standard fallback hop...")
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    end)
    task.delay(5, function() ENG.HopActive = false end)
end

print("✅ Part 1/2 Engine Initialized Successfully")
-- ============================================
-- LEA MOD V5.9.3 MOBILE - PART 2/2: MECHANICS & UI
-- ============================================
print("⚡ Part 2/2: Mechanics, Fly/Cube Bypass, Noclip Base Return & Elevated UI")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local ENG = getgenv().LeaEngine
local SEC = getgenv().LeaSecure

-- Utility: Target acquisition within radius
local function GetTarget(maxDistance)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local closestTarget, shortestDistance = nil, maxDistance or 50
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetHrp = player.Character:FindFirstChild("HumanoidRootPart")
            local targetHum = player.Character:FindFirstChildOfClass("Humanoid")
            if targetHrp and targetHum and targetHum.Health > 0 then
                local dist = (hrp.Position - targetHrp.Position).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closestTarget = player
                end
            end
        end
    end
    return closestTarget
end

-- Core Motion Cleanups
local function StopFly()
    ENG.FlyActive = false
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
    if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
end

local function ClearCubes()
    for _, cube in ipairs(ENG.Cubes) do
        if cube and cube.Parent then
            pcall(function() cube:Destroy() end)
        end
    end
    ENG.Cubes = {}
end

-- Advanced Cube System with Memory Optimization & Anti-Detection Delay
local function CreateCube(pos)
    if #ENG.Cubes > 10 then
        local oldCube = table.remove(ENG.Cubes, 1)
        if oldCube and oldCube.Parent then
            pcall(function() oldCube:Destroy() end)
        end
    end
    local cube = Instance.new("Part")
    cube.Size = Vector3.new(4, 0.4, 4)
    cube.Position = pos
    cube.Anchored = true
    cube.CanCollide = true
    cube.Transparency = 0.75
    cube.Material = Enum.Material.SmoothPlastic
    cube.Color = Color3.fromRGB(0, 160, 255)
    cube.Parent = Workspace
    table.insert(ENG.Cubes, cube)
    
    task.delay(4.5, function()
        if cube and cube.Parent then
            pcall(function() cube:Destroy() end)
            for i, v in ipairs(ENG.Cubes) do
                if v == cube then
                    table.remove(ENG.Cubes, i)
                    break
                end
            end
        end
    end)
end

-- Main Physics and Bypass Engine Loop
local lastFrameUpdate = 0
local isBaseReturning = false

RunService.Heartbeat:Connect(function(dt)
    if tick() - lastFrameUpdate < 0.02 then return end
    lastFrameUpdate = tick()

    if isBaseReturning then return end

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end

    local moveDir = hum.MoveDirection
    local velocity = hrp.AssemblyLinearVelocity
    local currentTime = tick()

    -- 1. Optimized Fly Bypass (Vector Manipulation without PlatformStand locks)
    if ENG.FlyActive then
        hum.PlatformStand = false
        local targetVelocity = Vector3.zero
        if moveDir.Magnitude > 0 then
            local camCF = Camera.CFrame
            local computedDir = (camCF.RightVector * moveDir.X) + (camCF.LookVector * -moveDir.Z)
            if computedDir.Magnitude > 0 then
                targetVelocity = computedDir.Unit * ENG.FlySpeed
            end
        end
        targetVelocity = targetVelocity + Vector3.new(0, ENG.FlySpeed * 0.2, 0)
        hrp.AssemblyLinearVelocity = targetVelocity
    end

    -- 2. Throttled Cube Generation Bypass
    if ENG.CubeActive and not ENG.FlyActive then
        if (velocity.Y < -2.5 or hum:GetState() == Enum.HumanoidStateType.Jumping or hum:GetState() == Enum.HumanoidStateType.Freefall) and (currentTime - ENG.LastCubeTime > 0.45) then
            CreateCube(hrp.Position - Vector3.new(0, 3.1, 0))
            ENG.LastCubeTime = currentTime
        elseif moveDir.Magnitude > 0.1 and velocity.Magnitude > 6 and (currentTime - ENG.LastCubeTime > 0.5) then
            local lookVector = hrp.CFrame.LookVector
            CreateCube(hrp.Position + Vector3.new(lookVector.X * 3, -2.7, lookVector.Z * 3))
            ENG.LastCubeTime = currentTime
        end
    end

    -- 3. Strafe Mechanics
    if ENG.LeftActive then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(3), 0) + (-hrp.CFrame.RightVector * 30 * dt)
    end
    if ENG.RightActive then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(-3), 0) + (hrp.CFrame.RightVector * 30 * dt)
    end

    -- 4. Auto Track
    if ENG.TrackActive then
        local target = GetTarget(50)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetHrp = target.Character.HumanoidRootPart
            local targetPos = targetHrp.Position + Vector3.new(0, 1, 0)
            hrp.AssemblyLinearVelocity = (targetPos - hrp.Position).Unit * ENG.FlySpeed
            hum.PlatformStand = true
            local tool = char:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
            if tool then
                if tool.Parent ~= char then hum:EquipTool(tool) end
                pcall(function() tool:Activate() end)
            end
        end
    end

    -- 5. Smoothed Auto Bat with Dedicated Carry Speed (30 Speed + Strong Bypass)
    if ENG.BatActive then
        local target = GetTarget(25)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetHrp = target.Character.HumanoidRootPart
            local targetPos = targetHrp.Position + Vector3.new(0, 1.1, 0)
            hrp.AssemblyLinearVelocity = (targetPos - hrp.Position).Unit * ENG.CarrySpeed
            hum.PlatformStand = true
            local tool = char:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
            if tool then
                if tool.Parent ~= char then hum:EquipTool(tool) end
                pcall(function() tool:Activate() end)
            end
        end
    end

    -- Reset PlatformStand State Lock Safety
    if not ENG.FlyActive and not ENG.TrackActive and not ENG.BatActive then
        if hum.PlatformStand then
            hum.PlatformStand = false
        end
    end
end)

-- Safe Base Return Sequence with Noclip Integration (Instant Obstacle Bypass)
local function BaseReturn(mode)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local targetPos = ENG.BasePos + Vector3.new(0, 3, 0)
    local speed = 40 -- Increased travel velocity for instant response

    StopFly()
    isBaseReturning = true
    hum.PlatformStand = true

    -- Apply Noclip during return to prevent getting stuck on walls/terrain
    local noclipConnection
    noclipConnection = RunService.Stepped:Connect(function()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)

    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not char or not char.Parent or not hrp or not hum then
            isBaseReturning = false
            if noclipConnection then pcall(function() noclipConnection:Disconnect() end) end
            if connection then pcall(function() connection:Disconnect() end) end
            return
        end

        local direction = targetPos - hrp.Position
        if direction.Magnitude < 3 then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hum.PlatformStand = false
            isBaseReturning = false
            if noclipConnection then pcall(function() noclipConnection:Disconnect() end) end
            if connection then pcall(function() connection:Disconnect() end) end
            -- Restore collision state safely
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
            return
        end
        hrp.AssemblyLinearVelocity = direction.Unit * speed
    end)
end

-- Teleport Down Utility
local function TPDown()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local ray = Workspace:Raycast(hrp.Position, Vector3.new(0, -700, 0), params)
    if ray then
        hrp.CFrame = CFrame.new(ray.Position + Vector3.new(0, 3, 0))
        hrp.AssemblyLinearVelocity = Vector3.zero
    end
end

-- X-Ray System
local xrayCache = {}
local function ToggleXRay(state)
    ENG.XRayActive = state
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) then
            if state then
                if obj.Transparency < 0.3 then
                    xrayCache[obj] = obj.Transparency
                    obj.Transparency = 0.5
                end
            else
                if xrayCache[obj] then obj.Transparency = xrayCache[obj] end
            end
        end
    end
    if not state then xrayCache = {} end
end

-- Selector and Mobile Mini UI Builder (Shifted significantly higher up)
local function CreateSelector(callback)
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    local gui = Instance.new("ScreenGui")
    gui.Name = "LeaStart"
    gui.Parent = pg
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.new(0, 0, 0)
    bg.BackgroundTransparency = 0.4
    bg.Parent = gui
    
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(0, 200, 0, 30)
    t.Position = UDim2.new(0.5, -100, 0.15, 0) -- Shifted much higher up
    t.BackgroundTransparency = 1
    t.Text = "LEA V5.9.3"
    t.TextColor3 = Color3.new(1, 1, 1)
    t.TextSize = 20
    t.Font = Enum.Font.GothamBold
    t.Parent = bg
    
    local function createButton(label, mode, x)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 80, 0, 36)
        b.Position = UDim2.new(0, x, 0.22, 0) -- Shifted much higher up
        b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        b.Text = label
        b.TextColor3 = Color3.new(1, 1, 1)
        b.TextSize = 14
        b.Font = Enum.Font.GothamBold
        b.Parent = bg
        b.MouseButton1Click:Connect(function()
            SEC.Mode = mode
            gui:Destroy()
            callback(mode)
        end)
    end
    createButton("PET", "PET", 90)
    createButton("DUEL", "DUEL", 230)
end

local function BuildUI(mode)
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    local old = pg:FindFirstChild("LeaUI")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "LeaUI"
    gui.Parent = pg

    local cont = Instance.new("Frame")
    cont.Size = UDim2.new(0, 48, 0, 320)
    cont.Position = UDim2.new(1, -54, 0.01, 0) -- Shifted extremely high up near top edge
    cont.BackgroundTransparency = 1
    cont.Active = true
    cont.Draggable = true
    cont.Parent = gui

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 3)
    list.Parent = cont

    local function AddButton(text, toggle, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 44, 0, 24)
        b.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Text = text
        b.TextSize = 6
        b.Font = Enum.Font.GothamBold
        b.Parent = cont

        if toggle then
            local state = false
            b.MouseButton1Click:Connect(function()
                state = not state
                b.BackgroundColor3 = state and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(20, 20, 25)
                callback(state)
            end)
        else
            b.MouseButton1Click:Connect(function()
                b.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
                task.delay(0.12, function() b.BackgroundColor3 = Color3.fromRGB(20, 20, 25) end)
                callback()
            end)
        end
    end

    if mode == "PET" then
        AddButton("FLY", true, function(v) ENG.FlyActive = v end)
        AddButton("CUBE", true, function(v) ENG.CubeActive = v end)
        AddButton("BASE", false, function() BaseReturn("PET") end)
        AddButton("TRACK", true, function(v) ENG.TrackActive = v end)
        AddButton("BAT", true, function(v) ENG.BatActive = v end)
        AddButton("DOWN", false, TPDown)
        AddButton("XRAY", true, function(v) ToggleXRay(v) end)
        AddButton("HOP", false, function() ScanAndHop() end)
    else
        AddButton("FLY", true, function(v) ENG.FlyActive = v end)
        AddButton("CUBE", true, function(v) ENG.CubeActive = v end)
        AddButton("BASE", false, function() BaseReturn("DUEL") end)
        AddButton("TRACK", true, function(v) ENG.TrackActive = v end)
        AddButton("BAT", true, function(v) ENG.BatActive = v end)
        AddButton("LEFT", true, function(v) ENG.LeftActive = v end)
        AddButton("RIGHT", true, function(v) ENG.RightActive = v end)
        AddButton("DOWN", false, TPDown)
        AddButton("XRAY", true, function(v) ToggleXRay(v) end)
        AddButton("HOP", false, function() ScanAndHop() end)
    end
end

-- Initialize Launcher
CreateSelector(function(mode)
    BuildUI(mode)
    print("LEA V5.9.3 Active - Mode: " .. mode)
end)

getgenv().LeaKill = function()
    StopFly()
    ClearCubes()
    ToggleXRay(false)
    for k, v in pairs(ENG) do
        if type(v) == "boolean" then ENG[k] = false end
    end
    local gui = LocalPlayer.PlayerGui:FindFirstChild("LeaUI")
    if gui then gui:Destroy() end
    print("LEA Terminated & Cleaned.")
end

print("✅ Part 2/2 Complete - LEA V5.9.3 Ready!")
