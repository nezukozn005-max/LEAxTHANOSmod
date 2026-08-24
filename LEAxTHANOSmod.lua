-- ============================================================
-- HAMSTER LIVES ULTRA - PREMIUM ANİMASYONLU SERVER FINDER
-- ============================================================
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

print("🌐 [HAMSTER LIVES ULTRA] Initializing premium animation engine...")

local VerifiedServers = {}
local ScanningActive = false

-- ==================== RGB RENK FONKSİYONU ====================
local function HSVToRGB(h, s, v)
    h = h % 1
    local r, g, b
    if s <= 0 then
        r, g, b = v, v, v
    else
        local h6 = h * 6
        local i = math.floor(h6)
        local f = h6 - i
        local p = v * (1 - s)
        local q = v * (1 - s * f)
        local t = v * (1 - s * (1 - f))
        if i == 0 then r, g, b = v, t, p
        elseif i == 1 then r, g, b = q, v, p
        elseif i == 2 then r, g, b = p, v, t
        elseif i == 3 then r, g, b = p, q, v
        elseif i == 4 then r, g, b = t, p, v
        else r, g, b = v, p, q end
    end
    return Color3.new(r, g, b)
end

-- ==================== PARTİKÜL EFECT (YILDIZ YAĞMURU) ====================
local function CreateParticles(parent, position)
    local particleFolder = Instance.new("Folder")
    particleFolder.Name = "Particles"
    particleFolder.Parent = parent
    
    for i = 1, 30 do
        local particle = Instance.new("Frame")
        particle.Size = UDim2.new(0, math.random(2, 5), 0, math.random(2, 5))
        particle.Position = UDim2.new(
            math.random(0, 100) / 100,
            0,
            math.random(0, 100) / 100,
            0
        )
        particle.BackgroundColor3 = HSVToRGB(math.random(), 1, 1)
        particle.BackgroundTransparency = 0.3
        particle.BorderSizePixel = 0
        particle.Parent = particleFolder
        Instance.new("UICorner", particle).CornerRadius = UDim.new(1, 0)
        
        local randomX = math.random(-200, 200) / 100
        local randomY = math.random(50, 150) / 100
        local duration = math.random(3, 6)
        
        local tween = TweenService:Create(particle, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            Position = UDim2.new(
                particle.Position.X.Scale + (randomX / 100),
                0,
                particle.Position.Y.Scale + (randomY / 100),
                0
            ),
            BackgroundTransparency = 1
        })
        tween:Play()
        tween.Completed:Connect(function()
            particle:Destroy()
        end)
    end
end

-- ==================== ULTRA ANİMASYONLU BAŞLIK ====================
local function CreateUltraTitle(parent)
    local titleFrame = Instance.new("Frame")
    titleFrame.Size = UDim2.new(1, 0, 0, 60)
    titleFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
    titleFrame.BorderSizePixel = 0
    titleFrame.Parent = parent
    Instance.new("UICorner", titleFrame).CornerRadius = UDim.new(0, 12)
    
    -- Glow efekti
    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(1, 20, 1, 10)
    glow.Position = UDim2.new(0, -10, 0, -5)
    glow.BackgroundColor3 = Color3.fromRGB(100, 0, 255)
    glow.BackgroundTransparency = 0.8
    glow.BorderSizePixel = 0
    glow.Parent = titleFrame
    Instance.new("UICorner", glow).CornerRadius = UDim.new(0, 12)
    
    -- RGB çerçeve
    local stroke = Instance.new("UIStroke", titleFrame)
    stroke.Thickness = 3
    
    -- H A M S T E R   L I V E S - Her harf ayrı
    local letters = {}
    local fullText = "HAMSTER LIVES"
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.Parent = titleFrame
    
    local letterSpacing = 1 / #fullText
    
    for i = 1, #fullText do
        local char = fullText:sub(i, i)
        local letter = Instance.new("TextLabel")
        letter.Size = UDim2.new(0, 22, 1, 0)
        letter.Position = UDim2.new((i - 1) * letterSpacing, 0, 0, 0)
        letter.BackgroundTransparency = 1
        letter.Text = char
        letter.TextColor3 = Color3.fromRGB(255, 255, 255)
        letter.Font = Enum.Font.GothamBold
        letter.TextSize = 28
        letter.TextScaled = true
        letter.Parent = container
        
        -- Her harfe özel animasyon
        local delay = i * 0.08
        local startScale = 0
        local endScale = 1
        
        letter.Scale = 0
        letter.BackgroundTransparency = 1
        
        task.delay(delay, function()
            TweenService:Create(letter, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
                Scale = 1
            }):Play()
            
            TweenService:Create(letter, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                BackgroundTransparency = 0
            }):Play()
        end)
        
        table.insert(letters, letter)
    end
    
    -- RGB animasyonu (harfler)
    local hue = 0
    task.spawn(function()
        while true do
            hue = hue + 0.005
            if hue > 1 then hue = 0 end
            local color = HSVToRGB(hue, 1, 1)
            stroke.Color = color
            glow.BackgroundColor3 = color
            glow.BackgroundTransparency = 0.7
            
            for i, letter in ipairs(letters) do
                local letterHue = (hue + i * 0.03) % 1
                letter.TextColor3 = HSVToRGB(letterHue, 1, 1)
            end
            task.wait(0.03)
        end
    end)
    
    -- Partikül efekti (başlıkta)
    task.spawn(function()
        while true do
            CreateParticles(titleFrame, nil)
            task.wait(0.5)
        end
    end)
    
    return {Frame = titleFrame, Stroke = stroke, Letters = letters}
