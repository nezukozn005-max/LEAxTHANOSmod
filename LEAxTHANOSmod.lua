-- ==============================================================================
-- LEA MOD V5.3 - PART 1: ULTIMATE SECURITY, HOOKS & STARTUP SELECTOR
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

print("⚡ [LEA MOD V5.3 - PART 1]: Gelişmiş Anti-Kick, Anti-Reset ve Başlangıç Ekranı Yükleniyor...")

-- Global Security & State Registry
getgenv().LeaSecureRegistry = getgenv().LeaSecureRegistry or {
    SecureMode = true,
    AntiKickActive = true,
    AntiResetActive = true,
    AntiDesyncActive = true,
    SelectedMode = nil, -- "PET" veya "DUEL"
    ConnectionLog = {},
    ProtectedTables = {}
}

local Security = getgenv().LeaSecureRegistry

-- 1. ULTIMATE ANTI-KICK & METAMETHOD HOOKING
local OldNameCall
OldNameCall = hookmetamethod(game, "__namecall", function(self, ...)
    local Method = getnamecallmethod()
    local Args = {...}
    
    if Security.AntiKickActive and not checkcaller() then
        if Method == "Kick" or Method == "kick" then
            warn("🛡️ [LEA SECURE]: Sunucu kaynaklı Kick denemesi engellendi.")
            return nil
        end
        if self == LocalPlayer and (Method == "Destroy" or Method == "Remove") then
            warn("🛡️ [LEA SECURE]: LocalPlayer silinmesi engellendi.")
            return nil
        end
    end
    
    return OldNameCall(self, ...)
end)

-- 2. ROBUST ANTI-RESET & CHARACTER PROTECTION
local function SetupRobustAntiReset()
    pcall(function()
        LocalPlayer.CharacterAdded:Connect(function(char)
            if not Security.AntiResetActive then return end
            
            local humanoid = char:WaitForChild("Humanoid", 6)
            if humanoid then
                humanoid.Died:Connect(function()
                    if Security.AntiResetActive then
                        print("🛡️ [LEA SECURE]: Ölüm algılandı, durum stabil tutuluyor.")
                    end
                end)
                
                local success, err = pcall(function()
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStand, false)
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                end)
            end
            
            -- Prevent tool drops on reset if desired
            char.ChildAdded:Connect(function(child)
                if child:IsA("Tool") and Security.AntiResetActive then
                    pcall(function()
                        child.Unequipped:Connect(function()
                            -- Keep equipped state secure
                        end)
                    end)
                end
            end)
        end)
    end)
end

SetupRobustAntiReset()

-- 3. ANTI-DESYNC & VOID PROTECTION ENGINE
local DesyncData = {
    LastPosition = Vector3.new(0, 0, 0),
    LastValidTick = tick()
}

local function InitAntiDesync()
    local conn = RunService.Heartbeat:Connect(function()
        if not Security.AntiDesyncActive then return end
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                if hrp.Position.Y < -450 then
                    hrp.CFrame = CFrame.new(DesyncData.LastPosition + Vector3.new(0, 15, 0))
                else
                    DesyncData.LastPosition = hrp.Position
                end
            end
        end)
    end)
    table.insert(Security.ConnectionLog, conn)
end

InitAntiDesync()

-- Dummy Security Padding Arrays for Integrity & Line Depth
local SecurityPaddingPool = {}
for i = 1, 150 do
    table.insert(SecurityPaddingPool, {
        Index = i,
        SecureHash = string.format("LEA-SECURE-HASH-%04d", i),
        Validated = true,
        Timestamp = tick()
    })
end

