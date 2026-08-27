-- LocalScript
-- Köşelerden kayan ışınlar + KARANLIK MEGA patlama + HAMSTER LIVES PRO MODE menüsü
-- NIGHTMARE / VOID EDITION + SES EFEKTLERİ + AÇ/KAPA SİSTEMİ + SERVER FİNDER
-- F3: animasyonu atlayıp direkt menüyü açar

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera
local LocalPlayer = player

------------------------------------------------
-- SES EFEKTLERİ
------------------------------------------------
local function playSound(id, volume, pitch)
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. id
	sound.Volume = volume or 1
	sound.PlaybackSpeed = pitch or 1
	sound.Parent = SoundService
	sound:Play()
	sound.Ended:Connect(function() sound:Destroy() end)
	task.delay(8, function() if sound and sound.Parent then sound:Destroy() end end)
	return sound
end

local SOUNDS = {
	whoosh = 9118823728,
	explosion = 9125715540,
	darkRumble = 9046191806,
	menuAppear = 9114253392,
	glitch = 9042866550,
	heartbeat = 9046191806,
}

------------------------------------------------
-- CİHAZ ALGILAMA
------------------------------------------------
local function getDeviceType()
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		return "Mobile"
	end
	return "PC"
end

local deviceType = getDeviceType()
print("Algılanan cihaz: " .. deviceType)

------------------------------------------------
-- GUI KURULUMU
------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HamsterProEffect"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999
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

------------------------------------------------
-- SKIP FLAG (F3)
------------------------------------------------
local skipAnimation = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.F3 then
		skipAnimation = true
	end
end)

------------------------------------------------
-- VIGNETTE
------------------------------------------------
local function createVignette()
	local vignette = Instance.new("Frame")
	vignette.Size = UDim2.new(1, 0, 1, 0)
	vignette.BackgroundTransparency = 1
	vignette.BorderSizePixel = 0
	vignette.ZIndex = 2
	vignette.Parent = screenGui

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,0,0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
	})
	gradient.Parent = vignette

	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	overlay.BackgroundTransparency = 1
	overlay.BorderSizePixel = 0
	overlay.ZIndex = 2
	overlay.Parent = screenGui

	TweenService:Create(overlay, TweenInfo.new(0.6, Enum.EasingStyle.Sine), {
		BackgroundTransparency = 0.55
	}):Play()

	return overlay
end

------------------------------------------------
-- IŞIN
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

	TweenService:Create(beam, tweenInfo, {
		Position = UDim2.fromOffset(endPos.X, endPos.Y)
	}):Play()
	TweenService:Create(glow, tweenInfo, {
		Position = UDim2.fromOffset(endPos.X, endPos.Y)
	}):Play()
	TweenService:Create(outerGlow, tweenInfo, {
		Position = UDim2.fromOffset(endPos.X, endPos.Y)
	}):Play()

	return beam, glow, outerGlow
end

