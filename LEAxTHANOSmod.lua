-- ==============================================================================
-- LEA MOD V16.5 - PART 1 / 2 (CORE ENGINE, CUBE & BASE FPS FIX)
-- ==============================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local function ApplyStrictBypass()
    pcall(function()
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        local old = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" and tostring(self):find("AntiCheat") then
                return
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
    end)
end

local State = {
    Mode = "NONE",
    Speed = 24,
    SpawnPos = nil,
    Cube = false,
    Cubes = {},
    LastCube = 0,
    Noclip = false,
    BypassReset = false
}

local UI = {}
local btnRefs = {}

local function ClearCubes()
    for _, c in ipairs(State.Cubes) do 
        if c and c.Parent then c:Destroy() end 
    end
    State.Cubes = {}
end

RunService.Heartbeat:Connect(function(dt)
    ApplyStrictBypass()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- BASE MODU (FPS Düşüşü/Lag Kesin Çözüm)
    if State.Mode == "BASE" and State.SpawnPos then
        local targetCFrame = CFrame.new(State.SpawnPos)
        local dist = (State.SpawnPos - hrp.Position).Magnitude
        
        if dist > 2 then
            -- Yumuşak taşıma (FPS kilitleyen ağır döngüler kaldırıldı)
            local moveStep = math.min(dist, State.Speed * dt * 2.5)
            local dir = (State.SpawnPos - hrp.Position).Unit
            hrp.CFrame = hrp.CFrame + (dir * moveStep)
            hrp.AssemblyLinearVelocity = Vector3.zero
        else
            hrp.CFrame = targetCFrame
            hrp.AssemblyLinearVelocity = Vector3.zero
            ClearCubes()
            State.Mode = "NONE"
            if UI.Update then UI.Update() end
        end

    -- TARGET (TAKİP) MODU
    elseif State.Mode == "TARGET" then
        local target, minDist = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local thrp = p.Character:FindFirstChild("HumanoidRootPart")
                local thum = p.Character:FindFirstChildOfClass("Humanoid")
                if thrp and thum and thum.Health > 0 then
                    local dist = (thrp.Position - hrp.Position).Magnitude
                    if dist < minDist then minDist = dist; target = thrp end
                end
            end
        end
        if target then
            local move = target.Position - hrp.Position
            if move.Magnitude > 4 then
                hrp.CFrame = hrp.CFrame + (move.Unit * math.min(move.Magnitude, State.Speed * dt * 2.5))
                hrp.AssemblyLinearVelocity = Vector3.zero
            else
                hrp.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
        else
            State.Mode = "BASE"
            if UI.Update then UI.Update() end
        end
    end

    -- CUBE (KÜP) SİSTEMİ (Tamamen Onarıldı)
    if State.Cube then
        local velY = hrp.AssemblyLinearVelocity.Y
        if velY < -1 and (os.clock() - State.LastCube > 0.15) then
            if #State.Cubes >= 6 then 
                local oldC = table.remove(State.Cubes, 1)
                if oldC and oldC.Parent then oldC:Destroy() end 
            end
            
            local cube = Instance.new("Part")
            cube.Size = Vector3.new(4, 0.5, 4)
            cube.Position = hrp.Position - Vector3.new(0, 3.2, 0)
            cube.Anchored = true
            cube.CanCollide = true
            cube.Transparency = 0.4
            cube.Material = Enum.Material.Neon
            cube.Color = Color3.fromRGB(0, 255, 200)
            cube.Parent = Workspace
            
            table.insert(State.Cubes, cube)
            State.LastCube = os.clock()
        end
    end

    -- NOCLIP
    if State.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then 
                part.CanCollide = false 
            end
        end
    end
end)
-- ==============================================================================
-- LEA MOD V16.5 - PART 2 / 2 (UI, TOGGLE MENÜ & EKRAN ORTASI BAŞLIK)
-- ==============================================================================

local isMenuOpen = true

function UI.Update()
    pcall(function()
        if not btnRefs.Target then return end
        
        local isTarget = (State.Mode == "TARGET")
        btnRefs.Target.Text = isTarget and "🎯 TAKİP ON" or "🎯 TAKİP OFF"
        btnRefs.Target.BackgroundColor3 = isTarget and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(255, 50, 80)

        local isBase = (State.Mode == "BASE")
        btnRefs.Base.Text = isBase and "🏠 BASE ON" or "🏠 BASE OFF"
        btnRefs.Base.BackgroundColor3 = isBase and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(200, 150, 0)

        btnRefs.S16.Text = (State.Speed == 16) and "⚡ HIZ: 16 [ON]" or "⚡ HIZ: 16"
        btnRefs.S16.BackgroundColor3 = (State.Speed == 16) and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(70, 70, 90)

        btnRefs.S24.Text = (State.Speed == 24) and "⚡ HIZ: 24 [ON]" or "⚡ HIZ: 24"
        btnRefs.S24.BackgroundColor3 = (State.Speed == 24) and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(70, 70, 90)

        btnRefs.S32.Text = (State.Speed == 32) and "⚡ HIZ: 32 [ON]" or "⚡ HIZ: 32"
        btnRefs.S32.BackgroundColor3 = (State.Speed == 32) and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(70, 70, 90)

        btnRefs.Cube.Text = State.Cube and "🧊 CUBE ON" or "🧊 CUBE OFF"
        btnRefs.Cube.BackgroundColor3 = State.Cube and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(0, 140, 240)

        btnRefs.Noclip.Text = State.Noclip and "👻 NOCLIP ON" or "👻 NOCLIP OFF"
        btnRefs.Noclip.BackgroundColor3 = State.Noclip and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(170, 0, 255)
    end)
