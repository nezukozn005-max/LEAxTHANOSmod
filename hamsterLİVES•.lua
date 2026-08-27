-- ============================================================
-- HAMSTER LIVES - ULTRA EGG CARRY V4 (PART 1/2)
-- ANA MENÜ + MOD1/MOD2 BUTONLARI
-- ============================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

print("🐹 ULTRA EGG CARRY V4 BAŞLADI...")

------------------------------------------------
-- SES
------------------------------------------------
local function playSound(id, volume, pitch)
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. id
	sound.Volume = volume or 1
	sound.PlaybackSpeed = pitch or 1
	sound.Parent = SoundService
	sound:Play()
	sound.Ended:Connect(function() sound:Destroy() end)
	task.delay(6, function() if sound and sound.Parent then sound:Destroy() end end)
end

local SOUNDS = {
	paperUnroll = 9114253392,
	woodClack = 9118823728,
	paperCrinkle = 9042866550,
}

------------------------------------------------
-- GUI KURULUMU
------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ScrollMenu"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 998
screenGui.Parent = playerGui

------------------------------------------------
-- AYARLAR
------------------------------------------------
local ROLL_WIDTH = 100
local ROLL_CLOSED_HEIGHT = 36
local SCROLL_OPEN_HEIGHT = 290
local HORIZONTAL_OFFSET = 0.62
local isOpen = false

------------------------------------------------
-- ZEMİN GÖLGESİ
------------------------------------------------
local shadowBlob = Instance.new("Frame")
shadowBlob.AnchorPoint = Vector2.new(0.5, 0)
shadowBlob.Position = UDim2.new(HORIZONTAL_OFFSET, 3, 0, 14)
shadowBlob.Size = UDim2.fromOffset(ROLL_WIDTH + 10, ROLL_CLOSED_HEIGHT + 8)
shadowBlob.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadowBlob.BackgroundTransparency = 0.7
shadowBlob.BorderSizePixel = 0
shadowBlob.ZIndex = 47
shadowBlob.Parent = screenGui
local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(1, 0)
shadowCorner.Parent = shadowBlob

------------------------------------------------
-- SALLANAN ESKİ İP
------------------------------------------------
local hangerString = Instance.new("Frame")
hangerString.AnchorPoint = Vector2.new(0.5, 0)
hangerString.Position = UDim2.new(HORIZONTAL_OFFSET, 0, 0, 0)
hangerString.Size = UDim2.fromOffset(3, 12)
hangerString.BackgroundColor3 = Color3.fromRGB(75, 52, 24)
hangerString.BorderSizePixel = 0
hangerString.ZIndex = 49
hangerString.Parent = screenGui

local stringGradient = Instance.new("UIGradient")
stringGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 30, 12)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(95, 66, 28)),
})
stringGradient.Rotation = 90
stringGradient.Parent = hangerString

task.spawn(function()
	while hangerString.Parent do
		TweenService:Create(hangerString, TweenInfo.new(2.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Rotation = 2.5
		}):Play()
		task.wait(2.2)
		TweenService:Create(hangerString, TweenInfo.new(2.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Rotation = -2.5
		}):Play()
		task.wait(2.2)
	end
end)

------------------------------------------------
-- ANA RULO GÖVDESİ
------------------------------------------------
local rollHolder = Instance.new("Frame")
rollHolder.AnchorPoint = Vector2.new(0.5, 0)
rollHolder.Position = UDim2.new(HORIZONTAL_OFFSET, 0, 0, 10)
rollHolder.Size = UDim2.fromOffset(ROLL_WIDTH, ROLL_CLOSED_HEIGHT)
rollHolder.BackgroundColor3 = Color3.fromRGB(150, 32, 28)
rollHolder.BorderSizePixel = 0
rollHolder.ClipsDescendants = false
rollHolder.ZIndex = 50
rollHolder.Parent = screenGui

