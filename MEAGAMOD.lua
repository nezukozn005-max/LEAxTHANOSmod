-- ============================================================
-- HAMSTER LIVES - ULTIMATE BYPASS V12 (PART 1/10)
-- GERÇEK ÇALIŞIR | MOBİL UYUMLU | ANTİCHEAT KILLER
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local ScriptContext = game:GetService("ScriptContext")
local LocalPlayer = Players.LocalPlayer

print("⚡ ULTIMATE BYPASS V12 BAŞLADI...")

-- CİHAZ TESPİTİ (MOBİL/PC)
local isMobile = UserInputService.TouchEnabled

-- ============================================================
-- GERÇEK ANTİCHEAT KILLER (ÇALIŞIR)
-- ============================================================
local function RealAntiCheatKill()
    local patterns = {
        "AntiCheat", "AC", "Security", "Protect", "Ban",
        "Kick", "Detect", "Monitor", "Guard", "Watch",
        "Patrol", "Enforce", "Validate", "Verify", "Scan",
        "Filter", "Block", "Flag", "Report", "Logger",
        "Hyperion", "Byfron", "Luau", "Bytecode", "VM",
        "Sandbox", "Isolate", "Restrict", "Limit", "Cap"
    }
    
    local killed = 0
    local allObjects = game:GetDescendants()
    
    for _, obj in ipairs(allObjects) do
        if obj.Name then
            for _, p in ipairs(patterns) do
                if obj.Name:find(p) then
                    pcall(function()
                        -- Script'leri devre dışı bırak
                        if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                            obj.Disabled = true
                            killed = killed + 1
                        end
                        -- Remote'ları yok et (sadece anticheat olanlar)
                        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                            if obj.Name:find("Anti") or obj.Name:find("Cheat") or obj.Name:find("Detect") or obj.Name:find("Report") or obj.Name:find("Ban") or obj.Name:find("Kick") then
                                obj:Destroy()
                                killed = killed + 1
                            end
                        end
                        -- Değerleri sıfırla
                        if obj:IsA("BoolValue") or obj:IsA("IntValue") or obj:IsA("NumberValue") then
                            if obj.Name:find("Anti") or obj.Name:find("Cheat") or obj.Name:find("Detect") or obj.Name:find("Ban") then
                                obj.Value = false
                                killed = killed + 1
                            end
                        end
                        -- GUI'leri gizle
                        if obj:IsA("Frame") or obj:IsA("TextLabel") or obj:IsA("ImageLabel") then
                            if obj.Name:find("Anti") or obj.Name:find("Cheat") or obj.Name:find("Detect") or obj.Name:find("Ban") then
                                obj.Visible = false
                                killed = killed + 1
                            end
                        end
                    end)
                    break
                end
            end
        end
    end
    
    print("[AC] " .. killed .. " anticheat nesnesi imha edildi.")
    return killed
end

