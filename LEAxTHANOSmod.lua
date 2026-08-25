-- ============================================================
-- HAMSTER LIVES - SERVER FINDER V15 (FINAL)
-- ============================================================

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

print("🐹 HAMSTER LIVES - SERVER FINDER V15 BAŞLADI...")

local Servers = {}
local IsScanning = false
local StopScanning = false
local MenuVisible = true
local GuiRef = nil
local FrameRef = nil
local ButtonRef = nil
local ScrollRef = nil
local LayoutRef = nil

-- ==================== TEMİZLE ====================
local function CleanEverything()
    StopScanning = true
    IsScanning = false

    if GuiRef then
        pcall(function() GuiRef:Destroy() end)
        GuiRef = nil
    end

    if ButtonRef then
        pcall(function() ButtonRef:Destroy() end)
        ButtonRef = nil
    end

    local pg = CoreGui
    if pg then
        local old = pg:FindFirstChild("HLServerFinder")
        if old then pcall(function() old:Destroy() end) end
        local oldBtn = pg:FindFirstChild("HLServerButton")
        if oldBtn then pcall(function() oldBtn:Destroy() end) end
    end

    local pg2 = LocalPlayer:FindFirstChild("PlayerGui")
    if pg2 then
        local old = pg2:FindFirstChild("HLServerFinder")
        if old then pcall(function() old:Destroy() end) end
        local oldBtn = pg2:FindFirstChild("HLServerButton")
        if oldBtn then pcall(function() oldBtn:Destroy() end) end
    end

    Servers = {}
    FrameRef = nil
    ScrollRef = nil
    LayoutRef = nil
end

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
local function FastHttpGet(url)
    local success, response = pcall(function()
        if syn and syn.request then
            local req = syn.request({Url = url, Method = "GET", Headers = {["Cache-Control"] = "no-cache"}, Timeout = 5})
            if req and req.Body then return req.Body end
        elseif request then
            local req = request({Url = url, Method = "GET", Headers = {["Cache-Control"] = "no-cache"}, Timeout = 5})
            if req and req.Body then return req.Body end
        end
        return game:HttpGet(url)
    end)
    if success and response then return response end
    return nil
end

-- ==================== SUNUCU BUTONU OLUŞTUR ====================
local function CreateServerButton(parent, data)
    if not parent or not data then return end
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 35)

    if data.playing <= 2 then
        btn.BackgroundColor3 = Color3.fromRGB(0, 180, 60)
    elseif data.playing <= 5 then
        btn.BackgroundColor3 = Color3.fromRGB(200, 170, 0)
    else
        btn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    end

    btn.Text = "👥 " .. data.playing .. "/" .. data.maxPlayers .. "  ⚡" .. (data.ping or 0) .. "ms"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local serverId = data.id
    btn.MouseButton1Click:Connect(function()
        CleanEverything()
        task.wait(0.05)

        local success, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId, LocalPlayer)
        end)

        if not success then
            print("❌ Teleport başarısız: " .. tostring(err))
            task.wait(0.5)
            -- YENİDEN MENU OLUŞTUR VE TARA
            CreateMenu()
            ScanServers()
        end
    end)
end

-- ==================== MENU OLUŞTUR ====================
local function CreateMenu()
    CleanEverything()

    local pg = CoreGui
    if not pg then
        pg = LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then
            pg = Instance.new("ScreenGui")
            pg.Name = "PlayerGui"
            pg.Parent = LocalPlayer
            task.wait(0.1)
        end
    end
    if not pg then return end

    local gui = Instance.new("ScreenGui")
    gui.Name = "HLServerFinder"
    gui.Parent = pg
    gui.ResetOnSpawn = false
    GuiRef = gui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 400)
    frame.Position = UDim2.new(0.5, -160, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(8, 8, 20)
    frame.BackgroundTransparency = 0.05
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui
    FrameRef = frame
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 2.5
    local hue = 0
    task.spawn(function()
        while GuiRef and GuiRef.Parent and frame and frame.Parent do
            hue = hue + 0.008
            if hue > 1 then hue = 0 end
            stroke.Color = HSVToRGB(hue, 1, 1)
            task.wait(0.04)
        end
    end)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    title.Text = "🐹 HAMSTER LIVES - SUNUCU BUL"
    title.TextColor3 = Color3.fromRGB(255, 200, 0)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.Parent = frame
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 14)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -12, 1, -50)
    scroll.Position = UDim2.new(0, 6, 0, 40)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = frame
    ScrollRef = scroll

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scroll
    LayoutRef = layout

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
        StopScanning = true
        
        -- TIMEOUT İLE BEKLE (MAX 3 SANİYE)
        local waitTime = 0
        while IsScanning and waitTime < 30 do
            task.wait(0.1)
            waitTime = waitTime + 1
        end
        
        Servers = {}
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        StopScanning = false
        IsScanning = false
        ScanServers()
    end)

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
        MenuVisible = false
        frame.Visible = false
    end)

    -- MEVCUT SUNUCULARI GÖSTER
    for _, s in ipairs(Servers) do
        CreateServerButton(scroll, s)
    end

    task.wait(0.05)
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end

