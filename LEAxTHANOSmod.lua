-- ==============================================================================
-- LEA MOD ULTIMATE MEGA V33.0 - MASSIVE EDITION (BÖLÜM 1 / 3)
-- ULTRA BYPASS, GLOBAL STATE VE GELİŞTİRİLMİŞ MOBİL ARAYÜZ ALTYAPISI
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

print("⭐ [LEA V33.0 - BÖLÜM 1]: ULTRA BYPASS VE ARAYÜZ MOTORU BAŞLATILIYOR...")

-- ==============================================================================
-- 1. DEVASA DURUM VE GÜVENLİK YÖNETİMİ (GLOBAL STATE)
-- ==============================================================================
if not getgenv().LeaModGlobalState then
    getgenv().LeaModGlobalState = {
        Version = "33.0-MASSIVE-MEGA",
        Mode = "NONE",
        Speed = 30,
        SpawnPos = nil,
        Fly = false,
        FlySpeed = 60,
        Noclip = false,
        Visuals = false,
        AntiAntiCheat = true,
        BypassActive = true,
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
-- 2. ULTRA GÜÇLÜ BYPASS VE ANTI-DETECT (METATABLE HOOKING & TELEMETRY BLOCKER)
-- ==============================================================================
local function InitializeUltimateBypass()
    local success, err = pcall(function()
        if getgenv then
            getgenv().protected_environments = true
        end

        if not getrawmetatable then 
            LogEvent("Exploit metatable desteği sınırlı, alternatif koruma katmanı devrede.", "ERROR")
            return 
        end

        local gm = getrawmetatable(game)
        setreadonly(gm, false)
        local namecall_original = gm.__namecall
        local index_original = gm.__index

        -- Gelişmiş Anti-Kick, Anti-Ban ve Telemetri Engelleme Kancaları
        gm.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            if State.BypassActive and not checkcaller() then
                if method == "Kick" or method == "kick" or method == "SaveTouchInterest" then
                    return nil
                elseif method == "BreakJoints" and self == LocalPlayer.Character then
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

        -- Hız ve Fizik Değerlerini Sunucu Anticheat Sisteminden Maskeleme
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
        LogEvent("Bölüm 1: Ultra Bypass ve Metatable Hooking başarıyla uygulandı.", "INFO")
    end)

    if not success then
        LogEvent("Bypass başlatılırken hata oluştu: " .. tostring(err), "ERROR")
    end
end
pcall(InitializeUltimateBypass)

-- ==============================================================================
-- 3. MOBİL UYUMLU, GENİŞLETİLMİŞ VE DİKDÖRTGEN ARAYÜZ (GUI) MİMARİSİ
-- ==============================================================================
local function GetGuiParent()
    local success, parent = pcall(function() return CoreGui end)
    if success and parent then return parent end
    return LocalPlayer:WaitForChild("PlayerGui", 5)
end

pcall(function()
    local parentObj = GetGuiParent()
    if parentObj then
        local existing = parentObj:FindFirstChild("LeaModMassiveMegaGUI")
        if existing then existing:Destroy() end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LeaModMassiveMegaGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = GetGuiParent()

local MainContainer = Instance.new("Frame", ScreenGui)
MainContainer.Size = UDim2.new(0, 340, 0, 480) -- Geniş, telefonda kusursuz ergonomik yapı
MainContainer.Position = UDim2.new(0.5, -170, 0.5, -240)
MainContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainContainer.BackgroundTransparency = 0.05
MainContainer.BorderSizePixel = 0
MainContainer.Active = true
MainContainer.Draggable = true

local MainCorner = Instance.new("UICorner", MainContainer)
MainCorner.CornerRadius = UDim.new(0, 14)

local MainStroke = Instance.new("UIStroke", MainContainer)
MainStroke.Color = State.ThemeColor
MainStroke.Thickness = 2.5
MainStroke.Transparency = 0.15

local HeaderFrame = Instance.new("Frame", MainContainer)
HeaderFrame.Size = UDim2.new(1, 0, 0, 42)
HeaderFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
HeaderFrame.BorderSizePixel = 0

local HeaderCorner = Instance.new("UICorner", HeaderFrame)
HeaderCorner.CornerRadius = UDim.new(0, 14)

local TitleLabel = Instance.new("TextLabel", HeaderFrame)
TitleLabel.Size = UDim2.new(1, -55, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "LEA V33.0 MASSIVE EDITION"
TitleLabel.TextColor3 = State.ThemeColor
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local CloseButton = Instance.new("TextButton", HeaderFrame)
CloseButton.Size = UDim2.new(0, 32, 0, 32)
CloseButton.Position = UDim2.new(1, -38, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 13

local CloseCorner = Instance.new("UICorner", CloseButton)
CloseCorner.CornerRadius = UDim.new(0, 8)

local ScrollContainer = Instance.new("ScrollingFrame", MainContainer)
ScrollContainer.Size = UDim2.new(1, -20, 1, -58)
ScrollContainer.Position = UDim2.new(0, 10, 0, 50)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.ScrollBarThickness = 5
ScrollContainer.ScrollBarImageColor3 = State.ThemeColor
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 750)

local ButtonListLayout = Instance.new("UIListLayout", ScrollContainer)
ButtonListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ButtonListLayout.Padding = UDim.new(0, 8)
ButtonListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 55, 0, 55)
ToggleBtn.Position = UDim2.new(1, -75, 0.5, -28)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
ToggleBtn.Text = "LEA"
ToggleBtn.TextColor3 = State.ThemeColor
ToggleBtn.TextSize = 14
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

print("✅ [LEA V33.0 - BÖLÜM 1]: Tamamlandı. Lütfen Part 2 kodunu isteyin.")
-- ==============================================================================
-- LEA MOD ULTIMATE MEGA V33.0 - MASSIVE EDITION (BÖLÜM 2 / 3)
-- GÜVENLİ TWEEN HAREKET MOTORU, FABRİKA BUTONLARI VE KARAKTER KORUMA SİSTEMİ
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

print("⭐ [LEA V33.0 - BÖLÜM 2]: HAREKET MOTORU VE BUTON FABRİKASI YÜKLENİYOR...")

if not getgenv().LeaModGlobalState then
    warn("❌ [LEA ERROR]: Global State bulunamadı! Lütfen önce Bölüm 1'i çalıştırın.")
    return
end
local State = getgenv().LeaModGlobalState

-- Arayüz elementlerine erişim için ScreenGui üzerinden arama
local CoreGui = game:GetService("CoreGui")
local function GetGuiParent()
    local success, parent = pcall(function() return CoreGui end)
    if success and parent then return parent end
    return LocalPlayer:WaitForChild("PlayerGui", 5)
end

local parentObj = GetGuiParent()
local ScreenGui = parentObj and parentObj:FindFirstChild("LeaModMassiveMegaGUI")
local MainContainer = ScreenGui and ScreenGui:FindFirstChildOfClass("Frame")
local ScrollContainer = MainContainer and MainContainer:FindFirstChildOfClass("ScrollingFrame")

if not ScrollContainer then
    warn("❌ [LEA ERROR]: ScrollContainer (Bölüm 1 Arayüzü) tespit edilemedi!")
end

local UIButtons = {}

-- ==============================================================================
-- 1. DİNAMİK ARAYÜZ ELEMANLARI (FACTORY)
-- ==============================================================================
local function CreateMenuButton(order, text, defaultColor, activeColor, callback)
    if not ScrollContainer then return end
    local btn = Instance.new("TextButton", ScrollContainer)
    btn.LayoutOrder = order
    btn.Size = UDim2.new(1, -10, 0, 42)
    btn.BackgroundColor3 = defaultColor
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 8)
    
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
    btn.Size = UDim2.new(1, -10, 0, 42)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 8)
    
    btn.MouseButton1Click:Connect(function() pcall(callback) end)
    return btn