local rollCorner = Instance.new("UICorner")
rollCorner.CornerRadius = UDim.new(1, 0)
rollCorner.Parent = rollHolder

local rollGradient = Instance.new("UIGradient")
rollGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 12, 10)),
	ColorSequenceKeypoint.new(0.25, Color3.fromRGB(180, 55, 48)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(130, 22, 20)),
	ColorSequenceKeypoint.new(0.75, Color3.fromRGB(180, 55, 48)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 12, 10)),
})
rollGradient.Rotation = 90
rollGradient.Parent = rollHolder

local rollStroke = Instance.new("UIStroke")
rollStroke.Thickness = 2
rollStroke.Color = Color3.fromRGB(200, 170, 100)
rollStroke.Transparency = 0.3
rollStroke.Parent = rollHolder

for i = 1, 3 do
	local line = Instance.new("Frame")
	line.AnchorPoint = Vector2.new(0.5, 0.5)
	line.Position = UDim2.new(0.5, 0, (i - 2) * 0.28, 0)
	line.Size = UDim2.new(1, -14, 0, 1)
	line.BackgroundColor3 = Color3.fromRGB(200, 170, 100)
	line.BackgroundTransparency = 0.6
	line.BorderSizePixel = 0
	line.ZIndex = 51
	line.Parent = rollHolder
end

local function makeCap(xAnchor)
	local cap = Instance.new("Frame")
	cap.AnchorPoint = Vector2.new(xAnchor, 0.5)
	cap.Position = UDim2.new(xAnchor, xAnchor == 0 and -4 or 4, 0.5, 0)
	cap.Size = UDim2.fromOffset(12, ROLL_CLOSED_HEIGHT + 8)
	cap.BackgroundColor3 = Color3.fromRGB(72, 48, 22)
	cap.BorderSizePixel = 0
	cap.ZIndex = 52
	cap.Parent = rollHolder

	local capCorner = Instance.new("UICorner")
	capCorner.CornerRadius = UDim.new(1, 0)
	capCorner.Parent = cap

	local capGradient = Instance.new("UIGradient")
	capGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(42, 26, 10)),
		ColorSequenceKeypoint.new(0.45, Color3.fromRGB(110, 76, 38)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(42, 26, 10)),
	})
	capGradient.Rotation = 90
	capGradient.Parent = cap

	local capStroke = Instance.new("UIStroke")
	capStroke.Thickness = 1.5
	capStroke.Color = Color3.fromRGB(200, 170, 100)
	capStroke.Transparency = 0.35
	capStroke.Parent = cap

	local crack = Instance.new("Frame")
	crack.AnchorPoint = Vector2.new(0.5, 0.5)
	crack.Position = UDim2.new(0.5, 0, 0.5, 0)
	crack.Size = UDim2.new(0, 1, 0.6, 0)
	crack.Rotation = xAnchor == 0 and 15 or -15
	crack.BackgroundColor3 = Color3.fromRGB(20, 12, 5)
	crack.BackgroundTransparency = 0.4
	crack.BorderSizePixel = 0
	crack.ZIndex = 53
	crack.Parent = cap
end
makeCap(0)
makeCap(1)

------------------------------------------------
-- SOLMUŞ MÜHÜR
------------------------------------------------
local sealHolder = Instance.new("Frame")
sealHolder.AnchorPoint = Vector2.new(0.5, 0.5)
sealHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
sealHolder.Size = UDim2.new(1, -22, 1, -6)
sealHolder.BackgroundTransparency = 1
sealHolder.ZIndex = 54
sealHolder.Parent = rollHolder

local sealIcon = Instance.new("TextLabel")
sealIcon.Size = UDim2.new(1, 0, 1, 0)
sealIcon.BackgroundTransparency = 1
sealIcon.Text = "ハムスター"
sealIcon.TextColor3 = Color3.fromRGB(210, 180, 110)
sealIcon.Font = Enum.Font.GothamBlack
sealIcon.TextSize = 13
sealIcon.TextScaled = true
sealIcon.ZIndex = 54
sealIcon.Parent = sealHolder

