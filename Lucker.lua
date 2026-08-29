-- ============================================================
-- HAMSTER LIVES - ULTIMATE LUCK MANIPULATOR V3
-- TEK SEFER | ANINDA | TÜM LUCK MAKSİMUM | BLOOM %100
-- ============================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

print("[LUCK V3] BAŞLATILDI...")

-- ============================================================
-- ARANACAK KELİMELER
-- ============================================================
local SEARCH_PATTERNS = {
    "luck", "chance", "rarity", "odds", "divine", "eternal",
    "secret", "boost", "drop", "roll", "bloom", "sprit",
    "machine", "spawn", "rate", "percent", "probability",
    "lucky", "fortune", "destiny", "fate", "rare"
}

-- ============================================================
-- TÜM LUCK DEĞERLERİNİ MAKSİMUM YAP (TEK SEFER)
-- ============================================================
local function MaxAllLuck()
    local total = 0
    local containers = {
        Workspace,
        ReplicatedStorage,
        game:GetService("Lighting"),
        LocalPlayer:FindFirstChild("PlayerScripts"),
        LocalPlayer:FindFirstChild("PlayerGui")
    }
    
    for _, container in ipairs(containers) do
        if container then
            for _, obj in ipairs(container:GetDescendants()) do
                -- NumberValue/IntValue
                if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                    local name = obj.Name:lower()
                    for _, p in ipairs(SEARCH_PATTERNS) do
                        if name:find(p) then
                            pcall(function()
                                obj.Value = 999999
                                total = total + 1
                            end)
                            break
                        end
                    end
                end
                
                -- Attributes
                pcall(function()
                    local attrs = obj:GetAttributes()
                    for attrName, attrValue in pairs(attrs) do
                        local lowerName = attrName:lower()
                        for _, p in ipairs(SEARCH_PATTERNS) do
                            if lowerName:find(p) then
                                if type(attrValue) == "number" then
                                    obj:SetAttribute(attrName, 999999)
                                    total = total + 1
                                end
                                break
                            end
                        end
                    end
                end)
            end
        end
    end
    
    return total
end

-- ============================================================
-- BLOOM/SPRIT MAKİNELERİ ÖZEL (YÜZDE DEĞERLERİ %100 YAP)
-- ============================================================
local function MaxBloomMachines()
    local total = 0
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local name = obj.Name:lower()
        if name:find("bloom") or name:find("sprit") or name:find("machine") or name:find("spawn") then
            for _, child in ipairs(obj:GetDescendants()) do
                if child:IsA("NumberValue") or child:IsA("IntValue") then
                    pcall(function()
                        if child.Value > 0 and child.Value <= 100 then
                            child.Value = 100
                            total = total + 1
                        elseif child.Value > 100 then
                            child.Value = 999999
                            total = total + 1
                        end
                    end)
                end
                
                pcall(function()
                    local attrs = child:GetAttributes()
                    for attrName, attrValue in pairs(attrs) do
                        if type(attrValue) == "number" and attrValue > 0 and attrValue <= 100 then
                            child:SetAttribute(attrName, 100)
                            total = total + 1
                        elseif type(attrValue) == "number" and attrValue > 100 then
                            child:SetAttribute(attrName, 999999)
                            total = total + 1
                        end
                    end
                end)
            end
        end
    end
    
    return total
end

-- ============================================================
-- REDDEDEN REMOTE'LARI ENGELLE
-- ============================================================
local function BlockRejectRemotes()
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            if name:find("reject") or name:find("deny") or name:find("block") or name:find("check") or name:find("verify") then
                pcall(function()
                    if obj:IsA("RemoteEvent") then
                        local old = obj.FireServer
                        obj.FireServer = function(self, ...)
                            return
                        end
                    end
                end)
            end
        end
    end
end

-- ============================================================
-- KORUMA KALKANI (SUNUCU PATLATMA SİMÜLASYONU)
-- ============================================================
local function BreakShield()
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("BoolValue") then
            local name = obj.Name:lower()
            if name:find("shield") or name:find("protect") or name:find("guard") or name:find("secure") then
                pcall(function()
                    obj.Value = false
                end)
            end
        end
        if obj:IsA("NumberValue") or obj:IsA("IntValue") then
            local name = obj.Name:lower()
            if name:find("shield") or name:find("protect") or name:find("guard") or name:find("secure") then
                pcall(function()
                    obj.Value = 0
                end)
            end
        end
    end
end

-- ============================================================
-- ANA ÇALIŞTIR (TEK SEFER - BİTTİ)
-- ============================================================
task.wait(0.3)

print("[LUCK] Koruma kalkanı kırılıyor...")
BreakShield()

print("[LUCK] Reddediciler engelleniyor...")
BlockRejectRemotes()

print("[LUCK] Luck değerleri maksimum yapılıyor...")
local count1 = MaxAllLuck()
local count2 = MaxBloomMachines()

print("")
print("========================================")
print("✅ LUCK MANIPULATOR V3 TAMAMLANDI!")
print("   📊 " .. (count1 + count2) .. " değer güncellendi")
print("   🌸 Bloom/Sprit: " .. count2 .. " makine %100 yapıldı")
print("   🛡️ Koruma kalkanı kırıldı")
print("   🚫 Reddediciler engellendi")
print("   ✅ İŞLEM BİTTİ - SESSİZ")
print("========================================")
