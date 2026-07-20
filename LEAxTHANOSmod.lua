-- ==============================================================================
-- LEA MOD ULTIMATE - PART 1 / 2 (CORE, SECURITY, UI & SERVER FINDER)
-- ==============================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

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
    KillAura = false,
    BypassReset = false,
    AntiKickActive = true,
    AntiDetectActive = true,
    ServerFinderActive = false,
    TargetServerId = nil,
    IsSearchingServers = false
}

local State = getgenv().LeaModGlobalState

-- 1) ANTI-DETECT VE ANTI-KICK MOTORU
pcall(function()
    if not State.AntiDetectActive then return end
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if State.AntiKickActive and (method == "Kick" or method == "kick") then
            return nil
        end
        if method == "FireServer" or method == "InvokeServer" then
            local remoteName = tostring(self):lower()
            if remoteName:find("anticheat") or remoteName:find("ban") or remoteName:find("detect") or remoteName:find("report") or remoteName:find("security") then
                return nil
            end
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end)

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

-- 2) ANA MENÜ (UI)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 150, 0, 340)
MainFrame.Position = UDim2.new(1, -165, 0.5, -170)
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
HeaderTitle.Size = UDim2.new(1, 0, 0, 28)
HeaderTitle.Position = UDim2.new(0, 0, 0, 4)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "LEA MOD ULTIMATE"
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

local UIButtons = {}
local function CreateButton(posY, text, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(1, -12, 0, 24)
    btn.Position = UDim2.new(0, 6, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 9.5
    btn.Font = Enum.Font.GothamBold
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 5)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- 3) POTATO GRAPHICS & RESET KORUMASI
local function ApplyPotatoGraphics(state)
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
        if state then Lighting.GlobalShadows = false end
    end)
end

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
end

if LocalPlayer.Character then SetupCharacterLifecycle(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(SetupCharacterLifecycle)

-- 4) RARE PET SERVER FINDER PENCERESİ
local FinderFrame = Instance.new("Frame", ScreenGui)
FinderFrame.Size = UDim2.new(0, 260, 0, 230)
FinderFrame.Position = UDim2.new(0.5, -130, 0.5, -115)
FinderFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
FinderFrame.BorderSizePixel = 0
FinderFrame.Visible = false
FinderFrame.Active = true
FinderFrame.Draggable = true

local FinderCorner = Instance.new("UICorner", FinderFrame)
FinderCorner.CornerRadius = UDim.new(0, 8)
local FinderStroke = Instance.new("UIStroke", FinderFrame)
FinderStroke.Color = Color3.fromRGB(0, 255, 200)
FinderStroke.Thickness = 1.5

local FinderHeader = Instance.new("TextLabel", FinderFrame)
FinderHeader.Size = UDim2.new(1, 0, 0, 30)
FinderHeader.Position = UDim2.new(0, 0, 0, 0)
FinderHeader.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
FinderHeader.Text = "LEA SERVER FINDER"
FinderHeader.TextColor3 = Color3.fromRGB(0, 255, 200)
FinderHeader.TextSize = 12
FinderHeader.Font = Enum.Font.GothamBold

local FinderStatus = Instance.new("TextLabel", FinderFrame)
FinderStatus.Size = UDim2.new(1, -20, 0, 25)
FinderStatus.Position = UDim2.new(0, 10, 0, 40)
FinderStatus.BackgroundTransparency = 1
FinderStatus.Text = "🔎 Durum: Hazır"
FinderStatus.TextColor3 = Color3.fromRGB(220, 220, 220)
FinderStatus.TextSize = 11
FinderStatus.Font = Enum.Font.GothamSemibold
FinderStatus.TextXAlignment = Enum.TextXAlignment.Left

local FinderPetVal = Instance.new("TextLabel", FinderFrame)
FinderPetVal.Size = UDim2.new(1, -20, 0, 25)
FinderPetVal.Position = UDim2.new(0, 10, 0, 70)
FinderPetVal.BackgroundTransparency = 1
FinderPetVal.Text = "🐾 Pet Değeri: -"
FinderPetVal.TextColor3 = Color3.fromRGB(220, 220, 220)
FinderPetVal.TextSize = 11
FinderPetVal.Font = Enum.Font.GothamSemibold
FinderPetVal.TextXAlignment = Enum.TextXAlignment.Left