local sealConstraint = Instance.new("UITextSizeConstraint")
sealConstraint.MaxTextSize = 13
sealConstraint.Parent = sealIcon

task.spawn(function()
	while sealIcon.Parent do
		TweenService:Create(sealIcon, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			TextColor3 = Color3.fromRGB(225, 200, 140)
		}):Play()
		task.wait(1.2)
		if not sealIcon.Parent then break end
		TweenService:Create(sealIcon, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			TextColor3 = Color3.fromRGB(180, 150, 90)
		}):Play()
		task.wait(1.2)
	end
end)

------------------------------------------------
-- TOZ/KIRINTI PARÇACIKLARI
------------------------------------------------
task.spawn(function()
	while rollHolder.Parent do
		task.wait(math.random(5, 10) / 10)
		if not rollHolder.Parent then break end

		local dust = Instance.new("Frame")
		dust.AnchorPoint = Vector2.new(0.5, 0.5)
		dust.Position = UDim2.new(math.random(15, 85) / 100, 0, 1, 0)
		dust.Size = UDim2.fromOffset(2, 2)
		dust.BackgroundColor3 = Color3.fromRGB(200, 180, 140)
		dust.BackgroundTransparency = 0.3
		dust.BorderSizePixel = 0
		dust.ZIndex = 46
		dust.Parent = rollHolder

		local dustCorner = Instance.new("UICorner")
		dustCorner.CornerRadius = UDim.new(1, 0)
		dustCorner.Parent = dust

		local dur = 1 + math.random() * 0.6
		TweenService:Create(dust, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = dust.Position + UDim2.fromOffset(math.random(-8, 8), math.random(15, 30)),
			BackgroundTransparency = 1
		}):Play()
		task.delay(dur, function() if dust.Parent then dust:Destroy() end end)
	end
end)

------------------------------------------------
-- HOVER BÜYÜMESİ
------------------------------------------------
local clickTrigger = Instance.new("TextButton")
clickTrigger.Size = UDim2.new(1, 0, 1, 0)
clickTrigger.BackgroundTransparency = 1
clickTrigger.Text = ""
clickTrigger.ZIndex = 55
clickTrigger.Parent = rollHolder

clickTrigger.MouseEnter:Connect(function()
	TweenService:Create(rollHolder, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(ROLL_WIDTH + 6, ROLL_CLOSED_HEIGHT + 3)
	}):Play()
end)
clickTrigger.MouseLeave:Connect(function()
	TweenService:Create(rollHolder, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(ROLL_WIDTH, ROLL_CLOSED_HEIGHT)
	}):Play()
end)

------------------------------------------------
-- KAĞIT PANELİ
------------------------------------------------
local paperPanel = Instance.new("Frame")
paperPanel.AnchorPoint = Vector2.new(0.5, 0)
paperPanel.Position = UDim2.new(HORIZONTAL_OFFSET, 0, 0, 10 + ROLL_CLOSED_HEIGHT)
paperPanel.Size = UDim2.fromOffset(ROLL_WIDTH, 0)
paperPanel.BackgroundColor3 = Color3.fromRGB(214, 194, 150)
paperPanel.BorderSizePixel = 0
paperPanel.ClipsDescendants = false
paperPanel.ZIndex = 48
paperPanel.Parent = screenGui

local paperGradient = Instance.new("UIGradient")
paperGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(222, 202, 158)),
	ColorSequenceKeypoint.new(0.35, Color3.fromRGB(200, 178, 130)),
	ColorSequenceKeypoint.new(0.65, Color3.fromRGB(212, 190, 145)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 158, 112)),
})
paperGradient.Rotation = 80
paperGradient.Parent = paperPanel

local paperStroke = Instance.new("UIStroke")
paperStroke.Thickness = 1.5
paperStroke.Color = Color3.fromRGB(90, 60, 30)
paperStroke.Transparency = 0.35
paperStroke.Parent = paperPanel

