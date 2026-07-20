-- ==============================================================================
-- LEA MOD V17 - PART 1 / 3 (CORE, STATE & ADVANCED BYPASS)
-- ==============================================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

-- Global State (Parçaların haberleşmesi için)
getgenv().Lea = {
    State = {
        Mode = "NONE", Speed = 24, SpawnPos = nil, Cube = false, 
        Cubes = {}, LastCube = 0, Noclip = false, PotatoGraphics = false, 
        AutoAvoid = true, Visuals = false
    },
    Drawings = {},
    UIButtons = {}
}

-- GELİŞMİŞ BYPASS SİSTEMİ
local success, err = pcall(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        
        if method == "Kick" or method == "kick" then
            return -- Kick fonksiyonunu tamamen yoksay
        end
        
        if method == "FireServer" or method == "InvokeServer" then
            local name = string.lower(self.Name)
            if string.find(name, "kick") or string.find(name, "ban") or 
               string.find(name, "log") or string.find(name, "report") or 
               string.find(name, "anticheat") then
                return -- Zararlı remoteları engelle
            end
        end
        return oldNamecall(self, ...)
    end)
end)

-- Potato Graphics & Fullbright Logic
getgenv().Lea.TogglePotato = function(state)
    pcall(function()
        for _, desc in ipairs(Workspace:GetDescendants()) do
            if desc:IsA("BasePart") then
                if state then
                    desc.Material = Enum.Material.SmoothPlastic
                    desc.Reflectance = 0
                end
            elseif desc:IsA("ParticleEmitter") or desc:IsA("Trail") then
                desc.Enabled = not state
            end
        end
        if state then
            Lighting.GlobalShadows = false
            for _, eff in ipairs(Lighting:GetChildren()) do
                if eff:IsA("PostEffect") then eff.Enabled = false end
            end
        end
    end)
end

pcall(function()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
end)

print("⭐ LEA MOD - PART 1 LOADED (BYPASS ACTIVE)")
-- ==============================================================================
-- LEA MOD V17 - PART 2 / 3 (MODERN UI SYSTEM)
-- ==============================================================================
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function GetGuiParent()
    local success, parent = pcall(function() return CoreGui:FindFirstChild("CoreGui") or CoreGui end)
    return (success and parent) or LocalPlayer:WaitForChild("PlayerGui", 5)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LeaModModernGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = GetGuiParent()

local IntroFrame = Instance.new("Frame", ScreenGui)
IntroFrame.Size, IntroFrame.Position = UDim2.new(0, 320, 0, 180), UDim2.new(0.5, -160, 0.5, -90)
IntroFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
Instance.new("UICorner", IntroFrame).CornerRadius = UDim.new(0, 12)
local IntroStroke = Instance.new("UIStroke", IntroFrame)
IntroStroke.Color, IntroStroke.Thickness = Color3.fromRGB(0, 255, 200), 2

local IntroTitle = Instance.new("TextLabel", IntroFrame)
IntroTitle.Size, IntroTitle.Position = UDim2.new(1, 0, 0, 50), UDim2.new(0, 0, 0, 25)
IntroTitle.BackgroundTransparency, IntroTitle.Text = 1, "LEA MOD"
IntroTitle.TextColor3, IntroTitle.TextSize, IntroTitle.Font = Color3.fromRGB(0, 255, 200), 26, Enum.Font.GothamBold

local LoadBg = Instance.new("Frame", IntroFrame)
LoadBg.Size, LoadBg.Position, LoadBg.BackgroundColor3 = UDim2.new(0, 260, 0, 10), UDim2.new(0.5, -130, 0, 100), Color3.fromRGB(30, 30, 45)
Instance.new("UICorner", LoadBg).CornerRadius = UDim.new(1, 0)
local LoadFill = Instance.new("Frame", LoadBg)
LoadFill.Size, LoadFill.BackgroundColor3 = UDim2.new(0, 0, 1, 0), Color3.fromRGB(0, 255, 200)
Instance.new("UICorner", LoadFill).CornerRadius = UDim.new(1, 0)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size, MainFrame.Position = UDim2.new(0, 160, 0, 320), UDim2.new(1, -175, 0.5, -160)
MainFrame.BackgroundColor3, MainFrame.BackgroundTransparency, MainFrame.Visible, MainFrame.Draggable = Color3.fromRGB(18, 18, 25), 0.2, false, true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(0, 255, 200)

