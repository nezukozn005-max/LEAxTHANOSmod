-- ==============================================================================
-- LEA MOD ULTIMATE MEGA V50.0 - PART 1/2 (TEMEL SİSTEM & GÜVENLI BYPASS)
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

print("⭐ [LEA V50.0 ULTIMATE PART 1]: SİSTEM BAŞLATILIYOR...")

-- ==============================================================================
-- 1. GLOBAL STATE YÖNETİMİ (ÖNCELİK SİRASI DEĞİŞTİRİLDİ)
-- ==============================================================================
if not getgenv().LeaModGlobalState then
    getgenv().LeaModGlobalState = {
        Version = "50.0-ULTIMATE-PERFECT",
        Speed = 16,
        MoveSpeedIndex = 1,
        AutoAttack = false,
        AutoAttackLastTime = 0,
        AutoAttackCooldown = 0.5,
        CubeActive = false,
        CubeList = {},
        LastCubeTime = 0,
        CubeSpawnRate = 0.35,
        CubeLimit = 25,
        ThemeColor = Color3.fromRGB(0, 255, 200),
        Connections = {},
        EspActive = false,
        Visuals = false,
        AutoMedusa = false,
        AutoMedusaLastTime = 0,
        MedusaCooldown = 0.8,
        InfiniteJump = false,
        InfiniteJumpActive = false,
        SpawnPosition = nil,
        TargetPlayer = nil,
        IsProtected = true,
        Noclip = false,
        NoclipLastTime = 0,
        NoclipDebounce = 0.05
    }
end
local State = getgenv().LeaModGlobalState

-- Önceki bağlantıları temizle
for _, conn in ipairs(State.Connections) do
    pcall(function() conn:Disconnect() end)
end
State.Connections = {}

-- ==============================================================================
-- 2. GİZLİ HIZ VE GÜVENLI BYPASS KATMANI (DYNAMIC)
-- ==============================================================================
pcall(function()
    if hookmetamethod then
        -- ✅ FİKS 1: WalkSpeed Dynamic (State.Speed'i döndür)
        local oldIndex
        oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
            if not checkcaller() and self:IsA("Humanoid") and key == "WalkSpeed" then
                return State.Speed  -- ✅ SABÎT DEĞİL, STATE'DEN DÖNDÜR
            end
            return oldIndex(self, key)
        end))

        -- Anti-Kick ve Remote Bloğu (Geliştirilmiş)
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()
            
            if not checkcaller() then
                -- 1. Kick metodlarını engelle
                if method == "Kick" or method == "kick" then
                    return nil
                end
                
                -- 2. Server remotelarını kontrol et (Geliştirilmiş filter)
                if method == "FireServer" or method == "InvokeServer" then
                    local remoteName = tostring(self.Name):lower()
                    
                    -- Tehlikeli remote'ları engelle
                    local banWords = {
                        "anticheat", "banremote", "cheatdetect", "punishplayer",
                        "kickplayer", "kickclient", "ban", "detect", "detect_cheat",
                        "admin_kick", "server_kick", "violation", "hack"
                    }
                    
                    for _, word in ipairs(banWords) do
                        if remoteName:find(word) then
                            return nil
                        end
                    end
                end
            end
            
            return oldNamecall(self, ...)
        end))
    end
end)

-- ==============================================================================
-- 3. STABİL KARAKTER YÖNETİMİ
-- ==============================================================================
local function ProtectCharacter(character)
    if not character then return end
    local humanoid = character:WaitForChild("Humanoid", 5)
    if humanoid then
        local diedConn = humanoid.Died:Connect(function()
            State.AutoAttack = false
            State.CubeActive = false
            State.Noclip = false
            State.InfiniteJump = false
            for _, cube in ipairs(State.CubeList) do
                if cube and cube.Parent then pcall(function() cube:Destroy() end) end
            end
            State.CubeList = {}
        end)
        table.insert(State.Connections, diedConn)
    end
end

if LocalPlayer.Character then ProtectCharacter(LocalPlayer.Character) end
table.insert(State.Connections, LocalPlayer.CharacterAdded:Connect(ProtectCharacter))

-- ==============================================================================
-- 4. SPAWN TESPİTİ
-- ==============================================================================
task.spawn(function()
    task.wait(2)
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            State.SpawnPosition = LocalPlayer.Character.HumanoidRootPart.Position
        else
            State.SpawnPosition = Vector3.new(0, 5, 0)
        end
    end)
end)

-- ==============================================================================
-- 5. YARDIMCI FONKSİYONLAR
-- ==============================================================================

--- ✅ FİKS: Tüm fonksiyonları State'e kaydet
function FindAndEquipTool(toolName)
    local character = LocalPlayer.Character
    if not character then return false end
    
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():find(toolName:lower()) then
            return true
        end
    end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower():find(toolName:lower()) then
                pcall(function() tool.Parent = character end)
                task.wait(0.02)
                return true
            end
        end
    end
    return false
