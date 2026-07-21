-- ==============================================================================
-- LEA MOD ULTIMATE V29.0 (PART 1 / 2 - STABLE CORE & UI)
-- ==============================================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- GLOBAL STATE INITIALIZATION
if not getgenv().LeaModGlobalState then
    getgenv().LeaModGlobalState = {
        Mode = "NONE",
        Speed = 24,
        SpawnPos = nil,
        Cube = false,
        Cubes = {},
        LastCube = 0,
        Noclip = false,
        AutoAvoid = false,
        Visuals = false,
        Invisible = false,
        HitboxAura = false,
        AntiGeriatma = true,
        CubeAntiDetect = true,
        CurrentLevel = 1,
        SessionTime = os.time()
    }
end

local State = getgenv().LeaModGlobalState

-- GÜVENLİ GUI YÖNETİMİ VE TEMİZLİK (MEMORY LEAK FIX)
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
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = GetGuiParent()

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 245, 0, 310) 
MainFrame.Position = UDim2.new(1, -260, 0.35, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 255, 200)
MainStroke.Thickness = 1.8

local HeaderTitle = Instance.new("TextLabel", MainFrame)
HeaderTitle.Size = UDim2.new(1, 0, 0, 28)
HeaderTitle.Position = UDim2.new(0, 0, 0, 2)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "LEA MOD ULTIMATE V29.0"
HeaderTitle.TextColor3 = Color3.fromRGB(0, 255, 200)
HeaderTitle.TextSize = 11
HeaderTitle.Font = Enum.Font.GothamBold

local ToggleMenuBtn = Instance.new("TextButton", ScreenGui)
ToggleMenuBtn.Size = UDim2.new(0, 45, 0, 28)
ToggleMenuBtn.Position = UDim2.new(1, -60, 0, 12)
ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
ToggleMenuBtn.Text = "LEA"
ToggleMenuBtn.TextColor3 = Color3.fromRGB(15, 15, 22)
ToggleMenuBtn.TextSize = 11
ToggleMenuBtn.Font = Enum.Font.GothamBold
local ToggleCorner = Instance.new("UICorner", ToggleMenuBtn)
ToggleCorner.CornerRadius = UDim.new(0, 6)

ToggleMenuBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    ToggleMenuBtn.BackgroundColor3 = MainFrame.Visible and Color3.fromRGB(0, 255, 200) or Color3.fromRGB(255, 50, 80)
end)

local function CreateGridButton(posX, posY, sizeX, sizeY, text, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, sizeX, 0, sizeY)
    btn.Position = UDim2.new(0, posX, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.TextSize = 9
    btn.Font = Enum.Font.GothamBold
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(60, 60, 80)
    stroke.Thickness = 1
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- SUNUCU DEĞİŞTİRME (STATE KORUMALI SERVER HOP)
local function FlashServerHop()
    pcall(function()
        local serversUrl = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(serversUrl))
        end)
        
        if success and result and result.data then
            for _, s in ipairs(result.data) do
                if type(s) == "table" and s.id and s.playing < s.maxPlayers and s.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                    return
                end
            end
        end
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
end

-- PELERİN / GÖRünMEZLİK YÖNETİCİSİ
local function HandlePelerinInvisible(enabled)
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        if enabled then
            local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
            if backpack then
                for _, item in ipairs(backpack:GetChildren()) do
                    if item:IsA("Tool") then
                        local name = item.Name:lower()
                        if name:find("pelerin") or name:find("cape") or name:find("invis") or name:find("cloak") then
                            item.Parent = char
                            task.wait(0.02)
                        end
                    end
                end
            end
            
            for _, item in ipairs(char:GetChildren()) do
                if item:IsA("Tool") then
                    local name = item.Name:lower()
                    if name:find("pelerin") or name:find("cape") or name:find("invis") or name:find("cloak") then
                        item:Activate()
                    end
                end
            end

            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = 1
                elseif part:IsA("Decal") then
                    part.Transparency = 1
                end
            end
        else
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = 0
                elseif part:IsA("Decal") then
                    part.Transparency = 0
                end
            end
        end
    end)
end

-- STATS SENKRONİZASYONU
local function SyncRealLevel()
    pcall(function()
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
        if leaderstats then
            local lvlVal = leaderstats:FindFirstChild("Level") or leaderstats:FindFirstChild("Stage") or leaderstats:FindFirstChild("Rebirth")
            if lvlVal then State.CurrentLevel = lvlVal.Value end
        end
    end)
end

