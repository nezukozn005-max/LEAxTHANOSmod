-- ==============================================================================
-- LEA MOD ULTIMATE MEGA V32.0 - MASSIVE EDITION (CORRECTED & OPTIMIZED)
-- MOBİL ARAYÜZ VE GELİŞTİRİLMİŞ FİZİK MOTORU ALTYAPISI
-- ==============================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- ==============================================================================
-- 1. DEVASA DURUM YÖNETİMİ (STATE MANAGEMENT) VE SİSTEM YAPILANDIRMASI
-- ==============================================================================
local LeaEngine = {
    Config = {
        Version = "32.0-MASSIVE-FIXED",
        MenuWidth = 320,
        MenuHeight = 450,
        Theme = {
            Background = Color3.fromRGB(15, 15, 22),
            Border = Color3.fromRGB(0, 255, 200),
            Text = Color3.fromRGB(240, 240, 240),
            ButtonDefault = Color3.fromRGB(25, 25, 35),
            ButtonActive = Color3.fromRGB(0, 200, 100),
            ButtonHover = Color3.fromRGB(35, 35, 45)
        },
        Animations = {
            TweenTime = 0.3,
            EasingStyle = Enum.EasingStyle.Quart,
            EasingDirection = Enum.EasingDirection.Out
        },
        MobileOptimized = true
    },
    State = {
        IsMenuOpen = true,
        Speed = 16,
        JumpPower = 50,
        FastWalkActive = false,
        BaseMode = false,
        TargetMode = false,
        Visuals = false,
        SpawnLocation = nil,
        Connections = {},
        DiagnosticLogs = {}
    }
}

-- ==============================================================================
-- 2. GÜVENLİ FONKSİYON TETİKLEYİCİ VE HATA AYIKLAMA MOTORU
-- ==============================================================================
local function LogEvent(message, level)
    local prefix = level == "ERROR" and "❌ [LEA ERROR]: " or "✅ [LEA INFO]: "
    local formatted = os.date("%H:%M:%S") .. " | " .. prefix .. tostring(message)
    table.insert(LeaEngine.State.DiagnosticLogs, formatted)
    if #LeaEngine.State.DiagnosticLogs > 150 then
        table.remove(LeaEngine.State.DiagnosticLogs, 1)
    end
end

local function SafeExecute(taskName, func, ...)
    local success, err = pcall(func, ...)
    if not success then
        LogEvent("Görev Çöktü (" .. taskName .. "): " .. tostring(err), "ERROR")
    end
    return success
end

-- ==============================================================================
-- 3. MOBİL OPTİMİZASYONLU DEVASA GUI MİMARİSİ
-- ==============================================================================
local function ConstructUI()
    SafeExecute("Eski Arayüz Temizliği", function()
        local existing = CoreGui:FindFirstChild("LeaModMassiveUI")
        if existing then existing:Destroy() end
    end)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LeaModMassiveUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Name = "MainEngineFrame"
    MainFrame.Size = UDim2.new(0, LeaEngine.Config.MenuWidth, 0, LeaEngine.Config.MenuHeight)
    MainFrame.Position = UDim2.new(0.5, -LeaEngine.Config.MenuWidth/2, 0.5, -LeaEngine.Config.MenuHeight/2)
    MainFrame.BackgroundColor3 = LeaEngine.Config.Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true

    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 12)

    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = LeaEngine.Config.Theme.Border
    MainStroke.Thickness = 2.5
    MainStroke.Transparency = 0.2

    local HeaderFrame = Instance.new("Frame", MainFrame)
    HeaderFrame.Size = UDim2.new(1, 0, 0, 45)
    HeaderFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    HeaderFrame.BorderSizePixel = 0
    
    local HeaderCorner = Instance.new("UICorner", HeaderFrame)
    HeaderCorner.CornerRadius = UDim.new(0, 12)
    
    local Title = Instance.new("TextLabel", HeaderFrame)
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "LEA V32.0 (FIXED EDITION)"
    Title.TextColor3 = LeaEngine.Config.Theme.Border
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBlack
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local CloseButton = Instance.new("TextButton", HeaderFrame)
    CloseButton.Size = UDim2.new(0, 35, 0, 35)
    CloseButton.Position = UDim2.new(1, -40, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 14
    
    local CloseCorner = Instance.new("UICorner", CloseButton)
    CloseCorner.CornerRadius = UDim.new(0, 8)

    local ScrollContainer = Instance.new("ScrollingFrame", MainFrame)
    ScrollContainer.Size = UDim2.new(1, -20, 1, -60)
    ScrollContainer.Position = UDim2.new(0, 10, 0, 50)
    ScrollContainer.BackgroundTransparency = 1
    ScrollContainer.ScrollBarThickness = 6
    ScrollContainer.ScrollBarImageColor3 = LeaEngine.Config.Theme.Border
    ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 800)

    local Layout = Instance.new("UIListLayout", ScrollContainer)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 10)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local MiniButton = Instance.new("TextButton", ScreenGui)
    MiniButton.Size = UDim2.new(0, 60, 0, 60)
    MiniButton.Position = UDim2.new(1, -80, 0.5, -30)
    MiniButton.BackgroundColor3 = LeaEngine.Config.Theme.Background
    MiniButton.Text = "LEA"
    MiniButton.TextColor3 = LeaEngine.Config.Theme.Border
    MiniButton.TextSize = 14
    MiniButton.Font = Enum.Font.GothamBlack
    MiniButton.Visible = false

    local MiniCorner = Instance.new("UICorner", MiniButton)
    MiniCorner.CornerRadius = UDim.new(1, 0)
    
    local MiniStroke = Instance.new("UIStroke", MiniButton)
    MiniStroke.Color = LeaEngine.Config.Theme.Border
    MiniStroke.Thickness = 2

    return MainFrame, ScrollContainer, MiniButton, CloseButton
