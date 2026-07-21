-- ==============================================================================
-- LEA MOD ULTIMATE MEGA V44.0 - ADVANCED BYPASS & AUTO-DODGE EDITION (PART 1)
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

print("⭐ [LEA V44.0]: ADVANCED CORE & BYPASS BAŞLATILIYOR...")

-- ==============================================================================
-- 1. ULTRA GÜÇLÜ BYPASS, ANTI-KICK & ANTI-DETECTION SİSTEMİ
-- ==============================================================================
pcall(function()
    -- Metod kancalama koruması ve temel metin engelleme
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Anti-Kick: Sunucunun oyuncuyu atmaya çalışmasını engelle
        if method == "Kick" or method == "kick" then
            return nil
        end
        
        -- Anti-Cheat hız/teleport algılama loglarını blokla
        if tostring(method) == "FireServer" and self.Name:lower():find("anticheat") or self.Name:lower():find("ban") or self.Name:lower():find("report") then
            return nil
        end
        
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end)

-- Fizik ve Hız Sınırlandırmalarını Bypass Etme (Anti-Speed Cap / Anti-Clamp)
task.spawn(function()
    pcall(function()
        for _, v in ipairs(getgc(true)) do
            if typeof(v) == "table" and rawget(v, "WalkSpeed") then
                rawset(v, "WalkSpeed", 100)
            end
        end
    end)
end)

if not getgenv().LeaModGlobalState then
    getgenv().LeaModGlobalState = {
        Version = "44.0-ULTRA-BYPASS",
        Mode = "NONE",          -- "NONE", "BASE", "TARGET"
        Speed = 16,             
        MoveSpeedIndex = 1,     
        SpawnPos = nil,
        Fly = false,
        FlySpeed = 45,
        Visuals = false,
        CubeActive = false,
        CubeList = {},          
        LastCubeTime = 0,       
        AutoDodge = false,      -- Otomatik Kaçış Sistemi
        ThemeColor = Color3.fromRGB(0, 255, 200),
        Connections = {},
        TweenStorage = {},
        EspActive = false,
        ReturnSpeedIndex = 2    
    }
end
local State = getgenv().LeaModGlobalState

for _, conn in ipairs(State.Connections) do
    pcall(function() conn:Disconnect() end)
end
State.Connections = {}
State.EspActive = false

local function CancelActiveTweens()
    if State.TweenStorage.ActiveTween then
        State.TweenStorage.ActiveTween:Cancel()
        State.TweenStorage.ActiveTween = nil
    end
end

-- ==============================================================================
-- 2. CUBE SİSTEMİ
-- ==============================================================================
local function ClearCubes()
    for _, v in ipairs(State.CubeList) do
        if v and v.Parent then pcall(function() v:Destroy() end) end
    end
    State.CubeList = {}
end

local function CreateCube(pos)
    if #State.CubeList > 15 then
        local old = table.remove(State.CubeList, 1)
        if old and old.Parent then pcall(function() old:Destroy() end) end
    end

    local cube = Instance.new("Part")
    cube.Size = Vector3.new(4, 0.5, 4)
    cube.Position = pos
    cube.Anchored = true
    cube.CanCollide = true
    cube.Transparency = 0.8
    cube.Material = Enum.Material.SmoothPlastic
    cube.Color = Color3.fromRGB(0, 170, 255)
    cube.Parent = Workspace
    table.insert(State.CubeList, cube)
end

-- ==============================================================================
-- 3. RESET KORUMASI
-- ==============================================================================
local function SetupResetProtection(newChar)
    local humanoid = newChar:WaitForChild("Humanoid", 5)
    
    if humanoid then
        humanoid.BreakJointsOnDeath = false
        
        local healthConn = humanoid.HealthChanged:Connect(function(health)
            if health <= 0 then
                CancelActiveTweens()
                State.Mode = "NONE"
                State.Fly = false
                State.CubeActive = false
                ClearCubes()
                pcall(function()
                    humanoid.Health = 100
                end)
            end
        end)
        table.insert(State.Connections, healthConn)
        
        task.spawn(function()
            while newChar and newChar.Parent do
                pcall(function()
                    local forceField = newChar:FindFirstChildOfClass("ForceField")
                    if not forceField then
                        forceField = Instance.new("ForceField")
                        forceField.Parent = newChar
                    end
                    forceField.Visible = false
                end)
                task.wait(0.5)
            end
        end)
    end
