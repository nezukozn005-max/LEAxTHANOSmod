-- ============================================================
-- HAMSTER LIVES - ULTIMATE BYPASS ENGINE V11 (PART 1/10)
-- KERNEL | ANTİCHEAT KILLER | REMOTE KILLER | SELF HIDE
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

print("⚡ ULTIMATE BYPASS V11 BAŞLADI...")

-- ============================================================
-- KONFİG (MERKEZİ YÖNETİM)
-- ============================================================
local CONFIG = {
    ANTICHEAT_KILL = true,
    REMOTE_KILL = true,
    SCRIPT_HIDE = true,
    GOD_MODE = false,
    ANTIKICK = false,
    FLY = false,
    AUTO_FARM = false,
    NO_FALL = false,
    WALK_SPEED = 16,
    JUMP_POWER = 50,
    FLY_SPEED = 60,
    FARM_INTERVAL = 0.3
}

local STATE = {
    Active = true,
    AntiCheatKilled = false,
    RemoteKilled = false,
    ScriptHidden = false,
    GodModeActive = false,
    AntiKickActive = false,
    FlyActive = false,
    AutoFarmActive = false,
    NoFallActive = false,
    FlyVelocity = nil,
    FlyPosition = nil,
    FarmThread = nil,
    GodModeConn = nil,
    AntiKickConn = nil,
    StartTime = os.time()
}

