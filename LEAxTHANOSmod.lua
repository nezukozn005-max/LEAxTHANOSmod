-- ============================================
-- LEA MOD V5.8 MOBILE - PART 1/4: GÜVENLİK & YENİ FLY/CUBE TEMELLERİ
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

print("⚡ LEA V5.8 MOBILE - Part 1/4: Güvenlik & Fly/Cube")

getgenv().LeaSecure = {
    AntiKick = true,
    AntiReset = true,
    AntiVoid = true,
    Mode = nil,
    Logs = {}
}

local SEC = getgenv().LeaSecure

-- ============================================
-- GELİŞMİŞ ANTİ-KİCK BYPASS
-- ============================================
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if SEC.AntiKick and not checkcaller() then
        -- Direkt metod engeli
        if method == "Kick" or method == "kick" or method == "Destroy" or method == "Remove" then
            if self == LocalPlayer or self:IsA("Player") then
                return nil
            end
        end
        
        -- RemoteEvent/RemoteFunction Kick/Ban taraması
        if (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) and method == "FireServer" then
            for _, v in ipairs(args) do
                if type(v) == "string" then
                    local l = v:lower()
                    if l:find("kick") or l:find("ban") or l:find("exploit") or l:find("cheat") then
                        return nil
                    end
                end
            end
        end
    end
    return oldNamecall(self, ...)
end)

-- ============================================
-- ANTİ-RESET (ÖLÜM KORUMASI)
-- ============================================
local function AntiReset(char)
    if not SEC.AntiReset then return end
    pcall(function()
        local hum = char:FindFirstChild("Humanoid")
        if not hum then return end
        
        hum.BreakJointsOnDeath = false
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        
        hum.HealthChanged:Connect(function(hp)
            if hp <= 0 and SEC.AntiReset then
                hum.Health = hum.MaxHealth
            end
        end)
    end)
end

LocalPlayer.CharacterAdded:Connect(function(c)
    task.wait(0.3)
    AntiReset(c)
end)

if LocalPlayer.Character then
    AntiReset(LocalPlayer.Character)
end

-- ============================================
-- ANTİ-VOİD
-- ============================================
local lastSafe = Vector3.new(0, 10, 0)
RunService.Heartbeat:Connect(function()
    if not SEC.AntiVoid then return end
    pcall(function()
        local c = LocalPlayer.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        if hrp.Position.Y < -500 then
            hrp.CFrame = CFrame.new(lastSafe + Vector3.new(0, 10, 0))
        else
            lastSafe = hrp.Position
        end
    end)
end)

-- ============================================
-- BAŞLANGIÇ SEÇİCİ (MOBİL KÜÇÜK)
-- ============================================
local function CreateSelector(callback)
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "LeaStart"
    gui.Parent = pg
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.new(0, 0, 0)
    bg.Parent = gui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 200, 0, 30)
    title.Position = UDim2.new(0.5, -100, 0.35, 0)
    title.BackgroundTransparency = 1
    title.Text = "LEA V5.8"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = bg
    
    local btns = Instance.new("Frame")
    btns.Size = UDim2.new(0, 180, 0, 40)
    btns.Position = UDim2.new(0.5, -90, 0.5, 0)
    btns.BackgroundTransparency = 1
    btns.Parent = bg
    
    local function Btn(text, mode, posX)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 80, 0, 36)
        b.Position = UDim2.new(0, posX, 0, 2)
        b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        b.Text = text
        b.TextColor3 = Color3.new(1, 1, 1)
        b.TextSize = 14
        b.Font = Enum.Font.GothamBold
        b.Parent = btns
        
        b.MouseButton1Click:Connect(function()
            SEC.Mode = mode
            gui:Destroy()
            callback(mode)
        end)
    end
    
    Btn("PET", "PET", 0)
    Btn("DUEL", "DUEL", 100)
end

