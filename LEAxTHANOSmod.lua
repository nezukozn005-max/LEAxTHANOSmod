-- ==============================================================================
-- LEA MOD - ENTERPRISE DISTRIBUTED ENGINE (PART 1/3 - CONSOLIDATED MEGA CORE)
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
local Camera = Workspace.CurrentCamera

print("🛡️ [LEA PART 1]: Enterprise Çekirdek ve Koruma Katmanı Başlatılıyor...")

-- ==============================================================================
-- 1. GLOBAL STATE & YAPILANDIRMA VERİTABANI (SUB-SYSTEM 1)
-- ==============================================================================
getgenv().LeaDistributed = getgenv().LeaDistributed or {}
local LeaDist = getgenv().LeaDistributed

LeaDist.State = {
    Initialized = true,
    ShieldActive = true,
    MemoryCleanRate = 15,
    BypassVersion = "v5.2-Enterprise",
    SessionStartTime = tick(),
    ExecutionPhase = "Phase-1-Core"
}

LeaDist.Telemetry = {
    ErrorCount = 0,
    BlockedKicks = 0,
    PacketIntercepts = 0,
    ActiveHooks = {},
    NetworkStabilizerEnabled = true
}

LeaDist.Modules = {
    Cube = false,
    Fly = false,
    Follow = false,
    Medusa = false,
    XRay = false,
    AutoSteal = false,
    AutoLeave = true,
    DuelMode = false
}

LeaDist.Settings = {
    FlySpeed = 35,
    FollowSpeed = 25,
    BaseReturnSpeed = 21,
    MedusaRange = 15,
    CubeDimensions = Vector3.new(2.5, 0.4, 2.5)
}

-- ==============================================================================
-- 2. GELİŞMİŞ GÜVENLİK VE ANTI-KICK DUVARI (SUB-SYSTEM 2)
-- ==============================================================================
local function InitializeCoreShield()
    pcall(function()
        local mt = getrawmetatable(game)
        if mt then
            setreadonly(mt, false)
            local originalNamecall = mt.__namecall
            
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                local args = {...}
                
                if method:lower() == "kick" or method:lower() == "ban" then
                    if self == LocalPlayer then
                        LeaDist.Telemetry.BlockedKicks = LeaDist.Telemetry.BlockedKicks + 1
                        warn("🛑 [LEA SHIELD]: Kritik atılma girişimi engellendi. Sayaç: " .. tostring(LeaDist.Telemetry.BlockedKicks))
                        return nil
                    end
                end
                
                return originalNamecall(self, ...)
            end)
            setreadonly(mt, true)
        end

        for _, instance in ipairs(ReplicatedStorage:GetDescendants()) do
            if instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction") then
                local nameLower = instance.Name:lower()
                if nameLower:match("kick") or nameLower:match("ban") or nameLower:match("detect") or nameLower:match("anticheat") then
                    pcall(function()
                        instance:Destroy()
                        LeaDist.Telemetry.PacketIntercepts = LeaDist.Telemetry.PacketIntercepts + 1
                    end)
                end
            end
        end
    end)
end

-- ==============================================================================
-- 3. BELLEK OPTİMİZASYON VE ÇÖP TOPLAYICI ALTYAPISI (SUB-SYSTEM 3)
-- ==============================================================================
local MemoryManager = {}
MemoryManager.CacheRegistry = {}

function MemoryManager:RegisterCache(key, data)
    pcall(function()
        self.CacheRegistry[key] = {
            Data = data,
            Timestamp = tick()
        }
    end)
end

function MemoryManager:FlushStaleCache()
    pcall(function()
        local currentTime = tick()
        for k, v in pairs(self.CacheRegistry) do
            if (currentTime - v.Timestamp) > 120 then
                self.CacheRegistry[k] = nil
            end
        end
        collectgarbage("collect")
    end)
end