local HeaderTitle = Instance.new("TextLabel", MainFrame)
HeaderTitle.Size, HeaderTitle.Position, HeaderTitle.BackgroundTransparency = UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 5), 1
HeaderTitle.Text, HeaderTitle.TextColor3, HeaderTitle.Font = "LEA MOD", Color3.fromRGB(0, 255, 200), Enum.Font.GothamBold

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size, ToggleBtn.Position = UDim2.new(0, 45, 0, 30), UDim2.new(1, -55, 0, 15)
ToggleBtn.BackgroundColor3, ToggleBtn.Text, ToggleBtn.Visible = Color3.fromRGB(0, 255, 200), "LEA", false
ToggleBtn.TextColor3, ToggleBtn.Font = Color3.fromRGB(20, 20, 30), Enum.Font.GothamBold
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local function mkBtn(y, txt, cb)
    local b = Instance.new("TextButton", MainFrame)
    b.Size, b.Position, b.BackgroundColor3 = UDim2.new(1, -12, 0, 28), UDim2.new(0, 6, 0, y), Color3.fromRGB(45, 45, 60)
    b.Text, b.TextColor3, b.Font = txt, Color3.new(1,1,1), Enum.Font.GothamBold
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(cb)
    return b
end

getgenv().Lea.UIButtons.Target = mkBtn(40, "🎯 TAKİP OFF", function()
    local s = getgenv().Lea.State
    s.Mode = (s.Mode == "TARGET" and "NONE" or "TARGET")
    getgenv().Lea.UIButtons.Target.Text = (s.Mode == "TARGET") and "🎯 TAKİP ON" or "🎯 TAKİP OFF"
    getgenv().Lea.UIButtons.Target.BackgroundColor3 = (s.Mode == "TARGET") and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(45, 45, 60)
end)

getgenv().Lea.UIButtons.Base = mkBtn(74, "🏠 BASE OFF", function()
    local s = getgenv().Lea.State
    s.Mode = (s.Mode == "BASE" and "NONE" or "BASE")
    if s.Mode == "BASE" and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
    end
    getgenv().Lea.UIButtons.Base.Text = (s.Mode == "BASE") and "🏠 BASE ON" or "🏠 BASE OFF"
    getgenv().Lea.UIButtons.Base.BackgroundColor3 = (s.Mode == "BASE") and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(45, 45, 60)
end)

getgenv().Lea.UIButtons.Cube = mkBtn(108, "🧊 CUBE OFF", function()
    local s = getgenv().Lea.State
    s.Cube = not s.Cube
    getgenv().Lea.UIButtons.Cube.Text = s.Cube and "🧊 CUBE ON" or "🧊 CUBE OFF"
    getgenv().Lea.UIButtons.Cube.BackgroundColor3 = s.Cube and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(45, 45, 60)
end)

getgenv().Lea.UIButtons.Noclip = mkBtn(142, "👻 NOCLIP OFF", function()
    local s = getgenv().Lea.State
    s.Noclip = not s.Noclip
    getgenv().Lea.UIButtons.Noclip.Text = s.Noclip and "👻 NOCLIP ON" or "👻 NOCLIP OFF"
    getgenv().Lea.UIButtons.Noclip.BackgroundColor3 = s.Noclip and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(45, 45, 60)
end)

getgenv().Lea.UIButtons.Potato = mkBtn(176, "🥔 POTATO OFF", function()
    local s = getgenv().Lea.State
    s.PotatoGraphics = not s.PotatoGraphics
    getgenv().Lea.TogglePotato(s.PotatoGraphics)
    getgenv().Lea.UIButtons.Potato.Text = s.PotatoGraphics and "🥔 POTATO ON" or "🥔 POTATO OFF"
    getgenv().Lea.UIButtons.Potato.BackgroundColor3 = s.PotatoGraphics and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(45, 45, 60)
end)

getgenv().Lea.UIButtons.Visuals = mkBtn(210, "👁️ GÖRÜŞ OFF", function()
    local s = getgenv().Lea.State
    s.Visuals = not s.Visuals
    getgenv().Lea.UIButtons.Visuals.Text = s.Visuals and "👁️ GÖRÜŞ ON" or "👁️ GÖRÜŞ OFF"
    getgenv().Lea.UIButtons.Visuals.BackgroundColor3 = s.Visuals and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(45, 45, 60)
end)

getgenv().Lea.UIButtons.AutoAvoid = mkBtn(244, "🛡️ KORUMA ON", function()
    local s = getgenv().Lea.State
    s.AutoAvoid = not s.AutoAvoid
    getgenv().Lea.UIButtons.AutoAvoid.Text = s.AutoAvoid and "🛡️ KORUMA ON" or "🛡️ KORUMA OFF"
    getgenv().Lea.UIButtons.AutoAvoid.BackgroundColor3 = s.AutoAvoid and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(45, 45, 60)
end)
getgenv().Lea.UIButtons.AutoAvoid.BackgroundColor3 = Color3.fromRGB(0, 200, 80)

mkBtn(278, "🔄 RESET", function()
    pcall(function() LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health = 0 end)
end)

