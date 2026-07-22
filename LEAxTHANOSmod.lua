-- ==============================================================================
-- LEA MOD V5.7 MOBILE - PART 1/4: ÇEKİRDEK GÜVENLİK & ANTI-KORUMALAR
-- MOBİL İÇİN OPTİMİZE EDİLDİ | GEREKSİZ KOMUTLAR KALDIRILDI
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

print("⚡ LEA V5.7 MOBILE - Part 1/4: Güvenlik çekirdeği...")

getgenv().LeaSecure = {
    AntiKick = true,
    AntiReset = true,
    AntiVoid = true,
    Mode = nil,
    Logs = {}
}

local SEC = getgenv().LeaSecure

-- =============================================
-- ANTI-KICK (SADECE TEMEL KORUMA)
-- =============================================
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if SEC.AntiKick and not checkcaller() then
        if method == "Kick" or method == "kick" then
            return nil
        end
        if self == LocalPlayer and method == "Destroy" then
            return nil
        end
    end
    return oldNamecall(self, ...)
end)

-- =============================================
-- ANTI-RESET (ÖLÜM KORUMASI)
-- =============================================
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

-- =============================================
-- ANTI-VOID (BOŞLUĞA DÜŞME KORUMASI)
-- =============================================
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

-- =============================================
-- BAŞLANGIÇ SEÇİCİ (MOBİL KÜÇÜK)
-- =============================================
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
    title.Size = UDim2.new(0, 200, 0, 40)
    title.Position = UDim2.new(0.5, -100, 0.35, 0)
    title.BackgroundTransparency = 1
    title.Text = "LEA V5.7"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.Parent = bg
    
    local btns = Instance.new("Frame")
    btns.Size = UDim2.new(0, 220, 0, 50)
    btns.Position = UDim2.new(0.5, -110, 0.5, 0)
    btns.BackgroundTransparency = 1
    btns.Parent = bg
    
    local function Btn(text, mode)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 100, 0, 45)
        b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        b.Text = text
        b.TextColor3 = Color3.new(1, 1, 1)
        b.TextSize = 16
        b.Font = Enum.Font.GothamBold
        b.Parent = btns
        
        b.MouseButton1Click:Connect(function()
            SEC.Mode = mode
            gui:Destroy()
            callback(mode)
        end)
    end
    
    Btn("PET", "PET")
    btn2 = Instance.new("TextButton")
    btn2.Size = UDim2.new(0, 100, 0, 45)
    btn2.Position = UDim2.new(0, 120, 0, 2)
    btn2.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn2.Text = "DUEL"
    btn2.TextColor3 = Color3.new(1, 1, 1)
    btn2.TextSize = 16
    btn2.Font = Enum.Font.GothamBold
    btn2.Parent = btns
    
    btn2.MouseButton1Click:Connect(function()
        SEC.Mode = "DUEL"
        gui:Destroy()
        callback("DUEL")
    end)
end

print("✅ Part 1/4 tamam - Güvenlik aktif")-- ==============================================================================
-- LEA MOD V5.7 MOBILE - PART 2/4: FİZİK MOTORU & HAREKET SİSTEMLERİ
-- MOBİL İÇİN OPTİMİZE EDİLDİ
-- ==============================================================================

print("⚡ Part 2/4: Fizik motoru...")

getgenv().LeaEngine = {
    Carry = false,
    Cube = false,
    TP = false,
    Left = false,
    Right = false,
    Bat = false,
    Track = false,
    XRay = false,
    Speed = 30,
    Base = Vector3.new(0, 10, 0)
}

local ENG = getgenv().LeaEngine

-- Base kaydet
task.spawn(function()
    task.wait(2)
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        ENG.Base = c.HumanoidRootPart.Position
    end
end)

-- =============================================
-- GÖRÜNMEZ KÜP (SADECE YÜRÜRKEN)
-- =============================================
local lastCube = 0
local function SpawnCube()
    if tick() - lastCube < 0.35 then return end
    lastCube = tick()
    
    local c = LocalPlayer.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local cube = Instance.new("Part")
    cube.Size = Vector3.new(2.5, 2.5, 2.5)
    cube.Position = hrp.Position - Vector3.new(0, 2, 0)
    cube.Transparency = 1
    cube.Anchored = true
    cube.Parent = Workspace
    
    task.delay(4, function() cube:Destroy() end)
end

-- =============================================
-- BASE DÖNÜŞ
-- =============================================
local function BaseReturn(mode)
    local c = LocalPlayer.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local speed = mode == "PET" and 18 or 24
    local start = hrp.Position
    local finish = ENG.Base + Vector3.new(0, 3, 0)
    local dist = (finish - start).Magnitude
    local dur = dist / speed
    local t = 0
    
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = true end
    
    local conn
    conn = RunService.Heartbeat:Connect(function(dt)
        t = t + dt
        local a = math.clamp(t / dur, 0, 1)
        hrp.CFrame = CFrame.new(start:Lerp(finish, a))
        if a >= 1 then
            conn:Disconnect()
            if hum then hum.PlatformStand = false end
        end
    end)
end

-- =============================================
-- X-RAY
-- =============================================
local xrayCache = {}
local function ToggleXRay(state)
    ENG.XRay = state
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
end

-- =============================================
-- TP DOWN
-- =============================================
local function TPDown()
    local c = LocalPlayer.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local ray = Workspace:Raycast(hrp.Position, Vector3.new(0, -700, 0))
    if ray then
        hrp.CFrame = CFrame.new(ray.Position + Vector3.new(0, 3, 0))
    end
end

-- =============================================
-- HEDEF BULMA
-- =============================================
local function GetTarget(dist)
    dist = dist or 50
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local closest = nil
    local short = dist
    
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