-- ============================================================
-- GERÇEK REMOTE KILLER (SADECE ZARARLILAR)
-- ============================================================
local function RealRemoteKiller()
    local killed = 0
    local containers = {
        ReplicatedStorage,
        game:GetService("ReplicatedFirst"),
        workspace,
        LocalPlayer:FindFirstChild("PlayerScripts")
    }
    
    local killPatterns = {"Anti", "Cheat", "Detect", "Report", "Ban", "Kick", "Monitor", "Guard", "Security"}
    
    for _, container in ipairs(containers) do
        if container then
            for _, obj in ipairs(container:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    for _, p in ipairs(killPatterns) do
                        if obj.Name:find(p) then
                            pcall(function()
                                obj:Destroy()
                                killed = killed + 1
                            end)
                            break
                        end
                    end
                end
            end
        end
    end
    
    print("[REMOTE] " .. killed .. " zararlı remote imha edildi.")
    return killed
end

-- ============================================================
-- GERÇEK GOD MOD (MOBİL UYUMLU)
-- ============================================================
local GodModeActive = false
local GodModeThread = nil

local function RealGodMode()
    if GodModeActive then return end
    GodModeActive = true
    
    print("[GOD] God mod aktif!")
    
    GodModeThread = task.spawn(function()
        while GodModeActive do
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    if hum.Health < hum.MaxHealth then
                        hum.Health = hum.MaxHealth
                    end
                    -- Düşmeyi engelle
                    if hum:GetState() == Enum.HumanoidStateType.FallingDown then
                        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                end
                -- Vurulma anında koruma (BreakJoints engelle)
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        pcall(function()
                            part.BreakJointsOnTilt = false
                        end)
                    end
                end
            end
            task.wait(0.05)
        end
    end)
end

local function StopGodMode()
    if not GodModeActive then return end
    GodModeActive = false
    if GodModeThread then
        coroutine.close(GodModeThread)
        GodModeThread = nil
    end
    print("[GOD] God mod kapatıldı.")
end

-- ============================================================
-- GERÇEK FLY (MOBİL UYUMLU)
-- ============================================================
local FlyActive = false
local FlyVelocity = nil
local FlyPosition = nil
local FlySpeed = 50

local function RealFly()
    if FlyActive then return end
    FlyActive = true
    
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local hum = char:FindFirstChild("Humanoid")
    if hum then
        hum.PlatformStand = true
    end
    
    FlyVelocity = Instance.new("BodyVelocity")
    FlyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    FlyVelocity.Velocity = Vector3.new(0, 0, 0)
    FlyVelocity.Parent = hrp
    
    FlyPosition = Instance.new("BodyPosition")
    FlyPosition.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    FlyPosition.Position = hrp.Position
    FlyPosition.Parent = hrp
    
    print("[FLY] Uçuş aktif! Mobil/PC uyumlu")
    
    -- PC Kontrolleri (WASD + Space + Shift)
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if not FlyActive then return end
        if not FlyVelocity then return end
        
        local speed = FlySpeed
        local dir = Vector3.new(0, 0, 0)
        
        if input.KeyCode == Enum.KeyCode.W then dir = dir + Vector3.new(0, 0, -1) end
        if input.KeyCode == Enum.KeyCode.S then dir = dir + Vector3.new(0, 0, 1) end
        if input.KeyCode == Enum.KeyCode.A then dir = dir + Vector3.new(-1, 0, 0) end
        if input.KeyCode == Enum.KeyCode.D then dir = dir + Vector3.new(1, 0, 0) end
        if input.KeyCode == Enum.KeyCode.Space then 
            FlyVelocity.Velocity = Vector3.new(0, speed, 0)
        end
        if input.KeyCode == Enum.KeyCode.LeftShift then
            FlyVelocity.Velocity = Vector3.new(0, -speed, 0)
        end
        
        if dir ~= Vector3.new(0, 0, 0) then
            local cam = workspace.CurrentCamera
            local forward = cam.CFrame.LookVector
            local right = cam.CFrame.RightVector
            local moveDir = (forward * -dir.Z + right * dir.X)
            moveDir = moveDir.Unit * speed
            FlyVelocity.Velocity = Vector3.new(moveDir.X, FlyVelocity.Velocity.Y, moveDir.Z)
        end
    end)
    
    -- MOBİL KONTROLLERİ (Joystick simülasyonu - ekrana basılı tut)
    if isMobile then
        local touchStart = nil
        local touchMove = nil
        
        UserInputService.TouchStarted:Connect(function(touch)
            touchStart = touch.Position
        end)
        
        UserInputService.TouchMoved:Connect(function(touch)
            if not FlyActive then return end
            if not FlyVelocity then return end
            if not touchStart then return end
            
            local delta = touch.Position - touchStart
            local speed = FlySpeed
            
            -- Y ekseni: ileri/geri
            local forward = Vector3.new(0, 0, -delta.Y / 100)
            local right = Vector3.new(delta.X / 100, 0, 0)
            local moveDir = forward + right
            moveDir = moveDir.Unit * speed
            
            FlyVelocity.Velocity = Vector3.new(moveDir.X, FlyVelocity.Velocity.Y, moveDir.Z)
        end)
        
        UserInputService.TouchEnded:Connect(function()
            touchStart = nil
            if FlyVelocity then
                FlyVelocity.Velocity = Vector3.new(0, FlyVelocity.Velocity.Y, 0)
            end
        end)
    end
    
    -- Sürekli yükseklik koruma
    task.spawn(function()
        while FlyActive do
            local char2 = LocalPlayer.Character
            if char2 then
                local hrp2 = char2:FindFirstChild("HumanoidRootPart")
                if hrp2 and FlyPosition then
                    FlyPosition.Position = hrp2.Position
                end
            end
            task.wait(0.05)
        end
    end)
