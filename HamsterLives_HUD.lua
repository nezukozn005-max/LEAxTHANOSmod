-- ============================================================
-- HAMSTER LIVES - WHITELIST KONTROL (ANINDA)
-- ============================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- İZİN VERİLEN KULLANICILAR
-- ============================================================
local ALLOWED_USERS = {
    "Yamanxct",
    "usgwheiahwe"
}

-- ============================================================
-- WHITELIST KONTROLÜ (ANINDA KARAR VER)
-- ============================================================
local function IsUserAllowed()
    local username = LocalPlayer.Name
    for _, allowed in ipairs(ALLOWED_USERS) do
        if username == allowed then
            return true
        end
    end
    return false
end

-- ============================================================
-- WHITELIST GUI (SADECE YETKİSİZLER İÇİN GÖSTER)
-- ============================================================
local whitelistGui = Instance.new("ScreenGui")
whitelistGui.Name = "WhitelistGUI"
whitelistGui.ResetOnSpawn = false
whitelistGui.IgnoreGuiInset = true
whitelistGui.DisplayOrder = 1000
whitelistGui.Parent = CoreGui

-- Siyah arka plan
local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bg.BackgroundTransparency = 0.1
bg.Parent = whitelistGui
bg.ZIndex = 0

-- Ana kutu
local box = Instance.new("Frame")
box.Size = UDim2.new(0, 300, 0, 200)
box.Position = UDim2.new(0.5, -150, 0.5, -100)
box.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
box.BackgroundTransparency = 0.2
box.Parent = whitelistGui
box.ZIndex = 1
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 12)

local boxStroke = Instance.new("UIStroke", box)
boxStroke.Thickness = 1.5
boxStroke.Color = Color3.fromRGB(60, 60, 60)
boxStroke.Transparency = 0.5

-- Büyüteç (🔍) - sadece yetkisizler görür
local magnifier = Instance.new("TextLabel")
magnifier.Size = UDim2.new(0, 60, 0, 60)
magnifier.Position = UDim2.new(0.5, -30, 0, 10)
magnifier.BackgroundTransparency = 1
magnifier.Text = "🔍"
magnifier.TextColor3 = Color3.fromRGB(255, 255, 255)
magnifier.TextSize = 50
magnifier.Font = Enum.Font.GothamBold
magnifier.Parent = box
magnifier.ZIndex = 2

-- "Kontrol ediliyorsunuz..." - sadece yetkisizler görür
local checkingLabel = Instance.new("TextLabel")
checkingLabel.Size = UDim2.new(1, 0, 0, 30)
checkingLabel.Position = UDim2.new(0, 0, 0, 80)
checkingLabel.BackgroundTransparency = 1
checkingLabel.Text = "Kontrol ediliyorsunuz..."
checkingLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
checkingLabel.TextSize = 14
checkingLabel.Font = Enum.Font.GothamBold
checkingLabel.Parent = box
checkingLabel.ZIndex = 2

-- ============================================================
-- WHITELIST KONTROL FONKSİYONU (ANINDA)
-- ============================================================
local function StartWhitelistCheck(callback)
    -- ANINDA KONTROL ET (0.05 saniye beklet, ekran donmasın)
    task.wait(0.05)
    
    if IsUserAllowed() then
        -- Yetkili: GUI'yi hemen yok et, callback'i çağır
        whitelistGui:Destroy()
        if callback then callback() end
    else
        -- Yetkisiz: büyüteç ve kontrol yazısını kaldır, hata mesajı göster
        magnifier:Destroy()
        checkingLabel:Destroy()
        
        local statusLabel = Instance.new("TextLabel")
        statusLabel.Size = UDim2.new(1, -20, 0, 40)
        statusLabel.Position = UDim2.new(0, 10, 0, 120)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text = "❌ Bu scriptin sahibi değilsiniz.\nLütfen scripti satın alın."
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        statusLabel.TextSize = 13
        statusLabel.Font = Enum.Font.GothamBold
        statusLabel.TextWrapped = true
        statusLabel.TextXAlignment = Enum.TextXAlignment.Center
        statusLabel.Parent = box
        statusLabel.ZIndex = 2
        
        -- Script'i durdur (hatalı kullanıcı)
        script:Destroy()
    end
