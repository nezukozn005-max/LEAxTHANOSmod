-- ==============================================================================
-- LEA MOD ULTIMATE V50.1 - FULL REFACTOR (PLATFORM CUBE & AUTO SYSTEMS INCLUDED)
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

-- Clear existing threads/connections safely
if getgenv().LeaModGlobalState and getgenv().LeaModGlobalState.Connections then
    for _, conn in ipairs(getgenv().LeaModGlobalState.Connections) do
        pcall(function() conn:Disconnect() end)
    end
end

-- Global State Registry
getgenv().LeaModGlobalState = {
    Version = "50.1-PLATFORM",
    AutoAttack = false,
    AutoAttackLastTime = 0,
    AutoAttackCooldown = 0.35,
    AutoMedusa = false,
    AutoMedusaLastTime = 0,
    MedusaCooldown = 0.75,
    CubeActive = false,
    PlatformPart = nil,
    ThemeColor = Color3.fromRGB(0, 255, 200),
    Connections = {},
    EspActive = false,
    Visuals = false,
    Noclip = false,
    IsReturning = false,
    CustomBasePosition = nil,
    ReturnSpeed = 23
}

local State = getgenv().LeaModGlobalState

-- ==============================================================================
-- 1. UTILITIES & CHARACTER MANAGEMENT
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

local function ProtectCharacter(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        local conn = hum.HealthChanged:Connect(function(health)
            if health <= 0 and hum:GetState() ~= Enum.HumanoidStateType.Dead then
                pcall(function()
                    hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                end)
            end
        end)
        table.insert(State.Connections, conn)
    end
end

if LocalPlayer.Character then ProtectCharacter(LocalPlayer.Character) end
SafeConnect(LocalPlayer.CharacterAdded, ProtectCharacter)

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
-- 2. DYNAMIC PLATFORM (CUBE) SUBSYSTEM
-- ==============================================================================
local function DestroyPlatform()
    if State.PlatformPart and State.PlatformPart:IsA("BasePart") then
        pcall(function() State.PlatformPart:Destroy() end)
    end
    State.PlatformPart = nil
end

local function UpdatePlatform()
    if not State.CubeActive then
        DestroyPlatform()
        return
    end

    local char, hrp = GetCharacter()
    if not char or not hrp then return end

    if not State.PlatformPart or not State.PlatformPart.Parent then
        local part = Instance.new("Part")
        part.Name = "LeaMod_PlatformCube"
        part.Size = Vector3.new(6, 1, 6)
        part.Anchored = true
        part.CanCollide = true
        part.Material = Enum.Material.Neon
        part.Color = State.ThemeColor
        part.Transparency = 0.3
        part.Parent = Workspace
        State.PlatformPart = part
    end

    -- Position the platform right below the player's feet
    State.PlatformPart.CFrame = CFrame.new(hrp.Position - Vector3.new(0, 3.5, 0))
end

-- ==============================================================================
-- 3. TOOL & AUTOMATION SYSTEMS
-- ==============================================================================
local function FindAndEquipTool(keyword)
    local char = LocalPlayer.Character
    if not char then return false end
    
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():find(keyword:lower()) then
            return true
        end
    end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower():find(keyword:lower()) then
                pcall(function() tool.Parent = char end)
                task.wait(0.02)
                return true
            end
        end
    end
    return false
end

local function GetNearestPlayer(maxDistance)
    local nearest = nil
    local shortestDistance = maxDistance or 60
    local _, myHrp = GetCharacter()
    if not myHrp then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local dist = (myHrp.Position - hrp.Position).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    nearest = player
                end
            end
        end
    end
    return nearest
end

-- ==============================================================================
-- 4. BASE RETURN ENGINE
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
        
        if not currentChar or not currentHrp or not State.IsReturning or currentHum.Health <= 0 then
            if connection then connection:Disconnect() end
            bodyVel:Destroy()
            bodyGyro:Destroy()
            State.IsReturning = false
            return
        end

        local currentPos = currentHrp.Position
        local vecToTarget = (destination - currentPos)
        local distance = vecToTarget.Magnitude

        if distance <= 2.5 then
            bodyVel:Destroy()
            bodyGyro:Destroy()
            currentHrp.AssemblyLinearVelocity = Vector3.zero
            State.IsReturning = false
            if connection then connection:Disconnect() end
        else
            local flightDirection = vecToTarget.Unit
            bodyVel.Velocity = flightDirection * State.ReturnSpeed
            bodyGyro.CFrame = CFrame.lookAt(currentPos, currentPos + flightDirection)
        end
    end)