end

local function StopFly()
    if not FlyActive then return end
    FlyActive = false
    
    if FlyVelocity then
        FlyVelocity:Destroy()
        FlyVelocity = nil
    end
    if FlyPosition then
        FlyPosition:Destroy()
        FlyPosition = nil
    end
    
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.PlatformStand = false
        end
    end
    
    print("[FLY] Uçuş kapatıldı.")
end-- ============================================================
-- HAMSTER LIVES - ULTIMATE BYPASS V12 (PART 2/10)
-- AUTO FARM | EGG | BOSS | TREADMILL
-- ============================================================

-- ============================================================
-- HEDEF BULUCULAR (GERÇEK)
-- ============================================================
local function FindEgg()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local nearest = nil
    local nearestDist = math.huge
    local pos = hrp.Position
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            if name:find("egg") or name:find("carry") or name:find("collect") or name:find("pickup") or name:find("grab") then
                local dist = (pos - obj.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = obj
                end
            end
        end
    end
    
    return nearest, nearestDist
end

local function FindBoss()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local nearest = nil
    local nearestDist = math.huge
    local pos = hrp.Position
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            if name:find("boss") or name:find("guard") or name:find("enemy") or name:find("monster") then
                local dist = (pos - obj.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = obj
                end
            end
        end
    end
    
    return nearest, nearestDist
end

local function FindTreadmill()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local nearest = nil
    local nearestDist = math.huge
    local pos = hrp.Position
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            if name:find("treadmill") or name:find("belt") or name:find("run") or name:find("mill") or name:find("walk") then
                local dist = (pos - obj.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = obj
                end
            end
        end
    end
    
    return nearest, nearestDist
end

-- ============================================================
-- EGG PICKUP (GERÇEK)
-- ============================================================
local function PickupEggReal(eggObj)
    if not eggObj then return false end
    
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    -- Egg'in yanına git
    local targetPos = eggObj.Position + Vector3.new(0, 2, 0)
    local tween = TweenService:Create(hrp, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
        CFrame = CFrame.new(targetPos)
    })
    tween:Play()
    tween.Completed:Wait()
    
    -- E tuşu simüle
    pcall(function()
        UserInputService:SetKeyDown(Enum.KeyCode.E)
        task.wait(0.1)
        UserInputService:SetKeyUp(Enum.KeyCode.E)
    end)
    
    -- ProximityPrompt
    for _, prompt in ipairs(eggObj:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            pcall(function()
                prompt:Prompt()
            end)
        end
    end
    
    -- Remote
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            local name = remote.Name:lower()
            if name:find("egg") or name:find("carry") or name:find("collect") or name:find("pickup") then
                pcall(function()
                    remote:FireServer()
                end)
            end
        end
    end
    
    return true
end

-- ============================================================
-- AUTO FARM ANA DÖNGÜ (GERÇEK)
-- ============================================================
local FarmActive = false
local FarmThread = nil

local function StartRealFarm()
    if FarmActive then return end
    FarmActive = true
    
    print("[FARM] Auto farm başlatıldı!")
    
    FarmThread = task.spawn(function()
        while FarmActive do
            local char = LocalPlayer.Character
            if not char then
                task.wait(0.5)
                continue
            end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then
                task.wait(0.5)
                continue
            end
            
            -- 1. Egg bul ve al
            local egg, eggDist = FindEgg()
            if egg and eggDist < 30 then
                PickupEggReal(egg)
                task.wait(0.5)
                continue
            end
            
            -- 2. Boss bul
            local boss, bossDist = FindBoss()
            if boss and bossDist < 20 then
                -- Boss'a bin (sadece yaklaş)
                local targetPos = boss.Position + Vector3.new(0, 3, 0)
                local tween = TweenService:Create(hrp, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
                    CFrame = CFrame.new(targetPos)
                })
                tween:Play()
                tween.Completed:Wait()
                task.wait(0.5)
                continue
            end
            
            -- 3. Treadmill bul
            local treadmill, treadDist = FindTreadmill()
            if treadmill and treadDist < 15 then
                local targetPos = treadmill.Position + Vector3.new(0, 3, 0)
                local tween = TweenService:Create(hrp, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
                    CFrame = CFrame.new(targetPos)
                })
                tween:Play()
                tween.Completed:Wait()
                task.wait(0.5)
                continue
            end
            
            -- 4. Hedef yoksa rastgele yürü
            local randomPos = hrp.Position + Vector3.new(math.random(-20, 20), 0, math.random(-20, 20))
            local tween = TweenService:Create(hrp, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
                CFrame = CFrame.new(randomPos)
            })
            tween:Play()
            tween.Completed:Wait()
            
            task.wait(0.5)
        end
    end)
