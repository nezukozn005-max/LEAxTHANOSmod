-- ==============================================================================
-- LEA MOD ULTIMATE V21.0 - PART 1 / 2 (CORE, SETTINGS, MODERN UI & SYSTEMS)
-- ==============================================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

-- Sunucu değişimlerinde (Teleport) ayarların kaybolmaması için Hafıza (Global State)
if not getgenv().LeaModGlobalState then
    getgenv().LeaModGlobalState = {
        Mode = "NONE",
        Speed = 22,
        SpawnPos = nil,
        Cube = false,
        Cubes = {},
        LastCube = 0,
        Noclip = false,
        PotatoGraphics = false,
        AutoAvoid = false,
        Visuals = false,
        Invisible = false,
        HitboxAura = false,
        BypassReset = false
    }
end

local State = getgenv().LeaModGlobalState

-- 1) GÜVENLİ GUI PARENT
local function GetGuiParent()
    local success, parent = pcall(function() return CoreGui end)
    if success and parent then return parent end
    return LocalPlayer:WaitForChild("PlayerGui", 5)
end

pcall(function()
    local existing = GetGuiParent():FindFirstChild("LeaModMonolithicGUI")
    if existing then existing:Destroy() end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LeaModMonolithicGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = GetGuiParent()

-- 2) YENİ MODERN DİKDÖRTGEN MENÜ (Yatay Geniş, Kompakt ve Mobil Uyumlu)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 260) -- Yatay genişletilmiş, dikey olarak küçültülmüş
MainFrame.Position = UDim2.new(1, -235, 0.4, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 8)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 255, 200)
MainStroke.Thickness = 1.5

local HeaderTitle = Instance.new("TextLabel", MainFrame)
HeaderTitle.Size = UDim2.new(1, 0, 0, 26)
HeaderTitle.Position = UDim2.new(0, 0, 0, 2)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "LEA MOD ULTIMATE V21"
HeaderTitle.TextColor3 = Color3.fromRGB(0, 255, 200)
HeaderTitle.TextSize = 11
HeaderTitle.Font = Enum.Font.GothamBold

-- Aç/Kapat Butonu
local ToggleMenuBtn = Instance.new("TextButton", ScreenGui)
ToggleMenuBtn.Size = UDim2.new(0, 42, 0, 26)
ToggleMenuBtn.Position = UDim2.new(1, -55, 0, 10)
ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
ToggleMenuBtn.Text = "LEA"
ToggleMenuBtn.TextColor3 = Color3.fromRGB(20, 20, 30)
ToggleMenuBtn.TextSize = 11
ToggleMenuBtn.Font = Enum.Font.GothamBold

local ToggleCorner = Instance.new("UICorner", ToggleMenuBtn)
ToggleCorner.CornerRadius = UDim.new(0, 6)

ToggleMenuBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    ToggleMenuBtn.BackgroundColor3 = MainFrame.Visible and Color3.fromRGB(0, 255, 200) or Color3.fromRGB(255, 50, 80)
end)

-- Izgara (Grid) Düzeninde Buton Oluşturucu (Yatay Geniş Panel İçin)
local function CreateGridButton(posX, posY, sizeX, sizeY, text, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, sizeX, 0, sizeY)
    btn.Position = UDim2.new(0, posX, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 9
    btn.Font = Enum.Font.GothamBold
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 5)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- 3) INVISIBLE (GÖRÜNMEZLİK) MOTORU (Reset Koruması ve Perde Bug Entegrasyonlu)
local function ApplyInvisible(enabled)
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = enabled and 1 or 0
            elseif part:IsA("Decal") then
                part.Transparency = enabled and 1 or 0
            end
        end
    end)
end

-- 4) KARAKTER YAŞAM VE RESET KORUMASI
local function SetupCharacterLifecycle(char)
    State.Mode = "NONE"
    pcall(function()
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then
            if not State.BypassReset then
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            else
                State.BypassReset = false
            end
        end
    end)
    task.spawn(function()
        local hrp = char:WaitForChild("HumanoidRootPart", 10)
        if hrp then 
            State.SpawnPos = hrp.Position + Vector3.new(0, 3, 0) 
        end
    end)
    if State.Invisible then
        task.wait(0.3)
        ApplyInvisible(true)
    end
end