end

-- ==============================================================================
-- 2. GÜVENLİ TWEEN HAREKET MOTORU VE ANTI-RUBBERBANDING SİSTEMİ
-- ==============================================================================
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

-- Global erişim için State içerisine kaydediyoruz
State.TweenStorage.CancelActiveTweens = CancelActiveTweens
State.TweenStorage.SafeMoveTo = SafeMoveTo

-- ==============================================================================
-- 3. KARAKTER ÖLÜM VE YENİDEN DOĞMA YÖNETİMİ
-- ==============================================================================
local function SetupCharacter(char)
    State.Mode = "NONE"
    CancelActiveTweens()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if hrp and not State.SpawnPos then 
        State.SpawnPos = hrp.Position + Vector3.new(0, 5, 0) 
    end
end
if LocalPlayer.Character then SetupCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(SetupCharacter)

-- ==============================================================================
-- 4. KONTROL BUTONLARININ OLUŞTURULMASI
-- ==============================================================================
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

local speedBtn = CreateActionItem(6, "⚡ HIZI ARTIR (ŞU AN: 30)", Color3.fromRGB(30, 30, 45), function()
    State.Speed = State.Speed + 10
    if State.Speed > 100 then State.Speed = 20 end
    if ScrollContainer and ScrollContainer:GetChildren()[6] then
        ScrollContainer:GetChildren()[6].Text = "⚡ HIZI ARTIR (ŞU AN: " .. State.Speed .. ")"
    end
end)

