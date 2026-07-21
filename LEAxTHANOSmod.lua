-- ==============================================================================
-- LEA MOD - ULTIMATE ENTERPRISE PRODUCTION ENGINE V4.0
-- FULL ARCHITECTURAL SUITE WITH ADVANCED BYPASS & CUSTOM #LEA KICK HOOKS
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

print("⚡ [LEA CORE V4.0]: Enterprise Master Initialization Sequence Started...")

getgenv().LeaState = getgenv().LeaState or {
    Version = "4.0.0-PROD",
    Modules = {
        Cube = false,
        AutoHop = false,
        AntiCheatKick = true,
        AntiReset = true,
        AntiKickCrash = true,
        ESP = false
    },
    Settings = {
        MinServerPlayers = 1,
        MaxServerPlayers = 15,
        ScanInterval = 0.05
    },
    BasePosition = nil,
    IsReturning = false,
    ActiveConnections = {}
}

local Lea = getgenv().LeaState

-- Clear old background event connections cleanly
for _, connection in pairs(Lea.ActiveConnections) do
    if typeof(connection) == "RBXScriptConnection" then
        connection:Disconnect()
    end
end
Lea.ActiveConnections = {}

-- ==============================================================================
-- 1. ADVANCED BYPASS & METATABLE SECURITY HOOKS (ENTERPRISE GRADE)
-- ==============================================================================
pcall(function()
    local metatable = getrawmetatable(game)
    setreadonly(metatable, false)
    local originalNamecall = metatable.__namecall
    
    metatable.__namecall = newcclosure(function(self, ...)
        local methodName = getnamecallmethod()
        local arguments = {...}
        
        if (methodName == "Kick" or methodName == "Ban" or methodName == "ClientKick") and Lea.Modules.AntiKickCrash then
            print("🛡️ [SECURITY BYPASS]: Blocked external malicious server kick attempt.")
            return
        end
        
        return originalNamecall(self, unpack(arguments))
    end)
    setreadonly(metatable, true)
end)

-- ==============================================================================
-- 2. CUSTOM #LEA ANTI-CHEAT KICK SIMULATOR & PET DETECTION ENGINE
-- ==============================================================================
local function TriggerCustomLeaAntiCheatKick()
    pcall(function()
        if not Lea.Modules.AntiCheatKick then return end
        
        -- Custom Anti-Cheat kick message containing #LEA tag
        local customReason = "\n[#LEA - Security Protocol]: Unauthorized asset acquisition detected. Connection terminated safely by #LEA Anti-Cheat Matrix."
        
        print("🚨 [DETECTION]: Pet theft confirmed! Triggering #LEA protocol...")
        
        -- Safe immediate client termination display with #LEA branding
        LocalPlayer:Kick(customReason)
    end)
end

-- ==============================================================================
-- 3. ANTI-RESET PROTECTION SYSTEM
-- ==============================================================================
local function InitializeAntiReset(character)
    pcall(function()
        local humanoid = character:WaitForChild("Humanoid", 5)
        if humanoid then
            humanoid.Died:Connect(function()
                if Lea.Modules.AntiReset then
                    print("🛡️ [ANTI-RESET]: Character death intercepted, maintaining operational state.")
                end
            end)
            
            humanoid.StateChanged:Connect(function(_, newStateType)
                if Lea.Modules.AntiReset and newStateType == Enum.HumanoidStateType.Dead then
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                end
            end)
        end
    end)
end

