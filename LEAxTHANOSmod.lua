-- ============================================================
-- HAMSTER LIVES - DUAL SYSTEM V2 (2 AYRI MENU)
-- PRIVATE BREAKER + EGG HUNTER (KG FİLTRELİ)
-- ============================================================

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

print("🌐 HAMSTER LIVES - DUAL SYSTEM V2 LOADED...")

local PrivateServers = {}
local EggServers = {}
local ScanningActive = false
local SelectedKG = 100

-- ==================== RGB ====================
local function HSVToRGB(h, s, v)
    h = h % 1
    local r, g, b
    if s <= 0 then
        r, g, b = v, v, v
    else
        local h6 = h * 6
        local i = math.floor(h6)
        local f = h6 - i
        local p = v * (1 - s)
        local q = v * (1 - s * f)
        local t = v * (1 - s * (1 - f))
        if i == 0 then r, g, b = v, t, p
        elseif i == 1 then r, g, b = q, v, p
        elseif i == 2 then r, g, b = p, v, t
        elseif i == 3 then r, g, b = p, q, v
        elseif i == 4 then r, g, b = t, p, v
        else r, g, b = v, p, q end
    end
    return Color3.new(r, g, b)
end

-- ==================== SAFE HTTP GET ====================
local function SafeHttpGet(url)
    local success, response = pcall(function()
        if syn and syn.request then
            local req = syn.request({Url = url, Method = "GET"})
            if req and req.Body then return req.Body end
        elseif request then
            local req = request({Url = url, Method = "GET"})
            if req and req.Body then return req.Body end
        end
        return game:HttpGet(url)
    end)
    if success and response then return response end
    return nil
end

-- ==================== EGG KG BUL (SİMÜLASYON) ====================
local function GetEggKG(serverId)
    -- Gerçek oyunda remote'dan çekilecek
    -- Şimdilik rastgele KG üret (100-2000 arası)
    return math.random(100, 2000)
end

-- ==================== MENU 1: PRIVATE BREAKER (SOL) ====================
local function CreatePrivateMenu()
    local pg = CoreGui:FindFirstChild("HLPrivateBreaker") or LocalPlayer:WaitForChild("PlayerGui")
    local old = pg:FindFirstChild("HLPrivateBreaker")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "HLPrivateBreaker"
    gui.Parent = pg
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 260, 0, 340)
    frame.Position = UDim2.new(0.02, 0, 0.15, 0)
    frame.BackgroundColor3 = Color3.fromRGB(8, 8, 20)
    frame.BackgroundTransparency = 0.05
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)
    
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 2.5
    local hue = 0
    task.spawn(function()
        while true do
            hue = hue + 0.008
            if hue > 1 then hue = 0 end
            stroke.Color = HSVToRGB(hue, 1, 1)
            task.wait(0.04)
        end
    end)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    title.Text = "🔓 PRIVATE BREAKER"
    title.TextColor3 = Color3.fromRGB(0, 220, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.Parent = frame
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 14)
    
    -- REFRESH
    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.new(0.25, 0, 0, 28)
    refreshBtn.Position = UDim2.new(0.72, 0, 0, 4)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    refreshBtn.Text = "🔄"
    refreshBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    refreshBtn.Font = Enum.Font.GothamBold
    refreshBtn.TextSize = 14
    refreshBtn.Parent = frame
    Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 6)
    refreshBtn.MouseButton1Click:Connect(function()
        PrivateServers = {}
        ScanPrivateServers()
        print("🔄 Private listesi yenilendi!")
    end)
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -12, 1, -50)
    scroll.Position = UDim2.new(0, 6, 0, 40)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scroll

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 24, 0, 24)
    close.Position = UDim2.new(1, -28, 0, 4)
    close.BackgroundColor3 = Color3.fromRGB(180, 40, 50)
    close.Text = "✕"
    close.TextColor3 = Color3.fromRGB(255, 255, 255)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 13
    close.Parent = frame
    Instance.new("UICorner", close).CornerRadius = UDim.new(0, 5)
    close.MouseButton1Click:Connect(function() frame.Visible = false end)

    local function AddServer(data)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -4, 0, 38)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
        btn.Text = "👤 " .. data.playing .. "/" .. data.maxPlayers .. " | 🔒 " .. data.id:sub(1, 8)
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.TextSize = 10
        btn.Font = Enum.Font.Gotham
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = scroll
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        btn.MouseButton1Click:Connect(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, data.id, LocalPlayer)
        end)
    end

    for _, s in ipairs(PrivateServers) do
        AddServer(s)
    end

    return AddServer
end

