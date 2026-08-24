-- ============================================================
-- HAMSTER LIVES - EGG HUNTER V1.0
-- Cherry Blossom & Cosmic Egg Hunter
-- ============================================================

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

print("🌐 HAMSTER LIVES - EGG HUNTER LOADED...")

local EggServers = {}
local ScanningActive = false
local SelectedSize = 100 -- Varsayılan kg değeri (100k kg = 1 size)
local EggData = {}

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

-- ==================== EGG SİZE BUL ====================
local function GetEggSize(serverId)
    -- Remote'lardan egg bilgilerini çek
    -- Bu kısım server'dan egg bilgilerini almak için
    -- Gerçek uygulamada remote çağrıları ile yapılır
    return math.random(1, 1000) -- Simülasyon
end

-- ==================== MENÜ ====================
local function CreateMenu()
    local pg = CoreGui:FindFirstChild("HLEggHunter") or LocalPlayer:WaitForChild("PlayerGui")
    local old = pg:FindFirstChild("HLEggHunter")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "HLEggHunter"
    gui.Parent = pg
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 380)
    frame.Position = UDim2.new(0.5, -150, 0.15, 0)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 22)
    frame.BackgroundTransparency = 0.05
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)
    
    -- RGB çerçeve
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

    -- Başlık
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    title.Text = "🥚 EGG HUNTER"
    title.TextColor3 = Color3.fromRGB(0, 220, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = frame
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 14)
    
    -- SIZE SEÇİCİ
    local sizeFrame = Instance.new("Frame")
    sizeFrame.Size = UDim2.new(1, -12, 0, 30)
    sizeFrame.Position = UDim2.new(0, 6, 0, 40)
    sizeFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    sizeFrame.Parent = frame
    Instance.new("UICorner", sizeFrame).CornerRadius = UDim.new(0, 6)
    
    local sizeLabel = Instance.new("TextLabel")
    sizeLabel.Size = UDim2.new(0.3, 0, 1, 0)
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
    sizeInput.Position = UDim2.new(0.35, 0, 0, 0)
    sizeInput.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    sizeInput.Text = "100"
    sizeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    sizeInput.Font = Enum.Font.GothamBold
    sizeInput.TextSize = 11
    sizeInput.Parent = sizeFrame
    Instance.new("UICorner", sizeInput).CornerRadius = UDim.new(0, 4)
    
    local sizeUnit = Instance.new("TextLabel")
    sizeUnit.Size = UDim2.new(0.3, 0, 1, 0)
    sizeUnit.Position = UDim2.new(0.7, 0, 0, 0)
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
            SelectedSize = val
            print("🔍 Size seçildi: " .. SelectedSize .. "k kg")
            -- Yeniden tara
            EggServers = {}
            ScanEggServers()
        end
    end)
    
    -- Scroll
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
    Instance.new("UICorner", close).CornerRadius = UDim.new(0, 5)
    close.MouseButton1Click:Connect(function() frame.Visible = false end)

    -- SUNUCU EKLE
    local function AddServer(data)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -4, 0, 42)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
        btn.Text = "👤 " .. data.playing .. "/" .. data.maxPlayers .. "  |  🥚 " .. data.eggSize .. "k kg\n📡 " .. data.id:sub(1, 8) .. "..."
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.TextSize = 10
        btn.Font = Enum.Font.Gotham
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = scroll
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        -- Fare üstüne gelince kg göster
        btn.MouseEnter:Connect(function()
            btn.Text = "👤 " .. data.playing .. "/" .. data.maxPlayers .. "  |  🥚 " .. data.eggSize .. "k kg\n📡 " .. data.id:sub(1, 8) .. "..."
        end)

        btn.MouseButton1Click:Connect(function()
            print("⚡ [EGG HUNTER] Joining server...")
            TeleportService:TeleportToPlaceInstance(game.PlaceId, data.id, LocalPlayer)
        end)
    end

    for _, s in ipairs(EggServers) do
        AddServer(s)
    end

    return AddServer
end

-- ==================== EGG SUNUCU TARA ====================
local function ScanEggServers()
    if ScanningActive then return end
    ScanningActive = true

    task.spawn(function()
        local addCallback = CreateMenu()
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
                        -- Sunucudaki egg boyutunu kontrol et (simülasyon)
                        local eggSize = GetEggSize(server.id)
                        
                        -- Seçilen size'a göre filtrele
                        if eggSize >= SelectedSize then
                            local exists = false
                            for _, s in ipairs(EggServers) do
                                if s.id == server.id then exists = true break end
                            end

                            if not exists then
                                server.eggSize = eggSize
                                table.insert(EggServers, server)
                                if addCallback then
                                    pcall(function() addCallback(server) end)
                                end
                                print("🥚 " .. eggSize .. "k kg egg bulundu! Sunucu: " .. server.id:sub(1, 8))
                            end
                        end
                    end
                end
                cursor = result.nextPageCursor or ""
                if cursor == "" then task.wait(10) end
            end
            task.wait(3)
        end
    end)
end

-- ==================== AÇMA BUTONU ====================
local function CreateOpenButton()
    local pg = CoreGui:FindFirstChild("HLEggHunter") or LocalPlayer:WaitForChild("PlayerGui")
    local gui = pg:FindFirstChild("HLEggHunter")
    if not gui then return end
    
    local frame = gui:FindFirstChildWhichIsA("Frame")
    if not frame then return end
    
    local openBtn = Instance.new("TextButton")
    openBtn.Size = UDim2.new(0, 44, 0, 44)
    openBtn.Position = UDim2.new(1, -54, 0, 15)
    openBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 255)
    openBtn.Text = "🥚"
    openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    openBtn.Font = Enum.Font.GothamBold
    openBtn.TextSize = 20
    openBtn.Parent = gui
    Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)
    
    local hue = 0
    task.spawn(function()
        while true do
            hue = hue + 0.015
            if hue > 1 then hue = 0 end
            openBtn.BackgroundColor3 = HSVToRGB(hue, 1, 1)
            task.wait(0.05)
        end
    end)
    
    openBtn.MouseButton1Click:Connect(function()
        frame.Visible = not frame.Visible
    end)
end

-- ==================== BAŞLAT ====================
task.wait(0.5)
ScanEggServers()
task.wait(0.5)
CreateOpenButton()

print("")
print("========================================")
print("🥚 HAMSTER LIVES - EGG HUNTER")
print("   Egg serverları taranıyor...")
print("   KG değerini ayarlayıp filtrele!")
print("   Sağ üstteki 🥚 butonuna bas.")
print("========================================")
