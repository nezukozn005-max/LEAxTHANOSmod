-- ============================================
-- HAMSTER LIVES - ANIMATED SERVER FINDER
-- ============================================

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

print("🐹 [HAMSTER LIVES] Animated Server Finder başlatılıyor...")

local VerifiedServers = {}
local ScanningActive = false
local MenuOpen = false
local Gui = nil
local MainFrame = nil
local TitleLabel = nil
local ToggleBtn = nil

-- RGB Renk Fonksiyonu
local function GetRGB(t)
    local r = math.sin(t * 2) * 0.5 + 0.5
    local g = math.sin(t * 2 + 2) * 0.5 + 0.5
    local b = math.sin(t * 2 + 4) * 0.5 + 0.5
    return Color3.new(r, g, b)
end

-- Güvenli HTTP
local function SafeHttpGet(url)
    local success, response = pcall(function()
        if syn and syn.request then
            local req = syn.request({Url = url, Method = "GET"})
            if req and req.Body then return req.Body end
        elseif request then
            local req = request({Url = url, Method = "GET"})
            if req and req.Body then return req.Body end
        elseif http and http.request then
            local req = http.request({Url = url, Method = "GET"})
            if req and req.Body then return req.Body end
        end
        return game:HttpGet(url)
    end)
    if success and response then return response end
    return nil
end

-- GUI Oluşturma
local function CreateGUI()
    local pg = CoreGui:FindFirstChild("HamsterLivesGui") or LocalPlayer:WaitForChild("PlayerGui")
    local old = pg:FindFirstChild("HamsterLivesGui")
    if old then old:Destroy() end

    Gui = Instance.new("ScreenGui")
    Gui.Name = "HamsterLivesGui"
    Gui.ResetOnSpawn = false
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Gui.Parent = pg

    -- === BAŞLIK (HAMSTER LIVES) ===
    TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(0, 400, 0, 50)
    TitleLabel.Position = UDim2.new(0.5, -200, 0, 25)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = ""
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 28
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextStrokeTransparency = 0.3
    TitleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    TitleLabel.Parent = Gui

    -- Başlık RGB Stroke
    local titleStroke = Instance.new("UIStroke")
    titleStroke.Name = "RGBStroke"
    titleStroke.Thickness = 2
    titleStroke.Color = Color3.fromRGB(255, 0, 255)
    titleStroke.Parent = TitleLabel

    -- === TOGGLE BUTONU (Sağ Üst) ===
    ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = "Toggle"
    ToggleBtn.Size = UDim2.new(0, 48, 0, 48)
    ToggleBtn.Position = UDim2.new(1, -65, 0, 20)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    ToggleBtn.Text = "🌐"
    ToggleBtn.TextSize = 22
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.Parent = Gui

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = ToggleBtn

    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Name = "RGBStroke"
    toggleStroke.Thickness = 2.5
    toggleStroke.Color = Color3.fromRGB(0, 255, 255)
    toggleStroke.Parent = ToggleBtn

    -- === ANA MENÜ FRAME ===
    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainMenu"
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.Visible = false
    MainFrame.Parent = Gui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 14)
    mainCorner.Parent = MainFrame

    -- RGB Dönen Işık (UIStroke)
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Name = "RGBStroke"
    mainStroke.Thickness = 3
    mainStroke.Color = Color3.fromRGB(255, 0, 255)
    mainStroke.Parent = MainFrame

    -- Başlık Bar
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 42)
    header.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    header.BorderSizePixel = 0
    header.Parent = MainFrame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 14)
    headerCorner.Parent = header

    local headerTitle = Instance.new("TextLabel")
    headerTitle.Size = UDim2.new(1, -50, 1, 0)
    headerTitle.Position = UDim2.new(0, 15, 0, 0)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = "🐹 HAMSTER LIVES • SERVERS"
    headerTitle.TextColor3 = Color3.fromRGB(0, 255, 200)
    headerTitle.TextSize = 14
    headerTitle.Font = Enum.Font.GothamBold
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    headerTitle.Parent = header

    -- Kapatma Butonu
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -38, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 25)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn

    -- Scrolling Frame
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "ServerList"
    scroll.Size = UDim2.new(1, -16, 1, -55)
    scroll.Position = UDim2.new(0, 8, 0, 48)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 200)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = MainFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 6)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = scroll

    -- Sunucu Ekleme Fonksiyonu
    local function AddServerEntry(data)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -4, 0, 48)
        btn.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.Parent = scroll

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn

        local btnStroke = Instance.new("UIStroke")
        btnStroke.Thickness = 1
        btnStroke.Color = Color3.fromRGB(40, 40, 60)
        btnStroke.Parent = btn

        local playersLabel = Instance.new("TextLabel")
        playersLabel.Size = UDim2.new(1, -20, 0, 22)
        playersLabel.Position = UDim2.new(0, 12, 0, 6)
        playersLabel.BackgroundTransparency = 1
        playersLabel.Text = "👥 " .. data.playing .. " / " .. data.maxPlayers .. " oyuncu"
        playersLabel.TextColor3 = Color3.fromRGB(0, 255, 180)
        playersLabel.TextSize = 13
        playersLabel.Font = Enum.Font.GothamBold
        playersLabel.TextXAlignment = Enum.TextXAlignment.Left
        playersLabel.Parent = btn

        local idLabel = Instance.new("TextLabel")
        idLabel.Size = UDim2.new(1, -20, 0, 16)
        idLabel.Position = UDim2.new(0, 12, 0, 26)
        idLabel.BackgroundTransparency = 1
        idLabel.Text = "ID: " .. data.id:sub(1, 12) .. "..."
        idLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
        idLabel.TextSize = 11
        idLabel.Font = Enum.Font.Gotham
        idLabel.TextXAlignment = Enum.TextXAlignment.Left
        idLabel.Parent = btn

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 50)}):Play()
            btnStroke.Color = Color3.fromRGB(0, 255, 200)
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(22, 22, 32)}):Play()
            btnStroke.Color = Color3.fromRGB(40, 40, 60)
        end)

        btn.MouseButton1Click:Connect(function()
            print("⚡ [HAMSTER] Sunucuya bağlanılıyor...")
            TeleportService:TeleportToPlaceInstance(game.PlaceId, data.id, LocalPlayer)
        end)
    end

    -- Mevcut sunucuları ekle
    for _, s in ipairs(VerifiedServers) do
        AddServerEntry(s)
    end

    -- Kapatma
    closeBtn.MouseButton1Click:Connect(function()
        CloseMenu()
    end)

    return AddServerEntry