-- =============================================
-- ANA HAREKET DÖNGÜSÜ
-- =============================================
RunService.Heartbeat:Connect(function(dt)
    local c = LocalPlayer.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if not (hrp and hum) then return end
    
    -- Carry Speed
    if ENG.Carry and hum.MoveDirection.Magnitude > 0 then
        hrp.CFrame = hrp.CFrame + (hum.MoveDirection * ENG.Speed * dt)
    end
    
    -- Cube Fly
    if ENG.Cube then
        local moving = hum.MoveDirection.Magnitude > 0
        local jumping = hum:GetState() == Enum.HumanoidStateType.Jumping
        if moving or jumping then
            SpawnCube()
            local cam = Camera.CFrame.LookVector
            hrp.CFrame = hrp.CFrame + (Vector3.new(cam.X, 0, cam.Z) * ENG.Speed * dt)
            hum.PlatformStand = true
        end
    end
    
    -- Strafe Left
    if ENG.Left then
        local lv = -hrp.CFrame.RightVector
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(3.5), 0) + (lv * ENG.Speed * dt)
    end
    
    -- Strafe Right
    if ENG.Right then
        local rv = hrp.CFrame.RightVector
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(-3.5), 0) + (rv * ENG.Speed * dt)
    end
    
    -- Takip
    if ENG.Track then
        local t = GetTarget()
        if t and t.Character then
            local th = t.Character:FindFirstChild("HumanoidRootPart")
            if th then
                hrp.CFrame = CFrame.new(hrp.Position:Lerp(th.Position + Vector3.new(0,1,0), 0.12), th.Position)
                local tool = c:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                if tool then
                    if tool.Parent ~= c then hum:EquipTool(tool) end
                    tool:Activate()
                end
            end
        end
    end
    
    -- Auto Bat
    if ENG.Bat then
        local t = GetTarget(25)
        if t and t.Character then
            local th = t.Character:FindFirstChild("HumanoidRootPart")
            if th then
                hrp.CFrame = CFrame.new(hrp.Position:Lerp(th.Position + Vector3.new(0,1.2,0), 0.18), th.Position)
                local tool = c:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                if tool then
                    if tool.Parent ~= c then hum:EquipTool(tool) end
                    tool:Activate()
                end
            end
        end
    end
end)

print("✅ Part 2/4 tamam - Fizik motoru hazır")-- ==============================================================================
-- LEA MOD V5.7 MOBILE - PART 3/4: MOBİL MİNİ UI (KÜÇÜLTÜLMÜŞ)
-- MOBİL İÇİN OPTİMİZE EDİLDİ
-- ==============================================================================

print("⚡ Part 3/4: Mobil UI...")

local function BuildUI(mode)
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    local old = pg:FindFirstChild("LeaUI")
    if old then old:Destroy() end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "LeaUI"
    gui.Parent = pg
    
    -- KÜÇÜK KONTEYNER (SAĞ ALT)
    local cont = Instance.new("Frame")
    cont.Size = UDim2.new(0, 55, 0, 280)
    cont.Position = UDim2.new(1, -62, 0.5, -140)
    cont.BackgroundTransparency = 1
    cont.Active = true
    cont.Draggable = true
    cont.Parent = gui
    
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 4)
    list.Parent = cont
    
    -- MİNİ BUTON FABRİKASI
    local function Btn(text, toggle, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 50, 0, 28)
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
    
    -- MODA GÖRE BUTONLAR
    if mode == "PET" then
        Btn("CUBE", true, function(v) ENG.Cube = v end)
        Btn("BASE", false, function() BaseReturn("PET") end)
        Btn("TRACK", true, function(v) ENG.Track = v end)
        Btn("SPEED", true, function(v) ENG.Carry = v end)
        Btn("DOWN", false, TPDown)
        Btn("XRAY", true, function(v) ToggleXRay(v) end)
        Btn("BAT", true, function(v) ENG.Bat = v end)
    else
        Btn("SPEED", true, function(v) ENG.Carry = v end)
        Btn("FLY", true, function(v) ENG.Cube = v end)
        Btn("BASE", false, function() BaseReturn("DUEL") end)
        Btn("DOWN", false, TPDown)
        Btn("LEFT", true, function(v) ENG.Left = v end)
        Btn("RIGHT", true, function(v) ENG.Right = v end)
        Btn("XRAY", true, function(v) ToggleXRay(v) end)
        Btn("BAT", true, function(v) ENG.Bat = v end)
        Btn("TRACK", true, function(v) ENG.Track = v end)
    end
end

print("✅ Part 3/4 tamam - Mobil UI hazır")-- ==============================================================================
-- LEA MOD V5.7 MOBILE - PART 4/4: BAŞLATICI & TETİKLEYİCİ
-- MOBİL İÇİN OPTİMİZE EDİLDİ
-- ==============================================================================

print("⚡ Part 4/4: Başlatıcı...")

-- Başlat
CreateSelector(function(mode)
    BuildUI(mode)
    
    print("=========================")
    print("LEA V5.7 MOBILE AKTİF")
    print("Mod: " .. mode)
    print("=========================")
end)

-- Acil kapatma
getgenv().LeaKill = function()
    local gui = LocalPlayer.PlayerGui:FindFirstChild("LeaUI")
    if gui then gui:Destroy() end
    
    -- Tüm toggle'ları kapat
    for k, v in pairs(ENG) do
        if type(v) == "boolean" then
            ENG[k] = false
        end
    end
    
    -- XRay kapat
    if ENG.XRay then ToggleXRay(false) end
    
    print("LEA TEMİZLENDİ")
end

print([[
=======================
LEA V5.7 MOBILE HAZIR
- 4 Part tamamlandı
- Mobil optimize
- Leakill() ile kapat
=======================
]])
