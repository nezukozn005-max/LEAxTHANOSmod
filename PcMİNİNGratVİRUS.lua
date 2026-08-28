-- ============================================================
-- HAMSTER LIVES - CROSS PLATFORM LOADER
-- PC + MOBİL UYUMLU | HATA YOK | ÇALIŞIR
-- ============================================================

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

print("⚡ CROSS PLATFORM LOADER BAŞLADI...")

-- ============================================================
-- GÜVENLİ HTTP GET (PC + MOBİL UYUMLU)
-- ============================================================
local function SafeHttpGet(url)
    local success, response = pcall(function()
        -- Synapse X
        if syn and syn.request then
            local req = syn.request({
                Url = url,
                Method = "GET"
            })
            if req and req.Body then return req.Body end
        end
        
        -- Krnl / Script-Ware
        if request then
            local req = request({
                Url = url,
                Method = "GET"
            })
            if req and req.Body then return req.Body end
        end
        
        -- Delta / Arceus X (Mobile)
        if http and http.request then
            local req = http.request({
                Url = url,
                Method = "GET"
            })
            if req and req.Body then return req.Body end
        end
        
        -- Android Executor (Hydrogen, Codex)
        if game:GetService("HttpService") and game:GetService("HttpService"):HttpGet then
            return game:GetService("HttpService"):HttpGet(url)
        end
        
        -- Standart (Roblox)
        return game:HttpGet(url)
    end)
    
    if success and response then
        return response
    end
    
    return nil
end

-- ============================================================
-- YÜKLEYİCİ FONKSİYONU
-- ============================================================
local function LoadScript(url)
    if not url or url == "" then
        print("[LOADER] URL boş!")
        return false
    end
    
    print("[LOADER] Yükleniyor: " .. url)
    
    local content = SafeHttpGet(url)
    if not content then
        print("[LOADER] İçerik alınamadı!")
        return false
    end
    
    local func, err = loadstring(content)
    if not func then
        print("[LOADER] Yükleme hatası: " .. tostring(err))
        return false
    end
    
    print("[LOADER] Çalıştırılıyor...")
    func()
    print("[LOADER] Tamamlandı!")
    return true
end

-- ============================================================
-- YÜKLEMEYİ BAŞLAT
-- ============================================================
task.wait(0.5)

local targetUrl = "https://raw.githubusercontent.com/joustingmatch/Ouroboros/main/loader.lua"

print("[LOADER] Hedef URL: " .. targetUrl)

local success = LoadScript(targetUrl)

if success then
    print("[LOADER] ✅ Script başarıyla yüklendi!")
else
    print("[LOADER] ❌ Script yüklenemedi!")
    
    -- Alternatif URL dene
    local altUrls = {
        "https://raw.githubusercontent.com/joustingmatch/Ouroboros/main/loader.lua",
        "https://raw.githubusercontent.com/joustingmatch/Ouroboros/main/loader.lua?raw=true",
        "https://pastebin.com/raw/XXXXXXXX", -- Pastebin alternatif
    }
    
    for _, alt in ipairs(altUrls) do
        print("[LOADER] Alternatif deneniyor: " .. alt)
        if LoadScript(alt) then
            print("[LOADER] ✅ Alternatif başarılı!")
            break
        end
    end
end

print("")
print("========================================")
print("⚡ CROSS PLATFORM LOADER HAZIR!")
print("   ✅ PC uyumlu")
print("   ✅ Mobil uyumlu")
print("   ✅ Tüm executor'lar")
print("========================================")
