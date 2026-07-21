-- ==============================================================================
-- LEA MOD - PART 1/2 (ANA SİSTEM VE MODLAR)
-- ==============================================================================
-- Bu dosya: Ana sistem, bypass, cube, fly, base dönüş, takip, medusa, lagger
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

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
    Lagger = false
}

Lea.Settings = {
    FlySpeed = 35,
    FollowSpeed = 25,
    MedusaRange = 15,
    LaggerIntensity = 50
}

Lea.Target = nil
Lea.BasePosition = nil
Lea.IsReturning = false

-- ==============================================================================
-- 2. BYPASS - HER ZAMAN AKTİF
-- ==============================================================================
local function BypassSystem()
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
    
    -- Velocity smoothing
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and Lea.Modules.Fly then
        local vel = hrp.AssemblyLinearVelocity
        if vel.Magnitude > 60 then
            hrp.AssemblyLinearVelocity = vel * 0.6
        end
    end
end

-- Bypass'ı sürekli çalıştır
RunService.Heartbeat:Connect(function()
    pcall(BypassSystem)
end)

-- ==============================================================================
-- 3. CUBE SİSTEMİ
-- ==============================================================================
local cubePart = nil
local cubeConnection = nil

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

local function ToggleFly(state)
    Lea.Modules.Fly = state
end

if flyConnection then flyConnection:Disconnect() end
flyConnection = RunService.Heartbeat:Connect(function(dt)
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
-- 5. BASE DÖNÜŞ
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
    local targetPos = Lea.BasePosition + Vector3.new(0, 3, 0)
    local speed = 21
    
    -- Pet kontrolü
    local petInHand = char:FindFirstChildOfClass("Tool") ~= nil
    if petInHand then speed = 23 end
    
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
-- 6. TAKİP SİSTEMİ
-- ==============================================================================
local followConnection = nil
local followActive = false
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
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local targetHrp = Lea.Target.Character:FindFirstChild("HumanoidRootPart")
    
    if not hrp or not targetHrp then return end
    
    -- Saldırı remote bul
    local attackRemotes = {}
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            local name = remote.Name:lower()
            if name:match("attack") or name:match("hit") or name:match("damage") or name:match("click") then
                table.insert(attackRemotes, remote)
            end
        end
    end
    
    -- Saldırıyı tetikle
    for _, remote in ipairs(attackRemotes) do
        pcall(function()
            remote:FireServer(targetHrp)
            remote:FireServer(Lea.Target)
            remote:FireServer()
        end)
    end
    
    -- Mouse tıklama simülasyonu
    pcall(function()
        mouse1click()
    end)
end

if followConnection then followConnection:Disconnect() end
followConnection = RunService.Heartbeat:Connect(function(dt)
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
    
    -- Takip et
    local distance = (hrp.Position - targetHrp.Position).Magnitude
    
    if distance > 3 then
        -- Uçuş modunu aktif et
        hum.PlatformStand = true
        
        local direction = (targetHrp.Position - hrp.Position).Unit
        hrp.AssemblyLinearVelocity = direction * Lea.Settings.FollowSpeed
        hrp.CFrame = CFrame.lookAt(hrp.Position, targetHrp.Position)
        
        -- Hedefe doğru eğil
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, 0, 0)
    else
        -- Saldır
        attackTimer = attackTimer + dt
        
        if attackTimer > 0.15 then -- 0.15 saniyede bir vur
            attackTimer = 0
            DoAttack()
        end
        
        -- Kaçma mekaniği (hedef bize saldırırsa)
        local targetHum = target.Character:FindFirstChildOfClass("Humanoid")
        if targetHum and targetHum:GetState() == Enum.HumanoidStateType.Running then
            local randomDir = Vector3.new(math.random(-10, 10), 0, math.random(-10, 10)).Unit
            hrp.AssemblyLinearVelocity = randomDir * 30
        end
    end
end)

-- ==============================================================================
-- 7. MEDUSA SİSTEMİ
-- ==============================================================================
local medusaConnection = nil
local medusaActive = false

local function ToggleMedusa(state)
    Lea.Modules.Medusa = state
    medusaActive = state
end

