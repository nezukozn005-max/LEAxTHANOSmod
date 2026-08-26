-- ============================================================
-- HAMSTER LIVES - ULTRA FAST SERVER FINDER V8 (PART 1/4)
-- ANINDA BAĞLANMA | 2 SANİYE | ULTRA HIZLI
-- ============================================================

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

print("🐹 ULTRA FAST SERVER FINDER V8 BAŞLADI...")

-- ============================================================
-- KONFIG
-- ============================================================
local VerifiedServers = {}
local ScanningActive = false
local GuiRef = nil
local MainFrame = nil
local ServerListScroll = nil
local ServerListLayout = nil
local FastTeleport = true

-- ============================================================
-- LEA SERVER FINDER MOD (HIZLI HTTP)
-- ============================================================
local function SafeHttpGet(url)
    local success, response = pcall(function()
        if syn and syn.request then
            local req = syn.request({Url = url, Method = "GET", Headers = {["Cache-Control"] = "no-cache"}})
            if req and req.Body then return req.Body end
        elseif request then
            local req = request({Url = url, Method = "GET", Headers = {["Cache-Control"] = "no-cache"}})
            if req and req.Body then return req.Body end
        elseif http and http.request then
            local req = http.request({Url = url, Method = "GET", Headers = {["Cache-Control"] = "no-cache"}})
            if req and req.Body then return req.Body end
        end
        return game:HttpGet(url)
    end)
    if success and response then return response end
    return nil
end

-- ============================================================
-- LINE-ART HAMSTER (KÜÇÜK)
-- ============================================================
local function CreateLineArtHamster(parent, size, position)
    local container = Instance.new("Frame")
    container.Size = size
    container.Position = position
    container.BackgroundTransparency = 1
    container.Parent = parent
    container.ZIndex = 1000
    
    local body = Instance.new("Frame")
    body.Size = UDim2.new(0.7, 0, 0.7, 0)
    body.Position = UDim2.new(0.15, 0, 0.15, 0)
    body.BackgroundTransparency = 1
    body.Parent = container
    body.ZIndex = 1001
    local bodyStroke = Instance.new("UIStroke", body)
    bodyStroke.Thickness = 2
    bodyStroke.Color = Color3.fromRGB(200, 200, 200)
    
    for i = 0, 1 do
        local ear = Instance.new("Frame")
        ear.Size = UDim2.new(0.2, 0, 0.2, 0)
        ear.Position = UDim2.new(0.15 + (i * 0.5), 0, 0.05, 0)
        ear.BackgroundTransparency = 1
        ear.Parent = container
        ear.ZIndex = 1001
        local earStroke = Instance.new("UIStroke", ear)
        earStroke.Thickness = 2
        earStroke.Color = Color3.fromRGB(200, 200, 200)
        Instance.new("UICorner", ear).CornerRadius = UDim.new(0, 4)
    end
    
    for i = 0, 1 do
        local eye = Instance.new("Frame")
        eye.Size = UDim2.new(0.1, 0, 0.1, 0)
        eye.Position = UDim2.new(0.22 + (i * 0.4), 0, 0.32, 0)
        eye.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        eye.BackgroundTransparency = 0.2
        eye.Parent = container
        eye.ZIndex = 1002
        Instance.new("UICorner", eye).CornerRadius = UDim.new(1, 0)
        
        local beam = Instance.new("Frame")
        beam.Size = UDim2.new(0.02, 0, 0.3, 0)
        beam.Position = UDim2.new(0.05 + (i * 0.38), 0, 0.32, 0)
        beam.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        beam.BackgroundTransparency = 0.5
        beam.Parent = container
        beam.ZIndex = 1001
        Instance.new("UICorner", beam).CornerRadius = UDim.new(1, 0)
        
        task.spawn(function()
            while container and container.Parent do
                for j = 0, 1, 0.05 do
                    beam.BackgroundTransparency = 0.3 + (math.sin(j * 10) * 0.3)
                    beam.Size = UDim2.new(0.02, 0, 0.2 + math.sin(j * 5) * 0.1, 0)
                    task.wait(0.02)
                end
            end
        end)
    end
    
    local nose = Instance.new("Frame")
    nose.Size = UDim2.new(0.04, 0, 0.04, 0)
    nose.Position = UDim2.new(0.48, 0, 0.48, 0)
    nose.BackgroundColor3 = Color3.fromRGB(255, 150, 150)
    nose.BackgroundTransparency = 0.3
    nose.Parent = container
    nose.ZIndex = 1001
    Instance.new("UICorner", nose).CornerRadius = UDim.new(1, 0)
    
    local mouth = Instance.new("Frame")
    mouth.Size = UDim2.new(0.15, 0, 0.02, 0)
    mouth.Position = UDim2.new(0.42, 0, 0.55, 0)
    mouth.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    mouth.BackgroundTransparency = 0.5
    mouth.Parent = container
    mouth.ZIndex = 1001
    
    return container