end

function UI.Init()
    pcall(function()
        local pg = LocalPlayer:WaitForChild("PlayerGui", 10)
        if not pg then return end
        if pg:FindFirstChild("LeaModGUI") then pg.LeaModGUI:Destroy() end

        local sg = Instance.new("ScreenGui", pg)
        sg.Name = "LeaModGUI"
        sg.ResetOnSpawn = false

        -- Ekranın Tam Ortasının Üstüne Gelecek Başlık
        local title = Instance.new("TextLabel", sg)
        title.Size = UDim2.new(0, 300, 0, 20)
        title.Position = UDim2.new(0.5, -150, 0, 5)
        title.BackgroundTransparency = 1
        title.Text = "LEA MOD V16.5 [STABLE]"
        title.TextColor3 = Color3.fromRGB(0, 255, 200)
        title.TextSize = 14
        title.Font = Enum.Font.GothamBold
        
        local stroke = Instance.new("UIStroke", title)
        stroke.Thickness = 2
        stroke.Color = Color3.fromRGB(0, 0, 0)

        -- Sağ Üst Menü Aç/Kapat (Toggle) Butonu
        local toggleBtn = Instance.new("TextButton", sg)
        toggleBtn.Size = UDim2.new(0, 50, 0, 26)
        toggleBtn.Position = UDim2.new(1, -60, 0, 10)
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
        toggleBtn.Text = "LEA"
        toggleBtn.TextColor3 = Color3.fromRGB(20, 20, 30)
        toggleBtn.TextSize = 11
        toggleBtn.Font = Enum.Font.GothamBold

        local toggleCorner = Instance.new("UICorner", toggleBtn)
        toggleCorner.CornerRadius = UDim.new(0, 6)

        -- Ana Menü Kutusu
        local frame = Instance.new("Frame", sg)
        frame.Size = UDim2.new(0, 115, 0, 260)
        frame.Position = UDim2.new(1, -125, 0, 42)
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        frame.BackgroundTransparency = 0.25
        frame.BorderSizePixel = 0
        frame.Active = true

        local corner = Instance.new("UICorner", frame)
        corner.CornerRadius = UDim.new(0, 8)
        
        local fstroke = Instance.new("UIStroke", frame)
        fstroke.Color = Color3.fromRGB(0, 255, 200)
        fstroke.Thickness = 1.5

        -- Menü Açma / Kapama Mantığı
        toggleBtn.MouseButton1Click:Connect(function()
            isMenuOpen = not isMenuOpen
            frame.Visible = isMenuOpen
            toggleBtn.BackgroundColor3 = isMenuOpen and Color3.fromRGB(0, 255, 200) or Color3.fromRGB(255, 50, 80)
        end)

        local function mkBtn(posY, txt, cb)
            local btn = Instance.new("TextButton", frame)
            btn.Size = UDim2.new(1, -10, 0, 24)
            btn.Position = UDim2.new(0, 5, 0, posY)
            btn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
            btn.Text = txt
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.TextSize = 10
            btn.Font = Enum.Font.GothamBold
            
            local bcor = Instance.new("UICorner", btn)
            bcor.CornerRadius = UDim.new(0, 5)
            
            btn.MouseButton1Click:Connect(cb)
            return btn
        end

        btnRefs.Target = mkBtn(8, "🎯 TAKİP OFF", function()
            State.Mode = (State.Mode == "TARGET" and "NONE" or "TARGET")
            UI.Update()
        end)

        btnRefs.Base = mkBtn(38, "🏠 BASE OFF", function()
            State.Mode = (State.Mode == "BASE" and "NONE" or "BASE")
            if State.Mode == "BASE" and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            end
            UI.Update()
        end)

        btnRefs.S16 = mkBtn(68, "⚡ HIZ: 16", function() 
            State.Speed = 16 
            UI.Update() 
        end)

        btnRefs.S24 = mkBtn(98, "⚡ HIZ: 24 [ON]", function() 
            State.Speed = 24 
            UI.Update() 
        end)

        btnRefs.S32 = mkBtn(128, "⚡ HIZ: 32", function() 
            State.Speed = 32 
            UI.Update() 
        end)

        btnRefs.Cube = mkBtn(158, "🧊 CUBE OFF", function()
            State.Cube = not State.Cube
            if not State.Cube then ClearCubes() end
            UI.Update()
        end)

        btnRefs.Noclip = mkBtn(188, "👻 NOCLIP OFF", function()
            State.Noclip = not State.Noclip
            UI.Update()
        end)

        mkBtn(218, "🔄 RESET", function()
            State.BypassReset = true
            pcall(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.Health = 0 end
            end)
        end)
    end)
end

local function OnCharLoaded(char)
    State.Mode, State.SpawnPos = "NONE", nil
    ClearCubes()
    UI.Update()
    
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
        task.wait(1.5)
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then State.SpawnPos = hrp.Position + Vector3.new(0, 3, 0) end
    end)
end

UI.Init()
if LocalPlayer.Character then
    OnCharLoaded(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(OnCharLoaded)

print("⭐ LEA MOD V16.5 - PART 2 TAMAMLANDI VE YÜKLENDİ!")