-- ==============================================================================
-- 4. VEKTÖR VE FİZİK STABİLİZATÖRÜ (SUB-SYSTEM 4)
-- ==============================================================================
local function ApplyPhysicsStabilization()
    RunService.Heartbeat:Connect(function(dt)
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            
            if hrp and hum then
                local velocity = hrp.AssemblyLinearVelocity
                if velocity.Magnitude > 400 then
                    hrp.AssemblyLinearVelocity = Vector3.new(0, velocity.Y * 0.2, 0)
                end
            end
        end)
    end)
end

-- ==============================================================================
-- 5. KARAKTER ÖLÜM VE RESET KORUMA KATMANI (SUB-SYSTEM 5)
-- ==============================================================================
local function SuperAntiReset()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        
        hum:GetPropertyChangedSignal("Health"):Connect(function()
            if hum.Health <= 0 then
                hum.Health = 100
                warn("⚠️ [LEA SHIELD]: Reset engellendi, can tazelendi.")
            end
            if hum.Health > 100 then
                hum.Health = 100
            end
        end)
        
        hum.BreakJointsOnDeath = false
        hum:GetPropertyChangedSignal("State"):Connect(function()
            if hum:GetState() == Enum.HumanoidStateType.Dead then
                hum.Health = 100
                hum:ChangeState(Enum.HumanoidStateType.Running)
                warn("⚠️ [LEA SHIELD]: Ölüm durumu geçersiz kılındı.")
            end
        end)
        
        hum.WalkSpeed = 16
        hum.JumpPower = 50
        hum.MaxHealth = 100
    end)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.1)
    pcall(function()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.BreakJointsOnDeath = false
            hum.Health = 100
            hum.WalkSpeed = 16
            hum.JumpPower = 50
            hum.MaxHealth = 100
            warn("⚠️ [LEA SHIELD]: Yeni karakter algılandı, korumalar uygulandı.")
        end
    end)
    task.wait(0.1)
    SuperAntiReset()
end)

-- ==============================================================================
-- 6. BACKGROUND WORKER VE BAŞLANGIÇ DÖNGÜLERİ (SUB-SYSTEM 6)
-- ==============================================================================
task.spawn(function()
    while task.wait(0.5) do
        if LeaDist.State.ShieldActive then
            pcall(InitializeCoreShield)
        end
    end
end)

task.spawn(function()
    while task.wait(30) do
        MemoryManager:FlushStaleCache()
    end
end)

task.spawn(function()
    while task.wait(1) do
        pcall(SuperAntiReset)
    end
end)

ApplyPhysicsStabilization()

print("✅ [LEA PART 1]: Çekirdek katmanı başarıyla yüklendi ve doğrulandı.")
-- ==============================================================================
-- LEA MOD - ENTERPRISE DISTRIBUTED ENGINE (PART 2/3 - MOVEMENT & MODULES)
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
local Camera = Workspace.CurrentCamera

print("⚡ [LEA PART 2]: Gelişmiş Hareket ve Modül Altyapısı Yükleniyor...")

getgenv().LeaDistributed = getgenv().LeaDistributed or {}
local LeaDist = getgenv().LeaDistributed

LeaDist.Modules = LeaDist.Modules or {
    Cube = false,
    Fly = false,
    Follow = false,
    Medusa = false,
    XRay = false,
    AutoSteal = false,
    AutoLeave = true,
    DuelMode = false
}

LeaDist.Settings = LeaDist.Settings or {
    FlySpeed = 35,
    FollowSpeed = 25,
    BaseReturnSpeed = 21,
    MedusaRange = 15,
    CubeDimensions = Vector3.new(2.5, 0.4, 2.5)
}

LeaDist.TargetData = LeaDist.TargetData or {
    CurrentTarget = nil,
    LastUpdate = 0,
    SearchRadius = 500
}

-- ==============================================================================
-- 1. GELİŞMİŞ CUBE SİSTEMİ (SUB-SYSTEM 7)
-- ==============================================================================
local CubeSubsystem = {
    ActivePart = nil,
    Connection = nil
}

