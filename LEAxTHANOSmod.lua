-- ==============================================================================
-- LEA MOD ULTIMATE MEGA V45.0 - DUEL EDITION (STEAL A BRIANROT) - PART 1/3
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

print("⭐ [LEA V45.0 DUEL PART 1/3]: GÜÇLÜ BYPASS VE TEMEL SİSTEM BAŞLATILIYOR...")

-- ==============================================================================
-- 1. GELİŞTİRİLMİŞ ULTRA BYPASS SİSTEMİ (GitHub & Topluluk Standartları)
-- ==============================================================================
pcall(function()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Anti-Kick ve Anti-Teleport Back
        if method == "Kick" or method == "kick" or method == "Teleport" then
            return nil
        end
        
        -- Gelişmiş Anti-Detection / Anti-Cheat FireServer Engelleme
        if tostring(method) == "FireServer" or tostring(method) == "InvokeServer" then
            local parent = self.Parent
            if parent then
                local parentName = parent.Name:lower()
                if parentName:find("anticheat") or 
                   parentName:find("ban") or 
                   parentName:find("report") or 
                   parentName:find("detect") or
                   parentName:find("mod") or
                   parentName:find("admin") or
                   parentName:find("ac") then
                    return nil
                end
            end
        end
        
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end)

-- ==============================================================================
-- 2. GLOBAL STATE OLUŞTURMA
-- ==============================================================================
if not getgenv().LeaModGlobalState then
    getgenv().LeaModGlobalState = {
        Version = "45.0-DUEL-ULTIMATE",
        Speed = 16,
        MoveSpeedIndex = 1,
        Fly = false,
        FlySpeed = 19, -- 19-21 Güvenli aralık
        CubeActive = false,
        CubeList = {},
        LastCubeTime = 0,
        ThemeColor = Color3.fromRGB(0, 255, 200),
        Connections = {},
        EspActive = false,
        Visuals = false,
        DuelMode = false,
        AutoAttack = false,
        SpawnPosition = nil,
        TargetPlayer = nil,
        PetEquipped = false,
        LastMedusaTime = 0,
        MedusaCooldown = 2.0,
        IsProtected = true,
        LastHealthCheck = 0
    }
end
local State = getgenv().LeaModGlobalState

print("✅ [PART 1/3]: State oluşturuldu - Versiyon: " .. State.Version)

-- ==============================================================================
-- 3. BAĞLANTI TEMİZLİĞİ
-- ==============================================================================
for _, conn in ipairs(State.Connections) do
    pcall(function() conn:Disconnect() end)
end
State.Connections = {}

-- ==============================================================================
-- 4. KARAKTER KORUMA SİSTEMİ
-- ==============================================================================
local function ProtectCharacter(character)
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        humanoid = character:WaitForChild("Humanoid", 10)
    end
    
    if humanoid then
        humanoid.BreakJointsOnDeath = false
        
        local healthConn = humanoid.HealthChanged:Connect(function(health)
            if health <= 0 then
                State.Fly = false
                State.CubeActive = false
                State.AutoAttack = false
                State.DuelMode = false
                
                for _, cube in ipairs(State.CubeList) do
                    if cube and cube.Parent then
                        pcall(function() cube:Destroy() end)
                    end
                end
                State.CubeList = {}
                
                pcall(function()
                    humanoid.Health = 100
                end)
                
                print("🛡️ [KORUMA]: Karakter ölümden korundu!")
            end
        end)
        table.insert(State.Connections, healthConn)
    end
end

if LocalPlayer.Character then
    ProtectCharacter(LocalPlayer.Character)
end
table.insert(State.Connections, LocalPlayer.CharacterAdded:Connect(ProtectCharacter))

-- ==============================================================================
-- 5. SPAWN KONUMU TESPİTİ (5 Saniye Sonra)
-- ==============================================================================
print("⏳ [PART 1/3]: 5 saniye içinde spawn konumu tespit ediliyor...")
task.wait(5)

pcall(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        State.SpawnPosition = LocalPlayer.Character.HumanoidRootPart.Position
        print("📍 [PART 1/3]: SPAWN KONUMU KAYDEDILDI: " .. tostring(State.SpawnPosition))
    else
        warn("⚠️ [PART 1/3]: Spawn konumu tespit edilemedi, yedek konum atanıyor.")
        State.SpawnPosition = Vector3.new(0, 5, 0)
    end
end)