end

-- ==============================================================================
-- 5. MAIN EXECUTION LOOPS
-- ==============================================================================
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

SafeConnect(RunService.Heartbeat, function()
    -- Update platform position if enabled
    UpdatePlatform()

    local char, hrp, hum = GetCharacter()
    if not char or not hrp or hum.Health <= 0 then return end

    local nearestTarget = GetNearestPlayer(45)
    if nearestTarget and nearestTarget.Character and nearestTarget.Character:FindFirstChild("HumanoidRootPart") then
        local targetHrp = nearestTarget.Character.HumanoidRootPart
        local dist = (hrp.Position - targetHrp.Position).Magnitude
        
        -- Auto Medusa
        if State.AutoMedusa and dist <= 18 then
            local now = tick()
            if now - State.AutoMedusaLastTime >= State.MedusaCooldown then
                if FindAndEquipTool("medusa") then
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") and tool.Name:lower():find("medusa") then
                            pcall(function() tool:Activate() end)
                            State.AutoMedusaLastTime = now
                            break
                        end
                    end
                end
            end
        end
        
        -- Auto Attack
        if State.AutoAttack then
            local now = tick()
            if now - State.AutoAttackLastTime >= State.AutoAttackCooldown then
                State.AutoAttackLastTime = now
                if FindAndEquipTool("pet") or FindAndEquipTool("bad") or FindAndEquipTool("weapon") then
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            pcall(function() tool:Activate() end)
                            break
                        end
                    end
                end
            end
        end
    end
end)

-- ESP Loop
local espTimer = 0
SafeConnect(RunService.Heartbeat, function(dt)
    espTimer = espTimer + dt
    if espTimer >= 1.0 then
        espTimer = 0
        if State.Visuals and State.EspActive then
            pcall(function()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local c = player.Character
                        local highlight = c:FindFirstChild("LeaMegaESP")
                        if not highlight then
                            highlight = Instance.new("Highlight")
                            highlight.Name = "LeaMegaESP"
                            highlight.FillColor = Color3.fromRGB(255, 0, 80)
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            highlight.FillTransparency = 0.5
                            highlight.OutlineTransparency = 0
                            highlight.Parent = c
                        end
                    end
                end
            end)
        end
    end
end)

-- ==============================================================================
-- 6. MOBILE-FRIENDLY GUI MOUNTING ENGINE
-- ==============================================================================
local function GetGuiParent()
    if gethui then
        local success, res = pcall(gethui)
        if success and res then return res end
    end
    local success, res = pcall(function() return CoreGui end)
    if success and res then return res end
    return LocalPlayer:WaitForChild("PlayerGui", 5)
end

local TargetParent = GetGuiParent()
if TargetParent:FindFirstChild("LeaModMegaGUI") then
    TargetParent.LeaModMegaGUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LeaModMegaGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = TargetParent

local MainContainer = Instance.new("Frame", ScreenGui)
MainContainer.Name = "MainContainer"
MainContainer.Size = UDim2.new(0, 165, 0, 240)
MainContainer.Position = UDim2.new(0.5, -82, 0.25, 0)
MainContainer.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
MainContainer.BorderSizePixel = 0
MainContainer.Active = true
MainContainer.Draggable = true

Instance.new("UICorner", MainContainer).CornerRadius = UDim.new(0, 6)
local MainStroke = Instance.new("UIStroke", MainContainer)
MainStroke.Color = State.ThemeColor
MainStroke.Thickness = 1