end

-- Menü Aç
function OpenMenu()
    if MenuOpen or not MainFrame then return end
    MenuOpen = true
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.BackgroundTransparency = 1

    local openTween = TweenService:Create(MainFrame, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 280, 0, 360),
        BackgroundTransparency = 0.05
    })
    openTween:Play()
end

-- Menü Kapat
function CloseMenu()
    if not MenuOpen or not MainFrame then return end
    MenuOpen = false

    local closeTween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    })
    closeTween:Play()
    closeTween.Completed:Connect(function()
        MainFrame.Visible = false
    end)
end

-- Toggle
local function ToggleMenu()
    if MenuOpen then
        CloseMenu()
    else
        OpenMenu()
    end
end

-- Başlık Animasyonu (Harf Harf)
local function AnimateTitle()
    local fullText = "HAMSTER LIVES"
    TitleLabel.Text = ""
    
    task.spawn(function()
        for i = 1, #fullText do
            TitleLabel.Text = string.sub(fullText, 1, i)
            task.wait(0.12) -- ne çok yavaş ne çok hızlı
        end
    end)
end

-- RGB Animasyon Loop
local function StartRGB()
    task.spawn(function()
        local t = 0
        while Gui and Gui.Parent do
            t = t + 0.03
            local color = GetRGB(t)

            if TitleLabel and TitleLabel:FindFirstChild("RGBStroke") then
                TitleLabel.RGBStroke.Color = color
                TitleLabel.TextColor3 = color
            end

            if ToggleBtn and ToggleBtn:FindFirstChild("RGBStroke") then
                ToggleBtn.RGBStroke.Color = color
            end

            if MainFrame and MainFrame:FindFirstChild("RGBStroke") then
                MainFrame.RGBStroke.Color = color
            end

            task.wait(0.03)
        end
    end)
end

-- Sunucu Tarama
local function StartPolling(addCallback)
    if ScanningActive then return end
    ScanningActive = true

    task.spawn(function()
        local cursor = ""

        while ScanningActive do
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
            if cursor \~= "" then
                url = url .. "&cursor=" .. cursor
            end

            local rawData = SafeHttpGet(url)
            local success, result = pcall(function()
                return HttpService:JSONDecode(rawData)
            end)

            if success and result and result.data then
                for _, server in ipairs(result.data) do
                    if server.id \~= game.JobId and server.playing >= 1 and server.playing < server.maxPlayers then
                        local exists = false
                        for _, s in ipairs(VerifiedServers) do
                            if s.id == server.id then
                                exists = true
                                break
                            end
                        end

                        if not exists then
                            table.insert(VerifiedServers, server)
                            if addCallback then
                                pcall(function()
                                    addCallback(server)
                                end)
                            end
                        end
                    end
                end
                cursor = result.nextPageCursor or ""
                if cursor == "" then
                    task.wait(12)
                end
            else
                task.wait(6)
            end
            task.wait(4)
        end
    end)
end

-- Başlat
local function Init()
    local addCallback = CreateGUI()
    
    -- Toggle bağla
    ToggleBtn.MouseButton1Click:Connect(ToggleMenu)
    
    -- Başlık animasyonu
    AnimateTitle()
    
    -- RGB başlat
    StartRGB()
    
    -- Tarama başlat
    StartPolling(addCallback)
    
    print("✅ [HAMSTER LIVES] Hazır! Sağ üstteki 🌐 butonuna tıkla.")
end

Init()
