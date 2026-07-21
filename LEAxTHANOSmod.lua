-- ==============================================================================
-- LEA MOD ULTIMATE MEGA V33.2 - BÖLÜM 1 / 3 (BYPASS & KOMPAKT ARAYÜZ)
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

print("⭐ [LEA V33.2 - BÖLÜM 1]: ULTRA BYPASS VE KOMPAKT ARAYÜZ BAŞLATILIYOR...")

-- ==============================================================================
-- 1. DEVASA DURUM VE GÜVENLİK YÖNETİMİ (GLOBAL STATE)
-- ==============================================================================
if not getgenv().LeaModGlobalState then
    getgenv().LeaModGlobalState = {
        Version = "33.2-RESETFIX",
        Mode = "NONE",
        Speed = 30,
        SpawnPos = nil,
        Fly = false,
        FlySpeed = 60,
        Noclip = false,
        Visuals = false,
        AntiAntiCheat = true,
        BypassActive = true,
        ResetProtection = true,
        LastResetTime = 0,
        ThemeColor = Color3.fromRGB(0, 255, 200),
        TweenStorage = {},
        DiagnosticLogs = {}
    }
end
local State = getgenv().LeaModGlobalState

local function LogEvent(message, level)
    local prefix = level == "ERROR" and "❌ [LEA ERROR]: " or "✅ [LEA INFO]: "
    local formatted = os.date("%H:%M:%S") .. " | " .. prefix .. tostring(message)
    table.insert(State.DiagnosticLogs, formatted)
    if #State.DiagnosticLogs > 200 then
        table.remove(State.DiagnosticLogs, 1)
    end
end

-- ==============================================================================
-- 2. ULTRA GÜÇLÜ BYPASS VE ANTI-DETECT
-- ==============================================================================
local function InitializeUltimateBypass()
    local success, err = pcall(function()
        if getgenv then getgenv().protected_environments = true end
        if not getrawmetatable then return end

        local gm = getrawmetatable(game)
        setreadonly(gm, false)
        local namecall_original = gm.__namecall
        local index_original = gm.__index

        gm.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            if State.BypassActive and not checkcaller() then
                if method == "Kick" or method == "kick" or method == "SaveTouchInterest" then
                    return nil
                elseif method == "BreakJoints" and self == LocalPlayer.Character then
                    if State.ResetProtection and (os.clock() - State.LastResetTime < 3) then
                        return nil 
                    end
                    State.LastResetTime = os.clock()
                    return nil
                elseif method == "ReportAbuse" or method == "FireServer" then
                    for _, v in ipairs(args) do
                        if type(v) == "string" and (v:match("Cheat") or v:match("Exploit") or v:match("Speed") or v:match("Fly")) then
                            return nil
                        end
                    end
                end
            end
            return namecall_original(self, ...)
        end)

        gm.__index = newcclosure(function(self, key)
            if State.BypassActive and not checkcaller() then
                if self:IsA("Humanoid") then
                    if key == "WalkSpeed" then return 16 end
                    if key == "JumpPower" then return 50 end
                elseif self:IsA("BasePart") and (key == "AssemblyLinearVelocity" or key == "Velocity") and State.Fly then
                    return Vector3.new(0, 0, 0)
                end
            end
            return index_original(self, key)
        end)

        setreadonly(gm, true)
        LogEvent("Bölüm 1: Ultra Bypass ve Metatable Hooking aktif.", "INFO")
    end)
end
pcall(InitializeUltimateBypass)

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
        local existing = parentObj:FindFirstChild("LeaModCompactMegaGUI")
        if existing then existing:Destroy() end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LeaModCompactMegaGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = GetGuiParent()

local MainContainer = Instance.new("Frame", ScreenGui)
MainContainer.Size = UDim2.new(0, 280, 0, 360) 
MainContainer.Position = UDim2.new(0.5, -140, 0.5, -180)
MainContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainContainer.BackgroundTransparency = 0.05
MainContainer.BorderSizePixel = 0
MainContainer.Active = true
MainContainer.Draggable = true

