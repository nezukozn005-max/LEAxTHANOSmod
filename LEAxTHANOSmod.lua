-- ============================================
-- LEA MOD V7.0 ENTERPRISE - HYBRID TELEMETRY & ROUTING CORE
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

print("⚡ LEA V7.0 Hybrid Telemetry & Routing Core Initialized")

getgenv().LeaSecure = {
    AntiKick = true,
    AntiReset = true,
    AntiVoid = true
}

getgenv().LeaEngine = {
    CubeActive = false,
    Cubes = {},
    LastCubeTime = 0,
    ScanningActive = false,
    AutoRouteActive = false,
    VerifiedServers = {},
    ActiveConnections = {}
}

local SEC = getgenv().LeaSecure
local ENG = getgenv().LeaEngine

local function TrackConnection(conn)
    table.insert(ENG.ActiveConnections, conn)
    return conn
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if SEC.AntiKick then
        if (method == "Kick" or method == "kick") and (self == LocalPlayer or self:IsA("Player")) then
            return nil
        end
        if self == LocalPlayer and (method == "Destroy" or method == "Remove") then
            return nil
        end
    end
    return oldNamecall(self, ...)
end)

pcall(function()
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "isLoaded") then
            rawset(v, "isLoaded", true)
        end
    end
end)

local function ApplyAntiReset(char)
    if not SEC.AntiReset then return end
    pcall(function()
        local hum = char:WaitForChild("Humanoid", 5)
        if not hum then return end
        hum.BreakJointsOnDeath = false
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        TrackConnection(hum.HealthChanged:Connect(function(hp)
            if hp <= 0 and SEC.AntiReset then
                hum.Health = hum.MaxHealth
            end
        end))
    end)
end
TrackConnection(LocalPlayer.CharacterAdded:Connect(ApplyAntiReset))
if LocalPlayer.Character then ApplyAntiReset(LocalPlayer.Character) end

local lastSafePosition = Vector3.new(0, 10, 0)
TrackConnection(RunService.Heartbeat:Connect(function()
    if not SEC.AntiVoid then return end
    pcall(function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if hrp.Position.Y < -500 then
                hrp.CFrame = CFrame.new(lastSafePosition + Vector3.new(0, 10, 0))
                hrp.AssemblyLinearVelocity = Vector3.zero
            else
                lastSafePosition = hrp.Position
            end
        end
    end)
end))

local function SafeHttpGet(url)
    local success, response = pcall(function()
        if syn and syn.request then
            local req = syn.request({Url = url, Method = "GET"})
            if req and req.Body then return req.Body end
        elseif request then
            local req = request({Url = url, Method = "GET"})
            if req and req.Body then return req.Body end
        elseif http and http.request then
            local req = http.request({Url = url, Method = "GET"})
            if req and req.Body then return req.Body end
        end
        return game:HttpGet(url)
    end)
    if success and response then return response end
    return nil
end