-- ============================================================
-- 1. ANTİ-CHEAT KERNEL İMHA (TAM KAPATMA)
-- ============================================================
local function KillAntiCheat()
    if not CONFIG.ANTICHEAT_KILL then return end
    
    local patterns = {
        "AntiCheat", "AC", "Security", "Protect", "Ban",
        "Kick", "Detect", "Monitor", "Guard", "Watch",
        "Patrol", "Enforce", "Validate", "Verify", "Scan",
        "Filter", "Block", "Flag", "Report", "Logger",
        "Hyperion", "Byfron", "Luau", "Bytecode", "VM",
        "Sandbox", "Isolate", "Restrict", "Limit", "Cap",
        "Track", "Spy", "Observer", "Sentinel", "Watcher",
        "Audit", "Check", "Control", "Inspect", "Review"
    }
    
    local killed = 0
    local total = 0
    
    for _, obj in ipairs(game:GetDescendants()) do
        if obj.Name then
            total = total + 1
            for _, p in ipairs(patterns) do
                if obj.Name:find(p) then
                    pcall(function()
                        if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                            obj.Disabled = true
                            killed = killed + 1
                        end
                        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                            if obj.Name:find("Anti") or obj.Name:find("Cheat") or obj.Name:find("Detect") or obj.Name:find("Report") then
                                obj:Destroy()
                                killed = killed + 1
                            end
                        end
                        if obj:IsA("BoolValue") or obj:IsA("IntValue") or obj:IsA("NumberValue") then
                            if obj.Name:find("Anti") or obj.Name:find("Cheat") or obj.Name:find("Detect") or obj.Name:find("Ban") then
                                obj.Value = false
                                killed = killed + 1
                            end
                        end
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
    
    STATE.AntiCheatKilled = true
    print("[AC] " .. killed .. " anticheat nesnesi imha edildi. (" .. total .. " tarandı)")
    return killed
end

-- ============================================================
-- 2. SMART REMOTE KILLER (SADECE ZARARLILAR)
-- ============================================================
local function KillRemotes()
    if not CONFIG.REMOTE_KILL then return end
    
    local killed = 0
    local containers = {
        ReplicatedStorage,
        game:GetService("ReplicatedFirst"),
        game:GetService("ScriptContext"),
        game:GetService("ServerScriptService"),
        game:GetService("ServerStorage"),
        workspace,
        LocalPlayer:FindFirstChild("PlayerScripts")
    }
    
    local killPatterns = {
        "Anti", "Cheat", "Detect", "Report", "Ban",
        "Kick", "Monitor", "Guard", "Security", "Protect",
        "Audit", "Inspect", "Review", "Check", "Scan"
    }
    
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
    
    STATE.RemoteKilled = true
    print("[REMOTE] " .. killed .. " zararlı remote imha edildi.")
    return killed
end

-- ============================================================
-- 3. SCRİPT KENDİNİ GİZLE (DERİN)
-- ============================================================
local function HideScript()
    if not CONFIG.SCRIPT_HIDE then return end
    
    local script = script
    if not script then return end
    
    local fakeNames = {
        "GameModule", "UIHandler", "NetworkManager", "DataStore",
        "PlayerController", "CameraSystem", "AudioManager", "EventBus",
        "StateManager", "ResourceLoader", "SceneManager", "InputHandler"
    }
    
    pcall(function()
        script.Name = fakeNames[math.random(1, #fakeNames)] .. "_" .. os.time() .. "_" .. math.random(100, 999)
    end)
    
    pcall(function()
        script.ClassName = "ModuleScript"
    end)
    
    pcall(function()
        script.Parent = ReplicatedStorage
    end)
    
    pcall(function()
        local fakeSource = "--[[ " .. string.rep("-", math.random(30, 60)) .. " ]]"
        fakeSource = fakeSource .. "\n-- System Module v" .. math.random(1, 9) .. "." .. math.random(0, 9)
        fakeSource = fakeSource .. "\n-- Generated: " .. os.date("%Y-%m-%d %H:%M:%S")
        script.Source = fakeSource
    end)
    
    STATE.ScriptHidden = true
    print("[HIDE] Script derinlemesine gizlendi.")
end

-- ============================================================
-- 4. GOD MOD (HASAR ALMAZ)
-- ============================================================
local function EnableGodMode()
    if STATE.GodModeActive then return end
    STATE.GodModeActive = true
    
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    
    STATE.GodModeConn = hum.HealthChanged:Connect(function(health)
        local old = hum.Health
        if health < old then
            hum.Health = hum.MaxHealth
            print("[GOD] Hasar engellendi!")
        end
    end)
    
    print("[GOD] God mod aktif!")
end

local function DisableGodMode()
    if not STATE.GodModeActive then return end
    STATE.GodModeActive = false
    if STATE.GodModeConn then
        STATE.GodModeConn:Disconnect()
        STATE.GodModeConn = nil
    end
    print("[GOD] God mod kapatıldı.")
end

-- ============================================================
-- 5. ANTİ-KICK (ATILMA ENGELLE)
-- ============================================================
local function EnableAntiKick()
    if STATE.AntiKickActive then return end
    STATE.AntiKickActive = true
    
    -- Kick remote'larını engelle
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            if obj.Name:find("Kick") or obj.Name:find("Ban") or obj.Name:find("Remove") then
                pcall(function()
                    local old = obj.FireServer
                    obj.FireServer = function(self, ...)
                        print("[ANTIKICK] Kick remote engellendi: " .. self.Name)
                        return
                    end
                end)
            end
        end
    end
    
    STATE.AntiKickConn = Players.PlayerRemoving:Connect(function(player)
        if player == LocalPlayer then
            print("[ANTIKICK] Atılma engellendi!")
            return
        end
    end)
    
    print("[ANTIKICK] Anti-kick aktif!")
end

local function DisableAntiKick()
    if not STATE.AntiKickActive then return end
    STATE.AntiKickActive = false
    if STATE.AntiKickConn then
        STATE.AntiKickConn:Disconnect()
        STATE.AntiKickConn = nil
    end
    print("[ANTIKICK] Anti-kick kapatıldı.")
end

-- ============================================================
-- 6. NO FALL DAMAGE (DÜŞME HASARI YOK)
-- ============================================================
local function EnableNoFall()
    if STATE.NoFallActive then return end
    STATE.NoFallActive = true
    CONFIG.NO_FALL = true
    
    task.spawn(function()
        while STATE.NoFallActive do
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                end
            end
            task.wait(0.5)
        end
    end)
    
    print("[FALL] Düşme hasarı engellendi!")
end

local function DisableNoFall()
    STATE.NoFallActive = false
    CONFIG.NO_FALL = false
    print("[FALL] Düşme hasarı koruması kapatıldı.")
end

-- ============================================================
-- 7. FLY SİSTEMİ (GELİŞMİŞ)
-- ============================================================
local function StartFly()
    if STATE.FlyActive then return end
    STATE.FlyActive = true
    CONFIG.FLY = true
    
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local hum = char:FindFirstChild("Humanoid")
    if hum then
        hum.PlatformStand = true
    end
    
    STATE.FlyVelocity = Instance.new("BodyVelocity")
    STATE.FlyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    STATE.FlyVelocity.Velocity = Vector3.new(0, 0, 0)
    STATE.FlyVelocity.Parent = hrp
    
    STATE.FlyPosition = Instance.new("BodyPosition")
    STATE.FlyPosition.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    STATE.FlyPosition.Position = hrp.Position
    STATE.FlyPosition.Parent = hrp
    
    print("[FLY] Uçuş aktif! (WASD, Space↑, Shift↓)")
    
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if not STATE.FlyActive then return end
        if not STATE.FlyVelocity then return end
        
        local speed = CONFIG.FLY_SPEED
        local dir = Vector3.new(0, 0, 0)
        
        if input.KeyCode == Enum.KeyCode.W then dir = dir + Vector3.new(0, 0, -1) end
        if input.KeyCode == Enum.KeyCode.S then dir = dir + Vector3.new(0, 0, 1) end
        if input.KeyCode == Enum.KeyCode.A then dir = dir + Vector3.new(-1, 0, 0) end
        if input.KeyCode == Enum.KeyCode.D then dir = dir + Vector3.new(1, 0, 0) end
        if input.KeyCode == Enum.KeyCode.Space then 
            STATE.FlyVelocity.Velocity = Vector3.new(0, speed, 0)
        end
        if input.KeyCode == Enum.KeyCode.LeftShift then
            STATE.FlyVelocity.Velocity = Vector3.new(0, -speed, 0)
        end
        
        if dir ~= Vector3.new(0, 0, 0) then
            local cam = workspace.CurrentCamera
            local forward = cam.CFrame.LookVector
            local right = cam.CFrame.RightVector
            local moveDir = (forward * -dir.Z + right * dir.X)
            moveDir = moveDir.Unit * speed
            STATE.FlyVelocity.Velocity = Vector3.new(moveDir.X, STATE.FlyVelocity.Velocity.Y, moveDir.Z)
        end
    end)
end

local function StopFly()
    if not STATE.FlyActive then return end
    STATE.FlyActive = false
    CONFIG.FLY = false
    
    if STATE.FlyVelocity then
        STATE.FlyVelocity:Destroy()
        STATE.FlyVelocity = nil
    end
    if STATE.FlyPosition then
        STATE.FlyPosition:Destroy()
        STATE.FlyPosition = nil
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
-- HAMSTER LIVES - ULTIMATE BYPASS ENGINE V11 (PART 2/10)
-- AUTO FARM | EGG TOPLAMA | BOSS RIDE | TREADMILL
-- ============================================================

-- ============================================================
-- 8. HEDEF BULUCU (EGG, BOSS, TREADMILL)
-- ============================================================
local function FindNearestEgg()
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
            if name:find("egg") or name:find("carry") or name:find("collect") or name:find("pickup") then
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

local function FindNearestBoss()
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
            if name:find("boss") or name:find("guard") or name:find("enemy") then
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

local function FindNearestTreadmill()
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
            if name:find("treadmill") or name:find("belt") or name:find("run") or name:find("mill") then
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
-- 9. MOVE TO TARGET (SMOOTH TWEEN)
-- ============================================================
local function MoveToTarget(targetPos, speed)
    speed = speed or 0.5
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local direction = (targetPos - hrp.Position).Unit
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {char}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local ray = Workspace:Raycast(hrp.Position, direction * 5, rayParams)
    if ray then
        local newDir = (targetPos - hrp.Position + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3))).Unit
        targetPos = hrp.Position + newDir * 5
    end
    
    local tween = TweenService:Create(hrp, TweenInfo.new(speed, Enum.EasingStyle.Linear), {
        CFrame = CFrame.new(targetPos)
    })
    tween:Play()
    tween.Completed:Wait()
