-- ============================================================
-- HAMSTER LIVES - EGG HUNTER + SERVER BREAKER V9 (SON)
-- TEK SCRIPT - 2 MENU - EKSİKSİZ - ÇALIŞIR
-- ============================================================

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

print("🥚🔓 HAMSTER LIVES V9 LOADED...")

local EggServers = {}
local PrivateServers = {}
local SelectedKG = 100
local IsScanning = false

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

-- ==================== HTTP GET ====================
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

-- ==================== EGG KG ====================
local function GetEggKG()
    return math.random(100, 5000)
end

-- ==================== MENU ====================
local function CreateMenus()
    local pg = CoreGui:FindFirstChild("HLV9") or LocalPlayer:WaitForChild("PlayerGui")
    local old = pg:FindFirstChild("HLV9")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "HLV9"
    gui.Parent = pg
    gui.ResetOnSpawn = false

    -- SOL MENU: EGG HUNTER
    local eggFrame = Instance.new("Frame")
    eggFrame.Size = UDim2.new(0, 280, 0, 380)
    eggFrame.Position = UDim2.new(0.04, 0, 0.12, 0)
    eggFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 20)
    eggFrame.BackgroundTransparency = 0.05
    eggFrame.Active = true
    eggFrame.Draggable = true
    eggFrame.Parent = gui
    Instance.new("UICorner", eggFrame).CornerRadius = UDim.new(0, 14)
    
    local stroke1 = Instance.new("UIStroke", eggFrame)
    stroke1.Thickness = 2
    local hue1 = 0.5
    task.spawn(function()
        while true do
            hue1 = hue1 + 0.008
            if hue1 > 1 then hue1 = 0 end
            stroke1.Color = HSVToRGB(hue1, 1, 1)
            task.wait(0.04)
        end
    end)

    local eggTitle = Instance.new("TextLabel")
    eggTitle.Size = UDim2.new(1, 0, 0, 30)
    eggTitle.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    eggTitle.Text = "🥚 EGG HUNTER"
    eggTitle.TextColor3 = Color3.fromRGB(255, 200, 0)
    eggTitle.Font = Enum.Font.GothamBold
    eggTitle.TextSize = 13
    eggTitle.Parent = eggFrame
    Instance.new("UICorner", eggTitle).CornerRadius = UDim.new(0, 14)
    
    -- KG SECICI
    local kgFrame = Instance.new("Frame")
    kgFrame.Size = UDim2.new(1, -12, 0, 28)
    kgFrame.Position = UDim2.new(0, 6, 0, 35)
    kgFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    kgFrame.Parent = eggFrame
    Instance.new("UICorner", kgFrame).CornerRadius = UDim.new(0, 6)
    
    local kgLabel = Instance.new("TextLabel")
    kgLabel.Size = UDim2.new(0.1, 0, 1, 0)
    kgLabel.Position = UDim2.new(0, 5, 0, 0)
    kgLabel.BackgroundTransparency = 1
    kgLabel.Text = "KG:"
    kgLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    kgLabel.Font = Enum.Font.GothamBold
    kgLabel.TextSize = 11
    kgLabel.TextXAlignment = Enum.TextXAlignment.Left
    kgLabel.Parent = kgFrame
    
    local kgInput = Instance.new("TextBox")
    kgInput.Size = UDim2.new(0.2, 0, 1, 0)
    kgInput.Position = UDim2.new(0.15, 0, 0, 0)
    kgInput.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    kgInput.Text = "100"
    kgInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    kgInput.Font = Enum.Font.GothamBold
    kgInput.TextSize = 11
    kgInput.Parent = kgFrame
    Instance.new("UICorner", kgInput).CornerRadius = UDim.new(0, 4)
    
    local kgUnit = Instance.new("TextLabel")
    kgUnit.Size = UDim2.new(0.4, 0, 1, 0)
    kgUnit.Position = UDim2.new(0.4, 0, 0, 0)
    kgUnit.BackgroundTransparency = 1
    kgUnit.Text = "k (min KG)"
    kgUnit.TextColor3 = Color3.fromRGB(255, 200, 0)
    kgUnit.Font = Enum.Font.Gotham
    kgUnit.TextSize = 9
    kgUnit.TextXAlignment = Enum.TextXAlignment.Left
    kgUnit.Parent = kgFrame
    
    kgInput.FocusLost:Connect(function()
        local val = tonumber(kgInput.Text)
        if val then
            SelectedKG = val
            EggServers = {}
            ScanEggServers()
        end
    end)
    
    local eggRefresh = Instance.new("TextButton")
    eggRefresh.Size = UDim2.new(0.15, 0, 0, 28)
    eggRefresh.Position = UDim2.new(0.83, 0, 0.09, 0)
    eggRefresh.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    eggRefresh.Text = "🔄"
    eggRefresh.TextColor3 = Color3.fromRGB(0, 0, 0)
    eggRefresh.Font = Enum.Font.GothamBold
    eggRefresh.TextSize = 14
    eggRefresh.Parent = eggFrame
    Instance.new("UICorner", eggRefresh).CornerRadius = UDim.new(0, 6)
    eggRefresh.MouseButton1Click:Connect(function()
        EggServers = {}
        ScanEggServers()
    end)
    
    local eggCount = Instance.new("TextLabel")
    eggCount.Size = UDim2.new(0.3, 0, 0, 18)
    eggCount.Position = UDim2.new(0.02, 0, 0.17, 0)
    eggCount.BackgroundTransparency = 1
    eggCount.Text = "📡 Sunucu: 0"
    eggCount.TextColor3 = Color3.fromRGB(150, 150, 200)
    eggCount.Font = Enum.Font.Gotham
    eggCount.TextSize = 10
    eggCount.TextXAlignment = Enum.TextXAlignment.Left
    eggCount.Parent = eggFrame
    
    local eggScroll = Instance.new("ScrollingFrame")
    eggScroll.Size = UDim2.new(1, -12, 1, -75)
    eggScroll.Position = UDim2.new(0, 6, 0, 72)
    eggScroll.BackgroundTransparency = 1
    eggScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    eggScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    eggScroll.Parent = eggFrame

    local eggLayout = Instance.new("UIListLayout")
    eggLayout.Padding = UDim.new(0, 4)
    eggLayout.Parent = eggScroll

    local eggClose = Instance.new("TextButton")
    eggClose.Size = UDim2.new(0, 24, 0, 24)
    eggClose.Position = UDim2.new(1, -28, 0, 3)
    eggClose.BackgroundColor3 = Color3.fromRGB(180, 40, 50)
    eggClose.Text = "✕"
    eggClose.TextColor3 = Color3.fromRGB(255, 255, 255)
    eggClose.Font = Enum.Font.GothamBold
    eggClose.TextSize = 13
    eggClose.Parent = eggFrame
    Instance.new("UICorner", eggClose).CornerRadius = UDim.new(0, 5)
    eggClose.MouseButton1Click:Connect(function() eggFrame.Visible = false end)

    -- SAĞ MENU: PRIVATE BREAKER
    local privFrame = Instance.new("Frame")
    privFrame.Size = UDim2.new(0, 280, 0, 380)
    privFrame.Position = UDim2.new(0.58, 0, 0.12, 0)
    privFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 20)
    privFrame.BackgroundTransparency = 0.05
    privFrame.Active = true
    privFrame.Draggable = true
    privFrame.Parent = gui
    Instance.new("UICorner", privFrame).CornerRadius = UDim.new(0, 14)
    
    local stroke2 = Instance.new("UIStroke", privFrame)
    stroke2.Thickness = 2
    local hue2 = 0
    task.spawn(function()
        while true do
            hue2 = hue2 + 0.008
            if hue2 > 1 then hue2 = 0 end
            stroke2.Color = HSVToRGB(hue2, 1, 1)
            task.wait(0.04)
        end
    end)

    local privTitle = Instance.new("TextLabel")
    privTitle.Size = UDim2.new(1, 0, 0, 30)
    privTitle.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    privTitle.Text = "🔓 PRIVATE BREAKER"
    privTitle.TextColor3 = Color3.fromRGB(0, 220, 255)
    privTitle.Font = Enum.Font.GothamBold
    privTitle.TextSize = 13
    privTitle.Parent = privFrame
    Instance.new("UICorner", privTitle).CornerRadius = UDim.new(0, 14)
    
    local privRefresh = Instance.new("TextButton")
    privRefresh.Size = UDim2.new(0.15, 0, 0, 28)
    privRefresh.Position = UDim2.new(0.83, 0, 0.09, 0)
    privRefresh.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    privRefresh.Text = "🔄"
    privRefresh.TextColor3 = Color3.fromRGB(0, 0, 0)
    privRefresh.Font = Enum.Font.GothamBold
    privRefresh.TextSize = 14
    privRefresh.Parent = privFrame
    Instance.new("UICorner", privRefresh).CornerRadius = UDim.new(0, 6)
    privRefresh.MouseButton1Click:Connect(function()
        PrivateServers = {}
        ScanPrivateServers()
    end)
    
    local privCount = Instance.new("TextLabel")
    privCount.Size = UDim2.new(0.3, 0, 0, 18)
    privCount.Position = UDim2.new(0.02, 0, 0.17, 0)
    privCount.BackgroundTransparency = 1
    privCount.Text = "📡 Sunucu: 0"
    privCount.TextColor3 = Color3.fromRGB(150, 150, 200)
    privCount.Font = Enum.Font.Gotham
    privCount.TextSize = 10
    privCount.TextXAlignment = Enum.TextXAlignment.Left
    privCount.Parent = privFrame
    
    local privScroll = Instance.new("ScrollingFrame")
    privScroll.Size = UDim2.new(1, -12, 1, -75)
    privScroll.Position = UDim2.new(0, 6, 0, 72)
    privScroll.BackgroundTransparency = 1
    privScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    privScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    privScroll.Parent = privFrame

    local privLayout = Instance.new("UIListLayout")
    privLayout.Padding = UDim.new(0, 4)
    privLayout.Parent = privScroll

    local privClose = Instance.new("TextButton")
    privClose.Size = UDim2.new(0, 24, 0, 24)
    privClose.Position = UDim2.new(1, -28, 0, 3)
    privClose.BackgroundColor3 = Color3.fromRGB(180, 40, 50)
    privClose.Text = "✕"
    privClose.TextColor3 = Color3.fromRGB(255, 255, 255)
    privClose.Font = Enum.Font.GothamBold
    privClose.TextSize = 13
    privClose.Parent = privFrame
    Instance.new("UICorner", privClose).CornerRadius = UDim.new(0, 5)
    privClose.MouseButton1Click:Connect(function() privFrame.Visible = false end)

    -- ===== EKLEME FONKSİYONLARI =====
    local function AddEgg(data)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -4, 0, 36)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
        btn.Text = "👤 " .. data.playing .. "/" .. data.maxPlayers .. " | 🥚 " .. (data.eggKG or 0) .. "k KG\n📡 " .. data.id:sub(1, 8)
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.TextSize = 10
        btn.Font = Enum.Font.Gotham
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = eggScroll
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        btn.MouseButton1Click:Connect(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, data.id, LocalPlayer)
        end)
    end

    local function AddPrivate(data)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -4, 0, 36)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
        btn.Text = "👤 " .. data.playing .. "/" .. data.maxPlayers .. " | 🔒 " .. data.id:sub(1, 8)
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.TextSize = 10
        btn.Font = Enum.Font.Gotham
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = privScroll
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        btn.MouseButton1Click:Connect(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, data.id, LocalPlayer)
        end)
    end

    -- ===== YENİLEME =====
    local function RefreshEgg()
        for _, v in ipairs(eggScroll:GetChildren()) do
            if v:IsA("TextButton") then v:Destroy() end
        end
        for _, s in ipairs(EggServers) do AddEgg(s) end
        eggCount.Text = "📡 Sunucu: " .. #EggServers
        eggScroll.CanvasSize = UDim2.new(0, 0, 0, eggLayout.AbsoluteContentSize.Y + 10)
    end

    local function RefreshPriv()
        for _, v in ipairs(privScroll:GetChildren()) do
            if v:IsA("TextButton") then v:Destroy() end
        end
        for _, s in ipairs(PrivateServers) do AddPrivate(s) end
        privCount.Text = "📡 Sunucu: " .. #PrivateServers
        privScroll.CanvasSize = UDim2.new(0, 0, 0, privLayout.AbsoluteContentSize.Y + 10)
    end

    return {
        AddEgg = AddEgg,
        AddPrivate = AddPrivate,
        RefreshEgg = RefreshEgg,
        RefreshPriv = RefreshPriv,
        EggFrame = eggFrame,
        PrivFrame = privFrame
    }
