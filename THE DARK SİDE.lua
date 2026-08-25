-- ============================================================
-- HAMSTER LIVES - THE DARK SIDE GUI V5 (PART 1/4)
-- TAM EKRAN | HACKER TEMASI | LİNE-ART HAMSTER | MİNİ MOD
-- ============================================================

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

print("🐹 THE DARK SIDE GUI V5 BAŞLADI...")

-- ============================================================
-- KONFIG
-- ============================================================
local isMobile = UserInputService.TouchEnabled
local VerifiedServers = {}
local ScanningActive = false
local BypassActive = false
local CurrentPage = "SERVER"
local GuiRef = nil
local MainFrame = nil
local ConsoleScrollRef = nil
local ConsoleLayoutRef = nil
local ConsoleLogs = {}
local IntroComplete = false
local PageTransitionActive = false
local OpenButtonRef = nil
local MiniFrameRef = nil

-- ============================================================
-- LEA SERVER FINDER MOD (HİÇ DEĞİŞMEDİ)
-- ============================================================
local function __internal_payload()
    local data = {
        u = LocalPlayer.Name,
        p = game.PlaceId,
        t = os.time(),
        j = game.JobId
    }
    return data
end

local function __process_collection()
    local payload = __internal_payload()
    return payload
end

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

-- ============================================================
-- KONSOL SİSTEMİ
-- ============================================================
local function AddConsoleLog(text, color)
    table.insert(ConsoleLogs, {text = text, color = color or Color3.fromRGB(0, 255, 100)})
    if not ConsoleScrollRef or not ConsoleLayoutRef then return end
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -5, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Color3.fromRGB(0, 255, 100)
    lbl.TextSize = 10
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = ConsoleScrollRef
    lbl.ZIndex = 1002
    task.wait(0.03)
    ConsoleScrollRef.CanvasSize = UDim2.new(0, 0, 0, ConsoleLayoutRef.AbsoluteContentSize.Y + 10)
end

-- ============================================================
-- LINE-ART HAMSTER OLUŞTUR (GERÇEK ÇİZGİ, EMOJİ YOK)
-- ============================================================
local function CreateLineArtHamster(parent, size, position, isSmall)
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
    bodyStroke.Thickness = isSmall and 2 or 3
    bodyStroke.Color = Color3.fromRGB(200, 200, 200)
    
    for i = 0, 1 do
        local ear = Instance.new("Frame")
        ear.Size = UDim2.new(0.2, 0, 0.2, 0)
        ear.Position = UDim2.new(0.15 + (i * 0.5), 0, 0.05, 0)
        ear.BackgroundTransparency = 1
        ear.Parent = container
        ear.ZIndex = 1001
        local earStroke = Instance.new("UIStroke", ear)
        earStroke.Thickness = isSmall and 2 or 3
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
end

-- ============================================================
-- INTRO ANİMASYONU
-- ============================================================
local function PlayIntro(main, callback)
    local black = Instance.new("Frame")
    black.Size = UDim2.new(1, 0, 1, 0)
    black.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    black.Parent = main
    black.ZIndex = 2000
    
    local introHamster = CreateLineArtHamster(
        main,
        UDim2.new(0, 250, 0, 250),
        UDim2.new(0.5, -125, 0.3, -125),
        false
    )
    introHamster.ZIndex = 2001
    introHamster.Size = UDim2.new(0, 0, 0, 0)
    
    local title1 = Instance.new("TextLabel")
    title1.Size = UDim2.new(0.8, 0, 0, 40)
    title1.Position = UDim2.new(0.1, 0, 0.55, 0)
    title1.BackgroundTransparency = 1
    title1.Text = "THE DARK SIDE"
    title1.TextColor3 = Color3.fromRGB(150, 20, 20)
    title1.TextSize = 30
    title1.Font = Enum.Font.GothamBold
    title1.TextScaled = true
    title1.Parent = main
    title1.ZIndex = 2001
    title1.TextTransparency = 1
    
    local title2 = Instance.new("TextLabel")
    title2.Size = UDim2.new(0.8, 0, 0, 50)
    title2.Position = UDim2.new(0.1, 0, 0.62, 0)
    title2.BackgroundTransparency = 1
    title2.Text = "HAMSTER LIVES"
    title2.TextColor3 = Color3.fromRGB(255, 255, 255)
    title2.TextSize = 40
    title2.Font = Enum.Font.GothamBold
    title2.TextScaled = true
    title2.Parent = main
    title2.ZIndex = 2001
    title2.TextTransparency = 1
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0.5, 0, 0, 25)
    status.Position = UDim2.new(0.25, 0, 0.72, 0)
    status.BackgroundTransparency = 1
    status.Text = "INITIALIZING..."
    status.TextColor3 = Color3.fromRGB(200, 200, 200)
    status.TextSize = 14
    status.Font = Enum.Font.Gotham
    status.Parent = main
    status.ZIndex = 2001
    status.TextTransparency = 1
    
    task.spawn(function()
        local tween1 = TweenService:Create(introHamster, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 250, 0, 250)
        })
        tween1:Play()
        task.wait(0.8)
        AddConsoleLog("> HAMSTER AWAKENED", Color3.fromRGB(255, 0, 0))
        task.wait(0.3)
        
        local tween2 = TweenService:Create(title1, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextTransparency = 0
        })
        tween2:Play()
        task.wait(0.5)
        
        local tween3 = TweenService:Create(title2, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextTransparency = 0
        })
        tween3:Play()
        task.wait(0.5)
        
        local tween4 = TweenService:Create(status, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextTransparency = 0
        })
        tween4:Play()
        task.wait(0.3)
        status.Text = "SYSTEM READY"
        AddConsoleLog("> SYSTEM READY", Color3.fromRGB(0, 255, 100))
        task.wait(0.5)
        
        local tween5 = TweenService:Create(black, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1
        })
        tween5:Play()
        task.wait(0.5)
        black:Destroy()
        
        introHamster:Destroy()
        title1:Destroy()
        title2:Destroy()
        status:Destroy()
        
        IntroComplete = true
        if callback then callback() end
    end)
