-- LocalScript
-- HAMSTER LIVES - V1.5 SUNUCU HUD
-- Giriş: çapraz köşelerden birleşen 2 ışın -> HUD -> V1.5
-- V1.5 sunucu tarayıcı: açılışta anında başlar, liste sürekli güncellenir

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
-- WHITELIST
-- Sadece Yamanxct ve U ile başlayan kullanıcı için izin
------------------------------------------------
local WHITELIST = {
	[1342015154] = true,   -- Yamanxct
	[11549642187] = true,  -- U ile başlayan kullanıcı
}

if not WHITELIST[LocalPlayer.UserId] then
	return
end

------------------------------------------------
-- KOZMETİK ROZET (herkes menüyü kullanır, bu sadece bir etiket - kısıtlama yok)
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
screenGui.Parent = playerGui

local function getViewportCenter()
	local vp = camera.ViewportSize
	return Vector2.new(vp.X / 2, vp.Y / 2)
end

local beamColor = Color3.fromRGB(255, 20, 20)
local BEAM_LENGTH = 90
local BEAM_THICKNESS = 9
local TRAVEL_TIME = 0.32

local skipAnimation = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.F3 then
		skipAnimation = true
	end
end)

------------------------------------------------
-- IŞIN (genel amaçlı - herhangi iki nokta arası)
------------------------------------------------
local function createTravelingBeam(startPos, endPos, travelTime)
	travelTime = travelTime or TRAVEL_TIME
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

	local tweenInfo = TweenInfo.new(travelTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	TweenService:Create(beam, tweenInfo, { Position = UDim2.fromOffset(endPos.X, endPos.Y) }):Play()
	TweenService:Create(glow, tweenInfo, { Position = UDim2.fromOffset(endPos.X, endPos.Y) }):Play()
	TweenService:Create(outerGlow, tweenInfo, { Position = UDim2.fromOffset(endPos.X, endPos.Y) }):Play()

	return beam, glow, outerGlow
end

------------------------------------------------
-- PATLAMA (giriş sekansının sonunda, ışınların birleştiği noktada)
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

	for i = 1, 8 do
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

		local goalSize = 160 + (i * 95)
		task.delay(i * 0.07, function()
			TweenService:Create(ring, TweenInfo.new(0.48, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
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
end

------------------------------------------------
-- HUD (üstte, hafif sağda) - ARKA PLANSIZ, BOŞLUKTA DURAN AYRI ELEMANLAR
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

local brandLabel = Instance.new("TextLabel")
brandLabel.Name = "BrandLabel"
brandLabel.Size = UDim2.new(0, 150, 0, 24)
brandLabel.Position = UDim2.new(0, 0, 0, 28)
brandLabel.BackgroundTransparency = 1
brandLabel.Text = "🐹  HAMSTER LIVES"
brandLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
brandLabel.Font = Enum.Font.GothamBlack
brandLabel.TextSize = 14
brandLabel.TextXAlignment = Enum.TextXAlignment.Left
brandLabel.ZIndex = 41
brandLabel.Parent = hudHolder

local brandStroke = Instance.new("UIStroke")
brandStroke.Thickness = 1.2
brandStroke.Color = Color3.fromRGB(0, 0, 0)
brandStroke.Transparency = 0.25
brandStroke.Parent = brandLabel

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

-- Menü Aç/Kapa butonu - kaliteli, animasyonlu (hover + basılma tepkisi)
local hudToggle = Instance.new("TextButton")
hudToggle.Size = UDim2.new(0, 42, 0, 32)
hudToggle.Position = UDim2.new(0, 158, 0, -2)
hudToggle.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
hudToggle.Text = "☰"
hudToggle.AutoButtonColor = false
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
local hudToggleGradient = Instance.new("UIGradient")
hudToggleGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 30, 30)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 0, 0)),
})
hudToggleGradient.Rotation = 90
hudToggleGradient.Parent = hudToggle

hudToggle.MouseEnter:Connect(function()
	TweenService:Create(hudToggle, TweenInfo.new(0.15), { Size = UDim2.new(0, 46, 0, 35) }):Play()
end)
hudToggle.MouseLeave:Connect(function()
	TweenService:Create(hudToggle, TweenInfo.new(0.15), { Size = UDim2.new(0, 42, 0, 32) }):Play()
end)