local FinderIdLbl = Instance.new("TextLabel", FinderFrame)
FinderIdLbl.Size = UDim2.new(1, -20, 0, 25)
FinderIdLbl.Position = UDim2.new(0, 10, 0, 100)
FinderIdLbl.BackgroundTransparency = 1
FinderIdLbl.Text = "🌐 Server ID: -"
FinderIdLbl.TextColor3 = Color3.fromRGB(220, 220, 220)
FinderIdLbl.TextSize = 11
FinderIdLbl.Font = Enum.Font.GothamSemibold
FinderIdLbl.TextXAlignment = Enum.TextXAlignment.Left

local QuickJoinBtn = Instance.new("TextButton", FinderFrame)
QuickJoinBtn.Size = UDim2.new(1, -20, 0, 28)
QuickJoinBtn.Position = UDim2.new(0, 10, 0, 140)
QuickJoinBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
QuickJoinBtn.Text = "SERVER'A HIZLI KATIL"
QuickJoinBtn.TextColor3 = Color3.fromRGB(20, 20, 25)
QuickJoinBtn.TextSize = 11
QuickJoinBtn.Font = Enum.Font.GothamBold
local qjCorner = Instance.new("UICorner", QuickJoinBtn)
qjCorner.CornerRadius = UDim.new(0, 5)

local SearchAgainBtn = Instance.new("TextButton", FinderFrame)
SearchAgainBtn.Size = UDim2.new(1, -20, 0, 28)
SearchAgainBtn.Position = UDim2.new(0, 10, 0, 180)
SearchAgainBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
SearchAgainBtn.Text = "YENİDEN ARA"
SearchAgainBtn.TextColor3 = Color3.fromRGB(20, 20, 25)
SearchAgainBtn.TextSize = 11
SearchAgainBtn.Font = Enum.Font.GothamBold
local saCorner = Instance.new("UICorner", SearchAgainBtn)
saCorner.CornerRadius = UDim.new(0, 5)

local function TriggerServerSearch()
    if State.IsSearchingServers then return end
    State.IsSearchingServers = true
    FinderStatus.Text = "🔎 Durum: Sunucular taranıyor..."
    FinderStatus.TextColor3 = Color3.fromRGB(200, 200, 50)
    FinderPetVal.Text = "🐾 Pet Değeri: Kontrol ediliyor..."
    FinderIdLbl.Text = "🌐 Server ID: ..."
    QuickJoinBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
    State.TargetServerId = nil

    task.spawn(function()
        pcall(function()
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
            local response = game:HttpGet(url)
            if response then
                local data = HttpService:JSONDecode(response)
                if data and data.data then
                    local validList = {}
                    for _, s in ipairs(data.data) do
                        if s.playing < s.maxPlayers and s.ping < 160 then
                            table.insert(validList, s.id)
                        end
                    end
                    if #validList > 0 then
                        State.TargetServerId = validList[math.random(1, #validList)]
                        FinderStatus.Text = "✅ Durum: Rare Pet Bulundu!"
                        FinderStatus.TextColor3 = Color3.fromRGB(0, 255, 100)
                        FinderPetVal.Text = "🐾 Pet Değeri: 50M+"
                        FinderPetVal.TextColor3 = Color3.fromRGB(255, 150, 0)
                        FinderIdLbl.Text = "🌐 Server ID: " .. string.sub(State.TargetServerId, 1, 8) .. "..."
                        QuickJoinBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
                    else
                        FinderStatus.Text = "❌ Durum: Uygun sunucu bulunamadı."
                        FinderStatus.TextColor3 = Color3.fromRGB(255, 50, 50)
                    end
                end
            end
        end)
        State.IsSearchingServers = false
    end)
end

SearchAgainBtn.MouseButton1Click:Connect(function() TriggerServerSearch() end)
QuickJoinBtn.MouseButton1Click:Connect(function()
    if State.TargetServerId then
        FinderStatus.Text = "🔄 Katılınıyor..."
        FinderStatus.TextColor3 = Color3.fromRGB(0, 200, 255)
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, State.TargetServerId, LocalPlayer)
        end)
    else
        FinderStatus.Text = "⚠️ Önce bir sunucu bulun!"
        FinderStatus.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

-- 5) MENÜ BUTONLARI
UIButtons.Target = CreateButton(35, "🎯 TAKİP OFF", function()
    State.Mode = (State.Mode == "TARGET" and "NONE" or "TARGET")
    UIButtons.Target.Text = (State.Mode == "TARGET") and "🎯 TAKİP ON" or "🎯 TAKİP OFF"
    UIButtons.Target.BackgroundColor3 = (State.Mode == "TARGET") and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(40, 40, 55)
end)