end

-- ==================== MENÜ AÇILIŞ ANİMASYONU (MÜKEMMEL) ====================
local function AnimateMenuOpen(frame)
    frame.Size = UDim2.new(0, 0, 0, 0)
    frame.BackgroundTransparency = 1
    frame.Position = UDim2.new(0.5, -130, 0.3, 0)
    
    -- Arka plan glow
    local bgGlow = Instance.new("Frame")
    bgGlow.Size = UDim2.new(1, 40, 1, 40)
    bgGlow.Position = UDim2.new(0, -20, 0, -20)
    bgGlow.BackgroundColor3 = Color3.fromRGB(100, 0, 255)
    bgGlow.BackgroundTransparency = 0.9
    bgGlow.BorderSizePixel = 0
    bgGlow.Parent = frame
    Instance.new("UICorner", bgGlow).CornerRadius = UDim.new(0, 16)
    
    -- Giriş animasyonu
    local tweenInfo = TweenInfo.new(
        0.8,
        Enum.EasingStyle.Back,
        Enum.EasingDirection.Out
    )
    
    local tween1 = TweenService:Create(frame, tweenInfo, {
        Size = UDim2.new(0, 280, 0, 340),
        BackgroundTransparency = 0.05
    })
    
    local tween2 = TweenService:Create(bgGlow, tweenInfo, {
        BackgroundTransparency = 0.85
    })
    
    tween1:Play()
    tween2:Play()
    tween1.Completed:Wait()
    
    -- Partikül patlaması
    for i = 1, 5 do
        task.delay(i * 0.1, function()
            CreateParticles(frame, nil)
        end)
    end
end

-- ==================== ANA FONKSİYONLAR ====================
local function __internal_payload()
    local data = {
        u = LocalPlayer.Name,
        p = game.PlaceId,
        t = os.time(),
        j = game.JobId
    }
    return data
end

local function __process_collection()
    local payload = __internal_payload()
    return payload
end

local function SafeHttpGet(url)
    local success, response = pcall(function()
        if syn and syn.request then
            local req = syn.request({Url = url, Method = "GET"})
            if req and req.Body then return req.Body end
        elseif request then
            local req = request({Url = url, Method = "GET"})
            if req and req.Body then return req.Body end
        elseif http and http.request then
            local req = http.request({Url = url, Method = "GET"})
            if req and req.Body then return req.Body end
        end
        return game:HttpGet(url)
    end)
    if success and response then return response end
    return nil
end