end

-- ============================================================
-- 10. EGG PICKUP (TAM)
-- ============================================================
local function PickupEgg(eggObj)
    if not eggObj then return false end
    
    print("[EGG] Egg alınıyor: " .. eggObj.Name)
    
    local targetPos = eggObj.Position + Vector3.new(0, 2, 0)
    MoveToTarget(targetPos, 0.3)
    
    pcall(function()
        UserInputService:SetKeyDown(Enum.KeyCode.E)
        task.wait(0.1)
        UserInputService:SetKeyUp(Enum.KeyCode.E)
    end)
    
    for _, prompt in ipairs(eggObj:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            pcall(function()
                prompt:Prompt()
                print("[EGG] Prompt: " .. prompt.Name)
            end)
        end
    end
    
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            local name = remote.Name:lower()
            if name:find("egg") or name:find("carry") or name:find("collect") then
                pcall(function()
                    remote:FireServer()
                    print("[EGG] Remote: " .. remote.Name)
                end)
            end
        end
    end
    
    print("[EGG] Egg alındı!")
    return true
end

-- ============================================================
-- 11. BOSS RIDE (BOSSU KULLAN)
-- ============================================================
local BossRideActive = false
local BossRideTarget = nil

local function RideBoss(bossObj)
    if not bossObj then return false end
    if BossRideActive then return true end
    
    print("[BOSS] Boss'a biniliyor: " .. bossObj.Name)
    
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local bossCF = CFrame.new(bossObj.Position)
    local ridePos = bossObj.Position + (bossCF.LookVector * -3) + Vector3.new(0, 5, 0)
    MoveToTarget(ridePos, 0.2)
    
    BossRideActive = true
    BossRideTarget = bossObj
    
    task.spawn(function()
        while BossRideActive and BossRideTarget and BossRideTarget.Parent do
            pcall(function()
                local newBossCF = CFrame.new(BossRideTarget.Position)
                local newRidePos = BossRideTarget.Position + (newBossCF.LookVector * -3) + Vector3.new(0, 5, 0)
                hrp.CFrame = CFrame.new(newRidePos)
            end)
            task.wait(0.05)
        end
        BossRideActive = false
    end)
    
    print("[BOSS] Boss'a başarıyla binildi!")
    return true
end

local function StopRideBoss()
    BossRideActive = false
    BossRideTarget = nil
    print("[BOSS] Boss'tan inildi.")
end

-- ============================================================
-- 12. TREADMILL KULLANIMI
-- ============================================================
local TreadmillActive = false
local TreadmillTarget = nil

local function UseTreadmill(treadmillObj)
    if not treadmillObj then return false end
    if TreadmillActive then return true end
    
    print("[TREADMILL] Koşu bandı kullanılıyor: " .. treadmillObj.Name)
    
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local targetPos = treadmillObj.Position + Vector3.new(0, 3, 0)
    MoveToTarget(targetPos, 0.2)
    
    TreadmillActive = true
    TreadmillTarget = treadmillObj
    
    task.spawn(function()
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = 16
        end
        
        while TreadmillActive and TreadmillTarget and TreadmillTarget.Parent do
            pcall(function()
                local forward = CFrame.new(TreadmillTarget.Position).LookVector
                local newPos = hrp.Position + forward * 0.5
                hrp.CFrame = CFrame.new(newPos)
            end)
            task.wait(0.05)
        end
        TreadmillActive = false
    end)
    
    print("[TREADMILL] Koşu bandı aktif!")
    return true
end

local function StopTreadmill()
    TreadmillActive = false
    TreadmillTarget = nil
    print("[TREADMILL] Koşu bandı durduruldu.")
end

-- ============================================================
-- 13. AUTO FARM (ANA DÖNGÜ)
-- ============================================================
local function StartAutoFarm()
    if STATE.AutoFarmActive then return end
    STATE.AutoFarmActive = true
    CONFIG.AUTO_FARM = true
    
    print("[FARM] Auto farm başlatıldı!")
    
    STATE.FarmThread = task.spawn(function()
        while STATE.AutoFarmActive do
            -- 1. EGG
            local egg, eggDist = FindNearestEgg()
            if egg and eggDist < 30 then
                PickupEgg(egg)
                task.wait(0.5)
            end
            
            -- 2. BOSS
            local boss, bossDist = FindNearestBoss()
            if boss and bossDist < 20 and not BossRideActive then
                RideBoss(boss)
                task.wait(0.5)
            end
            
            -- 3. TREADMILL
            local treadmill, treadDist = FindNearestTreadmill()
            if treadmill and treadDist < 15 and not TreadmillActive then
                UseTreadmill(treadmill)
                task.wait(0.5)
            end
            
            -- 4. HEDEF YOKSA RASTGELE
            if not egg and not boss and not treadmill then
                local char = LocalPlayer.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local randomPos = hrp.Position + Vector3.new(math.random(-30, 30), 0, math.random(-30, 30))
                        MoveToTarget(randomPos, 0.5)
                    end
                end
            end
            
            task.wait(CONFIG.FARM_INTERVAL)
        end
    end)
end

local function StopAutoFarm()
    if not STATE.AutoFarmActive then return end
    STATE.AutoFarmActive = false
    CONFIG.AUTO_FARM = false
    
    if STATE.FarmThread then
        coroutine.close(STATE.FarmThread)
        STATE.FarmThread = nil
    end
    
    StopRideBoss()
    StopTreadmill()
    
    print("[FARM] Auto farm durduruldu.")
  end-- ============================================================
-- HAMSTER LIVES - ULTIMATE BYPASS ENGINE V11 (PART 3/10)
-- MENÜ (SAĞ ÜST) | KONSOL KOMUTLARI | BYPASS EKRANI
-- ============================================================

-- ============================================================
-- 14. BYPASS EKRANI (AÇILIR-KAPANIR)
-- ============================================================
local function ShowBypassScreen()
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
    frame.Size = UDim2.new(0, 0, 0, 55)
    frame.Position = UDim2.new(0.5, -170, 0.5, -27.5)
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
    label.Text = "🐹 HAMSTER LIVES ULTIMATE BYPASS"
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
    subLabel.Text = "⚡ v11 | " .. (STATE.AntiCheatKilled and "✅ AC" or "❌ AC") .. " | " .. (STATE.RemoteKilled and "✅ REMOTE" or "❌ REMOTE")
    subLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    subLabel.TextSize = 10
    subLabel.Font = Enum.Font.Gotham
    subLabel.TextXAlignment = Enum.TextXAlignment.Left
    subLabel.Parent = frame
    subLabel.ZIndex = 1000
    
    task.spawn(function()
        TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 340, 0, 55),
            Position = UDim2.new(0.5, -170, 0.5, -27.5)
        }):Play()
        task.wait(2.0)
        TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 55),
            Position = UDim2.new(0.5, 0, 0.5, -27.5)
        }):Play()
        task.wait(0.5)
        gui:Destroy()
    end)
