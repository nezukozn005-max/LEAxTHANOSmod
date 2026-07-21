-- ==============================================================================
-- LEA MOD ULTIMATE V22.5 (FULL MONOLITHIC - ALL FEATURES COMBINED & UNLIMITED)
-- ==============================================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

-- GLOBAL STATE INITIALIZATION
if not getgenv().LeaModGlobalState then
    getgenv().LeaModGlobalState = {
        Mode = "NONE",
        Speed = 22,
        SpawnPos = nil,
        Cube = false,
        Cubes = {},
        LastCube = 0,
        Noclip = false,
        AutoAvoid = false,
        Visuals = false,
        Invisible = false,
        HitboxAura = false,
        BypassReset = false,
        CurrentLevel = 1
    }
end

local State = getgenv().LeaModGlobalState

-- GUI PARENT PROTECTION
local function GetGuiParent()
    local success, parent = pcall(function() return CoreGui end)
    if success and parent then return parent end
    return LocalPlayer:WaitForChild("PlayerGui", 5)
end

pcall(function()
    local existing = GetGuiParent():FindFirstChild("LeaModMonolithicGUI")
    if existing then existing:Destroy() end
end)

-- SCREEN GUI CREATION
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LeaModMonolithicGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = GetGuiParent()

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 280) 
MainFrame.Position = UDim2.new(1, -235, 0.4, -140)
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
HeaderTitle.Text = "LEA MOD ULTIMATE V22.5"
HeaderTitle.TextColor3 = Color3.fromRGB(0, 255, 200)
HeaderTitle.TextSize = 11
HeaderTitle.Font = Enum.Font.GothamBold

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

-- PELERIN & INVISIBLE LOGIC
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
                            task.wait(0.05)
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

local function SyncRealLevel()
    pcall(function()
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
        if leaderstats then
            local lvlVal = leaderstats:FindFirstChild("Level") or leaderstats:FindFirstChild("Stage") or leaderstats:FindFirstChild("Rebirth")
            if lvlVal then State.CurrentLevel = lvlVal.Value end
        end
    end)
end

local function SetupCharacterLifecycle(char)
    pcall(function()
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        end
    end)
    task.spawn(function()
        local hrp = char:WaitForChild("HumanoidRootPart", 10)
        if hrp then State.SpawnPos = hrp.Position + Vector3.new(0, 3, 0) end
    end)
    if State.Invisible then
        task.wait(0.3)
        HandlePelerinInvisible(true)
    end
end