-- ==============================================================================
-- 6. OYUNCU TESPİT FONKSİYONU
-- ==============================================================================
function GetNearestPlayer(maxDistance)
    local nearest = nil
    local shortestDistance = maxDistance or 60
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            
            if hrp and humanoid and humanoid.Health > 0 then
                local myChar = LocalPlayer.Character
                if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                    local distance = (myChar.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        nearest = player
                    end
                end
            end
        end
    end
    
    return nearest
end

print("✅ [PART 1/3 TAMAMLANDI]: Temel sistem hazır!")
-- ==============================================================================
-- LEA MOD ULTIMATE MEGA V45.0 - DUEL EDITION (STEAL A BRIANROT) - PART 2/3
-- ==============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

if not getgenv().LeaModGlobalState then
    warn("❌ [HATA]: Part 1 çalıştırılmamış! Önce Part 1'i çalıştırın.")
    return
end
local State = getgenv().LeaModGlobalState

print("⭐ [LEA V45.0 DUEL PART 2/3]: FONKSİYONLAR YÜKLENİYOR...")

-- ==============================================================================
-- 1. TOOL/PET BULMA VE EKİPMANLAMA
-- ==============================================================================
function FindAndEquipTool(toolName)
    local character = LocalPlayer.Character
    if not character then return false end
    
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            local toolLower = tool.Name:lower()
            if toolLower:find(toolName:lower()) then
                return true
            end
        end
    end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local toolLower = tool.Name:lower()
                if toolLower:find(toolName:lower()) then
                    local equipped = false
                    pcall(function()
                        tool.Parent = character
                        equipped = true
                    end)
                    if equipped then
                        task.wait(0.03)
                        return true
                    end
                end
            end
        end
    end
    
    return false
end

-- ==============================================================================
-- 2. MEDUSA KULLANMA SİSTEMİ (Anti-Ban Korumalı)
-- ==============================================================================
function UseMedusa()
    local now = tick()
    if now - State.LastMedusaTime < State.MedusaCooldown then
        return false
    end
    
    local character = LocalPlayer.Character
    if not character then return false end
    
    local medusaTool = nil
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():find("medusa") then
            medusaTool = tool
            break
        end
    end
    
    if not medusaTool then
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and tool.Name:lower():find("medusa") then
                    pcall(function() tool.Parent = character end)
                    task.wait(0.05)
                    medusaTool = character:FindFirstChild(tool.Name)
                    break
                end
            end
        end
    end
    
    if medusaTool then
        local activated = false
        pcall(function()
            medusaTool:Activate()
            activated = true
        end)
        
        if activated then
            State.LastMedusaTime = now
            print("🐍 [MEDUSA]: Anlık tetiklendi!")
            return true
        end
    end
    
    return false
end

-- ==============================================================================
-- 3. GÜVENLİ SPAWN'A DÖNÜŞ SİSTEMİ (19-21 Hız Sınırı)
-- ==============================================================================
function ReturnToSpawn()
    if not State.SpawnPosition then return false end
    
    local character = LocalPlayer.Character
    if not character then return false end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local wasFlying = State.Fly
    State.Fly = false
    
    local flySpeed = math.random(19, 21) / 10
    local startPos = hrp.Position
    local targetPos = State.SpawnPosition + Vector3.new(0, 3, 0)
    local distance = (targetPos - startPos).Magnitude
    
    if distance < 2 then return true end
    
    local startTime = tick()
    local duration = math.max(distance / (flySpeed * 10), 0.5)
    
    while tick() - startTime < duration do
        task.wait()
        if not character or not character:FindFirstChild("HumanoidRootPart") then break end
        
        local alpha = math.min((tick() - startTime) / duration, 1)
        local currentPos = startPos:Lerp(targetPos, alpha)
        
        pcall(function()
            character.HumanoidRootPart.CFrame = CFrame.new(currentPos)
            character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        end)
    end
    
    pcall(function()
        character.HumanoidRootPart.CFrame = CFrame.new(State.SpawnPosition + Vector3.new(0, 2, 0))
        character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
    end)
    
    if wasFlying then
        State.Fly = true
    end
    
    print("✅ [SPAWN]: Güvenli dönüş yapıldı!")
    return true
end

-- ==============================================================================
-- 4. CUBE SİSTEMİ
-- ==============================================================================
function ClearAllCubes()
    for _, cube in ipairs(State.CubeList) do
        if cube and cube.Parent then pcall(function() cube:Destroy() end) end
    end
    State.CubeList = {}
end

function CreateCube(position)
    if #State.CubeList > 12 then
        local oldCube = table.remove(State.CubeList, 1)
        if oldCube and oldCube.Parent then pcall(function() oldCube:Destroy() end) end
    end
    
    local cube = Instance.new("Part")
    cube.Name = "LeaCube"
    cube.Size = Vector3.new(4, 0.5, 4)
    cube.Position = position
    cube.Anchored = true
    cube.CanCollide = true
    cube.Transparency = 0.8
    cube.Material = Enum.Material.SmoothPlastic
    cube.Color = Color3.fromRGB(0, 170, 255)
    cube.Parent = Workspace
    
    table.insert(State.CubeList, cube)
    return cube
end

getgenv().LeaFindAndEquipTool = FindAndEquipTool
getgenv().LeaUseMedusa = UseMedusa
getgenv().LeaReturnToSpawn = ReturnToSpawn
getgenv().LeaClearCubes = ClearAllCubes
getgenv().LeaCreateCube = CreateCube

print("✅ [PART 2/3 TAMAMLANDI]: Fonksiyonlar yüklendi!")
-- ==============================================================================
-- LEA MOD ULTIMATE MEGA V45.0 - DUEL EDITION (STEAL A BRIANROT) - PART 3/3
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

if not getgenv().LeaModGlobalState then
    warn("❌ [HATA]: Part 1 çalıştırılmamış! Önce Part 1'i çalıştırın.")
    return
end
local State = getgenv().LeaModGlobalState

print("⭐ [LEA V45.0 DUEL PART 3/3]: GUI VE DÖNGÜ BAŞLATILIYOR...")

-- GUI Kurulumu
local function GetGuiParent()
    local success, parent = pcall(function() return CoreGui end)
    if success and parent then return parent end
    return LocalPlayer:WaitForChild("PlayerGui", 5)
end

pcall(function()
    local parentObj = GetGuiParent()
    if parentObj then
        local existing = parentObj:FindFirstChild("LeaModMegaGUI")
        if existing then existing:Destroy() end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LeaModMegaGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = GetGuiParent()

-- Watermark
local ActiveWatermark = Instance.new("TextLabel", ScreenGui)
ActiveWatermark.Name = "LeaActiveWatermark"
ActiveWatermark.Size = UDim2.new(0, 200, 0, 20)
ActiveWatermark.Position = UDim2.new(0.5, -100, 0.16, -10)
ActiveWatermark.BackgroundTransparency = 1
ActiveWatermark.Text = "⚡ LEA V45 ULTIMATE DUEL ⚡"
ActiveWatermark.TextColor3 = State.ThemeColor
ActiveWatermark.TextSize = 10
ActiveWatermark.Font = Enum.Font.GothamBlack
ActiveWatermark.Visible = false
ActiveWatermark.TextStrokeTransparency = 0.3

-- Ana Konteyner
local MainContainer = Instance.new("Frame", ScreenGui)
MainContainer.Size = UDim2.new(0, 130, 0, 165)
MainContainer.Position = UDim2.new(0.5, -65, 0.5, -82)
MainContainer.BackgroundColor3 = Color3.fromRGB(6, 6, 10)
MainContainer.BackgroundTransparency = 0.05
MainContainer.BorderSizePixel = 0
MainContainer.Active = true
MainContainer.Draggable = true

local MainCorner = Instance.new("UICorner", MainContainer)
MainCorner.CornerRadius = UDim.new(0, 5)
local MainStroke = Instance.new("UIStroke", MainContainer)
MainStroke.Color = State.ThemeColor
MainStroke.Thickness = 1

local HeaderFrame = Instance.new("Frame", MainContainer)
HeaderFrame.Size = UDim2.new(1, 0, 0, 18)
HeaderFrame.BackgroundColor3 = Color3.fromRGB(3, 3, 6)
HeaderFrame.BorderSizePixel = 0

local TitleLabel = Instance.new("TextLabel", HeaderFrame)
TitleLabel.Size = UDim2.new(1, -18, 1, 0)
TitleLabel.Position = UDim2.new(0, 4, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "LEA DUEL V45"
TitleLabel.TextColor3 = State.ThemeColor
TitleLabel.TextSize = 8
TitleLabel.Font = Enum.Font.GothamBlack

local CloseButton = Instance.new("TextButton", HeaderFrame)
CloseButton.Size = UDim2.new(0, 14, 0, 14)
CloseButton.Position = UDim2.new(1, -16, 0, 2)
CloseButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 7

local ScrollContainer = Instance.new("ScrollingFrame", MainContainer)
ScrollContainer.Size = UDim2.new(1, -6, 1, -22)
ScrollContainer.Position = UDim2.new(0, 3, 0, 20)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.ScrollBarThickness = 2
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 200)

local ButtonListLayout = Instance.new("UIListLayout", ScrollContainer)
ButtonListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ButtonListLayout.Padding = UDim.new(0, 4)
ButtonListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 28, 0, 28)
ToggleBtn.Position = UDim2.new(1, -34, 0.5, -14)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(6, 6, 10)
ToggleBtn.Text = "LEA"
ToggleBtn.TextColor3 = State.ThemeColor
ToggleBtn.TextSize = 8
ToggleBtn.Visible = false

CloseButton.MouseButton1Click:Connect(function()
    MainContainer.Visible = false
    ToggleBtn.Visible = true
    ActiveWatermark.Visible = true
end)

ToggleBtn.MouseButton1Click:Connect(function()
    MainContainer.Visible = true
    ToggleBtn.Visible = false
    ActiveWatermark.Visible = false
end)

-- Buton oluşturucular
local function CreateMenuButton(order, text, defaultColor, activeColor, callback)
    local btn = Instance.new("TextButton", ScrollContainer)
    btn.LayoutOrder = order
    btn.Size = UDim2.new(1, -2, 0, 21)
    btn.BackgroundColor3 = defaultColor
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 8
    btn.Font = Enum.Font.GothamBold
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 4)
    
    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = active and activeColor or defaultColor}):Play()
        pcall(function() callback(active, btn) end)
    end)
    return btn