end

local MainPanel, ScrollArea, ToggleBtn, CloseBtn = ConstructUI()

-- ==============================================================================
-- 4. ANİMASYONLU BUTON OLUŞTURUCU FACTORY
-- ==============================================================================
local function CreateToggle(order, labelText, stateKey)
    local Btn = Instance.new("TextButton", ScrollArea)
    Btn.LayoutOrder = order
    Btn.Size = UDim2.new(1, -10, 0, 45)
    Btn.BackgroundColor3 = LeaEngine.Config.Theme.ButtonDefault
    Btn.Text = labelText .. " [KAPALI]"
    Btn.TextColor3 = LeaEngine.Config.Theme.Text
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 14
    Btn.AutoButtonColor = false

    local Corner = Instance.new("UICorner", Btn)
    Corner.CornerRadius = UDim.new(0, 8)

    Btn.MouseButton1Click:Connect(function()
        LeaEngine.State[stateKey] = not LeaEngine.State[stateKey]
        local isActive = LeaEngine.State[stateKey]
        
        Btn.Text = labelText .. (isActive and " [AÇIK]" or " [KAPALI]")
        
        local tweenInfo = TweenInfo.new(LeaEngine.Config.Animations.TweenTime, LeaEngine.Config.Animations.EasingStyle, LeaEngine.Config.Animations.EasingDirection)
        local goal = {BackgroundColor3 = isActive and LeaEngine.Config.Theme.ButtonActive or LeaEngine.Config.Theme.ButtonDefault}
        TweenService:Create(Btn, tweenInfo, goal):Play()
        
        LogEvent(labelText .. " durumu değiştirildi: " .. tostring(isActive), "INFO")
    end)
    
    return Btn
end

local function CreateAction(order, labelText, callback)
    local Btn = Instance.new("TextButton", ScrollArea)
    Btn.LayoutOrder = order
    Btn.Size = UDim2.new(1, -10, 0, 45)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    Btn.Text = labelText
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14

    local Corner = Instance.new("UICorner", Btn)
    Corner.CornerRadius = UDim.new(0, 8)

    Btn.MouseButton1Click:Connect(function()
        SafeExecute("Action Click: " .. labelText, callback)
    end)
    
    return Btn
end

-- ==============================================================================
-- 5. MENÜ ETKİLEŞİM VE GÖRÜNÜRLÜK ANİMASYONLARI
-- ==============================================================================
local function ToggleMenuVisibility(show)
    LeaEngine.State.IsMenuOpen = show
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    
    if show then
        MainPanel.Visible = true
        ToggleBtn.Visible = false
        MainPanel.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(MainPanel, tweenInfo, {Size = UDim2.new(0, LeaEngine.Config.MenuWidth, 0, LeaEngine.Config.MenuHeight)}):Play()
    else
        local shrink = TweenService:Create(MainPanel, tweenInfo, {Size = UDim2.new(0, 0, 0, 0)})
        shrink:Play()
        shrink.Completed:Connect(function()
            if not LeaEngine.State.IsMenuOpen then
                MainPanel.Visible = false
                ToggleBtn.Visible = true
            end
        end)
    end