end

if LocalPlayer.Character then
    task.spawn(function() SetupResetProtection(LocalPlayer.Character) end)
end
table.insert(State.Connections, LocalPlayer.CharacterAdded:Connect(SetupResetProtection))

-- ==============================================================================
-- 4. GELİŞTİRİLMİŞ FLY (BYPASS DESTEKLİ SÜZÜLME)
-- ==============================================================================
local function StopFly(humanoid, rootPart)
    if humanoid then
        humanoid.PlatformStand = false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    if rootPart then
        rootPart.AssemblyLinearVelocity = Vector3.zero
    end
end

local function UpdateFly(humanoid, rootPart)
    if not State.Fly or not rootPart or not humanoid then return end

    humanoid.PlatformStand = true
    local cam = Workspace.CurrentCamera
    local moveDir = humanoid.MoveDirection

    if moveDir.Magnitude > 0 then
        local camCFrame = cam.CFrame
        local targetDir = (camCFrame.RightVector * moveDir.X) + (camCFrame.LookVector * moveDir.Z)
        
        if targetDir.Magnitude > 0 then
            -- Hız kesici engeller tamamen kaldırıldı, doğrudan tam güç veriliyor
            rootPart.AssemblyLinearVelocity = targetDir.Unit * State.FlySpeed
        end
    else
        rootPart.AssemblyLinearVelocity = Vector3.zero
    end
end

print("✅ [LEA V44.0]: PART 1 (BYPASS & CORE) YÜKLENDİ.")
-- ==============================================================================
-- LEA MOD ULTIMATE MEGA V44.0 - PART 2 / 2 (GUI & AUTO-DODGE MOTORU)
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

print("⭐ [LEA V44.0]: PART 2 (GUI & DODGE) BAŞLATILIYOR...")

local State = getgenv().LeaModGlobalState
if not State then
    error("Önce Part 1 kodunu çalıştırmalısın!")
end

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
ActiveWatermark.Size = UDim2.new(0, 180, 0, 20)
ActiveWatermark.Position = UDim2.new(0.5, -90, 0.16, -10)
ActiveWatermark.BackgroundTransparency = 1
ActiveWatermark.Text = "⚡ LEA V44 ACTIVE (BYPASS) ⚡"
ActiveWatermark.TextColor3 = State.ThemeColor
ActiveWatermark.TextSize = 10
ActiveWatermark.Font = Enum.Font.GothamBlack
ActiveWatermark.Visible = false
ActiveWatermark.TextStrokeTransparency = 0.3
ActiveWatermark.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

-- Genişletilmiş Panel (10 buton sığması için yükseklik artırıldı)
local MainContainer = Instance.new("Frame", ScreenGui)
MainContainer.Size = UDim2.new(0, 125, 0, 175)
MainContainer.Position = UDim2.new(0.5, -62, 0.5, -87)
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
MainStroke.Transparency = 0.15

local HeaderFrame = Instance.new("Frame", MainContainer)
HeaderFrame.Size = UDim2.new(1, 0, 0, 18)
HeaderFrame.BackgroundColor3 = Color3.fromRGB(3, 3, 6)
HeaderFrame.BorderSizePixel = 0

local HeaderCorner = Instance.new("UICorner", HeaderFrame)
HeaderCorner.CornerRadius = UDim.new(0, 5)

local TitleLabel = Instance.new("TextLabel", HeaderFrame)
TitleLabel.Size = UDim2.new(1, -18, 1, 0)
TitleLabel.Position = UDim2.new(0, 4, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "LEA V44"
TitleLabel.TextColor3 = State.ThemeColor
TitleLabel.TextSize = 8
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local CloseButton = Instance.new("TextButton", HeaderFrame)
CloseButton.Size = UDim2.new(0, 14, 0, 14)
CloseButton.Position = UDim2.new(1, -16, 0, 2)
CloseButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 7

local CloseCorner = Instance.new("UICorner", CloseButton)
CloseCorner.CornerRadius = UDim.new(0, 3)

local ScrollContainer = Instance.new("ScrollingFrame", MainContainer)
ScrollContainer.Size = UDim2.new(1, -6, 1, -22)
ScrollContainer.Position = UDim2.new(0, 3, 0, 20)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.ScrollBarThickness = 2
ScrollContainer.ScrollBarImageColor3 = State.ThemeColor
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 220)

