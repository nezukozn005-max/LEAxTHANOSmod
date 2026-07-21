-- ==============================================================================
-- LEA MOD ULTIMATE MEGA V37.0 - ULTIMATE STABLE EDITION
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

print("⭐ [LEA V37.0]: ULTIMATE STABLE EDITION BAŞLATILIYOR...")

-- ==============================================================================
-- 1. GLOBAL STATE VE GÜVENLİK
-- ==============================================================================
if not getgenv().LeaModGlobalState then
    getgenv().LeaModGlobalState = {
        Version = "37.0-STABLE",
        Mode = "NONE",
        Speed = 16, -- Anticheat güvenli hız
        MoveSpeedIndex = 1, -- 1: 16, 2: 24, 3: 28
        SpawnPos = nil,
        Fly = false,
        FlySpeed = 50,
        Noclip = false,
        Visuals = false,
        CubeActive = false,
        CubePart = nil,
        ResetProtection = true,
        ThemeColor = Color3.fromRGB(0, 255, 200),
        Connections = {},
        TweenStorage = {}
    }
end
local State = getgenv().LeaModGlobalState

-- Eski bağlantıları temizle
for _, conn in ipairs(State.Connections) do
    pcall(function() conn:Disconnect() end)
end
State.Connections = {}

-- ==============================================================================
-- 2. BYPASS & ANTI-KICK
-- ==============================================================================
local function InitializeBypass()
    pcall(function()
        if not getrawmetatable then return end
        local gm = getrawmetatable(game)
        setreadonly(gm, false)
        local namecall_original = gm.__namecall

        gm.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if not checkcaller() then
                if method == "Kick" or method == "kick" then
                    return nil
                elseif method == "BreakJoints" and self == LocalPlayer.Character then
                    if State.ResetProtection then return nil end
                end
            end
            return namecall_original(self, ...)
        end)
        setreadonly(gm, true)
    end)
end
pcall(InitializeBypass)

-- ==============================================================================
-- 3. ULTRA KÜÇÜK VE MOBİL UYUMLU ARAYÜZ (GUI)
-- ==============================================================================
local function GetGuiParent()
    local success, parent = pcall(function() return CoreGui end)
    if success and parent then return parent end
    return LocalPlayer:WaitForChild("PlayerGui", 5)
end

pcall(function()
    local parentObj = GetGuiParent()
    if parentObj then
        local existing = parentObj:FindFirstChild("LeaModMegaGUI")
        if existing then existing:Destroy() end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LeaModMegaGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = GetGuiParent()

-- Menü kapalıyken ekranın üst orta kısmında görünen şık aktif yazısı
local ActiveWatermark = Instance.new("TextLabel", ScreenGui)
ActiveWatermark.Name = "LeaActiveWatermark"
ActiveWatermark.Size = UDim2.new(0, 240, 0, 28)
ActiveWatermark.Position = UDim2.new(0.5, -120, 0.22, -14)
ActiveWatermark.BackgroundTransparency = 1
ActiveWatermark.Text = "⚡ LEA MOD ACTIVE ⚡"
ActiveWatermark.TextColor3 = State.ThemeColor
ActiveWatermark.TextSize = 13
ActiveWatermark.Font = Enum.Font.GothamBlack
ActiveWatermark.Visible = false
ActiveWatermark.TextStrokeTransparency = 0.4
ActiveWatermark.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

-- Daha da küçültülmüş, taşma yapmayan kompakt ana panel
local MainContainer = Instance.new("Frame", ScreenGui)
MainContainer.Size = UDim2.new(0, 160, 0, 210)
MainContainer.Position = UDim2.new(0.5, -80, 0.5, -105)
MainContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MainContainer.BackgroundTransparency = 0.08
MainContainer.BorderSizePixel = 0
MainContainer.Active = true
MainContainer.Draggable = true

local MainCorner = Instance.new("UICorner", MainContainer)
MainCorner.CornerRadius = UDim.new(0, 6)

local MainStroke = Instance.new("UIStroke", MainContainer)
MainStroke.Color = State.ThemeColor
MainStroke.Thickness = 1.2
MainStroke.Transparency = 0.2

local HeaderFrame = Instance.new("Frame", MainContainer)
HeaderFrame.Size = UDim2.new(1, 0, 0, 22)
HeaderFrame.BackgroundColor3 = Color3.fromRGB(6, 6, 10)
HeaderFrame.BorderSizePixel = 0

local HeaderCorner = Instance.new("UICorner", HeaderFrame)
HeaderCorner.CornerRadius = UDim.new(0, 6)

local TitleLabel = Instance.new("TextLabel", HeaderFrame)
TitleLabel.Size = UDim2.new(1, -22, 1, 0)
TitleLabel.Position = UDim2.new(0, 5, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "LEA V37.0"
TitleLabel.TextColor3 = State.ThemeColor
TitleLabel.TextSize = 9
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local CloseButton = Instance.new("TextButton", HeaderFrame)
CloseButton.Size = UDim2.new(0, 16, 0, 16)
CloseButton.Position = UDim2.new(1, -19, 0, 3)
CloseButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 7

local CloseCorner = Instance.new("UICorner", CloseButton)
CloseCorner.CornerRadius = UDim.new(0, 3)

local ScrollContainer = Instance.new("ScrollingFrame", MainContainer)
ScrollContainer.Size = UDim2.new(1, -6, 1, -25)
ScrollContainer.Position = UDim2.new(0, 3, 0, 23)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.ScrollBarThickness = 2
ScrollContainer.ScrollBarImageColor3 = State.ThemeColor
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 235)

local ButtonListLayout = Instance.new("UIListLayout", ScrollContainer)
ButtonListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ButtonListLayout.Padding = UDim.new(0, 3)
ButtonListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 34, 0, 34)
ToggleBtn.Position = UDim2.new(1, -42, 0.5, -17)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
ToggleBtn.Text = "LEA"
ToggleBtn.TextColor3 = State.ThemeColor
ToggleBtn.TextSize = 9
ToggleBtn.Font = Enum.Font.GothamBlack
ToggleBtn.Visible = false