local MainCorner = Instance.new("UICorner", MainContainer)
MainCorner.CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", MainContainer)
MainStroke.Color = State.ThemeColor
MainStroke.Thickness = 2
MainStroke.Transparency = 0.15

local HeaderFrame = Instance.new("Frame", MainContainer)
HeaderFrame.Size = UDim2.new(1, 0, 0, 32)
HeaderFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
HeaderFrame.BorderSizePixel = 0

local HeaderCorner = Instance.new("UICorner", HeaderFrame)
HeaderCorner.CornerRadius = UDim.new(0, 10)

local TitleLabel = Instance.new("TextLabel", HeaderFrame)
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "LEA V33.2 (PROTECTED)"
TitleLabel.TextColor3 = State.ThemeColor
TitleLabel.TextSize = 12
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local CloseButton = Instance.new("TextButton", HeaderFrame)
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Position = UDim2.new(1, -28, 0, 4)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 11

local CloseCorner = Instance.new("UICorner", CloseButton)
CloseCorner.CornerRadius = UDim.new(0, 6)

local ScrollContainer = Instance.new("ScrollingFrame", MainContainer)
ScrollContainer.Size = UDim2.new(1, -16, 1, -42)
ScrollContainer.Position = UDim2.new(0, 8, 0, 36)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.ScrollBarThickness = 4
ScrollContainer.ScrollBarImageColor3 = State.ThemeColor
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 500)

local ButtonListLayout = Instance.new("UIListLayout", ScrollContainer)
ButtonListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ButtonListLayout.Padding = UDim.new(0, 6)
ButtonListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(1, -60, 0.5, -22)
ToggleBtn.BackgroundTransparency = 0.1
ToggleBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
ToggleBtn.Text = "LEA"
ToggleBtn.TextColor3 = State.ThemeColor
ToggleBtn.TextSize = 12
ToggleBtn.Font = Enum.Font.GothamBlack
ToggleBtn.Visible = false

local ToggleCorner = Instance.new("UICorner", ToggleBtn)
ToggleCorner.CornerRadius = UDim.new(1, 0)
local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Color = State.ThemeColor
ToggleStroke.Thickness = 2

CloseButton.MouseButton1Click:Connect(function()
    MainContainer.Visible = false
    ToggleBtn.Visible = true
end)

ToggleBtn.MouseButton1Click:Connect(function()
    MainContainer.Visible = true
    ToggleBtn.Visible = false
end)

print("✅ [LEA V33.2 - BÖLÜM 1]: Tamamlandı.")
-- ==============================================================================
-- LEA MOD ULTIMATE MEGA V33.2 - BÖLÜM 2 / 3 (RESET KORUMASI VE TWEEN MOTORU)
-- ==============================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

print("⭐ [LEA V33.2 - BÖLÜM 2]: RESET KORUMASI VE BUTONLAR YÜKLENİYOR...")

if not getgenv().LeaModGlobalState then
    warn("❌ [LEA ERROR]: Global State bulunamadı! Önce Bölüm 1'i çalıştır.")
    return
end
local State = getgenv().LeaModGlobalState

local CoreGui = game:GetService("CoreGui")
local function GetGuiParent()
    local success, parent = pcall(function() return CoreGui end)
    if success and parent then return parent end
    return LocalPlayer:WaitForChild("PlayerGui", 5)
end

local parentObj = GetGuiParent()
local ScreenGui = parentObj and parentObj:FindFirstChild("LeaModCompactMegaGUI")
local MainContainer = ScreenGui and ScreenGui:FindFirstChildOfClass("Frame")
local ScrollContainer = MainContainer and MainContainer:FindFirstChildOfClass("ScrollingFrame")

local UIButtons = {}