end

-- ============================================================
-- 15. MENÜ (SAĞ ÜST - KARANLIK TEMA)
-- ============================================================
local MenuActive = false
local MenuGui = nil

local function CreateMenu()
    local old = CoreGui:FindFirstChild("UltimateMenu")
    if old then old:Destroy() end
    
    MenuGui = Instance.new("ScreenGui")
    MenuGui.Name = "UltimateMenu"
    MenuGui.Parent = CoreGui
    MenuGui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 160, 0, 150)
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
    title.Text = "🐹 HAMSTER BYPASS"
    title.TextColor3 = Color3.fromRGB(255, 200, 0)
    title.TextSize = 9
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame
    title.ZIndex = 1000
    
    -- FLY BUTON
    local flyBtn = Instance.new("TextButton")
    flyBtn.Size = UDim2.new(0.9, -5, 0, 20)
    flyBtn.Position = UDim2.new(0, 5, 0, 20)
    flyBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
    flyBtn.Text = "🟢 FLY"
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
        if STATE.FlyActive then
            StopFly()
            flyBtn.Text = "🟢 FLY"
            flyBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
        else
            StartFly()
            flyBtn.Text = "🔴 FLY"
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
        if STATE.GodModeActive then
            DisableGodMode()
            godBtn.Text = "🟢 GOD"
            godBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        else
            EnableGodMode()
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
        if STATE.AutoFarmActive then
            StopAutoFarm()
            farmBtn.Text = "🟢 FARM"
            farmBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 0)
        else
            StartAutoFarm()
            farmBtn.Text = "🔴 FARM"
            farmBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        end
    end)
    
    -- NO FALL BUTON
    local fallBtn = Instance.new("TextButton")
    fallBtn.Size = UDim2.new(0.9, -5, 0, 20)
    fallBtn.Position = UDim2.new(0, 5, 0, 89)
    fallBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
    fallBtn.Text = "🟢 NO FALL"
    fallBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    fallBtn.TextSize = 9
    fallBtn.Font = Enum.Font.GothamBold
    fallBtn.Parent = frame
    fallBtn.ZIndex = 1000
    Instance.new("UICorner", fallBtn).CornerRadius = UDim.new(0, 4)
    
    fallBtn.MouseEnter:Connect(function()
        fallBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
    end)
    fallBtn.MouseLeave:Connect(function()
        fallBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
    end)
    
    fallBtn.MouseButton1Click:Connect(function()
        if STATE.NoFallActive then
            DisableNoFall()
            fallBtn.Text = "🟢 NO FALL"
            fallBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
        else
            EnableNoFall()
            fallBtn.Text = "🔴 NO FALL"
            fallBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        end
    end)
    
    -- ANTIKICK BUTON
    local kickBtn = Instance.new("TextButton")
    kickBtn.Size = UDim2.new(0.9, -5, 0, 20)
    kickBtn.Position = UDim2.new(0, 5, 0, 112)
    kickBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    kickBtn.Text = "🟢 ANTI-KICK"
    kickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    kickBtn.TextSize = 9
    kickBtn.Font = Enum.Font.GothamBold
    kickBtn.Parent = frame
    kickBtn.ZIndex = 1000
    Instance.new("UICorner", kickBtn).CornerRadius = UDim.new(0, 4)
    
    kickBtn.MouseEnter:Connect(function()
        kickBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end)
    kickBtn.MouseLeave:Connect(function()
        kickBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    end)
    
    kickBtn.MouseButton1Click:Connect(function()
        if STATE.AntiKickActive then
            DisableAntiKick()
            kickBtn.Text = "🟢 ANTI-KICK"
            kickBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        else
            EnableAntiKick()
            kickBtn.Text = "🔴 ANTI-KICK"
            kickBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        end
    end)
    
    -- KAPAT BUTON
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.9, -5, 0, 20)
    closeBtn.Position = UDim2.new(0, 5, 0, 135)
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
-- 16. MENÜ AÇ/KAPA BUTONU (SAĞ ÜST KÜÇÜK)
-- ============================================================
local function CreateMenuToggle()
    local gui = Instance.new("ScreenGui")
    gui.Name = "MenuToggle"
    gui.Parent = CoreGui
    gui.ResetOnSpawn = false
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 32, 0, 32)
    btn.Position = UDim2.new(1, -40, 0, 5)
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
            CreateMenu()
        end
    end)
    end-- ============================================================
