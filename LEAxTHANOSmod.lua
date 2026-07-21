-- ==============================================================================
-- LEA MOD - ENTERPRISE PRODUCTION CONSOLIDATED ENGINE V3.5
-- FULLY OPTIMIZED FOR MOBILE ARCHITECTURE & ASYNCHRONOUS EXECUTIONS
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

print("⚡ [LEA ENTERPRISE CORE]: Master initialization sequence started...")

getgenv().LeaState = getgenv().LeaState or {
    Version = "3.5.0-PROD",
    Modules = {
        Cube = false,
        Fly = false,
        Follow = false,
        ServerFinder = false,
        AutoHop = false,
        PetStealth = false,
        AntiKickCrash = true,
        ESP = false
    },
    Settings = {
        FlySpeed = 45,
        FollowSpeed = 30,
        ReturnSpeed = 40,
        MinServerPlayers = 1,
        MaxServerPlayers = 12,
        ScanInterval = 0.05,
        TargetThreshold = 10000000
    },
    BasePosition = nil,
    IsReturning = false,
    ActiveConnections = {}
}

local Lea = getgenv().LeaState

-- Clear old connections if re-executed
for _, conn in pairs(Lea.ActiveConnections) do
    if typeof(conn) == "RBXScriptConnection" then
        conn:Disconnect()
    end
end
Lea.ActiveConnections = {}

-- ==============================================================================
-- 1. ADVANCED BYPASS & METATABLE SECURITY HOOKS
-- ==============================================================================
pcall(function()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if (method == "Kick" or method == "Ban" or method == "ClientKick") and Lea.Modules.AntiKickCrash then
            print("🛡️ [SECURITY BYPASS]: Intercepted malicious kick/ban execution attempt.")
            return
        end
        return oldNamecall(self, unpack(args))
    end)
    setreadonly(mt, true)
end)

-- ==============================================================================
-- 2. KUBE ENGINE & DYNAMIC BASE NAVIGATION SUBSYSTEM
-- ==============================================================================
local cubePart = nil

local function ToggleCube(state)
    Lea.Modules.Cube = state
    pcall(function()
        if state then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and not cubePart then
                cubePart = Instance.new("Part")
                cubePart.Name = "LeaEnterpriseCubeNode"
                cubePart.Size = Vector3.new(2.8, 0.45, 2.8)
                cubePart.Anchored = false
                cubePart.CanCollide = false
                cubePart.Massless = true
                cubePart.Material = Enum.Material.Neon
                cubePart.Color = Color3.fromRGB(0, 255, 200)
                cubePart.Transparency = 0.25
                cubePart.Parent = Workspace
            end
        else
            if cubePart then
                cubePart:Destroy()
                cubePart = nil
            end
        end
    end)
end

local function SetBasePosition()
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            Lea.BasePosition = hrp.Position
            print("📍 [BASE MANAGER]: Coordinates locked at: " .. tostring(Lea.BasePosition))
        end
    end)
end

local function ReturnToBasePosition()
    if not Lea.BasePosition then
        print("⚠️ [BASE MANAGER]: No baseline vector established!")
        return
    end
    Lea.IsReturning = true
    task.spawn(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        while hrp and Lea.IsReturning do
            local distance = (hrp.Position - Lea.BasePosition).Magnitude
            if distance < 4 then
                Lea.IsReturning = false
                break
            end
            hrp.CFrame = CFrame.new(hrp.Position:Lerp(Lea.BasePosition, 0.20))
            task.wait()
        end
    end)
end