task.spawn(function()
    for i = 1, 100 do LoadFill.Size = UDim2.new(i/100, 0, 1, 0); task.wait(0.01) end
    pcall(function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local r = game.Workspace:Raycast(hrp.Position, Vector3.new(0, -500, 0))
            if r then hrp.CFrame = CFrame.new(r.Position + Vector3.new(0, 3, 0)); hrp.AssemblyLinearVelocity = Vector3.zero end
        end
    end)
    IntroFrame:Destroy()
    MainFrame.Visible, ToggleBtn.Visible = true, true
end)
print("⭐ LEA MOD - PART 2 LOADED (UI)")
-- ==============================================================================
-- LEA MOD - PART 3 / 3 (GELİŞMİŞ SALDIRI, KİLLAURA VE HİTBOX SİSTEMİ)
-- ==============================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local CombatState = {
    KillAura = false,
    HitboxExpander = false,
    AuraRange = 15,
    AttackDelay = 0.2, -- Saniyede 5 vuruş (Spam engelleyici)
    LastAttack = 0
}

-- Aktif Silahı/Eşyayı Bulma Fonksiyonu
local function GetEquippedWeapon()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            return tool
        end
    end
    return nil
end

-- Optimize Edilmiş Saldırı Döngüsü (Sadece karakter hayattayken çalışır)
RunService.Heartbeat:Connect(function(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local now = os.clock()

    -- 1) KILLAURA (Otomatik Yakın Mesafe Saldırısı)
    if CombatState.KillAura and (now - CombatState.LastAttack) >= CombatState.AttackDelay then
        local weapon = GetEquippedWeapon()
        if weapon then
            local targetFound = false
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local eHrp = p.Character:FindFirstChild("HumanoidRootPart")
                    local eHum = p.Character:FindFirstChildOfClass("Humanoid")
                    
                    if eHrp and eHum and eHum.Health > 0 then
                        local dist = (eHrp.Position - hrp.Position).Magnitude
                        if dist <= CombatState.AuraRange then
                            targetFound = true
                            break -- Hedef bulundu, döngüyü kır ve saldırıya geç
                        end
                    end
                end
            end

            -- Eğer yakında düşman varsa aralıklı olarak vur (Spam yapıp sunucuyu yormaz)
            if targetFound then
                pcall(function()
                    weapon:Activate()
                end)
                CombatState.LastAttack = now
            end
        end
    end

    -- 2) HITBOX BÜYÜTME SİSTEMİ (Telefonlar için optimize)
    if CombatState.HitboxExpander then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local eHrp = p.Character:FindFirstChild("HumanoidRootPart")
                local eHum = p.Character:FindFirstChildOfClass("Humanoid")
                
                if eHrp and eHum and eHum.Health > 0 then
                    -- Hitbox sadece 100 stud içindeki oyuncular için büyütülür (FPS dostu)
                    local dist = (eHrp.Position - hrp.Position).Magnitude
                    if dist <= 100 then
                        eHrp.Size = Vector3.new(10, 10, 10)
                        eHrp.Transparency = 0.6
                        eHrp.CanCollide = false
                    else
                        -- Uzaklaşan oyuncunun hitbox'ını normale döndür
                        eHrp.Size = Vector3.new(2, 2, 1)
                        eHrp.Transparency = 1
                    end
                end
            end
        end
    end
end)

-- ==============================================================================
-- PART 3 UI ENTEGRASYONU (Menüye Saldırı Butonlarını Ekleme)
-- ==============================================================================
-- Not: Bu kısmı mevcut menünün UIButtons oluşturma alanına ekleyebilirsin.

-- Örnek Buton Eklemeleri:
--[[
UIButtons.KillAura = CreateButton(312, "⚔️ AURA OFF", function()
    CombatState.KillAura = not CombatState.KillAura
    UIButtons.KillAura.Text = CombatState.KillAura and "⚔️ AURA ON" or "⚔️ AURA OFF"
    UIButtons.KillAura.BackgroundColor3 = CombatState.KillAura and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(45, 45, 60)
end)

UIButtons.Hitbox = CreateButton(346, "🎯 HITBOX OFF", function()
    CombatState.HitboxExpander = not CombatState.HitboxExpander
    if not CombatState.HitboxExpander then
        -- Kapatıldığında tüm hitboxları sıfırla
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                p.Character.HumanoidRootPart.Transparency = 1
            end
        end
    end
    UIButtons.Hitbox.Text = CombatState.HitboxExpander and "🎯 HITBOX ON" or "🎯 HITBOX OFF"
    UIButtons.Hitbox.BackgroundColor3 = CombatState.HitboxExpander and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(45, 45, 60)
end)
]]

print("⭐ LEA MOD - PART 3 (GELİŞMİŞ SALDIRI SİSTEMİ) YÜKLENDİ!")