end

CloseBtn.MouseButton1Click:Connect(function() ToggleMenuVisibility(false) end)
ToggleBtn.MouseButton1Click:Connect(function() ToggleMenuVisibility(true) end)

-- ==============================================================================
-- 6. MOTOR FONKSİYONLARI VE OYUN İÇİ ETKİLEŞİM (GÜVENLİ MOD)
-- ==============================================================================
local function FetchCharacterData()
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hrp, hum, char
end

-- Butonları Sisteme Kaydet
CreateToggle(1, "🏃 Hızlı Yürüme", "FastWalkActive")
CreateToggle(2, "🌌 Gelişmiş ESP (Visuals)", "Visuals")
CreateToggle(3, "🏠 Güvenli Üs Modu", "BaseMode")
CreateToggle(4, "🎯 Yumuşak Takip Modu", "TargetMode")

CreateAction(5, "⚡ Hızı +10 Artır", function()
    LeaEngine.State.Speed = math.min(LeaEngine.State.Speed + 10, 100)
    LogEvent("Hız güncellendi: " .. LeaEngine.State.Speed, "INFO")
end)

CreateAction(6, "📍 Zemin Noktasını Kaydet", function()
    local hrp, hum, char = FetchCharacterData()
    if hrp then
        LeaEngine.State.SpawnLocation = hrp.Position
        LogEvent("Yeni zemin noktası başarıyla kaydedildi.", "INFO")
    end
end)

CreateAction(7, "🌙 Gece/Gündüz Döngüsü", function()
    if Lighting.ClockTime == 14 then
        Lighting.ClockTime = 0
        Lighting.Brightness = 0.5
    else
        Lighting.ClockTime = 14
        Lighting.Brightness = 2
    end
end)

