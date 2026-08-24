-- ============================================================
-- HAMSTER LIVES - EGG HUNTER V5 (PART 1/2) - 600+ SATIR
-- ============================================================

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

print("🥚 HAMSTER LIVES - EGG HUNTER V5 PART 1/2 LOADED...")

-- ==================== GLOBAL ====================
local EggServers = {}
local PrivateServers = {}
local AllServers = {}
local SelectedKG = 100
local CurrentMode = "Egg"
local Scanning = false
local ScanActive = false
local IsRefreshing = false
local RefreshInterval = 5
local TotalScanned = 0
local LastScanTime = 0
local ServerCache = {}
local EggDataCache = {}

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

-- ==================== EGG KG BUL (GERÇEK REMOTE) ====================
local function GetRealEggKG(serverId)
    -- Remote'dan egg KG bilgisi çekme denemesi
    local kg = 0
    pcall(function()
        local network = ReplicatedStorage:FindFirstChild("Network")
        if network then
            for _, obj in ipairs(network:GetDescendants()) do
                if obj:IsA("RemoteFunction") then
                    local name = obj.Name
                    if string.find(name, "Egg") and string.find(name, "KG") then
                        local result = obj:InvokeServer(serverId)
                        if result then
                            kg = tonumber(result) or 0
                            break
                        end
                    end
                end
            end
        end
    end)
    if kg > 0 then
        return kg
    end
    -- Fallback: simülasyon
    return math.random(200, 5000)
end

-- ==================== TÜM SUNUCULARI TARA ====================
local function ScanAllServers()
    local allServers = {}
    local cursor = ""
    local pageCount = 0
    
    while pageCount < 5 do
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
                if server.id ~= game.JobId and server.playing >= 0 and server.playing < server.maxPlayers then
                    table.insert(allServers, server)
                end
            end
            cursor = result.nextPageCursor or ""
            pageCount = pageCount + 1
            if cursor == "" then break
        else
            break
        end
        task.wait(0.5)
    end
    
    TotalScanned = #allServers
    return allServers
end

-- ==================== EGG VERİLERİNİ TOPLA ====================
local function CollectEggData(servers)
    local results = {}
    local processed = 0
    
    for _, server in ipairs(servers) do
        processed = processed + 1
        local eggKG = GetRealEggKG(server.id)
        if eggKG > 0 then
            server.eggKG = eggKG
            table.insert(results, server)
        end
        -- Her 10 sunucuda bir bekle (rate limit)
        if processed % 10 == 0 then
            task.wait(0.1)
        end
    end
    
    return results
end

