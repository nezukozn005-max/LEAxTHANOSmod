-- ==============================================================================
-- LEA MOD - ATLAS STREAMLINED ENGINE (PART 1/2 - CORE & SERVER HOPPER)
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

print("⚡ [LEA ATLAS]: Sunucu Tarayıcı ve Çekirdek Başlatılıyor...")

getgenv().LeaAtlas = getgenv().LeaAtlas or {}
local Lea = getgenv().LeaAtlas

Lea.Modules = {
    Cube = false,
    Follow = false,
    Medusa = false
}

Lea.Settings = {
    FollowSpeed = 25,
    MedusaRange = 15,
    CubeDimensions = Vector3.new(2.5, 0.4, 2.5)
}

Lea.Target = nil
Lea.BasePosition = nil
Lea.IsReturning = false
Lea.IsAllowingTeleport = false

-- ==============================================================================
-- 1. ATLAS TARZI GELİŞMİŞ SERVER FINDER (SUB-SYSTEM 1)
-- ==============================================================================
local function AtlasServerFinder()
    pcall(function()
        print("🔍 [ATLAS FINDER]: Optimize edilmiş sunucular taranıyor...")
        local placeId = game.PlaceId
        local cursor = ""
        local foundServer = false
        
        repeat
            local url = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100%s", tostring(placeId), cursor ~= "" and "&cursor=" .. cursor or "")
            local success, response = pcall(function()
                return game:HttpGet(url)
            end)
            
            if success and response then
                local data = HttpService:JSONDecode(response)
                if data and data.data then
                    for _, server in ipairs(data.data) do
                        if server.id ~= game.JobId and server.playing and server.maxPlayers and server.playing < server.maxPlayers then
                            if server.ping and server.ping < 150 or not server.ping then
                                print("🚀 [ATLAS FINDER]: Uygun sunucu bulundu! ID: " .. tostring(server.id))
                                Lea.IsAllowingTeleport = true
                                foundServer = true
                                TeleportService:TeleportToPlaceInstance(placeId, server.id, LocalPlayer)
                                break
                            end
                        end
                    end
                    cursor = data.nextPageCursor or ""
                else
                    break
                end
            else
                break
            end
            task.wait(0.2)
        まで until foundServer or cursor == "" or cursor == nil
        
        if not foundServer then
            print("⚠️ [ATLAS FINDER]: Uygun boş sunucu bulunamadı, tekrar deneniyor...")
        end
    end)
end

Lea.AtlasServerFinder = AtlasServerFinder

-- ==============================================================================
-- 2. KÜP SİSTEMİ (SUB-SYSTEM 2)
-- ==============================================================================
local cubePart = nil
local function ToggleCube(state)
    Lea.Modules.Cube = state
    pcall(function()
        if state then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and not cubePart then
                cubePart = Instance.new("Part")
                cubePart.Name = "LeaAtlasCube"
                cubePart.Size = Lea.Settings.CubeDimensions
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

task.spawn(function()
    while task.wait(0.04) do
        pcall(function()
            if Lea.Modules.Cube and cubePart then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hrp and hum then
                    local isMoving = (hum.MoveDirection.Magnitude > 0.1)
                    local isJumping = (hum:GetState() == Enum.HumanoidStateType.Jumping)
                    if isMoving or isJumping then
                        cubePart.Position = hrp.Position - Vector3.new(0, 3.4, 0)
                        cubePart.Transparency = 0.3
                    else
                        cubePart.Transparency = 1
                    end
                end
            end
        end)
    end
end)

print("✅ [LEA ATLAS]: Part 1 yüklendi.")
-- ==============================================================================
-- LEA MOD - LEGITIMATE UI & SERVER TELEPORT INTERFACE (PART 2/2)
-- ==============================================================================

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ==============================================================================
-- 1. MOBİL UYUMLU SUNUCU LİSTE MENÜSÜ (GUI)
-- ==============================================================================
local function CreateAtlasServerMenu()
    local existingGui = PlayerGui:FindFirstChild("AtlasServerGui")
    if existingGui then existingGui:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AtlasServerGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui

    -- Mobil için küçük boyutlu ana çerçeve (160x220)
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 160, 0, 220)
    frame.Position = UDim2.new(0.5, -80, 0.5, -110)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 20)
    title.BackgroundTransparency = 1
    title.Text = "ATLAS FINDER"
    title.TextColor3 = Color3.fromRGB(0, 255, 180)
    title.TextSize = 10
    title.Font = Enum.Font.GothamBold
    title.Parent = frame

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(0.9, 0, 0.75, 0)
    scrollFrame.Position = UDim2.new(0.05, 0, 0.12, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.ScrollBarThickness = 2
    scrollFrame.Parent = frame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 4)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = scrollFrame

    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    end)

    return scrollFrame
end

-- ==============================================================================
-- 2. VERİ TARAMA VE TELEPORT İŞLEYİCİSİ
-- ==============================================================================
local function PopulateServerList(scrollContainer)
    for _, child in ipairs(scrollContainer:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    pcall(function()
        local placeId = game.PlaceId
        local url = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=20", tostring(placeId))
        local response = game:HttpGet(url)
        
        if response then
            local data = HttpService:JSONDecode(response)
            if data and data.data then
                for index, server in ipairs(data.data) do
                    if server.id ~= game.JobId and server.playing < server.maxPlayers then
                        local btn = Instance.new("TextButton")
                        btn.Size = UDim2.new(1, 0, 0, 22)
                        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                        btn.Text = string.format("Server #%d (%d/%d)", index, server.playing, server.maxPlayers)
                        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                        btn.TextSize = 8
                        btn.Font = Enum.Font.GothamSemibold
                        btn.Parent = scrollContainer

                        local btnCorner = Instance.new("UICorner")
                        btnCorner.CornerRadius = UDim.new(0, 4)
                        btnCorner.Parent = btn

                        btn.MouseButton1Click:Connect(function()
                            btn.Text = "Işınlanıyor..."
                            TeleportService:TeleportToPlaceInstance(placeId, server.id, LocalPlayer)
                        end)
                    end
                end
            end
        end
    end)
end

-- ==============================================================================
-- 3. ÇALIŞTIRMA
-- ==============================================================================
local container = CreateAtlasServerMenu()
task.spawn(function()
    PopulateServerList(container)
end)

print("✅ [LEA ATLAS]: Mobil arayüz ve teleport sistemi hazır.")