-- ==============================================================================
-- 7. MERKEZİ GÜNCELLEME DÖNGÜSÜ (HEARTBEAT MOTORU - ANTİ-CHEAT UYUMLU)
-- ==============================================================================
RunService.Heartbeat:Connect(function(deltaTime)
    local hrp, hum, char = FetchCharacterData()
    if not hrp or not hum then return end

    -- Güvenli Yürüme Hızı Kontrolü
    if LeaEngine.State.FastWalkActive then
        if hum.MoveDirection.Magnitude > 0 then
            hum.WalkSpeed = LeaEngine.State.Speed
        end
    else
        hum.WalkSpeed = 16
    end

    -- Güvenli Hedef Takibi (Sunucu banını önlemek için Humanoid:MoveTo kullanıldı)
    if LeaEngine.State.TargetMode then
        local targetPlayer, minDist = nil, 200
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local eHrp = p.Character:FindFirstChild("HumanoidRootPart")
                if eHrp then
                    local dist = (eHrp.Position - hrp.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        targetPlayer = eHrp
                    end
                end
            end
        end
        
        if targetPlayer and minDist > 8 then
            hum:MoveTo(targetPlayer.Position)
        end
    end

    -- Güvenli Üs Dönüşü (Humanoid:MoveTo ile sunucu destekli pürüzsüz rota)
    if LeaEngine.State.BaseMode and LeaEngine.State.SpawnLocation then
        local dist = (LeaEngine.State.SpawnLocation - hrp.Position).Magnitude
        if dist > 5 then
            hum:MoveTo(LeaEngine.State.SpawnLocation)
        else
            LeaEngine.State.BaseMode = false
            LogEvent("Üsse güvenle varıldı.", "INFO")
        end
    end
end)

-- ==============================================================================
-- 8. OYUNCU ESP (EKSTRA GÖRSELLEŞTİRİCİ MOTOR)
-- ==============================================================================
task.spawn(function()
    while task.wait(1.5) do
        SafeExecute("ESP Worker Thread", function()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local char = player.Character
                    local highlight = char:FindFirstChild("LeaESP_V32")
                    
                    if LeaEngine.State.Visuals then
                        if not highlight then
                            highlight = Instance.new("Highlight")
                            highlight.Name = "LeaESP_V32"
                            highlight.FillColor = LeaEngine.Config.Theme.Border
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            highlight.FillTransparency = 0.6
                            highlight.Parent = char
                        end
                    else
                        if highlight then highlight:Destroy() end
                    end
                end
            end
        end)
    end
end)

LogEvent("Lea Mod Massive Edition V32 Engine başarıyla başlatıldı ve hatalar giderildi.", "INFO")
-- ==============================================================================
-- LEA MOD ULTIMATE MEGA V32.0 - MASSIVE EDITION (PART 2: ADVANCED FLY & NOCLIP)
-- ==============================================================================

-- Bu modül ana motora ek olarak gelişmiş Uçuş (Fly), Hayalet (Noclip) ve 
-- Fizik Hilelerine Karşı Koruma (Anti-Rubberbanding) mekanizmalarını entegre eder.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Ek Durum Parametreleri (Ana motordaki LeaEngine.State tablosuna eklenecektir)
-- LeaEngine.State.FlyActive = false
-- LeaEngine.State.NoclipActive = false
-- LeaEngine.State.AntiRubberbandActive = true

local FlyConnection = nil
local NoclipConnection = nil

-- ==============================================================================
-- 1. GELİŞMİŞ UÇUŞ MOTORU (SAFE FLY SYSTEM)
-- ==============================================================================
local function ToggleFly(isActive)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if isActive then
        -- Yerçekimini etkisiz kılmak için BodyVelocity veya AssemblyLinearVelocity kontrolü
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = "LeaFlyVelocity"
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = hrp

        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.Name = "LeaFlyGyro"
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.CFrame = hrp.CFrame
        bodyGyro.Parent = hrp

        hum.PlatformStand = true

        FlyConnection = RunService.RenderStepped:Connect(function()
            if not LocalPlayer.Character or not hrp.Parent then return end
            
            local camCFrame = Camera.CFrame
            local moveDirection = Vector3.new(0, 0, 0)

            -- Mobil ve Tuş Kombinasyonları İçin Yön Hesaplama
            if UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Up) then
                moveDirection = moveDirection + camCFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.Down) then
                moveDirection = moveDirection - camCFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.Left) then
                moveDirection = moveDirection - camCFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) or UserInputService:IsKeyDown(Enum.KeyCode.Right) then
                moveDirection = moveDirection + camCFrame.RightVector
            end

            bodyVelocity.Velocity = moveDirection * 50
            bodyGyro.CFrame = camCFrame
        end)
    else
        if FlyConnection then
            FlyConnection:Disconnect()
            FlyConnection = nil
        end
        
        if hrp:FindFirstChild("LeaFlyVelocity") then hrp.LeaFlyVelocity:Destroy() end
        if hrp:FindFirstChild("LeaFlyGyro") then hrp.LeaFlyGyro:Destroy() end
        
        if hum then
            hum.PlatformStand = false
        end
    end
end

-- ==============================================================================
-- 2. HAYALET NOCLIP MOTORU (WALL PASSING SYSTEM)
-- ==============================================================================
local function ToggleNoclip(isActive)
    if isActive then
        NoclipConnection = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if NoclipConnection then
            NoclipConnection:Disconnect()
            NoclipConnection = nil
        end
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- ==============================================================================
-- 3. ANTİ-RUBBERBANDING VE POZİSYON KORUMA FİLTRESİ
-- ==============================================================================
local function InitializeAntiRubberband()
    RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        
        if hrp then
            -- Harita altı sınır kontrolü (Void düşüş koruması)
            if hrp.Position.Y < -500 then
                hrp.CFrame = CFrame.new(hrp.Position.X, 50, hrp.Position.Z)
            end
        end
    end)
end

InitializeAntiRubberband()
print("✅ [LEA MOD PART 2]: Uçuş, Noclip ve Fizik Güvenlik Katmanı Yüklendi.")
-- ==============================================================================
-- LEA MOD ULTIMATE MEGA V32.0 - MASSIVE EDITION (PART 3: CONFIG, GUI INTEGRATION & EXECUTOR BYPASS)
-- ==============================================================================

-- Bu son bölüm, Part 1 (Ana Motor) ve Part 2 (Fly/Noclip) modüllerini tek bir çatı altında 
-- birleştirir, arayüze yeni butonlar ekler ve mobil executor ortamları için güvenlik kancalarını kurar.

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

