-- ============================================================
-- HAMSTER LIVES - MINI SERVER FINDER V9 (PART 1/3)
-- 150x150 | SÜRÜKLEYEBİLİR | ANINDA BAĞLANMA | BYPASS YOK
-- ============================================================

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

print("🐹 MINI SERVER FINDER V9 BAŞLADI...")

-- ============================================================
-- KONFIG
-- ============================================================
local VerifiedServers = {}
local ScanningActive = false
local GuiRef = nil
local MenuFrame = nil
local IsDragging = false
local DragStart = nil
local StartPos = nil

-- ============================================================
-- HIZLI HTTP
-- ============================================================
local function SafeHttpGet(url)
    local success, response = pcall(function()
        if syn and syn.request then
            local req = syn.request({Url = url, Method = "GET", Headers = {["Cache-Control"] = "no-cache"}})
            if req and req.Body then return req.Body end
        elseif request then
            local req = request({Url = url, Method = "GET", Headers = {["Cache-Control"] = "no-cache"}})
            if req and req.Body then return req.Body end
        end
        return game:HttpGet(url)
    end)
    if success and response then return response end
    return nil
end

-- ============================================================
-- MINI MENU OLUŞTUR (150x150 SÜRÜKLEYEBİLİR)
-- ============================================================
local function CreateMiniMenu()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then
        pg = Instance.new("ScreenGui")
        pg.Name = "PlayerGui"
        pg.Parent = LocalPlayer
    end
    
    local old = pg:FindFirstChild("MiniServerFinder")
    if old then old:Destroy() end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "MiniServerFinder"
    gui.Parent = pg
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    GuiRef = gui
    
    -- 150x150 MENU (SÜRÜKLEYEBİLİR)
    local menu = Instance.new("Frame")
    menu.Size = UDim2.new(0, 150, 0, 200)
    menu.Position = UDim2.new(0.5, -75, 0.1, 0)
    menu.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    menu.BackgroundTransparency = 0.1
    menu.Parent = gui
    menu.ZIndex = 1000
    menu.Active = true
    menu.Draggable = true
    Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 8)
    MenuFrame = menu
    
    -- İNCE KENARLIK
    local stroke = Instance.new("UIStroke", menu)
    stroke.Thickness = 1.5
    stroke.Color = Color3.fromRGB(180, 0, 0)
    stroke.Transparency = 0.5
    
    -- BAŞLIK (KIRMIZI)
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 22)
    title.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    title.Text = "🐹 HAMSTER"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 10
    title.Font = Enum.Font.GothamBold
    title.Parent = menu
    title.ZIndex = 1001
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)
    
    -- KAPATMA BUTONU (KÜÇÜK)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 18, 0, 18)
    closeBtn.Position = UDim2.new(1, -20, 0, 2)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeBtn.TextSize = 11
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = title
    closeBtn.ZIndex = 1002
    closeBtn.MouseButton1Click:Connect(function()
        GuiRef:Destroy()
        GuiRef = nil
        MenuFrame = nil
        ScanningActive = false
    end)
    
    -- SUNUCU SAYISI
    local countLabel = Instance.new("TextLabel")
    countLabel.Size = UDim2.new(1, 0, 0, 16)
    countLabel.Position = UDim2.new(0, 0, 0, 24)
    countLabel.BackgroundTransparency = 1
    countLabel.Text = "👥 SUNUCU: " .. #VerifiedServers
    countLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    countLabel.TextSize = 9
    countLabel.Font = Enum.Font.Gotham
    countLabel.Parent = menu
    countLabel.ZIndex = 1001
    
    -- SUNUCU LİSTESİ (SCROLL)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -50)
    scroll.Position = UDim2.new(0, 5, 0, 42)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = menu
    scroll.ZIndex = 1001
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Color3.fromRGB(180, 0, 0)
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 3)
    layout.Parent = scroll    -- ============================================================
    -- SUNUCU BUTONU (ANINDA BAĞLANMA)
    -- ============================================================
    local function AddServerButton(server)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -4, 0, 26)
        btn.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
        btn.Text = "👤 " .. server.playing .. "/" .. server.maxPlayers
        btn.TextColor3 = server.playing == 1 and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(200, 200, 200)
        btn.TextSize = 9
        btn.Font = Enum.Font.GothamBold
        btn.Parent = scroll
        btn.ZIndex = 1002
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        
        -- HOVER
        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
        end)
        
        -- ANINDA BAĞLANMA
        btn.MouseButton1Click:Connect(function()
            local serverId = server.id
            btn.Text = "⚡ GİDİYOR..."
            btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            
            task.spawn(function()
                -- GUI'Yİ TEMİZLE
                if GuiRef then
                    pcall(function() GuiRef:Destroy() end)
                    GuiRef = nil
                    MenuFrame = nil
                end
                -- ANINDA BAĞLAN
                TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId, LocalPlayer)
            end)
        end)
    end
    
    -- MEVCUT SUNUCULARI EKLE
    for _, server in ipairs(VerifiedServers) do
        AddServerButton(server)
    end
    
    -- YENİ SUNUCU EKLEME FONKSİYONU
    local function AddNewServer(server)
        AddServerButton(server)
        -- SAYACI GÜNCELLE
        if countLabel then
            countLabel.Text = "👥 SUNUCU: " .. #VerifiedServers
        end
        task.wait(0.05)
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end
    
    -- ============================================================
    -- SÜRÜKLEME (DRAG) SİSTEMİ
    -- ============================================================
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = menu.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging and menu then
            local delta = input.Position - dragStart
            local newX = startPos.X.Offset + delta.X
            local newY = startPos.Y.Offset + delta.Y
            menu.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
        end
    end)
    
    return AddNewServer
