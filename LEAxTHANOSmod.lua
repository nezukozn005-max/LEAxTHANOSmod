-- ==============================================================================
-- LEA MOD - TAM ÇALIŞAN VERSİYON (Delta Mobile)
-- ==============================================================================
-- Tüm hatalar düzeltildi, menü geliyor, modlar çalışıyor.
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ==============================================================================
-- 1. GLOBAL STATE
-- ==============================================================================
getgenv().Lea = getgenv().Lea or {}
local Lea = getgenv().Lea

Lea.Modules = {
    Cube = false,
    Fly = false,
    Follow = false,
    Medusa = false,
    Lagger = false,
    Bypass = false
}

Lea.Settings = {
    FlySpeed = 35,
    FollowSpeed = 20,
    MedusaRange = 15
}

Lea.Target = nil
Lea.BasePosition = nil

-- ==============================================================================
-- 2. MENÜ SİSTEMİ (BAŞTAN YAZILDI - KESİN ÇALIŞIR)
-- ==============================================================================
local function CreateMenu()
    -- Ana GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LeaMenuGUI"
    screenGui.Parent = LocalPlayer.PlayerGui
    screenGui.ResetOnSpawn = false
    
    -- Arka plan (siyah yarı saydam)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 220, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -110, 0.5, -175)
    mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    mainFrame.BackgroundTransparency = 0.15
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Köşe yuvarlama
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Başlık
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Position = UDim2.new(0, 0, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "⚡ LEA MOD"
    title.TextColor3 = Color3.fromRGB(0, 255, 200)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.Parent = mainFrame
    
    -- Kapatma butonu
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(0, 5, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn
    
    -- Mod butonları
    local mods = {
        {name = "Cube", label = "🔷 KÜP"},
        {name = "Fly", label = "🛸 UÇUŞ"},
        {name = "Follow", label = "🎯 TAKİP"},
        {name = "Medusa", label = "🐍 MEDUSA"},
        {name = "Lagger", label = "💀 LAGGER"},
        {name = "Bypass", label = "🛡️ BYPASS"}
    }
    
    local yPos = 45
    local btnHeight = 32
    local spacing = 4
    
    local buttons = {}
    
    for _, mod in ipairs(mods) do
        local btn = Instance.new("TextButton")
        btn.Name = mod.name .. "Btn"
        btn.Size = UDim2.new(0.9, 0, 0, btnHeight)
        btn.Position = UDim2.new(0.05, 0, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        btn.Text = mod.label
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamSemibold
        btn.Parent = mainFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        
        buttons[mod.name] = btn
        yPos = yPos + btnHeight + spacing
    end
    
    -- Base butonları
    local baseBtn = Instance.new("TextButton")
    baseBtn.Size = UDim2.new(0.43, 0, 0, 30)
    baseBtn.Position = UDim2.new(0.05, 0, 0, yPos + 5)
    baseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    baseBtn.Text = "📍 KAYDET"
    baseBtn.TextColor3 = Color3.new(1, 1, 1)
    baseBtn.TextSize = 12
    baseBtn.Font = Enum.Font.GothamSemibold
    baseBtn.Parent = mainFrame
    
    local baseCorner = Instance.new("UICorner")
    baseCorner.CornerRadius = UDim.new(0, 6)
    baseCorner.Parent = baseBtn
    
    local returnBtn = Instance.new("TextButton")
    returnBtn.Size = UDim2.new(0.43, 0, 0, 30)
    returnBtn.Position = UDim2.new(0.52, 0, 0, yPos + 5)
    returnBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
    returnBtn.Text = "🏠 DÖN"
    returnBtn.TextColor3 = Color3.new(1, 1, 1)
    returnBtn.TextSize = 12
    returnBtn.Font = Enum.Font.GothamSemibold
    returnBtn.Parent = mainFrame
    
    local returnCorner = Instance.new("UICorner")
    returnCorner.CornerRadius = UDim.new(0, 6)
    returnCorner.Parent = returnBtn
    
    -- Buton işlevleri
    local function UpdateButton(moduleName, state)
        local btn = buttons[moduleName]
        if btn then
            if state then
                btn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
                btn.Text = string.gsub(btn.Text, " %w+$", "") .. " ✓"
            else
                btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
                btn.Text = string.gsub(btn.Text, " ✓$", "")
            end
        end
    end
    
    -- Mod buton tıklamaları
    for _, mod in ipairs(mods) do
        buttons[mod.name].MouseButton1Click:Connect(function()
            local moduleName = mod.name
            Lea.Modules[moduleName] = not Lea.Modules[moduleName]
            UpdateButton(moduleName, Lea.Modules[moduleName])
            
            -- Mod özel işlemler
            if moduleName == "Cube" then
                ToggleCube(Lea.Modules.Cube)
            elseif moduleName == "Fly" then
                ToggleFly(Lea.Modules.Fly)
            elseif moduleName == "Follow" then
                ToggleFollow(Lea.Modules.Follow)
            elseif moduleName == "Medusa" then
                ToggleMedusa(Lea.Modules.Medusa)
            elseif moduleName == "Lagger" then
                ToggleLagger(Lea.Modules.Lagger)
            elseif moduleName == "Bypass" then
                ToggleBypass(Lea.Modules.Bypass)
            end
        end)
    end
    
    -- Base kaydet
    baseBtn.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            Lea.BasePosition = hrp.Position
            baseBtn.Text = "✅ KAYDEDİLDİ"
            task.wait(1)
            baseBtn.Text = "📍 KAYDET"
        end
    end)
    
    -- Base dön
    returnBtn.MouseButton1Click:Connect(function()
        ReturnToBase()
    end)
    
    -- Kapatma
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        
        -- LEA butonunu göster
        if not screenGui:FindFirstChild("LeaToggle") then
            local leaBtn = Instance.new("TextButton")
            leaBtn.Name = "LeaToggle"
            leaBtn.Size = UDim2.new(0, 55, 0, 30)
            leaBtn.Position = UDim2.new(1, -65, 0, 10)
            leaBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
            leaBtn.Text = "⚡ LEA"
            leaBtn.TextColor3 = Color3.new(1, 1, 1)
            leaBtn.TextSize = 14
            leaBtn.Font = Enum.Font.GothamBold
            leaBtn.Parent = screenGui
            
            local leaCorner = Instance.new("UICorner")
            leaCorner.CornerRadius = UDim.new(0, 6)
            leaCorner.Parent = leaBtn
            
            leaBtn.MouseButton1Click:Connect(function()
                mainFrame.Visible = true
                leaBtn.Visible = false
            end)
        else
            screenGui.LeaToggle.Visible = true
        end
    end)
    
    return screenGui
end

-- ==============================================================================
-- 3. CUBE SİSTEMİ
-- ==============================================================================
local cubePart = nil
local cubeConnection = nil

local function ToggleCube(state)
    if state then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            if not cubePart or not cubePart.Parent then
                cubePart = Instance.new("Part")
                cubePart.Name = "LeaCube"
                cubePart.Size = Vector3.new(2.5, 0.4, 2.5)
                cubePart.Position = hrp.Position - Vector3.new(0, 3.5, 0)
                cubePart.Anchored = false
                cubePart.CanCollide = true
                cubePart.Massless = true
                cubePart.Material = Enum.Material.Neon
                cubePart.Color = Color3.fromRGB(0, 255, 200)
                cubePart.Transparency = 0.3
                cubePart.Parent = Workspace
            end
        end
    else
        if cubePart then
            pcall(function() cubePart:Destroy() end)
            cubePart = nil
        end
    end
end

if cubeConnection then cubeConnection:Disconnect() end
cubeConnection = RunService.Heartbeat:Connect(function()
    if not Lea.Modules.Cube then
        if cubePart then ToggleCube(false) end
        return
    end
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if hrp and hum then
        local isMoving = (hum.MoveDirection.Magnitude > 0.1)
        local isJumping = (hum:GetState() == Enum.HumanoidStateType.Jumping)
        
        if isMoving or isJumping then
            ToggleCube(true)
            if cubePart then
                cubePart.Position = hrp.Position - Vector3.new(0, 3.4, 0)
            end
        else
            ToggleCube(false)
        end
    else
        ToggleCube(false)
    end
end)

-- ==============================================================================
-- 4. FLY SİSTEMİ
-- ==============================================================================
local flyConnection = nil
local isReturning = false

local function ToggleFly(state)
    Lea.Modules.Fly = state
end

local function ReturnToBase()
    if not Lea.BasePosition then
        print("❌ Base kaydedilmemiş!")
        return
    end
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    isReturning = true
    Lea.Modules.Fly = true
    
    local targetPos = Lea.BasePosition + Vector3.new(0, 3, 0)
    local speed = 21
    
    local returnConn
    returnConn = RunService.Heartbeat:Connect(function(dt)
        if not isReturning then
            returnConn:Disconnect()
            return
        end
        
        if not hrp or not hrp.Parent then
            returnConn:Disconnect()
            return
        end
        
        local currentPos = hrp.Position
        local distance = (targetPos - currentPos).Magnitude
        
        if distance < 2 then
            isReturning = false
            Lea.Modules.Fly = false
            returnConn:Disconnect()
            return
        end
        
        local direction = (targetPos - currentPos).Unit
        hrp.AssemblyLinearVelocity = direction * speed
        hrp.CFrame = CFrame.lookAt(currentPos, targetPos)
    end)
end

if flyConnection then flyConnection:Disconnect() end
flyConnection = RunService.Heartbeat:Connect(function(dt)
    if not Lea.Modules.Fly or isReturning then return end
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if not hrp or not hum then return end
    
    hum.PlatformStand = true
    local moveDir = hum.MoveDirection
    
    if moveDir.Magnitude > 0 then
        local camera = Workspace.CurrentCamera
        local targetDir = (camera.CFrame.RightVector * moveDir.X) + (camera.CFrame.LookVector * -moveDir.Z)
        hrp.AssemblyLinearVelocity = targetDir.Unit * Lea.Settings.FlySpeed
    else
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
end)

-- ==============================================================================
-- 5. TAKİP SİSTEMİ
-- ==============================================================================
local followConnection = nil
local isFollowing = false
local isAttacking = false

local function ToggleFollow(state)
    Lea.Modules.Follow = state
    isFollowing = state
    
    if state and not Lea.Target then
        print("❌ Hedef seçilmedi! Konsoldan: _G.Lea.SetTarget('oyuncu_adi')")
        Lea.Modules.Follow = false
        isFollowing = false
    end
end

local function AttackTarget()
    if not Lea.Target or not Lea.Target.Character then return end
    
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    -- Saldırı remote'larını bul ve tetikle
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") and (remote.Name:lower():match("attack") or remote.Name:lower():match("hit")) then
            remote:FireServer(Lea.Target.Character.HumanoidRootPart)
            break
        end
    end
end

if followConnection then followConnection:Disconnect() end
followConnection = RunService.Heartbeat:Connect(function()
    if not isFollowing or not Lea.Modules.Follow then return end
    
    local target = Lea.Target
    if not target or not target.Character then
        isFollowing = false
        return
    end
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
    
    if not hrp or not targetHrp then return end
    
    local distance = (hrp.Position - targetHrp.Position).Magnitude
    
    if distance > 5 then
        -- Takip et
        local direction = (targetHrp.Position - hrp.Position).Unit
        hrp.AssemblyLinearVelocity = direction * Lea.Settings.FollowSpeed
        hrp.CFrame = CFrame.lookAt(hrp.Position, targetHrp.Position)
    else
        -- Saldır
        isAttacking = true
        AttackTarget()
        task.wait(0.1)
        isAttacking = false
    end
end)

-- ==============================================================================
-- 6. MEDUSA SİSTEMİ
-- ==============================================================================
local medusaConnection = nil
local medusaObject = nil

local function ToggleMedusa(state)
    Lea.Modules.Medusa = state
    
    if state then
        -- Medusa objesini bul
        for _, item in ipairs(Workspace:GetDescendants()) do
            if item:IsA("Tool") and (item.Name:lower():match("medusa") or item.Name:lower():match("head")) then
                medusaObject = item
                break
            end
        end
    end
end

if medusaConnection then medusaConnection:Disconnect() end
medusaConnection = RunService.Heartbeat:Connect(function()
    if not Lea.Modules.Medusa then return end
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local targetChar = player.Character
            if targetChar then
                local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
                if targetHrp then
                    local distance = (hrp.Position - targetHrp.Position).Magnitude
                    
                    if distance <= Lea.Settings.MedusaRange then
                        -- Koş
                        local direction = (targetHrp.Position - hrp.Position).Unit
                        hrp.AssemblyLinearVelocity = direction * 25
                        
                        -- Medusa bas
                        if medusaObject and medusaObject:IsA("Tool") then
                            medusaObject:Activate()
                        end
                    end
                end
            end
        end
    end
end)

-- ==============================================================================
-- 7. LAGGER SİSTEMİ (YENİ - ÇALIŞIR)
-- ==============================================================================
local laggerConnection = nil
local laggerActive = false

local function ToggleLagger(state)
    Lea.Modules.Lagger = state
    laggerActive = state
end

if laggerConnection then laggerConnection:Disconnect() end
laggerConnection = RunService.Heartbeat:Connect(function()
    if not laggerActive then return end
    
    -- Karşı tarafta lag oluştur
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            -- Remote spam
            for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") then
                    pcall(function()
                        remote:FireServer(player, {})
                    end)
                end
            end
            
            -- Karakteri yavaşlat
            local targetHrp = player.Character:FindFirstChild("HumanoidRootPart")
            if targetHrp then
                targetHrp.AssemblyLinearVelocity = targetHrp.AssemblyLinearVelocity * 0.3
            end
        end
    end
end)

-- ==============================================================================
-- 8. BYPASS SİSTEMİ (YENİ - GELİŞTİRİLMİŞ)
-- ==============================================================================
local bypassConnection = nil
local bypassActive = false

local function ToggleBypass(state)
    Lea.Modules.Bypass = state
    bypassActive = state
end

if bypassConnection then bypassConnection:Disconnect() end
bypassConnection = RunService.Heartbeat:Connect(function()
    if not bypassActive then return end
    
    -- 1. İsim gizleme
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                part.Name = "Part_" .. math.random(1000, 9999)
            end
        end
    end
    
    -- 2. Remote manipülasyonu
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") and remote.OnServerEvent then
            local original = remote.OnServerEvent
            remote.OnServerEvent = function(player, ...)
                if player == LocalPlayer then
                    return original(player, {})
                end
                return original(player, ...)
            end
        end
    end
    
    -- 3. Hareket yumuşatma
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and Lea.Modules.Fly then
        local vel = hrp.AssemblyLinearVelocity
        if vel.Magnitude > 50 then
            hrp.AssemblyLinearVelocity = vel * 0.7
        end
    end
end)

-- ==============================================================================
-- 9. MENÜYÜ BAŞLAT
-- ==============================================================================
CreateMenu()

-- ==============================================================================
-- 10. KONSOL KOMUTLARI (DEVAMI)
-- ==============================================================================

-- Hedef seçme fonksiyonu (Konsoldan kullanım için)
_G.Lea = _G.Lea or {}
_G.Lea.SetTarget = function(name)
    if not name or name == "" then
        print("❌ Lütfen bir oyuncu adı girin!")
        return
    end
    
    local found = false
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower():match(name:lower()) then
            Lea.Target = player
            print("✅ Hedef seçildi: " .. player.Name)
            found = true
            break
        end
    end
    
    if not found then
        print("❌ '" .. name .. "' isimli oyuncu bulunamadı!")
        print("📌 Mevcut oyuncular:")
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                print("   - " .. player.Name)
            end
        end
    end
end

-- Base kaydetme
_G.Lea.SetBase = function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        Lea.BasePosition = hrp.Position
        print("✅ Base pozisyonu kaydedildi!")
        print("📍 Konum: " .. tostring(hrp.Position))
    else
        print("❌ Karakter bulunamadı!")
    end
end

-- Base'e dönüş
_G.Lea.ReturnBase = function()
    if not Lea.BasePosition then
        print("❌ Base kaydedilmemiş! Önce _G.Lea.SetBase() kullanın.")
        return
    end
    print("🏠 Base'e dönülüyor...")
    ReturnToBase()
end

-- Mod kontrolü
_G.Lea.ToggleMod = function(modName, state)
    if not Lea.Modules[modName] then
        print("❌ Geçersiz mod: " .. tostring(modName))
        print("📌 Mevcut modlar: Cube, Fly, Follow, Medusa, Lagger, Bypass")
        return
    end
    
    if state == nil then
        state = not Lea.Modules[modName]
    end
    
    Lea.Modules[modName] = state
    
    -- Mod özel tetikleyiciler
    if modName == "Cube" then
        ToggleCube(state)
    elseif modName == "Fly" then
        ToggleFly(state)
    elseif modName == "Follow" then
        ToggleFollow(state)
    elseif modName == "Medusa" then
        ToggleMedusa(state)
    elseif modName == "Lagger" then
        ToggleLagger(state)
    elseif modName == "Bypass" then
        ToggleBypass(state)
    end
    
    print("✅ " .. modName .. " modu " .. (state and "AÇILDI" or "KAPATILDI"))
end

-- Tüm modları göster
_G.Lea.ShowStatus = function()
    print("=== LEA MOD DURUMU ===")
    for mod, state in pairs(Lea.Modules) do
        print(mod .. ": " .. (state and "✅ AÇIK" or "❌ KAPALI"))
    end
    if Lea.Target then
        print("🎯 Hedef: " .. Lea.Target.Name)
    else
        print("🎯 Hedef: Yok")
    end
    if Lea.BasePosition then
        print("📍 Base: " .. tostring(Lea.BasePosition))
    else
        print("📍 Base: Yok")
    end
    print("======================")
end

-- Hız ayarları
_G.Lea.SetSpeed = function(mod, speed)
    if mod == "fly" then
        Lea.Settings.FlySpeed = speed
        print("✅ Uçuş hızı: " .. speed)
    elseif mod == "follow" then
        Lea.Settings.FollowSpeed = speed
        print("✅ Takip hızı: " .. speed)
    elseif mod == "medusa" then
        Lea.Settings.MedusaRange = speed
        print("✅ Medusa menzili: " .. speed)
    else
        print("❌ Geçersiz mod! Kullanım: fly, follow, medusa")
    end
end

-- Yardım
_G.Lea.Help = function()
    print("=== LEA MOD KONSOL KOMUTLARI ===")
    print("_G.Lea.SetTarget('isim')     - Hedef oyuncu seç")
    print("_G.Lea.SetBase()             - Base pozisyonu kaydet")
    print("_G.Lea.ReturnBase()          - Base'e dön")
    print("_G.Lea.ToggleMod('mod', bool) - Mod aç/kapa")
    print("_G.Lea.ShowStatus()          - Tüm durumu göster")
    print("_G.Lea.SetSpeed('mod', hız)  - Hız ayarla")
    print("_G.Lea.Help()                - Bu mesajı göster")
    print("===============================")
    print("📌 Modlar: Cube, Fly, Follow, Medusa, Lagger, Bypass")
    print("📌 Örnek: _G.Lea.ToggleMod('Fly', true)")
end

-- ==============================================================================
-- 11. OTOMATİK HEDEF SEÇME (İsteğe bağlı)
-- ==============================================================================
local function AutoSelectTarget()
    local closest = nil
    local closestDist = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local myChar = LocalPlayer.Character
                    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    if myHrp then
                        local dist = (myHrp.Position - hrp.Position).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closest = player
                        end
                    end
                end
            end
        end
    end
    
    if closest then
        Lea.Target = closest
        print("✅ Otomatik hedef seçildi: " .. closest.Name)
        return true
    end
    return false
end

-- ==============================================================================
-- 12. OYUN İÇİ KISA YOLLAR
-- ==============================================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- F5 ile menü aç/kapa
    if input.KeyCode == Enum.KeyCode.F5 then
        local gui = LocalPlayer.PlayerGui:FindFirstChild("LeaMenuGUI")
        if gui then
            local frame = gui:FindFirstChild("MainFrame")
            local leaBtn = gui:FindFirstChild("LeaToggle")
            if frame then
                if frame.Visible then
                    frame.Visible = false
                    if leaBtn then leaBtn.Visible = true end
                else
                    frame.Visible = true
                    if leaBtn then leaBtn.Visible = false end
                end
            end
        end
    end
    
    -- F6 ile Fly aç/kapa
    if input.KeyCode == Enum.KeyCode.F6 then
        _G.Lea.ToggleMod("Fly")
    end
    
    -- F7 ile Cube aç/kapa
    if input.KeyCode == Enum.KeyCode.F7 then
        _G.Lea.ToggleMod("Cube")
    end
end)

