-- ==============================================================================
-- LEA MOD ULTIMATE MEGA V40.0 - STABLE MODULAR CORE EDITION
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

print("⭐ [LEA V40.0]: MODULAR CORE STABLE BAŞLATILIYOR...")

-- ==============================================================================
-- 1. SETTINGS & GLOBAL STATE (MERKEZİ DURUM YÖNETİMİ)
-- ==============================================================================
if not getgenv().LeaModGlobalState then
    getgenv().LeaModGlobalState = {
        Version = "40.0-MODULAR",
        Mode = "NONE",          -- "NONE", "BASE", "TARGET"
        Speed = 16,             -- Güvenli taban hız
        MoveSpeedIndex = 1,     -- 1: 16, 2: 18, 3: 20
        SpawnPos = nil,
        Fly = false,
        FlySpeed = 35,
        Noclip = false,
        Visuals = false,
        CubeActive = false,
        CubePart = nil,
        ThemeColor = Color3.fromRGB(0, 255, 200),
        Connections = {},
        TweenStorage = {}
    }
end
local State = getgenv().LeaModGlobalState

-- Önceki bağlantıları güvenli bir şekilde temizle
for _, conn in ipairs(State.Connections) do
    pcall(function() conn:Disconnect() end)
end
State.Connections = {}

local function CancelActiveTweens()
    if State.TweenStorage.ActiveTween then
        State.TweenStorage.ActiveTween:Cancel()
        State.TweenStorage.ActiveTween = nil
    end
end

-- ==============================================================================
-- 2. RESET & ÖLÜM KORUMASI (STABLE RECOVERY)
-- ==============================================================================
local function SetupResetProtection(char)
    local humanoid = char:WaitForChild("Humanoid", 5)
    if humanoid then
        pcall(function()
            humanoid.BreakJointsOnDeath = false
        end)
        
        local healthConn = humanoid.HealthChanged:Connect(function(health)
            if health <= 0 then
                CancelActiveTweens()
                State.Mode = "NONE"
                State.Fly = false
                if State.CubePart then
                    State.CubePart:Destroy()
                    State.CubePart = nil
                end
                State.CubeActive = false
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
-- 3. MİKRO KÜP SİSTEMİ (ÇARPIŞMASIZ / GERİ TEPME YAPMAYAN YAPI)
-- ==============================================================================
local function ToggleCube(on)
    State.CubeActive = on
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if on and hrp then
        if not State.CubePart or not State.CubePart.Parent then
            local cube = Instance.new("Part")
            cube.Name = "LeaPlatformCube"
            -- Karakteri itmeyen, pet alımında geri tepme yaratmayan mikro taban
            cube.Size = Vector3.new(1.5, 0.2, 1.5)
            cube.Position = hrp.Position - Vector3.new(0, 3.2, 0)
            cube.Anchored = true
            cube.CanCollide = false -- Çarpışma kapatıldı: Fiziksel geri tepme / fırlama riski tamamen sıfırlandı
            cube.Massless = true
            cube.Material = Enum.Material.Neon
            cube.Color = State.ThemeColor
            cube.Transparency = 0.4
            
            local mesh = Instance.new("SpecialMesh", cube)
            mesh.MeshType = Enum.MeshType.Brick
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
-- 4. ULTRA KÜÇÜK VE MOBİL UYUMLU ARAYÜZ (GUI - 110x140)
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

local ActiveWatermark = Instance.new("TextLabel", ScreenGui)
ActiveWatermark.Name = "LeaActiveWatermark"
ActiveWatermark.Size = UDim2.new(0, 180, 0, 20)
ActiveWatermark.Position = UDim2.new(0.5, -90, 0.16, -10)
ActiveWatermark.BackgroundTransparency = 1
ActiveWatermark.Text = "⚡ LEA V40 ACTIVE ⚡"
ActiveWatermark.TextColor3 = State.ThemeColor
ActiveWatermark.TextSize = 10
ActiveWatermark.Font = Enum.Font.GothamBlack
ActiveWatermark.Visible = false
ActiveWatermark.TextStrokeTransparency = 0.3
ActiveWatermark.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

-- Telefon ekranını kapatmayan, ultra kompakt ana panel (110x140)
local MainContainer = Instance.new("Frame", ScreenGui)
MainContainer.Size = UDim2.new(0, 110, 0, 145)
MainContainer.Position = UDim2.new(0.5, -55, 0.5, -72)
MainContainer.BackgroundColor3 = Color3.fromRGB(6, 6, 10)
MainContainer.BackgroundTransparency = 0.05
MainContainer.BorderSizePixel = 0
MainContainer.Active = true
MainContainer.Draggable = true

local MainCorner = Instance.new("UICorner", MainContainer)
MainCorner.CornerRadius = UDim.new(0, 4)

local MainStroke = Instance.new("UIStroke", MainContainer)
MainStroke.Color = State.ThemeColor
MainStroke.Thickness = 1
MainStroke.Transparency = 0.15

local HeaderFrame = Instance.new("Frame", MainContainer)
HeaderFrame.Size = UDim2.new(1, 0, 0, 16)
HeaderFrame.BackgroundColor3 = Color3.fromRGB(3, 3, 6)
HeaderFrame.BorderSizePixel = 0

local HeaderCorner = Instance.new("UICorner", HeaderFrame)
HeaderCorner.CornerRadius = UDim.new(0, 4)

local TitleLabel = Instance.new("TextLabel", HeaderFrame)
TitleLabel.Size = UDim2.new(1, -16, 1, 0)
TitleLabel.Position = UDim2.new(0, 3, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "LEA V40"
TitleLabel.TextColor3 = State.ThemeColor
TitleLabel.TextSize = 7
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local CloseButton = Instance.new("TextButton", HeaderFrame)
CloseButton.Size = UDim2.new(0, 12, 0, 12)
CloseButton.Position = UDim2.new(1, -14, 0, 2)
CloseButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 6

local CloseCorner = Instance.new("UICorner", CloseButton)
CloseCorner.CornerRadius = UDim.new(0, 2)

local ScrollContainer = Instance.new("ScrollingFrame", MainContainer)
ScrollContainer.Size = UDim2.new(1, -4, 1, -18)
ScrollContainer.Position = UDim2.new(0, 2, 0, 17)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.ScrollBarThickness = 1
ScrollContainer.ScrollBarImageColor3 = State.ThemeColor
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 175)

local ButtonListLayout = Instance.new("UIListLayout", ScrollContainer)
ButtonListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ButtonListLayout.Padding = UDim.new(0, 2)
ButtonListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 26, 0, 26)
ToggleBtn.Position = UDim2.new(1, -32, 0.5, -13)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(6, 6, 10)
ToggleBtn.Text = "LEA"
ToggleBtn.TextColor3 = State.ThemeColor
ToggleBtn.TextSize = 7
ToggleBtn.Font = Enum.Font.GothamBlack
ToggleBtn.Visible = false

