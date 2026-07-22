-- ============================================================
-- LEA PET FINDER – AGGRESSIVE SERVER HOPPER (EN HIZLI)
-- ============================================================
-- Amaç: Her sunucuya gir, anlık tarama yap, iyi pet varsa kal,
-- yoksa 2 saniye içinde atla. Telefonu yormaz, bypass ve anti-kick mevcut.
-- ============================================================

-- KONFIGÜRASYON
local CONFIG = {
    PetValueThreshold = 50000000,      -- 50M eşik
    HopInterval = 2,                   -- her 2 saniyede bir atla (mümkün olan en hızlı)
    MaxPlayers = 12,                   -- kalabalık sunuculardan kaçın
    MinPlayers = 2,                    -- en az bu kadar oyuncu olsun
    Debug = true,
}

-- ============================================================
-- SERVİSLER
-- ============================================================
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

print("⚡ LEA Pet Finder – Aggressive Mode started.")

-- ============================================================
-- GÜVENLİK (Bypass + Anti-Kick)
-- ============================================================
local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if method == "Kick" or method == "kick" then
        if self == LocalPlayer or self:IsA("Player") then return nil end
    end
    if self == LocalPlayer and (method == "Destroy" or method == "Remove") then
        return nil
    end
    return oldNamecall(self, ...)
end)

-- Anti-Reset (ölümü engelle)
local function AntiReset(char)
    pcall(function()
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.BreakJointsOnDeath = false
            hum.HealthChanged:Connect(function(hp)
                if hp <= 0 then hum.Health = hum.MaxHealth end
            end)
        end
    end)
end
LocalPlayer.CharacterAdded:Connect(AntiReset)
if LocalPlayer.Character then AntiReset(LocalPlayer.Character) end

