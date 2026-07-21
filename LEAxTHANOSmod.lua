-- ==============================================================================
-- LEA MOD - STABLE MICRO MATRIX EXTENSION
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

print("⚡ [LEA MICRO]: Stable core ve micro arayüz başlatılıyor...")

getgenv().LeaState = getgenv().LeaState or {
    Modules = {
        Cube = false,
        ServerFinder = false
    },
    Settings = {
        ReturnSpeed = 0.08,
        MinServerPlayers = 1,
        MaxServerPlayers = 10
    },
    BasePosition = nil,
    IsReturning = false
}

local Lea = getgenv().LeaState

-- ==============================================================================
-- 1. KÜP, TAKİP VE BASE (ÜS) SİSTEMİ (ÇALIŞAN ORİJİNAL MANTIK)
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
            -- Pürüzsüz ve yavaşlatılmış dönüş hızı
            hrp.CFrame = CFrame.new(hrp.Position:Lerp(Lea.BasePosition, Lea.Settings.ReturnSpeed))
            task.wait()
        end
    end)
end

-- ==============================================================================
-- 2. SERVER FINDER & AUTO-HOP SİSTEMİ
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
-- 3. MİKRO BOYUTLU MOBİL UYUMLU ARAYÜZ (MICRO UI)
-- ==============================================================================
local function BuildMicroUI()
    pcall(function()
        if CoreGui:FindFirstChild("LeaMicroGui") then
            CoreGui.LeaMicroGui:Destroy()
        end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "LeaMicroGui"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = CoreGui

        -- Mikro Ana Çerçeve (130x165)
        local mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainFrame"
        mainFrame.Size = UDim2.new(0, 130, 0, 165)
        mainFrame.Position = UDim2.new(0.5, -65, 0.4, -82)
        mainFrame.BackgroundColor3 = Color3.fromRGB(12, 15, 22)
        mainFrame.BackgroundTransparency = 0.1
        mainFrame.Active = true
        mainFrame.Draggable = true
        mainFrame.Parent = screenGui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = mainFrame

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -20, 0, 18)
        title.Position = UDim2.new(0, 4, 0, 2)
        title.BackgroundTransparency = 1
        title.Text = "LEA MICRO"
        title.TextColor3 = Color3.fromRGB(0, 255, 200)
        title.TextSize = 9
        title.Font = Enum.Font.GothamBold
        title.Parent = mainFrame

        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 16, 0, 16)
        closeBtn.Position = UDim2.new(1, -18, 0, 2)
        closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        closeBtn.Text = "X"
        closeBtn.TextColor3 = Color3.new(1, 1, 1)
        closeBtn.TextSize = 8
        closeBtn.Parent = mainFrame
        Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 3)

        local yPos = 22
        local function CreateMicroButton(name, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -8, 0, 22)
            btn.Position = UDim2.new(0, 4, 0, yPos)
            btn.BackgroundColor3 = Color3.fromRGB(25, 32, 44)
            btn.Text = name
            btn.TextColor3 = Color3.fromRGB(210, 210, 210)
            btn.TextSize = 8
            btn.Font = Enum.Font.GothamMedium
            btn.Parent = mainFrame
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            
            btn.MouseButton1Click:Connect(callback)
            yPos = yPos + 24
            return btn
        end

        CreateMicroButton("Küp Aç/Kapat", function()
            UpdateCube(not Lea.Modules.Cube)
        end)

        CreateMicroButton("Base Kaydet", function()
            SetBase()
        end)

        CreateMicroButton("Base'e Dön", function()
            ReturnToBase()
        end)

        CreateMicroButton("Server Finder", function()
            HopToBestServer()
        end)

        local toggleIcon = Instance.new("TextButton")
        toggleIcon.Size = UDim2.new(0, 30, 0, 16)
        toggleIcon.Position = UDim2.new(1, -35, 0, 2)
        toggleIcon.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
        toggleIcon.Text = "LEA"
        toggleIcon.TextColor3 = Color3.new(1, 1, 1)
        toggleIcon.TextSize = 8
        toggleIcon.Visible = false
        toggleIcon.Parent = screenGui
        Instance.new("UICorner", toggleIcon).CornerRadius = UDim.new(0, 3)

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

BuildMicroUI()
print("✅ [LEA MICRO]: Kararlı çekirdek ve mikro arayüz aktif.")