end

local function CreateActionItem(order, text, color, callback)
    local btn = Instance.new("TextButton", ScrollContainer)
    btn.LayoutOrder = order
    btn.Size = UDim2.new(1, -2, 0, 21)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 8
    btn.Font = Enum.Font.GothamBold
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 4)
    
    btn.MouseButton1Click:Connect(function() pcall(callback) end)
    return btn
end

-- Menü Butonları
CreateMenuButton(1, "🎯 DUEL FLY OFF", Color3.fromRGB(45, 35, 65), Color3.fromRGB(0, 180, 90), function(on, btn)
    State.Fly = on
    State.DuelMode = on
    btn.Text = on and "🎯 DUEL FLY ON" or "🎯 DUEL FLY OFF"
end)

CreateMenuButton(2, "⚔️ AUTO ATTACK OFF", Color3.fromRGB(45, 25, 25), Color3.fromRGB(255, 50, 50), function(on, btn)
    State.AutoAttack = on
    btn.Text = on and "⚔️ AUTO ATTACK ON" or "⚔️ AUTO ATTACK OFF"
end)

CreateActionItem(3, "🏠 SPAWN'A DÖN", Color3.fromRGB(30, 30, 45), function()
    if getgenv().LeaReturnToSpawn then getgenv().LeaReturnToSpawn() end
end)

