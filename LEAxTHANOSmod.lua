-- ============================================
-- LEA MOD V5.9 MOBILE FIX - PART 1/4
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

print("⚡ LEA V5.9 FIX Part 1/4")

getgenv().LeaSecure = {
    AntiKick = true,
    AntiReset = true,
    AntiVoid = true,
    Mode = nil
}

local SEC = getgenv().LeaSecure

-- ============================================
-- SABİT, HAFİF ANTİ-KİCK (checkcaller'sız)
-- ============================================
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if SEC.AntiKick then
        if method == "Kick" or method == "kick" then
            if self == LocalPlayer or self:IsA("Player") then
                return nil
            end
        end
        if self == LocalPlayer and (method == "Destroy" or method == "Remove") then
            return nil
        end
    end
    return oldNamecall(self, ...)
end)

-- ============================================
-- ANTİ-RESET (BASİT)
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

LocalPlayer.CharacterAdded:Connect(AntiReset)
if LocalPlayer.Character then AntiReset(LocalPlayer.Character) end

-- ============================================
-- ANTİ-VOİD (HAFİF)
-- ============================================
local lastSafe = Vector3.new(0,10,0)
RunService.Heartbeat:Connect(function()
    if not SEC.AntiVoid then return end
    pcall(function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if hrp.Position.Y < -500 then
                hrp.CFrame = CFrame.new(lastSafe + Vector3.new(0,10,0))
            else
                lastSafe = hrp.Position
            end
        end
    end)
end)

-- ============================================
-- MOBİL BAŞLANGIÇ SEÇİCİ (KÜÇÜK)
-- ============================================
local function CreateSelector(callback)
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    local gui = Instance.new("ScreenGui")
    gui.Name = "LeaStart"
    gui.Parent = pg
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundColor3 = Color3.new()
    bg.Parent = gui
    
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(0,200,0,30)
    t.Position = UDim2.new(0.5,-100,0.35,0)
    t.BackgroundTransparency = 1
    t.Text = "LEA V5.9"
    t.TextColor3 = Color3.new(1,1,1)
    t.TextSize = 20
    t.Font = Enum.Font.GothamBold
    t.Parent = bg
    
    local function btn(label, mode, x)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0,80,0,36)
        b.Position = UDim2.new(0,x,0.5,0)
        b.BackgroundColor3 = Color3.fromRGB(30,30,30)
        b.Text = label
        b.TextColor3 = Color3.new(1,1,1)
        b.TextSize = 14
        b.Font = Enum.Font.GothamBold
        b.Parent = bg
        b.MouseButton1Click:Connect(function()
            SEC.Mode = mode
            gui:Destroy()
            callback(mode)
        end)
    end
    btn("PET", "PET", 90)
    btn("DUEL", "DUEL", 230)
end

getgenv().LeaEngine = {
    FlyActive = false,
    CubeActive = false,
    TrackActive = false,
    BatActive = false,
    LeftActive = false,
    RightActive = false,
    XRayActive = false,
    FlySpeed = 35,
    BasePos = Vector3.zero,
    Cubes = {},
    LastCubeTime = 0
}

local ENG = getgenv().LeaEngine

-- Base konumu al (hemen, beklemeden)
pcall(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        ENG.BasePos = LocalPlayer.Character.HumanoidRootPart.Position
    end
end)

print("✅ Part 1/4 tamam")-- ============================================
-- LEA MOD V5.9 MOBILE FIX - PART 2/4
-- ============================================
print("⚡ Part 2/4: Hareket sistemleri")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local ENG = getgenv().LeaEngine

-- ============================================
-- YARDIMCI FONKSİYONLAR
-- ============================================
local function GetTarget(dist)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local closest, short = nil, dist or 50
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

function StopFly()
    ENG.FlyActive = false
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
end

-- Cube temizleme
function ClearCubes()
    for _, v in ipairs(ENG.Cubes) do
        if v and v.Parent then v:Destroy() end
    end
    ENG.Cubes = {}
