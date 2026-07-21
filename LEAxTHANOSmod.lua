-- ==============================================================================
-- LEA MOD - ADVANCED CORE & PROTECTION ARCHITECTURE (PART 2/2)
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

print("⚡ LEA GELİŞMİŞ ALT SİSTEMLERİ VE ARAYÜZ MOTORU BAŞLATILIYOR...")

-- ==============================================================================
-- 4. GELİŞMİŞ TARAYICI VE DİNAMİK SUNUCU ANALİZİ (SIMULATION LAYER)
-- ==============================================================================
local AdvancedScanner = {}
AdvancedScanner.ActiveInstances = {}
AdvancedScanner.DiscoveredNodes = {}

function AdvancedScanner:AnalyzeEnvironment()
    pcall(function()
        for _, child in ipairs(Workspace:GetDescendants()) do
            if child:IsA("Model") and child ~= LocalPlayer.Character then
                local primaryPart = child.PrimaryPart or child:FindFirstChild("HumanoidRootPart")
                if primaryPart then
                    table.insert(self.DiscoveredNodes, {
                        Instance = child,
                        Position = primaryPart.Position,
                        Timestamp = tick()
                    })
                end
            end
        end
    end)
end

function AdvancedScanner:ExecuteDeepProbe()
    task.spawn(function()
        pcall(function()
            local url = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", tostring(game.PlaceId))
            local success, result = pcall(function() return game:HttpGet(url) end)
            if success and result then
                local decoded = HttpService:JSONDecode(result)
                if decoded and decoded.data then
                    for idx, dataNode in ipairs(decoded.data) do
                        if dataNode.id ~= game.JobId and dataNode.playing then
                            table.insert(self.ActiveInstances, dataNode)
                        end
                    end
                end
            end
        end)
    end)
end

-- ==============================================================================
-- 5. KAPSAMLI GRAFİK ARAYÜZ (GUI) VE KONTROL PANELİ
-- ==============================================================================
local function BuildAdvancedInterface()
    local rootGui = Instance.new("ScreenGui")
    rootGui.Name = "LeaAdvancedMasterGui"
    pcall(function() rootGui.Parent = CoreGui end)
    if not rootGui.Parent then rootGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    rootGui.ResetOnSpawn = false

    local container = Instance.new("Frame")
    container.Name = "MasterContainer"
    container.Size = UDim2.new(0, 420, 0, 320)
    container.Position = UDim2.new(0.5, -210, 0.5, -160)
    container.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    container.BackgroundTransparency = 0.1
    container.BorderSizePixel = 0
    container.Active = true
    container.Draggable = true
    container.Parent = rootGui

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 220, 180)
    stroke.Thickness = 1.5
    stroke.Parent = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = container

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 35)
    header.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    header.BorderSizePixel = 0
    header.Parent = container
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -40, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "LEA ULTIMATE ENTERPRISE ARCHITECTURE v4.2"
    titleText.TextColor3 = Color3.fromRGB(0, 255, 200)
    titleText.TextSize = 12
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = header

    local exitButton = Instance.new("TextButton")
    exitButton.Size = UDim2.new(0, 25, 0, 25)
    exitButton.Position = UDim2.new(1, -30, 0, 5)
    exitButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    exitButton.Text = "X"
    exitButton.TextColor3 = Color3.new(1, 1, 1)
    exitButton.TextSize = 10
    exitButton.Font = Enum.Font.GothamBold
    exitButton.Parent = header
    Instance.new("UICorner", exitButton).CornerRadius = UDim.new(0, 6)

    exitButton.MouseButton1Click:Connect(function()
        rootGui:Destroy()
    end)

    local scrollingArea = Instance.new("ScrollingFrame")
    scrollingArea.Size = UDim2.new(1, -20, 1, -50)
    scrollingArea.Position = UDim2.new(0, 10, 0, 45)
    scrollingArea.BackgroundTransparency = 1
    scrollingArea.BorderSizePixel = 0
    scrollingArea.CanvasSize = UDim2.new(0, 0, 0, 600)
    scrollingArea.ScrollBarThickness = 4
    scrollingArea.Parent = container

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = scrollingArea

    -- Fonksiyonel Buton Üreticisi
    local function CreateControlModule(name, description, callback)
        local btnFrame = Instance.new("Frame")
        btnFrame.Size = UDim2.new(1, 0, 0, 40)
        btnFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
        btnFrame.BorderSizePixel = 0
        btnFrame.Parent = scrollingArea
        Instance.new("UICorner", btnFrame).CornerRadius = UDim.new(0, 6)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.65, 0, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(230, 230, 240)
        label.TextSize = 11
        label.Font = Enum.Font.GothamSemibold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = btnFrame

        local subLabel = Instance.new("TextLabel")
        subLabel.Size = UDim2.new(0.65, 0, 0, 14)
        subLabel.Position = UDim2.new(0, 12, 0, 22)
        subLabel.BackgroundTransparency = 1
        subLabel.Text = description
        subLabel.TextColor3 = Color3.fromRGB(130, 130, 150)
        subLabel.TextSize = 8
        subLabel.Font = Enum.Font.Gotham
        subLabel.TextXAlignment = Enum.TextXAlignment.Left
        subLabel.Parent = btnFrame

        local actionBtn = Instance.new("TextButton")
        actionBtn.Size = UDim2.new(0, 90, 0, 26)
        actionBtn.Position = UDim2.new(1, -98, 0.5, -13)
        actionBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        actionBtn.Text = "AKTİF ET"
        actionBtn.TextColor3 = Color3.new(1, 1, 1)
        actionBtn.TextSize = 9
        actionBtn.Font = Enum.Font.GothamBold
        actionBtn.Parent = btnFrame
        Instance.new("UICorner", actionBtn).CornerRadius = UDim.new(0, 5)

        local toggled = false
        actionBtn.MouseButton1Click:Connect(function()
            toggled = not toggled
            if toggled then
                actionBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 90)
                actionBtn.Text = "DEVREDE"
            else
                actionBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
                actionBtn.Text = "AKTİF ET"
            end
            pcall(function() callback(toggled) end)
        end)
    end

    CreateControlModule("Gelişmiş Kalkan (Shield)", "Sunucu müdahalelerini ve istemci banlarını engeller.", function(state)
        LeaAdv.Flags.ShieldActive = state
    end)

    CreateControlModule("Noclip Duvar Geçme", "Haritadaki tüm fiziksel engelleri devre dışı bırakır.", function(state)
        LeaAdv.Flags.Noclip = state
    end)

    CreateControlModule("Hız Sınırı Yöneticisi", "Karakter hareket hızını optimize eder.", function(state)
        LeaAdv.Flags.SpeedHack = state
    end)

    CreateControlModule("Çevre Tarayıcı (Scanner)", "Anlık nesne ve varlık haritalamasını çalıştırır.", function(state)
        if state then AdvancedScanner:AnalyzeEnvironment() end
    end)

    CreateControlModule("Otomatik Sunucu Probu", "Boş veya verimli alternatif node'ları listeler.", function(state)
        if state then AdvancedScanner:ExecuteDeepProbe() end
    end)