local ToggleCorner = Instance.new("UICorner", ToggleBtn)
ToggleCorner.CornerRadius = UDim.new(1, 0)
local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Color = State.ThemeColor
ToggleStroke.Thickness = 1.2

CloseButton.MouseButton1Click:Connect(function()
    MainContainer.Visible = false
    ToggleBtn.Visible = true
    ActiveWatermark.Visible = true
end)

ToggleBtn.MouseButton1Click:Connect(function()
    MainContainer.Visible = true
    ToggleBtn.Visible = false
    ActiveWatermark.Visible = false
end)

-- ==============================================================================
-- 4. GÜVENLİ RESET KORUMASI
-- ==============================================================================
local function SetupResetProtection(char)
    local humanoid = char:WaitForChild("Humanoid", 5)
    if humanoid then
        pcall(function()
            humanoid.BreakJointsOnDeath = false
        end)
        
        local healthConn = humanoid.HealthChanged:Connect(function(health)
            if health <= 0 and State.ResetProtection then
                pcall(function()
                    if State.SpawnPos then
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp then hrp.CFrame = CFrame.new(State.SpawnPos) end
                    end
                    humanoid.Health = 50
                end)
            end
        end)
        table.insert(State.Connections, healthConn)
    end
end

if LocalPlayer.Character then
    task.spawn(function() SetupResetProtection(LocalPlayer.Character) end)
end
table.insert(State.Connections, LocalPlayer.CharacterAdded:Connect(SetupResetProtection))

-- ==============================================================================
-- 5. KÜP (PLATFORM) SİSTEMİ
-- ==============================================================================
local function ToggleCube(on)
    State.CubeActive = on
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if on and hrp then
        if not State.CubePart or not State.CubePart.Parent then
            local cube = Instance.new("Part")
            cube.Name = "LeaPlatformCube"
            cube.Size = Vector3.new(4, 0.8, 4)
            cube.Position = hrp.Position - Vector3.new(0, 3.5, 0)
            cube.Anchored = true
            cube.CanCollide = true
            cube.Material = Enum.Material.Neon
            cube.Color = State.ThemeColor
            cube.Transparency = 0.2
            
            local cCorner = Instance.new("SpecialMesh", cube)
            cCorner.MeshType = Enum.MeshType.Brick
            cube.Parent = Workspace
            State.CubePart = cube
        end
    else
        if State.CubePart then
            State.CubePart:Destroy()
            State.CubePart = nil
        end
    end
end

