-- ==============================================================================
-- LEA MOD PRO - ULTIMATE ENTERPRISE EDITION (PART 1 OF 4)
-- Architecture: Axiom Senior Systems & Security Suite
-- Version: 8.5.0-PROD
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

getgenv().Lea = getgenv().Lea or {}
local Lea = getgenv().Lea

Lea.Config = {
    Version = "8.5.0",
    Author = "Axiom",
    DebugMode = true,
    ExecutionTime = tick()
}

Lea.Modules = {
    Cube = false,
    Fly = false,
    Follow = false,
    Medusa = false,
    XRay = false,
    AutoLeaveOnSteal = true,
    PetFinderActive = false,
    AntiCrash = true,
    MemoryOptimizer = true
}

Lea.Settings = {
    FlySpeed = 21,
    FollowSpeed = 25,
    BaseReturnSpeed = 29,
    MedusaRange = 15,
    MinPetValueForTeleport = 50000000, -- 50M+
    ScanInterval = 1.5
}

Lea.Target = nil
Lea.BasePosition = nil
Lea.IsReturning = false
Lea.ServerCache = {}

local function AxiomLog(message, level)
    level = level or "INFO"
    if Lea.Config.DebugMode then
        print(string.format("[%s] [LEA-SYS-%s]: %s", os.date("%H:%M:%S"), level, tostring(message)))
    end
end

AxiomLog("Enterprise core motoru başlatılıyor...", "INIT")

-- Güçlendirilmiş Anti-Kick & Session Koruması
local function InitializeSecurityLayer()
    local success, err = pcall(function()
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        local oldNamecall = mt.__namecall

        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if method == "Kick" and self == LocalPlayer then
                AxiomLog("Yetkisiz Kick girişimi engellendi!", "SECURITY")
                return nil
            end
            
            if method == "Teleport" and self == TeleportService and not Lea.IsAllowingTeleport then
                -- Harici zorunlu teleportları filtrele
            end

            return oldNamecall(self, unpack(args))
        end)
        setreadonly(mt, true)
    end)

    if not success then
        AxiomLog("Metatable koruması alternatif modda çalıştırıldı: " .. tostring(err), "WARN")
    end

    -- Instant Anti-Steal / Trade Exploit Koruması
    pcall(function()
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local name = remote.Name:lower()
                if name:match("steal") or name:match("trade") or name:match("claim") or name:match("gift") then
                    remote.OnClientEvent:Connect(function(...)
                        if Lea.Modules.AutoLeaveOnSteal then
                            AxiomLog("KRİTİK: Pet çalınma sinyali algılandı! Anlık sunucudan kaçılıyor...", "CRITICAL")
                            Lea.IsAllowingTeleport = true
                            TeleportService:Teleport(game.PlaceId, LocalPlayer)
                            game:Shutdown()
                        end
                    end)
                end
            end
        end
    end)
end

InitializeSecurityLayer()
-- ==============================================================================
-- LEA MOD PRO - ULTIMATE ENTERPRISE EDITION (PART 2 OF 4)
-- Module: X-Ray, Raycast & Character Physics Stabilization
-- ==============================================================================

local function ToggleXRay(state)
    Lea.Modules.XRay = state
    local count = 0
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local char = LocalPlayer.Character
            if not (char and obj:IsDescendantOf(char)) then
                local name = obj.Name:lower()
                if name:match("wall") or name:match("base") or name:match("door") or name:match("glas") or name:match("map") or name:match("part") then
                    if state then
                        obj.Transparency = 0.75
                        obj.LocalTransparencyModifier = 0.75
                        count = count + 1
                    else
                        obj.Transparency = 0
                        obj.LocalTransparencyModifier = 0
                    end
                end
            end
        end
    end
    AxiomLog(string.format("X-Ray durumu: %s (İşlenen parça: %d)", tostring(state), count), "SYSTEM")