-- ==============================================================================
-- 1. EXECUTOR ORTAM KONTROLÜ VE METATABLE GÜVENLİK Kancaları (BYPASS)
-- ==============================================================================
local function InitializeExecutorBypass()
    local success, err = pcall(function()
        if getgenv then
            getgenv().LeaProtectedMode = true
        end
        
        -- Roblox güvenlik loglamalarını ve hata tetikleyicilerini bastırma girişimi
        if hookmetamethod and getrawmetatable then
            local mt = getrawmetatable(game)
            setreadonly(mt, false)
            local oldNamecall = mt.__namecall
            
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                -- Sunucuya giden şüpheli log veya telemetri isteklerini filtrele
                if method == "Kick" or method == "ReportAbuse" then
                    return nil
                end
                return oldNamecall(self, ...)
            end)
            setreadonly(mt, true)
        end
    end)
    
    if not success then
        warn("⚠️ [LEA WARNING]: Bazı gelişmiş executor özellikleri bu cihazda desteklenmiyor: " .. tostring(err))
    end
end

InitializeExecutorBypass()

-- ==============================================================================
-- 2. PART 1 VE PART 2 ENTEGRASYON KÖPRÜSÜ
-- ==============================================================================
-- Not: Bu kodun tam verimli çalışabilmesi için Part 1 ve Part 2 ile aynı 
-- script ortamında (veya birleştirilmiş tek bir dosya halinde) çalıştırılması gerekir.

local function RegisterPart3Components()
    local screenGui = CoreGui:FindFirstChild("LeaModMassiveUI")
    if not screenGui then
        warn("❌ [LEA ERROR]: Ana Arayüz (Part 1) bulunamadı! Lütfen önce Part 1'i yükleyin.")
        return
    end

    local mainFrame = screenGui:FindFirstChild("MainEngineFrame")
    if not mainFrame then return end
    
    local scrollContainer = mainFrame:FindFirstChild("ScrollingFrame", true)
    if not scrollContainer then return end

    -- Yardımcı Buton Üretici (Part 1 ile uyumlu)
    local function CreateAdvancedToggle(order, labelText, callback)
        local Btn = Instance.new("TextButton", scrollContainer)
        Btn.LayoutOrder = order
        Btn.Size = UDim2.new(1, -10, 0, 45)
        Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        Btn.Text = labelText .. " [KAPALI]"
        Btn.TextColor3 = Color3.fromRGB(240, 240, 240)
        Btn.Font = Enum.Font.GothamSemibold
        Btn.TextSize = 14
        Btn.AutoButtonColor = false

        local Corner = Instance.new("UICorner", Btn)
        Corner.CornerRadius = UDim.new(0, 8)

        local activeState = false
        Btn.MouseButton1Click:Connect(function()
            activeState = not activeState
            Btn.Text = labelText .. (activeState and " [AÇIK]" or " [KAPALI]")
            
            local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            local goal = {BackgroundColor3 = activeState and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(25, 25, 35)}
            TweenService:Create(Btn, tweenInfo, goal):Play()
            
            callback(activeState)
        end)
        
        return Btn
    end

    -- Uçuş ve Noclip Tuşlarını Arayüze Dahil Et (Sıra 10 ve 11)
    CreateAdvancedToggle(10, "✈️ Gelişmiş Uçuş (Fly)", function(state)
        -- Part 2 içindeki ToggleFly fonksiyonunu tetikler
        pcall(function()
            ToggleFly(state)
        end)
    end)

    CreateAdvancedToggle(11, "👻 Hayalet Modu (Noclip)", function(state)
        -- Part 2 içindeki ToggleNoclip fonksiyonunu tetikler
        pcall(function()
            ToggleNoclip(state)
        end)
    end)

    -- Scroll Alanının Boyutunu Yeni Butonlara Göre Otomatik Güncelle
    scrollContainer.CanvasSize = UDim2.new(0, 0, 0, 1100)
end

RegisterPart3Components()

-- ==============================================================================
-- 3. BİLDİRİM VE BAŞARILI KURULUM RAPORU
-- ==============================================================================
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "LEA MOD V32.0",
        Text = "Tüm Parçalar (Part 1, 2, 3) Başarıyla Yüklendi!",
        Duration = 5
    })
end)

print("✅ [LEA MOD PART 3]: Tüm modüller entegre edildi, arayüz genişletildi ve sistem aktif.")