end

local function CreateCube(pos)
    if #ENG.Cubes > 10 then
        local old = table.remove(ENG.Cubes, 1)
        if old and old.Parent then old:Destroy() end
    end
    local cube = Instance.new("Part")
    cube.Size = Vector3.new(4, 0.5, 4)
    cube.Position = pos
    cube.Anchored = true
    cube.CanCollide = true
    cube.Transparency = 0.8
    cube.Parent = workspace
    table.insert(ENG.Cubes, cube)
end

-- ============================================
-- ANA DÖNGÜ (HAFİFLETİLMİŞ)
-- ============================================
local lastProcess = 0
RunService.Heartbeat:Connect(function(dt)
    -- Her kare yerine 0.05 saniyede bir işlem yap (performans)
    if tick() - lastProcess < 0.03 then return end
    lastProcess = tick()
    
    local c = LocalPlayer.Character
    if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end

    local moveDir = hum.MoveDirection
    local vel = hrp.AssemblyLinearVelocity
    local now = tick()

    -- FLY
    if ENG.FlyActive then
        hum.PlatformStand = true
        if moveDir.Magnitude > 0 then
            local camCFrame = Camera.CFrame
            local dir = (camCFrame.RightVector * moveDir.X) + (camCFrame.LookVector * -moveDir.Z)
            if dir.Magnitude > 0 then
                hrp.AssemblyLinearVelocity = dir.Unit * ENG.FlySpeed
            end
        else
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end

    -- CUBE
    if ENG.CubeActive and (now - ENG.LastCubeTime > 0.4) then
        if vel.Y < -5 then
            CreateCube(hrp.Position - Vector3.new(0,3,0))
            ENG.LastCubeTime = now
        elseif vel.Magnitude > 2 then
            local lv = hrp.CFrame.LookVector
            CreateCube(hrp.Position + Vector3.new(lv.X*3, -2.5, lv.Z*3))
            ENG.LastCubeTime = now
        end
    end

    -- STRAFE
    if ENG.LeftActive then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(3), 0) + (-hrp.CFrame.RightVector * 30 * dt)
    end
    if ENG.RightActive then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(-3), 0) + (hrp.CFrame.RightVector * 30 * dt)
    end

    -- TAKİP
    if ENG.TrackActive then
        local t = GetTarget(50)
        if t and t.Character then
            local th = t.Character:FindFirstChild("HumanoidRootPart")
            if th then
                local targetPos = th.Position + Vector3.new(0,1,0)
                local dir = targetPos - hrp.Position
                hrp.AssemblyLinearVelocity = dir.Unit * ENG.FlySpeed
                hum.PlatformStand = true
                local tool = c:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                if tool then
                    if tool.Parent ~= c then hum:EquipTool(tool) end
                    pcall(function() tool:Activate() end)
                end
            end
        end
    end

    -- AUTO BAT
    if ENG.BatActive then
        local t = GetTarget(25)
        if t and t.Character then
            local th = t.Character:FindFirstChild("HumanoidRootPart")
            if th then
                local targetPos = th.Position + Vector3.new(0,1.2,0)
                hrp.AssemblyLinearVelocity = (targetPos - hrp.Position).Unit * ENG.FlySpeed
                hum.PlatformStand = true
                local tool = c:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                if tool then
                    if tool.Parent ~= c then hum:EquipTool(tool) end
                    pcall(function() tool:Activate() end)
                end
            end
        end
    end

    -- Otomatik PlatformStand kapatma (hiçbir uçuş modu aktif değilse)
    if not ENG.FlyActive and not ENG.TrackActive and not ENG.BatActive then
        if hum.PlatformStand then
            hum.PlatformStand = false
        end
        hrp.AssemblyLinearVelocity = Vector3.zero
    end
end)

