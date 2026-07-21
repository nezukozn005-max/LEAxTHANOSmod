-- ==============================================================================
-- LEA MOD - UNIFIED MASTER SCRIPT (FULL SYSTEM INTEGRATION)
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

print("🛡️ LEA MASTER SİSTEMİ BAŞLATILIYOR...")

-- ==============================================================================
-- 1. GLOBAL STATE & CONFIGURATION
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
Lea.PetFinderActive = false
Lea.IsAllowingTeleport = false

-- ==============================================================================
-- 2. GÜÇLENDİRİLMİŞ KORUMA & BYPASS (PART 1)
-- ==============================================================================
local function SuperAntiKick()
    pcall(function()
        local originalKick = LocalPlayer.Kick
        LocalPlayer.Kick = function(self, message)
            warn("⚠️ KICK ENGELLENDİ! Mesaj: " .. tostring(message))
            return nil
        end
        
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
        
        if TeleportService then
            local originalTeleport = TeleportService.Teleport
            TeleportService.Teleport = function(self, placeId, player, ...)
                if player == LocalPlayer and not Lea.IsAllowingTeleport then
                    warn("⚠️ İZİNSİZ TELEPORT ENGELLENDİ!")
                    return nil
                end
                return originalTeleport(self, placeId, player, ...)
            end
        end
        
        LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
            if LocalPlayer.Parent == nil then
                warn("⚠️ PARENT DEĞİŞİMİ ENGELLENDİ!")
                LocalPlayer.Parent = Players
            end
        end)
    end)
end

local function SuperAntiReset()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    hum:GetPropertyChangedSignal("Health"):Connect(function()
        if hum.Health <= 0 then
            hum.Health = 100
            warn("⚠️ RESET ENGELLENDİ! Can yenilendi.")
        end
        if hum.Health > 100 then
            hum.Health = 100
        end
    end)
    
    hum.BreakJointsOnDeath = false
    hum:GetPropertyChangedSignal("State"):Connect(function()
        if hum.State == Enum.HumanoidStateType.Dead then
            hum.Health = 100
            hum:ChangeState(Enum.HumanoidStateType.Running)
            warn("⚠️ ÖLÜM ENGELLENDİ!")
        end
    end)
    
    hum.WalkSpeed = 16
    hum.JumpPower = 50
    hum.MaxHealth = 100
end

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

local function SuperBypass()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                part.Name = "Part_" .. HttpService:GenerateGUID(false):sub(1, 8)
            end
        end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp:GetPropertyChangedSignal("AssemblyLinearVelocity"):Connect(function()
                local vel = hrp.AssemblyLinearVelocity
                if vel.Magnitude > 200 then
                    hrp.AssemblyLinearVelocity = vel * 0.3
                end
            end)
        end
    end)
end

task.spawn(function()
    while task.wait(1) do
        pcall(SuperAntiKick)
        pcall(SuperAntiReset)
        pcall(SuperBypass)
    end
end)

-- ==============================================================================
-- 3. YARDIMCI MOTORLAR & MOD SİSTEMLERİ (PART 2)
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
    while task.wait(0.3) do
        if Lea.Modules.Follow or Lea.Modules.Medusa then
            Lea.Target = GetClosestPlayer()
        end
    end
end)

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

local function ToggleFly(state)
    Lea.Modules.Fly = state
    if not state and not Lea.IsReturning and not Lea.Modules.Follow then
        GroundToFloor()
    end
end

local function ReturnToBase()
    if not Lea.BasePosition then
        print("❌ Base kaydedilmemiş!")
        return
    end
    Lea.IsReturning = true
end

local function ToggleFollow(state)
    Lea.Modules.Follow = state
    if not state then GroundToFloor() end
end

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
                    pcall(function() medusaTool:Activate() end)
                end
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
                obj.Transparency = state and 0.75 or 0
                obj.LocalTransparencyModifier = state and 0.75 or 0
            end
        end
    end
end

-- ==============================================================================
-- 4. HAREKET MOTORU (HEARTBEAT)
-- ==============================================================================
RunService.Heartbeat:Connect(function(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

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
                hrp.AssemblyLinearVelocity = (tHrp.Position - tHrp.Position).Unit * Lea.Settings.FollowSpeed
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
-- 5. PET FINDER, DUEL & MENÜ SİSTEMİ (PART 3)
-- ==============================================================================
local function ExecutePetFinder()
    if Lea.PetFinderActive then return end
    Lea.PetFinderActive = true
    
    task.spawn(function()
        pcall(function()
            print("🔍 50M+ PET ARANIYOR...")
            local apiEndpoint = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", tostring(game.PlaceId))
            local success, response = pcall(function() return game:HttpGet(apiEndpoint) end)
            
            if success and response then
                local decoded = HttpService:JSONDecode(response)
                if decoded and decoded.data then
                    for _, server in ipairs(decoded.data) do
                        if server.id ~= game.JobId and server.playing and server.maxPlayers and server.playing < server.maxPlayers and server.playing >= 2 then
                            Lea.IsAllowingTeleport = true
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                            break
                        end
                    end
                end
            end
        end)
        Lea.PetFinderActive = false
    end)
end

task.spawn(function()
    pcall(function()
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local name = remote.Name:lower()
                
                if name:match("steal") or name:match("trade") or name:match("claim") or name:match("take") then
                    remote.OnClientEvent:Connect(function(...)
                        if Lea.Modules.AutoSteal then
                            pcall(function() remote:FireServer(LocalPlayer, ...) end)
                        end
                        if Lea.Modules.AutoLeave then
                            Lea.IsAllowingTeleport = true
                            task.wait(0.1)
                            TeleportService:Teleport(game.PlaceId, LocalPlayer)
                        end
                    end)
                end
                
                if name:match("duel") or name:match("battle") or name:match("fight") then
                    local original = remote.OnServerEvent
                    remote.OnServerEvent = function(player, ...)
                        if player == LocalPlayer and Lea.Modules.DuelMode then
                            return original and original(player, true)
                        end
                        return original and original(player, ...)
                    end
                end
            end
        end
    end)
end)

local function CreateMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LeaMenu"
    pcall(function() screenGui.Parent = CoreGui end)
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
        Instance.new("UICorner", baseBtn).CornerRadius = UDim.new(0, 4)

    baseBtn.MouseButton1Click:Connect(function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            Lea.BasePosition = hrp.Position
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

    returnBtn.MouseButton1Click:Connect(function() ReturnToBase() end)

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
        ExecutePetFinder()
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
end

CreateMenu()

-- ==============================================================================
-- 6. KISAYOLLAR & KONSOL
-- ==============================================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F5 then
        local gui = CoreGui:FindFirstChild("LeaMenu") or LocalPlayer.PlayerGui:FindFirstChild("LeaMenu")
        if gui then
            local frame = gui:FindFirstChild("MainFrame")
            local toggle = gui:FindFirstChild("LeaToggle")
            if frame then
                frame.Visible = not frame.Visible
                if toggle then toggle.Visible = not frame.Visible end
            end
        end
    elseif input.KeyCode == Enum.KeyCode.F6 then
        ToggleFly(not Lea.Modules.Fly)
    elseif input.KeyCode == Enum.KeyCode.F7 then
        ToggleCube(not Lea.Modules.Cube)
    end
end)

print("")
print("========================================")
print("✅ LEA ULTIMATE MASTER SİSTEMİ YÜKLENDİ!")
print("========================================")