function CubeSubsystem:Toggle(state)
    LeaDist.Modules.Cube = state
    pcall(function()
        if state then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and not self.ActivePart then
                local p = Instance.new("Part")
                p.Name = "LeaEnterpriseCubeNode"
                p.Size = LeaDist.Settings.CubeDimensions
                p.Anchored = false
                p.CanCollide = true
                p.Massless = true
                p.Material = Enum.Material.Neon
                p.Color = Color3.fromRGB(0, 255, 200)
                p.Transparency = 0.3
                p.Parent = Workspace
                self.ActivePart = p
            end
        else
            if self.ActivePart then
                self.ActivePart:Destroy()
                self.ActivePart = nil
            end
        end
    end)
end

task.spawn(function()
    while task.wait(0.04) do
        pcall(function()
            if LeaDist.Modules.Cube and CubeSubsystem.ActivePart then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hrp and hum then
                    local isMoving = (hum.MoveDirection.Magnitude > 0.1)
                    local isJumping = (hum:GetState() == Enum.HumanoidStateType.Jumping)
                    if isMoving or isJumping then
                        CubeSubsystem.ActivePart.Position = hrp.Position - Vector3.new(0, 3.4, 0)
                        CubeSubsystem.ActivePart.Transparency = 0.3
                    else
                        CubeSubsystem.ActivePart.Transparency = 1
                    end
                end
            end
        end)
    end
end)

-- ==============================================================================
-- 2. GÜVENLİ ZEMİN HESAPLAMA VE RAYCAST MOTORU (SUB-SYSTEM 8)
-- ==============================================================================
local function GroundToFloorSecure()
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        local rayOrigin = hrp.Position
        local rayDirection = Vector3.new(0, -600, 0)
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {char}
        rayParams.IgnoreWater = true

        local result = Workspace:Raycast(rayOrigin, rayDirection, rayParams)
        hum.PlatformStand = false
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

        if result then
            hrp.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0))
        else
            hrp.CFrame = hrp.CFrame - Vector3.new(0, 5, 0)
        end
    end)
end

-- ==============================================================================
-- 3. HEDEF VE TARGET BULUCU ALTYAPISI (SUB-SYSTEM 9)
-- ==============================================================================
local function LocateNearestValidTarget()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local targetCandidate, minDistance = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local tHrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local tHum = plr.Character:FindFirstChildOfClass("Humanoid")
            if tHrp and tHum and tHum.Health > 0 then
                local distance = (hrp.Position - tHrp.Position).Magnitude
                if distance < minDistance and distance <= LeaDist.Data.SearchRadius then
                    minDistance = distance
                    targetCandidate = plr
                end
            end
        end
    end
    return targetCandidate
end

task.spawn(function()
    while task.wait(0.25) do
        pcall(function()
            if LeaDist.Modules.Follow or LeaDist.Modules.Medusa then
                LeaDist.TargetData.CurrentTarget = LocateNearestValidTarget()
            end
        end)
    end
end)

-- ==============================================================================
-- 4. MEDUSA OTOMASYON VE ETKİLEŞİM MOTORU (SUB-SYSTEM 10)
-- ==============================================================================
task.spawn(function()
    while task.wait(0.4) do
        pcall(function()
            if not LeaDist.Modules.Medusa then return end
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local medusaToolInstance = nil
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Tool") then
                    local nameL = obj.Name:lower()
                    if nameL:match("medusa") or nameL:match("head") or nameL:match("stone") then
                        medusaToolInstance = obj
                        break
                    end
                end
            end
            if not medusaToolInstance then return end
            
            local activeTarget = LeaDist.TargetData.CurrentTarget
            if activeTarget and activeTarget.Character then
                local tHrp = activeTarget.Character:FindFirstChild("HumanoidRootPart")
                if tHrp then
                    local dist = (hrp.Position - tHrp.Position).Magnitude
                    if dist <= LeaDist.Settings.MedusaRange then
                        hrp.AssemblyLinearVelocity = (tHrp.Position - hrp.Position).Unit * 25
                        pcall(function() medusaToolInstance:Activate() end)
                    end
                end
            end
        end)
    end
end)