-- ============================================
-- YENİ FLY & CUBE DEĞİŞKENLERİ VE FONKSİYONLARI
-- ============================================
getgenv().LeaEngine = {
    FlyActive = false,
    CubeActive = false,
    TrackActive = false,
    BatActive = false,
    LeftActive = false,
    RightActive = false,
    XRayActive = false,
    
    FlySpeed = 35,
    BasePos = Vector3.new(0, 10, 0),
    
    -- Cube yardımcıları
    Cubes = {},
    LastCubeTime = 0
}

local ENG = getgenv().LeaEngine

-- Base kaydet
task.spawn(function()
    task.wait(2)
    local c = LocalPlayer.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    if hrp then ENG.BasePos = hrp.Position end
end)

-- Fly durdurma
function StopFly()
    ENG.FlyActive = false
    local c = LocalPlayer.Character
    if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if hum then hum.PlatformStand = false end
    if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
end

-- Cube temizleme
local function ClearCubes()
    for _, v in ipairs(ENG.Cubes) do
        if v and v.Parent then v:Destroy() end
    end
    ENG.Cubes = {}
end

local function CreateCube(pos)
    if #ENG.Cubes > 15 then
        local old = table.remove(ENG.Cubes, 1)
        if old and old.Parent then old:Destroy() end
    end
    local cube = Instance.new("Part")
    cube.Size = Vector3.new(4, 0.5, 4)
    cube.Position = pos
    cube.Anchored = true
    cube.CanCollide = true
    cube.Transparency = 0.8
    cube.Material = Enum.Material.SmoothPlastic
    cube.Color = Color3.fromRGB(0, 170, 255)
    cube.Parent = workspace
    table.insert(ENG.Cubes, cube)
end

local function UpdateCube()
    if not ENG.CubeActive then return end
    local c = LocalPlayer.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    local now = tick()
    local vel = hrp.AssemblyLinearVelocity
    
    if vel.Y < -5 and (now - ENG.LastCubeTime > 0.3) then
        CreateCube(hrp.Position - Vector3.new(0, 3, 0))
        ENG.LastCubeTime = now
    end
    if vel.Magnitude > 2 and (now - ENG.LastCubeTime > 0.3) then
        local dir = hrp.CFrame.LookVector
        CreateCube(hrp.Position + Vector3.new(dir.X * 3, -2.5, dir.Z * 3))
        ENG.LastCubeTime = now
    end
end

print("✅ Part 1/4 tamam")-- ============================================
-- LEA MOD V5.8 MOBILE - PART 2/4: HAREKET SİSTEMLERİ
-- ============================================
print("⚡ Part 2/4: Hareket motoru")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ENG = getgenv().LeaEngine

-- ============================================
-- YARDIMCI: HEDEF BULMA
-- ============================================
local function GetTarget(dist)
    dist = dist or 50
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local closest, short = nil, dist
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local t = p.Character:FindFirstChild("HumanoidRootPart")
            if t then
                local d = (hrp.Position - t.Position).Magnitude
                if d < short then
                    short = d
                    closest = p
                end
            end
        end
    end
    return closest
end

-- ============================================
-- FLY GÜNCELLEME (HER KAREDE)
-- ============================================
local function UpdateFly()
    if not ENG.FlyActive then return end
    local c = LocalPlayer.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    hum.PlatformStand = true
    local moveDir = hum.MoveDirection
    if moveDir.Magnitude > 0 then
        local camCFrame = Camera.CFrame
        local targetDir = (camCFrame.RightVector * moveDir.X) + (camCFrame.LookVector * -moveDir.Z)
        if targetDir.Magnitude > 0 then
            hrp.AssemblyLinearVelocity = targetDir.Unit * ENG.FlySpeed
        end
    else
        hrp.AssemblyLinearVelocity = Vector3.zero
    end
end

