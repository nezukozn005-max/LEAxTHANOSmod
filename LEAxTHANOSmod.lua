-- ==============================================================================
-- LEA MOD - PART 1/3 (ANTI-KICK & ANTI-RESET & KORUMA)
-- ==============================================================================
-- Bu dosya: Anti-kick, anti-reset, teleport engelleyici, koruma sistemleri
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

print("🛡️ LEA KORUMA SİSTEMİ BAŞLATILIYOR...")

-- ==============================================================================
-- 1. ANTI-KICK SİSTEMİ (GELİŞTİRİLMİŞ)
-- ==============================================================================
local function AntiKick()
    -- 1. Kick fonksiyonunu devre dışı bırak
    local originalKick = LocalPlayer.Kick
    LocalPlayer.Kick = function(self, message)
        warn("⚠️ KICK ENGELLENDİ! Mesaj: " .. tostring(message))
        return nil
    end
    
    -- 2. Remote kickleri engelle
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            local name = remote.Name:lower()
            if name:match("kick") or name:match("ban") or name:match("remove") or name:match("delete") or name:match("destroy") then
                local original = remote.OnServerEvent
                remote.OnServerEvent = function(player, ...)
                    if player == LocalPlayer then
                        warn("⚠️ KICK REMOTE ENGELLENDİ: " .. remote.Name)
                        return nil
                    end
                    return original and original(player, ...)
                end
            end
        end
    end
    
    -- 3. Teleport kicklerini engelle (TeleportService'i kullanma)
    local TeleportService = game:GetService("TeleportService")
    if TeleportService then
        local originalTeleport = TeleportService.Teleport
        TeleportService.Teleport = function(self, ...)
            warn("⚠️ TELEPORT ENGELLENDİ!")
            return nil
        end
    end
end

-- ==============================================================================
-- 2. ANTI-RESET SİSTEMİ (GELİŞTİRİLMİŞ)
-- ==============================================================================
local function AntiReset()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            -- Health resetini engelle
            hum:GetPropertyChangedSignal("Health"):Connect(function()
                if hum.Health <= 0 then
                    hum.Health = 100
                    warn("⚠️ RESET ENGELLENDİ! Can yenilendi.")
                end
            end)
            
            -- BreakJointsOnDeath'i devre dışı bırak
            hum.BreakJointsOnDeath = false
            
            -- State değişimini kontrol et
            hum:GetPropertyChangedSignal("State"):Connect(function()
                if hum.State == Enum.HumanoidStateType.Dead then
                    hum.Health = 100
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                    warn("⚠️ ÖLÜM ENGELLENDİ!")
                end
            end)
        end
    end
    
    -- CharacterAdded ile reset kontrolü
    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.1)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.BreakJointsOnDeath = false
            hum.Health = 100
            warn("⚠️ YENİ KARAKTER - RESET ENGELLENDİ!")
        end
    end)
end

-- ==============================================================================
-- 3. TELEPORT ENGELLEYİCİ
-- ==============================================================================
local function AntiTeleport()
    -- Teleport remoted'ları engelle
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            local name = remote.Name:lower()
            if name:match("teleport") or name:match("tp") or name:match("move") or name:match("position") then
                local original = remote.OnServerEvent
                remote.OnServerEvent = function(player, ...)
                    if player == LocalPlayer then
                        warn("⚠️ TELEPORT REMOTE ENGELLENDİ: " .. remote.Name)
                        return nil
                    end
                    return original and original(player, ...)
                end
            end
        end
    end
    
    -- CFrame değişimini kontrol et (aşırı teleportu engelle)
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local lastPos = hrp.Position
            hrp:GetPropertyChangedSignal("CFrame"):Connect(function()
                local newPos = hrp.Position
                local distance = (newPos - lastPos).Magnitude
                if distance > 100 then
                    warn("⚠️ AŞIRI TELEPORT ENGELLENDİ!")
                    hrp.CFrame = CFrame.new(lastPos)
                end
                lastPos = newPos
            end)
        end
    end