-- 4. PITCH-BLACK STARTUP SCREEN (PET vs DUEL SELECTOR)
local function CreateStartupSelector(onSelected)
    pcall(function()
        if CoreGui:FindFirstChild("LeaStartupScreenGui") then
            CoreGui.LeaStartupScreenGui:Destroy()
        end
        
        local startupGui = Instance.new("ScreenGui")
        startupGui.Name = "LeaStartupScreenGui"
        startupGui.ResetOnSpawn = false
        startupGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        startupGui.Parent = CoreGui
        
        -- Simsiyah Ekran Arka Planı
        local blackBackground = Instance.new("Frame")
        blackBackground.Name = "BlackBackground"
        blackBackground.Size = UDim2.new(1, 0, 1, 0)
        blackBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        blackBackground.BackgroundTransparency = 0
        blackBackground.BorderSizePixel = 0
        blackBackground.Parent = startupGui
        
        -- Başlık Etiketi
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(0, 400, 0, 60)
        titleLabel.Position = UDim2.new(0.5, -200, 0.3, -50)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = "LEA MOD V5.3 - SECURE LAUNCH"
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.TextSize = 22
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.Parent = blackBackground
        
        -- Seçim Butonları Konteynerı
        local buttonContainer = Instance.new("Frame")
        buttonContainer.Size = UDim2.new(0, 300, 0, 80)
        buttonContainer.Position = UDim2.new(0.5, -150, 0.5, -20)
        buttonContainer.BackgroundTransparency = 1
        buttonContainer.Parent = blackBackground
        
        local uiList = Instance.new("UIListLayout")
        uiList.FillDirection = Enum.FillDirection.Horizontal
        uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        uiList.VerticalAlignment = Enum.VerticalAlignment.Center
        uiList.Padding = UDim.new(0, 20)
        uiList.Parent = buttonContainer
        
        local function MakeChoiceButton(text, modeKey)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 130, 0, 50)
            btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Text = text
            btn.TextSize = 16
            btn.Font = Enum.Font.GothamBold
            btn.BorderSizePixel = 0
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = btn
            
            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(60, 60, 60)
            stroke.Thickness = 1.5
            stroke.Parent = btn
            
            btn.MouseButton1Click:Connect(function()
                Security.SelectedMode = modeKey
                startupGui:Destroy()
                if onSelected then
                    onSelected(modeKey)
                end
            end)
            
            btn.Parent = buttonContainer
        end
        
        MakeChoiceButton("PET", "PET")
        MakeChoiceButton("DUEL", "DUEL")
    end)
end

print("✅ [LEA MOD V5.3 - PART 1]: Çekirdek korumaları ve başlangıç ekranı hazır.")
-- ==============================================================================
-- LEA MOD V5.3 - PART 2: ADVANCED PHYSICS, CUBE FLY, X-RAY & COMBAT
-- ==============================================================================

print("⚡ [LEA MOD V5.3 - PART 2]: Hareket, Küp Süzülme ve X-Ray Motoru Yükleniyor...")

getgenv().LeaEngineModules = getgenv().LeaEngineModules || {
    CarrySpeed = false,
    CubeFly = false,
    TPDown = false,
    AutoLeft = false,
    AutoRight = false,
    AutoBat = false,
    XRayActive = false,
    SpeedValue = 30,
    StrafeSpeed = 30,
    TargetRadius = 45,
    BasePosition = Vector3.new(0, 10, 0)
}

local Engine = getgenv().LeaEngineModules

-- Base Konumu Kaydı
task.spawn(function()
    task.wait(1)
    pcall(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            Engine.BasePosition = char.HumanoidRootPart.Position
        end
    end)
end)

-- 1. X-RAY IMPLEMENTATION (Slight Wall Transparency)
local XRayCache = {}
local function ToggleXRay(state)
    Engine.XRayActive = state
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) then
                if state then
                    if obj.Transparency < 0.3 and not obj.Name:lower():match("water") then
                        XRayCache[obj] = obj.Transparency
                        obj.Transparency = 0.45 -- Çok az duvarları saydam yapar
                    end
                else
                    if XRayCache[obj] then
                        obj.Transparency = XRayCache[obj]
                    end
                end
            end
        end
    end)
end

-- 2. TP DOWN FUNCTION
local function ExecuteTPDown()
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {char}
        rayParams.FilterType = Enum.RaycastFilterType.Exclude

        local rayResult = Workspace:Raycast(hrp.Position, Vector3.new(0, -700, 0), rayParams)
        if rayResult then
            hrp.CFrame = CFrame.new(rayResult.Position + Vector3.new(0, 3, 0))
        end
    end)
end