-- V1.5 kutucuğu - animasyonlu, kaliteli
local tabHolder = Instance.new("Frame")
tabHolder.Size = UDim2.new(0, 70, 0, 26)
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
	btn.AutoButtonColor = false
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

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.12), { Size = UDim2.new(0, 48, 1, 4) }):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.12), { Size = UDim2.new(0, 44, 1, 0) }):Play()
	end)

	return btn
end

tabButtons.v1 = makeTabButton("V1.5")

------------------------------------------------
-- ALT PANEL (kaydırılabilir - Draggable)
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
panelHolder.Active = true
panelHolder.Draggable = true
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

-- Sürükleme tutamacı (üst kenar - görsel ipucu)
local dragHandle = Instance.new("Frame")
dragHandle.Size = UDim2.new(0, 36, 0, 4)
dragHandle.Position = UDim2.new(0.5, -18, 0, 4)
dragHandle.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
dragHandle.BackgroundTransparency = 0.3
dragHandle.BorderSizePixel = 0
dragHandle.ZIndex = 41
dragHandle.Parent = panelHolder
local dragHandleCorner = Instance.new("UICorner")
dragHandleCorner.CornerRadius = UDim.new(1, 0)
dragHandleCorner.Parent = dragHandle

local PANEL_OPEN_HEIGHT = 260
local menuOpen = false
local currentVersion = "v1"

------------------------------------------------
-- İçerik konteynerları
------------------------------------------------
local v1Container = Instance.new("Frame")
v1Container.Name = "V1Container"
v1Container.Size = UDim2.new(1, -8, 1, -14)
v1Container.Position = UDim2.new(0, 4, 0, 10)
v1Container.BackgroundTransparency = 1
v1Container.ZIndex = 50
v1Container.Visible = true
v1Container.Parent = panelHolder

local v2Container = Instance.new("Frame")
v2Container.Name = "V2Container"
v2Container.Size = UDim2.new(1, -8, 1, -14)
v2Container.Position = UDim2.new(0, 4, 0, 10)
v2Container.BackgroundTransparency = 1
v2Container.ZIndex = 50
v2Container.Visible = false
v2Container.Parent = panelHolder

local v3Container = Instance.new("Frame")
v3Container.Name = "V3Container"
v3Container.Size = UDim2.new(1, -8, 1, -14)
v3Container.Position = UDim2.new(0, 4, 0, 10)
v3Container.BackgroundTransparency = 1
v3Container.ZIndex = 50
v3Container.Visible = false
v3Container.Parent = panelHolder

------------------------------------------------
-- PAYLAŞIMLI SUNUCU TARAYICI (V1 ve V2 aynı kaynaktan besleniyor)
-- Tek arka plan döngüsü sürekli çalışır, liste kalıcıdır (sekme değişince silinmez),
-- sıralama her taramada karışık başlar (hep aynı sunucular gelmesin diye).
------------------------------------------------
local SharedServerList = {}
local sharedScanRunning = false
local sharedListeners = {}

local function SafeHttpGet(url)
	local success, response = pcall(function()
		return game:HttpGet(url)
	end)
	if success and response then return response end
	return nil
end

local function notifyListeners(server)
	for _, cb in ipairs(sharedListeners) do
		pcall(cb, server)
	end
end

local function startSharedScanner()
	if sharedScanRunning then return end
	sharedScanRunning = true

	task.spawn(function()
		while true do
			local sortOrder = (math.random(1, 2) == 1) and "Asc" or "Desc"
			local cursor = ""
			local pagesThisRound = 0

			while pagesThisRound < 6 do
				local url = "https://games.roblox.com/v1/games/" .. game.PlaceId ..
					"/servers/Public?sortOrder=" .. sortOrder .. "&limit=100"
				if cursor ~= "" then url = url .. "&cursor=" .. cursor end

				local raw = SafeHttpGet(url)
				if raw then
					local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
					if ok and data and data.data then
						for _, s in ipairs(data.data) do
							if s.id ~= game.JobId and s.playing and s.maxPlayers
								and s.playing >= 1 and s.playing < s.maxPlayers then
								local exists = false
								for _, v in ipairs(SharedServerList) do
									if v.id == s.id then exists = true break end
								end
								if not exists then
									table.insert(SharedServerList, s)
									notifyListeners(s)
								end
							end
						end
						cursor = data.nextPageCursor or ""
						pagesThisRound += 1
						if cursor == "" then break end
						task.wait(0.12)
					else
						task.wait(0.15)
						break
					end
				else
					task.wait(1)
					break
				end
			end

			-- Liste çok büyürse en eski girdileri temizle (bellek şişmesin)
			if #SharedServerList > 400 then
				local newList = {}
				for i = #SharedServerList - 300, #SharedServerList do
					if SharedServerList[i] then table.insert(newList, SharedServerList[i]) end
				end
				SharedServerList = newList
			end

			task.wait(0.75)
		end
	end)