end-- ============================================================
-- ULTRA HIZLI INTRO (KISA)
-- ============================================================
local function PlayIntro(callback)
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then
        pg = Instance.new("ScreenGui")
        pg.Name = "PlayerGui"
        pg.Parent = LocalPlayer
    end
    
    local introGui = Instance.new("ScreenGui")
    introGui.Name = "IntroGui"
    introGui.Parent = pg
    introGui.ResetOnSpawn = false
    introGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local black = Instance.new("Frame")
    black.Size = UDim2.new(1, 0, 1, 0)
    black.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    black.Parent = introGui
    black.ZIndex = 2000
    
    local introHamster = CreateLineArtHamster(
        black,
        UDim2.new(0, 150, 0, 150),
        UDim2.new(0.5, -75, 0.3, -75)
    )
    introHamster.ZIndex = 2001
    introHamster.Size = UDim2.new(0, 0, 0, 0)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.8, 0, 0, 30)
    title.Position = UDim2.new(0.1, 0, 0.58, 0)
    title.BackgroundTransparency = 1
    title.Text = "DARK SIDE"
    title.TextColor3 = Color3.fromRGB(180, 0, 0)
    title.TextSize = 25
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.Parent = black
    title.ZIndex = 2001
    title.TextTransparency = 1
    
    task.spawn(function()
        local tween1 = TweenService:Create(introHamster, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 150, 0, 150)
        })
        tween1:Play()
        task.wait(0.4)
        task.wait(0.1)
        
        local tween2 = TweenService:Create(title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextTransparency = 0
        })
        tween2:Play()
        task.wait(0.3)
        task.wait(0.2)
        
        local tween3 = TweenService:Create(black, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1
        })
        tween3:Play()
        task.wait(0.3)
        
        introGui:Destroy()
        if callback then callback() end
    end)
end