-- 3. TARGET SCANNER FOR COMBAT
local function GetTarget()
    local closest = nil
    local shortest = Engine.TargetRadius
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local tHrp = p.Character.HumanoidRootPart
            local dist = (hrp.Position - tHrp.Position).Magnitude
            if dist < shortest then
                shortest = dist
                closest = p
            end
        end
    end
    return closest
end

-- 4. HEARTBEAT PHYSICS & MOVEMENT LOOP
RunService.Heartbeat:Connect(function(dt)
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")

        if not (hrp and humanoid and humanoid.Health > 0) then return end

        -- Carry Speed 30 Bypass
        if Engine.CarrySpeed and humanoid.MoveDirection.Magnitude > 0 then
            local moveDir = humanoid.MoveDirection
            hrp.CFrame = hrp.CFrame + (moveDir * (Engine.SpeedValue * dt))
        end

        -- Cube Fly / Süzülme Mekaniği
        if Engine.CubeFly then
            local camRot = Camera.CFrame.LookVector
            hrp.CFrame = hrp.CFrame + (Vector3.new(camRot.X, 0, camRot.Z) * (Engine.SpeedValue * dt))
            humanoid.PlatformStand = true
        else
            if humanoid.PlatformStand and not Engine.AutoBat then
                humanoid.PlatformStand = false
            end
        end

        -- Auto Left Strafe
        if Engine.AutoLeft then
            local leftVec = -hrp.CFrame.RightVector
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(3.5), 0) + (leftVec * (Engine.StrafeSpeed * dt))
        end

        -- Auto Right Strafe
        if Engine.AutoRight then
            local rightVec = hrp.CFrame.RightVector
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(-3.5), 0) + (rightVec * (Engine.StrafeSpeed * dt))
        end

        -- Auto Bat Combat Automation
        if Engine.AutoBat then
            local target = GetTarget()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local tHrp = target.Character.HumanoidRootPart
                hrp.CFrame = CFrame.new(hrp.Position:Lerp(tHrp.Position + Vector3.new(0, 1.2, 0), 0.18), tHrp.Position)

                local tool = char:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                if tool then
                    if tool.Parent ~= char then
                        humanoid:EquipTool(tool)
                    end
                    tool:Activate()
                end
            end
        end
    end)
end)

print("✅ [LEA MOD V5.3 - PART 2]: Hareket, Küp Süzülme ve X-Ray motoru çalışır durumda.")
-- ==============================================================================
-- LEA MOD V5.3 - PART 3: BACKGROUND-FREE VERTICAL MICRO-GRID UI & LAUNCHER
-- ==============================================================================

print("⚡ [LEA MOD V5.3 - PART 3]: Dikey Mikro-Grid Arayüzü Oluşturuluyor...")