end

function UseMedusa()
    local now = tick()
    if now - State.AutoMedusaLastTime < State.MedusaCooldown then return false end
    
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
                    task.wait(0.04)
                    medusaTool = character:FindFirstChild(tool.Name)
                    break
                end
            end
        end
    end
    
    if medusaTool then
        pcall(function() medusaTool:Activate() end)
        State.AutoMedusaLastTime = now
        return true
    end
    return false
end

function ReturnToSpawnFast()
    if not State.SpawnPosition then return end
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local startPos = hrp.Position
    local targetPos = State.SpawnPosition + Vector3.new(0, 3, 0)
    local distance = (targetPos - startPos).Magnitude
    if distance < 2 then return end
    
    local startTime = tick()
    local duration = math.clamp(distance / 50, 0.2, 0.8)
    
    while tick() - startTime < duration do
        task.wait()
        if not character or not character:FindFirstChild("HumanoidRootPart") then break end
        local alpha = math.min((tick() - startTime) / duration, 1)
        pcall(function()
            character.HumanoidRootPart.CFrame = CFrame.new(startPos:Lerp(targetPos, alpha))
            character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        end)
    end
    
    pcall(function()
        character.HumanoidRootPart.CFrame = CFrame.new(targetPos)
        character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
    end)
end

function GetNearestPlayer(maxDistance)
    local nearest = nil
    local shortestDistance = maxDistance or 60
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local myChar = LocalPlayer.Character
                if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                    local dist = (myChar.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
                        nearest = player
                    end
                end
            end
        end
    end
    return nearest
end

-- ✅ FİKS: Fonksiyonları State'e kaydet (Part 2'de kullanabilmek için)
State.FindAndEquipTool = FindAndEquipTool
State.UseMedusa = UseMedusa
State.ReturnToSpawnFast = ReturnToSpawnFast
State.GetNearestPlayer = GetNearestPlayer

print("✅ [PART 1 TAMAMLANDI]: Part 2'yi çalıştırabilirsiniz.")-- ==============================================================================
-- LEA MOD ULTIMATE MEGA V50.0 - PART 2/2 (GUI VE OYUN DÖNGÜSÜ - PERFECT)
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

if not getgenv().LeaModGlobalState then
    warn("❌ [HATA]: Önce Part 1 çalıştırılmalıdır!")
    return
end
local State = getgenv().LeaModGlobalState

print("⭐ [LEA V50.0 ULTIMATE PART 2]: ARAYÜZ VE DÖNGÜLER YÜKLENİYOR...")

-- ==============================================================================
-- 1. GUI KURULUMU
-- ==============================================================================

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

local ActiveWatermark = Instance.new("TextLabel", ScreenGui)
ActiveWatermark.Name = "LeaActiveWatermark"
ActiveWatermark.Size = UDim2.new(0, 220, 0, 20)
ActiveWatermark.Position = UDim2.new(0.5, -110, 0.15, -10)
ActiveWatermark.BackgroundTransparency = 1
ActiveWatermark.Text = "⚡ LEA V50 ULTIMATE DUEL MODS ⚡"
ActiveWatermark.TextColor3 = State.ThemeColor
ActiveWatermark.TextSize = 10
ActiveWatermark.Font = Enum.Font.GothamBlack
ActiveWatermark.Visible = false
ActiveWatermark.TextStrokeTransparency = 0.3

local MainContainer = Instance.new("Frame", ScreenGui)
MainContainer.Size = UDim2.new(0, 145, 0, 210)
MainContainer.Position = UDim2.new(0.5, -72, 0.5, -105)
MainContainer.BackgroundColor3 = Color3.fromRGB(6, 6, 10)
MainContainer.BackgroundTransparency = 0.05
MainContainer.BorderSizePixel = 0
MainContainer.Active = true
MainContainer.Draggable = true

local MainCorner = Instance.new("UICorner", MainContainer)
MainCorner.CornerRadius = UDim.new(0, 6)
local MainStroke = Instance.new("UIStroke", MainContainer)
MainStroke.Color = State.ThemeColor
MainStroke.Thickness = 1

local HeaderFrame = Instance.new("Frame", MainContainer)
HeaderFrame.Size = UDim2.new(1, 0, 0, 20)
HeaderFrame.BackgroundColor3 = Color3.fromRGB(3, 3, 6)
HeaderFrame.BorderSizePixel = 0