------------------------------------------------
-- PATLAMA
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

	local chromaColors = {
		Color3.fromRGB(255, 0, 0),
		Color3.fromRGB(120, 0, 0),
		Color3.fromRGB(255, 255, 255),
	}
	for ci, col in ipairs(chromaColors) do
		local ring = Instance.new("Frame")
		ring.AnchorPoint = Vector2.new(0.5, 0.5)
		ring.Position = UDim2.fromOffset(center.X + (ci - 2) * 5, center.Y)
		ring.Size = UDim2.fromOffset(6, 6)
		ring.BackgroundTransparency = 1
		ring.BorderSizePixel = 0
		ring.ZIndex = 17
		ring.Parent = screenGui

		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 5
		stroke.Color = col
		stroke.Transparency = 0.05
		stroke.Parent = ring

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = ring

		TweenService:Create(ring, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.fromOffset(280, 280),
			Position = UDim2.fromOffset(center.X, center.Y)
		}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
		task.delay(0.55, function() ring:Destroy() end)
	end

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

		local goalSize = 150 + (i * 115)
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

	local coreGlow = Instance.new("Frame")
	coreGlow.AnchorPoint = Vector2.new(0.5, 0.5)
	coreGlow.Position = UDim2.fromOffset(center.X, center.Y)
	coreGlow.Size = UDim2.fromOffset(45, 45)
	coreGlow.BackgroundColor3 = Color3.fromRGB(255, 200, 200)
	coreGlow.BackgroundTransparency = 0.1
	coreGlow.BorderSizePixel = 0
	coreGlow.ZIndex = 15
	coreGlow.Parent = screenGui
	local coreGlowCorner = Instance.new("UICorner")
	coreGlowCorner.CornerRadius = UDim.new(1, 0)
	coreGlowCorner.Parent = coreGlow

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
	TweenService:Create(coreGlow, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(340, 340),
		BackgroundTransparency = 1
	}):Play()
	task.delay(0.5, function()
		core:Destroy()
		coreGlow:Destroy()
	end)

	local sparkColors = {
		Color3.fromRGB(255, 30, 30),
		Color3.fromRGB(180, 0, 0),
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(80, 0, 0),
	}
	for i = 1, 40 do
		local particle = Instance.new("Frame")
		particle.AnchorPoint = Vector2.new(0.5, 0.5)
		particle.Position = UDim2.fromOffset(center.X, center.Y)
		local size = math.random(3, 7)
		particle.Size = UDim2.fromOffset(size, size)
		particle.BackgroundColor3 = sparkColors[math.random(1, #sparkColors)]
		particle.BorderSizePixel = 0
		particle.ZIndex = 14
		particle.Parent = screenGui

		local pCorner = Instance.new("UICorner")
		pCorner.CornerRadius = UDim.new(1, 0)
		pCorner.Parent = particle

		local ang = math.rad(math.random(0, 360))
		local dist = math.random(150, 440)
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
-- HAMSTER İKON (KÜÇÜK)
------------------------------------------------
local function createHamsterIcon(parent)
	local holder = Instance.new("Frame")
	holder.AnchorPoint = Vector2.new(0.5, 0)
	holder.Position = UDim2.new(0.5, 0, 0, 2)
	holder.Size = UDim2.fromOffset(50, 50)
	holder.BackgroundTransparency = 1
	holder.ZIndex = 32
	holder.Parent = parent

	local strokeColor = Color3.fromRGB(200, 200, 200)

	local head = Instance.new("Frame")
	head.AnchorPoint = Vector2.new(0.5, 0.5)
	head.Position = UDim2.new(0.5, 0, 0.55, 0)
	head.Size = UDim2.fromOffset(40, 34)
	head.BackgroundTransparency = 1
	head.ZIndex = 33
	head.Parent = holder

	local headCorner = Instance.new("UICorner")
	headCorner.CornerRadius = UDim.new(1, 0)
	headCorner.Parent = head

	local headStroke = Instance.new("UIStroke")
	headStroke.Thickness = 2
	headStroke.Color = strokeColor
	headStroke.Parent = head

	local function makeEar(xScale)
		local ear = Instance.new("Frame")
		ear.AnchorPoint = Vector2.new(0.5, 0.5)
		ear.Position = UDim2.new(xScale, 0, 0.12, 0)
		ear.Size = UDim2.fromOffset(14, 14)
		ear.BackgroundTransparency = 1
		ear.ZIndex = 32
		ear.Parent = holder

		local earCorner = Instance.new("UICorner")
		earCorner.CornerRadius = UDim.new(1, 0)
		earCorner.Parent = ear

		local earStroke = Instance.new("UIStroke")
		earStroke.Thickness = 2
		earStroke.Color = strokeColor
		earStroke.Parent = ear

		return ear
	end
	makeEar(0.28)
	makeEar(0.72)

	local nose = Instance.new("Frame")
	nose.AnchorPoint = Vector2.new(0.5, 0.5)
	nose.Position = UDim2.new(0.5, 0, 0.72, 0)
	nose.Size = UDim2.fromOffset(4, 3)
	nose.BackgroundColor3 = strokeColor
	nose.BorderSizePixel = 0
	nose.ZIndex = 34
	nose.Parent = holder

	local noseCorner = Instance.new("UICorner")
	noseCorner.CornerRadius = UDim.new(1, 0)
	noseCorner.Parent = nose

	local function makeWhisker(xScale, yScale, rotation)
		local whisker = Instance.new("Frame")
		whisker.AnchorPoint = Vector2.new(0.5, 0.5)
		whisker.Position = UDim2.new(xScale, 0, yScale, 0)
		whisker.Size = UDim2.fromOffset(12, 1.5)
		whisker.Rotation = rotation
		whisker.BackgroundColor3 = strokeColor
		whisker.BackgroundTransparency = 0.3
		whisker.BorderSizePixel = 0
		whisker.ZIndex = 32
		whisker.Parent = holder
	end
	makeWhisker(0.2, 0.66, -12)
	makeWhisker(0.18, 0.76, 10)
	makeWhisker(0.8, 0.66, 12)
	makeWhisker(0.82, 0.76, -10)

	local function makeEye(xScale)
		local eye = Instance.new("Frame")
		eye.AnchorPoint = Vector2.new(0.5, 0.5)
		eye.Position = UDim2.new(xScale, 0, 0.52, 0)
		eye.Size = UDim2.fromOffset(6, 6)
		eye.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		eye.BorderSizePixel = 0
		eye.ZIndex = 34
		eye.Parent = holder

		local eyeCorner = Instance.new("UICorner")
		eyeCorner.CornerRadius = UDim.new(1, 0)
		eyeCorner.Parent = eye

		local eyeGlow = Instance.new("Frame")
		eyeGlow.AnchorPoint = Vector2.new(0.5, 0.5)
		eyeGlow.Position = UDim2.fromScale(0.5, 0.5)
		eyeGlow.Size = UDim2.fromOffset(14, 14)
		eyeGlow.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		eyeGlow.BackgroundTransparency = 0.3
		eyeGlow.BorderSizePixel = 0
		eyeGlow.ZIndex = 33
		eyeGlow.Parent = eye

		local eyeGlowCorner = Instance.new("UICorner")
		eyeGlowCorner.CornerRadius = UDim.new(1, 0)
		eyeGlowCorner.Parent = eyeGlow

		task.spawn(function()
			while eye.Parent do
				TweenService:Create(eyeGlow, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					BackgroundTransparency = 0.0,
					Size = UDim2.fromOffset(18, 18)
				}):Play()
				task.wait(0.5)
				if not eye.Parent then break end
				TweenService:Create(eyeGlow, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					BackgroundTransparency = 0.45,
					Size = UDim2.fromOffset(10, 10)
				}):Play()
				task.wait(0.5)
			end
		end)

		return eye
	end
	makeEye(0.4)
	makeEye(0.6)

	return holder