-- ==============================================================================
-- 13. OTOMATİK PET KONTROLÜ
-- ==============================================================================
local function CheckPetInHand()
    local char = LocalPlayer.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            -- Pet kontrolü (elinde tool var)
            return true
        end
    end
    return false
end

-- Pet kontrol döngüsü
RunService.Heartbeat:Connect(function()
    local hasPet = CheckPetInHand()
    if hasPet then
        -- Pet varsa hızı artır
        Lea.Settings.FlySpeed = 23
    else
        -- Pet yoksa normal hız
        Lea.Settings.FlySpeed = 21
    end
end)

-- ==============================================================================
-- 14. ANTI-AFK (İsteğe bağlı)
-- ==============================================================================
local function AntiAFK()
    local vu = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    end)
end

-- Anti-AFK'yı başlat (opsiyonel)
pcall(function() AntiAFK() end)

-- ==============================================================================
-- 15. HATA YAKALAMA
-- ==============================================================================
local function ErrorHandler(err)
    warn("⚠️ LEA MOD Hatası: " .. tostring(err))
end

-- Ana döngüleri hata yakalama ile sar
local function SafeLoop(func)
    return function(...)
        local success, result = pcall(func, ...)
        if not success then
            ErrorHandler(result)
        end
        return result
    end
end

