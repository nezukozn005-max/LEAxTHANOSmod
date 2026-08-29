-- HAMSTER LIVES V1.5
-- Anında açılan menü + 1 kişilik sunucu tarayıcı
-- Whitelist: Yamanxct ve U ile başlayan kullanıcı

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

-- =========================
-- WHITELIST
-- =========================
local WHITELIST = {
    [1342015154] = true,   -- Yamanxct
    [11549642187] = true,  -- U ile başlayan kullanıcı

    -- Yeni kişi:
    -- [123456789] = true,
}

if not WHITELIST[LocalPlayer.UserId] then
    return
end

-- =========================
-- GUI
-- =========================
local old = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("HamsterLives_Instant")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "HamsterLives_Instant"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999
gui.Parent = LocalPlayer.PlayerGui

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.fromOffset(170, 38)
toggle.Position = UDim2.new(0.5, -85, 0, 18)
toggle.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
toggle.TextColor3 = Color3.new(1,1,1)
toggle.Text = "🐹 HAMSTER LIVES"
toggle.Font = Enum.Font.GothamBlack
toggle.TextSize = 13
toggle.AutoButtonColor = true
toggle.Parent = gui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 9)
toggleCorner.Parent = toggle

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Thickness = 1.5
toggleStroke.Color = Color3.fromRGB(255, 70, 70)
toggleStroke.Parent = toggle

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(300, 360)
panel.Position = UDim2.new(0.5, -150, 0, 64)
panel.BackgroundColor3 = Color3.fromRGB(8, 8, 11)
panel.BorderSizePixel = 0
panel.Visible = true
panel.Active = true
panel.Draggable = true
panel.Parent = gui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 12)
panelCorner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Thickness = 2
panelStroke.Color = Color3.fromRGB(210, 0, 0)
panelStroke.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 32)
title.Position = UDim2.fromOffset(10, 8)
title.BackgroundTransparency = 1
title.Text = "🐹 HAMSTER LIVES  •  V1.5"
title.TextColor3 = Color3.fromRGB(255, 70, 70)
title.Font = Enum.Font.GothamBlack
title.TextSize = 15
title.Parent = panel

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 22)
status.Position = UDim2.fromOffset(10, 40)
status.BackgroundTransparency = 1
status.Text = "Sunucular aranıyor..."
status.TextColor3 = Color3.fromRGB(190, 190, 190)
status.Font = Enum.Font.GothamBold
status.TextSize = 10
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = panel

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -16, 1, -72)
list.Position = UDim2.fromOffset(8, 66)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.CanvasSize = UDim2.new()
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.Parent = list

-- =========================
-- SERVER TARAYICI
-- =========================
local seen = {}
local serverCount = 0
local scanRunning = false

local function addServer(server)
    if not server or not server.id then return end
    if seen[server.id] then return end
    if server.id == game.JobId then return end

    -- SADECE TAM OLARAK 1 OYUNCULU SUNUCULAR
    if server.playing ~= 1 then return end
    if not server.maxPlayers or server.playing >= server.maxPlayers then return end

    seen[server.id] = true
    serverCount += 1

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -4, 0, 34)
    button.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    button.BorderSizePixel = 0
    button.AutoButtonColor = true
    button.Text = "👤  1/ "..tostring(server.maxPlayers).."     •     SUNUCU"
    button.TextColor3 = Color3.fromRGB(255, 205, 70)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 10
    button.Parent = list

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = button

    button.MouseButton1Click:Connect(function()
        button.Text = "⏳ BAĞLANIYOR..."
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
        end)
    end)

    status.Text = tostring(serverCount) .. " adet 1 kişilik sunucu bulundu"
end

local function httpGet(url)
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and type(result) == "string" and #result > 0 then
        return result
    end
    return nil
end

local function scanServers()
    if scanRunning then return end
    scanRunning = true

    task.spawn(function()
        local cursor = nil

        -- Sayfa sayfa ilerler; aralarda yapay bekleme yoktur.
        for page = 1, 10 do
            local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId)
                .. "/servers/Public?sortOrder=Asc&limit=100"

            if cursor and cursor ~= "" then
                url = url .. "&cursor=" .. HttpService:UrlEncode(cursor)
            end

            local raw = httpGet(url)
            if not raw then
                status.Text = "Sunucu listesi alınamadı."
                break
            end

            local ok, data = pcall(function()
                return HttpService:JSONDecode(raw)
            end)

            if not ok or type(data) ~= "table" or type(data.data) ~= "table" then
                status.Text = "Sunucu listesi okunamadı."
                break
            end

            for _, server in ipairs(data.data) do
                addServer(server)
            end

            cursor = data.nextPageCursor
            if not cursor or cursor == "" then
                break
            end

            -- İSTENMEYEN BEKLEME YOK.
            -- Bir sonraki HTTP isteği doğrudan başlar.
        end

        if serverCount == 0 then
            status.Text = "Şu an 1 kişilik uygun sunucu bulunamadı."
        else
            status.Text = tostring(serverCount) .. " adet 1 kişilik sunucu bulundu"
        end

        scanRunning = false
    end)
end

-- =========================
-- AÇ/KAPA
-- =========================
toggle.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
end)

-- Menü hazır olur olmaz taramayı başlat.
-- Açılış animasyonu / task.wait / gecikme yok.
scanServers()