end

------------------------------------------------
-- SERVER FİNDER (MENÜ İÇİNE ALTA EKLENEN LİSTE) - DEĞİŞMEDİ
------------------------------------------------
local function CreateServerFinder(parentSlot)
	local VerifiedServers = {}
	local GuiRef = nil
	local scanning = false
	
	local function SafeHttpGet(url)
		local success, response = pcall(function()
			return game:HttpGet(url)
		end)
		if success and response then return response end
		return nil
	end
	
	local function BuildList()
		local old = parentSlot:FindFirstChild("ServerList")
		if old then old:Destroy() end
		
		local main = Instance.new("Frame")
		main.Name = "ServerList"
		main.Size = UDim2.new(1, -5, 1, -5)
		main.Position = UDim2.new(0, 2.5, 0, 2.5)
		main.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
		main.BackgroundTransparency = 0.2
		main.Parent = parentSlot
		main.ZIndex = 50
		Instance.new("UICorner", main).CornerRadius = UDim.new(0, 6)
		GuiRef = main
		
		local scroll = Instance.new("ScrollingFrame")
		scroll.Size = UDim2.new(1, -8, 1, -8)
		scroll.Position = UDim2.new(0, 4, 0, 4)
		scroll.BackgroundTransparency = 1
		scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scroll.Parent = main
		scroll.ZIndex = 51
		scroll.ScrollBarThickness = 3
		scroll.ScrollBarImageColor3 = Color3.fromRGB(180, 0, 0)
		
		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 3)
		layout.Parent = scroll
		
		local function AddServer(server)
			if server.playing ~= 1 then return end
			
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, -4, 0, 22)
			btn.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
			btn.Text = server.id:sub(1, 6) .. " | 👤" .. server.playing
			btn.TextColor3 = Color3.fromRGB(255, 200, 0)
			btn.TextSize = 9
			btn.Font = Enum.Font.GothamBold
			btn.Parent = scroll
			btn.ZIndex = 52
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
			
			btn.MouseButton1Click:Connect(function()
				local sid = server.id
				task.spawn(function()
					pcall(function()
						TeleportService:TeleportToPlaceInstance(game.PlaceId, sid, LocalPlayer)
					end)
				end)
			end)
		end
		
		for _, s in ipairs(VerifiedServers) do
			AddServer(s)
		end
		
		local function AddNew(server)
			if server.playing == 1 then
				AddServer(server)
				task.wait(0.05)
				scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
			end
		end
		
		return AddNew
	end
	
	local function StartScan(addCb)
		if scanning then return end
		scanning = true
		
		task.spawn(function()
			local cursor = ""
			while GuiRef and GuiRef.Parent do
				local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
				if cursor ~= "" then url = url .. "&cursor=" .. cursor end
				
				local raw = SafeHttpGet(url)
				if raw then
					local ok, res = pcall(function() return HttpService:JSONDecode(raw) end)
					if ok and res and res.data then
						for _, s in ipairs(res.data) do
							if s.id ~= game.JobId and s.playing == 1 and s.playing < s.maxPlayers then
								local exists = false
								for _, v in ipairs(VerifiedServers) do
									if v.id == s.id then exists = true break end
								end
								if not exists then
									table.insert(VerifiedServers, s)
									if addCb then addCb(s) end
								end
							end
						end
						cursor = res.nextPageCursor or ""
						if cursor == "" then task.wait(3) else task.wait(1) end
					else task.wait(1) end
				else task.wait(1) end
				task.wait(0.5)
			end
		end)
	end
	
	local addCb = BuildList()
	if addCb then StartScan(addCb) end
