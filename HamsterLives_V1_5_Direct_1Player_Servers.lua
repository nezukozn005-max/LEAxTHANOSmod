-- ============================================================
-- HAMSTER LIVES - ULTRA FAST SERVER FINDER V2
-- 1 KİŞİLİK | ANINDA LİSTE | SÜREKLİ YENİLENİR
-- ============================================================

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

print("🐹 ULTRA FAST SERVER FINDER V2 BAŞLADI...")

local OnePlayerServers = {}
local ScanningActive = false
local GuiRef = nil
local ServerListFrame = nil
local ServerListScroll = nil
local ServerListLayout = nil
local CountLabel = nil

-- ============================================================
-- HIZLI HTTP
-- ============================================================
local function FastHttpGet(url)
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    if success and response then return response end
    return nil
end

-- ============================================================
-- MENU OLUŞTUR (SÜRÜKLEYEBİLİR - OTOMATİK LİSTE)
-- ============================================================
local function CreateServerMenu()
    local old = CoreGui:FindFirstChild("FastServerFinder")
    if old then old:Destroy() end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "FastServerFinder"
    gui.Parent = CoreGui
    gui.ResetOnSpawn = false
    GuiRef = gui

    local menu = Instance.new("Frame")
    menu.Size = UDim2.new(0, 160, 0, 220)
    menu.Position = UDim2.new(0.5, -80, 0.1, 0)
    menu.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    menu.BackgroundTransparency = 0.1
    menu.Parent = gui
    menu.Active = true
    menu.Draggable = true
    Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 8)
    ServerListFrame = menu

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 22)
    title.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    title.Text = "⚡ 1 KİŞİLİK"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 10
    title.Font = Enum.Font.GothamBold
    title.Parent = menu
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 18, 0, 18)
    closeBtn.Position = UDim2.new(1, -20, 0, 2)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeBtn.TextSize = 11
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = title
    closeBtn.MouseButton1Click:Connect(function()
        ScanningActive = false
        if GuiRef then GuiRef:Destroy() end
        GuiRef = nil
    end)

    CountLabel = Instance.new("TextLabel")
    CountLabel.Size = UDim2.new(1, 0, 0, 16)
    CountLabel.Position = UDim2.new(0, 0, 0, 24)
    CountLabel.BackgroundTransparency = 1
    CountLabel.Text = "👥 1 KİŞİLİK: 0"
    CountLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    CountLabel.TextSize = 9
    CountLabel.Font = Enum.Font.GothamBold
    CountLabel.Parent = menu

    ServerListScroll = Instance.new("ScrollingFrame")
    ServerListScroll.Size = UDim2.new(1, -10, 1, -50)
    ServerListScroll.Position = UDim2.new(0, 5, 0, 42)
    ServerListScroll.BackgroundTransparency = 1
    ServerListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    ServerListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ServerListScroll.Parent = menu
    ServerListScroll.ScrollBarThickness = 3
    ServerListScroll.ScrollBarImageColor3 = Color3.fromRGB(180, 0, 0)

    ServerListLayout = Instance.new("UIListLayout")
    ServerListLayout.Padding = UDim.new(0, 3)
    ServerListLayout.Parent = ServerListScroll

    -- MEVCUT SUNUCULARI EKLE
    for _, server in ipairs(OnePlayerServers) do
        AddServerButton(server)
    end
    UpdateCount()

    return menu
end

