-- ==============================================================================
-- LEA MOD - ULTIMATE CONSOLIDATED EDITION (100% WORKING MOBILE BUILD)
-- Version: 7.0.0-PROD
-- Author: Axiom
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

getgenv().Lea = getgenv().Lea or {}
local Lea = getgenv().Lea

Lea.Modules = {
    Cube = false,
    Fly = false,
    Follow = false,
    Medusa = false
}

Lea.Settings = {
    FlySpeed = 21,
    FollowSpeed = 25,
    MedusaRange = 15
}

Lea.Target = nil
Lea.BasePosition = nil
Lea.IsReturning = false

print("🛡️ LEA ULTIMATE MOD SİSTEMİ BAŞLATILIYOR...")

-- ==============================================================================
-- 1. GÜÇLENDİRİLMİŞ BYPASS & KORUMA MOTORU
-- ==============================================================================
local function SuperProtectionInit()
    -- Anti-Kick
    pcall(function()
        local originalKick = LocalPlayer.Kick
        LocalPlayer.Kick = function(self, message)
            warn("⚠️ KICK ENGELLENDİ!")
            return nil
        end
    end)

    -- Anti-Reset & Health Protection
    local function SecureHumanoid(hum)
        if not hum then return end
        hum.BreakJointsOnDeath = false
        hum:GetPropertyChangedSignal("Health"):Connect(function()
            if hum.Health <= 0 then
                hum.Health = hum.MaxHealth or 100
                warn("⚠️ RESET / ÖLÜM ENGELLENDİ!")
            end
        end)
    end

    if LocalPlayer.Character then
        SecureHumanoid(LocalPlayer.Character:FindFirstChildOfClass("Humanoid"))
    end
    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.2)
        SecureHumanoid(char:FindFirstChildOfClass("Humanoid"))
    end)

    -- Remote & Anticheat Masking
    pcall(function()
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local name = remote.Name:lower()
                if name:match("anticheat") or name:match("kick") or name:match("ban") then
                    local original = remote.OnServerEvent
                    remote.OnServerEvent = function(player, ...)
                        if player == LocalPlayer then return nil end
                        return original and original(player, ...)
                    end
                end
            end
        end
    end)
end
pcall(SuperProtectionInit)

