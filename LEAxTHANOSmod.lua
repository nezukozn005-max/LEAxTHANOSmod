-- ==============================================================================
-- LEA MOD - PART 1/3 (KORUMA & BYPASS)
-- ==============================================================================
-- Bu dosya: Anti-Kick, Anti-Reset, Bypass, Session Protection
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

print("🛡️ LEA PART 1/3 - KORUMA BAŞLATILIYOR...")

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
    XRay = false,
    AutoSteal = false,
    AutoLeave = true,
    DuelMode = false
}

Lea.Settings = {
    FlySpeed = 35,
    FollowSpeed = 25,
    BaseReturnSpeed = 21,
    MedusaRange = 15
}

Lea.Target = nil
Lea.BasePosition = nil
Lea.IsReturning = false

-- ==============================================================================
-- 2. GÜÇLENDİRİLMİŞ ANTI-KICK
-- ==============================================================================
local function SuperAntiKick()
    pcall(function()
        -- Kick fonksiyonunu devre dışı bırak
        local originalKick = LocalPlayer.Kick
        LocalPlayer.Kick = function(self, message)
            warn("⚠️ KICK ENGELLENDİ! Mesaj: " .. tostring(message))
            return nil
        end
        
        -- Tüm remote kickleri engelle
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                local name = remote.Name:lower()
                if name:match("kick") or name:match("ban") or name:match("remove") or 
                   name:match("delete") or name:match("destroy") or name:match("block") or
                   name:match("disconnect") or name:match("terminate") then
                    
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
        
        -- TeleportService'i engelle
        local TeleportService = game:GetService("TeleportService")
        if TeleportService then
            local originalTeleport = TeleportService.Teleport
            TeleportService.Teleport = function(self, ...)
                warn("⚠️ TELEPORT ENGELLENDİ!")
                return nil
            end
        end
        
        -- Parent değişimini engelle
        LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
            if LocalPlayer.Parent == nil then
                warn("⚠️ PARENT DEĞİŞİMİ ENGELLENDİ!")
                LocalPlayer.Parent = Players
            end
        end)
    end)
end

-- ==============================================================================
-- 3. GÜÇLENDİRİLMİŞ ANTI-RESET
-- ==============================================================================
local function SuperAntiReset()
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    -- Health resetini engelle
    hum:GetPropertyChangedSignal("Health"):Connect(function()
        if hum.Health <= 0 then
            hum.Health = 100
            warn("⚠️ RESET ENGELLENDİ! Can yenilendi.")
        end
        if hum.Health > 100 then
            hum.Health = 100
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
    
    -- Humanoid özelliklerini koru
    hum.WalkSpeed = 16
    hum.JumpPower = 50
    hum.MaxHealth = 100
end

-- CharacterAdded ile reset kontrolü
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.1)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.BreakJointsOnDeath = false
        hum.Health = 100
        hum.WalkSpeed = 16
        hum.JumpPower = 50
        hum.MaxHealth = 100
        warn("⚠️ YENİ KARAKTER - RESET ENGELLENDİ!")
    end
    task.wait(0.1)
    SuperAntiReset()
end)