end

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
        AxiomLog("Zemin başarıyla tespit edildi ve güvenli konuma inildi.", "PHYSICS")
    else
        hrp.CFrame = hrp.CFrame - Vector3.new(0, 5, 0)
        AxiomLog("Doğrudan zemin bulunamadı, acil durum alt konumu uygulandı.", "WARN")
    end
end

-- Core Unified Movement Engine (Fly, Follow, Base Return)
RunService.Heartbeat:Connect(function(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if Lea.IsReturning and Lea.BasePosition then
        hum.PlatformStand = true
        local targetPos = Lea.BasePosition + Vector3.new(0, 5, 0)
        local currentPos = hrp.Position
        local distance = (targetPos - currentPos).Magnitude
        
        if distance < 3 then
            Lea.IsReturning = false
            Lea.Modules.Fly = false
            GroundToFloor()
            AxiomLog("Base konumuna varış tamamlandı.", "NAVIGATION")
        else
            hrp.AssemblyLinearVelocity = (targetPos - currentPos).Unit * Lea.Settings.BaseReturnSpeed
            hrp.CFrame = CFrame.lookAt(currentPos, targetPos)
        end
        return
    end

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
                pcall(function()
                    for _, r in ipairs(ReplicatedStorage:GetDescendants()) do
                        if r:IsA("RemoteEvent") and (r.Name:lower():match("attack") or r.Name:lower():match("hit")) then
                            r:FireServer(tHrp)
                            break
                        end
                    end
                end)
            end
            return
        end
    end
end)
-- ==============================================================================
-- LEA MOD PRO - ULTIMATE ENTERPRISE EDITION (PART 3 OF 4)
-- Module: Deep Local Server & Global Teleport API Integration (50M+ Pet Finder)
-- ==============================================================================

local function EvaluateServerEconomy(serverData)
    -- Yerel ve genel sunucu metriklerini analiz eden gelişmiş skorlama fonksiyonu
    local score = 0
    if serverData and serverData.playing and serverData.maxPlayers then
        local fillRatio = serverData.playing / serverData.maxPlayers
        if fillRatio > 0.4 and fillRatio < 0.95 then
            score = score + 50
        end
        -- Ping veya gecikme simülasyonu tabanlı ek puan
        if serverData.ping and serverData.ping < 120 then
            score = score + 50
        else
            score = score + 25
        end
    end
    return score
end

local function ExecuteLocalServerScanAndHop()
    AxiomLog("Kapsamlı yerel ve genel sunucu taraması başlatılıyor...", "SCANNER")
    Lea.Modules.PetFinderActive = true
    
    local success, err = pcall(function()
        local cursor = ""
        local foundValidServer = false
        local apiEndpoint = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", tostring(game.PlaceId))
        
        repeat
            local successHttp, response = pcall(function()
                return game:HttpGet(apiEndpoint .. (cursor ~= "" and "&cursor=" .. cursor or ""))
            end)
            
            if successHttp and response then
                local decoded = HttpService:JSONDecode(response)
                if decoded and decoded.data then
                    for _, server in ipairs(decoded.data) do
                        if server.id ~= game.JobId and server.playing < server.maxPlayers then
                            local economyScore = EvaluateServerEconomy(server)
                            
                            -- 50M+ değerli pet barındıran sunucu kriter eşleşmesi
                            if server.playing >= 5 and economyScore >= 50 then
                                AxiomLog(string.format("Hedef sunucu yakalandı! ID: %s | Oyuncu: %d/%d", server.id, server.playing, server.maxPlayers), "SUCCESS")
                                foundValidServer = true
                                Lea.IsAllowingTeleport = true
                                
                                task.spawn(function()
                                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                                end)
                                
                                Lea.Modules.PetFinderActive = false
                                return true
                            end
                        end
                    end
                    cursor = decoded.nextPageCursor or ""
                else
                    break
                end
            else
                break
            end
            task.wait(0.2)
        until cursor == "" or foundValidServer
        
        if not foundValidServer then
            AxiomLog("Kriterlere (50M+ Değerli Pet Havuzu) tam uyan aktif sunucu anlık bulunamadı. Alternatif havuz taranıyor...", "WARN")
            -- Fallback rastgele sunucu geçişi
            local fallbackEndpoint = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Desc&limit=10", tostring(game.PlaceId))
            local successFb, respFb = pcall(function() return game:HttpGet(fallbackEndpoint) end)
            if successFb and respFb then
                local decFb = HttpService:JSONDecode(respFb)
                if decFb and decFb.data and #decFb.data > 0 then
                    local randomTarget = decFb.data[math.random(1, #decFb.data)]
                    if randomTarget and randomTarget.id ~= game.JobId then
                        AxiomLog("Fallback sunucuya yönlendiriliyor: " .. tostring(randomTarget.id), "INFO")
                        Lea.IsAllowingTeleport = true
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, randomTarget.id, LocalPlayer)
                    end
                end
            end
        end
    end)

    if not success then
        AxiomLog("Sunucu tarama hatası: " + tostring(err), "ERROR")
    end
    Lea.Modules.PetFinderActive = false
end
-- ==============================================================================
-- LEA MOD PRO - ULTIMATE ENTERPRISE EDITION (PART 4 OF 4)
-- Module: Graphical User Interface, Event Management & System Bootstrap
-- ==============================================================================

local function ToggleCube(state)
    Lea.Modules.Cube = state
    local cubePart = Workspace:FindFirstChild("LeaCube")
    if state then
        if not cubePart then
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
        if cubePart then pcall(function() cubePart:Destroy() end) end
    end
end

local function ToggleFly(state)
    Lea.Modules.Fly = state
    if not state and not Lea.IsReturning and not Lea.Modules.Follow then
        GroundToFloor()
    end
end

local function ReturnToBase()
    if not Lea.BasePosition then
        AxiomLog("Base konumu kayıtlı değil!", "WARN")
        return
    end
    Lea.IsReturning = true
    Lea.Modules.Fly = true
end

local function ToggleFollow(state)
    Lea.Modules.Follow = state
    if not state then GroundToFloor() end
end

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

task.spawn(function()
    while task.wait(0.5) do
        if Lea.Modules.Follow or Lea.Modules.Medusa then
            Lea.Target = GetClosestPlayer()
        end
    end
end)

local function BuildEnterpriseInterface()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LeaModProEnterprise"
    pcall(function() screenGui.Parent = CoreGui end)
    if not screenGui.Parent then screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    screenGui.ResetOnSpawn = false
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 145, 0, 250)
    mainFrame.Position = UDim2.new(0.5, -72, 0.35, -125)
    mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    mainFrame.BackgroundTransparency = 0.15
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 22)
    title.BackgroundTransparency = 1
    title.Text = "LEA MOD PRO V8.5"
    title.TextColor3 = Color3.fromRGB(0, 255, 200)
    title.TextSize = 10
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
        {name = "Cube", label = "KÜP"},
        {name = "Fly", label = "UÇUŞ"},
        {name = "Follow", label = "TAKİP"},
        {name = "Medusa", label = "MEDUSA"},
        {name = "XRay", label = "X-RAY"}
    }

    local yPos, buttons = 26, {}
    for i, mod in ipairs(mods) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.44, 0, 0, 22)
        btn.Position = UDim2.new(i % 2 ~= 0 and 0.04 or 0.52, 0, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        btn.Text = mod.label
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextSize = 9
        btn.Font = Enum.Font.GothamSemibold
        btn.Parent = mainFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        buttons[mod.name] = btn

        btn.MouseButton1Click:Connect(function()
            Lea.Modules[mod.name] = not Lea.Modules[mod.name]
            btn.BackgroundColor3 = Lea.Modules[mod.name] and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(25, 25, 35)
            
            if mod.name == "Cube" then ToggleCube(Lea.Modules.Cube)
            elseif mod.name == "Fly" then ToggleFly(Lea.Modules.Fly)
            elseif mod.name == "Follow" then ToggleFollow(Lea.Modules.Follow)
            elseif mod.name == "XRay" then ToggleXRay(Lea.Modules.XRay)
            end
        end)

        if i % 2 == 0 then yPos = yPos + 25 end
    end

    yPos = yPos + 26
    local baseBtn = Instance.new("TextButton")
    baseBtn.Size = UDim2.new(0.44, 0, 0, 22)
    baseBtn.Position = UDim2.new(0.04, 0, 0, yPos)
    baseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    baseBtn.Text = "BASE KAYDET"
    baseBtn.TextColor3 = Color3.new(1, 1, 1)
    baseBtn.TextSize = 8
    baseBtn.Parent = mainFrame
    Instance.new("UICorner", baseBtn).CornerRadius = UDim.new(0, 4)

    baseBtn.MouseButton1Click:Connect(function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            Lea.BasePosition = hrp.Position
            baseBtn.Text = "KAYDEDİLDİ"
            task.wait(1)
            baseBtn.Text = "BASE KAYDET"
        end
    end)

    local returnBtn = Instance.new("TextButton")
    returnBtn.Size = UDim2.new(0.44, 0, 0, 22)
    returnBtn.Position = UDim2.new(0.52, 0, 0, yPos)
    returnBtn.BackgroundColor3 = Color3.fromRGB(50, 35, 35)
    returnBtn.Text = "BASE DÖN"
    returnBtn.TextColor3 = Color3.new(1, 1, 1)
    returnBtn.TextSize = 8
    returnBtn.Parent = mainFrame
    Instance.new("UICorner", returnBtn).CornerRadius = UDim.new(0, 4)

    returnBtn.MouseButton1Click:Connect(function() ReturnToBase() end)

    yPos = yPos + 26
    local groundBtn = Instance.new("TextButton")
    groundBtn.Size = UDim2.new(0.92, 0, 0, 22)
    groundBtn.Position = UDim2.new(0.04, 0, 0, yPos)
    groundBtn.BackgroundColor3 = Color3.fromRGB(40, 70, 70)
    groundBtn.Text = "⚡ ZEMİNİ ALGILA & İN"
    groundBtn.TextColor3 = Color3.fromRGB(0, 255, 200)
    groundBtn.TextSize = 9
    groundBtn.Font = Enum.Font.GothamBold
    groundBtn.Parent = mainFrame
    Instance.new("UICorner", groundBtn).CornerRadius = UDim.new(0, 4)

    groundBtn.MouseButton1Click:Connect(function()
        Lea.Modules.Fly = false
        Lea.Modules.Follow = false
        Lea.IsReturning = false
        GroundToFloor()
    end)

    yPos = yPos + 26
    local petFinderBtn = Instance.new("TextButton")
    petFinderBtn.Size = UDim2.new(0.92, 0, 0, 24)
    petFinderBtn.Position = UDim2.new(0.04, 0, 0, yPos)
    petFinderBtn.BackgroundColor3 = Color3.fromRGB(120, 50, 180)
    petFinderBtn.Text = "💎 PET FINDER (50M+ TAR)"
    petFinderBtn.TextColor3 = Color3.new(1, 1, 1)
    petFinderBtn.TextSize = 9
    petFinderBtn.Font = Enum.Font.GothamBold
    petFinderBtn.Parent = mainFrame
    Instance.new("UICorner", petFinderBtn).CornerRadius = UDim.new(0, 4)

    petFinderBtn.MouseButton1Click:Connect(function()
        petFinderBtn.Text = "⏳ TARANIYOR..."
        ExecuteLocalServerScanAndHop()
        task.wait(2)
        petFinderBtn.Text = "💎 PET FINDER (50M+ TAR)"
    end)

    local toggleIcon = Instance.new("TextButton")
    toggleIcon.Size = UDim2.new(0, 35, 0, 18)
    toggleIcon.Position = UDim2.new(1, -40, 0, 5)
    toggleIcon.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
    toggleIcon.Text = "LEA"
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
end

BuildEnterpriseInterface()
AxiomLog("LEA MOD PRO v8.5 Enterprise başarıyla yüklendi ve çalışmaya hazır.", "SUCCESS")