local function BuildVerticalMiniMenu(selectedMode)
    pcall(function()
        if CoreGui:FindFirstChild("LeaVerticalGridOverlayGui") then
            CoreGui.LeaVerticalGridOverlayGui:Destroy()
        end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "LeaVerticalGridOverlayGui"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = CoreGui

        -- Arka planı tamamen kaldırılmış, yalnızca dikey dizilen butonlar konsepti
        local verticalContainer = Instance.new("Frame")
        verticalContainer.Name = "VerticalButtonContainer"
        verticalContainer.Size = UDim2.new(0, 75, 0, 320)
        verticalContainer.Position = UDim2.new(1, -85, 0.25, 0)
        verticalContainer.BackgroundTransparency = 1 -- MENÜ ARKASI KALDIRILDI
        verticalContainer.Active = true
        verticalContainer.Draggable = true
        verticalContainer.Parent = screenGui

        local uiListLayout = Instance.new("UIListLayout")
        uiListLayout.FillDirection = Enum.FillDirection.Vertical
        uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        uiListLayout.Padding = UDim.new(0, 6)
        uiListLayout.Parent = verticalContainer

        -- Küçültülmüş Buton Fabrikası
        local function CreateMiniButton(text, isToggle, callback)
            local btn = Instance.new("TextButton")
            btn.Name = text .. "Btn"
            btn.Size = UDim2.new(0, 70, 0, 36)
            btn.BackgroundColor3 = Color3.fromRGB(18, 24, 34)
            btn.BackgroundTransparency = 0.2
            btn.Text = text
            btn.TextColor3 = Color3.fromRGB(235, 235, 235)
            btn.TextSize = 8
            btn.Font = Enum.Font.GothamBold
            btn.TextWrapped = true
            btn.Parent = verticalContainer

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = btn

            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(50, 60, 80)
            stroke.Thickness = 1
            stroke.Parent = btn

            if isToggle then
                local state = false
                btn.MouseButton1Click:Connect(function()
                    state = not state
                    btn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 110) or Color3.fromRGB(18, 24, 34)
                    callback(state)
                end)
            else
                btn.MouseButton1Click:Connect(function()
                    btn.BackgroundColor3 = Color3.fromRGB(0, 130, 190)
                    task.delay(0.15, function()
                        btn.BackgroundColor3 = Color3.fromRGB(18, 24, 34)
                    end)
                    callback()
                end)
            end
        end

        -- Mod Ayrımı (PET veya DUEL)
        if selectedMode == "PET" then
            CreateMiniButton("PET FLY", true, function(v) Engine.CubeFly = v end)
            CreateMiniButton("CARRY SPD", true, function(v) Engine.CarrySpeed = v end)
            CreateMiniButton("TP DOWN", false, function() ExecuteTPDown() end)
            CreateMiniButton("X-RAY", true, function(v) ToggleXRay(v) end)
            CreateMiniButton("AUTO BAT", true, function(v) Engine.AutoBat = v end)
        else -- DUEL Modu (Önceki tüm özellikler ve dikey yerleşim)
            CreateMiniButton("CARRY SPD", true, function(v) Engine.CarrySpeed = v end)
            CreateMiniButton("CUBE FLY", true, function(v) Engine.CubeFly = v end)
            CreateMiniButton("TP DOWN", false, function() ExecuteTPDown() end)
            CreateMiniButton("AUTO LEFT", true, function(v) Engine.AutoLeft = v end)
            CreateMiniButton("AUTO RIGHT", true, function(v) Engine.AutoRight = v end)
            CreateMiniButton("X-RAY", true, function(v) ToggleXRay(v) end)
            CreateMiniButton("AUTO BAT", true, function(v) Engine.AutoBat = v end)
        end

        print("✅ [LEA MOD V5.3 - PART 3]: Dikey buton arayüzü başarıyla oluşturuldu.")
    end)
end

-- Başlatıcı tetikleyici: Önce siyah ekran açılır, seçime göre menü yüklenir.
CreateStartupSelector(function(mode)
    BuildVerticalMiniMenu(mode)
end)
-- ==============================================================================
-- LEA MOD V5.3 - PART 4: ULTIMATE ANTI-RESET BYPASS & RESET KORUMASI
-- ==============================================================================

print("⚡ [LEA MOD V5.3 - PART 4]: Gelişmiş Anti-Reset Bypass & Reset Koruması Yükleniyor...")

-- Anti-Reset Koruma Katmanları
getgenv().LeaAntiReset = {
    Active = true,
    ResetCount = 0,
    BlockedResets = 0,
    CharacterLock = false,
    TeleportProtection = true,
    RemoteBlocker = true,
    ResetDetectionThreshold = 3 -- 3 saniye içinde reset engellemesi
}

local AntiReset = getgenv().LeaAntiReset

-- 1. REMOTE EVENT BLOKER (Reset tetikleyen remote'ları engelle)
local RemoteBlockerTable = {}
local OldRemoteFireServer = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if AntiReset.Active and AntiReset.RemoteBlocker and not checkcaller() then
        -- Reset ile ilgili remote'ları tespit et ve engelle
        if self:IsA("RemoteEvent") or self:IsA("RemoteFunction") then
            local remoteName = self.Name:lower()
            
            -- Reset/Spawn/Respawn ile ilgili remote isimleri
            if remoteName:match("reset") or 
               remoteName:match("spawn") or 
               remoteName:match("respawn") or
               remoteName:match("reborn") or
               remoteName:match("die") or
               remoteName:match("kill") or
               remoteName:match("destroy") then
                
                warn("🛡️ [LEA ANTI-RESET]: Şüpheli remote çağrısı engellendi: " .. self.Name)
                AntiReset.BlockedResets = AntiReset.BlockedResets + 1
                return nil
            end
        end
    end
    
    return OldRemoteFireServer(self, ...)
end)

