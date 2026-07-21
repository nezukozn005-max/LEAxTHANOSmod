-- ==============================================================================
-- LEA MOD - TACTICAL (FLY, CUBE, BASE & FOLLOW SYSTEM)
-- ==============================================================================

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/Fluent.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "LEA MOD - TACTICAL",
    SubTitle = "Base, Follow, Fly & Cube System",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Takip & Base", Icon = "navigation" }),
    Settings = Window:AddTab({ Title = "Ayarlar", Icon = "settings" })
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera

-- ==============================================================================
-- DURUM DEĞİŞKENLERİ VE KONTROL SİSTEMİ
-- ==============================================================================
local FlyEnabled = false
local FlySpeed = 35

local SavedBasePosition = nil

local SelectedPlayerName = ""
local TargetPlayer = nil
local FollowEnabled = false

-- ============================================
-- CUBE SİSTEMİ (İSTENEN ÖZEL KOD BLOKU)
-- ============================================
local CubeActive = false
local CubeList = {}
local LastCubeTime = 0

local function ClearCubes()
    for _, v in ipairs(CubeList) do
        if v and v.Parent then pcall(function() v:Destroy() end) end
    end
    CubeList = {}
end

local function CreateCube(pos)
    if #CubeList > 15 then
        local old = table.remove(CubeList, 1)
        if old and old.Parent then pcall(function() old:Destroy() end) end
    end

    local cube = Instance.new("Part")
    cube.Size = Vector3.new(4, 0.5, 4)
    cube.Position = pos
    cube.Anchored = true
    cube.CanCollide = true
    cube.Transparency = 0.8
    cube.Material = Enum.Material.SmoothPlastic
    cube.Color = Color3.fromRGB(0, 170, 255)
    cube.Parent = Workspace
    table.insert(CubeList, cube)
end

local function UpdateCube(RootPart, Humanoid)
    if not CubeActive or not RootPart or not Humanoid then return end
    local now = tick()

    if RootPart.AssemblyLinearVelocity.Y < -5 and (now - LastCubeTime > 0.3) then
        CreateCube(RootPart.Position - Vector3.new(0, 3, 0))
        LastCubeTime = now
    end

    if RootPart.AssemblyLinearVelocity.Magnitude > 2 and (now - LastCubeTime > 0.3) then
        local dir = RootPart.CFrame.LookVector
        CreateCube(RootPart.Position + Vector3.new(dir.X * 3, -2.5, dir.Z * 3))
        LastCubeTime = now
    end
end

-- ==============================================================================
-- ARAYÜZ (FLUENT) BİLEŞENLERİ
-- ==============================================================================

-- 1. UÇUŞ (FLY) SİSTEMİ
Tabs.Main:AddToggle("FlyToggle", {
    Title = "Uçuş (Fly)",
    Description = "Havada serbest hareket et",
    Default = false,
    Callback = function(Value)
        FlyEnabled = Value
        if Value then
            FollowEnabled = false -- Çakışma önleyici
        end
    end
})

Tabs.Main:AddSlider("FlySpeedSlider", {
    Title = "Uçuş Hızı",
    Description = "Uçarken hareket hızını ayarla",
    Default = 35,
    Min = 10,
    Max = 100,
    Rounding = 1,
    Callback = function(Value)
        FlySpeed = Value
    end
})

-- 2. CUBE SİSTEMİ TOGGLE
Tabs.Main:AddToggle("CubeToggle", {
    Title = "Cube Sistemi (Platform)",
    Description = "Hareket ederken altına geçici platformlar oluşturur",
    Default = false,
    Callback = function(Value)
        CubeActive = Value
        if not Value then
            ClearCubes()
        end
    end
})

-- 3. BASE SİSTEMİ
Tabs.Main:AddButton({
    Title = "Bulunduğun Yeri Base Yap",
    Description = "Şu anki durduğun konumu base olarak kaydeder",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            SavedBasePosition = char.HumanoidRootPart.CFrame
            Fluent:Notify({
                Title = "Base Kaydedildi",
                Content = "Mevcut konumunuz başarıyla base olarak ayarlandı!",
                Duration = 4
            })
        end
    end
})