end-- ============================================================
-- ORİJİNAL HAMSTER LIVES HUD KODU (PART 2/3)
-- ============================================================

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera
local LocalPlayer = player

------------------------------------------------
-- KOZMETİK ROZET
------------------------------------------------
local COSMETIC_ROLE_USERNAME = "Yamanxct"
local hasSpecialRole = (LocalPlayer.Name == COSMETIC_ROLE_USERNAME)

------------------------------------------------
-- SES
------------------------------------------------
local function playSound(id, volume, pitch)
	local ok, sound = pcall(function()
		local s = Instance.new("Sound")
		s.SoundId = "rbxassetid://" .. tostring(id)
		s.Volume = volume or 1
		s.PlaybackSpeed = pitch or 1
		s.Parent = SoundService
		s:Play()
		s.Ended:Connect(function() s:Destroy() end)
		task.delay(8, function() if s and s.Parent then s:Destroy() end end)
		return s
	end)
	if ok then return sound end
end

local SOUNDS = {
	whoosh = 9118823728,
	explosion = 9125715540,
	darkRumble = 9046191806,
	menuAppear = 9114253392,
	glitch = 9042866550,
}

------------------------------------------------
-- GUI KÖK
------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HamsterLivesHUD"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999
screenGui.Visible = false   -- WHITELIST KONTROLÜ BİTENE KADAR GİZLİ
screenGui.Parent = playerGui

local function getCenterAndCorners()
	local vp = camera.ViewportSize
	local cx, cy = vp.X / 2, vp.Y / 2
	local corners = {
		Vector2.new(0, 0),
		Vector2.new(vp.X, 0),
		Vector2.new(0, vp.Y),
		Vector2.new(vp.X, vp.Y),
	}
	return Vector2.new(cx, cy), corners
end

local beamColor = Color3.fromRGB(255, 20, 20)
local BEAM_LENGTH = 60
local BEAM_THICKNESS = 6
local TRAVEL_TIME = 0.4

local skipAnimation = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.F3 then
		skipAnimation = true
	end
end)