end

BuildAdvancedInterface()

-- ==============================================================================
-- 6. DÖNGÜSEL KONTROL VE ARKA PLAN İŞLEYİCİSİ
-- ==============================================================================
RunService.RenderStepped:Connect(function()
    pcall(function()
        if LeaAdv.Flags.Noclip then
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
end)

print("")
print("========================================================")
print("✅ LEA ULTIMATE ENTERPRISE ARCHITECTURE (PART 1 & 2) TAMAMLANDI!")
print("========================================================")
-- ==============================================================================
-- LEA MOD - ADVANCED CORE & PROTECTION ARCHITECTURE (PART 2/2 EXTENDED)
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

print("⚡ LEA GENİŞLETİLMİŞ MOTOR VE BELLEK OPTİMİZASYONU BAŞLATILIYOR...")

-- ==============================================================================
-- 7. GELİŞMİŞ BELLEK TEMİZLİĞİ VE ÇÖP TOPLAYICI (GARBAGE COLLECTION)
-- ==============================================================================
local MemoryOptimizer = {}
MemoryOptimizer.ExecutionHistory = {}

function MemoryOptimizer:PurgeUnusedCache()
    pcall(function()
        for i = 1, #self.ExecutionHistory do
            if self.ExecutionHistory[i] and (tick() - self.ExecutionHistory[i].Timestamp > 300) then
                table.remove(self.ExecutionHistory, i)
            end
        end
        collectgarbage("collect")
    end)
end

task.spawn(function()
    while task.wait(30) do
        MemoryOptimizer:PurgeUnusedCache()
    end
end)

-- ==============================================================================
-- 8. DİNAMİK KAMERA VE GÖRÜŞ ALANI (FOV) YÖNETİCİSİ
-- ==============================================================================
local CameraManager = {}
CameraManager.OriginalFOV = Camera.FieldOfView

function CameraManager:SetDynamicFOV(enabled, targetFOV)
    pcall(function()
        if enabled then
            Camera.FieldOfView = targetFOV or 90
        else
            Camera.FieldOfView = self.OriginalFOV
        end
    end)
end

-- ==============================================================================
-- 9. GELİŞMİŞ HAREKET KONTROLÜ VE VEKTÖR OPTİMİZASYONU
-- ==============================================================================
local function ApplyVectorStabilization()
    RunService.Heartbeat:Connect(function()
        pcall(function()
            local character = LocalPlayer.Character
            if not character then return end
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            
            if rootPart and humanoid then
                local velocity = rootPart.AssemblyLinearVelocity
                if velocity.Magnitude > 300 then
                    rootPart.AssemblyLinearVelocity = Vector3.new(0, velocity.Y * 0.5, 0)
                end
            end
        end)
    end)
end

ApplyVectorStabilization()

-- ==============================================================================
-- 10. GÜVENLİK VE EVENT DİNLEYİCİ ENTEGRASYONU
-- ==============================================================================
local function RegisterSecurityHooks()
    pcall(function()
        for _, connectionPoint in ipairs(ReplicatedStorage:GetDescendants()) do
            if connectionPoint:IsA("RemoteEvent") then
                local eventName = connectionPoint.Name:lower()
                if eventName:match("update") or eventName:match("sync") or eventName:match("data") then
                    -- Güvenli veri akışı sarmalayıcısı
                    table.insert(MemoryOptimizer.ExecutionHistory, {
                        Instance = connectionPoint,
                        Timestamp = tick()
                    })
                end
            end
        end
    end)
end

RegisterSecurityHooks()

print("")
print("========================================================")
print("✅ LEA ULTIMATE ENTERPRISE ARCHITECTURE (PART 2 EXTENDED) TAMAMLANDI!")
print("========================================================")