local TitleLabel = Instance.new("TextLabel", HeaderFrame)
TitleLabel.Size = UDim2.new(1, -20, 1, 0)
TitleLabel.Position = UDim2.new(0, 5, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "LEA V50 ULTIMATE"
TitleLabel.TextColor3 = State.ThemeColor
TitleLabel.TextSize = 8
TitleLabel.Font = Enum.Font.GothamBlack

local CloseButton = Instance.new("TextButton", HeaderFrame)
CloseButton.Size = UDim2.new(0, 16, 0, 16)
CloseButton.Position = UDim2.new(1, -18, 0, 2)
CloseButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 7

local ScrollContainer = Instance.new("ScrollingFrame", MainContainer)
ScrollContainer.Size = UDim2.new(1, -6, 1, -24)
ScrollContainer.Position = UDim2.new(0, 3, 0, 22)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.ScrollBarThickness = 2
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 280)

local ButtonListLayout = Instance.new("UIListLayout", ScrollContainer)
ButtonListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ButtonListLayout.Padding = UDim.new(0, 4)
ButtonListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 30, 0, 30)
ToggleBtn.Position = UDim2.new(1, -36, 0.5, -15)
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

-- ==============================================================================
-- 2. BUTON OLUŞTURMA FONKSİYONLARI
-- ==============================================================================

local function CreateMenuButton(order, text, defaultColor, activeColor, callback)
    local btn = Instance.new("TextButton", ScrollContainer)
    btn.LayoutOrder = order
    btn.Size = UDim2.new(1, -2, 0, 22)
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
    btn.Size = UDim2.new(1, -2, 0, 22)
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

-- ==============================================================================
-- 3. MENÜ ELEMANLAARI
-- ==============================================================================

CreateMenuButton(1, "⚔️ AUTO ATTACK OFF", Color3.fromRGB(45, 25, 25), Color3.fromRGB(255, 50, 50), function(on, btn)
    State.AutoAttack = on
    State.AutoAttackLastTime = tick()
    btn.Text = on and "⚔️ AUTO ATTACK ON" or "⚔️ AUTO ATTACK OFF"
end)

CreateMenuButton(2, "🐍 AUTO MEDUSA OFF", Color3.fromRGB(35, 45, 35), Color3.fromRGB(0, 180, 90), function(on, btn)
    State.AutoMedusa = on
    State.AutoMedusaLastTime = tick()
    btn.Text = on and "🐍 AUTO MEDUSA ON" or "🐍 AUTO MEDUSA OFF"
end)

CreateActionItem(3, "🏠 HIZLI BASE'E DÖN", Color3.fromRGB(30, 30, 45), function()
    State.ReturnToSpawnFast()
end)

CreateMenuButton(4, "🧊 CUBE PLATFORM OFF", Color3.fromRGB(35, 55, 55), Color3.fromRGB(0, 180, 90), function(on, btn)
    State.CubeActive = on
    btn.Text = on and "🧊 CUBE PLATFORM ON" or "🧊 CUBE PLATFORM OFF"
    if not on then
        for _, cube in ipairs(State.CubeList) do
            if cube and cube.Parent then pcall(function() cube:Destroy() end) end
        end
        State.CubeList = {}
    end
end)

CreateActionItem(5, "⚡ HIZ: 16", Color3.fromRGB(30, 30, 45), function()
    State.MoveSpeedIndex = State.MoveSpeedIndex + 1
    if State.MoveSpeedIndex > 4 then State.MoveSpeedIndex = 1 end
    local speeds = {16, 20, 24, 28}
    State.Speed = speeds[State.MoveSpeedIndex]
    
    for _, child in ipairs(ScrollContainer:GetChildren()) do
        if child:IsA("TextButton") and child.Text:find("HIZ:") then
            child.Text = "⚡ HIZ: " .. State.Speed
            break
        end
    end
end)

CreateMenuButton(6, "👻 NOCLIP OFF", Color3.fromRGB(45, 35, 55), Color3.fromRGB(150, 50, 200), function(on, btn)
    State.Noclip = on
    btn.Text = on and "👻 NOCLIP ON" or "👻 NOCLIP OFF"
end)

CreateMenuButton(7, "🚀 INF JUMP OFF", Color3.fromRGB(35, 35, 55), Color3.fromRGB(0, 150, 255), function(on, btn)
    State.InfiniteJump = on
    State.InfiniteJumpActive = false
    btn.Text = on and "🚀 INF JUMP ON" or "🚀 INF JUMP OFF"
end)

CreateMenuButton(8, "👁️ ESP OFF", Color3.fromRGB(35, 35, 48), Color3.fromRGB(0, 180, 90), function(on, btn)
    State.Visuals = on
    State.EspActive = on
    btn.Text = on and "👁️ ESP ON" or "👁️ ESP OFF"
    
    if not on then
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("LeaMegaESP") then
                p.Character.LeaMegaESP:Destroy()
            end
        end
    end
end)

