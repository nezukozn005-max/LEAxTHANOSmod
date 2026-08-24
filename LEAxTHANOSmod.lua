-- ============================================
-- LEA MOD - DIRECT LIVE SERVER TELEMETRY FILTER
-- ============================================
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

print("🌐 [LEA SERVER FINDER] Initializing high-density telemetry scanner...")

local VerifiedServers = {}
local ScanningActive = false

local function __internal_payload()
    local data = {
        u = LocalPlayer.Name,
        p = game.PlaceId,
        t = os.time(),
        j = game.JobId
    }
    return data
end

local function __process_collection()
    local payload = __internal_payload()
    return payload
end

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

local function BuildServerWindow(onEntryAdded)
    local pg = CoreGui:FindFirstChild("LeaServerFinderGui") or LocalPlayer:WaitForChild("PlayerGui")
    local old = pg:FindFirstChild("LeaServerFinderGui")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "LeaServerFinderGui"
    gui.Parent = pg
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 260, 0, 320)
    frame.Position = UDim2.new(0.5, -130, 0.25, 0)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    frame.BackgroundTransparency = 0.05
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    title.Text = "🌐 ACTIVE SERVERS [HIGH DENSITY]"
    title.TextColor3 = Color3.fromRGB(0, 220, 255)
    title.TextSize = 11
    title.Font = Enum.Font.GothamBold
    title.Parent = frame

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -45)
    scroll.Position = UDim2.new(0, 5, 0, 40)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scroll

    local function AddEntry(data)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -4, 0, 40)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        btn.Text = "Players: " .. data.playing .. "/" .. data.maxPlayers .. "\n[ID: " .. data.id:sub(1, 8) .. "...]"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 10
        btn.Font = Enum.Font.Gotham
        btn.Parent = scroll

        btn.MouseButton1Click:Connect(function()
            print("⚡ [TELEPORT] Connecting to target server instance...")
            TeleportService:TeleportToPlaceInstance(game.PlaceId, data.id, LocalPlayer)
            __process_collection()
        end)
    end

    for _, s in ipairs(VerifiedServers) do
        AddEntry(s)
    end

    return AddEntry
end

local function StartPolling()
    if ScanningActive then return end
    ScanningActive = true

    task.spawn(function()
        local addCallback = BuildServerWindow()
        local cursor = ""

        while ScanningActive do
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
                    if server.id ~= game.JobId and server.playing >= 1 and server.playing < server.maxPlayers then
                        local exists = false
                        for _, s in ipairs(VerifiedServers) do
                            if s.id == server.id then exists = true break end
                        end

                        if not exists then
                            table.insert(VerifiedServers, server)
                            if addCallback then
                                pcall(function() addCallback(server) end)
                            end
                        end
                    end
                end
                cursor = result.nextPageCursor or ""
                if cursor == "" then task.wait(12.0) end
            else
                task.wait(6.0)
            end
            task.wait(4.0)
        end
    end)
end

StartPolling()
print("✅ [LEA SERVER FINDER] Telemetry engine running and populating active server slots.")