-- ============================================
-- BASE DÖNÜŞ (FLY TABANLI)
-- ============================================
local function BaseReturn(mode)
    local c = LocalPlayer.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local targetPos = ENG.BasePos + Vector3.new(0, 3, 0)
    local speed = (mode == "PET") and 18 or 24

    -- Geçici olarak fly mantığını kullan
    local flyWasActive = ENG.FlyActive
    ENG.FlyActive = true
    local oldFlySpeed = ENG.FlySpeed
    ENG.FlySpeed = speed

    hum.PlatformStand = true

    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not c or not hrp or not hum then
            conn:Disconnect()
            return
        end

        local dir = (targetPos - hrp.Position)
        if dir.Magnitude < 1 then
            -- Hedefe ulaştık
            hrp.AssemblyLinearVelocity = Vector3.zero
            conn:Disconnect()
            hum.PlatformStand = false
            ENG.FlyActive = flyWasActive
            ENG.FlySpeed = oldFlySpeed
            return
        end

        -- Fly benzeri hız uygula (sabit hızla hedefe yönel)
        local vel = dir.Unit * speed
        hrp.AssemblyLinearVelocity = vel
    end)
end

-- ============================================
-- TP DOWN (RAYCAST)
-- ============================================
local function TPDown()
    local c = LocalPlayer.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local ray = Workspace:Raycast(hrp.Position, Vector3.new(0, -700, 0))
    if ray then
        hrp.CFrame = CFrame.new(ray.Position + Vector3.new(0, 3, 0))
    end
end

-- ============================================
-- X-RAY
-- ============================================
local xrayCache = {}
local function ToggleXRay(state)
    ENG.XRayActive = state
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) then
            if state then
                if obj.Transparency < 0.3 then
                    xrayCache[obj] = obj.Transparency
                    obj.Transparency = 0.5
                end
            else
                if xrayCache[obj] then
                    obj.Transparency = xrayCache[obj]
                end
            end
        end
    end
    if not state then xrayCache = {} end
end

-- ============================================
-- ANA HAREKET DÖNGÜSÜ
-- ============================================
RunService.Heartbeat:Connect(function(dt)
    local c = LocalPlayer.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end

    -- Fly (serbest uçuş)
    UpdateFly()

    -- Cube (platform oluşturma)
    UpdateCube()

    -- Sol/Sağ strafe
    if ENG.LeftActive then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(3.5), 0) + (-hrp.CFrame.RightVector * 30 * dt)
    end
    if ENG.RightActive then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(-3.5), 0) + (hrp.CFrame.RightVector * 30 * dt)
    end

    -- Takip (hedefe fly ile yaklaş)
    if ENG.TrackActive then
        local t = GetTarget(50)
        if t and t.Character then
            local th = t.Character:FindFirstChild("HumanoidRootPart")
            if th then
                local targetPos = th.Position + Vector3.new(0, 1, 0)
                local dir = targetPos - hrp.Position
                if dir.Magnitude > 2 then
                    hrp.AssemblyLinearVelocity = dir.Unit * ENG.FlySpeed
                else
                    hrp.AssemblyLinearVelocity = Vector3.zero
                end
                hum.PlatformStand = true
                -- Otomatik saldırı
                local tool = c:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                if tool then
                    if tool.Parent ~= c then hum:EquipTool(tool) end
                    pcall(function() tool:Activate() end)
                end
            end
        else
            if not ENG.FlyActive then
                hum.PlatformStand = false
            end
        end
    end

    -- Auto Bat (yakın hedefe uç + vur)
    if ENG.BatActive then
        local t = GetTarget(25)
        if t and t.Character then
            local th = t.Character:FindFirstChild("HumanoidRootPart")
            if th then
                local targetPos = th.Position + Vector3.new(0, 1.2, 0)
                local dir = targetPos - hrp.Position
                hrp.AssemblyLinearVelocity = dir.Unit * ENG.FlySpeed
                hum.PlatformStand = true
                local tool = c:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                if tool then
                    if tool.Parent ~= c then hum:EquipTool(tool) end
                    pcall(function() tool:Activate() end)
                end
            end
        else
            if not ENG.FlyActive then
                hum.PlatformStand = false
            end
        end
    end

    -- Eğer hiçbir uçuş modu aktif değilse PlatformStand'i kapat
    if not ENG.FlyActive and not ENG.TrackActive and not ENG.BatActive then
        if hum.PlatformStand then hum.PlatformStand = false end
        hrp.AssemblyLinearVelocity = Vector3.zero
    end