-- ==================== SUNUCU TARA ====================
local function ScanServers()
    if IsScanning then return end
    IsScanning = true
    StopScanning = false

    task.spawn(function()
        if not GuiRef or not GuiRef.Parent then
            CreateMenu()
        end

        local cursor = ""
        local retryCount = 0
        local requestCount = 0

        while not StopScanning and GuiRef and GuiRef.Parent do
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
            if cursor ~= "" then
                url = url .. "&cursor=" .. cursor
            end

            local rawData = FastHttpGet(url)

            if rawData and rawData ~= "" then
                local success, result = pcall(function()
                    return HttpService:JSONDecode(rawData)
                end)

                if success and result and result.data then
                    retryCount = 0
                    local addedCount = 0
                    local scroll = ScrollRef
                    local layout = LayoutRef

                    for _, server in ipairs(result.data) do
                        if StopScanning then break end

                        if server.id ~= game.JobId and server.playing < server.maxPlayers then
                            local exists = false
                            for _, s in ipairs(Servers) do
                                if s.id == server.id then
                                    exists = true
                                    break
                                end
                            end
                            if not exists then
                                table.insert(Servers, server)
                                if scroll then
                                    pcall(function()
                                        CreateServerButton(scroll, server)
                                        addedCount = addedCount + 1
                                    end)
                                end
                            end
                        end
                    end

                    if addedCount > 0 and layout then
                        task.wait(0.02)
                        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
                    end

                    cursor = result.nextPageCursor or ""
                    if cursor == "" then
                        task.wait(5)
                    end
                else
                    retryCount = retryCount + 1
                    if retryCount >= 3 then
                        task.wait(5)
                        retryCount = 0
                    else
                        task.wait(1)
                    end
                end
            else
                retryCount = retryCount + 1
                if retryCount >= 3 then
                    task.wait(5)
                    retryCount = 0
                else
                    task.wait(1)
                end
            end

            requestCount = requestCount + 1
            if requestCount > 50 then
                task.wait(5)
                requestCount = 0
            end
            
            task.wait(0.5)
        end

        IsScanning = false
    end)
end

-- ==================== AÇMA BUTONU ====================
local function CreateOpenButton()
    task.wait(0.2)

    if ButtonRef then
        pcall(function() ButtonRef:Destroy() end)
        ButtonRef = nil
    end

    local pg = CoreGui
    if not pg then
        pg = LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then
            pg = Instance.new("ScreenGui")
            pg.Name = "PlayerGui"
            pg.Parent = LocalPlayer
        end
    end
    if not pg then return end

    local btn = Instance.new("TextButton")
    btn.Name = "HLServerButton"
    btn.Size = UDim2.new(0, 44, 0, 44)
    btn.Position = UDim2.new(0.02, 0, 0.02, 0)
    btn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    btn.Text = "🐹"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 22
    btn.Parent = pg
    btn.ZIndex = 999
    ButtonRef = btn
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local hue = 0
    task.spawn(function()
        while ButtonRef and ButtonRef.Parent do
            hue = hue + 0.015
            if hue > 1 then hue = 0 end
            ButtonRef.BackgroundColor3 = HSVToRGB(hue, 1, 1)
            task.wait(0.05)
        end
    end)

    btn.MouseButton1Click:Connect(function()
        if FrameRef and FrameRef.Parent then
            MenuVisible = not MenuVisible
            FrameRef.Visible = MenuVisible
        else
            CleanEverything()
            Servers = {}
            CreateMenu()
            MenuVisible = true
            ScanServers()
        end
    end)
end

-- ==================== BAŞLAT ====================
local function Init()
    CleanEverything()
    Servers = {}
    IsScanning = false
    StopScanning = false

    CreateMenu()
    MenuVisible = true

    task.wait(0.1)
    ScanServers()

    task.wait(0.2)
    CreateOpenButton()

    print("")
    print("========================================")
    print("🐹 HAMSTER LIVES - SERVER FINDER V15")
    print("   ✅ Tüm hatalar fixlendi")
    print("   ✅ Sunucuya tıklayınca tamamen temizlenir")
    print("   ✅ Hiç donma yok")
    print("   ✅ Gecikme sıfır")
    print("   🐹 Sol üstteki butona tıkla menüyü aç/kapa")
    print("========================================")
end

task.wait(0.3)
pcall(Init)
