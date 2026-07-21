-- ==============================================================================
-- LEA MOD - ULTRA COMPACT MOBILE MATRIX & MODULE FIX V3.6
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

print("⚡ [LEA PATCH]: Ultra kompakt modül motoru başlatılıyor...")

getgenv().LeaState = getgenv().LeaState or {
    Modules = {
        Cube = false,
        AutoHop = false,
        PetStealth = false,
        AntiKick = true
    },
    Settings = {
        MinPlayers = 1,
        MaxPlayers = 12
    },
    BasePosition = nil,
    IsReturning = false
}

local Lea = getgenv().LeaState

-- ==============================================================================
-- 1. BYPASS & EXECUTION HOOKS (DÜZELTİLMİŞ KONTROL)
-- ==============================================================================
pcall(function()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if (method == "Kick" or method == "Ban") and Lea.Modules.AntiKick then
            return
        end
        return oldNamecall(self, unpack(args))
    end)
    setreadonly(mt, true)
end)

-- ==============================================================================
-- 2. MODÜL FONKSİYONLARI (KÜP, BASE, HOP, STEALTH)
-- ==============================================================================
local cubePart = nil

local function ToggleCube(state)
    Lea.Modules.Cube = state
    pcall(function()
        if state then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and not cubePart then
                cubePart = Instance.new("Part")
                cubePart.Name = "LeaCompactCube"
                cubePart.Size = Vector3.new(2, 0.3, 2)
                cubePart.Anchored = false
                cubePart.CanCollide = false
                cubePart.Massless = true
                cubePart.Material = Enum.Material.Neon
                cubePart.Color = Color3.fromRGB(0, 255, 200)
                cubePart.Transparency = 0.2
                cubePart.Parent = Workspace
            end
        else
            if cubePart then
                cubePart:Destroy()
                cubePart = nil
            end
        end
    end)
end

local function SetBase()
    pcall(function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            Lea.BasePosition = hrp.Position
        end
    end)
end

local function ReturnBase()
    if not Lea.BasePosition then return end
    Lea.IsReturning = true
    task.spawn(function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        while hrp and Lea.IsReturning do
            if (hrp.Position - Lea.BasePosition).Magnitude < 3 then
                Lea.IsReturning = false
                break
            end
            hrp.CFrame = CFrame.new(hrp.Position:Lerp(Lea.BasePosition, 0.25))
            task.wait()
        end
    end)
end

local function InstantHop()
    pcall(function()
        local servers = {}
        local success, res = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)
        if success and res and res.data then
            for _, s in ipairs(res.data) do
                if s.playing and s.playing < s.maxPlayers then
                    table.insert(servers, s.id)
                end
            end
        end
        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
        end
    end)
end

-- ==============================================================================
-- 3. HEARTBEAT DÖNGÜSÜ (TÜM AKTİF MODÜLLER)
-- ==============================================================================
RunService.Heartbeat:Connect(function()
    pcall(function()
        -- Küp Takip
        if Lea.Modules.Cube and cubePart then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                cubePart.CFrame = hrp.CFrame * CFrame.new(0, -3.2, 0)
            end
        end

        -- Pet Stealth (180 Derece + Yerin İçi)
        if Lea.Modules.PetStealth then
            local char = LocalPlayer.Character
            if char then
                for _, tool in ipairs(char:GetChildren()) do
                    if tool:IsA("Tool") and (tool.Name:find("Pet") or tool.Name:find("Brainrot") or tool.Name:find("Secret")) then
                        local handle = tool:FindFirstChild("Handle") or tool:FindFirstChild("Part")
                        if handle then
                            handle.CFrame = handle.CFrame * CFrame.Angles(0, math.rad(180), 0) + Vector3.new(0, -9999, 0)
                            handle.Transparency = 1
                            handle.CanCollide = false
                        end
                    end
                end
            end
        end

        -- Auto Hop Tetikleyici
        if Lea.Modules.AutoHop then
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj:IsA("Model") and (obj.Name:find("Secret") or obj.Name:find("Brainrot")) then
                    InstantHop()
                    break
                end
            end
        end
    end)
end)

