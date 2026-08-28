-- ============================================================
-- HAMSTER LIVES - BAKIM EKRANI (SİYAH)
-- ============================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

print("🔧 BAKIM EKRANI BAŞLADI...")

local function CreateMaintenanceScreen()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then
        pg = Instance.new("ScreenGui")
        pg.Name = "PlayerGui"
        pg.Parent = LocalPlayer
    end
    
    local old = pg:FindFirstChild("MaintenanceScreen")
    if old then old:Destroy() end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "MaintenanceScreen"
    gui.Parent = pg
    gui.ResetOnSpawn = false
    
    -- TAM EKRAN SİYAH (ARKA PLAN)
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0
    bg.Parent = gui
    bg.ZIndex = 0
    
    -- ANA KUTU (ORTADA)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0
    frame.Parent = gui
    frame.ZIndex = 1
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 0)
    
    -- YAZI 1: BAKIMDAYIZ
    local text1 = Instance.new("TextLabel")
    text1.Size = UDim2.new(1, 0, 0, 40)
    text1.Position = UDim2.new(0, 0, 0, 10)
    text1.BackgroundTransparency = 1
    text1.Text = "BAKIMDAYIZ"
    text1.TextColor3 = Color3.fromRGB(255, 255, 255)
    text1.TextSize = 32
    text1.Font = Enum.Font.GothamBold
    text1.Parent = frame
    text1.ZIndex = 2
    
    -- YAZI 2: BAKİYOZ DAYİ
    local text2 = Instance.new("TextLabel")
    text2.Size = UDim2.new(1, 0, 0, 30)
    text2.Position = UDim2.new(0, 0, 0, 55)
    text2.BackgroundTransparency = 1
    text2.Text = "BAKİYOZ DAYİ"
    text2.TextColor3 = Color3.fromRGB(200, 200, 200)
    text2.TextSize = 22
    text2.Font = Enum.Font.Gotham
    text2.Parent = frame
    text2.ZIndex = 2
end

-- ============================================================
-- BAŞLAT
-- ============================================================
task.wait(0.3)
CreateMaintenanceScreen()

print("")
print("========================================")
print("🔧 BAKIM EKRANI HAZIR!")
print("   📌 Tam ekran siyah")
print("   📝 BAKIMDAYIZ / BAKİYOZ DAYİ")
print("========================================")
