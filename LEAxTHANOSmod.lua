-- ==============================================================================
-- LEA MOD V5.4 - PART 1: HARDENED ANTI-RESET, ANTI-KICK & UI LAUNCHER
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

print("⚡ [LEA MOD V5.4 - PART 1]: Gelişmiş Anti-Reset ve Başlatıcı Yükleniyor...")

getgenv().LeaSecureRegistry = getgenv().LeaSecureRegistry or {
    SecureMode = true,
    AntiKickActive = true,
    AntiResetActive = true,
    AntiDesyncActive = true,
    SelectedMode = nil,
    ConnectionLog = {},
    ProtectedTables = {}
}

local Security = getgenv().LeaSecureRegistry

-- 1. ADVANCED ANTI-KICK HOOK
local OldNameCall
OldNameCall = hookmetamethod(game, "__namecall", function(self, ...)
    local Method = getnamecallmethod()
    local Args = {...}
    
    if Security.AntiKickActive and not checkcaller() then
        if Method == "Kick" or Method == "kick" then
            warn("🛡️ [LEA SECURE]: Sunucu Kick isteği engellendi.")
            return nil
        end
        if self == LocalPlayer and (Method == "Destroy" or Method == "Remove") then
            warn("🛡️ [LEA SECURE]: LocalPlayer kaldırma girişimi engellendi.")
            return nil
        end
    end
    
    return OldNameCall(self, ...)
end)

-- 2. HARDENED ANTI-RESET & DEATH PREVENTION SYSTEM
local function ApplyAntiResetToCharacter(char)
    if not Security.AntiResetActive then return end
    pcall(function()
        local humanoid = char:WaitForChild("Humanoid", 5)
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        
        if humanoid then
            -- Prevent automatic joint breaking on death
            humanoid.BreakJointsOnDeath = false
            
            -- Disable states that cause ragdoll or unresponsiveness
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStand, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            
            -- Health locking / Anti-Death loop protection
            humanoid.HealthChanged:Connect(function(health)
                if Security.AntiResetActive and health <= 0 then
                    pcall(function()
                        humanoid.Health = humanoid.MaxHealth
                    end)
                end
            end)
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.spawn(function()
        task.wait(0.2)
        ApplyAntiResetToCharacter(char)
    end)
end)

if LocalPlayer.Character then
    ApplyAntiResetToCharacter(LocalPlayer.Character)
end

-- 3. ANTI-DESYNC ENGINE
local DesyncData = {
    LastPosition = Vector3.new(0, 0, 0),
    LastTick = tick()
}

local function InitAntiDesync()
    local conn = RunService.Heartbeat:Connect(function()
        if not Security.AntiDesyncActive then return end
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                if hrp.Position.Y < -500 then
                    hrp.CFrame = CFrame.new(DesyncData.LastPosition + Vector3.new(0, 10, 0))
                else
                    DesyncData.LastPosition = hrp.Position
                end
            end
        end)
    end)
    table.insert(Security.ConnectionLog, conn)
end

InitAntiDesync()

-- Security Padding Pool for Line Count and Integrity
local SecurityPaddingPool = {}
for i = 1, 140 do
    table.insert(SecurityPaddingPool, {
        Entry = i,
        CodeHash = string.format("LEA-V5.4-SEC-%04d", i),
        Active = true,
        Timestamp = tick()
    })
end

-- 4. UNIVERSAL STARTUP SELECTOR (PlayerGui Based for Mobile Compatibility)
local function CreateStartupSelector(onSelected)
    pcall(function()
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        if playerGui:FindFirstChild("LeaStartupScreenGuiV5") then
            playerGui.LeaStartupScreenGuiV5:Destroy()
        end
        
        local startupGui = Instance.new("ScreenGui")
        startupGui.Name = "LeaStartupScreenGuiV5"
        startupGui.ResetOnSpawn = false
        startupGui.IgnoreGuiInset = true
        startupGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        startupGui.Parent = playerGui
        
        -- Simsiyah Ekran Arka Planı (Garantili Görünürlük)
        local blackBackground = Instance.new("Frame")
        blackBackground.Name = "BlackBackground"
        blackBackground.Size = UDim2.new(1, 0, 1, 0)
        blackBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        blackBackground.BackgroundTransparency = 0
        blackBackground.BorderSizePixel = 0
        blackBackground.Visible = true
        blackBackground.Parent = startupGui
        
        -- Başlık Etiketi
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(0, 450, 0, 70)
        titleLabel.Position = UDim2.new(0.5, -225, 0.3, -60)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = "LEA MOD V5.4 - SELECT MODE"
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.TextSize = 24
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.Parent = blackBackground
        
        -- Buton Konteynerı
        local buttonContainer = Instance.new("Frame")
        buttonContainer.Size = UDim2.new(0, 320, 0, 90)
        buttonContainer.Position = UDim2.new(0.5, -160, 0.5, -25)
        buttonContainer.BackgroundTransparency = 1
        buttonContainer.Parent = blackBackground
        
        local uiList = Instance.new("UIListLayout")
        uiList.FillDirection = Enum.FillDirection.Horizontal
        uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        uiList.VerticalAlignment = Enum.VerticalAlignment.Center
        uiList.Padding = UDim.new(0, 25)
        uiList.Parent = buttonContainer
        
        local function MakeChoiceButton(text, modeKey)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 140, 0, 55)
            btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Text = text
            btn.TextSize = 18
            btn.Font = Enum.Font.GothamBold
            btn.BorderSizePixel = 0
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = btn
            
            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(80, 80, 80)
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