-- ============================================================
-- PET TESPİTİ (HIZLI TARAMA)
-- ============================================================
local function ScanCurrentServer()
    local found = false
    local bestValue = 0
    local bestPet = nil
    local playerCount = 0
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            playerCount = playerCount + 1
            local char = plr.Character
            if char then
                for _, child in ipairs(char:GetChildren()) do
                    -- Pet olabilecek nesneleri tara (Tool, Model, Part)
                    if child:IsA("Tool") or child:IsA("Model") or child:IsA("Part") then
                        -- İsimde "pet", "egg", "dragon" vb. ara
                        local name = child.Name:lower()
                        if name:find("pet") or name:find("egg") or name:find("dragon") or name:find("mythic") or name:find("legend") then
                            -- Değer tahmini (isimden veya içindeki NumberValue'dan)
                            local val = 0
                            -- Önce isimden tahmin
                            if name:find("mythic") or name:find("legend") then val = 80000000 end
                            if name:find("ultra") then val = 60000000 end
                            if name:find("cosmic") then val = 70000000 end
                            -- Sonra içindeki NumberValue'leri kontrol et
                            if val == 0 then
                                for _, sub in ipairs(child:GetDescendants()) do
                                    if sub:IsA("NumberValue") or sub:IsA("IntValue") then
                                        local v = tonumber(sub.Value)
                                        if v and v > 1000000 then
                                            val = v
                                            break
                                        end
                                    end
                                end
                            end
                            if val > bestValue then
                                bestValue = val
                                bestPet = child.Name
                                found = true
                            end
                        end
                    end
                end
            end
        end
    end
    
    return {
        found = found,
        bestValue = bestValue,
        bestPet = bestPet,
        playerCount = playerCount,
    }
end

-- ============================================================
-- ANA DÖNGÜ (HIZLI ATLAMA)
-- ============================================================
local hopCount = 0
local lastHopTime = 0
local isRunning = false
local badServers = {}

function StartFinder()
    if isRunning then return end
    isRunning = true
    print("🔄 Pet Finder aktif – sunucular taranıyor...")
    
    task.spawn(function()
        while isRunning do
            -- 1. Mevcut sunucuyu tara
            local result = ScanCurrentServer()
            if CONFIG.Debug then
                print(string.format("[Scan] Oyuncu: %d, En iyi pet: %s (Değer: %d)",
                    result.playerCount,
                    result.bestPet or "Yok",
                    result.bestValue))
            end
            
            -- 2. Karar ver: iyi pet var mı? ve sunucu kalabalık değil mi?
            local isGood = false
            if result.bestValue >= CONFIG.PetValueThreshold then
                isGood = true
                print(string.format("✅ İYİ PET BULUNDU! %s (%d) – Sunucuda kalınıyor.", 
                    result.bestPet, result.bestValue))
                -- UI bildirimi yapabilirsin
                break
            end
            
            -- Eğer oyuncu sayısı çok az veya çok fazlaysa da atla
            if result.playerCount < CONFIG.MinPlayers or result.playerCount > CONFIG.MaxPlayers then
                if CONFIG.Debug then print("⏭ Oyuncu sayısı uygun değil, atlanıyor...") end
                -- atla
            end
            
            -- 3. İyi değilse, yeni sunucuya atla
            local currentJobId = game.JobId
            if not badServers[currentJobId] then
                badServers[currentJobId] = os.time()
            end
            
            -- Hop yap (cooldown kontrolü)
            local now = tick()
            if now - lastHopTime >= CONFIG.HopInterval then
                hopCount = hopCount + 1
                print("🔄 Sunucu atlanıyor #" .. hopCount .. "...")
                lastHopTime = now
                
                -- Teleport et
                local success = pcall(function()
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                end)
                if success then
                    -- Yeni sunucu yüklenene kadar bekle (minimum)
                    task.wait(1.5)
                else
                    warn("Teleport başarısız, tekrar deneniyor...")
                    task.wait(2)
                end
            else
                -- Bekleme süresi dolmadıysa kısa bekle
                task.wait(0.5)
            end
        end
    end)
end

function StopFinder()
    isRunning = false
    print("⏹ Pet Finder durduruldu.")
end

-- ============================================================
-- KONTROL PANELİ (BUTONLAR – SAĞ ÜST)
-- ============================================================
local function CreateUI()
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    local old = pg:FindFirstChild("PetFinderUI")
    if old then old:Destroy() end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "PetFinderUI"
    gui.Parent = pg
    
    local cont = Instance.new("Frame")
    cont.Size = UDim2.new(0, 70, 0, 200)
    cont.Position = UDim2.new(1, -75, 0.01, 0)
    cont.BackgroundTransparency = 1
    cont.Parent = gui
    
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 3)
    list.Parent = cont
    
    local function Button(text, toggle, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 66, 0, 28)
        b.BackgroundColor3 = Color3.fromRGB(30,30,40)
        b.Text = text
        b.TextColor3 = Color3.new(1,1,1)
        b.TextSize = 10
        b.Font = Enum.Font.GothamBold
        b.Parent = cont
        if toggle then
            local state = false
            b.MouseButton1Click:Connect(function()
                state = not state
                b.BackgroundColor3 = state and Color3.fromRGB(0,150,80) or Color3.fromRGB(30,30,40)
                callback(state)
            end)
        else
            b.MouseButton1Click:Connect(function()
                callback()
            end)
        end
    end
    
    Button("FIND", true, function(state)
        if state then StartFinder() else StopFinder() end
    end)
    
    Button("STOP", false, function()
        StopFinder()
        -- UI'da durum gösterimi yapabilirsin
    end)
end

CreateUI()

print("✅ Pet Finder başlatıldı. 'FIND' butonuna basarak aktifleştirin.")
print("⚠️ NOT: Saniyede 50 sunucu mümkün değil. En hızlı hali ~2 saniyede bir atlar.")
print("💡 Oyunun veri yapısını biliyorsanız, ScanCurrentServer() içindeki pet tespitini özelleştirin.")