end

local function StopRealFarm()
    if not FarmActive then return end
    FarmActive = false
    if FarmThread then
        coroutine.close(FarmThread)
        FarmThread = nil
    end
    print("[FARM] Auto farm durduruldu.")
    end-- ============================================================
-- HAMSTER LIVES - ULTIMATE BYPASS V12 (PART 3/10)
-- MENÜ | KONSOL | BYPASS EKRANI | GERÇEK
-- ============================================================

-- ============================================================
-- BYPASS EKRANI (GERÇEK)
-- ============================================================
local function ShowRealBypassScreen()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then
        pg = Instance.new("ScreenGui")
        pg.Name = "PlayerGui"
        pg.Parent = LocalPlayer
    end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "BypassScreen"
    gui.Parent = pg
    gui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 0, 0, 50)
    frame.Position = UDim2.new(0.5, -150, 0.5, -25)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.2
    frame.Parent = gui
    frame.ZIndex = 999
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(255, 200, 0)
    stroke.Transparency = 0.6
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 24)
    label.Position = UDim2.new(0, 10, 0, 2)
    label.BackgroundTransparency = 1
    label.Text = "🐹 HAMSTER LIVES BYPASS AKTİF"
    label.TextColor3 = Color3.fromRGB(255, 200, 0)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    label.ZIndex = 1000
    
    local subLabel = Instance.new("TextLabel")
    subLabel.Size = UDim2.new(1, 0, 0, 16)
    subLabel.Position = UDim2.new(0, 10, 0, 28)
    subLabel.BackgroundTransparency = 1
    subLabel.Text = "⚡ MOBİL/PC | " .. (isMobile and "📱 MOBİL" or "💻 PC")
    subLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    subLabel.TextSize = 10
    subLabel.Font = Enum.Font.Gotham
    subLabel.TextXAlignment = Enum.TextXAlignment.Left
    subLabel.Parent = frame
    subLabel.ZIndex = 1000
    
    task.spawn(function()
        TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 300, 0, 50),
            Position = UDim2.new(0.5, -150, 0.5, -25)
        }):Play()
        task.wait(1.5)
        TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 50),
            Position = UDim2.new(0.5, 0, 0.5, -25)
        }):Play()
        task.wait(0.5)
        gui:Destroy()
    end)
end

-- ============================================================
-- MENÜ (SAĞ ÜST - GERÇEK)
-- ============================================================
local MenuActive = false
local MenuGui = nil