end

startSharedScanner()

------------------------------------------------
-- V1: KARANLIK TEMA - paylaşımlı listeyi gösterir, kalıcı (silinmez)
------------------------------------------------
local v1Scroll = nil
local v1Layout = nil
local v1ListenerAdded = false

local function V1_AddServerBtn(server)
	if not v1Scroll or not v1Scroll.Parent then return end
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 22)
	btn.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
	btn.AutoButtonColor = false
	btn.Text = "👤 " .. server.playing .. "/" .. server.maxPlayers
	btn.TextColor3 = server.playing == 1 and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(200, 200, 200)
	btn.TextSize = 9
	btn.Font = Enum.Font.GothamBold
	btn.ZIndex = 52
	btn.Parent = v1Scroll
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 4)
	c.Parent = btn

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(35, 35, 55) }):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(15, 15, 25) }):Play()
	end)

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

local function V1_Build()
	if v1Container:FindFirstChild("Built") then
		-- Zaten kurulu, sadece görünür yap - liste kaybolmasın
		return
	end
	local marker = Instance.new("BoolValue")
	marker.Name = "Built"
	marker.Parent = v1Container

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 14)
	title.BackgroundTransparency = 1
	title.Text = "🐹 V1.5 - SUNUCU LİSTESİ"
	title.TextColor3 = Color3.fromRGB(255, 60, 60)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 10
	title.ZIndex = 51
	title.Parent = v1Container

	v1Scroll = Instance.new("ScrollingFrame")
	v1Scroll.Size = UDim2.new(1, 0, 1, -18)
	v1Scroll.Position = UDim2.new(0, 0, 0, 18)
	v1Scroll.BackgroundTransparency = 1
	v1Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	v1Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	v1Scroll.ScrollBarThickness = 3
	v1Scroll.ScrollBarImageColor3 = Color3.fromRGB(180, 0, 0)
	v1Scroll.ZIndex = 51
	v1Scroll.Parent = v1Container

	v1Layout = Instance.new("UIListLayout")
	v1Layout.Padding = UDim.new(0, 3)
	v1Layout.Parent = v1Scroll

	-- Mevcut listeyi hemen doldur
	for _, s in ipairs(SharedServerList) do
		V1_AddServerBtn(s)
	end

	if not v1ListenerAdded then
		v1ListenerAdded = true
		table.insert(sharedListeners, function(s)
			V1_AddServerBtn(s)
		end)
	end
end

------------------------------------------------
-- V2: NEON / AYDINLIK MİNİMAL TEMA - aynı paylaşımlı liste, farklı görsel
------------------------------------------------
local v2Scroll = nil
local v2Layout = nil
local v2ListenerAdded = false

local function V2_AddServerBtn(server)
	if not v2Scroll or not v2Scroll.Parent then return end
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 24)
	btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	btn.AutoButtonColor = false
	btn.Text = "👤 " .. server.playing .. "/" .. server.maxPlayers
	btn.TextColor3 = Color3.fromRGB(20, 30, 50)
	btn.TextSize = 10
	btn.Font = Enum.Font.GothamBold
	btn.ZIndex = 52
	btn.Parent = v2Scroll
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

local function V2_Build()
	if v2Container:FindFirstChild("Built") then
		return
	end
	local marker = Instance.new("BoolValue")
	marker.Name = "Built"
	marker.Parent = v2Container

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

	v2Scroll = Instance.new("ScrollingFrame")
	v2Scroll.Size = UDim2.new(1, -8, 1, -22)
	v2Scroll.Position = UDim2.new(0, 4, 0, 20)
	v2Scroll.BackgroundTransparency = 1
	v2Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	v2Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	v2Scroll.ScrollBarThickness = 3
	v2Scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
	v2Scroll.ZIndex = 51
	v2Scroll.Parent = v2Container

	v2Layout = Instance.new("UIListLayout")
	v2Layout.Padding = UDim.new(0, 4)
	v2Layout.Parent = v2Scroll

	for _, s in ipairs(SharedServerList) do
		V2_AddServerBtn(s)
	end

	if not v2ListenerAdded then
		v2ListenerAdded = true
		table.insert(sharedListeners, function(s)
			V2_AddServerBtn(s)
		end)
	end