-- ==============================================================================
-- 3. HIGH-PERFORMANCE SERVER HOPPER & PET TRACKER (STEAL A BRAINROT ENGINE)
-- ==============================================================================
local function ExecuteInstantServerHop()
    pcall(function()
        print("🚀 [SERVER HOPPER]: High-value asset detected! Scanning public instances...")
        local viableServers = {}
        local cursor = ""
        
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)
        
        if success and result and result.data then
            for _, s in ipairs(result.data) do
                if s.playing and s.playing >= Lea.Settings.MinServerPlayers and s.playing < s.maxPlayers then
                    table.insert(viableServers, s.id)
                end
            end
        end
        
        if #viableServers > 0 then
            local targetInstance = viableServers[math.random(1, #viableServers)]
            print("🌐 [SERVER HOPPER]: Teleporting to instance ID -> " .. tostring(targetInstance))
            TeleportService:TeleportToPlaceInstance(game.PlaceId, targetInstance, LocalPlayer)
        else
            print("⚠️ [SERVER HOPPER]: Retrying server query pool...")
        end
    end)
end

-- ==============================================================================
-- 4. PET STEALTH & 180 DEGREE INVERSION EXPLOIT SUBSYSTEM
-- ==============================================================================
table.insert(Lea.ActiveConnections, RunService.Heartbeat:Connect(function()
    pcall(function()
        -- Cube positioning logic
        if Lea.Modules.Cube and cubePart then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hrp and hum then
                local moving = (hum.MoveDirection.Magnitude > 0.05)
                local jumping = (hum:GetState() == Enum.HumanoidStateType.Jumping)
                if moving or jumping then
                    cubePart.CFrame = hrp.CFrame * CFrame.new(0, -3.4, 0)
                    cubePart.Transparency = 0.25
                else
                    cubePart.Transparency = 1
                end
            end
        end

        -- Pet Stealth & Inversion Bug Mechanics
        if Lea.Modules.PetStealth then
            local char = LocalPlayer.Character
            if char then
                for _, asset in ipairs(char:GetChildren()) do
                    if asset:IsA("Tool") and (asset.Name:find("Pet") or asset.Name:find("Brainrot") or asset.Name:find("Secret") or asset.Name:find("Gold")) then
                        local handle = asset:FindFirstChild("Handle") or asset:FindFirstChild("Part")
                        if handle then
                            handle.CFrame = handle.CFrame * CFrame.Angles(0, math.rad(180), 0) + Vector3.new(0, -10000, 0)
                            handle.Transparency = 1
                            handle.CanCollide = false
                        end
                    end
                end
            end
        end

        -- Auto-Hop Scanning Engine Loop
        if Lea.Modules.AutoHop then
            for _, entity in ipairs(Workspace:GetChildren()) do
                if entity:IsA("Model") and (entity.Name:find("Secret") or entity.Name:find("Brainrot") or entity.Name:find("Mythic")) then
                    print("💎 [ASSET ACQUIRED]: Triggering instantaneous jump procedure.")
                    ExecuteInstantServerHop()
                    break
                end
            end
        end
    end)
end))

-- ==============================================================================
-- 5. ENTERPRISE MOBILE UI FRAMEWORK CONSTRUCTOR
-- ==============================================================================
local function ConstructEnterpriseUI()
    pcall(function()
        if CoreGui:FindFirstChild("LeaEnterpriseMasterGui") then
            CoreGui.LeaEnterpriseMasterGui:Destroy()
        end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "LeaEnterpriseMasterGui"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = CoreGui

        -- Header Label
        local header = Instance.new("TextLabel")
        header.Size = UDim2.new(0, 240, 0, 28)
        header.Position = UDim2.new(0.5, -120, 0, 8)
        header.BackgroundTransparency = 1
        header.Text = "LEA MOD [ENTERPRISE CORE]"
        header.TextColor3 = Color3.fromRGB(0, 255, 200)
        header.TextSize = 14
        header.Font = Enum.Font.GothamBold
        header.Parent = screenGui

        -- Main Container Frame
        local mainFrame = Instance.new("Frame")
        mainFrame.Name = "MasterContainer"
        mainFrame.Size = UDim2.new(0, 260, 0, 360)
        mainFrame.Position = UDim2.new(0.5, -130, 0.5, -180)
        mainFrame.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
        mainFrame.BackgroundTransparency = 0.1
        mainFrame.Active = true
        mainFrame.Draggable = true
        mainFrame.Parent = screenGui

        Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(0, 255, 200)
        stroke.Transparency = 0.5
        stroke.Thickness = 1.5
        stroke.Parent = mainFrame

        -- Top Action Control Bar
        local topBar = Instance.new("Frame")
        topBar.Size = UDim2.new(1, 0, 0, 36)
        topBar.BackgroundColor3 = Color3.fromRGB(20, 24, 32)
        topBar.Parent = mainFrame
        Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 10)

        local titleText = Instance.new("TextLabel")
        titleText.Size = UDim2.new(1, -40, 1, 0)
        titleText.Position = UDim2.new(0, 12, 0, 0)
        titleText.BackgroundTransparency = 1
        titleText.Text = "Control Matrix"
        titleText.TextColor3 = Color3.fromRGB(240, 240, 240)
        titleText.TextSize = 12
        titleText.Font = Enum.Font.GothamBold
        titleText.TextXAlignment = Enum.TextXAlignment.Left
        titleText.Parent = topBar

        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 24, 0, 24)
        closeBtn.Position = UDim2.new(1, -28, 0, 6)
        closeBtn.BackgroundColor3 = Color3.fromRGB(200, 45, 45)
        closeBtn.Text = "X"
        closeBtn.TextColor3 = Color3.new(1, 1, 1)
        closeBtn.TextSize = 10
        closeBtn.Parent = topBar
        Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

        -- Scrollable Component Container for Options
        local scrollBox = Instance.new("ScrollingFrame")
        scrollBox.Size = UDim2.new(1, -16, 1, -50)
        scrollBox.Position = UDim2.new(0, 8, 0, 42)
        scrollBox.BackgroundTransparency = 1
        scrollBox.BorderSizePixel = 0
        scrollBox.CanvasSize = UDim2.new(0, 0, 0, 340)
        scrollBox.Parent = mainFrame

        local listLayout = Instance.new("UIListLayout")
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Padding = UDim.new(0, 8)
        listLayout.Parent = scrollBox

        -- Helper Function for Advanced Interactive Toggles
        local function BuildFeatureButton(name, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 38)
            btn.BackgroundColor3 = Color3.fromRGB(26, 32, 44)
            btn.Text = name .. " -> [KAPALI]"
            btn.TextColor3 = Color3.fromRGB(220, 220, 220)
            btn.TextSize = 11
            btn.Font = Enum.Font.GothamMedium
            btn.Parent = scrollBox
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

            local state = false
            btn.MouseButton1Click:Connect(function()
                state = not state
                btn.Text = name .. " -> " .. (state and "[AÇIK]" or "[KAPALI]")
                btn.BackgroundColor3 = state and Color3.fromRGB(0, 160, 110) or Color3.fromRGB(26, 32, 44)
                callback(state)
            end)
        end

        -- Helper Function for Standard Execution Actions
        local function BuildActionTrigger(name, callback)
            local actBtn = Instance.new("TextButton")
            actBtn.Size = UDim2.new(1, 0, 0, 38)
            actBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
            actBtn.Text = name
            actBtn.TextColor3 = Color3.new(1, 1, 1)
            actBtn.TextSize = 11
            actBtn.Font = Enum.Font.GothamBold
            actBtn.Parent = scrollBox
            Instance.new("UICorner", actBtn).CornerRadius = UDim.new(0, 6)

            actBtn.MouseButton1Click:Connect(callback)
        end

        -- Populate UI Panels
        BuildFeatureButton("Küp Node Sistemi", function(v) ToggleCube(v) end)
        BuildFeatureButton("Pet Stealth / 180° Bug", function(v) Lea.Modules.PetStealth = v end)
        BuildFeatureButton("Auto-Hop & Server Finder", function(v) Lea.Modules.AutoHop = v end)
        BuildFeatureButton("Anti-Kick / Anti-Crash", function(v) Lea.Modules.AntiKickCrash = v end)
        
        BuildActionTrigger("Üs Konumunu Kaydet (Set Base)", function() SetBasePosition() end)
        BuildActionTrigger("Üsse Işınlan / Dön (Return)", function() ReturnToBasePosition() end)
        BuildActionTrigger("Manuel Server Değiştir (Hop)", function() ExecuteInstantServerHop() end)

        -- Minimized Toggle Floating Icon
        local toggleIcon = Instance.new("TextButton")
        toggleIcon.Size = UDim2.new(0, 48, 0, 24)
        toggleIcon.Position = UDim2.new(1, -55, 0, 6)
        toggleIcon.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
        toggleIcon.Text = "LEA"
        toggleIcon.TextColor3 = Color3.new(1, 1, 1)
        toggleIcon.TextSize = 10
        toggleIcon.Font = Enum.Font.GothamBold
        toggleIcon.Visible = false
        toggleIcon.Parent = screenGui
        Instance.new("UICorner", toggleIcon).CornerRadius = UDim.new(0, 6)

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

ConstructEnterpriseUI()
print("✅ [LEA ENTERPRISE CORE]: All subsystems fully loaded and operational.")