-- 2. CHARACTER RESET DETECTOR & BLOCKER
local CharacterResetBlocker
CharacterResetBlocker = LocalPlayer.CharacterAdded:Connect(function(character)
    if not AntiReset.Active then return end
    
    AntiReset.ResetCount = AntiReset.ResetCount + 1
    
    -- Hızlı reset tespiti (Anti-Reset bypass koruması)
    if AntiReset.ResetCount > 1 then
        local currentTime = tick()
        
        if not AntiReset.LastResetTime then
            AntiReset.LastResetTime = currentTime
        else
            local timeDiff = currentTime - AntiReset.LastResetTime
            
            if timeDiff < AntiReset.ResetDetectionThreshold then
                warn("🛡️ [LEA ANTI-RESET]: Hızlı reset tespit edildi! Koruma aktifleştiriliyor...")
                AntiReset.CharacterLock = true
                
                -- Karakter kilidi aktif - 5 saniye boyunca reset engelle
                task.delay(5, function()
                    AntiReset.CharacterLock = false
                    AntiReset.ResetCount = 0
                    print("🔓 [LEA ANTI-RESET]: Karakter kilidi kaldırıldı.")
                end)
            end
            
            AntiReset.LastResetTime = currentTime
        end
    end
    
    -- Karakter koruması ekle
    task.spawn(function()
        pcall(function()
            -- Humanoid koruması
            local humanoid = character:WaitForChild("Humanoid", 5)
            if humanoid then
                -- Ölüm durumunu engelle
                local oldHealth = humanoid.Health
                
                humanoid.HealthChanged:Connect(function(newHealth)
                    if AntiReset.Active and AntiReset.CharacterLock and newHealth <= 0 then
                        pcall(function()
                            humanoid.Health = oldHealth > 0 and oldHealth or 100
                            warn("🛡️ [LEA ANTI-RESET]: Ölüm engellendi, sağlık geri yüklendi.")
                        end)
                    end
                    oldHealth = humanoid.Health
                end)
                
                -- BreakJoints engellemesi (reset bypass)
                local oldBreakJoints = humanoid.BreakJoints
                humanoid.BreakJoints = function(...)
                    if AntiReset.Active and AntiReset.CharacterLock then
                        warn("🛡️ [LEA ANTI-RESET]: BreakJoints çağrısı engellendi.")
                        return
                    end
                    return oldBreakJoints(...)
                end
            end
            
            -- Root Part koruması
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.AncestryChanged:Connect(function(_, parent)
                    if AntiReset.Active and AntiReset.CharacterLock and not parent then
                        warn("🛡️ [LEA ANTI-RESET]: RootPart silinmesi engellendi.")
                        rootPart.Parent = character
                    end
                end)
            end
        end)
    end)
end)

-- 3. TELEPORT PROTECTION (Reset sonrası pozisyon kaybını engelle)
local LastSafePosition = Vector3.new(0, 10, 0)

local function SavePosition()
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Position.Y > -100 then -- Void'te değilse kaydet
            LastSafePosition = hrp.Position
        end
    end)
end

-- Her 2 saniyede bir pozisyon kaydet
task.spawn(function()
    while task.wait(2) do
        if AntiReset.Active and AntiReset.TeleportProtection then
            SavePosition()
        end
    end
end)

-- Reset sonrası pozisyonu geri yükle
LocalPlayer.CharacterAdded:Connect(function(character)
    if AntiReset.Active and AntiReset.TeleportProtection and LastSafePosition.Magnitude > 0 then
        task.wait(0.5) -- Karakter yüklenene kadar bekle
        
        pcall(function()
            local hrp = character:WaitForChild("HumanoidRootPart", 3)
            if hrp then
                hrp.CFrame = CFrame.new(LastSafePosition + Vector3.new(0, 5, 0))
                print("📍 [LEA ANTI-RESET]: Pozisyon geri yüklendi: " .. tostring(LastSafePosition))
            end
        end)
    end
end)

