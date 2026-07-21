-- ==============================================================================
-- LEA MOD ULTIMATE V50.1 - REFACTORED ENGINE (ANTI-RESET + FLY BASE)
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

-- Safely purge previous connection threads
if getgenv().LeaModGlobalState and getgenv().LeaModGlobalState.Connections then
    for _, conn in ipairs(getgenv().LeaModGlobalState.Connections) do
        pcall(function() conn:Disconnect() end)
    end
end

-- Global State Setup
getgenv().LeaModGlobalState = {
    Version = "50.1-CONFIGURABLE-BASE",
    AutoAttack = false,
    AutoAttackLastTime = 0,
    AutoAttackCooldown = 0.4,
    AutoMedusa = false,
    AutoMedusaLastTime = 0,
    MedusaCooldown = 0.8,
    CubeActive = false,
    CubeList = {},
    LastCubeTime = 0,
    CubeSpawnRate = 0.3,
    CubeLimit = 20,
    ThemeColor = Color3.fromRGB(0, 255, 200),
    Connections = {},
    EspActive = false,
    Noclip = false,
    IsReturning = false,
    CustomBasePosition = nil,
    ReturnSpeed = 23 -- Fixed travel speed target
}

local State = getgenv().LeaModGlobalState

-- ==============================================================================
-- 1. UTILITY & CONNECTION MANAGER
-- ==============================================================================
local function SafeConnect(signal, callback)
    local conn = signal:Connect(callback)
    table.insert(State.Connections, conn)
    return conn
end

local function GetCharacter()
    local char = LocalPlayer.Character
    if char and char:Parent() and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") then
        return char, char.HumanoidRootPart, char:FindFirstChildOfClass("Humanoid")
    end
    return nil, nil, nil
end