end

------------------------------------------------
-- V3: PRO MODE ÇERÇEVESİ
-- "ŞANS ARTTIRICI MODE" ve "private server gibi yap" özellikleri için
-- BOŞ FONKSİYON YUVALARI bırakılmıştır. Bu fonksiyonların İÇİ doldurulmamıştır -
-- sadece buton, panel ve uyarı mesajının GÖRSEL/UI iskeleti hazırdır.
-- Gerçek mantık (şans arttırma, sunucuya giriş zorlaştırma) ayrıca eklenecektir.
------------------------------------------------
local function V3_OnShansArttiriciStart()
	-- BURAYA GERÇEK MANTIK EKLENECEK (bu fonksiyon şu an sadece bir yuva/placeholder)
	print("[V3] Şans Arttırıcı Mode - Başlat tıklandı (mantık henüz eklenmedi)")
end

local function V3_OnPrivateServerStart()
	-- BURAYA GERÇEK MANTIK EKLENECEK (bu fonksiyon şu an sadece bir yuva/placeholder)
	print("[V3] Private Server Mode - Başlat tıklandı (mantık henüz eklenmedi)")
end

local function V3_ShowWarning(parent, message)
	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	overlay.BackgroundTransparency = 0.3
	overlay.ZIndex = 90
	overlay.Parent = parent

	local box = Instance.new("Frame")
	box.AnchorPoint = Vector2.new(0.5, 0.5)
	box.Position = UDim2.new(0.5, 0, 0.5, 0)
	box.Size = UDim2.new(0.9, 0, 0, 90)
	box.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	box.ZIndex = 91
	box.Parent = overlay
	local boxCorner = Instance.new("UICorner")
	boxCorner.CornerRadius = UDim.new(0, 8)
	boxCorner.Parent = box
	local boxStroke = Instance.new("UIStroke")
	boxStroke.Thickness = 2
	boxStroke.Color = Color3.fromRGB(255, 0, 0)
	boxStroke.Parent = box

	local msg = Instance.new("TextLabel")
	msg.Size = UDim2.new(1, -12, 1, -36)
	msg.Position = UDim2.new(0, 6, 0, 6)
	msg.BackgroundTransparency = 1
	msg.Text = message
	msg.TextColor3 = Color3.fromRGB(230, 230, 230)
	msg.Font = Enum.Font.Gotham
	msg.TextSize = 10
	msg.TextWrapped = true
	msg.ZIndex = 92
	msg.Parent = box

	local okBtn = Instance.new("TextButton")
	okBtn.AnchorPoint = Vector2.new(0.5, 1)
	okBtn.Position = UDim2.new(0.5, 0, 1, -6)
	okBtn.Size = UDim2.new(0, 70, 0, 22)
	okBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
	okBtn.Text = "TAMAM"
	okBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	okBtn.Font = Enum.Font.GothamBold
	okBtn.TextSize = 10
	okBtn.ZIndex = 92
	okBtn.Parent = box
	local okCorner = Instance.new("UICorner")
	okCorner.CornerRadius = UDim.new(0, 6)
	okCorner.Parent = okBtn

	okBtn.MouseButton1Click:Connect(function()
		overlay:Destroy()
	end)
end

