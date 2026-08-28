-- ============================================================
-- HAMSTER LIVES - PURE BYPASS V9
-- SADECE ANTİCHEAT BYPASS | FLY YOK | TP YOK | MENÜ YOK
-- AÇILIR BYPASS EDER BİTER | SONRA SESSİZ
-- ============================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

print("⚡ PURE BYPASS V9 BAŞLADI...")

-- ============================================================
-- ANTİCHEAT İMHA (TAM KAPATMA)
-- ============================================================
local function KillAllAntiCheat()
    local patterns = {
        "AntiCheat", "AC", "Security", "Protect", "Ban",
        "Kick", "Detect", "Monitor", "Guard", "Watch",
        "Patrol", "Enforce", "Validate", "Verify", "Scan",
        "Filter", "Block", "Flag", "Report", "Logger",
        "Hyperion", "Byfron", "Luau", "Bytecode", "VM",
        "Sandbox", "Isolate", "Restrict", "Limit", "Cap"
    }
    
    local total = 0
    for _, obj in ipairs(game:GetDescendants()) do
        if obj.Name then
            for _, p in ipairs(patterns) do
                if obj.Name:find(p) then
                    pcall(function()
                        if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                            obj.Disabled = true
                            total = total + 1
                        end
                        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                            obj:Destroy()
                            total = total + 1
                        end
                        if obj:IsA("BoolValue") or obj:IsA("IntValue") then
                            if obj.Name:lower():find("anti") or obj.Name:lower():find("cheat") or obj.Name:lower():find("detect") then
                                obj.Value = false
                                total = total + 1
                            end
                        end
                    end)
                    break
                end
            end
        end
    end
    
    print("[BYPASS] " .. total .. " anticheat nesnesi imha edildi.")
end

-- ============================================================
-- TÜM REMOTE'LARI İMHA
-- ============================================================
local function KillAllRemotes()
    local total = 0
    local containers = {
        ReplicatedStorage,
        game:GetService("ReplicatedFirst"),
        workspace,
        LocalPlayer:FindFirstChild("PlayerScripts"),
        LocalPlayer:FindFirstChild("PlayerGui")
    }
    
    for _, container in ipairs(containers) do
        if container then
            for _, obj in ipairs(container:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    pcall(function()
                        obj:Destroy()
                        total = total + 1
                    end)
                end
            end
        end
    end
    
    print("[BYPASS] " .. total .. " remote imha edildi.")
end

-- ============================================================
-- SCRİPT KENDİNİ GİZLE
-- ============================================================
local function HideMyself()
    pcall(function()
        script.Name = "System_" .. math.random(1000, 9999)
        script.Parent = ReplicatedStorage
    end)
    print("[BYPASS] Script gizlendi.")
end

-- ============================================================
-- BYPASS EKRANI (GÖSTER - KAPAT)
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
    frame.Size = UDim2.new(0, 0, 0, 50)
    frame.Position = UDim2.new(0.5, -150, 0.5, -25)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.3
    frame.Parent = gui
    frame.ZIndex = 999
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(255, 200, 0)
    stroke.Transparency = 0.6
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "🐹 HAMSTER LIVES BYPASS AKTİF•"
    label.TextColor3 = Color3.fromRGB(255, 200, 0)
    label.TextSize = 18
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    label.ZIndex = 1000
    
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
-- BAŞLAT - TEK SEFER
-- ============================================================
task.wait(0.5)

-- BYPASS İŞLEMLERİ (SADECE BUNLAR)
KillAllAntiCheat()
KillAllRemotes()
HideMyself()
ShowBypassScreen()

print("")
print("========================================")
print("⚡ PURE BYPASS V9 HAZIR!")
print("   ✅ Anti-cheat tamamen kapatıldı")
print("   ✅ Tüm remote'lar imha edildi")
print("   ✅ Script gizlendi")
print("   ✅ Bypass ekranı gösterildi")
print("   ✅ İŞLEM TAMAMLANDI - SESSİZ")
print("========================================")