end

------------------------------------------------
-- ARKA PLAN PARÇACIKLARI
------------------------------------------------
local function startBackgroundParticles(content)
	task.spawn(function()
		while content.Parent do
			local p = Instance.new("Frame")
			p.AnchorPoint = Vector2.new(0.5, 0.5)
			p.Size = UDim2.fromOffset(math.random(2, 4), math.random(2, 4))
			p.Position = UDim2.new(math.random(), 0, 1, 10)
			p.BackgroundColor3 = Color3.fromRGB(200, 20, 20)
			p.BackgroundTransparency = 0.2
			p.BorderSizePixel = 0
			p.ZIndex = 31
			p.Parent = content
			local pc = Instance.new("UICorner")
			pc.CornerRadius = UDim.new(1, 0)
			pc.Parent = p

			local dur = 2 + math.random() * 1.5
			TweenService:Create(p, TweenInfo.new(dur, Enum.EasingStyle.Linear), {
				Position = UDim2.new(p.Position.X.Scale, 0, -0.1, 0),
				BackgroundTransparency = 1
			}):Play()
			task.delay(dur, function() if p.Parent then p:Destroy() end end)

			task.wait(0.1)
		end
	end)
end

------------------------------------------------
-- SCANLINE
------------------------------------------------
local function startScanline(content)
	local scan = Instance.new("Frame")
	scan.Size = UDim2.new(1, 0, 0, 2)
	scan.Position = UDim2.new(0, 0, 0, 0)
	scan.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	scan.BackgroundTransparency = 0.7
	scan.BorderSizePixel = 0
	scan.ZIndex = 35
	scan.Parent = content

	task.spawn(function()
		while scan.Parent do
			scan.Position = UDim2.new(0, 0, 0, -10)
			local tween = TweenService:Create(scan, TweenInfo.new(1.4, Enum.EasingStyle.Linear), {
				Position = UDim2.new(0, 0, 1, 10)
			})
			tween:Play()
			tween.Completed:Wait()
		end
	end)
end

------------------------------------------------
-- GLITCH
------------------------------------------------
local function startGlitch(titleLabel, titleStroke)
	task.spawn(function()
		while titleLabel.Parent do
			task.wait(math.random(12, 28) / 10)
			if not titleLabel.Parent then break end
			playSound(SOUNDS.glitch, 0.4, 1.3)
			local originalPos = titleLabel.Position
			for i = 1, 4 do
				if not titleLabel.Parent then break end
				titleLabel.Position = originalPos + UDim2.fromOffset(math.random(-4, 4), math.random(-3, 3))
				titleStroke.Color = (i % 2 == 0) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 0, 0)
				task.wait(0.04)
			end
			titleLabel.Position = originalPos
			titleStroke.Color = Color3.fromRGB(255, 0, 0)
		end
	end)
	end------------------------------------------------
-- AÇ/KAPA SİSTEMİ (X butonu + ışın toplanma animasyonu)
------------------------------------------------
local currentPanel = nil
local currentContent = nil
local currentOuterGlow = nil
local minimizedDot = nil
local menuIsOpen = true