-- HAMSTER LIVES - ULTIMATE BYPASS ENGINE V11 (PART 4/10)
-- KONSOL KOMUTLARI | STATUS | KORUMA | BAŞLATMA
-- ============================================================

-- ============================================================
-- 17. KONSOL KOMUT SİSTEMİ
-- ============================================================
local function ExecuteConsoleCommand(cmd)
    if cmd == "/help" then
        print("")
        print("========= HAMSTER ULTIMATE BYPASS KOMUTLARI =========")
        print("/fly      - Uçma modu aç/kapa")
        print("/god      - God mod aç/kapa")
        print("/farm     - Auto farm aç/kapa")
        print("/nofall   - Düşme hasarı engelle aç/kapa")
        print("/antikick - Atılma engelle aç/kapa")
        print("/status   - Bypass durumu")
        print("/killac   - Anti-cheat imha (tekrar)")
        print("/killremote - Zararlı remote'ları imha")
        print("/hide     - Script'i gizle")
        print("/stop     - Tüm modları kapat")
        print("====================================================")
        
    elseif cmd == "/fly" then
        if STATE.FlyActive then StopFly() else StartFly() end
        
    elseif cmd == "/god" then
        if STATE.GodModeActive then DisableGodMode() else EnableGodMode() end
        
    elseif cmd == "/farm" then
        if STATE.AutoFarmActive then StopAutoFarm() else StartAutoFarm() end
        
    elseif cmd == "/nofall" then
        if STATE.NoFallActive then DisableNoFall() else EnableNoFall() end
        
    elseif cmd == "/antikick" then
        if STATE.AntiKickActive then DisableAntiKick() else EnableAntiKick() end
        
    elseif cmd == "/status" then
        print("")
        print("========= ULTIMATE BYPASS DURUMU =========")
        print("Aktif: " .. tostring(STATE.Active))
        print("Anti-Cheat: " .. tostring(STATE.AntiCheatKilled))
        print("Remote Killer: " .. tostring(STATE.RemoteKilled))
        print("Script Gizli: " .. tostring(STATE.ScriptHidden))
        print("God Mod: " .. tostring(STATE.GodModeActive))
        print("Anti-Kick: " .. tostring(STATE.AntiKickActive))
        print("Fly: " .. tostring(STATE.FlyActive))
        print("Auto Farm: " .. tostring(STATE.AutoFarmActive))
        print("No Fall: " .. tostring(STATE.NoFallActive))
        print("Çalışma Süresi: " .. (os.time() - STATE.StartTime) .. " sn")
        print("=========================================")
        
    elseif cmd == "/killac" then
        KillAntiCheat()
        
    elseif cmd == "/killremote" then
        KillRemotes()
        
    elseif cmd == "/hide" then
        HideScript()
        
    elseif cmd == "/stop" then
        print("[STOP] Tüm modlar kapatılıyor...")
        if STATE.FlyActive then StopFly() end
        if STATE.AutoFarmActive then StopAutoFarm() end
        if STATE.GodModeActive then DisableGodMode() end
        if STATE.NoFallActive then DisableNoFall() end
        if STATE.AntiKickActive then DisableAntiKick() end
        print("[STOP] Tüm modlar kapatıldı.")
    end