local HeaderFrame = Instance.new("Frame", MainContainer)
HeaderFrame.Size = UDim2.new(1, 0, 0, 22)
HeaderFrame.BackgroundColor3 = Color3.fromRGB(4, 4, 8)
HeaderFrame.BorderSizePixel = 0

local TitleLabel = Instance.new("TextLabel", HeaderFrame)
TitleLabel.Size = UDim2.new(1, -22, 1, 0)
TitleLabel.Position = UDim2.new(0, 6, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "LEA V50.1 ULTIMATE"
TitleLabel.TextColor3 = State.ThemeColor
TitleLabel.TextSize = 9
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", HeaderFrame)
CloseBtn.Size = UDim2.new(0, 18, 0, 18)
CloseBtn.Position = UDim2.new(1, -20, 0, 2)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 8
CloseBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

local ScrollContainer = Instance.new("ScrollingFrame", MainContainer)
ScrollContainer.Size = UDim2.new(1, -6, 1, -26)
ScrollContainer.Position = UDim2.new(0, 3, 0, 24)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.ScrollBarThickness = 2
ScrollContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)

local ListLayout = Instance.new("UIListLayout", ScrollContainer)
ListLayout.Padding = UDim.new(0, 4)
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 36, 0, 36)
ToggleBtn.Position = UDim2.new(1, -42, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
ToggleBtn.Text = "LEA"
ToggleBtn.TextColor3 = State.ThemeColor
ToggleBtn.TextSize = 9
ToggleBtn.Font = Enum.Font.GothamBlack
ToggleBtn.Visible = false
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)
local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Color = State.ThemeColor
ToggleStroke.Thickness = 1

CloseBtn.MouseButton1Click:Connect(function()
    MainContainer.Visible = false
    ToggleBtn.Visible = true
end)

ToggleBtn.MouseButton1Click:Connect(function()
    MainContainer.Visible = true
    ToggleBtn.Visible = false
end)

local function CreateToggleButton(order, text, callback)
    local btn = Instance.new("TextButton", ScrollContainer)
    btn.LayoutOrder = order
    btn.Size = UDim2.new(1, -2, 0, 22)
    btn.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 8
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.Text = text .. (active and ": ON" or ": OFF")
        btn.TextColor3 = active and State.ThemeColor or Color3.fromRGB(255, 255, 255)
        pcall(callback, active)
    end)
    return btn
end

local function CreateActionButton(order, text, callback)
    local btn = Instance.new("TextButton", ScrollContainer)
    btn.LayoutOrder = order
    btn.Size = UDim2.new(1, -2, 0, 22)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 8
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    btn.MouseButton1Click:Connect(function()
        pcall(callback, btn)
    end)
    return btn
end

-- ==============================================================================
-- 7. MENU CONTROLS BINDING
-- ==============================================================================
CreateToggleButton(1, "⚔️ AUTO ATTACK", function(on)
    State.AutoAttack = on
end)

CreateToggleButton(2, "🐍 AUTO MEDUSA", function(on)
    State.AutoMedusa = on
end)

CreateToggleButton(3, "🧊 CUBE PLATFORM", function(on)
    State.CubeActive = on
    if not on then DestroyPlatform() end
end)

CreateActionButton(4, "📍 SET POS AS BASE", function(btn)
    local _, hrp = GetCharacter()
    if hrp then
        State.CustomBasePosition = hrp.Position
        btn.Text = "✅ BASE SAVED!"
        task.delay(1.2, function()
            btn.Text = "📍 SET POS AS BASE"
        end)
    end
end)

CreateActionButton(5, "✈️ RETURN TO BASE", function()
    StartSmoothReturn()
end)

CreateToggleButton(6, "👻 NOCLIP", function(on)
    State.Noclip = on
end)

CreateToggleButton(7, "👁️ ESP VISUALS", function(on)
    State.Visuals = on
    State.EspActive = on
    if not on then
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("LeaMegaESP") then
                p.Character.LeaMegaESP:Destroy()
            end
        end
    end
end)

print("✅ [LEA MOD V50.1]: FULL REFACTOR WITH CUBE PLATFORM LOADED.")