if medusaConnection then medusaConnection:Disconnect() end
medusaConnection = RunService.Heartbeat:Connect(function()
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
        -- Hedefe koş
        local targetHrp = closest.Character:FindFirstChild("HumanoidRootPart")
        if targetHrp then
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
-- 8. LAGGER SİSTEMİ
-- ==============================================================================
local laggerConnection = nil
local laggerActive = false

local function ToggleLagger(state)
    Lea.Modules.Lagger = state
    laggerActive = state
    
    if state then
        print("💀 LAGGER AKTİF")
    else
        print("💀 LAGGER KAPALI")
    end
end

if laggerConnection then laggerConnection:Disconnect() end
laggerConnection = RunService.Heartbeat:Connect(function()
    if not laggerActive then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetHrp = player.Character:FindFirstChild("HumanoidRootPart")
            
            -- 1. Remote spam
            for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") then
                    pcall(function()
                        remote:FireServer(player, {})
                        remote:FireServer(targetHrp, {})
                        remote:FireServer()
                    end)
                end
            end
            
            -- 2. Velocity spam
            if targetHrp then
                for i = 1, 10 do
                    targetHrp.AssemblyLinearVelocity = Vector3.new(
                        math.random(-100, 100),
                        math.random(-100, 100),
                        math.random(-100, 100)
                    )
                end
                targetHrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
            
            -- 3. CFrame spam
            if targetHrp then
                for i = 1, 5 do
                    targetHrp.CFrame = targetHrp.CFrame * CFrame.Angles(
                        math.rad(math.random(0, 360)),
                        math.rad(math.random(0, 360)),
                        math.rad(math.random(0, 360))
                    )
                end
            end
        end
    end
end)

print("✅ PART 1 YÜKLENDİ! (Mod Sistemleri)")

-- PART 1 BİTTİ - PART 2'YE GEÇ
-- ==============================================================================-- ==============================================================================
-- LEA MOD - PART 2/2 (MENÜ VE KONSOL KOMUTLARI)
-- ==============================================================================
-- Bu dosya: Menü sistemi, konsol komutları, kısayollar
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Global state'i al
local Lea = getgenv().Lea

-- ==============================================================================
-- 9. MENÜ SİSTEMİ (KÜÇÜK)
-- ==============================================================================
local function CreateMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LeaMenu"
    screenGui.Parent = LocalPlayer.PlayerGui
    screenGui.ResetOnSpawn = false
    
    -- Ana Frame (KÜÇÜK - 150x200)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 150, 0, 200)
    mainFrame.Position = UDim2.new(0.5, -75, 0.5, -100)
    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainFrame.BackgroundTransparency = 0.2
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
    title.Text = "⚡LEA"
    title.TextColor3 = Color3.fromRGB(0, 255, 200)
    title.TextSize = 14
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
        {name = "Cube", label = "🔷K"},
        {name = "Fly", label = "🛸F"},
        {name = "Follow", label = "🎯T"},
        {name = "Medusa", label = "🐍M"},
        {name = "Lagger", label = "💀L"}
    }
    
    local yPos = 25
    local btnHeight = 22
    local spacing = 3
    local btnWidth = 0.42
    
    local buttons = {}
    
    for i, mod in ipairs(mods) do
        local btn = Instance.new("TextButton")
        btn.Name = mod.name .. "Btn"
        btn.Size = UDim2.new(btnWidth, 0, 0, btnHeight)
        btn.Position = UDim2.new(i % 2 == 1 and 0.05 or 0.53, 0, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        btn.Text = mod.label
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextSize = 10
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
    baseBtn.Size = UDim2.new(0.42, 0, 0, 20)
    baseBtn.Position = UDim2.new(0.05, 0, 0, yPos + 2)
    baseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    baseBtn.Text = "📍K"
    baseBtn.TextColor3 = Color3.new(1, 1, 1)
    baseBtn.TextSize = 9
    baseBtn.Font = Enum.Font.GothamSemibold
    baseBtn.Parent = mainFrame
    
    local baseCorner = Instance.new("UICorner")
    baseCorner.CornerRadius = UDim.new(0, 4)
    baseCorner.Parent = baseBtn
    
    local returnBtn = Instance.new("TextButton")
    returnBtn.Size = UDim2.new(0.42, 0, 0, 20)
    returnBtn.Position = UDim2.new(0.53, 0, 0, yPos + 2)
    returnBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
    returnBtn.Text = "🏠D"
    returnBtn.TextColor3 = Color3.new(1, 1, 1)
    returnBtn.TextSize = 9
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
            baseBtn.Text = "✅K"
            task.wait(0.5)
            baseBtn.Text = "📍K"
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
            leaBtn.Size = UDim2.new(0, 40, 0, 20)
            leaBtn.Position = UDim2.new(1, -45, 0, 5)
            leaBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
            leaBtn.Text = "⚡L"
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
end

-- ==============================================================================
-- 10. KONSOL KOMUTLARI
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
    print("=== LEA MOD ===")
    for mod, state in pairs(Lea.Modules) do
        print(mod .. ": " .. (state and "✅" or "❌"))
    end
    if Lea.Target then
        print("🎯 " .. Lea.Target.Name)
    end
    if Lea.BasePosition then
        print("📍 Kayıtlı")
    end
end

_G.Lea.Help = function()
    print("=== LEA KOMUTLAR ===")
    print("SetTarget('isim') - Hedef seç")
    print("SetBase() - Base kaydet")
    print("ReturnBase() - Base dön")
    print("ToggleMod('mod') - Mod aç/kapa")
    print("Status() - Durum göster")
    print("Modlar: Cube, Fly, Follow, Medusa, Lagger")
end

-- ==============================================================================
-- 11. KISAYOLLAR VE BAŞLAT
-- ==============================================================================
CreateMenu()

print("✅ LEA MOD YÜKLENDİ!")
print("📌 Menü açık (KÜÇÜK)")
print("📌 Bypass her zaman aktif")
print("📌 Konsol: _G.Lea.Help()")
print("📌 Kısayollar: F5(Menü), F6(Fly), F7(Cube)")

-- Kısayollar
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

print("🚀 LEA MOD HAZIR!")

-- ==============================================================================
-- SON
-- ==============================================================================