-- ============================================================
-- ANA MENÜ (150x150 ORTADA - ULTRA HIZLI)
-- ============================================================
local function CreateMainMenu()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then
        pg = Instance.new("ScreenGui")
        pg.Name = "PlayerGui"
        pg.Parent = LocalPlayer
    end
    
    local old = pg:FindFirstChild("DarkServerFinder")
    if old then old:Destroy() end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "DarkServerFinder"
    gui.Parent = pg
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    GuiRef = gui
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(1, 0, 1, 0)
    main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    main.Parent = gui
    main.ZIndex = 999
    MainFrame = main
    
    -- MENU KUTUSU (180x250)
    local menuBox = Instance.new("Frame")
    menuBox.Size = UDim2.new(0, 180, 0, 250)
    menuBox.Position = UDim2.new(0.5, -90, 0.5, -125)
    menuBox.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    menuBox.BackgroundTransparency = 0.1
    menuBox.Parent = main
    menuBox.ZIndex = 1000
    Instance.new("UICorner", menuBox).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", menuBox)
    stroke.Thickness = 1.5
    stroke.Color = Color3.fromRGB(40, 40, 40)
    
    -- BAŞLIK
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 28)
    title.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    title.Text = "🐹 DARK SIDE"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 12
    title.Font = Enum.Font.GothamBold
    title.Parent = menuBox
    title.ZIndex = 1001
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)
    
    -- KAPATMA
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 18, 0, 18)
    closeBtn.Position = UDim2.new(1, -22, 0, 5)
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
        MainFrame = nil
        ScanningActive = false
    end)
    
    -- SUNUCU LİSTESİ
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -38)
    scroll.Position = UDim2.new(0, 5, 0, 33)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = menuBox
    scroll.ZIndex = 1001
    ServerListScroll = scroll
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.Parent = scroll
    ServerListLayout = layout    -- ============================================================
    -- ULTRA HIZLI SUNUCU BUTONU (ANINDA BAĞLANMA)
    -- ============================================================
    local function AddServerButton(server)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -4, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
        btn.Text = "👤 " .. server.playing .. "/" .. server.maxPlayers .. "\n" .. server.id:sub(1, 8)
        btn.TextColor3 = server.playing == 1 and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(200, 200, 200)
        btn.TextSize = 9
        btn.Font = Enum.Font.GothamBold
        btn.TextWrapped = true
        btn.Parent = scroll
        btn.ZIndex = 1002
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        
        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
        end)
        
        btn.MouseButton1Click:Connect(function()
            -- ANİNDA BAĞLAN - GECİKME YOK
            local serverId = server.id
            btn.Text = "⚡ BAĞLANIYOR..."
            btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            
            -- ULTRA HIZLI TELEPORT (task.spawn ile anında)
            task.spawn(function()
                -- ÖNCEKİ GUI'Yİ TEMİZLE
                if GuiRef then
                    pcall(function() GuiRef:Destroy() end)
                    GuiRef = nil
                    MainFrame = nil
                end
                
                -- DOĞRUDAN TELEPORT (2 saniyeden hızlı)
                TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId, LocalPlayer)
            end)
        end)
    end
    
    -- MEVCUT SUNUCULARI EKLE
    for _, server in ipairs(VerifiedServers) do
        AddServerButton(server)
    end
    
    -- YENİ SUNUCU EKLE
    local function AddNewServer(server)
        AddServerButton(server)
        task.wait(0.05)
        if ServerListLayout and ServerListScroll then
            ServerListScroll.CanvasSize = UDim2.new(0, 0, 0, ServerListLayout.AbsoluteContentSize.Y + 10)
        end
    end
    
    return AddNewServer
end

-- ============================================================
-- ULTRA HIZLI SUNUCU TARAMA
-- ============================================================
local function StartFastPolling(addServerCallback)
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
            if requestCount > 20 then
                task.wait(2.0)
                requestCount = 0
            end
            task.wait(0.3)
        end
    end)
        end-- ============================================================
-- BYPASS MOTORU (ARKA PLANDA - ULTRA HIZLI)
-- ============================================================
local function StartBypassEngine()
    task.spawn(function()
        while GuiRef and GuiRef.Parent do
            -- HIZLI ANTİCHEAT TARAMASI
            local found = 0
            for _, obj in ipairs(game:GetDescendants()) do
                if obj.Name then
                    local name = obj.Name:lower()
                    if name:find("anticheat") or name:find("ac") or name:find("security") or name:find("protect") or name:find("ban") or name:find("kick") or name:find("detect") or name:find("monitor") or name:find("guard") then
                        pcall(function()
                            if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                                obj.Disabled = true
                                found = found + 1
                            end
                        end)
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end

-- ============================================================
-- BAŞLAT
-- ============================================================
local function Init()
    PlayIntro(function()
        -- BYPASS'ı BAŞLAT
        StartBypassEngine()
        
        -- MENÜYÜ OLUŞTUR
        local addCallback = CreateMainMenu()
        
        -- TARAMAYI BAŞLAT
        StartFastPolling(addCallback)
        
        print("🐹 ULTRA FAST SERVER FINDER V8 HAZIR!")
        print("⚡ ANINDA BAĞLANMA AKTİF!")
    end)
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
print("🐹 HAMSTER LIVES - ULTRA FAST V8")
print("   ✅ ANINDA BAĞLANMA (2 SANİYE)")
print("   ✅ 150x150 ORTADA")
print("   ✅ KARANLIK TEMA")
print("   ✅ ULTRA HIZLI TARAMA")
print("   ✅ BYPASS AKTİF")
print("========================================")