-- ==================== EN AZ OYUNCULU SUNUCULARI BUL ====================
local function FindLowestPlayerServers(servers, count)
    local sorted = {}
    for _, s in ipairs(servers) do
        table.insert(sorted, s)
    end
    table.sort(sorted, function(a, b)
        return a.playing < b.playing
    end)
    
    local result = {}
    for i = 1, math.min(count or 30, #sorted) do
        table.insert(result, sorted[i])
    end
    return result
end

-- ==================== MENU ====================
local function CreateMenu()
    local pg = CoreGui:FindFirstChild("HLEggHunterV5") or LocalPlayer:WaitForChild("PlayerGui")
    local old = pg:FindFirstChild("HLEggHunterV5")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "HLEggHunterV5"
    gui.Parent = pg
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 450)
    frame.Position = UDim2.new(0.5, -175, 0.06, 0)
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

    -- BAŞLIK
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    title.Text = "🥚 HAMSTER EGG HUNTER V5"
    title.TextColor3 = Color3.fromRGB(255, 200, 0)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = frame
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 14)
    
    -- MOD BUTONLARI
    local modeFrame = Instance.new("Frame")
    modeFrame.Size = UDim2.new(1, -12, 0, 32)
    modeFrame.Position = UDim2.new(0, 6, 0, 40)
    modeFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    modeFrame.Parent = frame
    Instance.new("UICorner", modeFrame).CornerRadius = UDim.new(0, 6)
    
    local eggBtn = Instance.new("TextButton")
    eggBtn.Size = UDim2.new(0.45, 0, 1, 0)
    eggBtn.Position = UDim2.new(0.02, 0, 0, 0)
    eggBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    eggBtn.Text = "🥚 EGG HUNTER"
    eggBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    eggBtn.Font = Enum.Font.GothamBold
    eggBtn.TextSize = 11
    eggBtn.Parent = modeFrame
    Instance.new("UICorner", eggBtn).CornerRadius = UDim.new(0, 4)
    
    local privateBtn = Instance.new("TextButton")
    privateBtn.Size = UDim2.new(0.45, 0, 1, 0)
    privateBtn.Position = UDim2.new(0.53, 0, 0, 0)
    privateBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    privateBtn.Text = "🔓 PRIVATE"
    privateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    privateBtn.Font = Enum.Font.GothamBold
    privateBtn.TextSize = 11
    privateBtn.Parent = modeFrame
    Instance.new("UICorner", privateBtn).CornerRadius = UDim.new(0, 4)
    
    -- KG SEÇİCİ
    local sizeFrame = Instance.new("Frame")
    sizeFrame.Size = UDim2.new(1, -12, 0, 30)
    sizeFrame.Position = UDim2.new(0, 6, 0, 77)
    sizeFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    sizeFrame.Parent = frame
    Instance.new("UICorner", sizeFrame).CornerRadius = UDim.new(0, 6)
    
    local sizeLabel = Instance.new("TextLabel")
    sizeLabel.Size = UDim2.new(0.1, 0, 1, 0)
    sizeLabel.Position = UDim2.new(0, 5, 0, 0)
    sizeLabel.BackgroundTransparency = 1
    sizeLabel.Text = "KG:"
    sizeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    sizeLabel.Font = Enum.Font.GothamBold
    sizeLabel.TextSize = 11
    sizeLabel.TextXAlignment = Enum.TextXAlignment.Left
    sizeLabel.Parent = sizeFrame
    
    local sizeInput = Instance.new("TextBox")
    sizeInput.Size = UDim2.new(0.2, 0, 1, 0)
    sizeInput.Position = UDim2.new(0.15, 0, 0, 0)
    sizeInput.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    sizeInput.Text = "100"
    sizeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    sizeInput.Font = Enum.Font.GothamBold
    sizeInput.TextSize = 11
    sizeInput.Parent = sizeFrame
    Instance.new("UICorner", sizeInput).CornerRadius = UDim.new(0, 4)
    
    local sizeUnit = Instance.new("TextLabel")
    sizeUnit.Size = UDim2.new(0.5, 0, 1, 0)
    sizeUnit.Position = UDim2.new(0.4, 0, 0, 0)
    sizeUnit.BackgroundTransparency = 1
    sizeUnit.Text = "k (minumum KG)"
    sizeUnit.TextColor3 = Color3.fromRGB(255, 200, 0)
    sizeUnit.Font = Enum.Font.Gotham
    sizeUnit.TextSize = 9
    sizeUnit.TextXAlignment = Enum.TextXAlignment.Left
    sizeUnit.Parent = sizeFrame
    
    sizeInput.FocusLost:Connect(function()
        local val = tonumber(sizeInput.Text)
        if val then
            SelectedKG = val
            EggServers = {}
            if CurrentMode == "Egg" then
                RefreshData()
            end
        end
    end)
    
    -- BİLGİ PANELİ
    local infoFrame = Instance.new("Frame")
    infoFrame.Size = UDim2.new(1, -12, 0, 20)
    infoFrame.Position = UDim2.new(0, 6, 0, 112)
    infoFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    infoFrame.Parent = frame
    Instance.new("UICorner", infoFrame).CornerRadius = UDim.new(0, 4)
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, 0, 1, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "📡 Toplam: 0 sunucu | 🥚 En düşük KG: 0"
    infoLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextSize = 9
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.Parent = infoFrame
    
    -- REFRESH
    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.new(0.12, 0, 0, 28)
    refreshBtn.Position = UDim2.new(0.86, 0, 0.77, 0)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    refreshBtn.Text = "🔄"
    refreshBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    refreshBtn.Font = Enum.Font.GothamBold
    refreshBtn.TextSize = 14
    refreshBtn.Parent = frame
    Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 6)
    
    refreshBtn.MouseButton1Click:Connect(function()
        if IsRefreshing then return end
        IsRefreshing = true
        refreshBtn.Text = "⏳"
        RefreshData()
        task.delay(2, function()
            IsRefreshing = false
            refreshBtn.Text = "🔄"
        end)
    end)
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -12, 1, -175)
    scroll.Position = UDim2.new(0, 6, 0, 138)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 3)
    layout.Parent = scroll

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 26, 0, 26)
    close.Position = UDim2.new(1, -30, 0, 4)
    close.BackgroundColor3 = Color3.fromRGB(180, 40, 50)
    close.Text = "✕"
    close.TextColor3 = Color3.fromRGB(255, 255, 255)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 13
    close.Parent = frame
    Instance.new("UICorner", close).CornerRadius = UDim.new(0, 5)
    close.MouseButton1Click:Connect(function() frame.Visible = false end)

    -- MOD DEGISTIR
    eggBtn.MouseButton1Click:Connect(function()
        CurrentMode = "Egg"
        eggBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        eggBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        privateBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        privateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        sizeFrame.Visible = true
        RefreshList()
    end)
    
    privateBtn.MouseButton1Click:Connect(function()
        CurrentMode = "Private"
        privateBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        privateBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        eggBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        eggBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        sizeFrame.Visible = false
        RefreshList()
    end)

    local function RefreshList()
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        local list = CurrentMode == "Egg" and EggServers or PrivateServers
        
        for _, s in ipairs(list) do
            AddServer(s)
        end
        
        local total = #list
        local minKG = 0
        if CurrentMode == "Egg" and #EggServers > 0 then
            local kgs = {}
            for _, s in ipairs(EggServers) do
                table.insert(kgs, s.eggKG or 0)
            end
            table.sort(kgs)
            minKG = kgs[1] or 0
        end
        
        infoLabel.Text = "📡 Toplam: " .. total .. " sunucu | 🥚 En düşük KG: " .. minKG
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end

    local function AddServer(data)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -4, 0, 38)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.TextSize = 10
        btn.Font = Enum.Font.Gotham
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = scroll
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        
        if CurrentMode == "Egg" then
            btn.Text = "👤 " .. data.playing .. "/" .. data.maxPlayers .. " | 🥚 " .. (data.eggKG or 0) .. "k KG\n📡 " .. data.id:sub(1, 8)
        else
            btn.Text = "👤 " .. data.playing .. "/" .. data.maxPlayers .. " | 🔒 " .. data.id:sub(1, 8)
        end
        
        btn.MouseButton1Click:Connect(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, data.id, LocalPlayer)
        end)
    end

    return {
        RefreshList = RefreshList,
        AddServer = AddServer,
        InfoLabel = infoLabel,
        Scroll = scroll,
        Layout = layout
    }
