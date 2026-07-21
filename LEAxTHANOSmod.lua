-- ==============================================================================
-- LEA MOD ULTIMATE MEGA V35.1 - FULL FIX (TEK PARÇA STABİL SÜRÜM)
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

print("⭐ [LEA V35.1]: STABİL MEGA KOD BAŞLATILIYOR...")

-- ==============================================================================
-- 1. GLOBAL STATE VE GÜVENLİK
-- ==============================================================================
if not getgenv().LeaModGlobalState then
    getgenv().LeaModGlobalState = {
        Version = "35.1-MEGA",
        Mode = "NONE", -- "NONE", "BASE", "TARGET", "LAND"
        Speed = 30,
        SpawnPos = nil,
        Fly = false,
        FlySpeed = 60,
        Noclip = false,
        Visuals = false,
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
-- 3. KOMPAKT MOBİL ARAYÜZ (GUI)
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

local MainContainer = Instance.new("Frame", ScreenGui)
MainContainer.Size = UDim2.new(0, 210, 0, 315)
MainContainer.Position = UDim2.new(0.5, -105, 0.5, -157)
MainContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainContainer.BackgroundTransparency = 0.05
MainContainer.BorderSizePixel = 0
MainContainer.Active = true
MainContainer.Draggable = true

local MainCorner = Instance.new("UICorner", MainContainer)
MainCorner.CornerRadius = UDim.new(0, 8)

local MainStroke = Instance.new("UIStroke", MainContainer)
MainStroke.Color = State.ThemeColor
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.2

local HeaderFrame = Instance.new("Frame", MainContainer)
HeaderFrame.Size = UDim2.new(1, 0, 0, 28)
HeaderFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
HeaderFrame.BorderSizePixel = 0

local HeaderCorner = Instance.new("UICorner", HeaderFrame)
HeaderCorner.CornerRadius = UDim.new(0, 8)

local TitleLabel = Instance.new("TextLabel", HeaderFrame)
TitleLabel.Size = UDim2.new(1, -30, 1, 0)
TitleLabel.Position = UDim2.new(0, 8, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "LEA MOD V35.1"
TitleLabel.TextColor3 = State.ThemeColor
TitleLabel.TextSize = 11
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local CloseButton = Instance.new("TextButton", HeaderFrame)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Position = UDim2.new(1, -24, 0, 4)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 9

local CloseCorner = Instance.new("UICorner", CloseButton)
CloseCorner.CornerRadius = UDim.new(0, 4)

local ScrollContainer = Instance.new("ScrollingFrame", MainContainer)
ScrollContainer.Size = UDim2.new(1, -12, 1, -34)
ScrollContainer.Position = UDim2.new(0, 6, 0, 30)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.ScrollBarThickness = 3
ScrollContainer.ScrollBarImageColor3 = State.ThemeColor
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 310)

local ButtonListLayout = Instance.new("UIListLayout", ScrollContainer)
ButtonListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ButtonListLayout.Padding = UDim.new(0, 5)
ButtonListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 40, 0, 40)
ToggleBtn.Position = UDim2.new(1, -55, 0.5, -20)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
ToggleBtn.Text = "LEA"
ToggleBtn.TextColor3 = State.ThemeColor
ToggleBtn.TextSize = 11
ToggleBtn.Font = Enum.Font.GothamBlack
ToggleBtn.Visible = false

local ToggleCorner = Instance.new("UICorner", ToggleBtn)
ToggleCorner.CornerRadius = UDim.new(1, 0)
local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Color = State.ThemeColor
ToggleStroke.Thickness = 1.5

CloseButton.MouseButton1Click:Connect(function()
    MainContainer.Visible = false
    ToggleBtn.Visible = true
end)

ToggleBtn.MouseButton1Click:Connect(function()
    MainContainer.Visible = true
    ToggleBtn.Visible = false
end)

-- ==============================================================================
-- 4. GÜVENLİ RESET KORUMASI (ÖLÜM DÖNGÜSÜ FIX)
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
                    -- Sürekli reset atan çökme hatasını engellemek için doğrudan can basmak yerine karakterin güvenli konumda yenilenmesini sağlıyoruz
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
-- 5. BUTONLAR VE MOD YÖNETİMİ (ÇAKIŞMA ÖNLEYİCİ)
-- ==============================================================================
local function CreateMenuButton(order, text, defaultColor, activeColor, callback)
    local btn = Instance.new("TextButton", ScrollContainer)
    btn.LayoutOrder = order
    btn.Size = UDim2.new(1, -4, 0, 28)
    btn.BackgroundColor3 = defaultColor
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 5)
    
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
    btn.Size = UDim2.new(1, -4, 0, 28)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 5)
    
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
        local tweenInfo = TweenInfo.new(timeToArrive, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetPosition})
        State.TweenStorage.ActiveTween = tween
        tween:Play()
    end
end

State.TweenStorage.CancelActiveTweens = CancelActiveTweens
State.TweenStorage.SafeMoveTo = SafeMoveTo