-- ============================================
-- BASE RETURN (AYNI DÖNGÜYÜ KULLANMAZ)
-- ============================================
function BaseReturn(mode)
    local c = LocalPlayer.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    
    local targetPos = ENG.BasePos + Vector3.new(0,3,0)
    local speed = (mode == "PET") and 18 or 24
    
    local flyWas = ENG.FlyActive
    ENG.FlyActive = false -- ana döngüyle çakışmasın
    hum.PlatformStand = true
    
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not c.Parent then conn:Disconnect() return end
        local dir = targetPos - hrp.Position
        if dir.Magnitude < 1 then
            hrp.AssemblyLinearVelocity = Vector3.zero
            conn:Disconnect()
            hum.PlatformStand = false
            ENG.FlyActive = flyWas
            return
        end
        hrp.AssemblyLinearVelocity = dir.Unit * speed
    end)
end

-- TP DOWN
function TPDown()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local ray = Workspace:Raycast(hrp.Position, Vector3.new(0,-700,0))
    if ray then hrp.CFrame = CFrame.new(ray.Position + Vector3.new(0,3,0)) end
end

-- X-RAY (hafif)
local xrayCache = {}
function ToggleXRay(state)
    ENG.XRayActive = state
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) then
            if state then
                if obj.Transparency < 0.3 then
                    xrayCache[obj] = obj.Transparency
                    obj.Transparency = 0.5
                end
            else
                if xrayCache[obj] then obj.Transparency = xrayCache[obj] end
            end
        end
    end
    if not state then xrayCache = {} end
end

print("✅ Part 2/4 tamam")-- ============================================
-- LEA MOD V5.9 MOBILE FIX - PART 3/4
-- ============================================
print("⚡ Part 3/4: Mobil UI")

local function BuildUI(mode)
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    local old = pg:FindFirstChild("LeaUI")
    if old then old:Destroy() end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "LeaUI"
    gui.Parent = pg
    
    -- DAHA KÜÇÜK KONTEYNER
    local cont = Instance.new("Frame")
    cont.Size = UDim2.new(0, 48, 0, 260)
    cont.Position = UDim2.new(1, -54, 0.35, 0)
    cont.BackgroundTransparency = 1
    cont.Active = true
    cont.Draggable = true
    cont.Parent = gui
    
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 3)
    list.Parent = cont
    
    local function Btn(text, toggle, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 44, 0, 24)
        b.BackgroundColor3 = Color3.fromRGB(20,20,25)
        b.TextColor3 = Color3.new(1,1,1)
        b.Text = text
        b.TextSize = 6
        b.Font = Enum.Font.GothamBold
        b.Parent = cont
        
        if toggle then
            local state = false
            b.MouseButton1Click:Connect(function()
                state = not state
                b.BackgroundColor3 = state and Color3.fromRGB(0,150,80) or Color3.fromRGB(20,20,25)
                callback(state)
            end)
        else
            b.MouseButton1Click:Connect(function()
                b.BackgroundColor3 = Color3.fromRGB(0,100,180)
                task.delay(0.12, function() b.BackgroundColor3 = Color3.fromRGB(20,20,25) end)
                callback()
            end)
        end
    end
    
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
-- LEA MOD V5.9 MOBILE FIX - PART 4/4
-- ============================================
print("⚡ Part 4/4: Başlatıcı")

CreateSelector(function(mode)
    BuildUI(mode)
    print("LEA V5.9 FIX Aktif - " .. mode)
end)

getgenv().LeaKill = function()
    StopFly()
    ClearCubes()
    ToggleXRay(false)
    for k,v in pairs(getgenv().LeaEngine) do
        if type(v) == "boolean" then getgenv().LeaEngine[k] = false end
    end
    local gui = LocalPlayer.PlayerGui:FindFirstChild("LeaUI")
    if gui then gui:Destroy() end
    print("LEA Temizlendi")
end

print("✅ Part 4/4 tamam - Hazır!")