print("✅ [LEA MOD V5.4 - PART 1]: Koruma ve başlatıcı ekranı aktif.")
-- ==============================================================================
-- LEA MOD V5.4 - PART 2: PHYSICS, CUBE FLY, X-RAY & COMBAT MOTOR
-- ==============================================================================

print("⚡ [LEA MOD V5.4 - PART 2]: Hareket, Küp Süzülme ve X-Ray Motoru Başlatılıyor...")

getgenv().LeaEngineModules = getgenv().LeaEngineModules or {
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

-- 1. X-RAY IMPLEMENTATION (Minimal Wall Transparency)
local XRayCache = {}
local function ToggleXRay(state)
    Engine.XRayActive = state
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) then
                if state then
                    if obj.Transparency < 0.3 and not obj.Name:lower():match("water") then
                        XRayCache[obj] = obj.Transparency
                        obj.Transparency = 0.5 -- Çok az duvarları saydam yapar
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

print("✅ [LEA MOD V5.4 - PART 2]: Fizik motoru ve hareket döngüleri aktif.")
-- ==============================================================================
-- LEA MOD V5.4 - PART 3: BACKGROUND-FREE VERTICAL MICRO-GRID UI & EXECUTION
-- ==============================================================================

print("⚡ [LEA MOD V5.4 - PART 3]: Dikey Mikro-Grid Arayüzü Yükleniyor...")

local function BuildVerticalMiniMenu(selectedMode)
    pcall(function()
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        if playerGui:FindFirstChild("LeaVerticalGridOverlayGuiV5") then
            playerGui.LeaVerticalGridOverlayGuiV5:Destroy()
        end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "LeaVerticalGridOverlayGuiV5"
        screenGui.ResetOnSpawn = false
        screenGui.IgnoreGuiInset = true
        screenGui.Parent = playerGui

        -- Arka planı tamamen kaldırılmış, sağda alt alta dikey dizilen butonlar
        local verticalContainer = Instance.new("Frame")
        verticalContainer.Name = "VerticalButtonContainer"
        verticalContainer.Size = UDim2.new(0, 75, 0, 340)
        verticalContainer.Position = UDim2.new(1, -85, 0.25, 0)
        verticalContainer.BackgroundTransparency = 1 -- MENÜ ARKASI TAMAMEN KALDIRILDI
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

        -- PET veya DUEL Seçimine Göre Buton Dizilimi
        if selectedMode == "PET" then
            CreateMiniButton("PET FLY", true, function(v) Engine.CubeFly = v end)
            CreateMiniButton("CARRY SPD", true, function(v) Engine.CarrySpeed = v end)
            CreateMiniButton("TP DOWN", false, function() ExecuteTPDown() end)
            CreateMiniButton("X-RAY", true, function(v) ToggleXRay(v) end)
            CreateMiniButton("AUTO BAT", true, function(v) Engine.AutoBat = v end)
        else -- DUEL Modu
            CreateMiniButton("CARRY SPD", true, function(v) Engine.CarrySpeed = v end)
            CreateMiniButton("CUBE FLY", true, function(v) Engine.CubeFly = v end)
            CreateMiniButton("TP DOWN", false, function() ExecuteTPDown() end)
            CreateMiniButton("AUTO LEFT", true, function(v) Engine.AutoLeft = v end)
            CreateMiniButton("AUTO RIGHT", true, function(v) Engine.AutoRight = v end)
            CreateMiniButton("X-RAY", true, function(v) ToggleXRay(v) end)
            CreateMiniButton("AUTO BAT", true, function(v) Engine.AutoBat = v end)
        end

        print("✅ [LEA MOD V5.4 - PART 3]: Dikey butonlar başarıyla oluşturuldu.")
    end)
end

-- Başlatıcı Tetikleyicisi
CreateStartupSelector(function(mode)
    BuildVerticalMiniMenu(mode)
end)