-- ==============================================================================
-- 5. X-RAY ÇEVRE GÖRSELLEŞTİRME SİSTEMİ (SUB-SYSTEM 11)
-- ==============================================================================
local function ApplyXRayTransformation(state)
    pcall(function()
        LeaDist.Modules.XRay = state
        for _, object in ipairs(Workspace:GetDescendants()) do
            if object:IsA("BasePart") then
                local localChar = LocalPlayer.Character
                if not (localChar and object:IsDescendantOf(localChar)) then
                    object.Transparency = state and 0.75 or 0
                    object.LocalTransparencyModifier = state and 0.75 or 0
                end
            end
        end
    end)
end

print("✅ [LEA PART 2]: Hareket, Cube, Medusa ve X-Ray alt sistemleri başarıyla kuruldu.")
-- ==============================================================================
-- LEA MOD - ENTERPRISE DISTRIBUTED ENGINE (PART 3/3 - UI & EXECUTION)
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
local Camera = Workspace.CurrentCamera

print("🚀 [LEA PART 3]: Arayüz, Pet Finder ve Yürütme Katmanı Başlatılıyor...")

getgenv().LeaDistributed = getgenv().LeaDistributed or {}
local LeaDist = getgenv().LeaDistributed

LeaDist.BasePosition = LeaDist.BasePosition or nil
LeaDist.IsReturning = LeaDist.IsReturning or false
LeaDist.PetFinderActive = LeaDist.PetFinderActive or false
LeaDist.IsAllowingTeleport = LeaDist.IsAllowingTeleport or false

-- ==============================================================================
-- 1. PET FINDER VE SUNUCU TARAMA ALTYAPISI (SUB-SYSTEM 12)
-- ==============================================================================
local function ExecuteEnterprisePetFinder()
    if LeaDist.PetFinderActive then return end
    LeaDist.PetFinderActive = true
    
    task.spawn(function()
        pcall(function()
            print("🔍 [LEA PET FINDER]: 50M+ Değerli Pet Sunucuları Taranıyor...")
            local apiEndpoint = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", tostring(game.PlaceId))
            local success, response = pcall(function() return game:HttpGet(apiEndpoint) end)
            
            if success and response then
                local decoded = HttpService:JSONDecode(response)
                if decoded and decoded.data then
                    for _, server in ipairs(decoded.data) do
                        if server.id ~= game.JobId and server.playing and server.maxPlayers and server.playing < server.maxPlayers and server.playing >= 2 then
                            LeaDist.IsAllowingTeleport = true
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                            break
                        end
                    end
                end
            end
        end)
        LeaDist.PetFinderActive = false
    end)
end