local ToggleCorner = Instance.new("UICorner", ToggleBtn)
ToggleCorner.CornerRadius = UDim.new(1, 0)
local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Color = State.ThemeColor
ToggleStroke.Thickness = 1

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
-- 5. BUTONLAR VE STABİL HAREKET KONTROLÜ
-- ==============================================================================
local function CreateMenuButton(order, text, defaultColor, activeColor, callback)
    local btn = Instance.new("TextButton", ScrollContainer)
    btn.LayoutOrder = order
    btn.Size = UDim2.new(1, -2, 0, 17)
    btn.BackgroundColor3 = defaultColor
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 6.5
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 3)
    
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
    btn.Size = UDim2.new(1, -2, 0, 17)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 6.5
    btn.Font = Enum.Font.GothamBold
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 3)
    
    btn.MouseButton1Click:Connect(function() pcall(callback) end)
    return btn
end

local function SafeMoveTo(targetPosition, timeToArrive)
    CancelActiveTweens()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        -- 16 - 18 - 20 güvenli kademe aralığı
        local speeds = {16, 18, 20}
        local currentMoveSpeed = speeds[State.MoveSpeedIndex] or 16
        local adjustedTime = math.max(timeToArrive * (16 / currentMoveSpeed), 0.3)
        
        local tweenInfo = TweenInfo.new(adjustedTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetPosition})
        State.TweenStorage.ActiveTween = tween
        tween:Play()
    end
end

State.TweenStorage.SafeMoveTo = SafeMoveTo

-- Menü Butonları
CreateMenuButton(1, "🚀 FLY OFF", Color3.fromRGB(45, 35, 65), Color3.fromRGB(0, 180, 90), function(on, btn)
    State.Fly = on
    btn.Text = on and "🚀 FLY ON" or "🚀 FLY OFF"
    if on then State.Mode = "NONE" end
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

CreateActionItem(6, "🛬 YERE İN", Color3.fromRGB(30, 45, 55), function()
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

-- Hız Kademesi (16 -> 18 -> 20)
CreateActionItem(8, "⚡ HIZ: 16", Color3.fromRGB(30, 30, 45), function()
    State.MoveSpeedIndex = State.MoveSpeedIndex + 1
    if State.MoveSpeedIndex > 3 then State.MoveSpeedIndex = 1 end
    
    local speeds = {16, 18, 20}
    State.Speed = speeds[State.MoveSpeedIndex]
    
    local targetBtn = ScrollContainer:GetChildren()[8]
    if targetBtn and targetBtn:IsA("TextButton") then
        targetBtn.Text = "⚡ HIZ: " .. State.Speed
    end
end)

CreateActionItem(9, "📍 ÜS YAP", Color3.fromRGB(30, 45, 35), function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        State.SpawnPos = hrp.Position + Vector3.new(0, 3, 0)
    end
end)

-- ==============================================================================
-- 6. MOTOR & FİZİK DÖNGÜLERİ (STABLE HEARTBEAT)
-- ==============================================================================

-- Noclip
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

-- Ana Hareket, Küp Takibi ve Mod Motoru
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

    -- Mikro Küp Güncellemesi (Ayak altında pürüzsüz takip)
    if State.CubeActive and State.CubePart then
        State.CubePart.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 3.35, hrp.Position.Z)
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
    else
        if hum.PlatformStand and State.Mode == "NONE" then
            hum.PlatformStand = false
        end
    end

    -- Base Takip Sistemi
    if State.Mode == "BASE" and State.SpawnPos then
        local dist = (State.SpawnPos - hrp.Position).Magnitude
        if dist > 3.5 then
            if not State.TweenStorage.ActiveTween then
                SafeMoveTo(CFrame.new(State.SpawnPos), math.clamp(dist / 80, 0.3, 2.0))
            end
        else
            CancelActiveTweens()
            State.Mode = "NONE"
        end
    end

    -- Target / Aura Takip Sistemi (Güvenli Max 20 Hız Aralığı)
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
                if dist > 4.5 then
                    local backPos = target.CFrame * CFrame.new(0, 0, 3.5)
                    if not State.TweenStorage.ActiveTween or State.TweenStorage.ActiveTween.PlaybackState ~= Enum.PlaybackState.Playing then
                        SafeMoveTo(backPos, math.clamp(dist / 85, 0.1, 1.0))
                    end
                end
            else
                CancelActiveTweens()
            end
        end)
    end
end))

-- ESP (Highlight) Sistemi
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

print("✅ [LEA V40.0]: MODULAR CORE STABLE BAŞARIYLA YÜKLENDİ!")