local ButtonListLayout = Instance.new("UIListLayout", ScrollContainer)
ButtonListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ButtonListLayout.Padding = UDim.new(0, 3)
ButtonListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 28, 0, 28)
ToggleBtn.Position = UDim2.new(1, -34, 0.5, -14)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(6, 6, 10)
ToggleBtn.Text = "LEA"
ToggleBtn.TextColor3 = State.ThemeColor
ToggleBtn.TextSize = 8
ToggleBtn.Font = Enum.Font.GothamBlack
ToggleBtn.Visible = false

local ToggleCorner = Instance.new("UICorner", ToggleBtn)
ToggleCorner.CornerRadius = UDim.new(1, 0)
local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Color = State.ThemeColor
ToggleStroke.Thickness = 1

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

local FlyButtonRef

local function CreateMenuButton(order, text, defaultColor, activeColor, callback)
    local btn = Instance.new("TextButton", ScrollContainer)
    btn.LayoutOrder = order
    btn.Size = UDim2.new(1, -2, 0, 19)
    btn.BackgroundColor3 = defaultColor
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 7.5
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    
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
    btn.Size = UDim2.new(1, -2, 0, 19)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 7.5
    btn.Font = Enum.Font.GothamBold
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 4)
    
    btn.MouseButton1Click:Connect(function() pcall(callback) end)
    return btn
end

local function CancelActiveTweens()
    if State.TweenStorage.ActiveTween then
        State.TweenStorage.ActiveTween:Cancel()
        State.TweenStorage.ActiveTween = nil
    end
end

local function SafeMoveTo(targetPosition, timeToArrive)
    CancelActiveTweens()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local returnSpeeds = {25, 30, 45}
        local activeSpeed = returnSpeeds[State.ReturnSpeedIndex] or 30
        local dist = (targetPosition.Position - hrp.Position).Magnitude
        local adjustedTime = math.max(dist / activeSpeed, 0.2)
        
        local tweenInfo = TweenInfo.new(adjustedTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetPosition})
        State.TweenStorage.ActiveTween = tween
        tween:Play()
    end
end
State.TweenStorage.SafeMoveTo = SafeMoveTo

local function StopFlyInternal(humanoid, rootPart)
    if humanoid then
        humanoid.PlatformStand = false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    if rootPart then
        rootPart.AssemblyLinearVelocity = Vector3.zero
    end
end

-- Menü Butonları Oluşturuluyor
FlyButtonRef = CreateMenuButton(1, "🚀 FLY OFF", Color3.fromRGB(45, 35, 65), Color3.fromRGB(0, 180, 90), function(on, btn)
    State.Fly = on
    btn.Text = on and "🚀 FLY ON" or "🚀 FLY OFF"
    if on then
        State.Mode = "NONE"
    else
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        StopFlyInternal(hum, hrp)
    end
end)

CreateMenuButton(2, "🧊 CUBE OFF", Color3.fromRGB(35, 55, 55), Color3.fromRGB(0, 180, 90), function(on, btn)
    State.CubeActive = on
    btn.Text = on and "🧊 CUBE ON" or "🧊 CUBE OFF"
    if not on then
        for _, v in ipairs(State.CubeList) do
            if v and v.Parent then pcall(function() v:Destroy() end) end
        end
        State.CubeList = {}
    end
end)

CreateMenuButton(3, "🏠 BASE OFF", Color3.fromRGB(55, 45, 25), Color3.fromRGB(0, 180, 90), function(on, btn)
    if on then
        State.Mode = "BASE"
        State.Fly = false
        if FlyButtonRef then
            FlyButtonRef.Text = "🚀 FLY OFF"
            TweenService:Create(FlyButtonRef, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 35, 65)}):Play()
        end
        local char = LocalPlayer.Character
        StopFlyInternal(char and char:FindFirstChildOfClass("Humanoid"), char and char:FindFirstChild("HumanoidRootPart"))
    else
        State.Mode = "NONE"
        CancelActiveTweens()
    end
    btn.Text = on and "🏠 BASE ON" or "🏠 BASE OFF"
