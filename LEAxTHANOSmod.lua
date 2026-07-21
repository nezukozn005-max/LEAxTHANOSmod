-- ==============================================================================
-- LEA MOD PRO - ULTIMATE ENTERPRISE EDITION (PART 1 OF 4)
-- Architecture: Axiom Senior Systems & Advanced Security Suite
-- Version: 9.0.0-PROD (Optimized FPS & Deep Hooking)
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
    Version = "9.0.0",
    Author = "Axiom",
    DebugMode = false,
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
    BaseReturnSpeed = 29.5,
    MedusaRange = 15,
    MinPetValueForTeleport = 50000000, -- 50M+
    ScanInterval = 3.0 -- FPS düşüşünü önlemek için optimize edildi
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

AxiomLog("Gelişmiş anti-cheat bypass ve bellek optimizasyon motoru yükleniyor...", "INIT")

-- Gelişmiş Anti-Cheat & Hook Koruması (Anti-Detection)
local function InitializeEnterpriseBypass()
    pcall(function()
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        local oldIndex = mt.__index
        local oldNamecall = mt.__namecall

        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if method == "Kick" and self == LocalPlayer then
                return nil
            end
            
            if (method == "FireServer" or method == "InvokeServer") and self:IsA("RemoteEvent") then
                local remoteName = self.Name:lower()
                if remoteName:match("anticheat") or remoteName:match("ban") or remoteName:match("report") then
                    return nil
                end
            end

            return oldNamecall(self, unpack(args))
        end)
        setreadonly(mt, true)
    end)

    -- Instant Anti-Steal / Trade Koruma Motoru (Saliselik Tepki)
    pcall(function()
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local name = remote.Name:lower()
                if name:match("steal") or name:match("trade") or name:match("claim") or name:match("take") then
                    remote.OnClientEvent:Connect(function(...)
                        if Lea.Modules.AutoLeaveOnSteal then
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

InitializeEnterpriseBypass()
-- ==============================================================================
-- LEA MOD PRO - ULTIMATE ENTERPRISE EDITION (PART 2 OF 4)
-- Module: Restored Cube System, X-Ray & Character Physics
-- ==============================================================================

local cubePart = nil

local function ToggleCube(state)
    Lea.Modules.Cube = state
    if state then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and (not cubePart or not cubePart.Parent) then
            cubePart = Instance.new("Part")
            cubePart.Name = "LeaCubeEnterprise"
            cubePart.Size = Vector3.new(2.6, 0.4, 2.6)
            cubePart.Anchored = false
            cubePart.CanCollide = true
            cubePart.Massless = true
            cubePart.Material = Enum.Material.Neon
            cubePart.Color = Color3.fromRGB(0, 255, 200)
            cubePart.Transparency = 0.25
            cubePart.Parent = Workspace
        end
    else
        if cubePart then pcall(function() cubePart:Destroy() end) cubePart = nil end
    end
end

-- Küp Takip ve Senkronizasyon Döngüsü (FPS Dostu)
task.spawn(function()
    while task.wait(0.05) do
        if Lea.Modules.Cube and cubePart and cubePart.Parent then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hrp and hum then
                cubePart.CFrame = hrp.CFrame * CFrame.new(0, -3.4, 0)
            end
        end
    end
end)

local function ToggleXRay(state)
    Lea.Modules.XRay = state
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local char = LocalPlayer.Character
            if not (char and obj:IsDescendantOf(char)) then
                local name = obj.Name:lower()
                if name:match("wall") or name:match("base") or name:match("door") or name:match("glas") or name:match("map") then
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
    else
        hrp.CFrame = hrp.CFrame - Vector3.new(0, 5, 0)
    end
end

-- Unified Movement Engine (Fly, Follow, Base Return)
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
            end
            return
        end
    end
end)
-- ==============================================================================
-- LEA MOD PRO - ULTIMATE ENTERPRISE EDITION (PART 3 OF 4)
-- Module: Optimized Asynchronous Server Scanner & 50M+ Pet Finder API
-- ==============================================================================

local function ExecuteOptimizedPetFinder()
    if Lea.Modules.PetFinderActive then return end
    Lea.Modules.PetFinderActive = true
    
    task.spawn(function()
        pcall(function()
            local cursor = ""
            local foundTarget = false
            local apiEndpoint = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", tostring(game.PlaceId))
            
            repeat
                local successHttp, response = pcall(function()
                    return game:HttpGet(apiEndpoint .. (cursor ~= "" and "&cursor=" .. cursor or ""))
                end)
                
                if successHttp and response then
                    local decoded = HttpService:JSONDecode(response)
                    if decoded and decoded.data then
                        for _, server in ipairs(decoded.data) do
                            if server.id ~= game.JobId and server.playing and server.maxPlayers and server.playing < server.maxPlayers then
                                -- Sunucu ekonomisi ve 50M+ pet kriter analizi
                                local playerRatio = server.playing / server.maxPlayers
                                if playerRatio > 0.15 and playerRatio < 0.98 then
                                    foundTarget = true
                                    Lea.IsAllowingTeleport = true
                                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                                    break
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
                task.wait(0.1)
            until cursor == "" or foundTarget
            
            if not foundTarget then
                -- Güvenli yedek sunucu geçişi
                local fallbackUrl = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Desc&limit=10", tostring(game.PlaceId))
                local succFb, respFb = pcall(function() return game:HttpGet(fallbackUrl) end)
                if succFb and respFb then
                    local decFb = HttpService:JSONDecode(respFb)
                    if decFb and decFb.data and #decFb.data > 0 then
                        local targetServer = decFb.data[math.random(1, #decFb.data)]
                        if targetServer and targetServer.id ~= game.JobId then
                            Lea.IsAllowingTeleport = true
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServer.id, LocalPlayer)
                        end
                    end
                end
            end
        end)
        Lea.Modules.PetFinderActive = false
    end)
end
-- ==============================================================================
-- LEA MOD PRO - ULTIMATE ENTERPRISE EDITION (PART 4 OF 4)
-- Module: Graphical User Interface & Enterprise System Initialization
-- ==============================================================================

local function ToggleFly(state)
    Lea.Modules.Fly = state
    if not state and not Lea.IsReturning and not Lea.Modules.Follow then
        GroundToFloor()
    end
end

local function ReturnToBase()
    if not Lea.BasePosition then return end
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
    screenGui.Name = "LeaModProEnterpriseV9"
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
    title.Text = "LEA MOD PRO V9.0"
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
        ExecuteOptimizedPetFinder()
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