local clipLayer = Instance.new("Frame")
clipLayer.Size = UDim2.new(1, 0, 1, 0)
clipLayer.BackgroundTransparency = 1
clipLayer.ClipsDescendants = true
clipLayer.ZIndex = 48
clipLayer.Parent = paperPanel

------------------------------------------------
-- YIRTIK KENAR EFEKTİ
------------------------------------------------
local function createTornEdge(yAnchor, isTop)
	local edgeHolder = Instance.new("Frame")
	edgeHolder.Size = UDim2.new(1, 0, 0, 10)
	edgeHolder.Position = isTop and UDim2.new(0, 0, 0, -4) or UDim2.new(0, 0, 1, -6)
	edgeHolder.BackgroundTransparency = 1
	edgeHolder.ZIndex = 47
	edgeHolder.Parent = paperPanel

	local teethCount = 9
	for i = 0, teethCount - 1 do
		local tooth = Instance.new("Frame")
		local w = 1 / teethCount
		local jag = math.random(3, 9)
		tooth.Position = UDim2.new(i * w, 0, isTop and 1 or 0, isTop and -jag or 0)
		tooth.Size = UDim2.new(w + 0.01, 1, 0, jag)
		tooth.Rotation = math.random(-6, 6)
		tooth.BackgroundColor3 = Color3.fromRGB(214, 194, 150)
		tooth.BorderSizePixel = 0
		tooth.ZIndex = 47
		tooth.Parent = edgeHolder

		local edgeShade = Instance.new("Frame")
		edgeShade.Size = UDim2.new(1, 0, 0, 1.5)
		edgeShade.Position = isTop and UDim2.new(0, 0, 1, -1.5) or UDim2.new(0, 0, 0, 0)
		edgeShade.BackgroundColor3 = Color3.fromRGB(110, 85, 50)
		edgeShade.BackgroundTransparency = 0.3
		edgeShade.BorderSizePixel = 0
		edgeShade.ZIndex = 47
		edgeShade.Parent = tooth
	end

	return edgeHolder
end

local topTorn = createTornEdge(0, true)
local bottomTorn = createTornEdge(1, false)

for i = 1, 6 do
	local fiber = Instance.new("Frame")
	fiber.AnchorPoint = Vector2.new(0.5, 0)
	fiber.Position = UDim2.new(math.random(5, 95) / 100, 0, 0, -math.random(1, 5))
	fiber.Size = UDim2.fromOffset(1, math.random(2, 5))
	fiber.Rotation = math.random(-25, 25)
	fiber.BackgroundColor3 = Color3.fromRGB(180, 160, 115)
	fiber.BackgroundTransparency = 0.3
	fiber.BorderSizePixel = 0
	fiber.ZIndex = 47
	fiber.Parent = topTorn
end

------------------------------------------------
-- SU LEKELERİ
------------------------------------------------
for i = 1, 6 do
	local stain = Instance.new("Frame")
	stain.AnchorPoint = Vector2.new(0.5, 0.5)
	stain.Position = UDim2.new(math.random(8, 92) / 100, 0, math.random(8, 92) / 100, 0)
	stain.Size = UDim2.fromOffset(math.random(14, 34), math.random(14, 34))
	stain.BackgroundColor3 = Color3.fromRGB(120, 90, 50)
	stain.BackgroundTransparency = 0.87
	stain.BorderSizePixel = 0
	stain.ZIndex = 49
	stain.Parent = clipLayer
	local stainCorner = Instance.new("UICorner")
	stainCorner.CornerRadius = UDim.new(1, 0)
	stainCorner.Parent = stain

	local stainRing = Instance.new("UIStroke")
	stainRing.Thickness = 1
	stainRing.Color = Color3.fromRGB(100, 72, 38)
	stainRing.Transparency = 0.75
	stainRing.Parent = stain
end