local function createMinimizedDot()
	if minimizedDot then minimizedDot:Destroy() end

	local vp = camera.ViewportSize
	local dotPos = Vector2.new(vp.X - 40, 40)

	local dotHolder = Instance.new("Frame")
	dotHolder.Name = "MinimizedDot"
	dotHolder.AnchorPoint = Vector2.new(0.5, 0.5)
	dotHolder.Position = UDim2.fromOffset(dotPos.X, dotPos.Y)
	dotHolder.Size = UDim2.fromOffset(0, 0)
	dotHolder.BackgroundTransparency = 1
	dotHolder.ZIndex = 40
	dotHolder.Parent = screenGui

	local dotBg = Instance.new("Frame")
	dotBg.AnchorPoint = Vector2.new(0.5, 0.5)
	dotBg.Position = UDim2.new(0.5, 0, 0.5, 0)
	dotBg.Size = UDim2.new(1, 0, 1, 0)
	dotBg.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
	dotBg.BorderSizePixel = 0
	dotBg.ZIndex = 40
	dotBg.Parent = dotHolder
	local dotCorner = Instance.new("UICorner")
	dotCorner.CornerRadius = UDim.new(1, 0)
	dotCorner.Parent = dotBg

	local dotStroke = Instance.new("UIStroke")
	dotStroke.Thickness = 2
	dotStroke.Color = Color3.fromRGB(255, 0, 0)
	dotStroke.Transparency = 0.3
	dotStroke.Parent = dotBg

	local fillRing = Instance.new("Frame")
	fillRing.AnchorPoint = Vector2.new(0.5, 0.5)
	fillRing.Position = UDim2.new(0.5, 0, 0.5, 0)
	fillRing.Size = UDim2.new(0, 0, 0, 0)
	fillRing.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	fillRing.BackgroundTransparency = 1
	fillRing.BorderSizePixel = 0
	fillRing.ZIndex = 39
	fillRing.Parent = dotHolder
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fillRing

	local miniIconHolder = Instance.new("Frame")
	miniIconHolder.AnchorPoint = Vector2.new(0.5, 0.5)
	miniIconHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
	miniIconHolder.Size = UDim2.new(0.6, 0, 0.6, 0)
	miniIconHolder.BackgroundTransparency = 1
	miniIconHolder.ZIndex = 41
	miniIconHolder.Parent = dotHolder

	local miniHead = Instance.new("Frame")
	miniHead.AnchorPoint = Vector2.new(0.5, 0.5)
	miniHead.Position = UDim2.new(0.5, 0, 0.5, 0)
	miniHead.Size = UDim2.new(1, 0, 0.85, 0)
	miniHead.BackgroundTransparency = 1
	miniHead.ZIndex = 41
	miniHead.Parent = miniIconHolder
	local miniHeadCorner = Instance.new("UICorner")
	miniHeadCorner.CornerRadius = UDim.new(1, 0)
	miniHeadCorner.Parent = miniHead
	local miniHeadStroke = Instance.new("UIStroke")
	miniHeadStroke.Thickness = 1.5
	miniHeadStroke.Color = Color3.fromRGB(255, 255, 255)
	miniHeadStroke.Parent = miniHead

	local function miniEye(xScale)
		local eye = Instance.new("Frame")
		eye.AnchorPoint = Vector2.new(0.5, 0.5)
		eye.Position = UDim2.new(xScale, 0, 0.5, 0)
		eye.Size = UDim2.fromOffset(3, 3)
		eye.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		eye.BorderSizePixel = 0
		eye.ZIndex = 42
		eye.Parent = miniIconHolder
		local eyeCorner = Instance.new("UICorner")
		eyeCorner.CornerRadius = UDim.new(1, 0)
		eyeCorner.Parent = eye
	end
	miniEye(0.35)
	miniEye(0.65)

	TweenService:Create(dotHolder, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(44, 44)
	}):Play()

	local clickBtn = Instance.new("TextButton")
	clickBtn.Size = UDim2.new(1, 0, 1, 0)
	clickBtn.BackgroundTransparency = 1
	clickBtn.Text = ""
	clickBtn.ZIndex = 43
	clickBtn.Parent = dotHolder

	minimizedDot = dotHolder

	return dotHolder, fillRing, clickBtn, dotPos
end