end

-- ============================================================
-- SUNUCU TARAMA (HIZLI)
-- ============================================================
local function StartScanning(addServerCallback)
    if ScanningActive then return end
    ScanningActive = true
    
    task.spawn(function()
        local cursor = ""
        local requestCount = 0
        
        while ScanningActive and GuiRef and GuiRef.Parent do
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
            if cursor ~= "" then
                url = url .. "&cursor=" .. cursor
            end
            
            local rawData = SafeHttpGet(url)
            if not rawData then
                task.wait(0.5)
                continue
            end
            
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
                            if addServerCallback then
                                pcall(function() addServerCallback(server) end)
                            end
                        end
                    end
                end
                cursor = result.nextPageCursor or ""
                if cursor == "" then task.wait(1.0)
            else
                task.wait(0.5)
            end
            
            requestCount = requestCount + 1
            if requestCount > 30 then
                task.wait(2.0)
                requestCount = 0
            end
            task.wait(0.3)
        end
    end)
    end-- ============================================================
-- BAŞLAT
-- ============================================================
local function Init()
    -- MENÜYÜ OLUŞTUR
    local addCallback = CreateMiniMenu()
    
    -- TARAMAYI BAŞLAT
    StartScanning(addCallback)
    
    print("🐹 MINI SERVER FINDER V9 HAZIR!")
    print("⚡ ANINDA BAĞLANMA AKTİF!")
    print("🖱️ SÜRÜKLEYEBİLİR MENU!")
end

-- BAŞLAT
task.wait(0.3)
local success, err = pcall(Init)
if not success then
    warn("🐹 HATA:", err)
    print("🐹 HATA DETAYI:", err)
end

print("")
print("========================================")
print("🐹 HAMSTER LIVES - MINI SERVER FINDER V9")
print("   ✅ 150x150 SÜRÜKLEYEBİLİR")
print("   ✅ ANINDA BAĞLANMA")
print("   ✅ BYPASS YOK (TEMİZ)")
print("   ✅ KARANLIK TEMA")
print("   ✅ SADECE SUNUCU LİSTESİ")
print("========================================")