end

-- ============================================================
-- 18. CHAT DİNLEYİCİ (KOMUTLAR İÇİN)
-- ============================================================
local function SetupChatListener()
    local coreGui = CoreGui
    if not coreGui then return end
    
    local chat = coreGui:FindFirstChild("Chat")
    if chat then
        chat.ChildAdded:Connect(function(child)
            if child:IsA("TextLabel") then
                local msg = child.Text or ""
                if msg:sub(1, 1) == "/" then
                    ExecuteConsoleCommand(msg)
                end
            end
        end)
    end
end

-- ============================================================
-- 19. KARAKTER KORUMA (ÖLÜM SONRASI YENİDEN)
-- ============================================================
local function SetupCharacterProtection()
    LocalPlayer.CharacterAdded:Connect(function(char)
        print("[PROTECT] Karakter yeniden doğdu!")
        task.wait(1)
        
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.MaxHealth = 100
            hum.Health = 100
            if CONFIG.WALK_SPEED then
                hum.WalkSpeed = CONFIG.WALK_SPEED
            end
            if CONFIG.JUMP_POWER then
                hum.JumpPower = CONFIG.JUMP_POWER
            end
        end
        
        if STATE.GodModeActive then
            EnableGodMode()
        end
    end)
end

-- ============================================================
-- 20. BAĞLANTI TEMİZLEME (GÜVENLİ ÇIKIŞ)
-- ============================================================
local function CleanupAll()
    if STATE.FlyActive then StopFly() end
    if STATE.AutoFarmActive then StopAutoFarm() end
    if STATE.GodModeActive then DisableGodMode() end
    if STATE.NoFallActive then DisableNoFall() end
    if STATE.AntiKickActive then DisableAntiKick() end
    
    if STATE.FarmThread then
        coroutine.close(STATE.FarmThread)
        STATE.FarmThread = nil
    end
    
    print("[CLEAN] Tüm bağlantılar temizlendi.")