local function collapseMenuToPoint(panel, content, outerGlow, onEachBeamArrive, onAllDone)
	local absPos = panel.AbsolutePosition
	local absSize = panel.AbsoluteSize

	local dotHolder, fillRing, clickBtn, dotPos = createMinimizedDot()

	content.Visible = false

	local quadrants = {
		{ pos = UDim2.fromOffset(absPos.X, absPos.Y), size = UDim2.fromOffset(absSize.X/2, absSize.Y/2) },
		{ pos = UDim2.fromOffset(absPos.X + absSize.X/2, absPos.Y), size = UDim2.fromOffset(absSize.X/2, absSize.Y/2) },
		{ pos = UDim2.fromOffset(absPos.X, absPos.Y + absSize.Y/2), size = UDim2.fromOffset(absSize.X/2, absSize.Y/2) },
		{ pos = UDim2.fromOffset(absPos.X + absSize.X/2, absPos.Y + absSize.Y/2), size = UDim2.fromOffset(absSize.X/2, absSize.Y/2) },
	}

	panel.Visible = false
	outerGlow.Visible = false

	local piecesRemaining = #quadrants
	local fillProgress = { value = 0 }

	for i, q in ipairs(quadrants) do
		task.delay((i - 1) * 0.05, function()
			local piece = Instance.new("Frame")
			piece.BackgroundColor3 = Color3.fromRGB(10, 2, 2)
			piece.Position = q.pos
			piece.Size = q.size
			piece.BorderSizePixel = 0
			piece.ZIndex = 45
			piece.Parent = screenGui

			local pieceStroke = Instance.new("UIStroke")
			pieceStroke.Thickness = 2
			pieceStroke.Color = Color3.fromRGB(255, 0, 0)
			pieceStroke.Transparency = 0.2
			pieceStroke.Parent = piece

			playSound(SOUNDS.whoosh, 0.4, 1.4)

			local tween = TweenService:Create(piece, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Position = UDim2.fromOffset(dotPos.X, dotPos.Y),
				Size = UDim2.fromOffset(4, 4),
				BackgroundTransparency = 1
			})
			TweenService:Create(pieceStroke, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Transparency = 1
			}):Play()
			tween:Play()

			tween.Completed:Connect(function(state)
				if state ~= Enum.PlaybackState.Completed then return end
				piece:Destroy()

				fillProgress.value += 1
				local pct = fillProgress.value / #quadrants

				TweenService:Create(fillRing, TweenInfo.new(0.15), {
					Size = UDim2.new(pct, 0, pct, 0),
					BackgroundTransparency = 1 - (pct * 0.6)
				}):Play()

				if onEachBeamArrive then onEachBeamArrive(pct) end

				piecesRemaining -= 1
				if piecesRemaining <= 0 then
					playSound(SOUNDS.glitch, 0.5, 1.2)
					if onAllDone then onAllDone() end
				end
			end)
		end)
	end
end