------------------------------------------------
-- GİRİŞ: IŞIN
------------------------------------------------
local function createTravelingBeam(startPos, endPos)
	local delta = endPos - startPos
	local dirAngle = math.deg(math.atan2(delta.Y, delta.X))

	local beam = Instance.new("Frame")
	beam.AnchorPoint = Vector2.new(0.5, 0.5)
	beam.Position = UDim2.fromOffset(startPos.X, startPos.Y)
	beam.Size = UDim2.fromOffset(BEAM_LENGTH, BEAM_THICKNESS)
	beam.Rotation = dirAngle
	beam.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	beam.BorderSizePixel = 0
	beam.ZIndex = 5
	beam.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = beam

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 0, 0)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, beamColor),
	})
	gradient.Parent = beam

	local glow = Instance.new("Frame")
	glow.AnchorPoint = Vector2.new(0.5, 0.5)
	glow.Position = UDim2.fromOffset(startPos.X, startPos.Y)
	glow.Size = UDim2.fromOffset(BEAM_LENGTH * 1.6, BEAM_THICKNESS * 4)
	glow.Rotation = dirAngle
	glow.BackgroundColor3 = beamColor
	glow.BackgroundTransparency = 0.45
	glow.BorderSizePixel = 0
	glow.ZIndex = 4
	glow.Parent = screenGui

	local glowCorner = Instance.new("UICorner")
	glowCorner.CornerRadius = UDim.new(1, 0)
	glowCorner.Parent = glow

	local outerGlow = Instance.new("Frame")
	outerGlow.AnchorPoint = Vector2.new(0.5, 0.5)
	outerGlow.Position = UDim2.fromOffset(startPos.X, startPos.Y)
	outerGlow.Size = UDim2.fromOffset(BEAM_LENGTH * 2.4, BEAM_THICKNESS * 8)
	outerGlow.Rotation = dirAngle
	outerGlow.BackgroundColor3 = beamColor
	outerGlow.BackgroundTransparency = 0.75
	outerGlow.BorderSizePixel = 0
	outerGlow.ZIndex = 3
	outerGlow.Parent = screenGui

	local outerGlowCorner = Instance.new("UICorner")
	outerGlowCorner.CornerRadius = UDim.new(1, 0)
	outerGlowCorner.Parent = outerGlow

	local tweenInfo = TweenInfo.new(TRAVEL_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	TweenService:Create(beam, tweenInfo, { Position = UDim2.fromOffset(endPos.X, endPos.Y) }):Play()
	TweenService:Create(glow, tweenInfo, { Position = UDim2.fromOffset(endPos.X, endPos.Y) }):Play()
	TweenService:Create(outerGlow, tweenInfo, { Position = UDim2.fromOffset(endPos.X, endPos.Y) }):Play()

	return beam, glow, outerGlow
end

------------------------------------------------
-- GİRİŞ: PATLAMA
------------------------------------------------
local function createExplosion(center, onDone)
	playSound(SOUNDS.explosion, 1.2, 0.85)
	playSound(SOUNDS.darkRumble, 0.9, 0.7)

	local flash = Instance.new("Frame")
	flash.Size = UDim2.new(1, 0, 1, 0)
	flash.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	flash.BackgroundTransparency = 0.1
	flash.BorderSizePixel = 0
	flash.ZIndex = 25
	flash.Parent = screenGui

	TweenService:Create(flash, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1
	}):Play()
	task.delay(0.4, function() flash:Destroy() end)

	for i = 1, 4 do
		local ring = Instance.new("Frame")
		ring.AnchorPoint = Vector2.new(0.5, 0.5)
		ring.Position = UDim2.fromOffset(center.X, center.Y)
		ring.Size = UDim2.fromOffset(10, 10)
		ring.BackgroundTransparency = 1
		ring.BorderSizePixel = 0
		ring.ZIndex = 15
		ring.Parent = screenGui

		local uiStroke = Instance.new("UIStroke")
		uiStroke.Thickness = 5 - (i * 0.4)
		uiStroke.Color = beamColor
		uiStroke.Transparency = 0.05
		uiStroke.Parent = ring

		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(1, 0)
		uiCorner.Parent = ring

		local goalSize = 150 + (i * 110)
		task.delay(i * 0.07, function()
			TweenService:Create(ring, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.fromOffset(goalSize, goalSize)
			}):Play()
			TweenService:Create(uiStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			task.delay(0.65, function() ring:Destroy() end)
		end)
	end

	local core = Instance.new("Frame")
	core.AnchorPoint = Vector2.new(0.5, 0.5)
	core.Position = UDim2.fromOffset(center.X, center.Y)
	core.Size = UDim2.fromOffset(26, 26)
	core.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	core.BorderSizePixel = 0
	core.ZIndex = 16
	core.Parent = screenGui
	local coreCorner = Instance.new("UICorner")
	coreCorner.CornerRadius = UDim.new(1, 0)
	coreCorner.Parent = core

	TweenService:Create(core, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(240, 240),
		BackgroundTransparency = 1
	}):Play()
	task.delay(0.45, function() core:Destroy() end)

	for i = 1, 30 do
		local particle = Instance.new("Frame")
		particle.AnchorPoint = Vector2.new(0.5, 0.5)
		particle.Position = UDim2.fromOffset(center.X, center.Y)
		local size = math.random(3, 7)
		particle.Size = UDim2.fromOffset(size, size)
		particle.BackgroundColor3 = Color3.fromRGB(255, math.random(30, 220), math.random(20, 90))
		particle.BorderSizePixel = 0
		particle.ZIndex = 14
		particle.Parent = screenGui
		local pCorner = Instance.new("UICorner")
		pCorner.CornerRadius = UDim.new(1, 0)
		pCorner.Parent = particle

		local ang = math.rad(math.random(0, 360))
		local dist = math.random(150, 420)
		local targetPos = Vector2.new(center.X + math.cos(ang) * dist, center.Y + math.sin(ang) * dist)

		local dur = 0.5 + math.random() * 0.35
		TweenService:Create(particle, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.fromOffset(targetPos.X, targetPos.Y),
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(1, 1),
		}):Play()
		task.delay(dur + 0.05, function() particle:Destroy() end)
	end

	task.delay(0.5, function()
		if onDone then onDone() end
	end)
	end------------------------------------------------