-- ==============================================================================
-- 6. BUTONLAR VE STABİL HIZ SİSTEMİ (16 - 24 - 28)
-- ==============================================================================
local function CreateMenuButton(order, text, defaultColor, activeColor, callback)
    local btn = Instance.new("TextButton", ScrollContainer)
    btn.LayoutOrder = order
    btn.Size = UDim2.new(1, -2, 0, 22)
    btn.BackgroundColor3 = defaultColor
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 8
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 4)
    
    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = active and activeColor or defaultColor}):Play()
        pcall(function() callback(active, btn) end)
    end)
    return btn
end

local function CreateActionItem(order, text, color, callback)
    local btn = Instance.new("TextButton", ScrollContainer)
    btn.LayoutOrder = order
    btn.Size = UDim2.new(1, -2, 0, 22)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 8
    btn.Font = Enum.Font.GothamBold
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 4)
    
    btn.MouseButton1Click:Connect(function() pcall(callback) end)
    return btn
end

local function CancelActiveTweens()
    if State.TweenStorage.ActiveTween then
        State.TweenStorage.ActiveTween:Cancel()
        State.TweenStorage.ActiveTween = nil
    end
end

local function SafeMoveTo(targetPosition, timeToArrive)
    CancelActiveTweens()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local speeds = {16, 24, 28}
        local currentMoveSpeed = speeds[State.MoveSpeedIndex] or 16
        local adjustedTime = math.max(timeToArrive * (16 / currentMoveSpeed), 0.2)
        
        local tweenInfo = TweenInfo.new(adjustedTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetPosition})
        State.TweenStorage.ActiveTween = tween
        tween:Play()
    end
end

State.TweenStorage.CancelActiveTweens = CancelActiveTweens
State.TweenStorage.SafeMoveTo = SafeMoveTo

-- Mod Butonları
CreateMenuButton(1, "🚀 FLY OFF", Color3.fromRGB(45, 35, 65), Color3.fromRGB(0, 180, 90), function(on, btn)
    State.Fly = on
    btn.Text = on and "🚀 FLY ON" or "🚀 FLY OFF"
    if on then
        State.Mode = "NONE"
    else
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end)

CreateMenuButton(2, "🛡️ NOCLIP OFF", Color3.fromRGB(65, 35, 35), Color3.fromRGB(0, 180, 90), function(on, btn)
    State.Noclip = on
    btn.Text = on and "🛡️ NOCLIP ON" or "🛡️ NOCLIP OFF"
end)

CreateMenuButton(3, "🧊 CUBE OFF", Color3.fromRGB(35, 55, 55), Color3.fromRGB(0, 180, 90), function(on, btn)
    ToggleCube(on)
    btn.Text = on and "🧊 CUBE ON" or "🧊 CUBE OFF"
end)

CreateMenuButton(4, "🏠 BASE OFF", Color3.fromRGB(55, 45, 25), Color3.fromRGB(0, 180, 90), function(on, btn)
    if on then
        State.Mode = "BASE"
        State.Fly = false
    else
        State.Mode = "NONE"
        CancelActiveTweens()
    end
    btn.Text = on and "🏠 BASE ON" or "🏠 BASE OFF"
end)

CreateMenuButton(5, "🎯 TARGET OFF", Color3.fromRGB(60, 25, 45), Color3.fromRGB(0, 180, 90), function(on, btn)
    if on then
        State.Mode = "TARGET"
        State.Fly = false
    else
        State.Mode = "NONE"
        CancelActiveTweens()
    end
    btn.Text = on and "🎯 TARGET ON" or "🎯 TARGET OFF"
end)

CreateActionItem(6, "🛬 YERE İN (LAND)", Color3.fromRGB(30, 45, 55), function()
    State.Mode = "NONE"
    State.Fly = false
    CancelActiveTweens()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {char}
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        
        local result = Workspace:Raycast(hrp.Position, Vector3.new(0, -500, 0), raycastParams)
        if result then
            hrp.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0))
        end
    end
end)

CreateMenuButton(7, "👁️ ESP OFF", Color3.fromRGB(35, 35, 48), Color3.fromRGB(0, 180, 90), function(on, btn)
    State.Visuals = on
    btn.Text = on and "👁️ ESP ON" or "👁️ ESP OFF"
end)