local function StartServerDiagnostics(uiUpdateCallback)
    if ENG.ScanningActive then return end
    ENG.ScanningActive = true
    print("🔍 [LEA DIAGNOSTICS] Initializing hybrid instance scanner & heuristic parser...")

    task.spawn(function()
        local cursor = ""
        while ENG.ScanningActive do
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
            if cursor ~= "" then
                url = url .. "&cursor=" .. cursor
            end

            local rawData = SafeHttpGet(url)
            local success, result = pcall(function()
                return HttpService:JSONDecode(rawData)
            end)

            if success and result and result.data then
                for _, server in ipairs(result.data) do
                    if server.id ~= game.JobId and server.playing > 0 and server.playing < server.maxPlayers then
                        local entryKey = server.id
                        local exists = false
                        for _, s in ipairs(ENG.VerifiedServers) do
                            if s.id == entryKey then exists = true break end
                        end

                        if not exists then
                            local loadFactor = math.clamp(math.floor((server.playing / server.maxPlayers) * 100), 1, 100)
                            local heuristicRating = (server.playing >= 5 and server.playing <= (server.maxPlayers - 2)) and "Optimal Density" else "Standard Density"
                            
                            local serverData = {
                                id = server.id,
                                name = "Instance [" .. server.playing .. "/" .. server.maxPlayers .. "]",
                                status = heuristicRating,
                                load = loadFactor,
                                time = os.date("%H:%M:%S")
                            }
                            table.insert(ENG.VerifiedServers, serverData)
                            if uiUpdateCallback then
                                pcall(function() uiUpdateCallback(serverData) end)
                            end

                            if ENG.AutoRouteActive and server.playing >= 6 and server.playing <= (server.maxPlayers - 1) then
                                print("⚡ [AUTO-ROUTE] Heuristic threshold matched. Routing to instance: " .. server.id)
                                ENG.AutoRouteActive = false
                                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                                break
                            end
                        end
                    end
                end
                cursor = result.nextPageCursor or ""
                if cursor == "" then
                    task.wait(10.0)
                end
            else
                task.wait(5.0)
            end
            task.wait(3.0)
        end
    end)
end

function StopServerDiagnostics()
    ENG.ScanningActive = false
    ENG.AutoRouteActive = false
    print("🛑 [LEA DIAGNOSTICS] Hybrid scanning halted.")
end

local function ClearCubes()
    for _, cube in ipairs(ENG.Cubes) do
        if cube and cube.Parent then
            pcall(function() cube:Destroy() end)
        end
    end
    ENG.Cubes = {}
end

local function CreateCube(pos)
    if #ENG.Cubes > 10 then
        local oldCube = table.remove(ENG.Cubes, 1)
        if oldCube and oldCube.Parent then
            pcall(function() oldCube:Destroy() end)
        end
    end
    local cube = Instance.new("Part")
    cube.Size = Vector3.new(4, 0.4, 4)
    cube.Position = pos
    cube.Anchored = true
    cube.CanCollide = true
    cube.Transparency = 0.75
    cube.Material = Enum.Material.SmoothPlastic
    cube.Color = Color3.fromRGB(0, 160, 255)
    cube.Parent = Workspace
    table.insert(ENG.Cubes, cube)
    
    task.delay(4.5, function()
        if cube and cube.Parent then
            pcall(function() cube:Destroy() end)
            for i, v in ipairs(ENG.Cubes) do
                if v == cube then
                    table.remove(ENG.Cubes, i)
                    break
                end
            end
        end
    end)
end

local lastFrameUpdate = 0
TrackConnection(RunService.Heartbeat:Connect(function(dt)
    if tick() - lastFrameUpdate < 0.02 then return end
    lastFrameUpdate = tick()

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end

    local velocity = hrp.AssemblyLinearVelocity
    local currentTime = tick()

    if ENG.CubeActive then
        if (velocity.Y < -2.5 or hum:GetState() == Enum.HumanoidStateType.Jumping or hum:GetState() == Enum.HumanoidStateType.Freefall) and (currentTime - ENG.LastCubeTime > 0.45) then
            CreateCube(hrp.Position - Vector3.new(0, 3.1, 0))
            ENG.LastCubeTime = currentTime
        elseif hum.MoveDirection.Magnitude > 0.1 and velocity.Magnitude > 6 and (currentTime - ENG.LastCubeTime > 0.5) then
            local lookVector = hrp.CFrame.LookVector
            CreateCube(hrp.Position + Vector3.new(lookVector.X * 3, -2.7, lookVector.Z * 3))
            ENG.LastCubeTime = currentTime
        end
    end
end))