-- Mod Butonları
CreateMenuButton(1, "🚀 FLY (UÇUŞ) OFF", Color3.fromRGB(45, 35, 65), Color3.fromRGB(0, 180, 90), function(on, btn)
    State.Fly = on
    btn.Text = on and "🚀 FLY (UÇUŞ) ON" or "🚀 FLY (UÇUŞ) OFF"
    if on then
        State.Mode = "NONE" -- Çakışmayı önle
    else
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end)

CreateMenuButton(2, "🛡️ NOCLIP (HAYALET) OFF", Color3.fromRGB(65, 35, 35), Color3.fromRGB(0, 180, 90), function(on, btn)
    State.Noclip = on
    btn.Text = on and "🛡️ NOCLIP ON" or "🛡️ NOCLIP OFF"
end)

CreateMenuButton(3, "🏠 BASE (ÜS) OFF", Color3.fromRGB(55, 45, 25), Color3.fromRGB(0, 180, 90), function(on, btn)
    if on then
        State.Mode = "BASE"
        State.Fly = false
    else
        State.Mode = "NONE"
        CancelActiveTweens()
    end
    btn.Text = on and "🏠 BASE (ÜS) ON" or "🏠 BASE (ÜS) OFF"
end)

CreateMenuButton(4, "🎯 TARGET (AURA) OFF", Color3.fromRGB(60, 25, 45), Color3.fromRGB(0, 180, 90), function(on, btn)
    if on then
        State.Mode = "TARGET"
        State.Fly = false
    else
        State.Mode = "NONE"
        CancelActiveTweens()
    end
    btn.Text = on and "🎯 TARGET (AURA) ON" or "🎯 TARGET (AURA) OFF"
end)

-- YENİ EKLENEN ÖZELLİK: YERE İN (LAND) MODU
CreateActionItem(5, "🛬 YERE İN (LAND)", Color3.fromRGB(30, 45, 55), function()
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
            print("✅ [LEA LAND]: Güvenli bir şekilde yere inildi.")
        end
    end
end)

CreateMenuButton(6, "👁️ VISUAL (ESP) OFF", Color3.fromRGB(35, 35, 48), Color3.fromRGB(0, 180, 90), function(on, btn)
    State.Visuals = on
    btn.Text = on and "👁️ VISUAL (ESP) ON" or "👁️ VISUAL (ESP) OFF"
end)

CreateActionItem(7, "⚡ HIZI ARTIR (ŞU AN: 30)", Color3.fromRGB(30, 30, 45), function()
    State.Speed = State.Speed + 10
    if State.Speed > 90 then State.Speed = 30 end
    local targetBtn = ScrollContainer:GetChildren()[7]
    if targetBtn and targetBtn:IsA("TextButton") then
        targetBtn.Text = "⚡ HIZI ARTIR (ŞU AN: " .. State.Speed .. ")"
    end
end)

CreateActionItem(8, "📍 MEVCUT KONUMU ÜS YAP", Color3.fromRGB(30, 45, 35), function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        State.SpawnPos = hrp.Position + Vector3.new(0, 3, 0)
        print("✅ [LEA BASE]: Yeni üs noktası başarıyla kaydedildi.")
    end
end)

-- ==============================================================================
-- 6. MERKEZİ FİZİK VE MOTOR DÖNGÜLERİ
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

-- Ana Hareket, Uçuş ve Mod Döngüsü (Çakışma Kilidi İle)
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
        return
    end

    -- Hız Sabitleme
    if hum.WalkSpeed ~= State.Speed and hum.MoveDirection.Magnitude > 0 then
        hum.WalkSpeed = State.Speed
    end

    -- Uçuş Mekaniği (Fly aktifken diğer modlar çalışmaz)
    if State.Fly then
        hum.PlatformStand = true
        local moveDir = hum.MoveDirection
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        
        if moveDir.Magnitude > 0 then
            local targetDir = (Camera.CFrame.RightVector * moveDir.X) + (Camera.CFrame.LookVector * -moveDir.Z)
            hrp.CFrame = hrp.CFrame + (targetDir.Unit * (State.FlySpeed * dt))
        end
        return -- Fly aktifken alt motorları atla (Çakışma Fix)
    end

    -- Base Sistemi
    if State.Mode == "BASE" and State.SpawnPos then
        local dist = (State.SpawnPos - hrp.Position).Magnitude
        if dist > 4 then
            if not State.TweenStorage.ActiveTween then
                SafeMoveTo(CFrame.new(State.SpawnPos), math.clamp(dist / 130, 0.3, 2.0))
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
                        SafeMoveTo(backPos, math.clamp(dist / 140, 0.1, 1.0))
                    end
                end
            else
                CancelActiveTweens()
            end
        end)
    end
end))

-- Performans Odaklı ESP (Visuals) Döngüsü
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
                            hl.FillColor = Color3.fromRGB(0, 255, 200)
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

print("✅ [LEA V35.1]: TÜM SİSTEMLER BAŞARIYLA YÜKLENDİ VE AKTİF!")