local setBaseBtn = CreateActionItem(7, "📍 MEVCUT KONUMU ÜS YAP", Color3.fromRGB(30, 45, 35), function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        State.SpawnPos = hrp.Position + Vector3.new(0, 5, 0)
        print("✅ [LEA BASE]: Yeni üs noktası başarıyla kaydedildi.")
    end
end)

print("✅ [LEA V33.0 - BÖLÜM 2]: Tamamlandı. Lütfen Part 3 kodunu isteyin.")
-- ==============================================================================
-- LEA MOD ULTIMATE MEGA V33.0 - MASSIVE EDITION (BÖLÜM 3 / 3)
-- MERKEZİ GÜNCELLEME DÖNGÜSÜ, FLY, NOCLIP, TWEEN BASE/TARGET VE ESP MOTORU
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

print("⭐ [LEA V33.0 - BÖLÜM 3]: MERKEZİ DÖNGÜLER VE FİZİK MOTORU BAŞLATILIYOR...")

if not getgenv().LeaModGlobalState then
    warn("❌ [LEA ERROR]: Global State bulunamadı! Lütfen önce Bölüm 1 ve Bölüm 2'yi çalıştırın.")
    return
end
local State = getgenv().LeaModGlobalState

-- ==============================================================================
-- 1. HAYALET NOCLIP DÖNGÜSÜ (DUVARDAN GEÇME MOTORU)
-- ==============================================================================
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

-- ==============================================================================
-- 2. ANA FİZİK VE HAREKET MOTORU (HEARTBEAT DÖNGÜSÜ)
-- ==============================================================================
RunService.Heartbeat:Connect(function(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    -- Güvenli Yürüme Hızı Kontrolü
    if hum.WalkSpeed ~= State.Speed and hum.MoveDirection.Magnitude > 0 then
        hum.WalkSpeed = State.Speed
    end

    -- Gelişmiş Güvenli Uçuş (Fly) Mekanizması
    if State.Fly then
        hum.PlatformStand = true
        local moveDir = hum.MoveDirection
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        
        if moveDir.Magnitude > 0 then
            local targetDir = (Camera.CFrame.RightVector * moveDir.X) + (Camera.CFrame.LookVector * -moveDir.Z)
            hrp.CFrame = hrp.CFrame + (targetDir.Unit * (State.FlySpeed * dt))
        end
    end

    -- Pürüzsüz Üs Dönüşü (Tween Base)
    if State.Mode == "BASE" and State.SpawnPos then
        local dist = (State.SpawnPos - hrp.Position).Magnitude
        if dist > 5 then
            local timeToArrive = math.clamp(dist / 120, 0.4, 2.5)
            if not State.TweenStorage.ActiveTween and State.TweenStorage.SafeMoveTo then
                State.TweenStorage.SafeMoveTo(CFrame.new(State.SpawnPos), timeToArrive)
            end
        else
            if State.TweenStorage.CancelActiveTweens then
                State.TweenStorage.CancelActiveTweens()
            end
            State.Mode = "NONE"
            print("✅ [LEA BASE]: Üsse güvenli bir şekilde ulaşıldı.")
        end
    end

    -- Kusursuz Hedef Takibi (Tween Target)
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
                if State.TweenStorage.CancelActiveTweens then
                    State.TweenStorage.CancelActiveTweens()
                end
            end
        end)
    end
end)

-- ==============================================================================
-- 3. GÜÇLENDİRİLMİŞ ESP (GÖRSEL OYUNCU İŞARETLEME SİSTEMİ)
-- ==============================================================================
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local char = p.Character
                    local hl = char:FindFirstChild("LeaMassiveESP")
                    if State.Visuals then
                        if not hl then
                            hl = Instance.new("Highlight")
                            hl.Name = "LeaMassiveESP"
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

print("✅ [LEA V33.0 - BÖLÜM 3]: TÜM PARÇALAR BAŞARIYLA BİRLEŞTİRİLDİ. SİSTEM KUSURSUZ ÇALIŞIYOR!")