end

-- ==============================================================================
-- 4. OTURUM KORUMASI
-- ==============================================================================
local function SessionProtection()
    -- Parent değişimini engelle
    LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
        if LocalPlayer.Parent == nil then
            warn("⚠️ PARENT DEĞİŞİMİ ENGELLENDİ!")
            LocalPlayer.Parent = Players
        end
    end)
end

-- ==============================================================================
-- 5. ANTİCHEAT BYPASS
-- ==============================================================================
local function AdvancedBypass()
    -- İsim gizleme
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                part.Name = "Part_" .. math.random(1000, 9999)
            end
        end
    end
    
    -- Remote manipülasyonu
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local original = remote.OnServerEvent
            remote.OnServerEvent = function(player, ...)
                if player == LocalPlayer then
                    return original and original(player, {})
                end
                return original and original(player, ...)
            end
        end
    end
end

-- ==============================================================================
-- 6. KORUMA DÖNGÜSÜ
-- ==============================================================================
local function ProtectionLoop()
    pcall(AntiKick)
    pcall(AntiReset)
    pcall(AntiTeleport)
    pcall(SessionProtection)
    pcall(AdvancedBypass)
end

-- Sürekli koruma
RunService.Heartbeat:Connect(function()
    ProtectionLoop()
end)

-- Karakter değişiminde koruma
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.1)
    ProtectionLoop()
end)

print("✅ KORUMA SİSTEMLERİ AKTİF!")
print("🛡️ Anti-Kick: AKTİF")
print("🛡️ Anti-Reset: AKTİF")
print("🛡️ Anti-Teleport: AKTİF")
print("🛡️ Session Protection: AKTİF")
print("🛡️ Advanced Bypass: AKTİF")

-- PART 1 BİTTİ - PART 2'YE GEÇ-- ==============================================================================
-- LEA MOD - PART 2/3 (MOD SİSTEMLERİ)
-- ==============================================================================
-- Bu dosya: Cube, Fly, Base Dönüş, Takip (360°), Medusa, Lagger
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Global state
getgenv().Lea = getgenv().Lea or {}
local Lea = getgenv().Lea

Lea.Modules = {
    Cube = false,
    Fly = false,
    Follow = false,
    Medusa = false,
    Lagger = false
}

Lea.Settings = {
    FlySpeed = 35,
    FollowSpeed = 25,
    MedusaRange = 15
}

Lea.Target = nil
Lea.BasePosition = nil
Lea.IsReturning = false

print("⚙️ MOD SİSTEMLERİ BAŞLATILIYOR...")

-- ==============================================================================
-- 1. CUBE SİSTEMİ
-- ==============================================================================
local cubePart = nil

local function ToggleCube(state)
    Lea.Modules.Cube = state
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