for i = 1, 5 do
	local scratch = Instance.new("Frame")
	scratch.AnchorPoint = Vector2.new(0.5, 0.5)
	scratch.Position = UDim2.new(math.random(10, 90) / 100, 0, math.random(10, 90) / 100, 0)
	scratch.Size = UDim2.fromOffset(math.random(12, 28), 1)
	scratch.Rotation = math.random(-40, 40)
	scratch.BackgroundColor3 = Color3.fromRGB(90, 65, 35)
	scratch.BackgroundTransparency = 0.75
	scratch.BorderSizePixel = 0
	scratch.ZIndex = 49
	scratch.Parent = clipLayer
end

local foldLine = Instance.new("Frame")
foldLine.Position = UDim2.new(0, 0, 0.5, 0)
foldLine.Size = UDim2.new(1, 0, 0, 2)
foldLine.BackgroundColor3 = Color3.fromRGB(140, 112, 70)
foldLine.BackgroundTransparency = 0.7
foldLine.BorderSizePixel = 0
foldLine.ZIndex = 49
foldLine.Parent = clipLayer

local foldShadow = Instance.new("UIGradient")
foldShadow.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 40, 15)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(160, 130, 80)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 40, 15)),
})
foldShadow.Parent = foldLine

local edgeVignette = Instance.new("Frame")
edgeVignette.Size = UDim2.new(1, 0, 1, 0)
edgeVignette.BackgroundTransparency = 1
edgeVignette.ZIndex = 49
edgeVignette.Parent = clipLayer
local vignetteStroke = Instance.new("UIStroke")
vignetteStroke.Thickness = 6
vignetteStroke.Color = Color3.fromRGB(70, 48, 22)
vignetteStroke.Transparency = 0.75
vignetteStroke.Parent = edgeVignette

------------------------------------------------
-- İÇERİK ALANI
------------------------------------------------
local contentHolder = Instance.new("Frame")
contentHolder.Size = UDim2.new(1, -18, 1, -18)
contentHolder.Position = UDim2.new(0, 9, 0, 9)
contentHolder.BackgroundTransparency = 1
contentHolder.ZIndex = 50
contentHolder.Parent = clipLayer

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 16)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "ハムスター • MOD SEÇ"
titleLabel.TextColor3 = Color3.fromRGB(95, 30, 20)
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 12
titleLabel.ZIndex = 50
titleLabel.Parent = contentHolder

local titleUnderline = Instance.new("Frame")
titleUnderline.Position = UDim2.new(0, 0, 0, 18)
titleUnderline.Size = UDim2.new(1, 0, 0, 1)
titleUnderline.BackgroundColor3 = Color3.fromRGB(95, 30, 20)
titleUnderline.BackgroundTransparency = 0.5
titleUnderline.BorderSizePixel = 0
titleUnderline.ZIndex = 50
titleUnderline.Parent = contentHolder

------------------------------------------------
-- BUTON STİLİ
------------------------------------------------
local function styleButton(btn)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 5)
	corner.Parent = btn

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(165, 45, 38)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(110, 25, 20)),
	})
	gradient.Rotation = 90
	gradient.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1.5
	stroke.Color = Color3.fromRGB(200, 170, 100)
	stroke.Transparency = 0.3
	stroke.Parent = btn

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(190, 60, 50)
		}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.15), {
			Transparency = 0.1
		}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(150, 32, 28)
		}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.15), {
			Transparency = 0.3
		}):Play()
	end)
end

------------------------------------------------
-- BUTONLAR
------------------------------------------------
local button1 = Instance.new("TextButton")
button1.Name = "ModButton1"
button1.Size = UDim2.new(1, 0, 0, 42)
button1.Position = UDim2.new(0, 0, 0, 34)
button1.BackgroundColor3 = Color3.fromRGB(150, 32, 28)
button1.Text = "MOD 1"
button1.TextColor3 = Color3.fromRGB(240, 220, 185)
button1.Font = Enum.Font.GothamBold
button1.TextSize = 13
button1.ZIndex = 50
button1.Parent = contentHolder
styleButton(button1)