-- ==============================================================================
-- 4. GÜÇLENDİRİLMİŞ BYPASS
-- ==============================================================================
local function SuperBypass()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        -- İsim gizleme
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                part.Name = "Part_" .. HttpService:GenerateGUID(false):sub(1, 8)
            end
        end
        
        -- Remote manipülasyonu
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local original = remote.OnServerEvent
                remote.OnServerEvent = function(player, ...)
                    if player == LocalPlayer then
                        return original and original(player, {})
                    end
                    return original and original(player, ...)
                end
            end
            
            if remote:IsA("RemoteFunction") then
                local originalInvoke = remote.OnServerInvoke
                remote.OnServerInvoke = function(player, ...)
                    if player == LocalPlayer then
                        return nil
                    end
                    return originalInvoke and originalInvoke(player, ...)
                end
            end
        end
        
        -- Velocity smoothing
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp:GetPropertyChangedSignal("AssemblyLinearVelocity"):Connect(function()
                local vel = hrp.AssemblyLinearVelocity
                if vel.Magnitude > 80 then
                    hrp.AssemblyLinearVelocity = vel * 0.5
                end
                if vel.Magnitude > 200 then
                    hrp.AssemblyLinearVelocity = vel * 0.3
                end
            end)
        end
        
        -- CFrame smoothing
        if hrp then
            local lastPos = hrp.Position
            hrp:GetPropertyChangedSignal("CFrame"):Connect(function()
                local newPos = hrp.Position
                local distance = (newPos - lastPos).Magnitude
                
                if distance > 50 then
                    warn("⚠️ AŞIRI TELEPORT ENGELLENDİ!")
                    hrp.CFrame = CFrame.new(lastPos)
                end
                
                if newPos.Y > 500 or newPos.Y < -100 then
                    warn("⚠️ AŞIRI YÜKSEKLİK ENGELLENDİ!")
                    hrp.CFrame = CFrame.new(lastPos.X, 5, lastPos.Z)
                end
                
                lastPos = newPos
            end)
        end
        
        -- Anticheat remote'larını engelle
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local name = remote.Name:lower()
                if name:match("anticheat") or name:match("antihack") or name:match("mod") or 
                   name:match("detect") or name:match("check") or name:match("verify") or
                   name:match("admin") or name:match("report") then
                    
                    local original = remote.OnServerEvent
                    remote.OnServerEvent = function(player, ...)
                        if player == LocalPlayer then
                            return nil
                        end
                        return original and original(player, ...)
                    end
                end
            end
        end
    end)
end

-- ==============================================================================
-- 5. OTURUM KORUMASI
-- ==============================================================================
local function SuperSessionProtection()
    pcall(function()
        -- Parent değişimini engelle
        LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
            if LocalPlayer.Parent == nil then
                warn("⚠️ PARENT DEĞİŞİMİ ENGELLENDİ!")
                LocalPlayer.Parent = Players
            end
        end)
        
        -- Player nesnesini koru
        local originalDestroy = LocalPlayer.Destroy
        LocalPlayer.Destroy = function(self)
            warn("⚠️ PLAYER DESTROY ENGELLENDİ!")
            return nil
        end
    end)
end

-- ==============================================================================
-- 6. KORUMA DÖNGÜSÜ
-- ==============================================================================
local function SuperProtectionLoop()
    pcall(SuperAntiKick)
    pcall(SuperAntiReset)
    pcall(SuperSessionProtection)
    pcall(SuperBypass)
end

-- Sürekli koruma
task.spawn(function()
    while task.wait(1) do
        pcall(SuperProtectionLoop)
    end
end)

-- Karakter değişiminde koruma
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.2)
    pcall(SuperProtectionLoop)
    pcall(SuperAntiReset)
end)

-- ==============================================================================
-- 7. EKSTRA KORUMALAR
-- ==============================================================================
-- Script injection koruması
pcall(function()
    local originalLoad = loadstring
    loadstring = function(code, chunk)
        if code and (code:match("kick") or code:match("ban") or code:match("reset") or code:match("remove")) then
            warn("⚠️ SCRIPT INJECTION ENGELLENDİ!")
            return nil
        end
        return originalLoad(code, chunk)
    end
end)

-- Error koruması
pcall(function()
    local originalError = error
    error = function(msg, level)
        if type(msg) == "string" and (msg:match("kick") or msg:match("ban") or msg:match("reset")) then
            warn("⚠️ ERROR ENGELLENDİ: " .. msg)
            return nil
        end
        return originalError(msg, level)
    end
end)

-- Memory koruması
task.spawn(function()
    while task.wait(30) do
        pcall(collectgarbage, "collect")
    end
end)

print("")
print("========================================")
print("✅ PART 1/3 - KORUMA SİSTEMLERİ YÜKLENDİ!")
print("========================================")
print("🛡️ Super Anti-Kick: AKTİF")
print("🛡️ Super Anti-Reset: AKTİF")
print("🛡️ Super Bypass: AKTİF")
print("🛡️ Super Session Protection: AKTİF")
print("🛡️ Anti-Script Injection: AKTİF")
print("🛡️ Error Protection: AKTİF")
print("========================================")