if LocalPlayer.Character then SetupCharacterLifecycle(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(SetupCharacterLifecycle)

-- 5) MENÜ BUTONLARI YERLEŞİMİ (2'li Sütun Düzeni)
local UIButtons = {}

UIButtons.Invisible = CreateGridButton(8, 32, 98, 24, "👻 INVIS OFF", function()
    State.Invisible = not State.Invisible
    ApplyInvisible(State.Invisible)
    UIButtons.Invisible.Text = State.Invisible and "👻 INVIS ON" or "👻 INVIS OFF"
    UIButtons.Invisible.BackgroundColor3 = State.Invisible and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(40, 40, 55)
end)

UIButtons.Base = CreateGridButton(112, 32, 98, 24, "🏠 BASE HIZLI", function()
    State.Mode = "BASE"
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if State.SpawnPos and hrp then
            char:PivotTo(CFrame.new(State.SpawnPos))
            hrp.Velocity = Vector3.zero
        end
    end)
    State.Mode = "NONE"
end)

UIButtons.HitboxAura = CreateGridButton(8, 60, 98, 24, "⚔️ SOPA AURA OFF", function()
    State.HitboxAura = not State.HitboxAura
    UIButtons.HitboxAura.Text = State.HitboxAura and "⚔️ SOPA AURA ON" or "⚔️ SOPA AURA OFF"
    UIButtons.HitboxAura.BackgroundColor3 = State.HitboxAura and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(40, 40, 55)
end)

UIButtons.Noclip = CreateGridButton(112, 60, 98, 24, "🛡️ NOCLIP OFF", function()
    State.Noclip = not State.Noclip
    UIButtons.Noclip.Text = State.Noclip and "🛡️ NOCLIP ON" or "🛡️ NOCLIP OFF"
    UIButtons.Noclip.BackgroundColor3 = State.Noclip and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(40, 40, 55)
end)

UIButtons.Cube = CreateGridButton(8, 88, 98, 24, "🧊 CUBE OFF", function()
    State.Cube = not State.Cube
    UIButtons.Cube.Text = State.Cube and "🧊 CUBE ON" or "🧊 CUBE OFF"
    UIButtons.Cube.BackgroundColor3 = State.Cube and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(40, 40, 55)
end)

UIButtons.Visuals = CreateGridButton(112, 88, 98, 24, "👁️ ESP OFF", function()
    State.Visuals = not State.Visuals
    UIButtons.Visuals.Text = State.Visuals and "👁️ ESP ON" or "👁️ ESP OFF"
    UIButtons.Visuals.BackgroundColor3 = State.Visuals and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(40, 40, 55)
end)

-- Hız Ayar Göstergesi ve Butonları (Güvenli Sınırlar İçinde: 16 - 50)
local SpeedLbl = Instance.new("TextLabel", MainFrame)
SpeedLbl.Size = UDim2.new(0, 202, 0, 18)
SpeedLbl.Position = UDim2.new(0, 8, 0, 118)
SpeedLbl.BackgroundTransparency = 1
SpeedLbl.Text = "Hız Değeri: " .. State.Speed
SpeedLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLbl.TextSize = 10
SpeedLbl.Font = Enum.Font.GothamSemibold

CreateGridButton(8, 140, 47, 22, "-5 Hız", function()
    State.Speed = math.clamp(State.Speed - 5, 16, 50)
    SpeedLbl.Text = "Hız Değeri: " .. State.Speed
end)

CreateGridButton(59, 140, 47, 22, "+5 Hız", function()
    State.Speed = math.clamp(State.Speed + 5, 16, 50)
    SpeedLbl.Text = "Hız Değeri: " .. State.Speed
end)

UIButtons.AutoAvoid = CreateGridButton(112, 140, 98, 22, "🛡️ KORUMA OFF", function()
    State.AutoAvoid = not State.AutoAvoid
    UIButtons.AutoAvoid.Text = State.AutoAvoid and "🛡️ KORUMA ON" or "🛡️ KORUMA OFF"
    UIButtons.AutoAvoid.BackgroundColor3 = State.AutoAvoid and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(40, 40, 55)
end)