-- HUD (üstte, hafif sağda)
------------------------------------------------
local HUD_X_OFFSET = 0.60

local hudHolder = Instance.new("Frame")
hudHolder.Name = "HUD"
hudHolder.AnchorPoint = Vector2.new(0.5, 0)
hudHolder.Position = UDim2.new(HUD_X_OFFSET, 0, 0, 12)
hudHolder.Size = UDim2.fromOffset(260, 62)
hudHolder.BackgroundTransparency = 1
hudHolder.BorderSizePixel = 0
hudHolder.ZIndex = 40
hudHolder.Visible = false
hudHolder.Parent = screenGui

local roleLabel = Instance.new("TextLabel")
roleLabel.Size = UDim2.new(0, 150, 0, 28)
roleLabel.Position = UDim2.new(0, 0, 0, 0)
roleLabel.BackgroundTransparency = 1
roleLabel.Text = hasSpecialRole and "ROL: HAMSTER" or "ROL: OYUNCU"
roleLabel.TextColor3 = hasSpecialRole and Color3.fromRGB(255, 210, 60) or Color3.fromRGB(220, 220, 220)
roleLabel.Font = Enum.Font.GothamBlack
roleLabel.TextSize = 18
roleLabel.TextXAlignment = Enum.TextXAlignment.Left
roleLabel.ZIndex = 41
roleLabel.Parent = hudHolder

local roleLabelStroke = Instance.new("UIStroke")
roleLabelStroke.Thickness = 1.5
roleLabelStroke.Color = Color3.fromRGB(0, 0, 0)
roleLabelStroke.Transparency = 0.3
roleLabelStroke.Parent = roleLabel

local hudToggle = Instance.new("TextButton")
hudToggle.Size = UDim2.new(0, 42, 0, 32)
hudToggle.Position = UDim2.new(0, 158, 0, -2)
hudToggle.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
hudToggle.Text = "☰"
hudToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
hudToggle.Font = Enum.Font.GothamBold
hudToggle.TextSize = 18
hudToggle.ZIndex = 41
hudToggle.Parent = hudHolder
local hudToggleCorner = Instance.new("UICorner")
hudToggleCorner.CornerRadius = UDim.new(0, 8)
hudToggleCorner.Parent = hudToggle
local hudToggleStroke = Instance.new("UIStroke")
hudToggleStroke.Thickness = 1.5
hudToggleStroke.Color = Color3.fromRGB(255, 120, 120)
hudToggleStroke.Transparency = 0.4
hudToggleStroke.Parent = hudToggle

local tabHolder = Instance.new("Frame")
tabHolder.Size = UDim2.new(0, 210, 0, 26)
tabHolder.Position = UDim2.new(0, 50, 0, 34)
tabHolder.BackgroundTransparency = 1
tabHolder.ZIndex = 41
tabHolder.Parent = hudHolder

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 6)
tabLayout.Parent = tabHolder

local tabButtons = {}

local function makeTabButton(labelText)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 44, 1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	btn.BackgroundTransparency = 0.1
	btn.Text = labelText
	btn.TextColor3 = Color3.fromRGB(210, 210, 210)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12
	btn.ZIndex = 42
	btn.Parent = tabHolder
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 7)
	c.Parent = btn
	local s = Instance.new("UIStroke")
	s.Thickness = 1.5
	s.Color = Color3.fromRGB(255, 0, 0)
	s.Transparency = 0.5
	s.Parent = btn
	return btn