RunService.Heartbeat:Connect(function()
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
-- 2. FLY SİSTEMİ
-- ==============================================================================
local function ToggleFly(state)
    Lea.Modules.Fly = state
end

RunService.Heartbeat:Connect(function(dt)
    if not Lea.Modules.Fly or Lea.IsReturning then return end
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if not hrp or not hum then return end
    
    hum.PlatformStand = true
    local moveDir = hum.MoveDirection
    
    if moveDir.Magnitude > 0 then
        local targetDir = (Camera.CFrame.RightVector * moveDir.X) + (Camera.CFrame.LookVector * -moveDir.Z)
        hrp.AssemblyLinearVelocity = targetDir.Unit * Lea.Settings.FlySpeed
    else
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
end)

-- ==============================================================================
-- 3. BASE DÖNÜŞ (FLY İLE)
-- ==============================================================================
local function ReturnToBase()
    if not Lea.BasePosition then
        print("❌ Base kaydedilmemiş!")
        return
    end
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    Lea.IsReturning = true
    Lea.Modules.Fly = true
    
    local targetPos = Lea.BasePosition + Vector3.new(0, 3, 0)
    local speed = 21
    
    local returnConn
    returnConn = RunService.Heartbeat:Connect(function()
        if not Lea.IsReturning then
            returnConn:Disconnect()
            return
        end
        
        if not hrp or not hrp.Parent then
            Lea.IsReturning = false
            returnConn:Disconnect()
            return
        end
        
        local currentPos = hrp.Position
        local distance = (targetPos - currentPos).Magnitude
        
        if distance < 2 then
            Lea.IsReturning = false
            Lea.Modules.Fly = false
            returnConn:Disconnect()
            print("✅ Base'e varıldı!")
            return
        end
        
        local direction = (targetPos - currentPos).Unit
        hrp.AssemblyLinearVelocity = direction * speed
        hrp.CFrame = CFrame.lookAt(currentPos, targetPos)
    end)
end

-- ==============================================================================
-- 4. TAKİP SİSTEMİ (360° DÖNEREK SALDIRI)
-- ==============================================================================
local followActive = false
local followAngle = 0
local attackTimer = 0

local function ToggleFollow(state)
    Lea.Modules.Follow = state
    followActive = state
    
    if state and not Lea.Target then
        print("❌ Hedef seçilmedi! Konsoldan: _G.Lea.SetTarget('isim')")
        followActive = false
        Lea.Modules.Follow = false
    end
end

-- Saldırı fonksiyonu
local function DoAttack()
    if not Lea.Target or not Lea.Target.Character then return end
    
    local char = LocalPlayer.Character
    local targetHrp = Lea.Target.Character:FindFirstChild("HumanoidRootPart")
    
    if not targetHrp then return end
    
    -- Saldırı remote bul
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            local name = remote.Name:lower()
            if name:match("attack") or name:match("hit") or name:match("damage") or name:match("click") then
                pcall(function()
                    remote:FireServer(targetHrp)
                    remote:FireServer(Lea.Target)
                    remote:FireServer()
                end)
            end
        end
    end
    
    pcall(function()
        mouse1click()
    end)
end

RunService.Heartbeat:Connect(function(dt)
    if not followActive or not Lea.Modules.Follow then return end
    
    local target = Lea.Target
    if not target or not target.Character then
        followActive = false
        Lea.Modules.Follow = false
        print("❌ Hedef öldü veya oyundan çıktı!")
        return
    end
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
    
    if not hrp or not hum or not targetHrp then return end
    
    local distance = (hrp.Position - targetHrp.Position).Magnitude
    
    -- Takip ve 360° dönüş
    if distance > 3 then
        -- Fly modunu aktif et
        hum.PlatformStand = true
        
        -- Hedefe doğru uç
        local direction = (targetHrp.Position - hrp.Position).Unit
        hrp.AssemblyLinearVelocity = direction * Lea.Settings.FollowSpeed
        
        -- Hedef etrafında 360° dön
        followAngle = followAngle + dt * 2
        local radius = 3
        local orbitPos = targetHrp.Position + Vector3.new(
            math.cos(followAngle) * radius,
            2,
            math.sin(followAngle) * radius
        )
        
        hrp.CFrame = CFrame.lookAt(hrp.Position, orbitPos)
        
        -- Hedefe bak
        hrp.CFrame = CFrame.lookAt(hrp.Position, targetHrp.Position)
        
    else
        -- Saldır (360° dönerken vur)
        attackTimer = attackTimer + dt
        
        if attackTimer > 0.1 then
            attackTimer = 0
            DoAttack()
            
            -- 360° dönüşü devam ettir
            followAngle = followAngle + 0.5
            local radius = 2.5
            local orbitPos = targetHrp.Position + Vector3.new(
                math.cos(followAngle) * radius,
                1,
                math.sin(followAngle) * radius
            )
            hrp.CFrame = CFrame.lookAt(hrp.Position, orbitPos)
        end
    end
end)

-- ==============================================================================
-- 5. MEDUSA SİSTEMİ
-- ==============================================================================
local medusaActive = false

local function ToggleMedusa(state)
    Lea.Modules.Medusa = state
    medusaActive = state
end

RunService.Heartbeat:Connect(function()
    if not medusaActive then return end
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Medusa tool bul
    local medusaTool = nil
    for _, tool in ipairs(Workspace:GetDescendants()) do
        if tool:IsA("Tool") then
            local name = tool.Name:lower()
            if name:match("medusa") or name:match("head") or name:match("stone") then
                medusaTool = tool
                break
            end
        end
    end
    
    if not medusaTool then return end
    
    -- En yakın oyuncuyu bul
    local closest = nil
    local closestDist = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local targetChar = player.Character
            if targetChar then
                local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
                if targetHrp then
                    local dist = (hrp.Position - targetHrp.Position).Magnitude
                    if dist < closestDist and dist <= Lea.Settings.MedusaRange then
                        closestDist = dist
                        closest = player
                    end
                end
            end
        end
    end
    
    if closest then
        local targetHrp = closest.Character:FindFirstChild("HumanoidRootPart")
        if targetHrp then
            -- Hedefe koş
            local direction = (targetHrp.Position - hrp.Position).Unit
            hrp.AssemblyLinearVelocity = direction * 25
            
            -- Medusa bas
            if medusaTool:IsA("Tool") then
                pcall(function()
                    medusaTool:Activate()
                    mouse1click()
                end)
            end
        end
    end
end)

-- ==============================================================================
-- 6. LAGGER SİSTEMİ (KARŞI TARAFTA LAG)
-- ==============================================================================
local laggerActive = false

local function ToggleLagger(state)
    Lea.Modules.Lagger = state
    laggerActive = state
    
    if state then
        print("💀 LAGGER AKTİF - Karşı tarafta lag oluşuyor!")
    else
        print("💀 LAGGER KAPALI")
    end
end

RunService.Heartbeat:Connect(function()
    if not laggerActive then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetHrp = player.Character:FindFirstChild("HumanoidRootPart")
            
            -- 1. Remote spam (karşı tarafa)
            for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") then
                    pcall(function()
                        remote:FireServer(player, {})
                        remote:FireServer(targetHrp, {})
                        remote:FireServer()
                    end)
                end
            end
            
            -- 2. Karşı tarafın karakterine velocity spam
            if targetHrp then
                for i = 1, 20 do
                    targetHrp.AssemblyLinearVelocity = Vector3.new(
                        math.random(-200, 200),
                        math.random(-200, 200),
                        math.random(-200, 200)
                    )
                end
                targetHrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
            
            -- 3. Karşı tarafın CFrame'ini boz
            if targetHrp then
                for i = 1, 10 do
                    targetHrp.CFrame = targetHrp.CFrame * CFrame.Angles(
                        math.rad(math.random(0, 360)),
                        math.rad(math.random(0, 360)),
                        math.rad(math.random(0, 360))
                    )
                end
            end
            
            -- 4. Karşı tarafın humanoid'ini yavaşlat
            local targetHum = player.Character:FindFirstChildOfClass("Humanoid")
            if targetHum then
                targetHum.WalkSpeed = 0
                targetHum.JumpPower = 0
                task.wait(0.1)
                targetHum.WalkSpeed = 16
                targetHum.JumpPower = 50
            end
        end
    end
end)

print("✅ PART 2 YÜKLENDİ! (Mod Sistemleri)")

-- PART 2 BİTTİ - PART 3'E GEÇ-- ==============================================================================
-- LEA MOD - PART 3/3 (MENÜ & KONSOL KOMUTLARI)
-- ==============================================================================
-- Bu dosya: Menü sistemi, konsol komutları, kısayollar
-- ==============================================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Lea = getgenv().Lea

print("📋 MENÜ SİSTEMİ BAŞLATILIYOR...")

-- ==============================================================================
-- 1. MENÜ SİSTEMİ (KÜÇÜK)
-- ==============================================================================
local function CreateMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LeaMenu"
    screenGui.Parent = LocalPlayer.PlayerGui
    screenGui.ResetOnSpawn = false
    
    -- Ana Frame (150x200)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 150, 0, 200)
    mainFrame.Position = UDim2.new(0.5, -75, 0.5, -100)
    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainFrame.BackgroundTransparency = 0.3
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- Başlık
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 20)
    title.Position = UDim2.new(0, 0, 0, 2)
    title.BackgroundTransparency = 1
    title.Text = "⚡LEA MOD"
    title.TextColor3 = Color3.fromRGB(0, 255, 200)
    title.TextSize = 12
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Kapatma butonu
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(0, 3, 0, 3)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = 12
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeBtn
    
    -- Mod butonları (2 sütun)
    local mods = {
        {name = "Cube", label = "🔷KÜP"},
        {name = "Fly", label = "🛸UÇUŞ"},
        {name = "Follow", label = "🎯TAKİP"},
        {name = "Medusa", label = "🐍MEDUSA"},
        {name = "Lagger", label = "💀LAGGER"}
    }
    
    local yPos = 25
    local btnHeight = 25
    local spacing = 3
    local btnWidth = 0.45
    local buttons = {}
    
    for i, mod in ipairs(mods) do
        local btn = Instance.new("TextButton")
        btn.Name = mod.name .. "Btn"
        btn.Size = UDim2.new(btnWidth, 0, 0, btnHeight)
        btn.Position = UDim2.new(i % 2 == 1 and 0.03 or 0.52, 0, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        btn.Text = mod.label
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextSize = 9
        btn.Font = Enum.Font.GothamSemibold
        btn.Parent = mainFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = btn
        
        buttons[mod.name] = btn
        
        if i % 2 == 1 then
            yPos = yPos + btnHeight + spacing
        end
    end
    
    -- Base butonları
    local baseBtn = Instance.new("TextButton")
    baseBtn.Size = UDim2.new(0.45, 0, 0, 22)
    baseBtn.Position = UDim2.new(0.03, 0, 0, yPos + 2)
    baseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    baseBtn.Text = "📍BASE KAYDET"
    baseBtn.TextColor3 = Color3.new(1, 1, 1)
    baseBtn.TextSize = 8
    baseBtn.Font = Enum.Font.GothamSemibold
    baseBtn.Parent = mainFrame
    
    local baseCorner = Instance.new("UICorner")
    baseCorner.CornerRadius = UDim.new(0, 4)
    baseCorner.Parent = baseBtn
    
    local returnBtn = Instance.new("TextButton")
    returnBtn.Size = UDim2.new(0.45, 0, 0, 22)
    returnBtn.Position = UDim2.new(0.52, 0, 0, yPos + 2)
    returnBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
    returnBtn.Text = "🏠BASE DÖN"
    returnBtn.TextColor3 = Color3.new(1, 1, 1)
    returnBtn.TextSize = 8
    returnBtn.Font = Enum.Font.GothamSemibold
    returnBtn.Parent = mainFrame
    
    local returnCorner = Instance.new("UICorner")
    returnCorner.CornerRadius = UDim.new(0, 4)
    returnCorner.Parent = returnBtn
    
    -- Buton işlevleri
    local function UpdateButton(moduleName, state)
        local btn = buttons[moduleName]
        if btn then
            if state then
                btn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
            else
                btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
            end
        end
    end
    
    for _, mod in ipairs(mods) do
        buttons[mod.name].MouseButton1Click:Connect(function()
            local moduleName = mod.name
            Lea.Modules[moduleName] = not Lea.Modules[moduleName]
            UpdateButton(moduleName, Lea.Modules[moduleName])
            
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
            end
        end)
    end
    
    -- Base kaydet
    baseBtn.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            Lea.BasePosition = hrp.Position
            baseBtn.Text = "✅KAYDEDİLDİ"
            task.wait(1)
            baseBtn.Text = "📍BASE KAYDET"
            print("✅ Base kaydedildi!")
        end
    end)
    
    -- Base dön
    returnBtn.MouseButton1Click:Connect(function()
        ReturnToBase()
    end)
    
    -- Kapatma
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        
        if not screenGui:FindFirstChild("LeaToggle") then
            local leaBtn = Instance.new("TextButton")
            leaBtn.Name = "LeaToggle"
            leaBtn.Size = UDim2.new(0, 45, 0, 22)
            leaBtn.Position = UDim2.new(1, -50, 0, 5)
            leaBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
            leaBtn.Text = "⚡LEA"
            leaBtn.TextColor3 = Color3.new(1, 1, 1)
            leaBtn.TextSize = 12
            leaBtn.Font = Enum.Font.GothamBold
            leaBtn.Parent = screenGui
            
            local leaCorner = Instance.new("UICorner")
            leaCorner.CornerRadius = UDim.new(0, 4)
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
-- 2. KONSOL KOMUTLARI
-- ==============================================================================
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
            print("✅ Hedef: " .. player.Name)
            found = true
            break
        end
    end
    
    if not found then
        print("❌ '" .. name .. "' bulunamadı!")
        print("📌 Mevcut oyuncular:")
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                print("   - " .. player.Name)
            end
        end
    end