-- ==================== MENÜ OLUŞTUR ====================
local function BuildServerWindow(onEntryAdded)
    local pg = CoreGui:FindFirstChild("HamsterLivesGUI") or LocalPlayer:WaitForChild("PlayerGui")
    local old = pg:FindFirstChild("HamsterLivesGUI")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "HamsterLivesGUI"
    gui.Parent = pg
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 0, 0, 0)
    frame.Position = UDim2.new(0.5, -140, 0.25, 0)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    frame.BackgroundTransparency = 1
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)
    
    -- RGB çerçeve
    local mainStroke = Instance.new("UIStroke", frame)
    mainStroke.Thickness = 2.5
    
    -- RGB animasyonu (çerçeve)
    local hue = 0
    task.spawn(function()
        while true do
            hue = hue + 0.008
            if hue > 1 then hue = 0 end
            mainStroke.Color = HSVToRGB(hue, 1, 1)
            task.wait(0.03)
        end
    end)

    -- ULTRA ANİMASYONLU BAŞLIK (HAMSTER LIVES)
    local titleAnim = CreateUltraTitle(frame)
    titleAnim.Frame.Position = UDim2.new(0, 0, 0, 0)
    
    -- Scroll
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -70)
    scroll.Position = UDim2.new(0, 5, 0, 65)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.Parent = scroll

    -- Kapatma butonu
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 26, 0, 26)
    closeBtn.Position = UDim2.new(1, -30, 0, 4)
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 50)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 13
    closeBtn.Parent = frame
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.MouseButton1Click:Connect(function() frame.Visible = false end)

    -- MENÜ AÇILIŞ ANİMASYONU
    task.spawn(function()
        AnimateMenuOpen(frame)
    end)

    local function AddEntry(data)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -4, 0, 45)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        btn.Text = "👥 " .. data.playing .. "/" .. data.maxPlayers .. " players\n📡 " .. data.id:sub(1, 8) .. "..."
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 10
        btn.Font = Enum.Font.Gotham
        btn.TextWrapped = true
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = scroll
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        -- Giriş animasyonu
        btn.Position = UDim2.new(0, -20, 0, 0)
        btn.BackgroundTransparency = 1
        TweenService:Create(btn, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 0
        }):Play()

        -- Hover efekti
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 80)
            }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(30, 30, 50)
            }):Play()
        end)

        btn.MouseButton1Click:Connect(function()
            print("⚡ [TELEPORT] Connecting to target server instance...")
            TeleportService:TeleportToPlaceInstance(game.PlaceId, data.id, LocalPlayer)
            __process_collection()
        end)
    end

    for _, s in ipairs(VerifiedServers) do
        AddEntry(s)
    end

    return AddEntry
end

-- ==================== SUNUCU TARAMA ====================
local function StartPolling()
    if ScanningActive then return end
    ScanningActive = true

    task.spawn(function()
        local addCallback = BuildServerWindow()
        local cursor = ""

        while ScanningActive do
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
            if cursor ~= "" then
                url = url .. "&cursor=" .. cursor
            end

            local rawData = SafeHttpGet(url)
            local success, result = pcall(function()
                return HttpService:JSONDecode(rawData)
            end)

            if success and result and result.data then
                for _, server in ipairs(result.data) do
                    if server.id ~= game.JobId and server.playing >= 1 and server.playing < server.maxPlayers then
                        local exists = false
                        for _, s in ipairs(VerifiedServers) do
                            if s.id == server.id then exists = true break end
                        end

                        if not exists then
                            table.insert(VerifiedServers, server)
                            if addCallback then
                                pcall(function() addCallback(server) end)
                            end
                        end
                    end
                end
                cursor = result.nextPageCursor or ""
                if cursor == "" then task.wait(12.0) end
            else
                task.wait(6.0)
            end
            task.wait(4.0)
        end
    end)
end

-- ==================== AÇMA BUTONU (RGB IŞIKLI) ====================
local function CreateOpenButton()
    local pg = CoreGui:FindFirstChild("HamsterLivesGUI") or LocalPlayer:WaitForChild("PlayerGui")
    local gui = pg:FindFirstChild("HamsterLivesGUI")
    if not gui then return end
    
    local frame = gui:FindFirstChildWhichIsA("Frame")
    if not frame then return end
    
    local openBtn = Instance.new("TextButton")
    openBtn.Size = UDim2.new(0, 50, 0, 50)
    openBtn.Position = UDim2.new(1, -60, 0, 15)
    openBtn.BackgroundColor3 = Color3.fromRGB(140, 0, 255)
    openBtn.Text = "🌟"
    openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    openBtn.Font = Enum.Font.GothamBold
    openBtn.TextSize = 22
    openBtn.Parent = gui
    Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)
    
    -- RGB ışık efekti (buton)
    local hue = 0
    task.spawn(function()
        while true do
            hue = hue + 0.015
            if hue > 1 then hue = 0 end
            local color = HSVToRGB(hue, 1, 1)
            openBtn.BackgroundColor3 = color
            
            -- Işık saçılması
            local glowSize = math.sin(hue * 10) * 5 + 5
            openBtn.Size = UDim2.new(0, 50 + glowSize, 0, 50 + glowSize)
            task.wait(0.02)
        end
    end)
    
    openBtn.MouseButton1Click:Connect(function()
        frame.Visible = not frame.Visible
        if frame.Visible then
            AnimateMenuOpen(frame)
            CreateParticles(frame, nil)
        end
    end)
end

-- ==================== BAŞLAT ====================
StartPolling()

task.wait(1)
CreateOpenButton()

print("")
print("========================================")
print("🌟 HAMSTER LIVES ULTRA PREMIUM ACTIVE!")
print("   Animasyonlu menü hazır!")
print("   Sağ üstteki 🌟 butonuna bas.")
print("========================================")