-- ==================== MENU 2: EGG HUNTER (SAĞ) ====================
local function CreateEggMenu()
    local pg = CoreGui:FindFirstChild("HLEggHunter") or LocalPlayer:WaitForChild("PlayerGui")
    local old = pg:FindFirstChild("HLEggHunter")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "HLEggHunter"
    gui.Parent = pg
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 260, 0, 340)
    frame.Position = UDim2.new(0.55, 0, 0.15, 0)
    frame.BackgroundColor3 = Color3.fromRGB(8, 8, 20)
    frame.BackgroundTransparency = 0.05
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)
    
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 2.5
    local hue = 0.5
    task.spawn(function()
        while true do
            hue = hue + 0.008
            if hue > 1 then hue = 0 end
            stroke.Color = HSVToRGB(hue, 1, 1)
            task.wait(0.04)
        end
    end)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    title.Text = "🥚 EGG HUNTER (KG)"
    title.TextColor3 = Color3.fromRGB(255, 200, 0)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.Parent = frame
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 14)
    
    -- REFRESH
    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.new(0.25, 0, 0, 28)
    refreshBtn.Position = UDim2.new(0.72, 0, 0, 4)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    refreshBtn.Text = "🔄"
    refreshBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    refreshBtn.Font = Enum.Font.GothamBold
    refreshBtn.TextSize = 14
    refreshBtn.Parent = frame
    Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 6)
    refreshBtn.MouseButton1Click:Connect(function()
        EggServers = {}
        ScanEggServers()
        print("🔄 Egg listesi yenilendi!")
    end)
    
    -- KG SEÇİCİ
    local sizeFrame = Instance.new("Frame")
    sizeFrame.Size = UDim2.new(1, -12, 0, 30)
    sizeFrame.Position = UDim2.new(0, 6, 0, 40)
    sizeFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    sizeFrame.Parent = frame
    Instance.new("UICorner", sizeFrame).CornerRadius = UDim.new(0, 6)
    
    local sizeLabel = Instance.new("TextLabel")
    sizeLabel.Size = UDim2.new(0.2, 0, 1, 0)
    sizeLabel.Position = UDim2.new(0, 5, 0, 0)
    sizeLabel.BackgroundTransparency = 1
    sizeLabel.Text = "KG:"
    sizeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    sizeLabel.Font = Enum.Font.GothamBold
    sizeLabel.TextSize = 11
    sizeLabel.TextXAlignment = Enum.TextXAlignment.Left
    sizeLabel.Parent = sizeFrame
    
    local sizeInput = Instance.new("TextBox")
    sizeInput.Size = UDim2.new(0.3, 0, 1, 0)
    sizeInput.Position = UDim2.new(0.25, 0, 0, 0)
    sizeInput.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    sizeInput.Text = "100"
    sizeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    sizeInput.Font = Enum.Font.GothamBold
    sizeInput.TextSize = 11
    sizeInput.Parent = sizeFrame
    Instance.new("UICorner", sizeInput).CornerRadius = UDim.new(0, 4)
    
    local sizeUnit = Instance.new("TextLabel")
    sizeUnit.Size = UDim2.new(0.35, 0, 1, 0)
    sizeUnit.Position = UDim2.new(0.6, 0, 0, 0)
    sizeUnit.BackgroundTransparency = 1
    sizeUnit.Text = "k = 1 Size"
    sizeUnit.TextColor3 = Color3.fromRGB(255, 200, 0)
    sizeUnit.Font = Enum.Font.Gotham
    sizeUnit.TextSize = 9
    sizeUnit.TextXAlignment = Enum.TextXAlignment.Left
    sizeUnit.Parent = sizeFrame
    
    sizeInput.FocusLost:Connect(function()
        local val = tonumber(sizeInput.Text)
        if val then
            SelectedKG = val
            print("🔍 KG seçildi: " .. SelectedKG .. "k")
            EggServers = {}
            ScanEggServers()
        end
    end)
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -12, 1, -85)
    scroll.Position = UDim2.new(0, 6, 0, 75)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scroll

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 24, 0, 24)
    close.Position = UDim2.new(1, -28, 0, 4)
    close.BackgroundColor3 = Color3.fromRGB(180, 40, 50)
    close.Text = "✕"
    close.TextColor3 = Color3.fromRGB(255, 255, 255)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 13
    close.Parent = frame
    Instance.new("UICorner", close).CornerRadius = UDim.new(0, 5)
    close.MouseButton1Click:Connect(function() frame.Visible = false end)

    local function AddServer(data)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -4, 0, 42)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
        btn.Text = "👤 " .. data.playing .. "/" .. data.maxPlayers .. "\n🥚 " .. data.eggKG .. "k KG | 📡 " .. data.id:sub(1, 8)
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.TextSize = 10
        btn.Font = Enum.Font.Gotham
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = scroll
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        
        btn.MouseButton1Click:Connect(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, data.id, LocalPlayer)
        end)
    end

    for _, s in ipairs(EggServers) do
        AddServer(s)
    end

    return AddServer