-- ==============================================================================
-- 4. INFINITE JUMP KONTROL (✅ FİKS 7: KONTROLLÜ ZIPLAMA)
-- ==============================================================================

UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump and not State.InfiniteJumpActive then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then 
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                State.InfiniteJumpActive = true
            end
        end
    end
end)

-- ==============================================================================
-- 5. ANA OYUN DÖNGÜSÜ (PÜRÜZSÜZ & OPTİMİZE EDİLMİŞ)
-- ==============================================================================

table.insert(State.Connections, RunService.Heartbeat:Connect(function(dt)
    local character = LocalPlayer.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end
    
    -- ✅ FİKS 1: WalkSpeed Smooth (Sadece farklıysa ayarla)
    if humanoid.WalkSpeed ~= State.Speed then
        humanoid.WalkSpeed = State.Speed
    end
    
    -- ✅ FİKS 4: Noclip Debounce (CPU yükü azaltıldı)
    if State.Noclip then
        local now = tick()
        if now - State.NoclipLastTime >= State.NoclipDebounce then
            State.NoclipLastTime = now
            pcall(function()
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end)
        end
    end
    
    -- ✅ FİKS 5: Cube Platform (Optimize - daha az spawn)
    if State.CubeActive then
        local now = tick()
        local velocity = hrp.AssemblyLinearVelocity
        if (velocity.Y < -5 or velocity.Magnitude > 2) and (now - State.LastCubeTime > State.CubeSpawnRate) then
            if #State.CubeList > State.CubeLimit then
                local oldCube = table.remove(State.CubeList, 1)
                if oldCube and oldCube.Parent then pcall(function() oldCube:Destroy() end) end
            end
            
            local cube = Instance.new("Part")
            cube.Name = "LeaCube"
            cube.Size = Vector3.new(4, 0.5, 4)
            cube.Position = hrp.Position - Vector3.new(0, 3.2, 0)
            cube.Anchored = true
            cube.CanCollide = true
            cube.Transparency = 0.8
            cube.Material = Enum.Material.SmoothPlastic
            cube.Color = Color3.fromRGB(0, 170, 255)
            cube.Parent = Workspace
            table.insert(State.CubeList, cube)
            State.LastCubeTime = now
        end
    end
    
    -- Hedef bulma ve ability kontroller
    local nearestTarget = State.GetNearestPlayer(45)
    if nearestTarget and nearestTarget.Character and nearestTarget.Character:FindFirstChild("HumanoidRootPart") then
        local targetHrp = nearestTarget.Character.HumanoidRootPart
        local dist = (hrp.Position - targetHrp.Position).Magnitude
        
        -- Auto Medusa (Cooldown kontrollü)
        if State.AutoMedusa and dist <= 15 then
            State.UseMedusa()
        end
        
        -- ✅ FİKS 6: AutoAttack Debounce (Spam engellendi)
        if State.AutoAttack then
            local now = tick()
            if now - State.AutoAttackLastTime >= State.AutoAttackCooldown then
                State.AutoAttackLastTime = now
                local hasTool = State.FindAndEquipTool("pet") or State.FindAndEquipTool("bad")
                if hasTool then
                    for _, tool in ipairs(character:GetChildren()) do
                        if tool:IsA("Tool") and (tool.Name:lower():find("pet") or tool.Name:lower():find("bad")) then
                            pcall(function() tool:Activate() end)
                            break
                        end
                    end
                end
            end
        end
    end
    
    -- ✅ FİKS 8: InfiniteJump Kontrol (Jump state'i sıfırla)
    if State.InfiniteJump then
        if humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
            State.InfiniteJumpActive = false
        end
    end
end))

-- ==============================================================================
-- 6. ESP DÖNGÜSÜ (✅ FİKS 3: Memory Leak engellendi)
-- ==============================================================================

local espTimer = 0
table.insert(State.Connections, RunService.Heartbeat:Connect(function(dt)
    espTimer = espTimer + dt
    if espTimer >= 1.0 then
        espTimer = 0
        if State.Visuals and State.EspActive then
            pcall(function()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local char = player.Character
                        local highlight = char:FindFirstChild("LeaMegaESP")
                        
                        -- ✅ FİKS: Yeni highlight oluşturmak yerine mevcut güncelle
                        if not highlight then
                            highlight = Instance.new("Highlight")
                            highlight.Name = "LeaMegaESP"
                            highlight.FillColor = Color3.fromRGB(255, 0, 80)
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            highlight.FillTransparency = 0.5
                            highlight.OutlineTransparency = 0
                            highlight.Parent = char
                        end
                    end
                end
            end)
        end
    end
end))

print("✅ [LEA V50.0 ULTIMATE]: SİSTEM BAŞARIYLA YÜKLENDİ.")
print("📋 Tüm hatalar düzeltilmiştir!")