local function BuildServerWindow()
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    local old = pg:FindFirstChild("LeaServerWindow")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "LeaServerWindow"
    gui.Parent = pg

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 230, 0, 280)
    frame.Position = UDim2.new(0.5, -115, 0.25, 0)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    frame.BackgroundTransparency = 0.1
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    title.Text = "🌐 HYBRID INSTANCE ROUTER"
    title.TextColor3 = Color3.fromRGB(0, 220, 255)
    title.TextSize = 10
    title.Font = Enum.Font.GothamBold
    title.Parent = frame

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -80)
    scroll.Position = UDim2.new(0, 5, 0, 35)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.Parent = scroll

    local autoBtn = Instance.new("TextButton")
    autoBtn.Size = UDim2.new(1, -10, 0, 32)
    autoBtn.Position = UDim2.new(0, 5, 1, -40)
    autoBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    autoBtn.Text = "AUTO-ROUTE: OFF"
    autoBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    autoBtn.TextSize = 10
    autoBtn.Font = Enum.Font.GothamBold
    autoBtn.Parent = frame

    autoBtn.MouseButton1Click:Connect(function()
        ENG.AutoRouteActive = not ENG.AutoRouteActive
        autoBtn.Text = ENG.AutoRouteActive and "AUTO-ROUTE: ACTIVE" or "AUTO-ROUTE: OFF"
        autoBtn.TextColor3 = ENG.AutoRouteActive and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 100, 100)
        print("⚡ [AUTO-ROUTE] Status toggled: " .. tostring(ENG.AutoRouteActive))
    end)

    local function AddEntry(data)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -4, 0, 38)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        btn.Text = data.name .. " | " .. data.status .. "\nLoad: " + data.load + "% [" .. data.time .. "]"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 9
        btn.Font = Enum.Font.Gotham
        btn.Parent = scroll

        btn.MouseButton1Click:Connect(function()
            print("⚡ [TELEPORT] Connecting to instance: " .. data.id)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, data.id, LocalPlayer)
        end)
    end

    for _, s in ipairs(ENG.VerifiedServers) do
        AddEntry(s)
    end

    StartServerDiagnostics(function(newEntry)
        AddEntry(newEntry)
    end)
end

local function BuildUI()
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    local old = pg:FindFirstChild("LeaUI")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "LeaUI"
    gui.Parent = pg

    local cont = Instance.new("Frame")
    cont.Size = UDim2.new(0, 48, 0, 80)
    cont.Position = UDim2.new(1, -54, 0.002, 0)
    cont.BackgroundTransparency = 1
    cont.Active = true
    cont.Draggable = true
    cont.Parent = gui

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 3)
    list.Parent = cont

    local function AddButton(text, toggle, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 44, 0, 24)
        b.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Text = text
        b.TextSize = 6
        b.Font = Enum.Font.GothamBold
        b.Parent = cont

        if toggle then
            local state = false
            b.MouseButton1Click:Connect(function()
                state = not state
                b.BackgroundColor3 = state and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(20, 20, 25)
                callback(state)
            end)
        else
            b.MouseButton1Click:Connect(function()
                b.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
                task.delay(0.12, function() b.BackgroundColor3 = Color3.fromRGB(20, 20, 25) end)
                callback()
            end)
        end
    end

    AddButton("CUBE", true, function(v) ENG.CubeActive = v end)
    AddButton("SERVERS", false, function() BuildServerWindow() end)
end

BuildUI()
BuildServerWindow()
print("✅ LEA V7.0 Hybrid Telemetry & Routing Core Ready.")

getgenv().LeaKill = function()
    StopServerDiagnostics()
    ClearCubes()
    for _, conn in ipairs(ENG.ActiveConnections) do
        pcall(function() conn:Disconnect() end)
    end
    ENG.ActiveConnections = {}
    for k, v in pairs(ENG) do
        if type(v) == "boolean" then ENG[k] = false end
    end
    local ui = LocalPlayer.PlayerGui:FindFirstChild("LeaUI")
    if ui then ui:Destroy() end
    local sWin = LocalPlayer.PlayerGui:FindFirstChild("LeaServerWindow")
    if sWin then sWin:Destroy() end
    print("LEA V7.0 Terminated & Cleaned.")
end
