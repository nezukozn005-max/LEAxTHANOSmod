-- ============================================================
-- HAMSTER LIVES - BAKIM EKRANI
-- 200x300 | KARANLIK | YAZI | TAMAM BUTONU | NOT
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
    
    -- ANA FRAME (200x320 - biraz uzattım not için)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 320)
    frame.Position = UDim2.new(0.5, -100, 0.5, -160)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.1
    frame.Parent = gui
    frame.ZIndex = 1000
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    -- İNCE KENARLIK
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 1.5
    stroke.Color = Color3.fromRGB(60, 60, 60)
    stroke.Transparency = 0.5
    
    -- YAZI 1: :/
    local text1 = Instance.new("TextLabel")
    text1.Size = UDim2.new(1, 0, 0, 30)
    text1.Position = UDim2.new(0, 0, 0, 20)
    text1.BackgroundTransparency = 1
    text1.Text = ":/"
    text1.TextColor3 = Color3.fromRGB(255, 255, 255)
    text1.TextSize = 28
    text1.Font = Enum.Font.GothamBold
    text1.Parent = frame
    text1.ZIndex = 1001
    
    -- YAZI 2: BAKIMDA ÖZÜR DİLERİM
    local text2 = Instance.new("TextLabel")
    text2.Size = UDim2.new(1, 0, 0, 22)
    text2.Position = UDim2.new(0, 0, 0, 55)
    text2.BackgroundTransparency = 1
    text2.Text = "BAKIMDA ÖZÜR DİLERİM"
    text2.TextColor3 = Color3.fromRGB(255, 255, 255)
    text2.TextSize = 12
    text2.Font = Enum.Font.GothamBold
    text2.Parent = frame
    text2.ZIndex = 1001
    
    -- YAZI 3: BOYLE OLMASİNİ BEN İSTEMEDİM
    local text3 = Instance.new("TextLabel")
    text3.Size = UDim2.new(1, 0, 0, 22)
    text3.Position = UDim2.new(0, 0, 0, 80)
    text3.BackgroundTransparency = 1
    text3.Text = "BÖYLE OLMASINI"
    text3.TextColor3 = Color3.fromRGB(255, 255, 255)
    text3.TextSize = 12
    text3.Font = Enum.Font.GothamBold
    text3.Parent = frame
    text3.ZIndex = 1001
    
    -- YAZI 4: BEN İSTEMEDİM
    local text4 = Instance.new("TextLabel")
    text4.Size = UDim2.new(1, 0, 0, 22)
    text4.Position = UDim2.new(0, 0, 0, 102)
    text4.BackgroundTransparency = 1
    text4.Text = "BEN İSTEMEDİM"
    text4.TextColor3 = Color3.fromRGB(255, 255, 255)
    text4.TextSize = 12
    text4.Font = Enum.Font.GothamBold
    text4.Parent = frame
    text4.ZIndex = 1001
    
    -- YAZI 5: SADECE BİL
    local text5 = Instance.new("TextLabel")
    text5.Size = UDim2.new(1, 0, 0, 22)
    text5.Position = UDim2.new(0, 0, 0, 124)
    text5.BackgroundTransparency = 1
    text5.Text = "SADECE BİL"
    text5.TextColor3 = Color3.fromRGB(255, 255, 255)
    text5.TextSize = 12
    text5.Font = Enum.Font.GothamBold
    text5.Parent = frame
    text5.ZIndex = 1001
    
    -- AYIRICI ÇİZGİ 1
    local line1 = Instance.new("Frame")
    line1.Size = UDim2.new(0.6, 0, 0, 1)
    line1.Position = UDim2.new(0.2, 0, 0, 158)
    line1.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    line1.BackgroundTransparency = 0.5
    line1.Parent = frame
    line1.ZIndex = 1001
    
    -- NOT YAZISI
    local note = Instance.new("TextLabel")
    note.Size = UDim2.new(1, -20, 0, 40)
    note.Position = UDim2.new(0, 10, 0, 170)
    note.BackgroundTransparency = 1
    note.Text = "Sen her şeye sinirlenen,\nben her şeye kırılan birisiyim merdo"
    note.TextColor3 = Color3.fromRGB(180, 180, 180)
    note.TextSize = 10
    note.Font = Enum.Font.Gotham
    note.TextXAlignment = Enum.TextXAlignment.Center
    note.Parent = frame
    note.ZIndex = 1001
    
    -- AYIRICI ÇİZGİ 2
    local line2 = Instance.new("Frame")
    line2.Size = UDim2.new(0.6, 0, 0, 1)
    line2.Position = UDim2.new(0.2, 0, 0, 220)
    line2.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    line2.BackgroundTransparency = 0.5
    line2.Parent = frame
    line2.ZIndex = 1001
    
    -- TAMAM BUTONU
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.6, 0, 0, 35)
    btn.Position = UDim2.new(0.2, 0, 0, 240)
    btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    btn.Text = "TAMAM"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame
    btn.ZIndex = 1002
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    -- HOVER
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(220, 0, 0)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    end)
    
    -- TIKLAYINCA SCRİPT KAPANSIN
    btn.MouseButton1Click:Connect(function()
        print("🔧 BAKIM EKRANI KAPATILIYOR...")
        gui:Destroy()
        script:Destroy()
    end)
end

-- ============================================================
-- BAŞLAT
-- ============================================================
task.wait(0.5)
CreateMaintenanceScreen()

print("")
print("========================================")
print("🔧 BAKIM EKRANI HAZIR!")
print("   📌 TAMAM butonuna bas → Kapat")
print("========================================")