-- ==============================================================================
-- 2. ANTI-RESET & CHARACTER PROTECTION
-- ==============================================================================
local function ProtectCharacter(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        -- Anti-Reset: Intercept local health depletion calls
        local healthConn = hum.HealthChanged:Connect(function(health)
            if health <= 0 and hum:GetState() ~= Enum.HumanoidStateType.Dead then
                pcall(function()
                    hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                end)
            end
        end)
        table.insert(State.Connections, healthConn)
    end
end

if LocalPlayer.Character then ProtectCharacter(LocalPlayer.Character) end
SafeConnect(LocalPlayer.CharacterAdded, ProtectCharacter)

-- Auto-initialize base position on spawn
local function InitDefaultBase()
    local _, hrp = GetCharacter()
    if hrp and not State.CustomBasePosition then
        State.CustomBasePosition = hrp.Position
    end
end

if LocalPlayer.Character then InitDefaultBase() end
SafeConnect(LocalPlayer.CharacterAdded, function()
    task.wait(1)
    InitDefaultBase()
end)

-- ==============================================================================
-- 3. CONFIGURABLE SMOOTH FLY RETURN ENGINE (SPEED: 23)
-- ==============================================================================
local function StartSmoothReturn()
    if State.IsReturning then return end
    
    local targetBase = State.CustomBasePosition
    if not targetBase then
        local _, hrp = GetCharacter()
        if hrp then
            targetBase = hrp.Position
            State.CustomBasePosition = targetBase
        else
            return
        end
    end

    local char, hrp, hum = GetCharacter()
    if not char or not hrp or not hum then return end

    State.IsReturning = true

    -- Setup flight mechanics
    local bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bodyVel.Velocity = Vector3.zero
    bodyVel.Parent = hrp

    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    bodyGyro.P = 10000
    bodyGyro.CFrame = hrp.CFrame
    bodyGyro.Parent = hrp

    local destination = targetBase + Vector3.new(0, 3, 0)
    local connection

    connection = SafeConnect(RunService.Heartbeat, function()
        local currentChar, currentHrp, currentHum = GetCharacter()
        
        -- Cancel flight if character dies or return state toggles off
        if not currentChar or not currentHrp or not State.IsReturning or currentHum.Health <= 0 then
            if connection then connection:Disconnect() end
            bodyVel:Destroy()
            bodyGyro:Destroy()
            State.IsReturning = false
            return
        end

        -- Noclip during flight to prevent getting stuck in walls
        for _, part in ipairs(currentChar:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end

        local currentPos = currentHrp.Position
        local vecToTarget = (destination - currentPos)
        local distance = vecToTarget.Magnitude

        -- Raycast to detect path obstacles and add elevation
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {currentChar}
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude

        local rayResult = Workspace:Raycast(currentPos, vecToTarget.Unit * 6, raycastParams)
        local activeTarget = destination
        if rayResult and distance > 10 then
            activeTarget = destination + Vector3.new(0, 12, 0) -- Lift up over obstacles
        end

        if distance <= 2.5 then
            -- Safe arrival
            bodyVel:Destroy()
            bodyGyro:Destroy()
            currentHrp.AssemblyLinearVelocity = Vector3.zero
            State.IsReturning = false
            if connection then connection:Disconnect() end
        else
            local flightDirection = (activeTarget - currentPos).Unit
            bodyVel.Velocity = flightDirection * State.ReturnSpeed -- Fixed speed 23
            bodyGyro.CFrame = CFrame.lookAt(currentPos, currentPos + flightDirection)
        end
    end)
end

State.ReturnToSpawnFast = StartSmoothReturn

-- ==============================================================================
-- 4. CORE ENGINE LOOPS (NOCLIP & CUBE PLATFORM)
-- ==============================================================================

-- Low-overhead Noclip Loop
SafeConnect(RunService.Stepped, function()
    if not State.Noclip or State.IsReturning then return end
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- Automation & Cube Handler
SafeConnect(RunService.Heartbeat, function()
    local char, hrp, hum = GetCharacter()
    if not char or not hrp or hum.Health <= 0 then return end

    if State.CubeActive and not State.IsReturning then
        local now = tick()
        local vel = hrp.AssemblyLinearVelocity
        if (vel.Y < -4 or vel.Magnitude > 3) and (now - State.LastCubeTime > State.CubeSpawnRate) then
            if #State.CubeList >= State.CubeLimit then
                local oldCube = table.remove(State.CubeList, 1)
                if oldCube and oldCube.Parent then oldCube:Destroy() end
            end

            local cube = Instance.new("Part")
            cube.Name = "LeaCube"
            cube.Size = Vector3.new(4, 0.4, 4)
            cube.Position = hrp.Position - Vector3.new(0, 3, 0)
            cube.Anchored = true
            cube.CanCollide = true
            cube.Transparency = 0.6
            cube.Material = Enum.Material.SmoothPlastic
            cube.Color = State.ThemeColor
            cube.Parent = Workspace

            table.insert(State.CubeList, cube)
            State.LastCubeTime = now
        end
    end
end)

-- ==============================================================================
-- 5. INTERFACE INITIALIZATION
-- ==============================================================================
local function GetGuiParent()
    local success, parent = pcall(function() return CoreGui end)
    if success and parent then return parent end
    return LocalPlayer:WaitForChild("PlayerGui", 5)
end

local GuiParent = GetGuiParent()
if GuiParent:FindFirstChild("LeaModMegaGUI") then
    GuiParent.LeaModMegaGUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LeaModMegaGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = GuiParent

local MainContainer = Instance.new("Frame", ScreenGui)
MainContainer.Size = UDim2.new(0, 160, 0, 210)
MainContainer.Position = UDim2.new(0.5, -80, 0.35, 0)
MainContainer.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
MainContainer.Active = true
MainContainer.Draggable = true

Instance.new("UICorner", MainContainer).CornerRadius = UDim.new(0, 6)
local UIStroke = Instance.new("UIStroke", MainContainer)
UIStroke.Color = State.ThemeColor
UIStroke.Thickness = 1

local ScrollContainer = Instance.new("ScrollingFrame", MainContainer)
ScrollContainer.Size = UDim2.new(1, -6, 1, -10)
ScrollContainer.Position = UDim2.new(0, 3, 0, 5)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.ScrollBarThickness = 2
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 230)

local ListLayout = Instance.new("UIListLayout", ScrollContainer)
ListLayout.Padding = UDim.new(0, 4)
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateButton(text, callback)
    local btn = Instance.new("TextButton", ScrollContainer)
    btn.Size = UDim2.new(1, -2, 0, 22)
    btn.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 8
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    btn.MouseButton1Click:Connect(function() pcall(callback, btn) end)
    return btn
end

-- Interface Buttons
CreateButton("📍 SET CURRENT POS AS BASE", function(btn)
    local _, hrp = GetCharacter()
    if hrp then
        State.CustomBasePosition = hrp.Position
        btn.Text = "✅ BASE POSITION SAVED!"
        task.delay(1.5, function()
            btn.Text = "📍 SET CURRENT POS AS BASE"
        end)
    end
end)

CreateButton("✈️ RETURN TO BASE (SPD 23)", function()
    StartSmoothReturn()
end)

CreateButton("🧊 CUBE PLATFORM: OFF", function(btn)
    State.CubeActive = not State.CubeActive
    btn.Text = State.CubeActive and "🧊 CUBE PLATFORM: ON" or "🧊 CUBE PLATFORM: OFF"
    btn.TextColor3 = State.CubeActive and State.ThemeColor or Color3.fromRGB(255, 255, 255)

    if not State.CubeActive then
        for _, cube in ipairs(State.CubeList) do
            if cube and cube.Parent then cube:Destroy() end
        end
        State.CubeList = {}
    end
end)

CreateButton("👻 NOCLIP: OFF", function(btn)
    State.Noclip = not State.Noclip
    btn.Text = State.Noclip and "👻 NOCLIP: ON" or "👻 NOCLIP: OFF"
    btn.TextColor3 = State.Noclip and State.ThemeColor or Color3.fromRGB(255, 255, 255)
end)

print("✅ [LEA MOD]: ANTI-RESET & SMOOTH BASE ENGINE LOADED SUCCESSFULLY.")