end)

CreateMenuButton(4, "🎯 TARGET OFF", Color3.fromRGB(60, 25, 45), Color3.fromRGB(0, 180, 90), function(on, btn)
    if on then
        State.Mode = "TARGET"
        State.Fly = false
        if FlyButtonRef then
            FlyButtonRef.Text = "🚀 FLY OFF"
            TweenService:Create(FlyButtonRef, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 35, 65)}):Play()
        end
        local char = LocalPlayer.Character
        StopFlyInternal(char and char:FindFirstChildOfClass("Humanoid"), char and char:FindFirstChild("HumanoidRootPart"))
    else
        State.Mode = "NONE"
        CancelActiveTweens()
    end
    btn.Text = on and "🎯 TARGET ON" or "🎯 TARGET OFF"
end)

-- Yeni Eklenen Otomatik Kaçış (Auto-Dodge) Tuşu
CreateMenuButton(5, "🛡️ AUTO-DODGE OFF", Color3.fromRGB(50, 25, 60), Color3.fromRGB(0, 180, 90), function(on, btn)
    State.AutoDodge = on
    btn.Text = on and "🛡️ AUTO-DODGE ON" or "🛡️ AUTO-DODGE OFF"
end)

CreateActionItem(6, "🛬 YERE İN", Color3.fromRGB(30, 45, 55), function()
    State.Mode = "NONE"
    State.Fly = false
    if FlyButtonRef then
        FlyButtonRef.Text = "🚀 FLY OFF"
        TweenService:Create(FlyButtonRef, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 35, 65)}):Play()
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    StopFlyInternal(hum, hrp)
    CancelActiveTweens()
    if hrp then
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {char}
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        
        local result = Workspace:Raycast(hrp.Position, Vector3.new(0, -500, 0), raycastParams)
        if result then
            hrp.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0))
        end
    end
end)

CreateMenuButton(7, "👁️ ESP OFF", Color3.fromRGB(35, 35, 48), Color3.fromRGB(0, 180, 90), function(on, btn)
    State.Visuals = on
    State.EspActive = on
    btn.Text = on and "👁️ ESP ON" or "👁️ ESP OFF"
end)

CreateActionItem(8, "⚡ YÜRÜME HIZI: 16", Color3.fromRGB(30, 30, 45), function()
    State.MoveSpeedIndex = State.MoveSpeedIndex + 1
    if State.MoveSpeedIndex > 3 then State.MoveSpeedIndex = 1 end
    
    local speeds = {16, 18, 20}
    State.Speed = speeds[State.MoveSpeedIndex]
    
    local targetBtn = ScrollContainer:GetChildren()[8]
    if targetBtn and targetBtn:IsA("TextButton") then
        targetBtn.Text = "⚡ YÜRÜME HIZI: " .. State.Speed
    end
end)

CreateActionItem(9, "🏎️ DÖNÜŞ HIZI: 30", Color3.fromRGB(45, 30, 30), function()
    State.ReturnSpeedIndex = State.ReturnSpeedIndex + 1
    if State.ReturnSpeedIndex > 3 then State.ReturnSpeedIndex = 1 end
    
    local returnSpeeds = {25, 30, 45}
    local currentReturnSpeed = returnSpeeds[State.ReturnSpeedIndex]
    
    local targetBtn = ScrollContainer:GetChildren()[9]
    if targetBtn and targetBtn:IsA("TextButton") then
        targetBtn.Text = "🏎️ DÖNÜŞ HIZI: " .. currentReturnSpeed
    end
end)

CreateActionItem(10, "📍 ÜS YAP", Color3.fromRGB(30, 45, 35), function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        State.SpawnPos = hrp.Position + Vector3.new(0, 3, 0)
    end
end)