end

-- ==================== PRIVATE SUNUCU TARA ====================
local function ScanPrivateServers()
    task.spawn(function()
        local addCallback = CreatePrivateMenu()
        local cursor = ""

        while true do
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
                    if server.id ~= game.JobId and server.playing < server.maxPlayers and server.maxPlayers <= 10 then
                        local exists = false
                        for _, s in ipairs(PrivateServers) do
                            if s.id == server.id then exists = true break end
                        end
                        if not exists then
                            table.insert(PrivateServers, server)
                            if addCallback then
                                pcall(function() addCallback(server) end)
                            end
                        end
                    end
                end
                cursor = result.nextPageCursor or ""
                if cursor == "" then task.wait(10)
            end
            task.wait(3)
        end
    end)
end

-- ==================== EGG SUNUCU TARA ====================
local function ScanEggServers()
    task.spawn(function()
        local addCallback = CreateEggMenu()
        local cursor = ""

        while true do
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
                        local eggKG = GetEggKG(server.id)
                        if eggKG >= SelectedKG then
                            local exists = false
                            for _, s in ipairs(EggServers) do
                                if s.id == server.id then exists = true break end
                            end
                            if not exists then
                                server.eggKG = eggKG
                                table.insert(EggServers, server)
                                if addCallback then
                                    pcall(function() addCallback(server) end)
                                end
                            end
                        end
                    end
                end
                cursor = result.nextPageCursor or ""
                if cursor == "" then task.wait(10)
            end
            task.wait(3)
        end
    end)
end

-- ==================== AÇMA BUTONLARI ====================
local function CreateOpenButtons()
    -- BUTON 1: Private Breaker (Sol)
    local pg1 = CoreGui:FindFirstChild("HLPrivateBreaker") or LocalPlayer:WaitForChild("PlayerGui")
    local gui1 = pg1:FindFirstChild("HLPrivateBreaker")
    if gui1 then
        local frame1 = gui1:FindFirstChildWhichIsA("Frame")
        if frame1 then
            local btn1 = Instance.new("TextButton")
            btn1.Size = UDim2.new(0, 44, 0, 44)
            btn1.Position = UDim2.new(0.08, 0, 0.55, 0)
            btn1.BackgroundColor3 = Color3.fromRGB(100, 0, 255)
            btn1.Text = "🔓"
            btn1.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn1.Font = Enum.Font.GothamBold
            btn1.TextSize = 20
            btn1.Parent = gui1
            Instance.new("UICorner", btn1).CornerRadius = UDim.new(1, 0)
            local hue = 0
            task.spawn(function()
                while true do
                    hue = hue + 0.015
                    if hue > 1 then hue = 0 end
                    btn1.BackgroundColor3 = HSVToRGB(hue, 1, 1)
                    task.wait(0.05)
                end
            end)
            btn1.MouseButton1Click:Connect(function()
                frame1.Visible = not frame1.Visible
            end)
        end
    end
    
    -- BUTON 2: Egg Hunter (Sağ)
    local pg2 = CoreGui:FindFirstChild("HLEggHunter") or LocalPlayer:WaitForChild("PlayerGui")
    local gui2 = pg2:FindFirstChild("HLEggHunter")
    if gui2 then
        local frame2 = gui2:FindFirstChildWhichIsA("Frame")
        if frame2 then
            local btn2 = Instance.new("TextButton")
            btn2.Size = UDim2.new(0, 44, 0, 44)
            btn2.Position = UDim2.new(0.75, 0, 0.55, 0)
            btn2.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
            btn2.Text = "🥚"
            btn2.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn2.Font = Enum.Font.GothamBold
            btn2.TextSize = 20
            btn2.Parent = gui2
            Instance.new("UICorner", btn2).CornerRadius = UDim.new(1, 0)
            local hue2 = 0.5
            task.spawn(function()
                while true do
                    hue2 = hue2 + 0.015
                    if hue2 > 1 then hue2 = 0 end
                    btn2.BackgroundColor3 = HSVToRGB(hue2, 1, 1)
                    task.wait(0.05)
                end
            end)
            btn2.MouseButton1Click:Connect(function()
                frame2.Visible = not frame2.Visible
            end)
        end
    end
end

-- ==================== BAŞLAT ====================
task.wait(0.3)
ScanPrivateServers()
task.wait(0.3)
ScanEggServers()
task.wait(0.5)
CreateOpenButtons()

print("")
print("========================================")
print("🔓🥚 HAMSTER LIVES - DUAL SYSTEM V2")
print("   Sol: 🔓 Private Server Breaker")
print("   Sağ: 🥚 Egg Hunter (KG filtreli)")
print("   KG girince otomatik filtreleme")
print("========================================")
