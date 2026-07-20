-- ==============================================================================
-- LEA MOD - STABLE & FIXED ENGINE (TÜM HATALAR GİDERİLDİ)
-- ==============================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. GLOBAL STATE (DURUM KONTROLÜ)
-- ==========================================
local State = {
    Mode = "NONE",
    Speed = 24,
    SpawnPos = nil,
    Cube = false,
    Cubes = {},
    LastCube = 0,
    Noclip = false,
    PotatoGraphics = false,
    AutoAvoid = false, -- Çakışma yapmaması için başlangıçta kapalı
    Visuals = false,
    KillAura = false
}

-- ==========================================
-- 2. GÜVENLİ GUI OLUŞTURMA
-- ==========================================
local function GetGuiParent()
    local success, parent = pcall(function() return CoreGui end)
    if success and parent then return parent end
    return LocalPlayer:WaitForChild("PlayerGui", 5)
end

-- ==========================================
-- 3. BYPASS VE OPTİMİZASYONLAR
-- ==========================================
pcall(function()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local old = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" and tostring(self):find("AntiCheat") then return end
        return old(self, ...)
    end)
    setreadonly(mt, true)
end)

pcall(function()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
end)

local function TogglePotatoGraphics(state)
    pcall(function()
        for _, descendant in ipairs(Workspace:GetDescendants()) do
            if descendant:IsA("BasePart") then
                if state then
                    descendant.Material = Enum.Material.SmoothPlastic
                    descendant.Reflectance = 0
                end
            elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") then
                descendant.Enabled = not state
            end
        end
    end)
end

-- Doğma noktasını kesin olarak kaydetme
local function SaveSpawnPos(char)
    State.Mode = "NONE"
    task.spawn(function()
        local hrp = char:WaitForChild("HumanoidRootPart", 10)
        if hrp then 
            State.SpawnPos = hrp.Position + Vector3.new(0, 3, 0) 
        end
    end)
end

if LocalPlayer.Character then SaveSpawnPos(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(SaveSpawnPos)

-- ==========================================
-- 4. MODERN MENÜ TASARIMI
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LeaModModernGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = GetGuiParent()

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 160, 0, 360)
MainFrame.Position = UDim2.new(1, -175, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 255, 200)
MainStroke.Thickness = 1.5

local HeaderTitle = Instance.new("TextLabel", MainFrame)
HeaderTitle.Size = UDim2.new(1, 0, 0, 30)
HeaderTitle.Position = UDim2.new(0, 0, 0, 5)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "LEA MOD"
HeaderTitle.TextColor3 = Color3.fromRGB(0, 255, 200)
HeaderTitle.TextSize = 15
HeaderTitle.Font = Enum.Font.GothamBold

local ToggleMenuBtn = Instance.new("TextButton", ScreenGui)
ToggleMenuBtn.Size = UDim2.new(0, 45, 0, 30)
ToggleMenuBtn.Position = UDim2.new(1, -55, 0, 15)
ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
ToggleMenuBtn.Text = "LEA"
ToggleMenuBtn.TextColor3 = Color3.fromRGB(20, 20, 30)
ToggleMenuBtn.TextSize = 12
ToggleMenuBtn.Font = Enum.Font.GothamBold
local ToggleCorner = Instance.new("UICorner", ToggleMenuBtn)
ToggleCorner.CornerRadius = UDim.new(0, 6)

ToggleMenuBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Buton Oluşturucu
local UIButtons = {}
local function CreateButton(posY, text, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(1, -12, 0, 28)
    btn.Position = UDim2.new(0, 6, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Butonları Ekleme
UIButtons.Target = CreateButton(40, "🎯 TAKİP OFF", function()
    State.Mode = (State.Mode == "TARGET" and "NONE" or "TARGET")
    UIButtons.Target.Text = (State.Mode == "TARGET") and "🎯 TAKİP ON" or "🎯 TAKİP OFF"
    UIButtons.Target.BackgroundColor3 = (State.Mode == "TARGET") and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(45, 45, 60)
end)

UIButtons.Base = CreateButton(74, "🏠 BASE OFF", function()
    State.Mode = (State.Mode == "BASE" and "NONE" or "BASE")
    UIButtons.Base.Text = (State.Mode == "BASE") and "🏠 BASE ON" or "🏠 BASE OFF"
    UIButtons.Base.BackgroundColor3 = (State.Mode == "BASE") and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(45, 45, 60)
end)

UIButtons.Cube = CreateButton(108, "🧊 CUBE OFF", function()
    State.Cube = not State.Cube
    UIButtons.Cube.Text = State.Cube and "🧊 CUBE ON" or "🧊 CUBE OFF"
    UIButtons.Cube.BackgroundColor3 = State.Cube and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(45, 45, 60)
end)

UIButtons.Noclip = CreateButton(142, "👻 NOCLIP OFF", function()
    State.Noclip = not State.Noclip
    UIButtons.Noclip.Text = State.Noclip and "👻 NOCLIP ON" or "👻 NOCLIP OFF"
    UIButtons.Noclip.BackgroundColor3 = State.Noclip and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(45, 45, 60)
end)

UIButtons.Potato = CreateButton(176, "🥔 POTATO OFF", function()
    State.PotatoGraphics = not State.PotatoGraphics
    TogglePotatoGraphics(State.PotatoGraphics)
    UIButtons.Potato.Text = State.PotatoGraphics and "🥔 POTATO ON" or "🥔 POTATO OFF"
    UIButtons.Potato.BackgroundColor3 = State.PotatoGraphics and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(45, 45, 60)
end)

UIButtons.Visuals = CreateButton(210, "👁️ GÖRÜŞ OFF", function()
    State.Visuals = not State.Visuals
    UIButtons.Visuals.Text = State.Visuals and "👁️ GÖRÜŞ ON" or "👁️ GÖRÜŞ OFF"
    UIButtons.Visuals.BackgroundColor3 = State.Visuals and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(45, 45, 60)
end)

UIButtons.AutoAvoid = CreateButton(244, "🛡️ KORUMA OFF", function()
    State.AutoAvoid = not State.AutoAvoid
    UIButtons.AutoAvoid.Text = State.AutoAvoid and "🛡️ KORUMA ON" or "🛡️ KORUMA OFF"
    UIButtons.AutoAvoid.BackgroundColor3 = State.AutoAvoid and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(45, 45, 60)
end)

UIButtons.Aura = CreateButton(278, "⚔️ AURA OFF", function()
    State.KillAura = not State.KillAura
    UIButtons.Aura.Text = State.KillAura and "⚔️ AURA ON" or "⚔️ AURA OFF"
    UIButtons.Aura.BackgroundColor3 = State.KillAura and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(45, 45, 60)
end)

CreateButton(312, "🔄 RESET", function()
    pcall(function() LocalPlayer.Character.Humanoid.Health = 0 end)
end)

-- ==========================================
-- 5. %100 ÇALIŞAN ESP SİSTEMİ (HIGHLIGHT)
-- ==========================================
task.spawn(function()
    while task.wait(0.5) do
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hl = p.Character:FindFirstChild("LeaESP")
                if State.Visuals then
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "LeaESP"
                        hl.FillColor = Color3.fromRGB(0, 255, 200)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.6
                        hl.OutlineTransparency = 0.2
                        hl.Parent = p.Character
                    end
                else
                    if hl then hl:Destroy() end
                end
            end
        end
    end
end)

-- ==========================================
-- 6. FİZİK VE HAREKET MOTORU (KESİN ÇÖZÜM)
-- ==========================================

-- NOCLIP (Stepped içinde olmalı ki duvarlardan atmasın)
RunService.Stepped:Connect(function()
    if State.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- BASE, TAKİP, KÜP VE KAÇIŞ MOTORU (Heartbeat)
RunService.Heartbeat:Connect(function(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- A. HAREKET SİSTEMLERİ (BASE & TARGET)
    if State.Mode == "BASE" and State.SpawnPos then
        local dist = (State.SpawnPos - hrp.Position).Magnitude
        if dist > 2 then
            local dir = (State.SpawnPos - hrp.Position).Unit
            local moveStep = math.min(dist, State.Speed * dt * 3)
            char:PivotTo(hrp.CFrame + (dir * moveStep))
            hrp.Velocity = Vector3.zero
            hrp.AssemblyLinearVelocity = Vector3.zero
        else
            char:PivotTo(CFrame.new(State.SpawnPos))
            State.Mode = "NONE"
            UIButtons.Base.Text = "🏠 BASE OFF"
            UIButtons.Base.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        end

    elseif State.Mode == "TARGET" then
        local target, minDist = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local eHrp = p.Character:FindFirstChild("HumanoidRootPart")
                if eHrp and p.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                    local dist = (eHrp.Position - hrp.Position).Magnitude
                    if dist < minDist then minDist = dist; target = eHrp end
                end
            end
        end
        
        if target then
            local dist = (target.Position - hrp.Position).Magnitude
            if dist > 4 then
                local dir = (target.Position - hrp.Position).Unit
                local moveStep = math.min(dist, State.Speed * dt * 3)
                char:PivotTo(hrp.CFrame + (dir * moveStep))
                hrp.Velocity = Vector3.zero
            else
                char:PivotTo(CFrame.new(target.Position + Vector3.new(0, 3, 0)))
                hrp.Velocity = Vector3.zero
            end
        end
    end

    -- B. OTOMATİK KORUMA (Sadece Base ve Takip kapalıysa çalışır)
    if State.AutoAvoid and State.Mode == "NONE" then
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
    end

    -- C. KÜP (CUBE) SİSTEMİ
    if State.Cube then
        -- AssemblyLinearVelocity bazen hatalı okunduğundan direkt Velocity kullanıyoruz
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
    end
end)

print("⭐ LEA MOD - STABLE V17 BÜTÜN HATALAR GİDERİLEREK YÜKLENDİ!")