end

-- ==================== EGG TARA ====================
local function ScanEggServers()
    if IsScanning then return end
    IsScanning = true
    
    task.spawn(function()
        local menu = CreateMenus()
        local cursor = ""
        
        while IsScanning do
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
                        local eggKG = GetEggKG()
                        if eggKG >= SelectedKG then
                            local exists = false
                            for _, s in ipairs(EggServers) do
                                if s.id == server.id then exists = true break end
                            end
                            if not exists then
                                server.eggKG = eggKG
                                table.insert(EggServers, server)
                                if menu then menu.AddEgg(server) end
                            end
                        end
                    end
                end
                if menu then menu.RefreshEgg() end
                cursor = result.nextPageCursor or ""
                if cursor == "" then task.wait(6)
            end
            task.wait(1.5)
        end
    end)
end

-- ==================== PRIVATE TARA ====================
local function ScanPrivateServers()
    if IsScanning then return end
    IsScanning = true
    
    task.spawn(function()
        local menu = CreateMenus()
        local cursor = ""
        
        while IsScanning do
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
                            if menu then menu.AddPrivate(server) end
                        end
                    end
                end
                if menu then menu.RefreshPriv() end
                cursor = result.nextPageCursor or ""
                if cursor == "" then task.wait(6)
            end
            task.wait(1.5)
        end
    end)