-- ==============================================================================
-- İSTEDİĞİN RESET KORUMASI VE KARARLILIK SAĞLAYICI ENTEGRASYONU
-- ==============================================================================
local function SetupResetProtection(newChar)
    local humanoid = newChar:WaitForChild("Humanoid", 5)
    
    if humanoid then
        -- Ölüm anında parçaların ayrılmasını engellemeye çalış
        humanoid.BreakJointsOnDeath = false
        
        -- Can sıfırlandığında müdahale
        humanoid.HealthChanged:Connect(function(health)
            if health <= 0 and State.ResetProtection then
                pcall(function()
                    humanoid.Health = 100
                end)
            end
        end)
        
        -- Periyodik kalkan (ForceField) yenileme döngüsü
        task.spawn(function()
            while newChar and newChar.Parent and State.ResetProtection do
                pcall(function()
                    local forceField = newChar:FindFirstChildOfClass("ForceField")
                    if not forceField then
                        forceField = Instance.new("ForceField")
                        forceField.Parent = newChar
                    end
                    forceField.Visible = false -- Görünmez yap
                end)
                task.wait(0.5)
            end
        end)
    end
end

if LocalPlayer.Character then
    task.spawn(function() SetupResetProtection(LocalPlayer.Character) end)
end
LocalPlayer.CharacterAdded:Connect(SetupResetProtection)

-- ==============================================================================
-- BUTON FABRİKASI
-- ==============================================================================
local function CreateMenuButton(order, text, defaultColor, activeColor, callback)
    if not ScrollContainer then return end
    local btn = Instance.new("TextButton", ScrollContainer)
    btn.LayoutOrder = order
    btn.Size = UDim2.new(1, -8, 0, 34)
    btn.BackgroundColor3 = defaultColor
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 6)
    
    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        TweenService:Create(btn, tweenInfo, {BackgroundColor3 = active and activeColor or defaultColor}):Play()
        pcall(function() callback(active, btn) end)
    end)
    return btn
end

local function CreateActionItem(order, text, color, callback)
    if not ScrollContainer then return end
    local btn = Instance.new("TextButton", ScrollContainer)
    btn.LayoutOrder = order
    btn.Size = UDim2.new(1, -8, 0, 34)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 6)
    
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

-- Butonlar
UIButtons.Fly = CreateMenuButton(1, "🚀 GÜVENLİ FLY OFF", Color3.fromRGB(45, 35, 65), Color3.fromRGB(0, 200, 100), function(on, btn)
    State.Fly = on
    btn.Text = on and "🚀 GÜVENLİ FLY ON" or "🚀 GÜVENLİ FLY OFF"
    if not on and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end)

UIButtons.Noclip = CreateMenuButton(2, "🛡️ HAYALET NOCLIP OFF", Color3.fromRGB(65, 35, 35), Color3.fromRGB(0, 200, 100), function(on, btn)
    State.Noclip = on
    btn.Text = on and "🛡️ HAYALET NOCLIP ON" or "🛡️ HAYALET NOCLIP OFF"
end)

UIButtons.Base = CreateMenuButton(3, "🏠 GÜVENLİ ÜS (BASE) OFF", Color3.fromRGB(55, 45, 25), Color3.fromRGB(0, 200, 100), function(on, btn)
    State.Mode = on and "BASE" or "NONE"
    btn.Text = on and "🏠 GÜVENLİ ÜS ON" or "🏠 GÜVENLİ ÜS OFF"
    if not on then CancelActiveTweens() end
end)

UIButtons.Target = CreateMenuButton(4, "🎯 HAYALET TAKİP OFF", Color3.fromRGB(60, 25, 45), Color3.fromRGB(0, 200, 100), function(on, btn)
    State.Mode = on and "TARGET" or "NONE"
    btn.Text = on and "🎯 HAYALET TAKİP ON" or "🎯 HAYALET TAKİP OFF"
    if not on then CancelActiveTweens() end
end)

UIButtons.Visuals = CreateMenuButton(5, "👁️ OYUNCU ESP OFF", Color3.fromRGB(35, 35, 48), Color3.fromRGB(0, 200, 100), function(on, btn)
    State.Visuals = on
    btn.Text = on and "👁️ OYUNCU ESP ON" or "👁️ OYUNCU ESP OFF"
end)

CreateActionItem(6, "⚡ HIZI ARTIR (ŞU AN: 30)", Color3.fromRGB(30, 30, 45), function()
    State.Speed = State.Speed + 10
    if State.Speed > 100 then State.Speed = 20 end
    if ScrollContainer and ScrollContainer:GetChildren()[6] then
        ScrollContainer:GetChildren()[6].Text = "⚡ HIZI ARTIR (ŞU AN: " .. State.Speed .. ")"
    end
end)