local function CreateRealMenu()
    local old = CoreGui:FindFirstChild("RealMenu")
    if old then old:Destroy() end
    
    MenuGui = Instance.new("ScreenGui")
    MenuGui.Name = "RealMenu"
    MenuGui.Parent = CoreGui
    MenuGui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 160, 0, 130)
    frame.Position = UDim2.new(1, -170, 0, 5)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.2
    frame.Parent = MenuGui
    frame.ZIndex = 999
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 1.5
    stroke.Color = Color3.fromRGB(255, 200, 0)
    stroke.Transparency = 0.5
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 16)
    title.Position = UDim2.new(0, 5, 0, 2)
    title.BackgroundTransparency = 1
    title.Text = "🐹 HAMSTER V12"
    title.TextColor3 = Color3.fromRGB(255, 200, 0)
    title.TextSize = 9
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame
    title.ZIndex = 1000
    
    -- FLY BUTON (GERÇEK)
    local flyBtn = Instance.new("TextButton")
    flyBtn.Size = UDim2.new(0.9, -5, 0, 20)
    flyBtn.Position = UDim2.new(0, 5, 0, 20)
    flyBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
    flyBtn.Text = isMobile and "🟢 FLY (M)" or "🟢 FLY"
    flyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    flyBtn.TextSize = 9
    flyBtn.Font = Enum.Font.GothamBold
    flyBtn.Parent = frame
    flyBtn.ZIndex = 1000
    Instance.new("UICorner", flyBtn).CornerRadius = UDim.new(0, 4)
    
    flyBtn.MouseEnter:Connect(function()
        flyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 220)
    end)
    flyBtn.MouseLeave:Connect(function()
        flyBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
    end)
    
    flyBtn.MouseButton1Click:Connect(function()
        if FlyActive then
            StopFly()
            flyBtn.Text = isMobile and "🟢 FLY (M)" or "🟢 FLY"
            flyBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
        else
            RealFly()
            flyBtn.Text = isMobile and "🔴 FLY (M)" or "🔴 FLY"
            flyBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        end
    end)
    
    -- GOD BUTON
    local godBtn = Instance.new("TextButton")
    godBtn.Size = UDim2.new(0.9, -5, 0, 20)
    godBtn.Position = UDim2.new(0, 5, 0, 43)
    godBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    godBtn.Text = "🟢 GOD"
    godBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    godBtn.TextSize = 9
    godBtn.Font = Enum.Font.GothamBold
    godBtn.Parent = frame
    godBtn.ZIndex = 1000
    Instance.new("UICorner", godBtn).CornerRadius = UDim.new(0, 4)
    
    godBtn.MouseEnter:Connect(function()
        godBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    end)
    godBtn.MouseLeave:Connect(function()
        godBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    end)
    
    godBtn.MouseButton1Click:Connect(function()
        if GodModeActive then
            StopGodMode()
            godBtn.Text = "🟢 GOD"
            godBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        else
            RealGodMode()
            godBtn.Text = "🔴 GOD"
            godBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        end
    end)
    
    -- FARM BUTON
    local farmBtn = Instance.new("TextButton")
    farmBtn.Size = UDim2.new(0.9, -5, 0, 20)
    farmBtn.Position = UDim2.new(0, 5, 0, 66)
    farmBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 0)
    farmBtn.Text = "🟢 FARM"
    farmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    farmBtn.TextSize = 9
    farmBtn.Font = Enum.Font.GothamBold
    farmBtn.Parent = frame
    farmBtn.ZIndex = 1000
    Instance.new("UICorner", farmBtn).CornerRadius = UDim.new(0, 4)
    
    farmBtn.MouseEnter:Connect(function()
        farmBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
    end)
    farmBtn.MouseLeave:Connect(function()
        farmBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 0)
    end)
    
    farmBtn.MouseButton1Click:Connect(function()
        if FarmActive then
            StopRealFarm()
            farmBtn.Text = "🟢 FARM"
            farmBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 0)
        else
            StartRealFarm()
            farmBtn.Text = "🔴 FARM"
            farmBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        end
    end)
    
    -- KAPAT BUTON
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.9, -5, 0, 20)
    closeBtn.Position = UDim2.new(0, 5, 0, 89)
    closeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    closeBtn.Text = "✕ KAPAT"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 9
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = frame
    closeBtn.ZIndex = 1000
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
    
    closeBtn.MouseEnter:Connect(function()
        closeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end)
    closeBtn.MouseLeave:Connect(function()
        closeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        MenuActive = false
        if MenuGui then
            MenuGui:Destroy()
            MenuGui = nil
        end
    end)
    
    MenuActive = true
end

-- ============================================================
-- MENÜ AÇ/KAPA (SAĞ ÜST KÜÇÜK BUTON)
-- ============================================================
local function CreateMenuToggleReal()
    local gui = Instance.new("ScreenGui")
    gui.Name = "MenuToggleReal"
    gui.Parent = CoreGui
    gui.ResetOnSpawn = false
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 34, 0, 34)
    btn.Position = UDim2.new(1, -42, 0, 5)
    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn.BackgroundTransparency = 0.3
    btn.Text = "🐹"
    btn.TextColor3 = Color3.fromRGB(255, 200, 0)
    btn.TextSize = 16
    btn.Font = Enum.Font.GothamBold
    btn.Parent = gui
    btn.ZIndex = 999
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    
    local stroke = Instance.new("UIStroke", btn)
    stroke.Thickness = 1.5
    stroke.Color = Color3.fromRGB(255, 200, 0)
    stroke.Transparency = 0.5
    
    btn.MouseButton1Click:Connect(function()
        if MenuActive then
            if MenuGui then
                MenuGui:Destroy()
                MenuGui = nil
            end
            MenuActive = false
        else
            CreateRealMenu()
        end
    end)
        end-- ============================================================
