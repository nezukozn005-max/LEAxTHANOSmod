-- ==============================================================================
-- LEA MOD ULTIMATE MEGA V39.0 - GOD-TIER EDITION (AUTO CODE & ANTI-RESET FIX)
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

print("⭐ [LEA V39.0]: GOD-TIER EDITION BAŞLATILIYOR...")

-- ==============================================================================
-- 1. GLOBAL STATE VE GÜVENLİK
-- ==============================================================================
if not getgenv().LeaModGlobalState then
    getgenv().LeaModGlobalState = {
        Version = "39.0-GOD",
        Mode = "NONE",
        Speed = 16,
        MoveSpeedIndex = 1, -- 1: 16, 2: 18, 3: 20 (Anti-reset & Anti-kick için aşırı güvenli bant)
        SpawnPos = nil,
        Fly = false,
        FlySpeed = 35,
        Noclip = false,
        Visuals = false,
        CubeActive = false,
        CubePart = nil,
        ResetProtection = true,
        AutoCodeActive = true, -- Sammy Kod Botu Otomatik Aktif
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
-- 2. KESİN ÇÖZÜM: ULTRA GÜÇLÜ BYPASS, ANTI-KICK & ANTI-DETECT (RESET ENGELLEYİCİ)
-- ==============================================================================
local function InitializeGodBypass()
    pcall(function()
        if getgenv then 
            getgenv().protected_environments = true 
            getgenv().secure_mode = true
        end

        if not getrawmetatable then return end
        local gm = getrawmetatable(game)
        setreadonly(gm, false)
        local namecall_original = gm.__namecall
        local index_original = gm.__index

        gm.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if not checkcaller() then
                -- Sunucunun attığı kick, ban, touch exploit algılamaları ve zorla öldürme (BreakJoints/Health) tetikleyicilerini engelle
                if method == "Kick" or method == "kick" or method == "SaveTouchInterest" or method == "SetCoreGuiEnabled" then
                    return nil
                elseif (method == "BreakJoints" or method == "LoadCharacter") and self == LocalPlayer.Character then
                    if State.ResetProtection then return nil end
                end
            end
            return namecall_original(self, ...)
        end)

        gm.__index = newcclosure(function(self, key)
            if not checkcaller() then
                -- Anti-cheat denetimlerini maskele (Hız ve ivmelenme güvenli sınırda gösterilir)
                if self:IsA("Humanoid") then
                    if key == "WalkSpeed" then return 16 end
                    if key == "JumpPower" then return 50 end
                elseif self:IsA("BasePart") and (key == "AssemblyLinearVelocity" or key == "Velocity") and (State.Fly or State.CubeActive or State.Mode ~= "NONE") then
                    return Vector3.new(0, 0, 0)
                end
            end
            return index_original(self, key)
        end)

        setreadonly(gm, true)
    end)
end
pcall(InitializeGodBypass)

