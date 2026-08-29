-- ============================================================
-- HAMSTER LIVES - SİYAH EKRAN MESAJI
-- ============================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

print("🔲 SİYAH EKRAN BAŞLADI...")

local function CreateBlackScreen()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then
        pg = Instance.new("ScreenGui")
        pg.Name = "PlayerGui"
        pg.Parent = LocalPlayer
        task.wait(0.1)
    end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "BlackScreen"
    gui.Parent = pg
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- TAM EKRAN SİYAH
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0
    bg.Parent = gui
    bg.ZIndex = 999
    
    -- YAZI
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(0.9, 0, 0, 60)
    text.Position = UDim2.new(0.05, 0, 0.4, 0)
    text.BackgroundTransparency = 1
    text.Text = "Bu kadar sinirlenmene gerek yok"
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextSize = 24
    text.Font = Enum.Font.GothamBold
    text.TextWrapped = true
    text.TextXAlignment = Enum.TextXAlignment.Center
    text.Parent = gui
    text.ZIndex = 1000
end

-- ============================================================
-- BAŞLAT
-- ============================================================
task.wait(0.3)
CreateBlackScreen()

print("✅ Siyah ekran aktif!")