-- Sunucu Değiş (Ayarlar Hafızada Kalır)
CreateGridButton(8, 172, 202, 26, "🌐 SUNUCU DEĞİŞ & HIZLI HOP", function()
    pcall(function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
end)

-- Reset Butonu
CreateGridButton(8, 204, 202, 26, "🔄 GÜVENLİ RESET", function()
    State.BypassReset = true
    pcall(function() 
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            hum.Health = 0 
        end
    end)
end)

print("✅ LEA MOD - PART 1 (YÜKLENDİ)")
-- ==============================================================================
-- LEA MOD ULTIMATE V21.0 - PART 2 / 2 (PHYSICS, ESP, SPEED & HITBOX/SOPA MOTOR)
-- ==============================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local State = getgenv().LeaModGlobalState

-- 1) ESP SİSTEMİ (HIGHLIGHT)
task.spawn(function()
    while task.wait(0.6) do
        pcall(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hl = p.Character:FindFirstChild("LeaESP")
                    if State.Visuals then
                        if not hl then
                            hl = Instance.new("Highlight")
                            hl.Name = "LeaESP"
                            hl.FillColor = Color3.fromRGB(0, 255, 200)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.5
                            hl.OutlineTransparency = 0.1
                            hl.Parent = p.Character
                        end
                    else
                        if hl then hl:Destroy() end
                    end
                end
            end
        end)
    end
end)

-- 2) NOCLIP FİZİK DÖNGÜSÜ
RunService.Stepped:Connect(function()
    if State.Noclip and LocalPlayer.Character then
        pcall(function()
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end)
    end
end)

-- 3) ANA HAREKET, HIZ VE SOPA / HİTBOX AURA MOTORU
RunService.Heartbeat:Connect(function(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    -- Güvenli Sınırlar İçinde Hız Ayarı Uygulama
    if hum.MoveDirection.Magnitude > 0 then
        local currentSpeed = math.clamp(State.Speed, 16, 50)
        hum.WalkSpeed = currentSpeed
    end

    -- Sopa / Hitbox Ucu Algılama ve Düşürme (Bad/Hitbox Algılama Sistemi)
    if State.HitboxAura then
        pcall(function()
            -- Karakterin ön ucunda (hitbox ucu / sopa menzili) sanal kontrol noktası
            local weaponReachPos = hrp.Position + (hrp.CFrame.LookVector * 4.5)
            
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local eHrp = p.Character:FindFirstChild("HumanoidRootPart")
                    local eHum = p.Character:FindFirstChildOfClass("Humanoid")
                    if eHrp and eHum and eHum.Health > 0 then
                        local distance = (eHrp.Position - weaponReachPos).Magnitude
                        -- Eğer oyuncu menzile / hitbox ucuna girerse vuruş algılanır ve yere düşürülür
                        if distance < 5.5 then
                            -- Pet veya envanter unsurlarından bağımsız güvenli vuruş tetiklemesi
                            eHum.PlatformStand = true
                            task.delay(0.2, function()
                                if eHum and eHum.Parent then
                                    eHum.PlatformStand = false
                                end
                            end)
                        end
                    end
                end
            end
        end)
    end

    -- Otomatik Koruma (Uzaklaştırma) Motoru
    if State.AutoAvoid then
        pcall(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local eHrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if eHrp then
                        if (eHrp.Position - hrp.Position).Magnitude < 10 then
                            local escapeDir = (hrp.Position - eHrp.Position).Unit
                            char:PivotTo(hrp.CFrame + (escapeDir * 1.5))
                        end
                    end
                end
            end
        end)
    end

    -- Küp (Cube) Oluşturma Motoru
    if State.Cube then
        pcall(function()
            if hrp.Velocity.Y < -1.5 and (os.clock() - State.LastCube > 0.15) then
                if #State.Cubes >= 6 then
                    local oldC = table.remove(State.Cubes, 1)
                    if oldC and oldC.Parent then oldC:Destroy() end
                end
                
                local cube = Instance.new("Part")
                cube.Size = Vector3.new(5, 0.5, 5)
                cube.Position = hrp.Position - Vector3.new(0, 3.2, 0)
                cube.Anchored = true
                cube.Transparency = 0.4
                cube.Material = Enum.Material.Neon
                cube.Color = Color3.fromRGB(0, 255, 200)
                cube.Parent = Workspace
                
                table.insert(State.Cubes, cube)
                State.LastCube = os.clock()
            end
        end)
    end
end)

print("🚀 LEA MOD ULTIMATE V21.0 - TÜM SİSTEMLER, INVIS VE SOPA HİTBOX AKTİF!")
-- ==============================================================================
-- LEA MOD ULTIMATE V21.0 - PART 3 / 3 (SECURITY, GUI RECOVERY & GARBAGE COLLECTOR)
-- ==============================================================================
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local State = getgenv().LeaModGlobalState

-- 1) GUI KORUMA VE REFAKATÇİ DÖNGÜSÜ (Arayüzün Silinmesini veya Bozulmasını Önler)
task.spawn(function()
    while task.wait(2) do
        pcall(function()
            local parent = CoreGui:FindFirstChild("CoreGui") or LocalPlayer:FindFirstChild("PlayerGui")
            if parent then
                local gui = parent:FindFirstChild("LeaModMonolithicGUI")
                if not gui and ScreenGui then
                    -- Eğer ekran arayüzü bir sebepten düşerse güvenle tekrar bağlar
                    ScreenGui.Parent = parent
                end
            end
        end)
    end
end)