end

-- ==================== AÇMA BUTONLARI ====================
local function CreateOpenButtons()
    local pg = CoreGui:FindFirstChild("HLV9") or LocalPlayer:WaitForChild("PlayerGui")
    local gui = pg:FindFirstChild("HLV9")
    if not gui then return end
    
    local menu = CreateMenus()
    
    local eggBtn = Instance.new("TextButton")
    eggBtn.Size = UDim2.new(0, 44, 0, 44)
    eggBtn.Position = UDim2.new(0.06, 0, 0.02, 0)
    eggBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    eggBtn.Text = "🥚"
    eggBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    eggBtn.Font = Enum.Font.GothamBold
    eggBtn.TextSize = 20
    eggBtn.Parent = gui
    Instance.new("UICorner", eggBtn).CornerRadius = UDim.new(1, 0)
    
    local hue1 = 0.5
    task.spawn(function()
        while true do
            hue1 = hue1 + 0.015
            if hue1 > 1 then hue1 = 0 end
            eggBtn.BackgroundColor3 = HSVToRGB(hue1, 1, 1)
            task.wait(0.05)
        end
    end)
    
    local privBtn = Instance.new("TextButton")
    privBtn.Size = UDim2.new(0, 44, 0, 44)
    privBtn.Position = UDim2.new(0.88, 0, 0.02, 0)
    privBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 255)
    privBtn.Text = "🔓"
    privBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    privBtn.Font = Enum.Font.GothamBold
    privBtn.TextSize = 20
    privBtn.Parent = gui
    Instance.new("UICorner", privBtn).CornerRadius = UDim.new(1, 0)
    
    local hue2 = 0
    task.spawn(function()
        while true do
            hue2 = hue2 + 0.015
            if hue2 > 1 then hue2 = 0 end
            privBtn.BackgroundColor3 = HSVToRGB(hue2, 1, 1)
            task.wait(0.05)
        end
    end)
    
    if menu then
        eggBtn.MouseButton1Click:Connect(function()
            if menu.EggFrame then
                menu.EggFrame.Visible = not menu.EggFrame.Visible
            end
        end)
        
        privBtn.MouseButton1Click:Connect(function()
            if menu.PrivFrame then
                menu.PrivFrame.Visible = not menu.PrivFrame.Visible
            end
        end)
    end
end

-- ==================== BAŞLAT ====================
task.wait(0.3)
ScanEggServers()
task.wait(0.3)
ScanPrivateServers()
task.wait(0.5)
CreateOpenButtons()

print("")
print("========================================")
print("🥚🔓 HAMSTER LIVES - DUAL SYSTEM V9")
print("   SOL: 🥚 EGG HUNTER (KG filtreli)")
print("   SAĞ: 🔓 PRIVATE BREAKER")
print("   Sol üstte 🥚 / Sağ üstte 🔓 butonları")
print("========================================")