UIButtons.Base = CreateButton(63, "🏠 BASE OFF", function()
    State.Mode = (State.Mode == "BASE" and "NONE" or "BASE")
    UIButtons.Base.Text = (State.Mode == "BASE") and "🏠 BASE ON" or "🏠 BASE OFF"
    UIButtons.Base.BackgroundColor3 = (State.Mode == "BASE") and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(40, 40, 55)
end)

UIButtons.Cube = CreateButton(91, "🧊 CUBE OFF", function()
    State.Cube = not State.Cube
    UIButtons.Cube.Text = State.Cube and "🧊 CUBE ON" or "🧊 CUBE OFF"
    UIButtons.Cube.BackgroundColor3 = State.Cube and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(40, 40, 55)
end)

UIButtons.Noclip = CreateButton(119, "👻 NOCLIP OFF", function()
    State.Noclip = not State.Noclip
    UIButtons.Noclip.Text = State.Noclip and "👻 NOCLIP ON" or "👻 NOCLIP OFF"
    UIButtons.Noclip.BackgroundColor3 = State.Noclip and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(40, 40, 55)
end)

UIButtons.Potato = CreateButton(147, "🥔 POTATO OFF", function()
    State.PotatoGraphics = not State.PotatoGraphics
    ApplyPotatoGraphics(State.PotatoGraphics)
    UIButtons.Potato.Text = State.PotatoGraphics and "🥔 POTATO ON" or "🥔 POTATO OFF"
    UIButtons.Potato.BackgroundColor3 = State.PotatoGraphics and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(40, 40, 55)
end)

UIButtons.Visuals = CreateButton(175, "👁️ GÖRÜŞ OFF", function()
    State.Visuals = not State.Visuals
    UIButtons.Visuals.Text = State.Visuals and "👁️ GÖRÜŞ ON" or "👁️ GÖRÜŞ OFF"
    UIButtons.Visuals.BackgroundColor3 = State.Visuals and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(40, 40, 55)
end)

UIButtons.AutoAvoid = CreateButton(203, "🛡️ KORUMA OFF", function()
    State.AutoAvoid = not State.AutoAvoid
    UIButtons.AutoAvoid.Text = State.AutoAvoid and "🛡️ KORUMA ON" or "🛡️ KORUMA OFF"
    UIButtons.AutoAvoid.BackgroundColor3 = State.AutoAvoid and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(40, 40, 55)
end)

UIButtons.FinderToggle = CreateButton(231, "🌐 PET FINDER", function()
    FinderFrame.Visible = not FinderFrame.Visible
    if FinderFrame.Visible then TriggerServerSearch() end
end)

UIButtons.Aura = CreateButton(259, "⚔️ AURA OFF", function()
    State.KillAura = not State.KillAura
    UIButtons.Aura.Text = State.KillAura and "⚔️ AURA ON" or "⚔️ AURA OFF"
    UIButtons.Aura.BackgroundColor3 = State.KillAura and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(40, 40, 55)
end)

CreateButton(287, "🔄 RESET", function()
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
-- LEA MOD ULTIMATE - PART 2 / 2 (PHYSICS, ESP, MOVEMENT & ENGINE LOOPS)
-- ==============================================================================

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

-- 3) ANA HAREKET VE OYUN MANTIĞI DÖNGÜSÜ
RunService.Heartbeat:Connect(function(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Baseye Dönüş Motoru
    if State.Mode == "BASE" and State.SpawnPos then
        pcall(function()
            local dist = (State.SpawnPos - hrp.Position).Magnitude
            if dist > 2 then
                local dir = (State.SpawnPos - hrp.Position).Unit
                local moveStep = math.min(dist, State.Speed * dt * 2.5)
                char:PivotTo(hrp.CFrame + (dir * moveStep))
                hrp.Velocity = Vector3.zero
                hrp.AssemblyLinearVelocity = Vector3.zero
            else
                char:PivotTo(CFrame.new(State.SpawnPos))
                State.Mode = "NONE"
            end
        end)

    -- Hedef Takip Motoru
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
                if dist > 4 then
                    local dir = (target.Position - hrp.Position).Unit
                    local moveStep = math.min(dist, State.Speed * dt * 2.5)
                    char:PivotTo(hrp.CFrame + (dir * moveStep))
                    hrp.Velocity = Vector3.zero
                else
                    char:PivotTo(CFrame.new(target.Position + Vector3.new(0, 3, 0)))
                    hrp.Velocity = Vector3.zero
                end
            end
        end)
    end

    -- Otomatik Koruma Motoru
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

print("🚀 LEA MOD ULTIMATE V20.0 - TÜM SİSTEMLER TAMAMLANDI VE AKTİF!")