-- KARARLI KARAKTER YAŞAM DÖNGÜSÜ & KESİNTİSİZ RESET KORUMASI (BEKLENMEYEN RE-SPAWN FIX)
local function SetupCharacterLifecycle(char)
    pcall(function()
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then
            -- Can düşmelerini engelle ve sonsuz zırh sağla
            hum:GetPropertyChangedSignal("Health"):Connect(function()
                if hum.Health < 5 then
                    hum.Health = hum.MaxHealth
                end
            end)
            
            -- Ölüm döngüsünü tamamen kır ve karakterin yok olmasını engelle
            hum.BreakJointsOnDeath = false
            hum.Died:Connect(function()
                hum.Health = hum.MaxHealth
            end)
        end
    end)
    
    task.spawn(function()
        local hrp = char:WaitForChild("HumanoidRootPart", 10)
        if hrp then State.SpawnPos = hrp.Position + Vector3.new(0, 3, 0) end
    end)
    
    if State.Invisible then
        task.wait(0.2)
        HandlePelerinInvisible(true)
    end
end

if LocalPlayer.Character then SetupCharacterLifecycle(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(SetupCharacterLifecycle)

local UIButtons = {}

UIButtons.Invisible = CreateGridButton(10, 35, 108, 26, "👻 INVIS OFF", function()
    State.Invisible = not State.Invisible
    HandlePelerinInvisible(State.Invisible)
    UIButtons.Invisible.Text = State.Invisible and "👻 INVIS ON" or "👻 INVIS OFF"
    UIButtons.Invisible.BackgroundColor3 = State.Invisible and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(30, 30, 42)
end)

UIButtons.Base = CreateGridButton(124, 35, 108, 26, "🏠 BASE OFF", function()
    State.Mode = (State.Mode == "BASE" and "NONE" or "BASE")
    UIButtons.Base.Text = (State.Mode == "BASE") and "🏠 BASE ON" or "🏠 BASE OFF"
    UIButtons.Base.BackgroundColor3 = (State.Mode == "BASE") and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(30, 30, 42)
end)

UIButtons.HitboxAura = CreateGridButton(10, 65, 108, 26, "⚔️ SOPA AURA OFF", function()
    State.HitboxAura = not State.HitboxAura
    UIButtons.HitboxAura.Text = State.HitboxAura and "⚔️ SOPA AURA ON" or "⚔️ SOPA AURA OFF"
    UIButtons.HitboxAura.BackgroundColor3 = State.HitboxAura and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(30, 30, 42)
end)

UIButtons.Noclip = CreateGridButton(124, 65, 108, 26, "🛡️ NOCLIP OFF", function()
    State.Noclip = not State.Noclip
    UIButtons.Noclip.Text = State.Noclip and "🛡️ NOCLIP ON" or "🛡️ NOCLIP OFF"
    UIButtons.Noclip.BackgroundColor3 = State.Noclip and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(30, 30, 42)
end)

UIButtons.Cube = CreateGridButton(10, 95, 108, 26, "🧊 CUBE OFF", function()
    State.Cube = not State.Cube
    UIButtons.Cube.Text = State.Cube and "🧊 CUBE ON" or "🧊 CUBE OFF"
    UIButtons.Cube.BackgroundColor3 = State.Cube and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(30, 30, 42)
end)

UIButtons.Visuals = CreateGridButton(124, 95, 108, 26, "👁️ ESP OFF", function()
    State.Visuals = not State.Visuals
    UIButtons.Visuals.Text = State.Visuals and "👁️ ESP ON" or "👁️ ESP OFF"
    UIButtons.Visuals.BackgroundColor3 = State.Visuals and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(30, 30, 42)
end)

UIButtons.AutoAvoid = CreateGridButton(10, 125, 108, 26, "🛡️ KORUMA OFF", function()
    State.AutoAvoid = not State.AutoAvoid
    UIButtons.AutoAvoid.Text = State.AutoAvoid and "🛡️ KORUMA ON" or "🛡️ KORUMA OFF"
    UIButtons.AutoAvoid.BackgroundColor3 = State.AutoAvoid and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(30, 30, 42)
end)

UIButtons.Target = CreateGridButton(124, 125, 108, 26, "🎯 TAKİP OFF", function()
    State.Mode = (State.Mode == "TARGET" and "NONE" or "TARGET")
    UIButtons.Target.Text = (State.Mode == "TARGET") and "🎯 TAKİP ON" or "🎯 TAKİP OFF"
    UIButtons.Target.BackgroundColor3 = (State.Mode == "TARGET") and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(30, 30, 42)
end)

local SpeedLbl = Instance.new("TextLabel", MainFrame)
SpeedLbl.Size = UDim2.new(0, 222, 0, 18)
SpeedLbl.Position = UDim2.new(0, 10, 0, 156)
SpeedLbl.BackgroundTransparency = 1
SpeedLbl.Text = "Hız Değeri: " .. State.Speed
SpeedLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLbl.TextSize = 10
SpeedLbl.Font = Enum.Font.GothamSemibold

CreateGridButton(10, 176, 108, 24, "-5 Hız", function()
    State.Speed = math.clamp(State.Speed - 5, 16, 120)
    SpeedLbl.Text = "Hız Değeri: " .. State.Speed
end)

CreateGridButton(124, 176, 108, 24, "+5 Hız", function()
    State.Speed = math.clamp(State.Speed + 5, 16, 120)
    SpeedLbl.Text = "Hız Değeri: " .. State.Speed
end)

CreateGridButton(10, 206, 222, 28, "⚡ FLASH SUNUCU DEĞİŞ (HOP)", function()
    FlashServerHop()
end)

local StatusBanner = Instance.new("TextLabel", MainFrame)
StatusBanner.Size = UDim2.new(0, 222, 0, 22)
StatusBanner.Position = UDim2.new(0, 10, 0, 240)
StatusBanner.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
StatusBanner.Text = "🛡️ STABLE MODE: V29.0 ACTIVE"
StatusBanner.TextColor3 = Color3.fromRGB(0, 255, 200)
StatusBanner.TextSize = 8.5
StatusBanner.Font = Enum.Font.GothamBold
local StatusCorner = Instance.new("UICorner", StatusBanner)
StatusCorner.CornerRadius = UDim.new(0, 4)

local CreditLbl = Instance.new("TextLabel", MainFrame)
CreditLbl.Size = UDim2.new(1, 0, 0, 20)
CreditLbl.Position = UDim2.new(0, 0, 0, 285)
CreditLbl.BackgroundTransparency = 1
CreditLbl.Text = "LEA MOD ULTIMATE • V29.0 STABILITY"
CreditLbl.TextColor3 = Color3.fromRGB(120, 120, 150)
CreditLbl.TextSize = 8
CreditLbl.Font = Enum.Font.Gotham
-- ==============================================================================
-- LEA MOD ULTIMATE V29.0 (PART 2 / 2 - OPTIMIZED ENGINE & ISOLATED MODULES)
-- ==============================================================================

-- 1. OPTİMİZE EDİLMİŞ DUVAR SAYDAMLAŞTIRMA (SADECE BÜYÜK YAPILAR, GEREKSİZ NESNELER HARİÇ)
task.spawn(function()
    while task.wait(4) do
        pcall(function()
            for _, part in ipairs(Workspace:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "Baseplate" and not part.Anchored then
                    -- Sabit büyük yapıları hedef al, küçük eşya/partları yorma
                    local nameL = part.Name:lower()
                    local isHazard = nameL:find("laser") or nameL:find("lazer") or nameL:find("kill") or nameL:find("hazard")
                    
                    if not isHazard and part.Size.Magnitude > 15 and part.Transparency < 0.75 then
                        part.Transparency = 0.75
                    end
                end
            end
        end)
    end
end)

-- 2. HAFİFLETİLMİŞ ESP DÖNGÜSÜ
task.spawn(function()
    while task.wait(1.0) do
        SyncRealLevel()
        pcall(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local char = p.Character
                    local hl = char:FindFirstChild("LeaESP")
                    
                    if State.Visuals then
                        if not hl then
                            hl = Instance.new("Highlight")
                            hl.Name = "LeaESP"
                            hl.FillColor = Color3.fromRGB(255, 50, 50) 
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.3
                            hl.OutlineTransparency = 0.0
                            hl.Parent = char
                        end
                    else
                        if hl then hl:Destroy() end
                    end
                end
            end
        end)
    end
end)

-- NOCLIP MODÜLÜ
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

-- 3. ANA MOTOR: KESİNTİSİZ HIZ, AKICI BASE VE İZOLASYONLU ALT SİSTEMLER
RunService.Heartbeat:Connect(function(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    -- HIZ SABİTLEME (ZAMANLA DÜŞMEYİ KESİN OLARAK ÖNLER)
    if hum.WalkSpeed ~= State.Speed then
        hum.WalkSpeed = State.Speed
    end

    -- ANTI-GERİATMA / FİZİK FİLTRESİ
    if State.AntiGeriatma then
        pcall(function()
            if hrp.AssemblyLinearVelocity.Magnitude > 180 then
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end)
    end

    if State.Invisible then HandlePelerinInvisible(true) end

    -- A. AKICI VE KESİNTİSİZ BASE HAREKET SİSTEMİ (GERİ DÖNME / TAKILMA FIX)
    if State.Mode == "BASE" and State.SpawnPos then
        pcall(function()
            local targetPos = State.SpawnPos
            local currentPos = hrp.Position
            local flatTarget = Vector3.new(targetPos.X, currentPos.Y, targetPos.Z)
            local dist = (flatTarget - currentPos).Magnitude
            
            if dist > 3 then
                local dir = (flatTarget - currentPos).Unit
                local step = math.min(dist, State.Speed * dt * 2.5)
                char:PivotTo(hrp.CFrame + (dir * step))
                hrp.AssemblyLinearVelocity = Vector3.zero
            else
                char:PivotTo(CFrame.new(targetPos))
                State.Mode = "NONE"
            end
        end)
    
    -- B. HEDEF (TARGET) TAKİP SİSTEMİ
    elseif State.Mode == "TARGET" then
        pcall(function()
            local target, minDist = nil, math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local eHrp = p.Character:FindFirstChild("HumanoidRootPart")
                    local eHum = p.Character:FindFirstChildOfClass("Humanoid")
                    if eHrp and eHum and eHum.Health > 0 then
                        local dist = (eHrp.Position - hrp.Position).Magnitude
                        if dist < minDist then 
                            minDist = dist
                            target = eHrp 
                        end
                    end
                end
            end
            
            if target then
                local dist = (target.Position - hrp.Position).Magnitude
                if dist > 3.5 then
                    local targetPos = Vector3.new(target.Position.X, hrp.Position.Y, target.Position.Z)
                    local dir = (targetPos - hrp.Position).Unit
                    local moveStep = math.min(dist, State.Speed * dt * 2.5)
                    local newCFrame = CFrame.lookAt(hrp.Position + (dir * moveStep), targetPos)
                    char:PivotTo(newCFrame)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                end
            end
        end)
    end

    -- C. SOPA / HITBOX AURA SİSTEMİ
    if State.HitboxAura then
        pcall(function()
            local tool = char:FindFirstChildOfClass("Tool")
            if not tool then
                local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
                if backpack then
                    tool = backpack:FindFirstChildOfClass("Tool")
                    if tool and not tool.Name:lower():find("pelerin") then
                        tool.Parent = char
                    end
                end
            end

            if tool then
                tool:Activate()
                local hitPart = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart") or hrp

                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local eHrp = p.Character:FindFirstChild("HumanoidRootPart")
                        local eHum = p.Character:FindFirstChildOfClass("Humanoid")
                        if eHrp and eHum and eHum.Health > 0 then
                            if (eHrp.Position - hrp.Position).Magnitude < 20 then
                                if firetouchinterest then
                                    firetouchinterest(hitPart, eHrp, 0)
                                    firetouchinterest(hitPart, eHrp, 1)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end

    -- D. OTOMATİK KORUMA (AUTO AVOID)
    if State.AutoAvoid and State.Mode == "NONE" then
        pcall(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local eHrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if eHrp then
                        if (eHrp.Position - hrp.Position).Magnitude < 14 then
                            local escapeDir = (hrp.Position - eHrp.Position).Unit
                            char:PivotTo(hrp.CFrame + (escapeDir * 2.2))
                        end
                    end
                end
            end
        end)
    end

    -- E. CUBE (KÜP OLUŞTURMA VE BELLEK OPTİMİZASYONU)
    if State.Cube then
        pcall(function()
            if hrp.AssemblyLinearVelocity.Y < -1.5 and (os.clock() - State.LastCube > 0.2) then
                if #State.Cubes >= 8 then
                    local oldC = table.remove(State.Cubes, 1)
                    if oldC and oldC.Parent then oldC:Destroy() end
                end
                local cube = Instance.new("Part")
                cube.Size = Vector3.new(5, 0.4, 5)
                cube.Position = hrp.Position - Vector3.new(0, 3.2, 0)
                cube.Anchored = true
                cube.CanCollide = true
                cube.Transparency = State.CubeAntiDetect and 0.85 or 0.75
                cube.Material = Enum.Material.Neon
                cube.Color = Color3.fromRGB(0, 255, 200)
                
                if State.CubeAntiDetect then
                    cube:SetAttribute("IsLeaModShield", true)
                end
                
                cube.Parent = Workspace
                table.insert(State.Cubes, cube)
                State.LastCube = os.clock()
            end
        end)
    end
end)

print("✅ LEA MOD ULTIMATE V29.0 - STABILITY & OPTIMIZATION APPLIED!")
