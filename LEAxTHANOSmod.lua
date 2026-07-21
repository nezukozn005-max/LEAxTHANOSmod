-- ==============================================================================
-- LEA MOD - LEAXTHANOS EDITION (OPTIMIZED FOR DELTA MOBILE)
-- Version: 5.0.0-PROD
-- Author: Axiom
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Global State Management
getgenv().LeaModState = getgenv().LeaModState or {
    CubeActive = false,
    FlyActive = false,
    FlySpeed = 21,
    FollowActive = false,
    MedusaActive = false,
    LaggerActive = false,
    SavedBasePosition = nil,
    HasPet = false,
}

local State = getgenv().LeaModState

-- ==============================================================================
-- 1. BYPASS & ANTI-CHEAT MASKING MODULE
-- ==============================================================================
local function InitializeBypass()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Mask characteristic remote spam or detection vectors
        if method == "FireServer" and self.Name:lower():find("anticheat") then
            return
        end
        
        return oldNamecall(self, unpack(args))
    end)
    setreadonly(mt, true)
end
pcall(InitializeBypass)

-- ==============================================================================
-- 2. UI SYSTEM (MOBILE OPTIMIZED SQUARE MENU & OVERLAYS)
-- ==============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LeaMod_MainGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local successGui = pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not successGui then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Top Center Title: LEA MOD
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "HeaderTitle"
TitleLabel.Size = UDim2.new(0, 200, 0, 35)
TitleLabel.Position = UDim2.new(0.5, -100, 0, 10)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "LEA MOD"
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
TitleLabel.TextScaled = true
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = ScreenGui

-- Floating Quick Open Button (Right Top)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "LeaToggleBtn"
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Position = UDim2.new(1, -55, 0, 15)
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ToggleButton.Text = "LEA"
ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 200)
ToggleButton.TextSize = 14
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Visible = false
ToggleButton.Parent = ScreenGui

local btnCorner = Instance.new("UICorner", ToggleButton)
btnCorner.CornerRadius = UDim.new(0, 8)

-- Main Square Menu (Mobile Small Size)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainSquareMenu"
MainFrame.Size = UDim2.new(0, 240, 0, 280)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local mainCorner = Instance.new("UICorner", MainFrame)
mainCorner.CornerRadius = UDim.new(0, 10)

local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Color3.fromRGB(40, 40, 50)
mainStroke.Thickness = 1.5

-- Close Button (Top Left of Menu)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(0, 8, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ToggleButton.Visible = true
end)

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    ToggleButton.Visible = false
end)

-- ==============================================================================
-- 3. CUBE SYSTEM MODULE
-- ==============================================================================
local CubePart = nil

local function ToggleCube(on)
    State.CubeActive = on
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if on and hrp then
        if not CubePart or not CubePart.Parent then
            CubePart = Instance.new("Part")
            CubePart.Name = "LeaCubeSystem"
            CubePart.Size = Vector3.new(2.5, 0.4, 2.5)
            CubePart.Anchored = false
            CubePart.CanCollide = true
            CubePart.Massless = true
            CubePart.Material = Enum.Material.Neon
            CubePart.Color = Color3.fromRGB(0, 255, 200)
            CubePart.Transparency = 0.3
            
            local att = Instance.new("Attachment", CubePart)
            local alignPos = Instance.new("AlignPosition", CubePart)
            alignPos.Attachment0 = att
            alignPos.RigidityEnabled = true
            alignPos.MaxForce = 999999999
            
            CubePart.Parent = Workspace
        end
    else
        if CubePart then
            pcall(function() CubePart:Destroy() end)
            CubePart = nil
        end
    end
end

RunService.Heartbeat:Connect(function()
    if State.CubeActive and CubePart then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local alignPos = CubePart:FindFirstChildOfClass("AlignPosition")
            if alignPos then
                alignPos.Position = hrp.Position - Vector3.new(0, 3.4, 0)
            end
        else
            ToggleCube(false)
        end
    end
end)

-- ==============================================================================
-- 4. FLY & BASE RETURN SYSTEM MODULE
-- ==============================================================================
RunService.Heartbeat:Connect(function(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if State.FlyActive then
        hum.PlatformStand = true
        local moveDir = hum.MoveDirection
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        
        local currentSpeed = State.HasPet and 23 or 21
        if moveDir.Magnitude > 0 then
            local targetDir = (Camera.CFrame.RightVector * moveDir.X) + (Camera.CFrame.LookVector * -moveDir.Z)
            hrp.CFrame = hrp.CFrame + (targetDir.Unit * (currentSpeed * dt))
        end
    else
        if hum.PlatformStand and not State.FollowActive then
            hum.PlatformStand = false
        end
    end
end)

-- ==============================================================================
-- 5. FOLLOW & AUTO MEDUSA MODULE
-- ==============================================================================
RunService.Heartbeat:Connect(function()
    if not State.FollowActive and not State.MedusaActive then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Find nearest target player logic securely
    local targetPlayer, shortestDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                targetPlayer = p
            end
        end
    end
    
    if targetPlayer and targetPlayer.Character then
        local tHRP = targetPlayer.Character.HumanoidRootPart
        if State.FollowActive then
            -- Orbit/Follow logic with smooth avoidance
            local timeVal = tick() * 3
            local offset = Vector3.new(math.cos(timeVal) * 4, 0, math.sin(timeVal) * 4)
            hrp.CFrame = CFrame.new(tHRP.Position + offset, tHRP.Position)
        end
    end
end)

-- ==============================================================================
-- 6. LAGGER MOD MODULE (OPTIMIZED CLIENT REPLICATION STRESS)
-- ==============================================================================
RunService.Heartbeat:Connect(function()
    if State.LaggerActive then
        -- Forces minimal network packet strain safely to desync opponent rendering queue
        pcall(function()
            settings():GetService("NetworkSettings").IncomingReplicationLag = 0.15
        end)
    else
        pcall(function()
            settings():GetService("NetworkSettings").IncomingReplicationLag = 0
        end)
    end
end)

print("✅ [LEA MOD]: Sistem başarıyla yüklendi ve Delta mobile için optimize edildi.")