CreateActionItem(7, "📍 MEVCUT KONUMU ÜS YAP", Color3.fromRGB(30, 45, 35), function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        State.SpawnPos = hrp.Position + Vector3.new(0, 5, 0)
        print("✅ [LEA BASE]: Yeni üs noktası kaydedildi.")
    end
end)

print("✅ [LEA V33.2 - BÖLÜM 2]: Tamamlandı.")
-- ==============================================================================
-- LEA MOD ULTIMATE MEGA V33.2 - BÖLÜM 3 / 3 (MERKEZİ DÖNGÜLER VE FİZİK)
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

print("⭐ [LEA V33.2 - BÖLÜM 3]: MERKEZİ DÖNGÜLER BAŞLATILIYOR...")

if not getgenv().LeaModGlobalState then
    warn("❌ [LEA ERROR]: Global State bulunamadı! Önce 1 ve 2'yi çalıştır.")
    return
end
local State = getgenv().LeaModGlobalState

-- Noclip Döngüsü
RunService.Stepped:Connect(function()
    if State.Noclip and LocalPlayer.Character then
        pcall(function()
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end)
    end
end)

-- Ana Hareket ve Fizik Motoru
RunService.Heartbeat:Connect(function(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if hum.Health <= 0 then
        if State.TweenStorage.CancelActiveTweens then
            State.TweenStorage.CancelActiveTweens()
        end
        State.Mode = "NONE"
        State.Fly = false
        return
    end

    if hum.WalkSpeed ~= State.Speed and hum.MoveDirection.Magnitude > 0 then
        hum.WalkSpeed = State.Speed
    end

    -- Uçuş (Fly)
    if State.Fly then
        hum.PlatformStand = true
        local moveDir = hum.MoveDirection
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        
        if moveDir.Magnitude > 0 then
            local targetDir = (Camera.CFrame.RightVector * moveDir.X) + (Camera.CFrame.LookVector * -moveDir.Z)
            hrp.CFrame = hrp.CFrame + (targetDir.Unit * (State.FlySpeed * dt))
        end
    end

    -- Üs Dönüşü
    if State.Mode == "BASE" and State.SpawnPos then
        local dist = (State.SpawnPos - hrp.Position).Magnitude
        if dist > 5 then
            local timeToArrive = math.clamp(dist / 120, 0.4, 2.5)
            if not State.TweenStorage.ActiveTween and State.TweenStorage.SafeMoveTo then
                State.TweenStorage.SafeMoveTo(CFrame.new(State.SpawnPos), timeToArrive)
            end
        else
            if State.TweenStorage.CancelActiveTweens then State.TweenStorage.CancelActiveTweens() end
            State.Mode = "NONE"
            print("✅ [LEA BASE]: Üsse güvenli bir şekilde ulaşıldı.")
        end
    end

    -- Hedef Takip
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
                if dist > 6 then
                    local backPos = target.CFrame * CFrame.new(0, 0, 4)
                    local timeToArrive = math.clamp(dist / 140, 0.1, 1.2)
                    
                    if (not State.TweenStorage.ActiveTween or State.TweenStorage.ActiveTween.PlaybackState ~= Enum.PlaybackState.Playing) and State.TweenStorage.SafeMoveTo then
                        State.TweenStorage.SafeMoveTo(backPos, timeToArrive)
                    end
                end
            else
                if State.TweenStorage.CancelActiveTweens then State.TweenStorage.CancelActiveTweens() end
            end
        end)
    end
end)

-- ESP Sistemi
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local char = p.Character
                    local hl = char:FindFirstChild("LeaCompactESP")
                    if State.Visuals then
                        if not hl then
                            hl = Instance.new("Highlight")
                            hl.Name = "LeaCompactESP"
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
end)

print("✅ [LEA V33.2]: TÜM SİSTEMLER, RESET KORUMASI VE ÖZEL KALKANLAR AKTİF!")