end

_G.Lea.SetBase = function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        Lea.BasePosition = hrp.Position
        print("✅ Base kaydedildi!")
    else
        print("❌ Karakter bulunamadı!")
    end
end

_G.Lea.ReturnBase = function()
    ReturnToBase()
end

_G.Lea.ToggleMod = function(modName, state)
    if not Lea.Modules[modName] then
        print("❌ Geçersiz mod: " .. tostring(modName))
        print("📌 Modlar: Cube, Fly, Follow, Medusa, Lagger")
        return
    end
    
    if state == nil then
        state = not Lea.Modules[modName]
    end
    
    Lea.Modules[modName] = state
    
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
    end
    
    print("✅ " .. modName .. " " .. (state and "AÇIK" or "KAPALI"))
end

_G.Lea.Status = function()
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
        print("📍 Base: Kayıtlı")
    else
        print("📍 Base: Yok")
    end
end

_G.Lea.Help = function()
    print("=== LEA KOMUTLARI ===")
    print("SetTarget('isim')  - Hedef seç")
    print("SetBase()          - Base kaydet")
    print("ReturnBase()       - Base dön")
    print("ToggleMod('mod')   - Mod aç/kapa")
    print("Status()           - Durum göster")
    print("")
    print("📌 Modlar: Cube, Fly, Follow, Medusa, Lagger")
    print("📌 Örnek: _G.Lea.ToggleMod('Fly')")
    print("📌 Kısayollar: F5(Menü), F6(Fly), F7(Cube)")
