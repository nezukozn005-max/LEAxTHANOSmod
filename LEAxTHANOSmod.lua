-- ============================================================
-- HAMSTER LIVES - SERVER FINDER V7 (FİNAL)
-- ============================================================

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

print("🐹 HAMSTER LIVES - SERVER FINDER BAŞLADI...")

local Servers = {}
local ScanActive = false

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

-- ==================== SAFE HTTP ====================
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

-- ==================== MENU ====================
local function CreateMenu()
    local pg = CoreGui:FindFirstChild("HLServerFinder") or LocalPlayer:WaitForChild("PlayerGui")
    local old = pg:FindFirstChild("HLServerFinder")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "HLServerFinder"
    gui.Parent = pg
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 400)
    frame.Position = UDim2.new(0.5, -160, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(8, 8, 20)
    frame.BackgroundTransparency = 0.05
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)
    
    -- RGB KENARLIK
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

    -- BAŞLIK
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    title.Text = "🐹 HAMSTER LIVES - SUNUCU BUL"
    title.TextColor3 = Color3.fromRGB(255, 200, 0)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.Parent = frame
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 14)
    
    -- YENİLE BUTONU
    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.new(0.2, 0, 0, 28)
    refreshBtn.Position = UDim2.new(0.78, 0, 0, 4)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    refreshBtn.Text = "🔄"
    refreshBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    refreshBtn.Font = Enum.Font.GothamBold
    refreshBtn.TextSize = 14
    refreshBtn.Parent = frame
    Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 6)
    refreshBtn.MouseButton1Click:Connect(function()
        Servers = {}
        ScanServers()
    end)
    
    -- LİSTE
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

    -- KAPAT
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 24, 0, 24)
    close.Position = UDim2.new(1, -28, 0, 4)
    close.BackgroundColor3 = Color3.fromRGB(180, 40, 50)
    close.Text = "✕"
    close.TextColor3 = Color3.fromRGB(255, 255, 255)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 13
    close.Parent = frame
    close.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    -- SUNUCU EKLE
    local function AddServer(data)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -4, 0, 38)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
        
        -- OYUNCU SAYISINA GÖRE RENK
        if data.playing <= 2 then
            btn.BackgroundColor3 = Color3.fromRGB(0, 180, 60)
        elseif data.playing <= 5 then
            btn.BackgroundColor3 = Color3.fromRGB(200, 170, 0)
        else
            btn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        end
        
        btn.Text = "👥 " .. data.playing .. "/" .. data.maxPlayers .. "  ⚡" .. (data.ping or 0) .. "ms  🔒 " .. data.id:sub(1, 8)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 11
        btn.Font = Enum.Font.GothamBold
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = scroll
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        
        btn.MouseButton1Click:Connect(function()
            btn.Text = "⏳ BAĞLANIYOR..."
            btn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
            btn.TextColor3 = Color3.fromRGB(0, 0, 0)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, data.id, LocalPlayer)
        end)
    end

    for _, s in ipairs(Servers) do
        AddServer(s)
    end

    return AddServer
end

-- ==================== SUNUCU TARA ====================
local function ScanServers()
    task.spawn(function()
        local addCallback = CreateMenu()
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
                    if server.id ~= game.JobId and server.playing < server.maxPlayers then
                        local exists = false
                        for _, s in ipairs(Servers) do
                            if s.id == server.id then exists = true break end
                        end
                        if not exists then
                            table.insert(Servers, server)
                            if addCallback then
                                pcall(function() addCallback(server) end)
                            end
                        end
                    end
                end
                cursor = result.nextPageCursor or ""
                if cursor == "" then task.wait(8) end
            end
            task.wait(2)
        end
    end)
end

-- ==================== AÇMA BUTONU ====================
local function CreateOpenButton()
    local pg = CoreGui:FindFirstChild("HLServerFinder") or LocalPlayer:WaitForChild("PlayerGui")
    local gui = pg:FindFirstChild("HLServerFinder")
    if gui then
        local frame = gui:FindFirstChildWhichIsA("Frame")
        if frame then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 50, 0, 50)
            btn.Position = UDim2.new(0.5, -25, 0.85, 0)
            btn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
            btn.Text = "🐹"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 24
            btn.Parent = gui
            Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
            
            local hue = 0
            task.spawn(function()
                while true do
                    hue = hue + 0.015
                    if hue > 1 then hue = 0 end
                    btn.BackgroundColor3 = HSVToRGB(hue, 1, 1)
                    task.wait(0.05)
                end
            end)
            
            btn.MouseButton1Click:Connect(function()
                frame.Visible = not frame.Visible
            end)
        end
    end
end

-- ==================== BAŞLAT ====================
task.wait(0.3)
ScanServers()
task.wait(0.5)
CreateOpenButton()

print("")
print("========================================")
print("🐹 HAMSTER LIVES - SERVER FINDER")
print("   📡 Tüm sunucular taranıyor")
print("   🟢 Yeşil = 1-2 kişi  🟡 Sarı = 3-5  🔴 Kırmızı = 6+")
print("   👆 Sunucuya tıkla ve bağlan!")
print("   🐹 Alttaki butona tıkla menüyü aç/kapa")
print("========================================")
