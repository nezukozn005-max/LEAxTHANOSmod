-- ============================================================
-- HAMSTER LIVES - MINI SERVER FINDER V17 (HAFİF)
-- SADECE E COOLDOWN SIFIRLAMA | BAD ZONE YOK | DÖNGÜ YOK
-- ============================================================

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

print("🐹 MINI SERVER FINDER V17 BAŞLADI...")

local VerifiedServers = {}
local ScanningActive = false
local GuiRef = nil

-- ============================================================
-- EKLENTİ: E TUŞU COOLDOWN SIFIRLAMA (DÖNGÜ YOK)
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E then
        task.spawn(function()
            for _, obj in ipairs(game:GetDescendants()) do
                if obj:IsA("IntValue") or obj:IsA("NumberValue") then
                    if obj.Name and (string.find(obj.Name:lower(), "cooldown") or string.find(obj.Name:lower(), "cd")) then
                        pcall(function()
                            obj.Value = 0
                        end)
                    end
                end
            end
        end)
    end
end)

-- ============================================================
-- HTTP
-- ============================================================
local function SafeHttpGet(url)
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    if success and response then return response end
    return nil
end

-- ============================================================
-- MENU OLUŞTUR
-- ============================================================
local function CreateMiniMenu()
    local old = CoreGui:FindFirstChild("MiniServerFinder")
    if old then old:Destroy() end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "MiniServerFinder"
    gui.Parent = CoreGui
    gui.ResetOnSpawn = false
    GuiRef = gui

    local menu = Instance.new("Frame")
    menu.Size = UDim2.new(0, 150, 0, 200)
    menu.Position = UDim2.new(0.5, -75, 0.1, 0)
    menu.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    menu.BackgroundTransparency = 0.1
    menu.Parent = gui
    menu.Active = true
    menu.Draggable = true
    Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 22)
    title.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    title.Text = "🐹 HAMSTER"
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
        if GuiRef then GuiRef:Destroy() end
        GuiRef = nil
        ScanningActive = false
    end)

    local countLabel = Instance.new("TextLabel")
    countLabel.Size = UDim2.new(1, 0, 0, 16)
    countLabel.Position = UDim2.new(0, 0, 0, 24)
    countLabel.BackgroundTransparency = 1
    countLabel.Text = "👥 SUNUCU: 0"
    countLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    countLabel.TextSize = 9
    countLabel.Font = Enum.Font.Gotham
    countLabel.Parent = menu

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -50)
    scroll.Position = UDim2.new(0, 5, 0, 42)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = menu
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Color3.fromRGB(180, 0, 0)

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 3)
    layout.Parent = scroll

    local function AddServerButton(server)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -4, 0, 26)
        btn.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
        btn.Text = "👤 " .. server.playing .. "/" .. server.maxPlayers
        btn.TextColor3 = server.playing == 1 and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(200, 200, 200)
        btn.TextSize = 9
        btn.Font = Enum.Font.GothamBold
        btn.Parent = scroll
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
        end)

        btn.MouseButton1Click:Connect(function()
            local serverId = server.id
            btn.Text = "⚡ GİDİYOR..."
            btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)

            task.spawn(function()
                if GuiRef then pcall(function() GuiRef:Destroy() end) end
                GuiRef = nil
                TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId, LocalPlayer)
            end)
        end)
    end

    for _, server in ipairs(VerifiedServers) do
        AddServerButton(server)
    end
    countLabel.Text = "👥 SUNUCU: " .. #VerifiedServers

    local function AddNewServer(server)
        AddServerButton(server)
        countLabel.Text = "👥 SUNUCU: " .. #VerifiedServers
        task.wait(0.05)
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end

    -- SÜRÜKLEME
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
            menu.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    return AddNewServer
end

-- ============================================================
-- TARAMA
-- ============================================================
local function StartScanning(addServerCallback)
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
                task.wait(1)
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
                if cursor == "" then 
                    task.wait(2)
                else
                    task.wait(1)
                end
            else
                task.wait(1)
            end
            task.wait(0.5)
        end
    end)
end

-- ============================================================
-- BAŞLAT
-- ============================================================
local function Init()
    local addCallback = CreateMiniMenu()
    if addCallback then
        StartScanning(addCallback)
        print("🐹 MINI SERVER FINDER V17 HAZIR!")
        print("⚡ ANINDA BAĞLANMA AKTİF!")
        print("⚡ E COOLDOWN SIFIRLAMA AKTİF! (DÖNGÜ YOK)")
    end
end

task.wait(0.5)
pcall(Init)

print("")
print("========================================")
print("🐹 HAMSTER LIVES - MINI SERVER FINDER V17")
print("   ✅ 150x150 SÜRÜKLEYEBİLİR")
print("   ✅ ANINDA BAĞLANMA")
print("   ✅ KARANLIK TEMA")
print("   ✅ E COOLDOWN SIFIRLAMA (HAFİF)")
print("   ❌ BAD ZONE KALDIRILDI")
print("   ❌ DÖNGÜ YOK - KASMA YOK")
print("========================================")