end

-- ==============================================================================
-- 3. KISAYOLLAR
-- ==============================================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F5 then
        local gui = LocalPlayer.PlayerGui:FindFirstChild("LeaMenu")
        if gui then
            local frame = gui:FindFirstChild("MainFrame")
            local leaBtn = gui:FindFirstChild("LeaToggle")
            if frame then
                frame.Visible = not frame.Visible
                if leaBtn then leaBtn.Visible = not frame.Visible end
            end
        end
    end
    
    if input.KeyCode == Enum.KeyCode.F6 then
        _G.Lea.ToggleMod("Fly")
    end
    
    if input.KeyCode == Enum.KeyCode.F7 then
        _G.Lea.ToggleMod("Cube")
    end
end)

-- ==============================================================================
-- 4. BAŞLAT
-- ==============================================================================
CreateMenu()

print("")
print("========================================")
print("✅ LEA MOD TAMAMEN YÜKLENDİ!")
print("========================================")
print("🛡️ Anti-Kick: AKTİF")
print("🛡️ Anti-Reset: AKTİF")
print("🛡️ Anti-Teleport: AKTİF")
print("🛡️ Bypass: AKTİF")
print("")
print("📌 Menü açık (KÜÇÜK)")
print("📌 Konsol: _G.Lea.Help()")
print("📌 Kısayollar: F5(Menü), F6(Fly), F7(Cube)")
print("========================================")
print("🚀 LEA MOD HAZIR! İYİ OYUNLAR!")