end

-- ============================================================
-- 21. ACİL DURUM KAPATMA (F12)
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F12 then
        print("[EMERGENCY] Acil durum kapatma! (F12)")
        CleanupAll()
        STATE.Active = false
        script:Destroy()
    end
end)

-- ============================================================
-- 22. ANA BAŞLATMA (ENTEGRE)
-- ============================================================
local function Initialize()
    print("")
    print("========================================")
    print("🐹 HAMSTER LIVES ULTIMATE BYPASS V11")
    print("========================================")
    
    -- 1. BYPASS
    KillAntiCheat()
    KillRemotes()
    HideScript()
    
    -- 2. KORUMA
    SetupCharacterProtection()
    
    -- 3. EKRAN
    ShowBypassScreen()
    CreateMenuToggle()
    SetupChatListener()
    
    -- 4. DURUM
    print("")
    print("✅ ULTIMATE BYPASS V11 HAZIR!")
    print("   📌 Sağ üstteki 🐹 butonuna tıkla → Menü")
    print("   📌 /help → Komut listesi")
    print("   📌 F12 → Acil durum kapatma")
    print("========================================")
end

-- ============================================================
-- 23. GÜVENLİ BAŞLAT
-- ============================================================
task.wait(0.5)
local success, err = pcall(Initialize)
if not success then
    print("[ERROR] Başlatma hatası: " .. tostring(err))
    -- Hata durumunda sadece temel bypass çalışsın
    pcall(KillAntiCheat)
    pcall(KillRemotes)
    pcall(HideScript)
      end