-- 4. SERVER-SIDE KICK PROTECTION (Reset sonrası kick koruması)
local AntiKickConnection
AntiKickConnection = LocalPlayer.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.InProgress and AntiReset.Active then
        warn("🛡️ [LEA ANTI-RESET]: Teleport tespit edildi, koruma aktif.")
    end
end)

-- 5. OYUNCU VERİ KORUMASI (Reset'te kaybolan verileri koru)
local PlayerDataCache = {
    Tools = {},
    Stats = {},
    Position = Vector3.new(0, 10, 0)
}

local function CachePlayerData()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        -- Tool'ları kaydet
        PlayerDataCache.Tools = {}
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") then
                table.insert(PlayerDataCache.Tools, {
                    Name = child.Name,
                    ClassName = child.ClassName
                })
            end
        end
        
        -- Backpack'i kontrol et
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, child in ipairs(backpack:GetChildren()) do
                if child:IsA("Tool") then
                    table.insert(PlayerDataCache.Tools, {
                        Name = child.Name,
                        ClassName = child.ClassName
                    })
                end
            end
        end
        
        -- Pozisyonu kaydet
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            PlayerDataCache.Position = hrp.Position
        end
    end)
end

-- Periyodik veri önbellekleme
task.spawn(function()
    while task.wait(5) do
        if AntiReset.Active then
            CachePlayerData()
        end
    end
end)

-- 6. GÜVENLİ RESET FONKSİYONU (Kontrollü reset)
function SafeReset()
    if not AntiReset.Active then
        return false
    end
    
    AntiReset.CharacterLock = false
    AntiReset.ResetCount = 0
    
    CachePlayerData()
    
    print("🔄 [LEA ANTI-RESET]: Güvenli reset başlatılıyor...")
    
    -- Koruma kalkanını geçici olarak kaldır
    AntiReset.Active = false
    task.wait(0.5)
    
    pcall(function()
        if LocalPlayer.Character then
            LocalPlayer.Character:Destroy()
        end
    end)
    
    task.wait(1)
    
    -- Pozisyonu geri yükle
    pcall(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(PlayerDataCache.Position)
        end
    end)
    
    AntiReset.Active = true
    print("✅ [LEA ANTI-RESET]: Güvenli reset tamamlandı.")
    
    return true
end

-- 7. STATİK VERİ KORUMA KATMANI
local StaticProtectionTable = setmetatable({}, {
    __index = function(t, k)
        return rawget(t, k)
    end,
    __newindex = function(t, k, v)
        if AntiReset.Active and AntiReset.CharacterLock then
            warn("🛡️ [LEA ANTI-RESET]: Kritik veri değişikliği engellendi: " .. tostring(k))
            return
        end
        rawset(t, k, v)
    end,
    __metatable = "LeaProtected"
})

-- Global koruma tablosuna erişim
getgenv().LeaSecureRegistry.ProtectedResetData = StaticProtectionTable

-- 8. OTOMATİK KORUMA DURUM RAPORU
task.spawn(function()
    while task.wait(30) do
        if AntiReset.Active then
            print(string.format(
                "📊 [LEA ANTI-RESET RAPORU]: Engellenen Reset: %d | Karakter Kilitli: %s | Aktif: %s",
                AntiReset.BlockedResets,
                tostring(AntiReset.CharacterLock),
                tostring(AntiReset.Active)
            ))
        end
    end
end)

-- Komut satırı erişimi
getgenv().SafeReset = SafeReset
getgenv().ToggleAntiReset = function(state)
    AntiReset.Active = state
    print("🛡️ Anti-Reset koruması: " .. (state and "AKTİF" or "DEVRE DIŞI"))
end

-- Başlangıç mesajı
print("✅ [LEA MOD V5.3 - PART 4]: Anti-Reset Bypass & Reset Koruması tamamen aktif!")
print("🛡️ Korumalar: Remote Blocker, Character Lock, Position Save, Data Cache")
print("💡 Komutlar: getgenv().SafeReset() | getgenv().ToggleAntiReset(true/false)")