local button2 = Instance.new("TextButton")
button2.Name = "ModButton2"
button2.Size = UDim2.new(1, 0, 0, 42)
button2.Position = UDim2.new(0, 0, 0, 84)
button2.BackgroundColor3 = Color3.fromRGB(150, 32, 28)
button2.Text = "MOD 2"
button2.TextColor3 = Color3.fromRGB(240, 220, 185)
button2.Font = Enum.Font.GothamBold
button2.TextSize = 13
button2.ZIndex = 50
button2.Parent = contentHolder
styleButton(button2)

------------------------------------------------
-- AÇMA / KAPAMA
------------------------------------------------
local function openScroll()
	isOpen = true
	playSound(SOUNDS.paperUnroll, 0.6, 0.9)
	playSound(SOUNDS.paperCrinkle, 0.35, 1.1)
	playSound(SOUNDS.woodClack, 0.4, 1.2)

	TweenService:Create(paperPanel, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(ROLL_WIDTH, SCROLL_OPEN_HEIGHT)
	}):Play()

	TweenService:Create(rollHolder, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Rotation = 4
	}):Play()
	task.delay(0.15, function()
		if rollHolder.Parent then
			TweenService:Create(rollHolder, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
				Rotation = 0
			}):Play()
		end
	end)
end

local function closeScroll()
	isOpen = false
	playSound(SOUNDS.paperCrinkle, 0.3, 0.85)
	playSound(SOUNDS.woodClack, 0.35, 0.9)

	TweenService:Create(paperPanel, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = UDim2.fromOffset(ROLL_WIDTH, 0)
	}):Play()

	TweenService:Create(rollHolder, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Rotation = -3
	}):Play()
	task.delay(0.12, function()
		if rollHolder.Parent then
			TweenService:Create(rollHolder, TweenInfo.new(0.18, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
				Rotation = 0
			}):Play()
		end
	end)
end

clickTrigger.MouseButton1Click:Connect(function()
	if isOpen then
		closeScroll()
	else
		openScroll()
	end
end)-- ============================================================
-- HAMSTER LIVES - ULTRA EGG CARRY V4 (PART 2/2)
-- MOD1/MOD2 KODLARI + E TUŞU + EGG REMOTE BULUCU
-- ============================================================

-- ============================================================
-- TÜM EGG REMOTE'LARINI BUL
-- ============================================================
local AllEggRemotes = {}

local function FindAllEggRemotes()
    local keywords = {"egg","carry","collect","pickup","grab","field","hatch","place","drop","shift","batch","redeem","wear","tool","doff","record","snapshot","growth","finish","live","carry"}
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            for _, kw in ipairs(keywords) do
                if name:find(kw) then
                    table.insert(AllEggRemotes, obj)
                    break
                end
            end
        end
    end
    print("🥚 " .. #AllEggRemotes .. " egg remote bulundu!")
end

-- ============================================================
-- COOLDOWN BYPASS
-- ============================================================
local function BypassCooldowns()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("IntValue") or obj:IsA("NumberValue") then
            local name = obj.Name:lower()
            if name:find("cooldown") or name:find("cd") or name:find("time") or name:find("delay") then
                pcall(function() obj.Value = 0 end)
            end
        end
    end
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("IntValue") or obj:IsA("NumberValue") then
            local name = obj.Name:lower()
            if name:find("cooldown") or name:find("cd") or name:find("time") or name:find("delay") then
                pcall(function() obj.Value = 0 end)
            end
        end
    end
end

-- ============================================================
-- ULTRA EGG CARRY
-- ============================================================
local function UltraEggCarry()
    -- 1. Tüm remote'ları fırlat
    for _, remote in ipairs(AllEggRemotes) do
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer()
            elseif remote:IsA("RemoteFunction") then
                remote:InvokeServer()
            end
        end)
    end
    
    -- 2. ProximityPrompt'ları tetikle
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local name = obj.Name:lower()
            if name:find("egg") or name:find("carry") or name:find("collect") or name:find("pickup") then
                pcall(function() obj:Prompt() end)
            end
        end
    end
    
    -- 3. Cooldown'ları sıfırla
    BypassCooldowns()
    
    -- 4. Touch simülasyonu
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local name = obj.Name:lower()
                    if name:find("egg") or name:find("carry") or name:find("collect") or name:find("pickup") or name:find("spot") then
                        local oldPos = hrp.Position
                        hrp.CFrame = CFrame.new(obj.Position + Vector3.new(0, 2, 0))
                        task.wait(0.1)
                        hrp.CFrame = CFrame.new(oldPos)
                        break
                    end
                end
            end
        end
    end
