-- ==============================================================================
-- LEA MOD - SERVER FINDER, AUTO-HOP & CONSOLIDATED CORE
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

print("⚡ [LEA CORE]: Server Finder ve Gelişmiş Sistemler Başlatılıyor...")

getgenv().LeaState = getgenv().LeaState or {
    Modules = {
        Cube = false,
        Fly = false,
        Follow = false,
        ServerFinder = false,
        AutoJoin = false
    },
    Settings = {
        FlySpeed = 35,
        FollowSpeed = 25,
        MinServerPlayers = 1,
        MaxServerPlayers = 10
    },
    BasePosition = nil,
    IsReturning = false
}

local Lea = getgenv().LeaState

-- ==============================================================================
-- 1. KÜP, TAKİP VE BASE (ÜS) SİSTEMİ
-- ==============================================================================
local cubePart = nil

local function UpdateCube(state)
    Lea.Modules.Cube = state
    pcall(function()
        if state then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and not cubePart then
                cubePart = Instance.new("Part")
                cubePart.Name = "LeaCubeNode"
                cubePart.Size = Vector3.new(2.5, 0.4, 2.5)
                cubePart.Anchored = false
                cubePart.CanCollide = true
                cubePart.Massless = true
                cubePart.Material = Enum.Material.Neon
                cubePart.Color = Color3.fromRGB(0, 255, 200)
                cubePart.Transparency = 0.3
                cubePart.Parent = Workspace
            end
        else
            if cubePart then
                cubePart:Destroy()
                cubePart = nil
            end
        end
    end)
end

-- Base Kaydetme ve Üsse Dönüş
local function SetBase()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        Lea.BasePosition = hrp.Position
        print("📍 [LEA BASE]: Üs konumu başarıyla kaydedildi.")
    end
end

local function ReturnToBase()
    if not Lea.BasePosition then
        print("⚠️ [LEA BASE]: Kayıtlı üs konumu yok!")
        return
    end
    Lea.IsReturning = true
    task.spawn(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        while hrp and Lea.IsReturning do
            local distance = (hrp.Position - Lea.BasePosition).Magnitude
            if distance < 4 then
                Lea.IsReturning = false
                break
            end
            hrp.CFrame = CFrame.new(hrp.Position:Lerp(Lea.BasePosition, 0.15))
            task.wait()
        end
    end)
end

-- ==============================================================================
-- 2. SERVER FINDER & AUTO-HOP SİSTEMİ (STEAL A BRAINROT)
-- ==============================================================================
local function HopToBestServer()
    pcall(function()
        print("🔍 [SERVER FINDER]: Uygun public server taranıyor...")
        local servers = {}
        local cursor = ""
        
        repeat
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
            if cursor ~= "" then
                url = url .. "&cursor=" + cursor
            end
            
            local success, response = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(url))
            end)
            
            if success and response and response.data then
                for _, server in ipairs(response.data) do
                    if server.playing and server.playing >= Lea.Settings.MinServerPlayers and server.playing < server.maxPlayers then
                        table.insert(servers, server.id)
                    end
                end
                cursor = response.nextPageCursor or ""
            else
                break
            end
        until #servers > 0 or cursor == ""

        if #servers > 0 then
            local targetServer = servers[math.random(1, #servers)]
            print("🚀 [SERVER FINDER]: Hedef server bulundu, aktarılıyor...")
            TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServer, LocalPlayer)
        else
            print("⚠️ [SERVER FINDER]: Uygun server bulunamadı, tekrar denetleniyor.")
        end
    end)
end

-- ==============================================================================
-- 3. MOBİL UYUMLU ARAYÜZ (GUI)
-- ==============================================================================
local function BuildUI()
    pcall(function()
        if CoreGui:FindFirstChild("LeaMainGui") then
            CoreGui.LeaMainGui:Destroy()
        end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "LeaMainGui"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = CoreGui

        -- Üst Bilgi Başlığı (LEA MOD)
        local topLabel = Instance.new("TextLabel")
        topLabel.Size = UDim2.new(0, 200, 0, 30)
        topLabel.Position = UDim2.new(0.5, -100, 0, 10)
        topLabel.BackgroundTransparency = 1
        topLabel.Text = "LEA MOD - ATLAS"
        topLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
        topLabel.TextSize = 16
        topLabel.Font = Enum.Font.GothamBold
        topLabel.Parent = screenGui

        -- Ana Menü Kutusu (Mobil)
        local mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainFrame"
        mainFrame.Size = UDim2.new(0, 220, 0, 280)
        mainFrame.Position = UDim2.new(0.5, -110, 0.5, -140)
        mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        mainFrame.BackgroundTransparency = 0.15
        mainFrame.Active = true
        mainFrame.Draggable = true
        mainFrame.Parent = screenGui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = mainFrame

        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 22, 0, 22)
        closeBtn.Position = UDim2.new(1, -26, 0, 4)
        closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        closeBtn.Text = "X"
        closeBtn.TextColor3 = Color3.new(1, 1, 1)
        closeBtn.TextSize = 10
        closeBtn.Parent = mainFrame
        Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

        -- Buton Oluşturucu Yardımcısı
        local function CreateButton(name, posY, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -20, 0, 32)
            btn.Position = UDim2.new(0, 10, 0, posY)
            btn.BackgroundColor3 = Color3.fromRGB(30, 40, 55)
            btn.Text = name
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 12
            btn.Font = Enum.Font.GothamMedium
            btn.Parent = mainFrame
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            
            btn.MouseButton1Click:Connect(callback)
            return btn
        end

        CreateButton("Küp Sistemi Aç/Kapat", 40, function()
            UpdateCube(not Lea.Modules.Cube)
        end)

        CreateButton("Üs (Base) Konumunu Kaydet", 80, function()
            SetBase()
        end)

        CreateButton("Üsse Geri Dön", 120, function()
            ReturnToBase()
        end)

        CreateButton("Server Finder (Auto-Hop)", 160, function()
            HopToBestServer()
        end)

        local toggleIcon = Instance.new("TextButton")
        toggleIcon.Size = UDim2.new(0, 40, 0, 20)
        toggleIcon.Position = UDim2.new(1, -45, 0, 5)
        toggleIcon.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
        toggleIcon.Text = "LEA"
        toggleIcon.TextColor3 = Color3.new(1, 1, 1)
        toggleIcon.TextSize = 10
        toggleIcon.Visible = false
        toggleIcon.Parent = screenGui
        Instance.new("UICorner", toggleIcon).CornerRadius = UDim.new(0, 4)

        closeBtn.MouseButton1Click:Connect(function()
            mainFrame.Visible = false
            toggleIcon.Visible = true
        end)

        toggleIcon.MouseButton1Click:Connect(function()
            mainFrame.Visible = true
            toggleIcon.Visible = false
        end)
    end)
end

RunService.Heartbeat:Connect(function()
    pcall(function()
        if Lea.Modules.Cube and cubePart then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hrp and hum then
                local isMoving = (hum.MoveDirection.Magnitude > 0.1)
                local isJumping = (hum:GetState() == Enum.HumanoidStateType.Jumping)
                if isMoving or isJumping then
                    cubePart.CFrame = hrp.CFrame * CFrame.new(0, -3.4, 0)
                    cubePart.Transparency = 0.3
                else
                    cubePart.Transparency = 1
                end
            end
        end
    end)
end)

BuildUI()
print("✅ [LEA CORE]: Tüm sistemler eksiksiz yüklendi.")