-- ==============================================================================
-- 3. SAMMY OTOMATİK KOD DENEYİCİ (AUTO-CODE BRUTEFORCE BOTU)
-- ==============================================================================
-- Sammy'nin yazacağı kelime havuzu ve sayı kombinasyonları ile kod alanını otomatik doldurur
task.spawn(function()
    local commonWords = {"free", "pet", "update", "release", "gift", "boost", "code", "lea", "ruby", "gem", "egg", "happy", "event"}
    local numbers = {100, 200, 300, 400, 500, 1000, 2026, 50, 10, 5}
    
    local function FindCodeTextBox()
        -- Oyun içindeki olası kod textbox'larını veyaGUI öğelerini tarar
        for _, gui in ipairs(CoreGui:GetDescendants()) do
            if gui:IsA("TextBox") then
                local name = string.lower(gui.Name .. (gui.Parent and gui.Parent.Name or ""))
                if string.find(name, "code") or string.find(name, "promo") or string.find(name, "redeem") then
                    return gui
                end
            end
        end
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            for _, gui in ipairs(playerGui:GetDescendants()) do
                if gui:IsA("TextBox") then
                    local name = string.lower(gui.Name .. (gui.Parent and gui.Parent.Name or ""))
                    if string.find(name, "code") or string.find(name, "promo") or string.find(name, "redeem") then
                        return gui
                    end
                end
            end
        end
        return nil
    end

    while true do
        task.wait(4)
        if State.AutoCodeActive then
            pcall(function()
                local textBox = FindCodeTextBox()
                if textBox then
                    -- Rastgele bir kelime ve sayı kombinasyonu türetip Sammy mantığıyla dener
                    local word = commonWords[math.random(1, #commonWords)]
                    local num = numbers[math.random(1, #numbers)]
                    local testCode = word .. tostring(num)
                    
                    textBox.Text = testCode
                    -- Metin değişim tetikleyicilerini simüle et
                    if firetextboxchanged then
                        firetextboxchanged(textBox)
                    end
                    
                    -- Redeem / Onay butonunu bulup tetiklemeye çalış
                    for _, btn in ipairs(textBox.Parent:GetDescendants()) do
                        if btn:IsA("TextButton") and (string.find(string.lower(btn.Name), "claim") or string.find(string.lower(btn.Text), "redeem") or string.find(string.lower(btn.Text), "ok")) then
                            for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do
                                conn:Fire()
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ==============================================================================
-- 4. ULTRA KÜÇÜK, FENOMENAL MOBİL ARAYÜZ (GUI)
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
ActiveWatermark.Size = UDim2.new(0, 200, 0, 22)
ActiveWatermark.Position = UDim2.new(0.5, -100, 0.18, -11)
ActiveWatermark.BackgroundTransparency = 1
ActiveWatermark.Text = "⚡ LEA GOD V39 ACTIVE ⚡"
ActiveWatermark.TextColor3 = State.ThemeColor
ActiveWatermark.TextSize = 11
ActiveWatermark.Font = Enum.Font.GothamBlack
ActiveWatermark.Visible = false
ActiveWatermark.TextStrokeTransparency = 0.3
ActiveWatermark.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

-- Daha da ufak, başparmakla rahatça kontrol edilen minimalist panel
local MainContainer = Instance.new("Frame", ScreenGui)
MainContainer.Size = UDim2.new(0, 135, 0, 185)
MainContainer.Position = UDim2.new(0.5, -67, 0.5, -92)
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
MainStroke.Transparency = 0.1

local HeaderFrame = Instance.new("Frame", MainContainer)
HeaderFrame.Size = UDim2.new(1, 0, 0, 18)
HeaderFrame.BackgroundColor3 = Color3.fromRGB(3, 3, 6)
HeaderFrame.BorderSizePixel = 0

local HeaderCorner = Instance.new("UICorner", HeaderFrame)
HeaderCorner.CornerRadius = UDim.new(0, 4)

local TitleLabel = Instance.new("TextLabel", HeaderFrame)
TitleLabel.Size = UDim2.new(1, -18, 1, 0)
TitleLabel.Position = UDim2.new(0, 3, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "LEA V39"
TitleLabel.TextColor3 = State.ThemeColor
TitleLabel.TextSize = 7.5
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local CloseButton = Instance.new("TextButton", HeaderFrame)
CloseButton.Size = UDim2.new(0, 12, 0, 12)
CloseButton.Position = UDim2.new(1, -14, 0, 3)
CloseButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 6

local CloseCorner = Instance.new("UICorner", CloseButton)
CloseCorner.CornerRadius = UDim.new(0, 2)

local ScrollContainer = Instance.new("ScrollingFrame", MainContainer)
ScrollContainer.Size = UDim2.new(1, -4, 1, -20)
ScrollContainer.Position = UDim2.new(0, 2, 0, 19)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.ScrollBarThickness = 1
ScrollContainer.ScrollBarImageColor3 = State.ThemeColor
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 205)

local ButtonListLayout = Instance.new("UIListLayout", ScrollContainer)
ButtonListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ButtonListLayout.Padding = UDim.new(0, 2)
ButtonListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 28, 0, 28)
ToggleBtn.Position = UDim2.new(1, -35, 0.5, -14)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(6, 6, 10)
ToggleBtn.Text = "LEA"
ToggleBtn.TextColor3 = State.ThemeColor
ToggleBtn.TextSize = 7.5
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
-- 5. KESİN ÇÖZÜM: ÖLÜM VE RESET DÖNGÜSÜ KİLİDİ
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
                    humanoid.Health = 70
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
-- 6. MİKRO, ANTI-RECOIL KÜP SİSTEMİ (PET ALINCA GERİ ATMAYAN YAPI)
-- ==============================================================================
local function ToggleCube(on)
    State.CubeActive = on
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if on and hrp then
        if not State.CubePart or not State.CubePart.Parent then
            local cube = Instance.new("Part")
            cube.Name = "LeaPlatformCube"
            -- Pet aldıktan sonra geri tepme/fırlama yapmayan, ağırlıksız, sürtünmesiz mikro taban
            cube.Size = Vector3.new(1.8, 0.25, 1.8)
            cube.Position = hrp.Position - Vector3.new(0, 3.2, 0)
            cube.Anchored = true
            cube.CanCollide = true
            cube.Massless = true
            cube.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            cube.Material = Enum.Material.Neon
            cube.Color = State.ThemeColor
            cube.Transparency = 0.35
            
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
-- 7. BUTONLAR VE İNCELTİLMİŞ KONTROL SİSTEMİ
-- ==============================================================================
local function CreateMenuButton(order, text, defaultColor, activeColor, callback)
    local btn = Instance.new("TextButton", ScrollContainer)
    btn.LayoutOrder = order
    btn.Size = UDim2.new(1, -2, 0, 19)
    btn.BackgroundColor3 = defaultColor
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 7
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
    btn.Size = UDim2.new(1, -2, 0, 19)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 7
    btn.Font = Enum.Font.GothamBold
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 3)
    
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
        -- Hız oranları 16 - 18 - 20 (Anti-reset ve aşırı hızlı takibi kusursuz dengeleyen bant)
        local speeds = {16, 18, 20}
        local currentMoveSpeed = speeds[State.MoveSpeedIndex] or 16
        local adjustedTime = math.max(timeToArrive * (16 / currentMoveSpeed), 0.25)
        
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

-- Hız Kademesi (Max 20 Sınırı: 16 -> 18 -> 20 - Reset ve Atılmayı Tamamen Önler)
CreateActionItem(8, "⚡ HIZ: 16 (GÜVENLİ)", Color3.fromRGB(30, 30, 45), function()
    State.MoveSpeedIndex = State.MoveSpeedIndex + 1
    if State.MoveSpeedIndex > 3 then State.MoveSpeedIndex = 1 end
    
    local speeds = {16, 18, 20}
    State.Speed = speeds[State.MoveSpeedIndex]
    
    local targetBtn = ScrollContainer:GetChildren()[8]
    if targetBtn and targetBtn:IsA("TextButton") then
        targetBtn.Text = "⚡ HIZ: " .. State.Speed .. " (GÜVENLİ)"
    end
end)

CreateActionItem(9, "📍 ÜS KONUMU YAP", Color3.fromRGB(30, 45, 35), function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        State.SpawnPos = hrp.Position + Vector3.new(0, 3, 0)
    end
end)

-- ==============================================================================
-- 8. FİZİK, MOTOR VE TAKİP DÖNGÜLERİ
-- ==============================================================================

-- Noclip Döngüsü
table.insert(State.Connections, RunS