CreateMenuButton(4, "🧊 CUBE OFF", Color3.fromRGB(35, 55, 55), Color3.fromRGB(0, 180, 90), function(on, btn)
    State.CubeActive = on
    btn.Text = on and "🧊 CUBE ON" or "🧊 CUBE OFF"
    if not on and getgenv().LeaClearCubes then getgenv().LeaClearCubes() end
end)

CreateActionItem(5, "⚡ HIZ: 16", Color3.fromRGB(30, 30, 45), function()
    State.MoveSpeedIndex = State.MoveSpeedIndex + 1
    if State.MoveSpeedIndex > 3 then State.MoveSpeedIndex = 1 end
    local speeds = {16, 19, 21}
    State.Speed = speeds[State.MoveSpeedIndex]
    for _, child in ipairs(ScrollContainer:GetChildren()) do
        if child:IsA("TextButton") and child.Text:find("HIZ:") then
            child.Text = "⚡ HIZ: " .. State.Speed
            break
        end
    end
end)

CreateMenuButton(6, "👁️ ESP OFF", Color3.fromRGB(35, 35, 48), Color3.fromRGB(0, 180, 90), function(on, btn)
    State.Visuals = on
    State.EspActive = on
    btn.Text = on and "👁️ ESP ON" or "👁️ ESP OFF"
end)