-- ==============================================================================
-- 4. ÇOK KÜÇÜLTÜLMÜŞ MOBİL ARAYÜZ (COMPACT UI)
-- ==============================================================================
local function BuildCompactUI()
    pcall(function()
        if CoreGui:FindFirstChild("LeaCompactGui") then
            CoreGui.LeaCompactGui:Destroy()
        end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "LeaCompactGui"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = CoreGui

        -- Mikro Boyutlu Ana Çerçeve (140x170)
        local mainFrame = Instance.new("Frame")
        mainFrame.Size = UDim2.new(0, 140, 0, 170)
        mainFrame.Position = UDim2.new(0.5, -70, 0.4, -85)
        mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
        mainFrame.BackgroundTransparency = 0.1
        mainFrame.Active = true
        mainFrame.Draggable = true
        mainFrame.Parent = screenGui
        Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 6)

        -- Başlık
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -20, 0, 20)
        title.Position = UDim2.new(0, 5, 0, 2)
        title.BackgroundTransparency = 1
        title.Text = "LEA MICRO"
        title.TextColor3 = Color3.fromRGB(0, 255, 200)
        title.TextSize = 10
        title.Font = Enum.Font.GothamBold
        title.Parent = mainFrame

        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 16, 0, 16)
        closeBtn.Position = UDim2.new(1, -18, 0, 3)
        closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        closeBtn.Text = "X"
        closeBtn.TextColor3 = Color3.new(1, 1, 1)
        closeBtn.TextSize = 8
        closeBtn.Parent = mainFrame
        Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 3)

        -- Kompakt Buton Oluşturucu
        local yPos = 24
        local function AddMicroBtn(txt, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 20)
            btn.Position = UDim2.new(0, 5, 0, yPos)
            btn.BackgroundColor3 = Color3.fromRGB(25, 32, 44)
            btn.Text = txt
            btn.TextColor3 = Color3.fromRGB(220, 220, 220)
            btn.TextSize = 8
            btn.Font = Enum.Font.GothamMedium
            btn.Parent = mainFrame
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

            local active = false
            btn.MouseButton1Click:Connect(function()
                active = not active
                btn.BackgroundColor3 = active and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(25, 32, 44)
                callback(active)
            end)
            yPos = yPos + 22
        end

        local function AddMicroAction(txt, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 20)
            btn.Position = UDim2.new(0, 5, 0, yPos)
            btn.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
            btn.Text = txt
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.TextSize = 8
            btn.Font = Enum.Font.GothamBold
            btn.Parent = mainFrame
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

            btn.MouseButton1Click:Connect(callback)
            yPos = yPos + 22
        end

        AddMicroBtn("Küp Modu", function(v) ToggleCube(v) end)
        AddMicroBtn("Pet Stealth", function(v) Lea.Modules.PetStealth = v end)
        AddMicroBtn("Auto-Hop", function(v) Lea.Modules.AutoHop = v end)
        AddMicroAction("Base Kaydet", function() SetBase() end)
        AddMicroAction("Base'e Dön", function() ReturnBase() end)

        -- Küçültülmüş Açma/Kapama İkonu
        local toggleIcon = Instance.new("TextButton")
        toggleIcon.Size = UDim2.new(0, 30, 0, 16)
        toggleIcon.Position = UDim2.new(1, -35, 0, 3)
        toggleIcon.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
        toggleIcon.Text = "LEA"
        toggleIcon.TextColor3 = Color3.new(1, 1, 1)
        toggleIcon.TextSize = 8
        toggleIcon.Visible = false
        toggleIcon.Parent = screenGui
        Instance.new("UICorner", toggleIcon).CornerRadius = UDim.new(0, 3)

        closeBtn.MouseButton1Click:Connect(function()
            mainFrame.Visible = false
            toggleIcon.Visible = true
        end)

        toggleIcon.MouseButton1Click:Connect(function()
            mainFrame.Visible = true
            toggleIcon.Visible = false
        end)
    end)
end

BuildCompactUI()
print("✅ [LEA PATCH]: Arayüz küçültüldü ve modüller aktif edildi.")