if LocalPlayer.Character then
    InitializeAntiReset(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(InitializeAntiReset)

-- ==============================================================================
-- 4. CUBE HITBOX & DYNAMIC BASE NAVIGATION SUBSYSTEM
-- ==============================================================================
local cubeHitboxPart = nil

local function ToggleCubeHitbox(state)
    Lea.Modules.Cube = state
    pcall(function()
        if state then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and not cubeHitboxPart then
                cubeHitboxPart = Instance.new("Part")
                cubeHitboxPart.Name = "LeaEnterpriseHitboxNode"
                cubeHitboxPart.Size = Vector3.new(3.2, 0.6, 3.2)
                cubeHitboxPart.Anchored = false
                cubeHitboxPart.CanCollide = true
                cubeHitboxPart.Massless = true
                cubeHitboxPart.Material = Enum.Material.Neon
                cubeHitboxPart.Color = Color3.fromRGB(0, 255, 200)
                cubeHitboxPart.Transparency = 0.2
                cubeHitboxPart.Parent = Workspace
                
                local weldConstraint = Instance.new("WeldConstraint")
                weldConstraint.Part0 = hrp
                weldConstraint.Part1 = cubeHitboxPart
                weldConstraint.Parent = cubeHitboxPart
                cubeHitboxPart.CFrame = hrp.CFrame * CFrame.new(0, -3.5, 0)
            end
        else
            if cubeHitboxPart then
                cubeHitboxPart:Destroy()
                cubeHitboxPart = nil
            end
        end
    end)
end

local function SaveBaseCoordinates()
    pcall(function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            Lea.BasePosition = hrp.Position
            print("📍 [BASE MANAGER]: Coordinates successfully saved at -> " .. tostring(Lea.BasePosition))
        end
    end)
end

local function ReturnToBaseCoordinates()
    if not Lea.BasePosition then
        print("⚠️ [BASE MANAGER]: No baseline coordinate vector found!")
        return
    end
    Lea.IsReturning = true
    task.spawn(function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        while hrp and Lea.IsReturning do
            local currentDistance = (hrp.Position - Lea.BasePosition).Magnitude
            if currentDistance < 4 then
                Lea.IsReturning = false
                break
            end
            hrp.CFrame = CFrame.new(hrp.Position:Lerp(Lea.BasePosition, 0.3))
            task.wait()
        end
    end)
end

-- ==============================================================================
-- 5. INSTANT SERVER HOPPER & PUBLIC INSTANCE SCANNER
-- ==============================================================================
local function ExecuteInstantServerHop()
    pcall(function()
        print("🚀 [SERVER HOPPER]: Scanning public server instances...")
        local viableServers = {}
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)
        
        if success and result and result.data then
            for _, serverData in ipairs(result.data) do
                if serverData.playing and serverData.playing >= Lea.Settings.MinServerPlayers and serverData.playing < serverData.maxPlayers then
                    table.insert(viableServers, serverData.id)
                end
            end
        end
        
        if #viableServers > 0 then
            local selectedServer = viableServers[math.random(1, #viableServers)]
            TeleportService:TeleportToPlaceInstance(game.PlaceId, selectedServer, LocalPlayer)
        end
    end)
end

-- ==============================================================================
-- 6. CONTINUOUS HEARTBEAT MONITORING ENGINE
-- ==============================================================================
table.insert(Lea.ActiveConnections, RunService.Heartbeat:Connect(function()
    pcall(function()
        -- Auto-Hop Scanner for high-value targets (Steal a Brainrot loop check)
        if Lea.Modules.AutoHop then
            for _, workspaceObject in ipairs(Workspace:GetChildren()) do
                if workspaceObject:IsA("Model") and (workspaceObject.Name:find("Secret") or workspaceObject.Name:find("Brainrot") or workspaceObject.Name:find("Mythic")) then
                    ExecuteInstantServerHop()
                    break
                end
            end
        end

        -- Check character inventory/tools for pet acquisition event to trigger #LEA kick
        local character = LocalPlayer.Character
        if character and Lea.Modules.AntiCheatKick then
            for _, itemInstance in ipairs(character:GetChildren()) do
                if itemInstance:IsA("Tool") and (itemInstance.Name:find("Pet") or itemInstance.Name:find("Brainrot") or itemInstance.Name:find("Secret")) then
                    TriggerCustomLeaAntiCheatKick()
                    break
                end
            end
        end
    end)
end))

-- ==============================================================================
-- 7. PRODUCTION-READY MOBILE INTERFACE (GUI CONSTRUCTOR)
-- ==============================================================================
local function BuildEnterpriseMobileUI()
    pcall(function()
        if CoreGui:FindFirstChild("LeaEnterpriseMatrixGui") then
            CoreGui.LeaEnterpriseMatrixGui:Destroy()
        end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "LeaEnterpriseMatrixGui"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = CoreGui

        local mainContainer = Instance.new("Frame")
        mainContainer.Name = "MainContainer"
        mainContainer.Size = UDim2.new(0, 190, 0, 270)
        mainContainer.Position = UDim2.new(0.5, -95, 0.4, -135)
        mainContainer.BackgroundColor3 = Color3.fromRGB(10, 13, 18)
        mainContainer.BackgroundTransparency = 0.1
        mainContainer.Active = true
        mainContainer.Draggable = true
        mainContainer.Parent = screenGui

        local cornerRadius = Instance.new("UICorner")
        cornerRadius.CornerRadius = UDim.new(0, 8)
        cornerRadius.Parent = mainContainer

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -30, 0, 26)
        titleLabel.Position = UDim2.new(0, 8, 0, 4)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = "LEA MOD - #LEA PRO"
        titleLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
        titleLabel.TextSize = 11
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.Parent = mainContainer

        local closeButton = Instance.new("TextButton")
        closeButton.Size = UDim2.new(0, 20, 0, 20)
        closeButton.Position = UDim2.new(1, -24, 0, 4)
        closeButton.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        closeButton.Text = "X"
        closeButton.TextColor3 = Color3.new(1, 1, 1)
        closeButton.TextSize = 9
        closeButton.Parent = mainContainer
        Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, 4)

        local verticalOffset = 34
        local function CreateFeatureToggle(buttonText, callbackFunction)
            local toggleButton = Instance.new("TextButton")
            toggleButton.Size = UDim2.new(1, -16, 0, 28)
            toggleButton.Position = UDim2.new(0, 8, 0, verticalOffset)
            toggleButton.BackgroundColor3 = Color3.fromRGB(24, 30, 42)
            toggleButton.Text = buttonText
            toggleButton.TextColor3 = Color3.fromRGB(220, 220, 220)
            toggleButton.TextSize = 9
            toggleButton.Font = Enum.Font.GothamMedium
            toggleButton.Parent = mainContainer
            Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 5)

            local isActiveState = false
            toggleButton.MouseButton1Click:Connect(function()
                isActiveState = not isActiveState
                toggleButton.BackgroundColor3 = isActiveState and Color3.fromRGB(0, 160, 110) or Color3.fromRGB(24, 30, 42)
                callbackFunction(isActiveState)
            end)
            verticalOffset = verticalOffset + 32
        end

        local function CreateActionTrigger(buttonText, callbackFunction)
            local actionButton = Instance.new("TextButton")
            actionButton.Size = UDim2.new(1, -16, 0, 28)
            actionButton.Position = UDim2.new(0, 8, 0, verticalOffset)
            actionButton.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
            actionButton.Text = buttonText
            actionButton.TextColor3 = Color3.new(1, 1, 1)
            actionButton.TextSize = 9
            actionButton.Font = Enum.Font.GothamBold
            actionButton.Parent = mainContainer
            Instance.new("UICorner", actionButton).CornerRadius = UDim.new(0, 5)

            actionButton.MouseButton1Click:Connect(callbackFunction)
            verticalOffset = verticalOffset + 32
        end

        CreateFeatureToggle("Küp Hitbox Sistemi", function(val) ToggleCubeHitbox(val) end)
        CreateFeatureToggle("#LEA Anti-Cheat Kick", function(val) Lea.Modules.AntiCheatKick = val end)
        CreateFeatureToggle("Auto-Hop & Server Finder", function(val) Lea.Modules.AutoHop = val end)
        CreateFeatureToggle("Anti-Reset Koruması", function(val) Lea.Modules.AntiReset = val end)
        
        CreateActionTrigger("Base (Üs) Kaydet", function() SaveBaseCoordinates() end)
        CreateActionTrigger("Base'e Işınlan", function() ReturnBaseCoordinates() end)

        local toggleIcon = Instance.new("TextButton")
        toggleIcon.Size = UDim2.new(0, 36, 0, 18)
        toggleIcon.Position = UDim2.new(1, -40, 0, 4)
        toggleIcon.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
        toggleIcon.Text = "LEA"
        toggleIcon.TextColor3 = Color3.new(1, 1, 1)
        toggleIcon.TextSize = 9
        toggleIcon.Visible = false
        toggleIcon.Parent = screenGui
        Instance.new("UICorner", toggleIcon).CornerRadius = UDim.new(0, 4)

        closeButton.MouseButton1Click:Connect(function()
            mainContainer.Visible = false
            toggleIcon.Visible = true
        end)

        toggleIcon.MouseButton1Click:Connect(function()
            mainContainer.Visible = true
            toggleIcon.Visible = false
        end)
    end)
end

BuildEnterpriseMobileUI()
print("✅ [LEA CORE V4.0]: Enterprise deployment complete, all modules fully loaded.")