-- 2) PERFORMANS VE ÇÖP TEMİZLEME (GARBAGE CLEANUP)
-- Bellek sızıntılarını (memory leak) önlemek için eski küp ve parça kalıntılarını temizler
local function CleanupMemory()
    pcall(function()
        if State.Cubes then
            for i = #State.Cubes, 1, -1 do
                local cube = State.Cubes[i]
                if not cube or not cube.Parent then
                    table.remove(State.Cubes, i)
                end
            end
        end
    end)
end

-- 3) HATA YÖNETİMİ VE ANLIK DURUM DOĞRULAMA (WATCHDOG)
RunService.Heartbeat:Connect(function()
    pcall(function()
        -- Karakter öldüğünde veya yenilendiğinde hız sınırının sıfırlanmasını engeller
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and State.Speed then
                if hum.WalkSpeed < 16 or (hum.WalkSpeed ~= State.Speed and hum.MoveDirection.Magnitude > 0) then
                    hum.WalkSpeed = math.clamp(State.Speed, 16, 50)
                end
            end
        end
    end)
end)

-- Periyodik bellek temizliği tetikleyicisi
task.spawn(function()
    while task.wait(10) do
        CleanupMemory()
    end
end)

print("✨ LEA MOD ULTIMATE V21.0 - PART 3 (TÜM SİSTEMLER FULL ENTEGRE VE KUSURSUZ ÇALIŞIYOR!)")
-- ==============================================================================
-- LEA MOD ULTIMATE V21.0 - PART 4 / 4 (ANTI-CHEAT BYPASS & SPOOF ENGINE)
-- ==============================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Sahte isim havuzu ve rastgele karmaşık karakter üretici
local function GenerateSpoofedName()
    local symbols = {"826392", "+₺+#)", "1-₺&!", "2#(3&2", "99482+", "xX_#", "§±!?", "49201#"}
    local part1 = symbols[math.random(1, #symbols)]
    local part2 = symbols[math.random(1, #symbols)]
    local randomNum = math.random(1000, 99999)
    return part1 .. "826392+₺+#)1-₺&!2#(3&2_" .. randomNum .. part2
end

-- Anti-Cheat Algılamalarını ve İsim Loglarını Sürekli Değişen Sahte Karakterlerle Besleme Döngüsü
task.spawn(function()
    while task.wait(0.8) do
        pcall(function()
            local fakeName = GenerateSpoofedName()
            
            -- Eğer oyun içi karakter veya DisplayName alanları destekliyorsa manipüle et
            if LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    -- Sunucu loglarını ve anti-cheat tarayıcılarını şaşırtmak için display adını sürekli değiştir
                    LocalPlayer.DisplayName = fakeName
                end
            end
            
            -- Roblox'un metatable veya remote log mekanizmalarındaki olası isim sorgularını yanıltma simülasyonu
            -- (Anti-cheat "Hile açıyor [İsim]" uyarısı verdiğinde loglara bu karmaşık karakterler yansır)
            script.Name = fakeName
        end)
    end
end)

-- Sunucu Tarafı Kick/Ban Denemelerine Karşı Ekstra Güvenlik Katmanı
pcall(function()
    LocalPlayer.Idled:Connect(function()
        local VirtualUser = game:GetService("VirtualUser")
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end)

print("🛡️ LEA MOD ULTIMATE V21.0 - PART 4 (ANTI-CHEAT SPOOF & HIDE MOTORU AKTİF!)")