-- ============================================================
-- SUNUCU BUTONU EKLE
-- ============================================================
local function AddServerButton(server)
    if not ServerListScroll then return end
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 24)
    btn.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    btn.Text = "🎯 " .. server.id:sub(1, 8)
    btn.TextColor3 = Color3.fromRGB(255, 200, 0)
    btn.TextSize = 9
    btn.Font = Enum.Font.GothamBold
    btn.Parent = ServerListScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local idLabel = Instance.new("TextLabel")
    idLabel.Size = UDim2.new(0.4, 0, 0, 14)
    idLabel.Position = UDim2.new(0.6, 0, 0.5, -7)
    idLabel.BackgroundTransparency = 1
    idLabel.Text = "👤 1/" .. server.maxPlayers
    idLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    idLabel.TextSize = 8
    idLabel.Font = Enum.Font.Gotham
    idLabel.TextXAlignment = Enum.TextXAlignment.Right
    idLabel.Parent = btn
    idLabel.ZIndex = 1001

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    end)

    btn.MouseButton1Click:Connect(function()
        local serverId = server.id
        btn.Text = "⚡ BAĞLAN..."
        btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)

        task.spawn(function()
            if GuiRef then pcall(function() GuiRef:Destroy() end) end
            GuiRef = nil
            TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId, LocalPlayer)
        end)
    end)
end

-- ============================================================
-- SAYACI GÜNCELLE
-- ============================================================
local function UpdateCount()
    if CountLabel then
        CountLabel.Text = "👥 1 KİŞİLİK: " .. #OnePlayerServers
    end
end

-- ============================================================
-- SUNUCU TARAMA (SÜREKLİ - SADECE 1 KİŞİLİK)
-- ============================================================
local function StartFastScanning()
    if ScanningActive then return end
    ScanningActive = true
    
    task.spawn(function()
        local cursor = ""
        local checkedIds = {}
        
        while ScanningActive and GuiRef and GuiRef.Parent do
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
            if cursor ~= "" then
                url = url .. "&cursor=" .. cursor
            end

            local rawData = FastHttpGet(url)
            if rawData then
                local success, result = pcall(function()
                    return HttpService:JSONDecode(rawData)
                end)

                if success and result and result.data then
                    for _, server in ipairs(result.data) do
                        if server.id ~= game.JobId and server.playing == 1 and server.playing < server.maxPlayers then
                            local exists = false
                            for _, s in ipairs(OnePlayerServers) do
                                if s.id == server.id then 
                                    exists = true 
                                    break 
                                end
                            end
                            if not exists then
                                table.insert(OnePlayerServers, server)
                                AddServerButton(server)
                                UpdateCount()
                                print("✅ 1 KİŞİLİK SUNUCU: " .. server.id:sub(1, 8))
                            end
                        end
                    end
                    cursor = result.nextPageCursor or ""
                    if cursor == "" then 
                        task.wait(1)
                    else
                        task.wait(0.3)
                    end
                else
                    task.wait(0.5)
                end
            else
                task.wait(0.5)
            end
            task.wait(0.2)
        end
    end)
end

-- ============================================================
-- AÇMA BUTONU
-- ============================================================
local function CreateOpenButton()
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 38, 0, 38)
    btn.Position = UDim2.new(0.5, -19, 0.85, 0)
    btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    btn.Text = "⚡"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 18
    btn.Font = Enum.Font.GothamBold
    btn.Parent = CoreGui
    btn.ZIndex = 999
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    
    local menuVisible = true
    
    btn.MouseButton1Click:Connect(function()
        if GuiRef then
            if menuVisible then
                GuiRef.Enabled = false
                menuVisible = false
            else
                GuiRef.Enabled = true
                menuVisible = true
            end
        else
            CreateServerMenu()
            StartFastScanning()
            menuVisible = true
        end
    end)
    
    return btn
end

-- ============================================================
-- BAŞLAT
-- ============================================================
task.wait(0.5)

CreateServerMenu()
StartFastScanning()
CreateOpenButton()

print("")
print("========================================")
print("⚡ ULTRA FAST SERVER FINDER V2")
print("   ✅ SADECE 1 KİŞİLİK SUNUCULAR")
print("   ✅ ANINDA LİSTE")
print("   ✅ SÜREKLİ TAZE")
print("   ✅ AÇ/KAPA BUTONU")
print("========================================")