end

-- ============================================================
-- DÜŞME KORUMA
-- ============================================================
local Mod2Active = false
local Mod2Connections = {}

local function StartFallProtection()
    if Mod2Active then return end
    Mod2Active = true
    
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    
    -- Vurulma koruması
    local conn1 = hum.HealthChanged:Connect(function(health)
        local old = hum.Health
        if health < old then
            UltraEggCarry()
        end
    end)
    table.insert(Mod2Connections, conn1)
    
    -- Düşme koruması
    local conn2 = hum.StateChanged:Connect(function(oldState, newState)
        if newState == Enum.HumanoidStateType.FallingDown then
            task.wait(0.05)
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            task.wait(0.1)
            UltraEggCarry()
        end
    end)
    table.insert(Mod2Connections, conn2)
end

local function StopFallProtection()
    Mod2Active = false
    for _, conn in ipairs(Mod2Connections) do
        pcall(function() conn:Disconnect() end)
    end
    Mod2Connections = {}
end

-- ============================================================
-- MOD1 (ANINDA EGG ALMA)
-- ============================================================
local Mod1Active = false

-- ============================================================
-- MENÜ BUTONLARINI BAĞLA
-- ============================================================
local function ConnectButtons()
    local scrollMenu = LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("ScrollMenu")
    if not scrollMenu then return end
    
    local btn1 = scrollMenu:FindFirstChild("ModButton1")
    if btn1 then
        btn1.MouseButton1Click:Connect(function()
            Mod1Active = not Mod1Active
            if Mod1Active then
                btn1.Text = "✅ MOD1"
                btn1.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                UltraEggCarry()
            else
                btn1.Text = "MOD 1"
                btn1.BackgroundColor3 = Color3.fromRGB(150, 32, 28)
            end
        end)
    end
    
    local btn2 = scrollMenu:FindFirstChild("ModButton2")
    if btn2 then
        btn2.MouseButton1Click:Connect(function()
            if Mod2Active then
                StopFallProtection()
                btn2.Text = "MOD 2"
                btn2.BackgroundColor3 = Color3.fromRGB(150, 32, 28)
            else
                StartFallProtection()
                btn2.Text = "✅ MOD2"
                btn2.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            end
        end)
    end
end

-- ============================================================
-- E TUŞU (MOD1 AKTİF İSE)
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E then
        if Mod1Active then
            UltraEggCarry()
        end
    end
end)

-- ============================================================
-- BAŞLAT
-- ============================================================
task.wait(1)
FindAllEggRemotes()
ConnectButtons()

local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
if playerGui then
    playerGui.ChildAdded:Connect(function(child)
        if child.Name == "ScrollMenu" then
            task.wait(0.5)
            ConnectButtons()
        end
    end)
end

print("")
print("========================================")
print("🐹 ULTRA EGG CARRY V4 HAZIR!")
print("   🟢 MOD1: Anında egg alma (E tuşu)")
print("   🛡️ MOD2: Düşme koruma")
print("   ⚡ " .. #AllEggRemotes .. " egg remote bulundu")
print("========================================")