-- ESP Döngüsü
local espTimeElapsed = 0
table.insert(State.Connections, RunService.Heartbeat:Connect(function(dt)
    espTimeElapsed = espTimeElapsed + dt
    if espTimeElapsed >= 1.5 then
        espTimeElapsed = 0
        pcall(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local char = p.Character
                    local hl = char:FindFirstChild("LeaMegaESP")
                    if State.Visuals then
                        if not hl then
                            hl = Instance.new("Highlight")
                            hl.Name = "LeaMegaESP"
                            hl.FillColor = State.ThemeColor
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.55
                            hl.Parent = char
                        end
                    else
                        if hl then hl:Destroy() end
                    end
                end
            end
        end)
    end
end))

-- Ana Fizik, Hız Sabitleme ve Oto Kaçış (Auto-Dodge) Motoru
table.insert(State.Connections, RunService.Heartbeat:Connect(function(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if hum.Health <= 0 then
        CancelActiveTweens()
        State.Mode = "NONE"
        State.Fly = false
        State.CubeActive = false
        for _, v in ipairs(State.CubeList) do
            if v and v.Parent then pcall(function() v:Destroy() end) end
        end
        State.CubeList = {}
        return
    end

    -- Küp Sistemi
    if State.CubeActive then
        local now = tick()
        if hrp.AssemblyLinearVelocity.Y < -5 and (now - State.LastCubeTime > 0.3) then
            local cube = Instance.new("Part")
            cube.Size = Vector3.new(4, 0.5, 4)
            cube.Position = hrp.Position - Vector3.new(0, 3, 0)
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

    -- Hız Sabitleme (Hız kesici engeller tamamen kaldırıldı, sabit tam hız verilir)
    if hum.WalkSpeed ~= State.Speed then
        pcall(function()
            hum.WalkSpeed = State.Speed
        end)
    end

    -- Otomatik Kaçış (Auto-Dodge) Sistemi: Düşman yaklaşınca veya vurmaya çalışınca anında kaçar
    if State.AutoDodge then
        pcall(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local eHrp = p.Character:FindFirstChild("HumanoidRootPart")
                    local eHum = p.Character:FindFirstChildOfClass("Humanoid")
                    if eHrp and eHum and eHum.Health > 0 then
                        local distance = (eHrp.Position - hrp.Position).Magnitude
                        -- Eğer düşman kritik yakınlaşma alanına (8 stud) girerse ters yöne kaçış tetiklenir
                        if distance < 8 then
                            local escapeDir = (hrp.Position - eHrp.Position).Unit
                            hrp.AssemblyLinearVelocity = Vector3.new(escapeDir.X * 50, 15, escapeDir.Z * 50)
                            return
                        end
                    end
                end
            end
        end)
    end

    -- Süzülme / Uçuş Modu
    if State.Fly then
        hum.PlatformStand = true
        local cam = Workspace.CurrentCamera
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            local camCFrame = cam.CFrame
            local targetDir = (camCFrame.RightVector * moveDir.X) + (camCFrame.LookVector * moveDir.Z)
            if targetDir.Magnitude > 0 then
                hrp.AssemblyLinearVelocity = targetDir.Unit * State.FlySpeed
            end
        else
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
        return
    end

    -- Base Takip Sistemi
    if State.Mode == "BASE" and State.SpawnPos then
        local dist = (State.SpawnPos - hrp.Position).Magnitude
        if dist > 3.5 then
            if not State.TweenStorage.ActiveTween or State.TweenStorage.ActiveTween.PlaybackState ~= Enum.PlaybackState.Playing then
                SafeMoveTo(CFrame.new(State.SpawnPos), dist)
            end
        else
            CancelActiveTweens()
            State.Mode = "NONE"
        end
    end

    -- Target Takip Sistemi
    if State.Mode == "TARGET" then
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
                if dist > 4.5 then
                    local backPos = target.CFrame * CFrame.new(0, 0, 3.5)
                    if not State.TweenStorage.ActiveTween or State.TweenStorage.ActiveTween.PlaybackState ~= Enum.PlaybackState.Playing then
                        SafeMoveTo(backPos, dist)
                    end
                end
            else
                CancelActiveTweens()
            end
        end)
    end
end))

print("✅ [LEA V44.0]: PART 2 BAŞARIYLA YÜKLENDİ VE TAMAMLANDI!")