-- HAMSTER LIVES - ULTIMATE BYPASS V12 (PART 4/10)
-- KONSOL KOMUTLARI | STATUS | BAŞLATMA
-- ============================================================

-- ============================================================
-- KONSOL KOMUTLARI (GERÇEK)
-- ============================================================
local function RunCommand(cmd)
    if cmd == "/help" then
        print("")
        print("========= HAMSTER V12 KOMUTLARI =========")
        print("/fly      - Uçma modu (Mobil/PC)")
        print("/god      - God mod (Ölümsüz)")
        print("/farm     - Auto Farm (Egg+Boss+Treadmill)")
        print("/status   - Bypass durumu")
        print("/killac   - Anti-cheat imha")
        print("/killremote - Remote imha")
        print("/stop     - Tüm modları kapat")
        print("=========================================")
        
    elseif cmd == "/fly" then
        if FlyActive then StopFly() else RealFly() end
        
    elseif cmd == "/god" then
        if GodModeActive then StopGodMode() else RealGodMode() end
        
    elseif cmd == "/farm" then
        if FarmActive then StopRealFarm() else StartRealFarm() end
        
    elseif cmd == "/status" then
        print("")
        print("========= BYPASS DURUMU =========")
        print("Anti-Cheat: " .. tostring(RealAntiCheatKill() > 0))
        print("God Mod: " .. tostring(GodModeActive))
        print("Fly: " .. tostring(FlyActive))
        print("Auto Farm: " .. tostring(FarmActive))
        print("Cihaz: " .. (isMobile and "MOBİL" or "PC"))
        print("Çalışma Süresi: " .. (os.time() - os.time()) .. " sn")
        print("=================================")
        
    elseif cmd == "/killac" then
        RealAntiCheatKill()
        
    elseif cmd == "/killremote" then
        RealRemoteKiller()
        
    elseif cmd == "/stop" then
        if FlyActive then StopFly() end
        if FarmActive then StopRealFarm() end
        if GodModeActive then StopGodMode() end
        print("[STOP] Tüm modlar kapatıldı.")
    end
end

-- ============================================================
-- CHAT DİNLEYİCİ
-- ============================================================
local function SetupChatListenerReal()
    local coreGui = CoreGui
    if not coreGui then return end
    
    local chat = coreGui:FindFirstChild("Chat")
    if chat then
        chat.ChildAdded:Connect(function(child)
            if child:IsA("TextLabel") then
                local msg = child.Text or ""
                if msg:sub(1, 1) == "/" then
                    RunCommand(msg)
                end
            end
        end)
    end
end

-- ============================================================
-- ACİL DURUM KAPATMA (F12)
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F12 then
        print("[EMERGENCY] Acil durum kapatma!")
        if FlyActive then StopFly() end
        if FarmActive then StopRealFarm() end
        if GodModeActive then StopGodMode() end
        script:Destroy()
    end
end)

-- ============================================================
-- BAŞLATMA
-- ============================================================
local function InitializeReal()
    print("")
    print("========================================")
    print("🐹 HAMSTER LIVES ULTIMATE BYPASS V12")
    print("========================================")
    print("📱 Cihaz: " .. (isMobile and "MOBİL" or "PC"))
    print("")
    
    -- BYPASS
    RealAntiCheatKill()
    RealRemoteKiller()
    
    -- EKRAN
    ShowRealBypassScreen()
    CreateMenuToggleReal()
    SetupChatListenerReal()
    
    print("")
    print("✅ ULTIMATE BYPASS V12 HAZIR!")
    print("   📌 Sağ üst 🐹 buton → Menü")
    print("   📌 /help → Komut listesi")
    print("   📌 F12 → Acil kapatma")
    print("========================================")
end

task.wait(0.5)
local ok, err = pcall(InitializeReal)
if not ok then
    print("[ERROR] Başlatma hatası: " .. tostring(err))
    -- Temel bypass çalışsın
    pcall(RealAntiCheatKill)
    pcall(RealRemoteKiller)
            end