local function expandMenuFromPoint(dotHolder, onDone)
	playSound(SOUNDS.menuAppear, 0.8, 1.1)

	TweenService:Create(dotHolder, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = UDim2.fromOffset(0, 0)
	}):Play()
	task.delay(0.25, function()
		if dotHolder and dotHolder.Parent then dotHolder:Destroy() end
		minimizedDot = nil
	end)

	local center2, corners = getCenterAndCorners()
	local elements = {}

	for _, cornerPos in ipairs(corners) do
		playSound(SOUNDS.whoosh, 0.4, 1.1 + math.random() * 0.2)
		local beam, glow, outerGlow = createTravelingBeam(cornerPos, center2)
		table.insert(elements, beam)
		table.insert(elements, glow)
		table.insert(elements, outerGlow)
	end

	task.delay(TRAVEL_TIME, function()
		createExplosion(center2, function()
			if onDone then onDone() end
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
-- ANA MENÜ (KÜÇÜK - SERVER LİSTESİ ALTA + X BUTONU)
------------------------------------------------
local function createHamsterMenu()
	currentPanel = nil
	currentContent = nil
	currentOuterGlow = nil

	playSound(SOUNDS.menuAppear, 1, 0.8)
	local vignette = createVignette()

	local vp = camera.ViewportSize
	local center = Vector2.new(vp.X / 2, vp.Y / 2)

	local panel = Instance.new("Frame")
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromOffset(center.X, center.Y)
	panel.Size = UDim2.fromOffset(0, 0)
	panel.BackgroundColor3 = Color3.fromRGB(10, 2, 2)
	panel.BorderSizePixel = 0
	panel.ZIndex = 30
	panel.ClipsDescendants = true
	panel.Parent = screenGui

	local panelCorner = Instance.new("UICorner")
	panelCorner.CornerRadius = UDim.new(0, 14)
	panelCorner.Parent = panel

	local panelStroke = Instance.new("UIStroke")
	panelStroke.Thickness = 2
	panelStroke.Color = Color3.fromRGB(255, 0, 0)
	panelStroke.Transparency = 0.1
	panelStroke.Parent = panel

	-- KAPAT (X) BUTONU
	local closeBtn = Instance.new("TextButton")
	closeBtn.AnchorPoint = Vector2.new(1, 0)
	closeBtn.Position = UDim2.new(1, -8, 0, 8)
	closeBtn.Size = UDim2.fromOffset(20, 20)
	closeBtn.BackgroundColor3 = Color3.fromRGB(20, 5, 5)
	closeBtn.Text = "✕"
	closeBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 12
	closeBtn.ZIndex = 60
	closeBtn.Parent = panel
	local closeBtnCorner = Instance.new("UICorner")
	closeBtnCorner.CornerRadius = UDim.new(1, 0)
	closeBtnCorner.Parent = closeBtn
	local closeBtnStroke = Instance.new("UIStroke")
	closeBtnStroke.Thickness = 1
	closeBtnStroke.Color = Color3.fromRGB(255, 0, 0)
	closeBtnStroke.Transparency = 0.4
	closeBtnStroke.Parent = closeBtn

	local outerGlow = Instance.new("Frame")
	outerGlow.AnchorPoint = Vector2.new(0.5, 0.5)
	outerGlow.Position = UDim2.fromOffset(center.X, center.Y)
	outerGlow.Size = UDim2.fromOffset(0, 0)
	outerGlow.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	outerGlow.BackgroundTransparency = 0.8
	outerGlow.BorderSizePixel = 0
	outerGlow.ZIndex = 29
	outerGlow.Parent = screenGui

	local outerGlowCorner = Instance.new("UICorner")
	outerGlowCorner.CornerRadius = UDim.new(0, 24)
	outerGlowCorner.Parent = outerGlow

	closeBtn.MouseButton1Click:Connect(function()
		if not menuIsOpen then return end
		menuIsOpen = false
		vignette:Destroy()
		collapseMenuToPoint(panel, currentContent, outerGlow, nil, function()
			panel:Destroy()
			outerGlow:Destroy()
		end)
	end)

	local content = Instance.new("Frame")
	content.Size = UDim2.fromOffset(280, 380)
	content.Position = UDim2.new(0.5, -140, 0.5, -190)
	content.BackgroundTransparency = 1
	content.ZIndex = 31
	content.ClipsDescendants = false
	content.Parent = panel

	TweenService:Create(panel, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(280, 380)
	}):Play()
	TweenService:Create(outerGlow, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(300, 400)
	}):Play()

	startBackgroundParticles(content)
	startScanline(content)

	local serverSlot = Instance.new("Frame")
	serverSlot.Name = "ServerSlot"
	serverSlot.AnchorPoint = Vector2.new(0.5, 0)
	serverSlot.Position = UDim2.new(0.5, 0, 0, 165)
	serverSlot.Size = UDim2.new(1, -10, 0, 190)
	serverSlot.BackgroundTransparency = 1
	serverSlot.ZIndex = 60
	serverSlot.Parent = content

	local tag = Instance.new("TextLabel")
	tag.AnchorPoint = Vector2.new(0.5, 0)
	tag.Position = UDim2.new(0.5, 0, 0, 2)
	tag.Size = UDim2.new(1, -20, 0, 12)
	tag.BackgroundTransparency = 1
	tag.Text = "▪ HAMSTER PRO ▪"
	tag.TextColor3 = Color3.fromRGB(255, 0, 0)
	tag.Font = Enum.Font.GothamBold
	tag.TextSize = 9
	tag.TextXAlignment = Enum.TextXAlignment.Center
	tag.ZIndex = 32
	tag.Parent = content

	createHamsterIcon(content)

	local title = Instance.new("TextLabel")
	title.AnchorPoint = Vector2.new(0.5, 0)
	title.Position = UDim2.new(0.5, 0, 0, 58)
	title.Size = UDim2.new(1, -20, 0, 24)
	title.BackgroundTransparency = 1
	title.Text = "HAMSTER LIVES"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 16
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.ZIndex = 32
	title.Parent = content

	local titleStroke = Instance.new("UIStroke")
	titleStroke.Thickness = 1
	titleStroke.Color = Color3.fromRGB(255, 0, 0)
	titleStroke.Parent = title

	startGlitch(title, titleStroke)

	local barBg = Instance.new("Frame")
	barBg.AnchorPoint = Vector2.new(0.5, 0)
	barBg.Position = UDim2.new(0.5, 0, 0, 88)
	barBg.Size = UDim2.new(0.6, 0, 0, 6)
	barBg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	barBg.BorderSizePixel = 0
	barBg.ZIndex = 32
	barBg.Parent = content

	local barBgCorner = Instance.new("UICorner")
	barBgCorner.CornerRadius = UDim.new(1, 0)
	barBgCorner.Parent = barBg

	local barFill = Instance.new("Frame")
	barFill.AnchorPoint = Vector2.new(0, 0.5)
	barFill.Position = UDim2.new(0, 0, 0.5, 0)
	barFill.Size = UDim2.new(0, 0, 1, 0)
	barFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	barFill.BorderSizePixel = 0
	barFill.ZIndex = 33
	barFill.Parent = barBg

	local barFillCorner = Instance.new("UICorner")
	barFillCorner.CornerRadius = UDim.new(1, 0)
	barFillCorner.Parent = barFill

	local barGradient = Instance.new("UIGradient")
	barGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 0, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
	})
	barGradient.Parent = barFill

	local loadingText = Instance.new("TextLabel")
	loadingText.AnchorPoint = Vector2.new(0.5, 0)
	loadingText.Position = UDim2.new(0.5, 0, 0, 72)
	loadingText.Size = UDim2.new(1, -40, 0, 14)
	loadingText.BackgroundTransparency = 1
	loadingText.Text = "INITIALIZING..."
	loadingText.TextColor3 = Color3.fromRGB(180, 180, 180)
	loadingText.Font = Enum.Font.GothamMedium
	loadingText.TextSize = 10
	loadingText.ZIndex = 32
	loadingText.Parent = content

	local fillTween = TweenService:Create(barFill, TweenInfo.new(2.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 1, 0)
	})
	fillTween:Play()

	fillTween.Completed:Connect(function(state)
		if state ~= Enum.PlaybackState.Completed then return end

		playSound(SOUNDS.darkRumble, 0.7, 1.1)

		local flash = Instance.new("Frame")
		flash.Size = UDim2.new(1, 0, 1, 0)
		flash.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		flash.BackgroundTransparency = 0.5
		flash.BorderSizePixel = 0
		flash.ZIndex = 36
		flash.Parent = content
		TweenService:Create(flash, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1
		}):Play()
		task.delay(0.4, function() flash:Destroy() end)

		TweenService:Create(panel, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		}):Play()

		TweenService:Create(panelStroke, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Transparency = 0.5
		}):Play()

		TweenService:Create(outerGlow, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.96
		}):Play()

		loadingText.Text = "READY"

		CreateServerFinder(serverSlot)
	end)

	currentPanel = panel
	currentContent = content
	currentOuterGlow = outerGlow