-- ==============================================================================
-- ANA OYUN DÖNGÜSÜ (Bypass, Auto-Attack, Medusa & Hız Senkronizasyonu)
-- ==============================================================================
table.insert(State.Connections, RunService.Heartbeat:Connect(function(dt)
    local character = LocalPlayer.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end
    
    if humanoid.Health <= 0 then
        State.Fly = false
        State.CubeActive = false
        State.AutoAttack = false
        if getgenv().LeaClearCubes then getgenv().LeaClearCubes() end
        return
    end
    
    if humanoid.WalkSpeed ~= State.Speed then
        pcall(function() humanoid.WalkSpeed = State.Speed end)
    end
    
    -- Cube Üretimi
    if State.CubeActive and getgenv().LeaCreateCube then
        local now = tick()
        local velocity = hrp.AssemblyLinearVelocity
        if (velocity.Y < -5 or velocity.Magnitude > 2) and (now - State.LastCubeTime > 0.25) then
            getgenv().LeaCreateCube(hrp.Position - Vector3.new(0, 3, 0))
            State.LastCubeTime = now
        end
    end
    
    -- Duel Fly & Auto Attack / Medusa Mantığı
    if State.Fly and State.DuelMode then
        local target = GetNearestPlayer(80)
        
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            State.TargetPlayer = target
            local targetHrp = target.Character.HumanoidRootPart
            local targetHum = target.Character:FindFirstChildOfClass("Humanoid")
            
            if targetHum and targetHum.Health > 0 then
                humanoid.PlatformStand = true
                
                local targetPos = targetHrp.Position
                local offset = Vector3.new(0, 3.0, -1.5)
                local desiredPos = targetPos + offset
                
                local distance = (desiredPos - hrp.Position).Magnitude
                
                -- Eğer düşman çok yakınsa veya pet almaya geldiyse anlık Medusa bas
                if distance < 12 and getgenv().LeaUseMedusa then
                    getgenv().LeaUseMedusa()
                end
                
                local flySpeed = math.min(distance * 3, State.FlySpeed)
                local direction = (desiredPos - hrp.Position).Unit
                
                hrp.AssemblyLinearVelocity = direction * flySpeed + Vector3.new(
                    math.random(-3, 3) / 100,
                    math.random(-2, 2) / 100,
                    math.random(-3, 3) / 100
                )
                
                -- Auto Attack & Pet Kontrolü
                if State.AutoAttack and getgenv().LeaFindAndEquipTool then
                    local hasTool = getgenv().LeaFindAndEquipTool("pet") or getgenv().LeaFindAndEquipTool("bad")
                    
                    if hasTool then
                        for _, tool in ipairs(character:GetChildren()) do
                            if tool:IsA("Tool") and (tool.Name:lower():find("pet") or tool.Name:lower():find("bad")) then
                                pcall(function() tool:Activate() end)
                                break
                            end
                        end
                    else
                        -- Pet elinde yoksa güvenli şekilde spawn'a kaçış
                        if getgenv().LeaReturnToSpawn then
                            getgenv().LeaReturnToSpawn()
                        end
                    end
                end
            end
        else
            humanoid.PlatformStand = false
        end
    end
end))

print("✅ [PART 3/3 TAMAMLANDI]: GUI ve Tüm Sistemler Aktif!")