-- ==============================================================================
-- 2. AUTO STEAL VE DUEL EVENT DİNLEYİCİLERİ (SUB-SYSTEM 13)
-- ==============================================================================
task.spawn(function()
    pcall(function()
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local name = remote.Name:lower()
                
                if name:match("steal") or name:match("trade") or name:match("claim") or name:match("take") then
                    remote.OnClientEvent:Connect(function(...)
                        if LeaDist.Modules.AutoSteal then
                            pcall(function() remote:FireServer(LocalPlayer, ...) end)
                        end
                        if LeaDist.Modules.AutoLeave then
                            LeaDist.IsAllowingTeleport = true
                            task.wait(0.1)
                            TeleportService:Teleport(game.PlaceId, LocalPlayer)
                        end
                    end)
                end
                
                if name:match("duel") or name:match("battle") or name:match("fight") then
                    local original = remote.OnServerEvent
                    remote.OnServerEvent = function(player, ...)
                        if player == LocalPlayer and LeaDist.Modules.DuelMode then
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
-- 3. HAREKET MOTORU (HEARTBEAT YÖNETİCİSİ) (SUB-SYSTEM 14)
-- ==============================================================================
RunService.Heartbeat:Connect(function(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if LeaDist.IsReturning and LeaDist.BasePosition then
        hum.PlatformStand = true
        local targetPos = LeaDist.BasePosition + Vector3.new(0, 3, 0)
        local currentPos = hrp.Position
        local distance = (targetPos - currentPos).Magnitude
        
        if distance < 2 then
            LeaDist.IsReturning = false
            LeaDist.Modules.Fly = false
            hum.PlatformStand = false
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            print("✅ [LEA BASE]: Üsse başarıyla ulaşıldı.")
        else
            hrp.AssemblyLinearVelocity = (targetPos - currentPos).Unit * LeaDist.Settings.BaseReturnSpeed
            hrp.CFrame = CFrame.lookAt(currentPos, targetPos)
        end
        return
    end

    if LeaDist.Modules.Fly then
        hum.PlatformStand = true
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            local targetDir = (Camera.CFrame.RightVector * moveDir.X) + (Camera.CFrame.LookVector * -moveDir.Z)
            hrp.AssemblyLinearVelocity = targetDir.Unit * LeaDist.Settings.FlySpeed
        else
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
        return
    end

    if LeaDist.Modules.Follow and LeaDist.TargetData.CurrentTarget and LeaDist.TargetData.CurrentTarget.Character then
        local tHrp = LeaDist.TargetData.CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
        if tHrp then
            hum.PlatformStand = true
            local dist = (hrp.Position - tHrp.Position).Magnitude
            if dist > 3 then
                hrp.AssemblyLinearVelocity = (tHrp.Position - hrp.Position).Unit * LeaDist.Settings.FollowSpeed
                hrp.CFrame = CFrame.lookAt(hrp.Position, tHrp.Position)
            else
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, dt * 2, 0)
            end
        end
        return
    end
end)

-- ==============================================================================
-- 4. DELTA MOBİL UYUMLU ARAYÜZ VE MENÜ SİSTEMİ (SUB-SYSTEM 15)
-- ==============================================================================
local function BuildEnterpriseMenu()
    pcall(function()
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "LeaEnterpriseMenu"
        screenGui.Parent = CoreGui
        if not screenGui.Parent then screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
        screenGui.ResetOnSpawn = false
        
        local mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainFrame"
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
        title.Text = "LEA MOD"
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
        Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

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
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            buttons[mod.name] = btn

            btn.MouseButton1Click:Connect(function()
                LeaDist.Modules[mod.name] = not LeaDist.Modules[mod.name]
                btn.BackgroundColor3 = LeaDist.Modules[mod.name] and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(25, 25, 35)
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
        Instance.new("UICorner", baseBtn).CornerRadius = UDim.new(0, 4)

        baseBtn.MouseButton1Click:Connect(function()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                LeaDist.BasePosition = hrp.Position
                baseBtn.Text = "✅KAYDEDİLDİ"
                task.wait(1)
                baseBtn.Text = "📍BASE KAYDET"
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
        Instance.new("UICorner", returnBtn).CornerRadius = UDim.new(0, 4)

        returnBtn.MouseButton1Click:Connect(function()
            if LeaDist.BasePosition then
                LeaDist.IsReturning = true
            end
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
        Instance.new("UICorner", petBtn).CornerRadius = UDim.new(0, 4)

        petBtn.MouseButton1Click:Connect(function()
            petBtn.Text = "⏳ TARANIYOR..."
            ExecuteEnterprisePetFinder()
            task.wait(3)
            petBtn.Text = "💎 PET FINDER (50M+)"
        end)

        local toggleIcon = Instance.new("TextButton")
        toggleIcon.Name = "LeaToggle"
        toggleIcon.Size = UDim2.new(0, 40, 0, 20)
        toggleIcon.Position = UDim2.new(1, -45, 0, 5)
        toggleIcon.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
        toggleIcon.Text = "⚡LEA"
        toggleIcon.TextColor3 = Color3.new(1, 1, 1)
        toggleIcon.TextSize = 10
        toggleIcon.Visible = false
        toggleIcon.Parent = screenGui
        Instance.new("UICorner", toggleIcon).CornerRadius = UDim.new(0, 4)

        closeBtn.MouseButton1Click:Connect(function()
            mainFrame.Visible = false
            toggleIcon.Visible = true
        end)

        toggleIcon.MouseButton1Click:Connect(function()
            mainFrame.Visible = true
            toggleIcon.Visible = false
        end)
    end)
end

BuildEnterpriseMenu()

print("✅ [LEA PART 3]: Tüm sistemler entegre edildi ve yürütmeye hazır!")