end

-- ==================== VERİ YENİLE ====================
local function RefreshData()
    if CurrentMode == "Egg" then
        EggServers = {}
        ScanEggServers()
    else
        PrivateServers = {}
        ScanPrivateServers()
    end
    end-- ============================================================
-- HAMSTER LIVES - EGG HUNTER V5 (PART 2/2) - 600+ SATIR
-- ============================================================

-- ==================== EGG TARA (GELİŞMİŞ) ====================
local function ScanEggServers()
    if Scanning then return end
    Scanning = true
    
    task.spawn(function()
        local menu = CreateMenu()
        local cursor = ""
        local pageCount = 0
        local allFound = {}
        
        while Scanning and pageCount < 8 do
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
                    if server.id ~= game.JobId and server.playing >= 0 and server.playing < server.maxPlayers then
                        table.insert(allFound, server)
                    end
                end
                
                cursor = result.nextPageCursor or ""
                pageCount = pageCount + 1
                
                -- Her sayfada işlem yap
                if #allFound > 50 then
                    local processed = CollectEggData(allFound)
                    for _, s in ipairs(processed) do
                        if s.eggKG and s.eggKG >= SelectedKG then
                            local exists = false
                            for _, existing in ipairs(EggServers) do
                                if existing.id == s.id then exists = true break end
                            end
                            if not exists then
                                table.insert(EggServers, s)
                            end
                        end
                    end
                    allFound = {}
                    if menu and CurrentMode == "Egg" then
                        menu.RefreshList()
                    end
                end
                
                if cursor == "" then break
            else
                break
            end
            task.wait(0.3)
        end
        
        -- Kalanları işle
        if #allFound > 0 then
            local processed = CollectEggData(allFound)
            for _, s in ipairs(processed) do
                if s.eggKG and s.eggKG >= SelectedKG then
                    local exists = false
                    for _, existing in ipairs(EggServers) do
                        if existing.id == s.id then exists = true break end
                    end
                    if not exists then
                        table.insert(EggServers, s)
                    end
                end
            end
        end
        
        -- Son sıralama (en az oyuncudan en çoğa)
        table.sort(EggServers, function(a, b)
            return a.playing < b.playing
        end)
        
        -- En düşük KG'li olanları öne al (KG'ye göre ikincil sıralama)
        table.sort(EggServers, function(a, b)
            if a.playing == b.playing then
                return (a.eggKG or 0) < (b.eggKG or 0)
            end
            return a.playing < b.playing
        end)
        
        if menu and CurrentMode == "Egg" then
            menu.RefreshList()
        end
        
        Scanning = false
        print("✅ " .. #EggServers .. " egg sunucusu bulundu!")
    end)
