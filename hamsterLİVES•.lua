-- ============================================================
-- HAMSTER LIVES - MOD1 & MOD2 KODLARI (PART 1/2)
-- ScrollMenu'deki butonlara eklenecek
-- ============================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- EGG REMOTE'LARI BUL
-- ============================================================
local EggRemotes = {}

local function FindEggRemotes()
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            if name:find("egg") or name:find("carry") or name:find("collect") or name:find("pickup") or name:find("grab") or name:find("field") then
                table.insert(EggRemotes, obj)
            end
        end
    end
end

-- ============================================================
-- MOD1: ANINDA EGG ALMA (E TUŞU BEKLEME YOK)
-- ============================================================
local Mod1Active = false

local function Mod1_EggCarry()
    if not Mod1Active then return end
    
    print("🥚 EGG ALINIYOR...")
    
    -- 1. Tüm egg remote'larını fırlat
    for _, remote in ipairs(EggRemotes) do
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer()
            elseif remote:IsA("RemoteFunction") then
                remote:InvokeServer()
            end
        end)
    end
    
    -- 2. ProximityPrompt'ları tetikle
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local name = obj.Name:lower()
            if name:find("egg") or name:find("carry") or name:find("collect") then
                pcall(function() obj:Prompt() end)
            end
        end
    end
    
    -- 3. Cooldown'ları sıfırla
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("IntValue") or obj:IsA("NumberValue") then
            local name = obj.Name:lower()
            if name:find("cooldown") or name:find("cd") then
                pcall(function() obj.Value = 0 end)
            end
        end
    end
    
    -- 4. Touch simülasyonu (karakteri egg'in yanına götür)
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local name = obj.Name:lower()
                    if name:find("egg") or name:find("carry") or name:find("collect") then
                        local oldPos = hrp.Position
                        hrp.CFrame = CFrame.new(obj.Position + Vector3.new(0, 2, 0))
                        task.wait(0.1)
                        hrp.CFrame = CFrame.new(oldPos)
                        break
                    end
                end
            end
        end
    end
    
    print("✅ EGG ALMA TAMAMLANDI!")
end-- ============================================================
-- HAMSTER LIVES - MOD1 & MOD2 KODLARI (PART 2/2)
-- BUTON BAĞLANTILARI | E TUŞU | BAŞLAT
-- ============================================================

-- ============================================================
-- MOD2: DÜŞME KORUMA (GUARD VURUNCA EGG DÜŞMEZ)
-- ============================================================
local Mod2Active = false
local Mod2Connections = {}

local function Mod2_FallProtection()
    if not Mod2Active then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    
    -- Önceki bağlantıları temizle
    for _, conn in ipairs(Mod2Connections) do
        pcall(function() conn:Disconnect() end)
    end
    Mod2Connections = {}
    
    -- Vurulunca egg düşmesin
    local conn1 = hum.HealthChanged:Connect(function(health)
        local old = hum.Health
        if health < old then
            print("🛡️ VURULDU! EGG DÜŞMEDİ!")
            Mod1_EggCarry()
        end
    end)
    table.insert(Mod2Connections, conn1)
    
    -- Düşünce hemen kalk
    local conn2 = hum.StateChanged:Connect(function(oldState, newState)
        if newState == Enum.HumanoidStateType.FallingDown then
            print("🛡️ DÜŞTÜ! EGG KORUNDU!")
            task.wait(0.05)
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            task.wait(0.1)
            Mod1_EggCarry()
        end
    end)
    table.insert(Mod2Connections, conn2)
    
    print("🛡️ DÜŞME KORUMA AKTİF!")
end

-- ============================================================
-- E TUŞU (MOD1 AKTİF İKEN ANINDA AL)
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E then
        if Mod1Active then
            Mod1_EggCarry()
        end
    end
end)

-- ============================================================
-- MENÜ'DEKİ BUTONLARI BUL VE BAĞLA
-- ============================================================
local function ConnectMenuButtons()
    local scrollMenu = LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("ScrollMenu")
    if not scrollMenu then
        print("⏳ ScrollMenu bulunamadı!")
        return
    end
    
    -- MOD1 BUTONU
    local btn1 = scrollMenu:FindFirstChild("ModButton1")
    if btn1 then
        btn1.MouseButton1Click:Connect(function()
            Mod1Active = not Mod1Active
            if Mod1Active then
                btn1.Text = "✅ MOD1 AKTİF"
                btn1.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                print("⚡ MOD1 AKTİF - E tuşuna basınca anında egg al")
                Mod1_EggCarry()
            else
                btn1.Text = "MOD 1"
                btn1.BackgroundColor3 = Color3.fromRGB(150, 32, 28)
                print("⏹️ MOD1 PASİF")
            end
        end)
        print("✅ MOD1 butonu bağlandı!")
    end
    
    -- MOD2 BUTONU
    local btn2 = scrollMenu:FindFirstChild("ModButton2")
    if btn2 then
        btn2.MouseButton1Click:Connect(function()
            Mod2Active = not Mod2Active
            if Mod2Active then
                btn2.Text = "✅ MOD2 AKTİF"
                btn2.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                print("🛡️ MOD2 AKTİF - Vurulunca egg düşmez")
                Mod2_FallProtection()
            else
                btn2.Text = "MOD 2"
                btn2.BackgroundColor3 = Color3.fromRGB(150, 32, 28)
                print("⏹️ MOD2 PASİF")
            end
        end)
        print("✅ MOD2 butonu bağlandı!")
    end
end

-- ============================================================
-- BAŞLAT
-- ============================================================
task.wait(1)

-- Egg remote'larını bul
FindEggRemotes()
print("✅ " .. #EggRemotes .. " egg remote bulundu.")

-- Menü butonlarını bağla
ConnectMenuButtons()

-- Menü henüz yüklenmediyse bekle
local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
if playerGui then
    playerGui.ChildAdded:Connect(function(child)
        if child.Name == "ScrollMenu" then
            task.wait(0.5)
            ConnectMenuButtons()
        end
    end)
end

print("")
print("========================================")
print("🐹 MOD1 & MOD2 HAZIR!")
print("   🟢 MOD1: Anında egg alma (E tuşu)")
print("   🛡️ MOD2: Düşme koruma")
print("========================================")