if LocalPlayer.Character then SetupCharacterLifecycle(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(SetupCharacterLifecycle)

local UIButtons = {}

-- Menü Butonları
UIButtons.Invisible = CreateGridButton(8, 32, 98, 24, "👻 INVIS OFF", function()
    State.Invisible = not State.Invisible
    HandlePelerinInvisible(State.Invisible)
    UIButtons.Invisible.Text = State.Invisible and "👻 INVIS ON" or "👻 INVIS OFF"
    UIButtons.Invisible.BackgroundColor3 = State.Invisible and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(40, 40, 55)
end)

UIButtons.Base = CreateGridButton(112, 32, 98, 24, "🏠 BASE OFF", function()
    State.Mode = (State.Mode == "BASE" and "NONE" or "BASE")
    UIButtons.Base.Text = (State.Mode == "BASE") and "🏠 BASE ON" or "🏠 BASE OFF"
    UIButtons.Base.BackgroundColor3 = (State.Mode == "BASE") and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(40, 40, 55)
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

UIButtons.AutoAvoid = CreateGridButton(8, 116, 98, 24, "🛡️ KORUMA OFF", function()
    State.AutoAvoid = not State.AutoAvoid
    UIButtons.AutoAvoid.Text = State.AutoAvoid and "🛡️ KORUMA ON" or "🛡️ KORUMA OFF"
    UIButtons.AutoAvoid.BackgroundColor3 = State.AutoAvoid and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(40, 40, 55)
end)

UIButtons.Target = CreateGridButton(112, 116, 98, 24, "🎯 TAKİP OFF", function()
    State.Mode = (State.Mode == "TARGET" and "NONE" or "TARGET")
    UIButtons.Target.Text = (State.Mode == "TARGET") and "🎯 TAKİP ON" or "🎯 TAKİP OFF"
    UIButtons.Target.BackgroundColor3 = (State.Mode == "TARGET") and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(40, 40, 55)
end)

-- Hız Kontrolleri
local SpeedLbl = Instance.new("TextLabel", MainFrame)
SpeedLbl.Size = UDim2.new(0, 202, 0, 18)
SpeedLbl.Position = UDim2.new(0, 8, 0, 146)
SpeedLbl.BackgroundTransparency = 1
SpeedLbl.Text = "Hız Değeri: " .. State.Speed
SpeedLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLbl.TextSize = 10
SpeedLbl.Font = Enum.Font.GothamSemibold

CreateGridButton(8, 166, 47, 22, "-5 Hız", function()
    State.Speed = math.clamp(State.Speed - 5, 16, 90)
    SpeedLbl.Text = "Hız Değeri: " .. State.Speed
end)
CreateGridButton(59, 166, 47, 22, "+5 Hız", function()
    State.Speed = math.clamp(State.Speed + 5, 16, 90)
    SpeedLbl.Text = "Hız Değeri: " .. State.Speed
end)
CreateGridButton(8, 196, 202, 26, "🌐 SUNUCU DEĞİŞ & HIZLI HOP", function()
    pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
end)
CreateGridButton(8, 230, 202, 26, "🔄 GÜVENLİ RESET", function()
    State.BypassReset = true
    pcall(function() 
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end)
end)

-- DUVARLAR VE BİNALAR ŞEFFAFLAŞTIRICI MOTOR (Lazerler Hariç)
task.spawn(function()
    while task.wait(2) do
        pcall(function()
            for _, part in ipairs(Workspace:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "Baseplate" then
                    local nameL = part.Name:lower()
                    local isLaser = nameL:find("laser") or nameL:find("lazer") or nameL:find("kill") or nameL:find("hazard")
                    
                    if not isLaser then
                        local isWallOrBuilding = (part.Size.Y > 4 or part.Size.X > 8 or part.Size.Z > 8) or nameL:find("wall") or nameL:find("duvar") or nameL:find("building") or nameL:find("part")
                        if isWallOrBuilding and part.Transparency < 0.75 and part.Transparency > 0 then
                            part.Transparency = 0.75
                        end
                    end
                end
            end
        end)
    end
end)

-- GÖRÜNMEZLERİ TESPİT EDEN ESP DÖNGÜSÜ
task.spawn(function()
    while task.wait(0.4) do
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

-- NOCLIP MOTORU
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

-- ANA FİZİK, ANTI-GERIATMA, HIZ KORUMA, PET/OBJE SENKRONİZASYONU VE CUBE KÜP DÖNGÜSÜ
RunService.Heartbeat:Connect(function(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    -- 1. ANTI-GERIATMA / ANTI-KICK HIZ SÖNÜMLEME FİLTRESİ
    pcall(function()
        if hrp.AssemblyLinearVelocity.Magnitude > 130 then
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end)

    -- 2. HIZ SABİTLEME (ASLA YAVAŞLAMA OLMAMASI İÇİN)
    hum.WalkSpeed = State.Speed

    -- 3. PET / ÇALINAN OBJE YER İÇİNE GİRME VE GÖRÜNMEZLİK FIX
    pcall(function()
        for _, joint in ipairs(char:GetDescendants()) do
            if joint:IsA("Weld") or joint:IsA("Motor6D") then
                if joint.Part1 and joint.Part1.Parent ~= char and joint.Part1.Parent ~= Workspace then
                    if not joint:GetAttribute("SyncedPet") then
                        joint.C0 = joint.C0 * CFrame.new(0, 0, 0)
                        joint:SetAttribute("SyncedPet", true)
                    end
                end
            end
        end
    end)

    if State.Invisible then HandlePelerinInvisible(true) end

    -- 4. BASE DÖNÜŞ MOTORU
    if State.Mode == "BASE" and State.SpawnPos then
        pcall(function()
            local dist = (State.SpawnPos - hrp.Position).Magnitude
            if dist > 2 then
                local dir = (State.SpawnPos - hrp.Position).Unit
                local moveStep = math.min(dist, State.Speed * dt * 3)
                char:PivotTo(hrp.CFrame + (dir * moveStep))
                hrp.Velocity = Vector3.zero
            else
                char:PivotTo(CFrame.new(State.SpawnPos))
                State.Mode = "NONE"
            end
        end)
    
    -- 5. HEDEF (TARGET) TAKİP MOTORU
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
                    local moveStep = math.min(dist, State.Speed * dt * 3)
                    local newCFrame = CFrame.lookAt(hrp.Position + (dir * moveStep), targetPos)
                    char:PivotTo(newCFrame)
                    hrp.Velocity = Vector3.zero
                end
            end
        end)
    end

    -- 6. SOPA / HITBOX AURA MOTORU
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
                local hitPart = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart") or char:FindFirstChild("Right Hand") or hrp

                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local eHrp = p.Character:FindFirstChild("HumanoidRootPart")
                        local eHum = p.Character:FindFirstChildOfClass("Humanoid")
                        if eHrp and eHum and eHum.Health > 0 then
                            local distance = (eHrp.Position - hrp.Position).Magnitude
                            if distance < 15 then
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

    -- 7. OTOMATİK KORUMA (AUTO AVOID)
    if State.AutoAvoid and State.Mode == "NONE" then
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

    -- 8. CUBE (KÜP OLUŞTURMA & ANTI-DETECT)
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
                cube.Transparency = 0.75
                cube.Material = Enum.Material.Neon
                cube.Color = Color3.fromRGB(0, 255, 200)
                cube.Parent = Workspace
                table.insert(State.Cubes, cube)
                State.LastCube = os.clock()
            end
        end)
    end
end)

print("✅ LEA MOD ULTIMATE V22.5 - TÜM ÖZELLİKLER BİRLEŞTİRİLDİ VE AKTİF!")