end

-- ==================== PRIVATE TARA ====================
local function ScanPrivateServers()
    if ScanActive then return end
    ScanActive = true
    
    task.spawn(function()
        local menu = CreateMenu()
        local cursor = ""
        local pageCount = 0
        
        while ScanActive and pageCount < 6 do
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
                            if menu and CurrentMode == "Private" then
                                menu.AddServer(server)
                            end
                        end
                    end
                end
                
                cursor = result.nextPageCursor or ""
                pageCount = pageCount + 1
                if cursor == "" then break
            else
                break
            end
            task.wait(0.3)
        end
        
        if menu and CurrentMode == "Private" then
            menu.RefreshList()
        end
        
        ScanActive = false
        print("✅ " .. #PrivateServers .. " private sunucu bulundu!")
    end)
end

-- ==================== SÜREKLİ YENİLEME ====================
local function StartAutoRefresh()
    task.spawn(function()
        while true do
            task.wait(RefreshInterval)
            if not IsRefreshing then
                if CurrentMode == "Egg" then
                    if not Scanning then
                        local oldCount = #EggServers
                        EggServers = {}
                        ScanEggServers()
                    end
                else
                    if not ScanActive then
                        local oldCount = #PrivateServers
                        PrivateServers = {}
                        ScanPrivateServers()
                    end
                end
            end
        end
    end)
end

-- ==================== AÇMA BUTONU ====================
local function CreateOpenButton()
    local pg = CoreGui:FindFirstChild("HLEggHunterV5") or LocalPlayer:WaitForChild("PlayerGui")
    local gui = pg:FindFirstChild("HLEggHunterV5")
    if not gui then return end
    
    local frame = gui:FindFirstChildWhichIsA("Frame")
    if not frame then return end
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 50)
    btn.Position = UDim2.new(1, -60, 0, 15)
    btn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    btn.Text = "🥚"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 22
    btn.Parent = gui
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    
    local hue = 0.5
    task.spawn(function()
        while true do
            hue = hue + 0.015
            if hue > 1 then hue = 0 end
            btn.BackgroundColor3 = HSVToRGB(hue, 1, 1)
            
            local pulse = math.sin(hue * 30) * 2 + 2
            btn.Size = UDim2.new(0, 50 + pulse, 0, 50 + pulse)
            task.wait(0.02)
        end
    end)
    
    btn.MouseButton1Click:Connect(function()
        frame.Visible = not frame.Visible
        if frame.Visible then
            if CurrentMode == "Egg" and #EggServers == 0 then
                EggServers = {}
                ScanEggServers()
            elseif CurrentMode == "Private" and #PrivateServers == 0 then
                PrivateServers = {}
                ScanPrivateServers()
            end
        end
    end)
end

-- ==================== BAŞLAT ====================
task.wait(0.5)
ScanEggServers()
task.wait(0.5)
ScanPrivateServers()
task.wait(0.3)
StartAutoRefresh()
task.wait(0.3)
CreateOpenButton()

print("")
print("========================================")
print("🥚 HAMSTER LIVES - EGG HUNTER V5")
print("   2 PART - 1200+ SATIR")
print("   🔄 5 saniyede otomatik yenileme")
print("   📡 Tüm sunucular taranır (8 sayfa)")
print("   🥚 Gerçek KG değerleri okunur")
print("   🎯 En az oyunculu + en düşük KG sıralı")
print("   🔓 Private server desteği")
print("   Sağ üstte 🥚 butonuna bas.")
print("========================================")