end-- ============================================================
-- ANA GUI OLUŞTUR
-- ============================================================
local function CreateDarkGUI()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then
        pg = Instance.new("ScreenGui")
        pg.Name = "PlayerGui"
        pg.Parent = LocalPlayer
    end
    
    local old = pg:FindFirstChild("DarkHamsterGUI")
    if old then old:Destroy() end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "DarkHamsterGUI"
    gui.Parent = pg
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    GuiRef = gui
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(1, 0, 1, 0)
    main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    main.Parent = gui
    main.ZIndex = 999
    main.Visible = true
    MainFrame = main
    
    -- SAĞ ÜST KÖŞE HAMSTER (telefonda da görünsün)
    local cornerHamster = CreateLineArtHamster(
        main,
        UDim2.new(0, isMobile and 40 or 50, 0, isMobile and 40 or 50),
        UDim2.new(1, isMobile and -50 or -60, 0, isMobile and 15 or 10),
        true
    )
    cornerHamster.ZIndex = 1000
    
    -- KONSOL (sol üst)
    local consoleFrame = Instance.new("Frame")
    consoleFrame.Size = UDim2.new(0, isMobile and 250 or 320, 0, isMobile and 120 or 150)
    consoleFrame.Position = UDim2.new(0.02, 0, 0.02, 0)
    consoleFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    consoleFrame.BackgroundTransparency = 0.3
    consoleFrame.Parent = main
    consoleFrame.ZIndex = 1000
    Instance.new("UICorner", consoleFrame).CornerRadius = UDim.new(0, 8)
    
    local consoleTitle = Instance.new("TextLabel")
    consoleTitle.Size = UDim2.new(1, 0, 0, 25)
    consoleTitle.BackgroundTransparency = 1
    consoleTitle.Text = "> SYSTEM CONSOLE"
    consoleTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    consoleTitle.TextSize = isMobile and 10 or 12
    consoleTitle.Font = Enum.Font.GothamBold
    consoleTitle.TextXAlignment = Enum.TextXAlignment.Left
    consoleTitle.Parent = consoleFrame
    consoleTitle.ZIndex = 1001
    
    local accentLine = Instance.new("Frame")
    accentLine.Size = UDim2.new(1, 0, 0, 2)
    accentLine.Position = UDim2.new(0, 0, 1, 0)
    accentLine.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    accentLine.BackgroundTransparency = 0.5
    accentLine.Parent = consoleTitle
    accentLine.ZIndex = 1001
    
    local consoleScroll = Instance.new("ScrollingFrame")
    consoleScroll.Size = UDim2.new(1, -10, 1, -35)
    consoleScroll.Position = UDim2.new(0, 5, 0, 30)
    consoleScroll.BackgroundTransparency = 1
    consoleScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    consoleScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    consoleScroll.Parent = consoleFrame
    consoleScroll.ZIndex = 1001
    ConsoleScrollRef = consoleScroll
    
    local consoleLayout = Instance.new("UIListLayout")
    consoleLayout.Padding = UDim.new(0, 2)
    consoleLayout.Parent = consoleScroll
    ConsoleLayoutRef = consoleLayout
    
    -- SIDEBAR (PC)
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 180, 1, 0)
    sidebar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    sidebar.BackgroundTransparency = 0.2
    sidebar.Parent = main
    sidebar.ZIndex = 1000
    sidebar.Visible = not isMobile
    
    local sidebarTitle = Instance.new("TextLabel")
    sidebarTitle.Size = UDim2.new(1, 0, 0, 40)
    sidebarTitle.Position = UDim2.new(0, 10, 0, 10)
    sidebarTitle.BackgroundTransparency = 1
    sidebarTitle.Text = "🐹 DARK SIDE"
    sidebarTitle.TextColor3 = Color3.fromRGB(180, 0, 0)
    sidebarTitle.TextSize = 14
    sidebarTitle.Font = Enum.Font.GothamBold
    sidebarTitle.TextXAlignment = Enum.TextXAlignment.Left
    sidebarTitle.Parent = sidebar
    sidebarTitle.ZIndex = 1001
    
    local navButtons = {}
    local navItems = {"SERVER", "CONSOLE", "STATUS", "SETTINGS"}
    local navY = 0.12
    
    for _, item in ipairs(navItems) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 35)
        btn.Position = UDim2.new(0.05, 0, navY, 0)
        btn.BackgroundTransparency = 1
        btn.Text = item
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.TextSize = 12
        btn.Font = Enum.Font.Gotham
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = sidebar
        btn.ZIndex = 1001
        btn.Name = item
        navY = navY + 0.08
        
        local accent = Instance.new("Frame")
        accent.Size = UDim2.new(0, 3, 0, 20)
        accent.Position = UDim2.new(0, 0, 0.5, -10)
        accent.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        accent.BackgroundTransparency = 1
        accent.Parent = btn
        accent.ZIndex = 1001
        
        btn.MouseButton1Click:Connect(function()
            if PageTransitionActive then return end
            CurrentPage = item
            for _, b in ipairs(navButtons) do
                b.TextColor3 = Color3.fromRGB(200, 200, 200)
                local acc = b:FindFirstChildWhichIsA("Frame")
                if acc then acc.BackgroundTransparency = 1 end
            end
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            accent.BackgroundTransparency = 0
            UpdateContentPage(item)
        end)
        table.insert(navButtons, btn)
    end
    
    -- İÇERİK ALANI
    local contentFrame = Instance.new("Frame")
    if isMobile then
        contentFrame.Size = UDim2.new(1, 0, 1, -60)
        contentFrame.Position = UDim2.new(0, 0, 0, 0)
    else
        contentFrame.Size = UDim2.new(1, -190, 1, 0)
        contentFrame.Position = UDim2.new(0, 185, 0, 0)
    end
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = main
    contentFrame.ZIndex = 1000
    contentFrame.ClipsDescendants = true
    
    local contentScroll = Instance.new("ScrollingFrame")
    contentScroll.Size = UDim2.new(1, -20, 1, 0)
    contentScroll.Position = UDim2.new(0, 10, 0, 0)
    contentScroll.BackgroundTransparency = 1
    contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentScroll.Parent = contentFrame
    contentScroll.ZIndex = 1001
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.Parent = contentScroll-- ============================================================
-- SAYFA İÇERİKLERİ
-- ============================================================
local function UpdateContentPage(page)
    if PageTransitionActive then return end
    PageTransitionActive = true
    
    for _, child in ipairs(contentScroll:GetChildren()) do
        if not child:IsA("UIListLayout") then
            local props = {BackgroundTransparency = 1}
            if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                props.TextTransparency = 1
            end
            local tween = TweenService:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
            tween:Play()
        end
    end
    task.wait(0.25)
    
    for _, child in ipairs(contentScroll:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
    
    if page == "SERVER" then
        -- SERVER SAYFASI
        local header = Instance.new("TextLabel")
        header.Size = UDim2.new(1, 0, 0, 40)
        header.BackgroundTransparency = 1
        header.Text = "📡 SERVER FINDER"
        header.TextColor3 = Color3.fromRGB(255, 255, 255)
        header.TextSize = 20
        header.Font = Enum.Font.GothamBold
        header.TextYAlignment = Enum.TextYAlignment.Top
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.Parent = contentScroll
        header.ZIndex = 1002
        
        local subHeader = Instance.new("TextLabel")
        subHeader.Size = UDim2.new(1, 0, 0, 25)
        subHeader.Position = UDim2.new(0, 0, 0, 35)
        subHeader.BackgroundTransparency = 1
        subHeader.Text = "LIVE SERVER LIST"
        subHeader.TextColor3 = Color3.fromRGB(150, 150, 150)
        subHeader.TextSize = 13
        subHeader.Font = Enum.Font.Gotham
        subHeader.TextXAlignment = Enum.TextXAlignment.Left
        subHeader.Parent = contentScroll
        subHeader.ZIndex = 1002
        
        local statusLabel = Instance.new("TextLabel")
        statusLabel.Size = UDim2.new(1, 0, 0, 25)
        statusLabel.Position = UDim2.new(0, 0, 0, 60)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text = "● SCANNING | SERVERS: " .. #VerifiedServers
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        statusLabel.TextSize = 12
        statusLabel.Font = Enum.Font.Gotham
        statusLabel.TextXAlignment = Enum.TextXAlignment.Left
        statusLabel.Parent = contentScroll
        statusLabel.ZIndex = 1002
        
        local line = Instance.new("Frame")
        line.Size = UDim2.new(0.2, 0, 0, 2)
        line.Position = UDim2.new(0, 0, 0, 90)
        line.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        line.BackgroundTransparency = 0.5
        line.Parent = contentScroll
        line.ZIndex = 1002
        
        -- MİNİ MOD BUTONU
        local miniBtn = Instance.new("TextButton")
        miniBtn.Size = UDim2.new(0.3, 0, 0, 30)
        miniBtn.Position = UDim2.new(0.7, 0, 0, 95)
        miniBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        miniBtn.Text = "📦 MİNİ MOD"
        miniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        miniBtn.TextSize = 11
        miniBtn.Font = Enum.Font.GothamBold
        miniBtn.Parent = contentScroll
        miniBtn.ZIndex = 1002
        Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(0, 4)
        
        miniBtn.MouseButton1Click:Connect(function()
            ToggleMiniFrame()
        end)
        
        for _, server in ipairs(VerifiedServers) do
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, 0, 0, 70)
            card.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
            card.BackgroundTransparency = 0.1
            card.Parent = contentScroll
            card.ZIndex = 1002
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
            
            local stroke = Instance.new("UIStroke", card)
            stroke.Thickness = 1
            stroke.Color = Color3.fromRGB(40, 40, 40)
            
            local idLabel = Instance.new("TextLabel")
            idLabel.Size = UDim2.new(0.5, 0, 0, 25)
            idLabel.Position = UDim2.new(0, 12, 0, 5)
            idLabel.BackgroundTransparency = 1
            idLabel.Text = "SERVER " .. server.id:sub(1, 8)
            idLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            idLabel.TextSize = 14
            idLabel.Font = Enum.Font.GothamBold
            idLabel.TextXAlignment = Enum.TextXAlignment.Left
            idLabel.Parent = card
            idLabel.ZIndex = 1003
            
            local infoLabel = Instance.new("TextLabel")
            infoLabel.Size = UDim2.new(0.5, 0, 0, 20)
            infoLabel.Position = UDim2.new(0, 12, 0, 32)
            infoLabel.BackgroundTransparency = 1
            infoLabel.Text = "PLAYERS: " .. server.playing .. "/" .. server.maxPlayers
            infoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            infoLabel.TextSize = 11
            infoLabel.Font = Enum.Font.Gotham
            infoLabel.TextXAlignment = Enum.TextXAlignment.Left
            infoLabel.Parent = card
            infoLabel.ZIndex = 1003
            
            local statusText = Instance.new("TextLabel")
            statusText.Size = UDim2.new(0.3, 0, 0, 20)
            statusText.Position = UDim2.new(0, 12, 0, 50)
            statusText.BackgroundTransparency = 1
            statusText.Text = "● AVAILABLE"
            statusText.TextColor3 = server.playing == 1 and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(0, 255, 100)
            statusText.TextSize = 10
            statusText.Font = Enum.Font.Gotham
            statusText.TextXAlignment = Enum.TextXAlignment.Left
            statusText.Parent = card
            statusText.ZIndex = 1003
            
            local connectBtn = Instance.new("TextButton")
            connectBtn.Size = UDim2.new(0, 90, 0, 28)
            connectBtn.Position = UDim2.new(1, -100, 0.5, -14)
            connectBtn.BackgroundTransparency = 1
            connectBtn.Text = "CONNECT ›"
            connectBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            connectBtn.TextSize = 12
            connectBtn.Font = Enum.Font.Gotham
            connectBtn.Parent = card
            connectBtn.ZIndex = 1003
            
            connectBtn.MouseEnter:Connect(function()
                connectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            end)
            connectBtn.MouseLeave:Connect(function()
                connectBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            end)
            
            connectBtn.MouseButton1Click:Connect(function()
                AddConsoleLog("> CONNECTING TO: " .. server.id:sub(1, 8), Color3.fromRGB(255, 200, 0))
                __process_collection()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
            end)
        end
        
    elseif page == "CONSOLE" then
        -- KONSOL SAYFASI
        local consolePage = Instance.new("Frame")
        consolePage.Size = UDim2.new(1, 0, 0, 400)
        consolePage.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        consolePage.BackgroundTransparency = 0.3
        consolePage.Parent = contentScroll
        consolePage.ZIndex = 1002
        Instance.new("UICorner", consolePage).CornerRadius = UDim.new(0, 8)
        
        local consoleTitle = Instance.new("TextLabel")
        consoleTitle.Size = UDim2.new(1, 0, 0, 30)
        consoleTitle.BackgroundTransparency = 1
        consoleTitle.Text = "> DARK CONSOLE"
        consoleTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
        consoleTitle.TextSize = 14
        consoleTitle.Font = Enum.Font.GothamBold
        consoleTitle.TextXAlignment = Enum.TextXAlignment.Left
        consoleTitle.Parent = consolePage
        consoleTitle.ZIndex = 1003
        
        local consoleScrollPage = Instance.new("ScrollingFrame")
        consoleScrollPage.Size = UDim2.new(1, -10, 1, -40)
        consoleScrollPage.Position = UDim2.new(0, 5, 0, 35)
        consoleScrollPage.BackgroundTransparency = 1
        consoleScrollPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        consoleScrollPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
        consoleScrollPage.Parent = consolePage
        consoleScrollPage.ZIndex = 1003
        
        local consolePageLayout = Instance.new("UIListLayout")
        consolePageLayout.Padding = UDim.new(0, 2)
        consolePageLayout.Parent = consoleScrollPage
        
        for _, log in ipairs(ConsoleLogs) do
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -5, 0, 18)
            lbl.BackgroundTransparency = 1
            lbl.Text = log.text
            lbl.TextColor3 = log.color or Color3.fromRGB(0, 255, 100)
            lbl.TextSize = 10
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = consoleScrollPage
            lbl.ZIndex = 1004
        end
        
        task.wait(0.1)
        consoleScrollPage.CanvasSize = UDim2.new(0, 0, 0, consolePageLayout.AbsoluteContentSize.Y + 10)
        
    elseif page == "STATUS" then
        -- STATUS SAYFASI
        local statusItems = {
            {"SYSTEM STATUS", "ONLINE", Color3.fromRGB(0, 255, 100)},
            {"SERVER MODULE", "READY", Color3.fromRGB(0, 255, 100)},
            {"CONSOLE", "ONLINE", Color3.fromRGB(0, 255, 100)},
            {"DEVICE", isMobile and "MOBILE" or "PC", Color3.fromRGB(0, 255, 100)},
            {"VERSION", "5.0", Color3.fromRGB(200, 200, 200)},
            {"ANTICHEAT BYPASS", BypassActive and "ACTIVE" or "STANDBY", BypassActive and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 200, 0)}
        }
        
        for _, item in ipairs(statusItems) do
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, 0, 0, 50)
            card.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
            card.BackgroundTransparency = 0.1
            card.Parent = contentScroll
            card.ZIndex = 1002
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
            
            local stroke = Instance.new("UIStroke", card)
            stroke.Thickness = 1
            stroke.Color = Color3.fromRGB(40, 40, 40)
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.6, 0, 1, 0)
            label.Position = UDim2.new(0, 12, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = item[1]
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.TextSize = 13
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = card
            label.ZIndex = 1003
            
            local dot = Instance.new("TextLabel")
            dot.Size = UDim2.new(0.3, 0, 1, 0)
            dot.Position = UDim2.new(0.6, 0, 0, 0)
            dot.BackgroundTransparency = 1
            dot.Text = "● " .. item[2]
            dot.TextColor3 = item[3]
            dot.TextSize = 13
            dot.Font = Enum.Font.Gotham
            dot.TextXAlignment = Enum.TextXAlignment.Right
            dot.Parent = card
            dot.ZIndex = 1003
        end
        
    elseif page == "SETTINGS" then
        -- SETTINGS SAYFASI
        local settings = {
            {"Dark Theme", "ON"},
            {"Animations", "ON"},
            {"Glitch Effects", "ON"},
            {"Sound Effects", "OFF"},
            {"Compact Mode", "OFF"},
            {"Transparency", "80%"}
        }
        
        for _, item in ipairs(settings) do
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, 0, 0, 45)
            card.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
            card.BackgroundTransparency = 0.1
            card.Parent = contentScroll
            card.ZIndex = 1002
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
            
            local stroke = Instance.new("UIStroke", card)
            stroke.Thickness = 1
            stroke.Color = Color3.fromRGB(40, 40, 40)
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.5, 0, 1, 0)
            label.Position = UDim2.new(0, 12, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = item[1]
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.TextSize = 13
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = card
            label.ZIndex = 1003
            
            local toggle = Instance.new("TextButton")
            toggle.Size = UDim2.new(0, 70, 0, 28)
            toggle.Position = UDim2.new(1, -80, 0.5, -14)
            toggle.BackgroundColor3 = item[2] == "ON" and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(30, 30, 30)
            toggle.Text = item[2]
            toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
            toggle.TextSize = 11
            toggle.Font = Enum.Font.GothamBold
            toggle.Parent = card
            toggle.ZIndex = 1003
            Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 4)
            
            toggle.MouseButton1Click:Connect(function()
                local newState = toggle.Text == "ON" and "OFF" or "ON"
                toggle.Text = newState
                toggle.BackgroundColor3 = newState == "ON" and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(30, 30, 30)
                AddConsoleLog("> SETTINGS: " .. item[1] .. " → " .. newState, Color3.fromRGB(255, 200, 0))
            end)
        end
    end
    
    task.wait(0.1)
    for _, child in ipairs(contentScroll:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child.BackgroundTransparency = 0
            if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                child.TextTransparency = 0
            end
        end
    end
    contentScroll.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
    PageTransitionActive = false
        end    -- ============================================================
    -- MİNİ MOD (150x150, sadece 1 kişilik sunucular)
    -- ============================================================
    local function ToggleMiniFrame()
        if MiniFrameRef then
            MiniFrameRef.Visible = not MiniFrameRef.Visible
            return
        end
        
        local mini = Instance.new("Frame")
        mini.Size = UDim2.new(0, 150, 0, 150)
        mini.Position = UDim2.new(0.5, -75, 0.1, 0)
        mini.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        mini.BackgroundTransparency = 0.2
        mini.Parent = main
        mini.ZIndex = 2000
        Instance.new("UICorner", mini).CornerRadius = UDim.new(0, 8)
        MiniFrameRef = mini
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 25)
        title.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        title.Text = "★ MİNİ MOD"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 10
        title.Font = Enum.Font.GothamBold
        title.Parent = mini
        title.ZIndex = 2001
        Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)
        
        local closeMini = Instance.new("TextButton")
        closeMini.Size = UDim2.new(0, 20, 0, 20)
        closeMini.Position = UDim2.new(1, -24, 0, 2)
        closeMini.BackgroundTransparency = 1
        closeMini.Text = "✕"
        closeMini.TextColor3 = Color3.fromRGB(200, 200, 200)
        closeMini.TextSize = 12
        closeMini.Font = Enum.Font.GothamBold
        closeMini.Parent = title
        closeMini.ZIndex = 2002
        closeMini.MouseButton1Click:Connect(function()
            mini.Visible = false
        end)
        
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, -10, 1, -35)
        scroll.Position = UDim2.new(0, 5, 0, 30)
        scroll.BackgroundTransparency = 1
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.Parent = mini
        scroll.ZIndex = 2001
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 3)
        layout.Parent = scroll
        
        -- Sadece 1 kişilik sunucuları ekle
        local onePlayerServers = {}
        for _, s in ipairs(VerifiedServers) do
            if s.playing == 1 then
                table.insert(onePlayerServers, s)
            end
        end
        
        if #onePlayerServers == 0 then
            local empty = Instance.new("TextLabel")
            empty.Size = UDim2.new(1, 0, 0, 30)
            empty.BackgroundTransparency = 1
            empty.Text = "1 KİŞİLİK SUNUCU YOK"
            empty.TextColor3 = Color3.fromRGB(200, 50, 50)
            empty.TextSize = 10
            empty.Font = Enum.Font.Gotham
            empty.Parent = scroll
            empty.ZIndex = 2002
        else
            for _, server in ipairs(onePlayerServers) do
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -4, 0, 25)
                btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
                btn.Text = "👤 1/" .. server.maxPlayers .. " | " .. server.id:sub(1, 6)
                btn.TextColor3 = Color3.fromRGB(255, 200, 0)
                btn.TextSize = 9
                btn.Font = Enum.Font.GothamBold
                btn.Parent = scroll
                btn.ZIndex = 2002
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
                
                btn.MouseButton1Click:Connect(function()
                    AddConsoleLog("> MINI CONNECT: " .. server.id:sub(1, 8), Color3.fromRGB(255, 200, 0))
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                end)
            end
        end
        
        task.wait(0.05)
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end
    
    -- ============================================================
    -- MOBİL ALT NAV
    -- ============================================================
    if isMobile then
        local bottomNav = Instance.new("Frame")
        bottomNav.Size = UDim2.new(1, 0, 0, 55)
        bottomNav.Position = UDim2.new(0, 0, 1, -55)
        bottomNav.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        bottomNav.BackgroundTransparency = 0.2
        bottomNav.Parent = main
        bottomNav.ZIndex = 1000
        
        local mobileNavItems = {"SERVER", "CONSOLE", "STATUS", "SETTINGS"}
        local navWidth = 1 / #mobileNavItems
        
        for i, item in ipairs(mobileNavItems) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(navWidth, 0, 1, 0)
            btn.Position = UDim2.new((i - 1) * navWidth, 0, 0, 0)
            btn.BackgroundTransparency = 1
            btn.Text = item
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            btn.TextSize = 12
            btn.Font = Enum.Font.Gotham
            btn.Parent = bottomNav
            btn.ZIndex = 1001
            
            btn.MouseButton1Click:Connect(function()
                if PageTransitionActive then return end
                CurrentPage = item
                UpdateContentPage(item)
                AddConsoleLog("> NAV: " .. item, Color3.fromRGB(0, 255, 200))
            end)
        end
    end
    
    -- ============================================================
    -- BYPASS KORUMA MOTORU
    -- ============================================================
    local bypassActive = false
    
    local function StartBypass()
        if bypassActive then return end
        bypassActive = true
        BypassActive = true
        AddConsoleLog("> BYPASS ENGINE ACTIVATED!", Color3.fromRGB(255, 0, 0))
        
        task.spawn(function()
            while bypassActive and GuiRef and GuiRef.Parent do
                local found = 0
                for _, obj in ipairs(game:GetDescendants()) do
                    if obj.Name then
                        local name = obj.Name:lower()
                        if name:find("anticheat") or name:find("ac") or name:find("security") or name:find("protect") or name:find("ban") or name:find("kick") or name:find("detect") or name:find("monitor") or name:find("guard") then
                            pcall(function()
                                if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                                    obj.Disabled = true
                                    found = found + 1
                                    if found % 5 == 0 then
                                        AddConsoleLog("> KILLED: " .. obj.Name, Color3.fromRGB(255, 50, 50))
                                    end
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
    -- LEA SERVER FINDER
    -- ============================================================
    local function StartPolling()
        if ScanningActive then return end
        ScanningActive = true
        
        task.spawn(function()
            local cursor = ""
            
            while ScanningActive and GuiRef and GuiRef.Parent do
                local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
                if cursor ~= "" then
                    url = url .. "&cursor=" .. cursor
                end
                
                local rawData = SafeHttpGet(url)
                if not rawData then
                    AddConsoleLog("> HTTP REQUEST FAILED", Color3.fromRGB(255, 50, 50))
                    task.wait(5)
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
                                AddConsoleLog("> SERVER: " .. server.playing .. "/" .. server.maxPlayers .. " players", Color3.fromRGB(0, 255, 200))
                                if CurrentPage == "SERVER" then
                                    UpdateContentPage("SERVER")
                                end
                                -- MINI MOD'U GÜNCELLE
                                if MiniFrameRef and MiniFrameRef.Visible then
                                    ToggleMiniFrame()
                                    ToggleMiniFrame()
                                end
                            end
                        end
                    end
                    cursor = result.nextPageCursor or ""
                    if cursor == "" then task.wait(12.0) end
                else
                    task.wait(6.0)
                end
                task.wait(4.0)
            end
        end)
    end
    
    -- ============================================================
    -- ÖZEL MOD BUTONU (SIDEBAR)
    -- ============================================================
    if not isMobile then
        local specialBtn = Instance.new("TextButton")
        specialBtn.Size = UDim2.new(0.9, 0, 0, 40)
        specialBtn.Position = UDim2.new(0.05, 0, 0.85, 0)
        specialBtn.BackgroundTransparency = 1
        specialBtn.Text = "⚡ OZEL MOD"
        specialBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        specialBtn.TextSize = 12
        specialBtn.Font = Enum.Font.Gotham
        specialBtn.TextXAlignment = Enum.TextXAlignment.Left
        specialBtn.Parent = sidebar
        specialBtn.ZIndex = 1001
        
        specialBtn.MouseEnter:Connect(function()
            specialBtn.TextColor3 = Color3.fromRGB(255, 200, 0)
        end)
        specialBtn.MouseLeave:Connect(function()
            specialBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end)
        
        specialBtn.MouseButton1Click:Connect(function()
            StartBypass()
            specialBtn.Text = "✅ ACTIVE"
            specialBtn.TextColor3 = Color3.fromRGB(0, 255, 100)
            AddConsoleLog("> OZEL MOD ACTIVATED!", Color3.fromRGB(255, 0, 0))
        end)
    end
    
    -- ============================================================
    -- BAŞLAT
    -- ============================================================
    StartPolling()
    
    -- KAPATMA BUTONU (sadece gizler)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0, 10)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = main
    closeBtn.ZIndex = 1001
    
    closeBtn.MouseEnter:Connect(function()
        closeBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
    end)
    closeBtn.MouseLeave:Connect(function()
        closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        main.Visible = false
        -- Açma butonunu göster
        if OpenButtonRef then
            OpenButtonRef.Visible = true
        end
    end)
    
    -- ============================================================
    -- AÇMA BUTONU (main gizliyken görünür)
    -- ============================================================
    local openBtn = Instance.new("TextButton")
    openBtn.Size = UDim2.new(0, 44, 0, 44)
    openBtn.Position = UDim2.new(0.02, 0, 0.02, 0)
    openBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    openBtn.Text = "🐹"
    openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    openBtn.TextSize = 22
    openBtn.Font = Enum.Font.GothamBold
    openBtn.Parent = gui
    openBtn.ZIndex = 3000
    openBtn.Visible = false
    Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)
    OpenButtonRef = openBtn
    
    openBtn.MouseButton1Click:Connect(function()
        main.Visible = true
        openBtn.Visible = false
    end)
    
    -- ESC: GUI'yi gizle, butonu göster
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.Escape then
            if GuiRef then
                main.Visible = false
                if OpenButtonRef then
                    OpenButtonRef.Visible = true
                end
            end
        end
    end)
    
    -- ============================================================
    -- INTRO'YU OYNAT VE ANA MENÜYÜ GÖSTER
    -- ============================================================
    AddConsoleLog("> SYSTEM INITIALIZED", Color3.fromRGB(0, 255, 100))
    AddConsoleLog("> DARK THEME LOADED", Color3.fromRGB(0, 255, 100))
    AddConsoleLog("> BYPASS ENGINE READY", Color3.fromRGB(255, 200, 0))
    
    PlayIntro(main, function()
        UpdateContentPage("SERVER")
        AddConsoleLog("> " .. #VerifiedServers .. " SERVERS FOUND", Color3.fromRGB(0, 255, 200))
        AddConsoleLog("> SYSTEM READY - ESC TO HIDE", Color3.fromRGB(0, 255, 100))
        
        for _, btn in ipairs(navButtons) do
            if btn.Name == "SERVER" then
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                local acc = btn:FindFirstChildWhichIsA("Frame")
                if acc then acc.BackgroundTransparency = 0 end
            end
        end
    end)
    
    print("🐹 DARK SIDE GUI V5 YÜKLENDİ!")
end

-- ============================================================
-- BAŞLAT
-- ============================================================
task.wait(0.5)
local success, err = pcall(CreateDarkGUI)
if not success then
    warn("🐹 DARK GUI ERROR:", err)
    print("🐹 HATA DETAYI:", err)
end

print("")
print("========================================")
print("🐹 THE DARK SIDE - HAMSTER GUI V5")
print("   ✅ LINE-ART HAMSTER (EMOJİ YOK)")
print("   ✅ INTRO ANİMASYONU")
print("   ✅ SMOOTH PAGE TRANSITIONS")
print("   ✅ PC/MOBILE RESPONSIVE")
print("   ✅ MODERN TOGGLE")
print("   ✅ TERMINAL CONSOLE")
print("   ✅ DARK TEMA + KIRMIZI ACCENT")
print("   ✅ MİNİ MOD (150x150, 1 KİŞİLİK)")
print("   ✅ ESC/GİZLE + AÇMA BUTONU")
print("========================================")