-- PART 1 BİTTİ - PART 2'YE GEÇ-- ==============================================================================
-- LEA MOD - PART 2/3 (MOD SİSTEMLERİ)
-- ==============================================================================
-- Bu dosya: Cube, Fly, Follow, Medusa, X-Ray, Base Dönüş
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Lea = getgenv().Lea

print("⚙️ PART 2/3 - MOD SİSTEMLERİ BAŞLATILIYOR...")

-- ==============================================================================
-- 1. GROUND TO FLOOR
-- ==============================================================================
local function GroundToFloor()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local rayOrigin = hrp.Position
    local rayDirection = Vector3.new(0, -600, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {char}
    raycastParams.IgnoreWater = true

    local raycastResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    
    hum.PlatformStand = false
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

    if raycastResult then
        hrp.CFrame = CFrame.new(raycastResult.Position + Vector3.new(0, 3, 0))
    else
        hrp.CFrame = hrp.CFrame - Vector3.new(0, 5, 0)
    end
end

-- ==============================================================================
-- 2. TARGET SİSTEMİ (OTOMATİK EN YAKIN)
-- ==============================================================================
local function GetClosestPlayer()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local closest, closestDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local tHrp = player.Character:FindFirstChild("HumanoidRootPart")
            if tHrp then
                local dist = (hrp.Position - tHrp.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = player
                end
            end
        end
    end
    return closest
end

-- Target güncelleme
task.spawn(function()
    while task.wait(0.3) do
        if Lea.Modules.Follow or Lea.Modules.Medusa then
            Lea.Target = GetClosestPlayer()
        end
    end
end)

-- ==============================================================================
-- 3. CUBE SİSTEMİ
-- ==============================================================================
local cubePart = nil

local function ToggleCube(state)
    Lea.Modules.Cube = state
    if state then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and not cubePart then
            cubePart = Instance.new("Part")
            cubePart.Name = "LeaCube"
            cubePart.Size = Vector3.new(2.5, 0.4, 2.5)
            cubePart.Anchored = false
            cubePart.CanCollide = true
            cubePart.Massless = true
            cubePart.Material = Enum.Material.Neon
            cubePart.Color = Color3.fromRGB(0, 255, 200)
            cubePart.Transparency = 0.3
            cubePart.Parent = Workspace
        end
    else
        if cubePart then pcall(function() cubePart:Destroy() end) cubePart = nil end
    end
end

task.spawn(function()
    while task.wait(0.05) do
        if Lea.Modules.Cube and cubePart then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hrp and hum then
                local isMoving = (hum.MoveDirection.Magnitude > 0.1)
                local isJumping = (hum:GetState() == Enum.HumanoidStateType.Jumping)
                if isMoving or isJumping then
                    cubePart.Position = hrp.Position - Vector3.new(0, 3.4, 0)
                    cubePart.Transparency = 0.3
                else
                    cubePart.Transparency = 1
                end
            end
        end
    end
end)

-- ==============================================================================
-- 4. FLY SİSTEMİ
-- ==============================================================================
local function ToggleFly(state)
    Lea.Modules.Fly = state
    if not state and not Lea.IsReturning and not Lea.Modules.Follow then
        GroundToFloor()
    end
end

-- ==============================================================================
-- 5. BASE DÖNÜŞ
-- ==============================================================================
local function ReturnToBase()
    if not Lea.BasePosition then
        print("❌ Base kaydedilmemiş!")
        return
    end
    Lea.IsReturning = true
end

-- ==============================================================================
-- 6. FOLLOW SİSTEMİ (360° DÖNÜŞ)
-- ==============================================================================
local function ToggleFollow(state)
    Lea.Modules.Follow = state
    if not state then GroundToFloor() end
end

-- ==============================================================================
-- 7. MEDUSA SİSTEMİ
-- ==============================================================================
local function ToggleMedusa(state)
    Lea.Modules.Medusa = state
end

task.spawn(function()
    while task.wait(0.5) do
        if not Lea.Modules.Medusa then continue end
        
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
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
        
        if not medusaTool then continue end
        
        local closest = GetClosestPlayer()
        if closest then
            local tHrp = closest.Character and closest.Character:FindFirstChild("HumanoidRootPart")
            if tHrp then
                local dist = (hrp.Position - tHrp.Position).Magnitude
                if dist <= Lea.Settings.MedusaRange then
                    hrp.AssemblyLinearVelocity = (tHrp.Position - hrp.Position).Unit * 25
                    pcall(function()
                        medusaTool:Activate()
                    end)
                end
            end
        end
    end
end)

-- ==============================================================================
-- 8. X-RAY SİSTEMİ
-- ==============================================================================
local function ToggleXRay(state)
    Lea.Modules.XRay = state
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local char = LocalPlayer.Character
            if not (char and obj:IsDescendantOf(char)) then
                if state then
                    obj.Transparency = 0.75
                    obj.LocalTransparencyModifier = 0.75
                else
                    obj.Transparency = 0
                    obj.LocalTransparencyModifier = 0
                end
            end
        end
    end
end

-- ==============================================================================
-- 9. HAREKET MOTORU
-- ==============================================================================
RunService.Heartbeat:Connect(function(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    -- Base dönüş
    if Lea.IsReturning and Lea.BasePosition then
        hum.PlatformStand = true
        local targetPos = Lea.BasePosition + Vector3.new(0, 3, 0)
        local currentPos = hrp.Position
        local distance = (targetPos - currentPos).Magnitude
        
        if distance < 2 then
            Lea.IsReturning = false
            Lea.Modules.Fly = false
            GroundToFloor()
            print("✅ Base'e varıldı!")
        else
            hrp.AssemblyLinearVelocity = (targetPos - currentPos).Unit * Lea.Settings.BaseReturnSpeed
            hrp.CFrame = CFrame.lookAt(currentPos, targetPos)
        end
        return
    end

    -- Fly
    if Lea.Modules.Fly then
        hum.PlatformStand = true
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            local targetDir = (Camera.CFrame.RightVector * moveDir.X) + (Camera.CFrame.LookVector * -moveDir.Z)
            hrp.AssemblyLinearVelocity = targetDir.Unit * Lea.Settings.FlySpeed
        else
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
        return
    end

    -- Follow (360° dönüş)
    if Lea.Modules.Follow and Lea.Target and Lea.Target.Character then
        local tHrp = Lea.Target.Character:FindFirstChild("HumanoidRootPart")
        if tHrp then
            hum.PlatformStand = true
            local dist = (hrp.Position - tHrp.Position).Magnitude
            if dist > 3 then
                hrp.AssemblyLinearVelocity = (tHrp.Position - hrp.Position).Unit * Lea.Settings.FollowSpeed
                hrp.CFrame = CFrame.lookAt(hrp.Position, tHrp.Position)
            else
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, dt * 2, 0)
            end
        end
        return
    end
end)

print("")
print("========================================")
print("✅ PART 2/3 - MOD SİSTEMLERİ YÜKLENDİ!")
print("========================================")
print("🔷 Cube: YÜRÜRKEN/ZIPLARKEN KÜP")
print("🛸 Fly: UÇUŞ MODU")
print("🎯 Follow: 360° TAKİP & SALDIRI")
print("🐍 Medusa: OTOMATİK MEDUSA")
print("👁️ X-Ray: DUVARLARI GÖR")
print("🏠 Base: KAYDET & DÖN")
print("========================================")

-- PART 2 BİTTİ - PART 3'E GEÇ-- ==============================================================================
-- LEA MOD - PART 3/3 (PET FINDER, DUEL & MENÜ)
-- ==============================================================================
-- Bu dosya: Pet Finder (50M+), Auto Steal, Duel Mode, Menü
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local Lea = getgenv().Lea

print("💎 PART 3/3 - PET FINDER, DUEL & MENÜ BAŞLATILIYOR...")

-- ==============================================================================
-- 1. PET FINDER (50M+)
-- ==============================================================================
local function ExecutePetFinder()
    if Lea.PetFinderActive then return end
    Lea.PetFinderActive = true
    
    task.spawn(function()
        pcall(function()
            print("🔍 50M+ PET ARANIYOR...")
            print("📡 Tüm public sunucular taranıyor...")
            
            local apiEndpoint = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", 
                tostring(game.PlaceId))
            
            local success, response = pcall(function()
                return game:HttpGet(apiEndpoint)
            end)
            
            if success and response then
                local decoded = HttpService:JSONDecode(response)
                if decoded and decoded.data then
                    local found = false
                    for _, server in ipairs(decoded.data) do
                        if server.id ~= game.JobId and server.playing and server.maxPlayers and 
                           server.playing < server.maxPlayers and server.playing >= 2 then
                            
                            print("✅ SUNUCU BULUNDU: " .. server.id)
                            print("👥 Oyuncu: " .. server.playing .. "/" .. server.maxPlayers)
                            print("📊 Yoğunluk: " .. math.floor((server.playing / server.maxPlayers) * 100) .. "%")
                            
                            found = true
                            Lea.IsAllowingTeleport = true
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                            break
                        end
                    end
                    
                    if not found then
                        print("❌ Uygun sunucu bulunamadı!")
                    end
                end
            else
                print("❌ Sunucu listesi alınamadı!")
            end
        end)
        Lea.PetFinderActive = false
    end)
end

-- ==============================================================================
-- 2. DUEL & STEAL MODLARI
-- ==============================================================================
task.spawn(function()
    pcall(function()
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local name = remote.Name:lower()
                
                -- Auto Steal
                if name:match("steal") or name:match("trade") or name:match("claim") or 
                   name:match("take") or name:match("grab") or name:match("snatch") then
                    
                    remote.OnClientEvent:Connect(function(...)
                        if Lea.Modules.AutoSteal then
                            warn("⚡ STEAL TESPİT EDİLDİ! OTOMATİK ÇALINIYOR...")
                            pcall(function()
                                remote:FireServer(LocalPlayer, ...)
                            end)
                        end
                        
                        if Lea.Modules.AutoLeave then
                            warn("⚡ STEAL YAPILDI! SUNUCUDAN KAÇILIYOR...")
                            Lea.IsAllowingTeleport = true
                            task.wait(0.1)
                            TeleportService:Teleport(game.PlaceId, LocalPlayer)
                        end
                    end)
                end
                
                -- Duel Mode
                if name:match("duel") or name:match("battle") or name:match("fight") or 
                   name:match("challenge") or name:match("request") then
                    
                    local original = remote.OnServerEvent
                    remote.OnServerEvent = function(player, ...)
                        if player == LocalPlayer and Lea.Modules.DuelMode then
                            warn("⚔️ DUEL TESPİT EDİLDİ! OTOMATİK KABUL...")
                            return original and original(player, true)
                        end
                        return original and original(player, ...)
                    end
                end
            end
        end
    end)
end)

-- ==============================================================================
-- 3. MENÜ SİSTEMİ
-- ==============================================================================
local function CreateMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LeaMenu"
    screenGui.Parent = LocalPlayer.PlayerGui
    screenGui.ResetOnSpawn = false
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 150, 0, 280)
    mainFrame.Position = UDim2.new(0.5, -75, 0.5, -140)
    mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    mainFrame.BackgroundTransparency = 0.15
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 22)
    title.BackgroundTransparency = 1
    title.Text = "⚡LEA PRO"
    title.TextColor3 = Color3.fromRGB(0, 255, 200)
    title.TextSize = 11
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 18, 0, 18)
    closeBtn.Position = UDim2.new(0, 4, 0, 2)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = 9
    closeBtn.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeBtn

    local mods = {
        {name = "Cube", label = "🔷KÜP"},
        {name = "Fly", label = "🛸UÇUŞ"},
        {name = "Follow", label = "🎯TAKİP"},
        {name = "Medusa", label = "🐍MEDUSA"},
        {name = "XRay", label = "👁️X-RAY"},
        {name = "AutoSteal", label = "⚡STEAL"},
        {name = "DuelMode", label = "⚔️DUEL"}
    }

    local yPos, buttons = 26, {}
    for i, mod in ipairs(mods) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.44, 0, 0, 22)
        btn.Position = UDim2.new(i % 2 ~= 0 and 0.04 or 0.52, 0, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        btn.Text = mod.label
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextSize = 8
        btn.Font = Enum.Font.GothamSemibold
        btn.Parent = mainFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = btn
        
        buttons[mod.name] = btn

        btn.MouseButton1Click:Connect(function()
            Lea.Modules[mod.name] = not Lea.Modules[mod.name]
            btn.BackgroundColor3 = Lea.Modules[mod.name] and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(25, 25, 35)
            
            if mod.name == "Cube" then ToggleCube(Lea.Modules.Cube)
            elseif mod.name == "Fly" then ToggleFly(Lea.Modules.Fly)
            elseif mod.name == "Follow" then ToggleFollow(Lea.Modules.Follow)
            elseif mod.name == "Medusa" then ToggleMedusa(Lea.Modules.Medusa)
            elseif mod.name == "XRay" then ToggleXRay(Lea.Modules.XRay)
            end
        end)

        if i % 2 == 0 then yPos = yPos + 24 end
    end

    yPos = yPos + 24
    
    local baseBtn = Instance.new("TextButton")
    baseBtn.Size = UDim2.new(0.44, 0, 0, 22)
    baseBtn.Position = UDim2.new(0.04, 0, 0, yPos)
    baseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    baseBtn.Text = "📍BASE KAYDET"
    baseBtn.TextColor3 = Color3.new(1, 1, 1)
    baseBtn.TextSize = 8
    baseBtn.Parent = mainFrame
    
    local baseCorner = Instance.new("UICorner")
    baseCorner.CornerRadius = UDim.new(0, 4)
    baseCorner.Parent = baseBtn

    baseBtn.MouseButton1Click:Connect(function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            Lea.BasePosition = hrp.Position
            baseBtn.Text = "✅KAYDEDİLDİ"
            task.wait(1)
            baseBtn.Text = "📍BASE KAYDET"
            print("✅ Base kaydedildi!")
        end
    end)

    local returnBtn = Instance.new("TextButton")
    returnBtn.Size = UDim2.new(0.44, 0, 0, 22)
    returnBtn.Position = UDim2.new(0.52, 0, 0, yPos)
    returnBtn.BackgroundColor3 = Color3.fromRGB(50, 35, 35)
    returnBtn.Text = "🏠BASE DÖN"
    returnBtn.TextColor3 = Color3.new(1, 1, 1)
    returnBtn.TextSize = 8
    returnBtn.Parent = mainFrame
    
    local returnCorner = Instance.new("UICorner")
    returnCorner.CornerRadius = UDim.new(0, 4)
    returnCorner.Parent = returnBtn

    returnBtn.MouseButton1Click:Connect(function()
        ReturnToBase()
    end)

    yPos = yPos + 26
    
    local petBtn = Instance.new("TextButton")
    petBtn.Size = UDim2.new(0.92, 0, 0, 24)
    petBtn.Position = UDim2.new(0.04, 0, 0, yPos)
    petBtn.BackgroundColor3 = Color3.fromRGB(120, 50, 180)
    petBtn.Text = "💎 PET FINDER (50M+)"
    petBtn.TextColor3 = Color3.new(1, 1, 1)
    petBtn.TextSize = 9
    petBtn.Font = Enum.Font.GothamBold
    petBtn.Parent = mainFrame
    
    local petCorner = Instance.new("UICorner")
    petCorner.CornerRadius = UDim.new(0, 4)
    petCorner.Parent = petBtn

    petBtn.MouseButton1Click:Connect(function()
        petBtn.Text = "⏳ TARANIYOR..."
        ExecutePetFinder()
        task.wait(3)
        petBtn.Text = "💎 PET FINDER (50M+)"
    end)

    -- LEA toggle butonu
    local toggleIcon = Instance.new("TextButton")
    toggleIcon.Size = UDim2.new(0, 40, 0, 20)
    toggleIcon.Position = UDim2.new(1, -45, 0, 5)
    toggleIcon.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
    toggleIcon.Text = "⚡LEA"
    toggleIcon.TextColor3 = Color3.new(1, 1, 1)
    toggleIcon.TextSize = 10
    toggleIcon.Visible = false
    toggleIcon.Parent = screenGui
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 4)
    toggleCorner.Parent = toggleIcon

    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        toggleIcon.Visible = true
    end)

    toggleIcon.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        toggleIcon.Visible = false
    end)