end)

print("✅ Part 2/4 tamam")-- ============================================
-- LEA MOD V5.8 MOBILE - PART 3/4: MOBİL YAN MENÜ (DAHA FAZLA BUTON)
-- ============================================
print("⚡ Part 3/4: Mobil UI")

local function BuildUI(mode)
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    local old = pg:FindFirstChild("LeaUI")
    if old then old:Destroy() end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "LeaUI"
    gui.Parent = pg
    
    -- SAĞ TARAFTA DİKEY KONTEYNER (biraz daha uzun, tüm butonlar sığsın)
    local cont = Instance.new("Frame")
    cont.Size = UDim2.new(0, 55, 0, 340)  -- 340px yeterli
    cont.Position = UDim2.new(1, -62, 0.3, 0)
    cont.BackgroundTransparency = 1
    cont.Active = true
    cont.Draggable = true
    cont.Parent = gui
    
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 4)
    list.Parent = cont
    
    -- MİNİ BUTON
    local function Btn(text, toggle, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 50, 0, 26)
        b.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Text = text
        b.TextSize = 7
        b.Font = Enum.Font.GothamBold
        b.Parent = cont
        
        if toggle then
            local state = false
            b.MouseButton1Click:Connect(function()
                state = not state
                b.BackgroundColor3 = state and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(20, 20, 25)
                callback(state)
            end)
        else
            b.MouseButton1Click:Connect(function()
                b.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
                task.delay(0.15, function() b.BackgroundColor3 = Color3.fromRGB(20, 20, 25) end)
                callback()
            end)
        end
    end
    
    -- Tüm butonlar (moda göre)
    if mode == "PET" then
        Btn("FLY", true, function(v) ENG.FlyActive = v end)
        Btn("CUBE", true, function(v) ENG.CubeActive = v end)
        Btn("BASE", false, function() BaseReturn("PET") end)
        Btn("TRACK", true, function(v) ENG.TrackActive = v end)
        Btn("BAT", true, function(v) ENG.BatActive = v end)
        Btn("DOWN", false, TPDown)
        Btn("XRAY", true, function(v) ToggleXRay(v) end)
    else
        Btn("FLY", true, function(v) ENG.FlyActive = v end)
        Btn("CUBE", true, function(v) ENG.CubeActive = v end)
        Btn("BASE", false, function() BaseReturn("DUEL") end)
        Btn("TRACK", true, function(v) ENG.TrackActive = v end)
        Btn("BAT", true, function(v) ENG.BatActive = v end)
        Btn("LEFT", true, function(v) ENG.LeftActive = v end)
        Btn("RIGHT", true, function(v) ENG.RightActive = v end)
        Btn("DOWN", false, TPDown)
        Btn("XRAY", true, function(v) ToggleXRay(v) end)
    end
end

print("✅ Part 3/4 tamam")-- ============================================
-- LEA MOD V5.8 MOBILE - PART 4/4: BAŞLATICI
-- ============================================
print("⚡ Part 4/4: Başlatıcı")

CreateSelector(function(mode)
    BuildUI(mode)
    
    print("=========================")
    print("LEA V5.8 MOBILE AKTİF")
    print("Mod: " .. mode)
    print("Fly ile eğik karakter")
    print("Gelişmiş Anti-Kick")
    print("=========================")
end)

-- Acil durum temizliği
getgenv().LeaKill = function()
    StopFly()
    ClearCubes()
    ToggleXRay(false)
    for _, v in pairs(ENG) do
        if type(v) == "boolean" then ENG[v] = false end
    end
    local gui = LocalPlayer.PlayerGui:FindFirstChild("LeaUI")
    if gui then gui:Destroy() end
    print("LEA TEMİZLENDİ")
end

print([[
=======================
LEA V5.8 MOBILE HAZIR
- Fly ile eğik hareket
- Cube platform desteği
- Gelişmiş Anti‑Kick
- Leakill() ile kapat
=======================
]])