end

------------------------------------------------
-- ANA ÇALIŞTIRICI
------------------------------------------------
local function playFullSequence()
	if skipAnimation then
		createHamsterMenu()
		return
	end

	local center, corners = getCenterAndCorners()
	local elements = {}
	local finished = false

	local function goToMenu()
		if finished then return end
		finished = true
		for _, el in ipairs(elements) do
			if el and el.Parent then el:Destroy() end
		end
		createHamsterMenu()
	end

	for _, cornerPos in ipairs(corners) do
		playSound(SOUNDS.whoosh, 0.5, 1 + math.random() * 0.2)
		local beam, glow, outerGlow = createTravelingBeam(cornerPos, center)
		table.insert(elements, beam)
		table.insert(elements, glow)
		table.insert(elements, outerGlow)
	end

	local skipConn
	skipConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if input.KeyCode == Enum.KeyCode.F3 then
			skipConn:Disconnect()
			goToMenu()
		end
	end)

	task.delay(TRAVEL_TIME, function()
		if finished then return end
		createExplosion(center, function()
			if not finished then
				finished = true
				skipConn:Disconnect()
				createHamsterMenu()
			end
		end)

		for _, el in ipairs(elements) do
			if el.Parent then
				TweenService:Create(el, TweenInfo.new(0.15), {
					BackgroundTransparency = 1
				}):Play()
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
-- MINIMIZED DOT TIKLAMA DİNLEYİCİSİ
------------------------------------------------
local function watchForDotClick()
	task.spawn(function()
		while true do
			task.wait(0.1)
			if minimizedDot and minimizedDot.Parent then
				local clickBtn = minimizedDot:FindFirstChildOfClass("TextButton")
				if clickBtn and not clickBtn:GetAttribute("Connected") then
					clickBtn:SetAttribute("Connected", true)
					clickBtn.MouseButton1Click:Connect(function()
						if menuIsOpen then return end
						local dotRef = minimizedDot
						expandMenuFromPoint(dotRef, function()
							menuIsOpen = true
							createHamsterMenu()
						end)
					end)
				end
			end
		end
	end)
end

------------------------------------------------
-- BAŞLAT
------------------------------------------------
watchForDotClick()
playFullSequence()