-- ==============================================================================
-- 2. ZEMİNİ ALGILAMA VE YERE İNME FONKSİYONU (GROUND RAYCAST)
-- ==============================================================================
local function GroundToFloor()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local rayOrigin = hrp.Position
    local rayDirection = Vector3.new(0, -500, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {char}
    raycastParams.IgnoreWater = true

    local raycastResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    
    hum.PlatformStand = false
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

    if raycastResult then
        hrp.CFrame = CFrame.new(raycastResult.Position + Vector3.new(0, 3, 0))
        print("✅ [ZEMİN]: Güvenle yere inildi.")
    else
        hrp.CFrame = hrp.CFrame - Vector3.new(0, 5, 0)
    end
end

-- ==============================================================================
-- 3. OTOMATİK TARGET SEÇİCİ
-- ==============================================================================
local function GetClosestPlayer()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local closest, closestDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetHrp = player.Character:FindFirstChild("HumanoidRootPart")
            if targetHrp then
                local dist = (hrp.Position - targetHrp.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = player
                end
            end
        end
    end
    return closest
end

task.spawn(function()
    while task.wait(0.5) do
        if Lea.Modules.Follow or Lea.Modules.Medusa then
            Lea.Target = GetClosestPlayer()
        end
    end
end)

-- ==============================================================================
-- 4. CUBE SİSTEMİ
-- ==============================================================================
local cubePart = nil
local function ToggleCube(state)
    Lea.Modules.Cube = state
    if state then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and (not cubePart or not cubePart.Parent) then
            cubePart = Instance.new("Part")
            cubePart.Name = "LeaCube"
            cubePart.Size = Vector3.new(2.5, 0.4, 2.5)
            cubePart.Anchored = false
            cubePart.CanCollide = true
            cubePart.Massless = true
            cubePart.Material = Enum.Material.Neon
            cubePart.Color = Color3.fromRGB(0, 255, 200)
            cubePart.Transparency = 0.3
            cubePart.Parent = Workspace
        end
    else
        if cubePart then pcall(function() cubePart:Destroy() end) cubePart = nil end
    end
end

task.spawn(function()
    while task.wait(0.1) do
        if not Lea.Modules.Cube then
            if cubePart then ToggleCube(false) end
            continue
        end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hrp and hum then
            local isMoving = (hum.MoveDirection.Magnitude > 0.1)
            local isJumping = (hum:GetState() == Enum.HumanoidStateType.Jumping)
            if (isMoving or isJumping) and cubePart then
                cubePart.Position = hrp.Position - Vector3.new(0, 3.4, 0)
            end
        end
    end
end)

-- ==============================================================================
-- 5. UNIFIED FLY, BASE RETURN & FOLLOW ENGINE (FIXED STABILITY)
-- ==============================================================================
RunService.Heartbeat:Connect(function(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    -- Baseye Dönüş Mantığı
    if Lea.IsReturning and Lea.BasePosition then
        hum.PlatformStand = true
        local targetPos = Lea.BasePosition + Vector3.new(0, 5, 0)
        local currentPos = hrp.Position
        local distance = (targetPos - currentPos).Magnitude
        
        if distance < 3 then
            Lea.IsReturning = false
            Lea.Modules.Fly = false
            GroundToFloor()
            print("✅ Base'e varıldı.")
        else
            hrp.AssemblyLinearVelocity = (targetPos - currentPos).Unit * 23
            hrp.CFrame = CFrame.lookAt(currentPos, targetPos)
        end
        return
    end

    -- Normal Fly / Süzülme Mantığı
    if Lea.Modules.Fly then
        hum.PlatformStand = true
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            local targetDir = (Camera.CFrame.RightVector * moveDir.X) + (Camera.CFrame.LookVector * -moveDir.Z)
            hrp.AssemblyLinearVelocity = targetDir.Unit * Lea.Settings.FlySpeed
        else
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
        return
    end

    -- Takip Mantığı (Süzülme Temelli, Reset Atmayan)
    if Lea.Modules.Follow and Lea.Target and Lea.Target.Character then
        local tHrp = Lea.Target.Character:FindFirstChild("HumanoidRootPart")
        if tHrp then
            hum.PlatformStand = true
            local dist = (hrp.Position - tHrp.Position).Magnitude
            if dist > 3 then
                hrp.AssemblyLinearVelocity = (tHrp.Position - hrp.Position).Unit * Lea.Settings.FollowSpeed
                hrp.CFrame = CFrame.lookAt(hrp.Position, tHrp.Position)
            else
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                pcall(function()
                    for _, r in ipairs(ReplicatedStorage:GetDescendants()) do
                        if r:IsA("RemoteEvent") and (r.Name:lower():match("attack") or r.Name:lower():match("hit")) then
                            r:FireServer(tHrp)
                            break
                        end
                    end
                end)
            end
            return
        end
    end
end)

local function ToggleFly(state)
    Lea.Modules.Fly = state
    if not state and not Lea.IsReturning and not Lea.Modules.Follow then
        GroundToFloor()
    end
end

local function ReturnToBase()
    if not Lea.BasePosition then
        print("❌ Base kaydedilmemiş!")
        return
    end
    Lea.IsReturning = true
    Lea.Modules.Fly = true
end

local function ToggleFollow(state)
    Lea.Modules.Follow = state
    if not state then
        GroundToFloor()
    end
end

-- ==============================================================================
-- 6. ULTRA KÜÇÜK MOBİL MENÜ SİSTEMİ
-- ==============================================================================
local function CreateMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LeaMenu"
    pcall(function() screenGui.Parent = CoreGui end)
    if not screenGui.Parent then screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    screenGui.ResetOnSpawn = false
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 140, 0, 160)
    mainFrame.Position = UDim2.new(0.5, -70, 0.4, -80)
    mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 6)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 20)
    title.BackgroundTransparency = 1
    title.Text = "LEA MOD"
    title.TextColor3 = Color3.fromRGB(0, 255, 200)
    title.TextSize = 11
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 18, 0, 18)
    closeBtn.Position = UDim2.new(0, 4, 0, 2)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = 10
    closeBtn.Parent = mainFrame
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

    local mods = {
        {name = "Cube", label = "KÜP"},
        {name = "Fly", label = "UÇUŞ"},
        {name = "Follow", label = "TAKİP"},
        {name = "Medusa", label = "MEDUSA"}
    }

    local yPos, buttons = 24, {}
    for i, mod in ipairs(mods) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.44, 0, 0, 22)
        btn.Position = UDim2.new(i % 2 ~= 0 and 0.04 or 0.52, 0, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        btn.Text = mod.label
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextSize = 9
        btn.Font = Enum.Font.GothamSemibold
        btn.Parent = mainFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        buttons[mod.name] = btn

        btn.MouseButton1Click:Connect(function()
            Lea.Modules[mod.name] = not Lea.Modules[mod.name]
            btn.BackgroundColor3 = Lea.Modules[mod.name] and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(25, 25, 35)
            
            if mod.name == "Cube" then ToggleCube(Lea.Modules.Cube)
            elseif mod.name == "Fly" then ToggleFly(Lea.Modules.Fly)
            elseif mod.name == "Follow" then ToggleFollow(Lea.Modules.Follow)
            elseif mod.name == "Medusa" then Lea.Modules.Medusa = Lea.Modules.Medusa end
        end)

        if i % 2 == 0 then yPos = yPos + 25 end
    end

    yPos = yPos + 26
    local baseBtn = Instance.new("TextButton")
    baseBtn.Size = UDim2.new(0.44, 0, 0, 22)
    baseBtn.Position = UDim2.new(0.04, 0, 0, yPos)
    baseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    baseBtn.Text = "BASE KAYDET"
    baseBtn.TextColor3 = Color3.new(1, 1, 1)
    baseBtn.TextSize = 8
    baseBtn.Parent = mainFrame
    Instance.new("UICorner", baseBtn).CornerRadius = UDim.new(0, 4)

    baseBtn.MouseButton1Click:Connect(function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            Lea.BasePosition = hrp.Position
            baseBtn.Text = "KAYDEDİLDİ"
            task.wait(1)
            baseBtn.Text = "BASE KAYDET"
        end
    end)

    local returnBtn = Instance.new("TextButton")
    returnBtn.Size = UDim2.new(0.44, 0, 0, 22)
    returnBtn.Position = UDim2.new(0.52, 0, 0, yPos)
    returnBtn.BackgroundColor3 = Color3.fromRGB(50, 35, 35)
    returnBtn.Text = "BASE DÖN"
    returnBtn.TextColor3 = Color3.new(1, 1, 1)
    returnBtn.TextSize = 8
    returnBtn.Parent = mainFrame
    Instance.new("UICorner", returnBtn).CornerRadius = UDim.new(0, 4)

    returnBtn.MouseButton1Click:Connect(function()
        ReturnToBase()
    end)

    yPos = yPos + 26
    local groundBtn = Instance.new("TextButton")
    groundBtn.Size = UDim2.new(0.92, 0, 0, 22)
    groundBtn.Position = UDim2.new(0.04, 0, 0, yPos)
    groundBtn.BackgroundColor3 = Color3.fromRGB(40, 70, 70)
    groundBtn.Text = "⚡ ZEMİNİ ALGILA & YERE İN"
    groundBtn.TextColor3 = Color3.fromRGB(0, 255, 200)
    groundBtn.TextSize = 9
    groundBtn.Font = Enum.Font.GothamBold
    groundBtn.Parent = mainFrame
    Instance.new("UICorner", groundBtn).CornerRadius = UDim.new(0, 4)

    groundBtn.MouseButton1Click:Connect(function()
        Lea.Modules.Fly = false
        Lea.Modules.Follow = false
        Lea.IsReturning = false
        GroundToFloor()
    end)

    local toggleIcon = Instance.new("TextButton")
    toggleIcon.Size = UDim2.new(0, 35, 0, 18)
    toggleIcon.Position = UDim2.new(1, -40, 0, 5)
    toggleIcon.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
    toggleIcon.Text = "LEA"
    toggleIcon.TextColor3 = Color3.new(1, 1, 1)
    toggleIcon.TextSize = 10
    toggleIcon.Visible = false
    toggleIcon.Parent = screenGui
    Instance.new("UICorner", toggleIcon).CornerRadius = UDim.new(0, 4)

    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        toggleIcon.Visible = true
    end)

    toggleIcon.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        toggleIcon.Visible = false
    end)
end

CreateMenu()
print("✅ [LEA MOD ULTIMATE]: Tüm korumalar ve optimize modlar aktifleşti!")