end

tabButtons.v1 = makeTabButton("V1")
tabButtons.v2 = makeTabButton("V2")
tabButtons.v3 = makeTabButton("V3")

------------------------------------------------
-- ALT PANEL
------------------------------------------------
local panelHolder = Instance.new("Frame")
panelHolder.Name = "VersionPanel"
panelHolder.AnchorPoint = Vector2.new(0.5, 0)
panelHolder.Position = UDim2.new(HUD_X_OFFSET, 0, 0, 78)
panelHolder.Size = UDim2.fromOffset(230, 0)
panelHolder.BackgroundColor3 = Color3.fromRGB(6, 6, 8)
panelHolder.BackgroundTransparency = 0.1
panelHolder.BorderSizePixel = 0
panelHolder.ClipsDescendants = true
panelHolder.ZIndex = 40
panelHolder.Visible = false
panelHolder.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 10)
panelCorner.Parent = panelHolder

local panelStroke = Instance.new("UIStroke")
panelStroke.Thickness = 2
panelStroke.Color = Color3.fromRGB(255, 0, 0)
panelStroke.Transparency = 0.3
panelStroke.Parent = panelHolder

local PANEL_OPEN_HEIGHT = 260
local menuOpen = false
local currentVersion = "v1"

------------------------------------------------
-- İçerik konteynerları
------------------------------------------------
local v1Container = Instance.new("Frame")
v1Container.Name = "V1Container"
v1Container.Size = UDim2.new(1, -8, 1, -8)
v1Container.Position = UDim2.new(0, 4, 0, 4)
v1Container.BackgroundTransparency = 1
v1Container.ZIndex = 50
v1Container.Visible = true
v1Container.Parent = panelHolder

local v2Container = Instance.new("Frame")
v2Container.Name = "V2Container"
v2Container.Size = UDim2.new(1, -8, 1, -8)
v2Container.Position = UDim2.new(0, 4, 0, 4)
v2Container.BackgroundTransparency = 1
v2Container.ZIndex = 50
v2Container.Visible = false
v2Container.Parent = panelHolder

local v3Container = Instance.new("Frame")
v3Container.Name = "V3Container"
v3Container.Size = UDim2.new(1, -8, 1, -8)
v3Container.Position = UDim2.new(0, 4, 0, 4)
v3Container.BackgroundTransparency = 1
v3Container.ZIndex = 50
v3Container.Visible = false
v3Container.Parent = panelHolder

------------------------------------------------
-- V1: KARANLIK TEMA SERVER FINDER
------------------------------------------------
local v1Scanning = false
local v1Servers = {}
local v1GuiAlive = false

local function V1_SafeHttpGet(url)
	local success, response = pcall(function()
		return game:HttpGet(url)
	end)
	if success and response then return response end
	return nil
end