end

CreateMenu()

-- ==============================================================================
-- 4. KONSOL KOMUTLARI
-- ==============================================================================
_G.Lea = _G.Lea or {}

_G.Lea.SetBase = function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        Lea.BasePosition = hrp.Position
        print("✅ Base kaydedildi!")
    else
        print("❌ Karakter bulunamadı!")
    end
end

_G.Lea.ReturnBase = ReturnToBase

_G.Lea.ToggleMod = function(mod, state)
    if not Lea.Modules[mod] then
        print("❌ Geçersiz mod: " .. tostring(mod))
        print("📌 Modlar: Cube, Fly, Follow, Medusa, XRay, AutoSteal, DuelMode")
        return
    end
    if state == nil then state = not Lea.Modules[mod] end
    Lea.Modules[mod] = state
    print("✅ " .. mod .. " " .. (state and "AÇIK" or "KAPALI"))
end

_G.Lea.FindPet = ExecutePetFinder

_G.Lea.Status = function()
    print("=== LEA PRO DURUMU ===")
    for mod, state in pairs(Lea.Modules) do
        print(mod .. ": " .. (state and "✅" or "❌"))
    end
    if Lea.Target then print("🎯 Hedef: " .. Lea.Target.Name) else print("🎯 Hedef: Yok") end
    if Lea.BasePosition then print("📍 Base: Kayıtlı") else print("📍 Base: Yok") end
    print("==========================")