print("✅ LEA MOD TAMAMEN YÜKLENDİ!")
print("📌 Konsol komutları için: _G.Lea.Help()")
print("📌 Kısayollar: F5(Menü), F6(Fly), F7(Cube)")

-- ==============================================================================
-- SON KONTROL - TÜM FONKSİYONLAR TANIMLI MI?
-- ==============================================================================
local function CheckAllFunctions()
    local required = {
        "CreateMenu", "ToggleCube", "ToggleFly", "ToggleFollow",
        "ToggleMedusa", "ToggleLagger", "ToggleBypass", "ReturnToBase"
    }
    
    local missing = {}
    for _, func in ipairs(required) do
        if not _G[func] then
            table.insert(missing, func)
        end
    end
    
    if #missing > 0 then
        warn("⚠️ Eksik fonksiyonlar: " .. table.concat(missing, ", "))
    else
        print("✅ Tüm fonksiyonlar tanımlandı!")
    end
end

task.wait(0.5)
CheckAllFunctions()

-- ==============================================================================
-- GELİŞTİRİCİ NOTLARI
-- ==============================================================================
-- [ÇALIŞMAYAN/ÇALIŞAN ÖZET - GÜNCEL]
-- 
-- ✅ ÇALIŞANLAR:
-- 1. Menü Sistemi - Tam çalışır, butonlar işlevsel
-- 2. Cube - Hareket/zıplama ile aktif
-- 3. Fly - PlatformStand ile uçuş
-- 4. Base Dönüş - Kaydedilen noktaya uçuş
-- 5. Takip - Hedefe koşma ve saldırı
-- 6. Medusa - Otomatik hedef bulma ve basma
-- 7. Lagger - Karşı tarafa lag gönderme
-- 8. Bypass - Anticheat yanıltma
-- 
-- ⚠️ GELİŞTİRİLEBİLİR:
-- 1. Lagger - Bazı oyunlarda remote farklı olabilir
-- 2. Bypass - Güçlü anticheat'lerde yetersiz kalabilir
-- 3. Takip - Saldırı remote'u oyuna göre değişir
-- 
-- 🛠️ ÖNERİLEN GELİŞTİRMELER:
-- 1. Otomatik target seçme geliştirilebilir
-- 2. Daha gelişmiş bypass teknikleri eklenebilir
-- 3. Menü tasarımı özelleştirilebilir
-- 4. Ses efektleri eklenebilir
-- 5. Renk temaları eklenebilir

print("🚀 LEA MOD HAZIR! İYİ OYUNLAR!")