local function V1_Build()
	for _, c in ipairs(v1Container:GetChildren()) do c:Destroy() end
	v1Servers = {}

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 14)
	title.BackgroundTransparency = 1
	title.Text = "🐹 V1 - SUNUCU LİSTESİ"
	title.TextColor3 = Color3.fromRGB(255, 60, 60)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 10
	title.ZIndex = 51
	title.Parent = v1Container

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, 0, 1, -18)
	scroll.Position = UDim2.new(0, 0, 0, 18)
	scroll.BackgroundTransparency = 1
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ScrollBarThickness = 3
	scroll.ScrollBarImageColor3 = Color3.fromRGB(180, 0, 0)
	scroll.ZIndex = 51
	scroll.Parent = v1Container

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 3)
	layout.Parent = scroll

	local function addServerBtn(server)
		if server.playing < 1 or server.playing >= server.maxPlayers then return end
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 22)
		btn.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
		btn.Text = "👤 " .. server.playing .. "/" .. server.maxPlayers
		btn.TextColor3 = server.playing == 1 and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(200, 200, 200)
		btn.TextSize = 9
		btn.Font = Enum.Font.GothamBold
		btn.ZIndex = 52
		btn.Parent = scroll
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 4)
		c.Parent = btn

		btn.MouseButton1Click:Connect(function()
			local sid = server.id
			btn.Text = "⏳ Bağlanıyor..."
			task.spawn(function()
				pcall(function()
					TeleportService:TeleportToPlaceInstance(game.PlaceId, sid, LocalPlayer)
				end)
			end)
		end)
	end

	v1GuiAlive = true
	if not v1Scanning then
		v1Scanning = true
		task.spawn(function()
			local cursor = ""
			while v1GuiAlive and currentVersion == "v1" and menuOpen do
				local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
				if cursor ~= "" then url = url .. "&cursor=" .. cursor end
				local raw = V1_SafeHttpGet(url)
				if raw then
					local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
					if ok and data and data.data then
						for _, s in ipairs(data.data) do
							if s.id ~= game.JobId then
								local exists = false
								for _, v in ipairs(v1Servers) do
									if v.id == s.id then exists = true break end
								end
								if not exists then
									table.insert(v1Servers, s)
									if v1Container.Parent then addServerBtn(s) end
								end
							end
						end
						cursor = data.nextPageCursor or ""
						task.wait(cursor == "" and 2 or 1)
					else
						task.wait(1)
					end
				else
					task.wait(1)
				end
				task.wait(0.5)
			end
			v1Scanning = false
		end)
	end
end

------------------------------------------------
-- V2: NEON TEMA
------------------------------------------------
local v2Scanning = false
local v2Servers = {}
local v2GuiAlive = false

local function V2_Build()
	for _, c in ipairs(v2Container:GetChildren()) do c:Destroy() end
	v2Servers = {}

	local bgLight = Instance.new("Frame")
	bgLight.Size = UDim2.new(1, 0, 1, 0)
	bgLight.BackgroundColor3 = Color3.fromRGB(245, 248, 255)
	bgLight.BackgroundTransparency = 0.05
	bgLight.ZIndex = 50
	bgLight.Parent = v2Container
	local bgCorner = Instance.new("UICorner")
	bgCorner.CornerRadius = UDim.new(0, 8)
	bgCorner.Parent = bgLight

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -8, 0, 16)
	title.Position = UDim2.new(0, 4, 0, 2)
	title.BackgroundTransparency = 1
	title.Text = "⚡ V2 - HIZLI MOD"
	title.TextColor3 = Color3.fromRGB(0, 200, 255)
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 11
	title.ZIndex = 51
	title.Parent = v2Container

	local titleGlow = Instance.new("UIStroke")
	titleGlow.Thickness = 1
	titleGlow.Color = Color3.fromRGB(0, 220, 255)
	titleGlow.Transparency = 0.5
	titleGlow.Parent = title

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -8, 1, -22)
	scroll.Position = UDim2.new(0, 4, 0, 20)
	scroll.BackgroundTransparency = 1
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ScrollBarThickness = 3
	scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
	scroll.ZIndex = 51
	scroll.Parent = v2Container

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 4)
	layout.Parent = scroll

	local function addServerBtn(server)
		if server.playing < 1 or server.playing >= server.maxPlayers then return end
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 24)
		btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		btn.Text = "👤 " .. server.playing .. "/" .. server.maxPlayers
		btn.TextColor3 = Color3.fromRGB(20, 30, 50)
		btn.TextSize = 10
		btn.Font = Enum.Font.GothamBold
		btn.ZIndex = 52
		btn.Parent = scroll
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 8)
		c.Parent = btn
		local s = Instance.new("UIStroke")
		s.Thickness = 1.5
		s.Color = Color3.fromRGB(0, 200, 255)
		s.Transparency = 0.3
		s.Parent = btn

		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(220, 245, 255) }):Play()
		end)
		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(255, 255, 255) }):Play()
		end)

		btn.MouseButton1Click:Connect(function()
			local sid = server.id
			btn.Text = "⚡ Bağlanıyor..."
			task.spawn(function()
				pcall(function()
					TeleportService:TeleportToPlaceInstance(game.PlaceId, sid, LocalPlayer)
				end)
			end)
		end)
	end

	v2GuiAlive = true
	if not v2Scanning then
		v2Scanning = true
		task.spawn(function()
			local cursor = ""
			while v2GuiAlive and currentVersion == "v2" and menuOpen do
				local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
				if cursor ~= "" then url = url .. "&cursor=" .. cursor end
				local raw = V1_SafeHttpGet(url)
				if raw then
					local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
					if ok and data and data.data then
						for _, s in ipairs(data.data) do
							if s.id ~= game.JobId then
								local exists = false
								for _, v in ipairs(v2Servers) do
									if v.id == s.id then exists = true break end
								end
								if not exists then
									table.insert(v2Servers, s)
									if v2Container.Parent then addServerBtn(s) end
								end
							end
						end
						cursor = data.nextPageCursor or ""
						task.wait(cursor == "" and 2 or 1)
					else
						task.wait(1)
					end
				else
					task.wait(1)
				end
				task.wait(0.5)
			end
			v2Scanning = false
		end)
	end