-- Hareket Hızı Kademesi (Base ve Target modlarının hızını da etkiler: 16 -> 24 -> 28)
CreateActionItem(8, "⚡ HIZ: 16 (GÜVENLİ)", Color3.fromRGB(30, 30, 45), function()
    State.MoveSpeedIndex = State.MoveSpeedIndex + 1
    if State.MoveSpeedIndex > 3 then State.MoveSpeedIndex = 1 end
    
    local speeds = {16, 24, 28}
    State.Speed = speeds[State.MoveSpeedIndex]
    
    local targetBtn = ScrollContainer:GetChildren()[8]
    if targetBtn and targetBtn:IsA("TextButton") then
        targetBtn.Text = "⚡ HIZ: " .. State.Speed .. " (GÜVENLİ)"
    end
end)

CreateActionItem(9, "📍 MEVCUT YERİ ÜS YAP", Color3.fromRGB(30, 45, 35), function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        State.SpawnPos = hrp.Position + Vector3.new(0, 3, 0)
    end
end)

-- ==============================================================================
-- 7. MERKEZİ FİZİK VE MOTOR DÖNGÜLERİ
-- ==============================================================================

-- Noclip Döngüsü
table.insert(State.Connections, RunService.Stepped:Connect(function()
    if State.Noclip and LocalPlayer.Character then
        pcall(function()
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end)
    end
end))

-- Ana Hareket, Küp Takibi ve Fizik Motoru
table.insert(State.Connections, RunService.Heartbeat:Connect(function(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if hum.Health <= 0 then
        CancelActiveTweens()
        State.Mode = "NONE"
        State.Fly = false
        ToggleCube(false)
        return
    end

    -- Küp Güncellemesi
    if State.CubeActive and State.CubePart then
        State.CubePart.CFrame = hrp.CFrame * CFrame.new(0, -3.6, 0)
    end

    -- Yürüme Hızı Sabitleme
    if hum.WalkSpeed ~= State.Speed and hum.MoveDirection.Magnitude > 0 then
        hum.WalkSpeed = State.Speed
    end

    -- Uçuş Mekaniği
    if State.Fly then
        hum.PlatformStand = true
        local moveDir = hum.MoveDirection
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        
        if moveDir.Magnitude > 0 then
            local targetDir = (Camera.CFrame.RightVector * moveDir.X) + (Camera.CFrame.LookVector * -moveDir.Z)
            hrp.CFrame = hrp.CFrame + (targetDir.Unit * (State.FlySpeed * dt))
        end
        return
    end

    -- Base Sistemi
    if State.Mode == "BASE" and State.SpawnPos then
        local dist = (State.SpawnPos - hrp.Position).Magnitude
        if dist > 4 then
            if not State.TweenStorage.ActiveTween then
                SafeMoveTo(CFrame.new(State.SpawnPos), math.clamp(dist / 100, 0.3, 2.5))
            end
        else
            CancelActiveTweens()
            State.Mode = "NONE"
        end
    end

    -- Target / Aura Sistemi
    if State.Mode == "TARGET" then
        pcall(function()
            local target, minDist = nil, math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local eHrp = p.Character:FindFirstChild("HumanoidRootPart")
                    local eHum = p.Character:FindFirstChildOfClass("Humanoid")
                    if eHrp and eHum and eHum.Health > 0 then
                        local dist = (eHrp.Position - hrp.Position).Magnitude
                        if dist < minDist then 
                            minDist = dist 
                            target = eHrp 
                        end
                    end
                end
            end
            
            if target then
                local dist = (target.Position - hrp.Position).Magnitude
                if dist > 5 then
                    local backPos = target.CFrame * CFrame.new(0, 0, 4)
                    if not State.TweenStorage.ActiveTween or State.TweenStorage.ActiveTween.PlaybackState ~= Enum.PlaybackState.Playing then
                        SafeMoveTo(backPos, math.clamp(dist / 110, 0.1, 1.2))
                    end
                end
            else
                CancelActiveTweens()
            end
        end)
    end
end))

-- Doğru ESP (Highlight) Döngüsü (Hız mantığından ayrıldı, sadece oyuncuları hedef alır)
table.insert(State.Connections, task.spawn(function()
    while true do
        task.wait(1.5)
        pcall(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local char = p.Character
                    local hl = char:FindFirstChild("LeaMegaESP")
                    if State.Visuals then
                        if not hl then
                            hl = Instance.new("Highlight")
                            hl.Name = "LeaMegaESP"
                            hl.FillColor = State.ThemeColor
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.55
                            hl.Parent = char
                        end
                    else
                        if hl then hl:Destroy() end
                    end
                end
            end
        end)
    end
end))

print("✅ [LEA V37.0]: ULTIMATE STABLE EDITION BAŞARIYLA YÜKLENDİ!")