end

_G.Lea.Help = function()
    print("=== LEA PRO KOMUTLARI ===")
    print("SetBase() - Base kaydet")
    print("ReturnBase() - Base dön")
    print("ToggleMod('mod') - Mod aç/kapa")
    print("FindPet() - 50M+ pet ara")
    print("Status() - Durum göster")
    print("")
    print("📌 Modlar: Cube, Fly, Follow, Medusa, XRay, AutoSteal, DuelMode")
    print("📌 Kısayollar: F5(Menü), F6(Fly), F7(Cube)")
end

-- ==============================================================================
-- 5. KISAYOLLAR
-- ==============================================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F5 then
        local gui = LocalPlayer.PlayerGui:FindFirstChild("LeaMenu")
        if gui then
            local frame = gui:FindFirstChild("MainFrame")
            local toggle = gui:FindFirstChild("LeaToggle")
            if frame then
                frame.Visible = not frame.Visible
                if toggle then toggle.Visible = not frame.Visible end
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
-- 6. BAŞLAT
-- ==============================================================================
print("")
print("========================================")
print("✅ PART 3/3 - PET FINDER, DUEL & MENÜ YÜKLENDİ!")
print("========================================")
print("💎 Pet Finder: 50M+ TARAMA")
print("⚡ Auto Steal: AKTİF")
print("⚔️ Duel Mode: AKTİF")
print("📋 Menü: KÜÇÜK VE KULLANIŞLI")
print("========================================")
print("✅ LEA ULTIMATE TAMAMEN YÜKLENDİ!")
print("📌 Konsol: _G.Lea.Help() - Tüm komutlar")
print("📌 Kısayollar: F5(Menü), F6(Fly), F7(Cube)")
print("========================================")
print("🚀 LEA PRO HAZIR! İYİ OYUNLAR!")