end

------------------------------------------------
-- V3: COMING SOON
------------------------------------------------
local function V3_Build()
	for _, c in ipairs(v3Container:GetChildren()) do c:Destroy() end

	local label = Instance.new("TextLabel")
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.new(0.5, 0, 0.5, 0)
	label.Size = UDim2.new(1, -20, 0, 30)
	label.BackgroundTransparency = 1
	label.Text = "Coming soon..."
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.GothamBlack
	label.TextSize = 16
	label.ZIndex = 51
	label.Parent = v3Container

	local glowStroke = Instance.new("UIStroke")
	glowStroke.Thickness = 1
	glowStroke.Color = Color3.fromRGB(255, 0, 0)
	glowStroke.Transparency = 0.3
	glowStroke.Parent = label

	task.spawn(function()
		while label.Parent do
			TweenService:Create(label, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				TextTransparency = 0.5
			}):Play()
			task.wait(1)
			if not label.Parent then break end
			TweenService:Create(label, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				TextTransparency = 0
			}):Play()
			task.wait(1)
		end
	end)

	for i = 1, 3 do
		local dot = Instance.new("Frame")
		dot.AnchorPoint = Vector2.new(0.5, 0.5)
		dot.Position = UDim2.new(0.5, 0, 0.5, 30)
		dot.Size = UDim2.fromOffset(5, 5)
		dot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		dot.BorderSizePixel = 0
		dot.ZIndex = 51
		dot.Parent = v3Container
		local dc = Instance.new("UICorner")
		dc.CornerRadius = UDim.new(1, 0)
		dc.Parent = dot

		task.spawn(function()
			local angle = i * 120
			while dot.Parent do
				angle = angle + 3
				local rad = math.rad(angle)
				dot.Position = UDim2.new(0.5, math.cos(rad) * 30, 0.5, 30 + math.sin(rad) * 6)
				task.wait(0.03)
			end
		end)
	end
end

------------------------------------------------
-- SEKME GEÇİŞ MANTIĞI
------------------------------------------------
local function selectVersion(version)
	currentVersion = version

	v1Container.Visible = (version == "v1")
	v2Container.Visible = (version == "v2")
	v3Container.Visible = (version == "v3")

	for key, btn in pairs(tabButtons) do
		if key == version then
			btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
			btn.TextColor3 = Color3.fromRGB(200, 200, 200)
		end
	end

	if version == "v1" then
		V1_Build()
	elseif version == "v2" then
		V2_Build()
	elseif version == "v3" then
		V3_Build()
	end
end

tabButtons.v1.MouseButton1Click:Connect(function()
	playSound(SOUNDS.whoosh, 0.3, 1.3)
	selectVersion("v1")
end)
tabButtons.v2.MouseButton1Click:Connect(function()
	playSound(SOUNDS.whoosh, 0.3, 1.3)
	selectVersion("v2")
end)
tabButtons.v3.MouseButton1Click:Connect(function()
	playSound(SOUNDS.whoosh, 0.3, 1.3)
	selectVersion("v3")
end)