Tabs.Main:AddButton({
    Title = "Base'e Dön / Işınlan",
    Description = "Kaydettiğiniz base konumuna anında ışınlar",
    Callback = function()
        if SavedBasePosition then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = SavedBasePosition
                Fluent:Notify({
                    Title = "Base'e Dönüldü",
                    Content = "Başarıyla kaydedilen base konumuna ışınlandınız.",
                    Duration = 3
                })
            end
        else
            Fluent:Notify({
                Title = "Hata",
                Content = "Önce bir base konumu kaydetmelisiniz!",
                Duration = 3
            })
        end
    end
})

-- 4. OYUNCU LİSTESİ VE TAKİP SİSTEMİ
local PlayerList = {}
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        table.insert(PlayerList, p.Name)
    end
end

Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then
        table.insert(PlayerList, p.Name)
    end
end)

Players.PlayerRemoving:Connect(function(p)
    for i, name in ipairs(PlayerList) do
        if name == p.Name then
            table.remove(PlayerList, i)
        end
    end
end)

local Dropdown = Tabs.Main:AddDropdown("PlayerDropdown", {
    Title = "Takip Edilecek Oyuncu",
    Values = PlayerList,
    Default = 1,
    Callback = function(Value)
        SelectedPlayerName = Value
        TargetPlayer = Players:FindFirstChild(Value)
    end
})

Tabs.Main:AddToggle("FollowToggle", {
    Title = "Oyuncuyu Takip Et (Aura Follow)",
    Description = "Seçilen oyuncunun arkasında kal",
    Default = false,
    Callback = function(Value)
        FollowEnabled = Value
        if Value then
            FlyEnabled = false -- Çakışma önleyici
        end
    end
})

-- ==============================================================================
-- FİZİK VE GÜNCELLEME DÖNGÜSÜ (HEARTBEAT)
-- ==============================================================================
RunService.Heartbeat:Connect(function(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if hum.Health <= 0 then
        FlyEnabled = false
        FollowEnabled = false
        CubeActive = false
        ClearCubes()
        return
    end

    -- Cube Güncellemesi
    if CubeActive then
        UpdateCube(hrp, hum)
    end

    -- Fly (Uçuş) Mekaniği
    if FlyEnabled then
        hum.PlatformStand = true
        local moveDir = hum.MoveDirection
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        
        if moveDir.Magnitude > 0 then
            local targetDir = (Camera.CFrame.RightVector * moveDir.X) + (Camera.CFrame.LookVector * -moveDir.Z)
            hrp.CFrame = hrp.CFrame + (targetDir.Unit * (FlySpeed * dt))
        end
        return
    else
        if hum.PlatformStand and not FollowEnabled then
            hum.PlatformStand = false
        end
    end

    -- Takip Sistemi (Follow)
    if FollowEnabled then
        if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = TargetPlayer.Character.HumanoidRootPart
            hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 4)
        end
    end
end)

-- ==============================================================================
-- MOBİL ARAYÜZ KONTROL BUTONU
-- ==============================================================================
local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("TextButton")

ScreenGui.Parent = game:GetService("CoreGui")
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleButton.BorderColor3 = Color3.fromRGB(0, 255, 128)
ToggleButton.Position = UDim2.new(0, 20, 0, 50)
ToggleButton.Size = UDim2.new(0, 120, 0, 45)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "LEA MENU"
ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 128)
ToggleButton.TextSize = 15
ToggleButton.Active = true
ToggleButton.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    Window:Minimize()
end)

-- ==============================================================================
-- AYAR YÖNETİCİSİ VE BAŞLANGIÇ
-- ==============================================================================
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("LEAMOD_Tactical")
SaveManager:BuildConfigSection(Tabs.Settings)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)

Window:SelectTab(1)
Fluent:Notify({
    Title = "LEA MOD",
    Content = "Base, Takip, Fly ve Cube sistemleri başarıyla yüklendi!",
    Duration = 5
})