local function V3_Build()
	if v3Container:FindFirstChild("Built") then
		return
	end
	local marker = Instance.new("BoolValue")
	marker.Name = "Built"
	marker.Parent = v3Container

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 16)
	title.BackgroundTransparency = 1
	title.Text = "🔒 V3 - PRO MODE"
	title.TextColor3 = Color3.fromRGB(255, 60, 60)
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 11
	title.ZIndex = 51
	title.Parent = v3Container

	-- BUTON 1: 4 yapraklı yonca ikonu -> "ŞANS ARTTIRICI MODE"
	local btn1 = Instance.new("TextButton")
	btn1.Size = UDim2.new(1, 0, 0, 60)
	btn1.Position = UDim2.new(0, 0, 0, 22)
	btn1.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
	btn1.AutoButtonColor = false
	btn1.Text = ""
	btn1.ZIndex = 51
	btn1.Parent = v3Container
	local btn1Corner = Instance.new("UICorner")
	btn1Corner.CornerRadius = UDim.new(0, 8)
	btn1Corner.Parent = btn1
	local btn1Stroke = Instance.new("UIStroke")
	btn1Stroke.Thickness = 1.5
	btn1Stroke.Color = Color3.fromRGB(80, 255, 120)
	btn1Stroke.Transparency = 0.3
	btn1Stroke.Parent = btn1

	local btn1Icon = Instance.new("TextLabel")
	btn1Icon.Size = UDim2.new(0, 30, 0, 30)
	btn1Icon.Position = UDim2.new(0, 8, 0, 4)
	btn1Icon.BackgroundTransparency = 1
	btn1Icon.Text = "🍀"
	btn1Icon.TextSize = 22
	btn1Icon.ZIndex = 52
	btn1Icon.Parent = btn1

	local btn1Title = Instance.new("TextLabel")
	btn1Title.Size = UDim2.new(1, -46, 0, 18)
	btn1Title.Position = UDim2.new(0, 42, 0, 6)
	btn1Title.BackgroundTransparency = 1
	btn1Title.Text = "ŞANS ARTTIRICI MODE"
	btn1Title.TextColor3 = Color3.fromRGB(120, 255, 150)
	btn1Title.Font = Enum.Font.GothamBlack
	btn1Title.TextSize = 10
	btn1Title.TextXAlignment = Enum.TextXAlignment.Left
	btn1Title.ZIndex = 52
	btn1Title.Parent = btn1

	local btn1Start = Instance.new("TextButton")
	btn1Start.Size = UDim2.new(0, 80, 0, 20)
	btn1Start.Position = UDim2.new(1, -88, 1, -26)
	btn1Start.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
	btn1Start.AutoButtonColor = false
	btn1Start.Text = "BAŞLAT"
	btn1Start.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn1Start.Font = Enum.Font.GothamBold
	btn1Start.TextSize = 10
	btn1Start.ZIndex = 52
	btn1Start.Parent = btn1
	local btn1StartCorner = Instance.new("UICorner")
	btn1StartCorner.CornerRadius = UDim.new(0, 6)
	btn1StartCorner.Parent = btn1Start

	btn1Start.MouseEnter:Connect(function()
		TweenService:Create(btn1Start, TweenInfo.new(0.12), { Size = UDim2.new(0, 84, 0, 22) }):Play()
	end)
	btn1Start.MouseLeave:Connect(function()
		TweenService:Create(btn1Start, TweenInfo.new(0.12), { Size = UDim2.new(0, 80, 0, 20) }):Play()
	end)
	btn1Start.MouseButton1Click:Connect(function()
		playSound(SOUNDS.whoosh, 0.4, 1.2)
		V3_OnShansArttiriciStart()
	end)

	-- BUTON 2: kilit ikonu -> "Sunucuyu private server gibi yap"
	local btn2 = Instance.new("TextButton")
	btn2.Size = UDim2.new(1, 0, 0, 60)
	btn2.Position = UDim2.new(0, 0, 0, 88)
	btn2.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
	btn2.AutoButtonColor = false
	btn2.Text = ""
	btn2.ZIndex = 51
	btn2.Parent = v3Container
	local btn2Corner = Instance.new("UICorner")
	btn2Corner.CornerRadius = UDim.new(0, 8)
	btn2Corner.Parent = btn2
	local btn2Stroke = Instance.new("UIStroke")
	btn2Stroke.Thickness = 1.5
	btn2Stroke.Color = Color3.fromRGB(255, 200, 60)
	btn2Stroke.Transparency = 0.3
	btn2Stroke.Parent = btn2

	local btn2Icon = Instance.new("TextLabel")
	btn2Icon.Size = UDim2.new(0, 30, 0, 30)
	btn2Icon.Position = UDim2.new(0, 8, 0, 4)
	btn2Icon.BackgroundTransparency = 1
	btn2Icon.Text = "🔒"
	btn2Icon.TextSize = 22
	btn2Icon.ZIndex = 52
	btn2Icon.Parent = btn2

	local btn2Title = Instance.new("TextLabel")
	btn2Title.Size = UDim2.new(1, -46, 0, 18)
	btn2Title.Position = UDim2.new(0, 42, 0, 6)
	btn2Title.BackgroundTransparency = 1
	btn2Title.Text = "SUNUCUYU PRIVATE\nSERVER GİBİ YAP"
	btn2Title.TextColor3 = Color3.fromRGB(255, 210, 90)
	btn2Title.Font = Enum.Font.GothamBlack
	btn2Title.TextSize = 9
	btn2Title.TextXAlignment = Enum.TextXAlignment.Left
	btn2Title.TextWrapped = true
	btn2Title.ZIndex = 52
	btn2Title.Parent = btn2

	local btn2Start = Instance.new("TextButton")
	btn2Start.Size = UDim2.new(0, 80, 0, 20)
	btn2Start.Position = UDim2.new(1, -88, 1, -26)
	btn2Start.BackgroundColor3 = Color3.fromRGB(200, 150, 30)
	btn2Start.AutoButtonColor = false
	btn2Start.Text = "BAŞLAT"
	btn2Start.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn2Start.Font = Enum.Font.GothamBold
	btn2Start.TextSize = 10
	btn2Start.ZIndex = 52
	btn2Start.Parent = btn2
	local btn2StartCorner = Instance.new("UICorner")
	btn2StartCorner.CornerRadius = UDim.new(0, 6)
	btn2StartCorner.Parent = btn2Start

	btn2Start.MouseEnter:Connect(function()
		TweenService:Create(btn2Start, TweenInfo.new(0.12), { Size = UDim2.new(0, 84, 0, 22) }):Play()
	end)
	btn2Start.MouseLeave:Connect(function()
		TweenService:Create(btn2Start, TweenInfo.new(0.12), { Size = UDim2.new(0, 80, 0, 20) }):Play()
	end)
	btn2Start.MouseButton1Click:Connect(function()
		playSound(SOUNDS.glitch, 0.4, 1.1)
		V3_ShowWarning(v3Container,
			"Bu sunucu private server olmaz. Script özel olarak sunucuya girişleri zorlaştırır.")
		V3_OnPrivateServerStart()
	end)