------------------------------------------------
-- MENÜ AÇ/KAPA
------------------------------------------------
local function openPanel()
	menuOpen = true
	v1GuiAlive = true
	v2GuiAlive = true
	panelHolder.Visible = true
	TweenService:Create(panelHolder, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(230, PANEL_OPEN_HEIGHT)
	}):Play()
	selectVersion(currentVersion)
	playSound(SOUNDS.menuAppear, 0.6, 1.1)
end

local function closePanel()
	menuOpen = false
	v1GuiAlive = false
	v2GuiAlive = false
	TweenService:Create(panelHolder, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = UDim2.fromOffset(230, 0)
	}):Play()
	task.delay(0.3, function()
		if not menuOpen then
			panelHolder.Visible = false
		end
	end)
	playSound(SOUNDS.glitch, 0.3, 1.2)
end

hudToggle.MouseButton1Click:Connect(function()
	if menuOpen then
		closePanel()
	else
		openPanel()
	end
end)

------------------------------------------------
-- GİRİŞ SEKANSI: IŞINLAR -> PATLAMA -> HUD BELİR
------------------------------------------------
local function popIn(el, delay)
	local originalSize = el.Size
	el.Size = UDim2.new(originalSize.X.Scale * 0.5, originalSize.X.Offset * 0.5, originalSize.Y.Scale * 0.5, originalSize.Y.Offset * 0.5)
	local isText = el:IsA("TextLabel") or el:IsA("TextButton")
	if isText then
		el.TextTransparency = 1
	else
		el.BackgroundTransparency = 1
	end
	task.delay(delay, function()
		if not el.Parent then return end
		TweenService:Create(el, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = originalSize
		}):Play()
		if isText then
			TweenService:Create(el, TweenInfo.new(0.25), { TextTransparency = 0 }):Play()
		else
			TweenService:Create(el, TweenInfo.new(0.25), { BackgroundTransparency = 0.1 }):Play()
		end
	end)
end

local function showHUD()
	hudHolder.Visible = true
	popIn(roleLabel, 0)
	popIn(hudToggle, 0.08)
	popIn(tabButtons.v1, 0.16)
	popIn(tabButtons.v2, 0.2)
	popIn(tabButtons.v3, 0.24)
end

local function playFullSequence()
	if skipAnimation then
		showHUD()
		return
	end

	local center, corners = getCenterAndCorners()
	local elements = {}
	local finished = false

	local function goToHUD()
		if finished then return end
		finished = true
		for _, el in ipairs(elements) do
			if el and el.Parent then el:Destroy() end
		end
		showHUD()
	end

	for _, cornerPos in ipairs(corners) do
		playSound(SOUNDS.whoosh, 0.4, 1 + math.random() * 0.2)
		local beam, glow, outerGlow = createTravelingBeam(cornerPos, center)
		table.insert(elements, beam)
		table.insert(elements, glow)
		table.insert(elements, outerGlow)
	end

	local skipConn
	skipConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if input.KeyCode == Enum.KeyCode.F3 then
			skipConn:Disconnect()
			goToHUD()
		end
	end)

	task.delay(TRAVEL_TIME, function()
		if finished then return end
		createExplosion(center, function()
			if not finished then
				finished = true
				skipConn:Disconnect()
				showHUD()
			end
		end)

		for _, el in ipairs(elements) do
			if el.Parent then
				TweenService:Create(el, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play()
			end
		end
		task.delay(0.15, function()
			for _, el in ipairs(elements) do
				if el.Parent then el:Destroy() end
			end
		end)
	end)
end

-- ============================================================
-- WHITELIST KONTROLÜNÜ BAŞLAT (ANINDA GEÇER)
-- ============================================================
local function onWhitelistPassed()
    screenGui.Visible = true
    playFullSequence()
end

-- WHITELIST KONTROLÜNÜ BAŞLAT
StartWhitelistCheck(onWhitelistPassed)