end

------------------------------------------------
-- SEKME GEÇİŞ MANTIĞI (liste artık silinmiyor, sadece görünürlük değişiyor)
------------------------------------------------
local function selectVersion(version)
	version = "v1"
	currentVersion = "v1"

	v1Container.Visible = true
	v2Container.Visible = false
	v3Container.Visible = false

	for key, btn in pairs(tabButtons) do
		if key == "v1" then
			TweenService:Create(btn, TweenInfo.new(0.15), {
				BackgroundColor3 = Color3.fromRGB(180, 0, 0),
				BackgroundTransparency = 0
			}):Play()
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
	end

	V1_Build()
end

tabButtons.v1.MouseButton1Click:Connect(function()
	playSound(SOUNDS.whoosh, 0.3, 1.3)
	selectVersion("v1")
end)

------------------------------------------------
-- MENÜ AÇ/KAPA
------------------------------------------------
local function openPanel()
	menuOpen = true
	panelHolder.Visible = true
	selectVersion(currentVersion)
	TweenService:Create(panelHolder, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(230, PANEL_OPEN_HEIGHT)
	}):Play()
	playSound(SOUNDS.menuAppear, 0.6, 1.1)
end

local function closePanel()
	menuOpen = false
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
-- GİRİŞ SEKANSI (YENİ): iki çapraz ışın (sağ-alt'tan yukarı, sol-üst'ten aşağı)
-- ortada birleşip patlıyor, sonra HUD merkeze/üste doğru belirir
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
end

local function playFullSequence()
	if skipAnimation then
		showHUD()
		return
	end

	local center = getViewportCenter()
	local vp = camera.ViewportSize

	-- Sağın aşağısından yukarı doğru giden ışın, solun yukarısından aşağı doğru giden ışın
	local startA = Vector2.new(vp.X * 0.85, vp.Y * 0.95)  -- sağ-alt
	local startB = Vector2.new(vp.X * 0.15, vp.Y * 0.05)  -- sol-üst

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

	playSound(SOUNDS.whoosh, 0.5, 0.9)
	local beamA1, beamA2, beamA3 = createTravelingBeam(startA, center, 0.5)
	local beamB1, beamB2, beamB3 = createTravelingBeam(startB, center, 0.5)
	table.insert(elements, beamA1); table.insert(elements, beamA2); table.insert(elements, beamA3)
	table.insert(elements, beamB1); table.insert(elements, beamB2); table.insert(elements, beamB3)

	local skipConn
	skipConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if input.KeyCode == Enum.KeyCode.F3 then
			skipConn:Disconnect()
			goToHUD()
		end
	end)

	task.delay(0.5, function()
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

------------------------------------------------
-- BAŞLAT
------------------------------------------------
playFullSequence()
