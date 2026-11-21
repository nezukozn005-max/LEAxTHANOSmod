--!nonstrict
--[[
	SpotifyHUD - Roblox (mobil uyumlu) "şu an çalan" HUD + senkron söz

	Ne yapar
	  - Spotify hesabında şu an çalanı okur. Telefonda arka planda çalan Spotify da, web player da aynı şekilde
	    görünür: okunan şey cihaz değil, hesabın çalma durumu (Spotify Web API "currently playing").
	  - Üstte kapsül HUD: şarkı, sanatçı, ilerleme.
	  - Sözleri LRCLIB'den çeker, şarkıyla senkron akıtır: satır + kelime vurgusu + karakterin üstünde süzülen kelimeler.

	Bir kerelik kurulum (telefonda yapılır)
	  1) developer.spotify.com/dashboard -> Create app. Redirect URI: http://127.0.0.1:8888/callback  (API: Web API).
	     (telefonda site açılmazsa tarayıcıda "masaüstü sitesi"ni aç)
	  2) Client ID'yi aşağıdaki CLIENT_ID'ye yapıştır.
	  3) Script'i çalıştır. Çıkan pencerede linki tarayıcıda aç, giriş yap, "Kabul et" de. Sayfa açılmaz
	     ("bağlanılamıyor") - normal. Adres çubuğundaki adresi komple kopyala, oyundaki kutuya yapıştır, "Bağlan".
	  Executor writefile destekliyorsa bir daha sormaz.

	Kontrol: kapsüle dokun = söz aç/kapat. Sözün altındaki -/+ = senkron kaydırma (söz geç kalıyorsa +, erken gidiyorsa -).
	Tekrar çalıştırırsan eskisini kapatıp yenisini açar.
]]

local CONFIG = {
	SOURCE = "relay", -- "relay" = telefon bildirimi (client id yok) | "spotify" = Spotify Web API (CLIENT_ID ister)
	RELAY_TOPIC = "spotifyhud-k7q2m9xv4w", -- FILL: telefondaki bildirim yönlendiricide AYNI topic. Kendine özel uzun bir şey yap
	RELAY_HOST = "https://ntfy.sh",
	RELAY_SINCE = "10m", -- bu süreden eski bildirimi görmezden gel
	CLIENT_ID = "", -- sadece SOURCE = "spotify" için -- FILL: developer.spotify.com/dashboard -> uygulaman -> Settings -> Client ID
	REDIRECT_URI = "http://127.0.0.1:8888/callback", -- dashboard'daki Redirect URI ile birebir aynı olmalı
	POLL_SECONDS = 3, -- çalarken kaç saniyede bir sor
	IDLE_POLL_SECONDS = 6, -- hiçbir şey çalmıyorken
	SHOW_LYRICS = true, -- söz açık başlasın
	FLOATING_WORDS = true, -- karakterin üstünde süzülen kelimeler
	LYRIC_OFFSET = 0, -- saniye; + = söz daha erken gelir
	FILE = "SpotifyHud.json", -- executor workspace'inde ayar/token dosyası
	ACCENT = Color3.fromRGB(150, 110, 255),
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- önceki kopya varsa kapat
if shared.SpotifyHud and shared.SpotifyHud.Destroy then
	pcall(shared.SpotifyHud.Destroy)
end

local alive = true
local conns = {}

------------------------------------------------------------------------------------------------------------
-- küçük yardımcılar
------------------------------------------------------------------------------------------------------------

local function clamp(v, a, b)
	if v < a then
		return a
	elseif v > b then
		return b
	end
	return v
end

local function trim(s)
	return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function fmtTime(sec)
	sec = math.max(0, math.floor(sec or 0))
	return string.format("%d:%02d", math.floor(sec / 60), sec % 60)
end

local function jdecode(s)
	if type(s) ~= "string" or s == "" then
		return nil
	end
	local ok, v = pcall(HttpService.JSONDecode, HttpService, s)
	if ok then
		return v
	end
	return nil
end

local function jencode(t)
	local ok, v = pcall(HttpService.JSONEncode, HttpService, t)
	if ok then
		return v
	end
	return nil
end

local function urlenc(s)
	return (tostring(s):gsub("[^%w%-%._~]", function(c)
		return string.format("%%%02X", c:byte())
	end))
end

local function form(list)
	local t = {}
	for i, kv in ipairs(list) do
		t[i] = urlenc(kv[1]) .. "=" .. urlenc(kv[2])
	end
	return table.concat(t, "&")
end

------------------------------------------------------------------------------------------------------------
-- sha256 + base64url (PKCE için; saf Luau, bit32 ile)
------------------------------------------------------------------------------------------------------------

local K = {
	0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
	0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
	0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
	0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
	0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
	0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
	0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
	0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
}

local band, bxor, bnot, rshift, rrotate = bit32.band, bit32.bxor, bit32.bnot, bit32.rshift, bit32.rrotate
local TWO32 = 4294967296

local function be32(x)
	x = math.floor(x)
	return string.char(math.floor(x / 16777216) % 256, math.floor(x / 65536) % 256, math.floor(x / 256) % 256, x % 256)
end

local function sha256(msg)
	local h = { 0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19 }
	local n = #msg
	local bits = n * 8
	msg = msg .. "\128" .. string.rep("\0", (55 - n) % 64) .. be32(math.floor(bits / TWO32)) .. be32(bits % TWO32)
	local w = {}
	for chunk = 1, #msg, 64 do
		for i = 0, 15 do
			local a, b, c, d = msg:byte(chunk + i * 4, chunk + i * 4 + 3)
			w[i] = ((a * 256 + b) * 256 + c) * 256 + d
		end
		for i = 16, 63 do
			local x, y = w[i - 15], w[i - 2]
			local s0 = bxor(rrotate(x, 7), rrotate(x, 18), rshift(x, 3))
			local s1 = bxor(rrotate(y, 17), rrotate(y, 19), rshift(y, 10))
			w[i] = (w[i - 16] + s0 + w[i - 7] + s1) % TWO32
		end
		local a, b, c, d, e, f, g, hh = h[1], h[2], h[3], h[4], h[5], h[6], h[7], h[8]
		for i = 0, 63 do
			local S1 = bxor(rrotate(e, 6), rrotate(e, 11), rrotate(e, 25))
			local ch = bxor(band(e, f), band(bnot(e), g))
			local t1 = (hh + S1 + ch + K[i + 1] + w[i]) % TWO32
			local S0 = bxor(rrotate(a, 2), rrotate(a, 13), rrotate(a, 22))
			local maj = bxor(band(a, b), band(a, c), band(b, c))
			local t2 = (S0 + maj) % TWO32
			hh, g, f, e, d, c, b, a = g, f, e, (d + t1) % TWO32, c, b, a, (t1 + t2) % TWO32
		end
		h[1] = (h[1] + a) % TWO32
		h[2] = (h[2] + b) % TWO32
		h[3] = (h[3] + c) % TWO32
		h[4] = (h[4] + d) % TWO32
		h[5] = (h[5] + e) % TWO32
		h[6] = (h[6] + f) % TWO32
		h[7] = (h[7] + g) % TWO32
		h[8] = (h[8] + hh) % TWO32
	end
	local out = {}
	for i = 1, 8 do
		out[i] = be32(h[i])
	end
	return table.concat(out)
end

local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function b64url(bin)
	local out = {}
	for i = 1, #bin, 3 do
		local a, b, c = bin:byte(i, i + 2)
		local n = a * 65536 + (b or 0) * 256 + (c or 0)
		local c1 = math.floor(n / 262144) % 64
		local c2 = math.floor(n / 4096) % 64
		local c3 = math.floor(n / 64) % 64
		local c4 = n % 64
		local s = B64:sub(c1 + 1, c1 + 1) .. B64:sub(c2 + 1, c2 + 1)
		if b then
			s = s .. B64:sub(c3 + 1, c3 + 1)
		end
		if c then
			s = s .. B64:sub(c4 + 1, c4 + 1)
		end
		out[#out + 1] = s
	end
	return (table.concat(out):gsub("%+", "-"):gsub("/", "_"))
end

local CHARSET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
local rng = Random and Random.new() or nil

local function randomString(n)
	local t = {}
	for i = 1, n do
		local k = rng and rng:NextInteger(1, #CHARSET) or math.random(1, #CHARSET)
		t[i] = CHARSET:sub(k, k)
	end
	return table.concat(t)
end

------------------------------------------------------------------------------------------------------------
-- HTTP (executor'ın request fonksiyonu) + dosya
------------------------------------------------------------------------------------------------------------

local HTTP = request or http_request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request)

local function headerOf(h, name)
	if type(h) ~= "table" then
		return nil
	end
	name = name:lower()
	for k, v in pairs(h) do
		if tostring(k):lower() == name then
			return v
		end
	end
	return nil
end

-- döner: {code, body, headers}  |  nil, hata
local function http(method, url, headers, body)
	if not HTTP then
		return nil, "no-http"
	end
	local ok, res = pcall(HTTP, { Url = url, Method = method, Headers = headers or {}, Body = body })
	if not ok then
		return nil, tostring(res)
	end
	if type(res) ~= "table" then
		return nil, "bad-response"
	end
	local code = tonumber(res.StatusCode or res.status_code or res.Status) or (res.Success and 200) or 0
	return { code = code, body = res.Body or res.body or "", headers = res.Headers or res.headers or {} }
end

local FILE_OK = (writefile and readfile and isfile) and true or false
local store = {}

local function saveStore()
	if FILE_OK then
		local s = jencode(store)
		if s then
			pcall(writefile, CONFIG.FILE, s)
		end
	end
end

if FILE_OK then
	local ok, s = pcall(function()
		if isfile(CONFIG.FILE) then
			return readfile(CONFIG.FILE)
		end
		return nil
	end)
	local t = ok and jdecode(s) or nil
	if type(t) == "table" then
		store = t
	end
end

------------------------------------------------------------------------------------------------------------
-- LRC: ayrıştırma, satır/kelime zamanlaması
------------------------------------------------------------------------------------------------------------

local function parseLrc(s)
	local lines = {}
	for raw in (tostring(s or "") .. "\n"):gmatch("(.-)\r?\n") do
		local stamps = {}
		local rest = raw
		while true do
			local _, e, mm, ss, ff = rest:find("^%s*%[(%d+):(%d+)([%.:]?%d*)%]")
			if not e then
				break
			end
			local frac = 0
			if ff and #ff > 1 then
				frac = tonumber("0." .. ff:sub(2)) or 0
			end
			stamps[#stamps + 1] = tonumber(mm) * 60 + tonumber(ss) + frac
			rest = rest:sub(e + 1)
		end
		if #stamps > 0 then
			local text = trim((rest:gsub("<%d+:%d+[%.:]?%d*>", "")))
			for _, t in ipairs(stamps) do
				lines[#lines + 1] = { t = t, text = text, n = #lines }
			end
		end
	end
	table.sort(lines, function(a, b)
		if a.t ~= b.t then
			return a.t < b.t
		end
		return a.n < b.n
	end)
	return lines
end

-- pos'tan küçük/eşit en büyük t'li satırın indeksi (yoksa 0)
local function findLine(lines, pos)
	local lo, hi, ans = 1, #lines, 0
	while lo <= hi do
		local mid = math.floor((lo + hi) / 2)
		if lines[mid].t <= pos then
			ans = mid
			lo = mid + 1
		else
			hi = mid - 1
		end
	end
	return ans
end

-- LRC kelime zamanı vermez: satır süresini harf sayısına bölüp tahmin ederiz
local function wordTimings(text, t0, t1)
	local ws = {}
	for w in text:gmatch("%S+") do
		ws[#ws + 1] = w
	end
	local n = #ws
	if n == 0 then
		return {}
	end
	local dur = math.max(0.2, t1 - t0)
	local span = math.min(dur * 0.92, 0.55 * n + 1.0)
	local wt, total = {}, 0
	for i = 1, n do
		wt[i] = (utf8.len(ws[i]) or #ws[i]) + 1.5
		total = total + wt[i]
	end
	local out, acc = {}, 0
	for i = 1, n do
		out[i] = { s = ws[i], t0 = t0 + span * acc / total }
		acc = acc + wt[i]
		out[i].t1 = (i == n) and t1 or (t0 + span * acc / total)
	end
	return out
end

local function findWord(words, pos)
	local ans = 0
	for i = 1, #words do
		if words[i].t0 <= pos then
			ans = i
		else
			break
		end
	end
	return ans
end

local function wordsOf(lines, i)
	local ln = lines[i]
	if not ln.w then
		local nextT = lines[i + 1] and lines[i + 1].t or (ln.t + 6)
		ln.w = wordTimings(ln.text, ln.t, nextT)
	end
	return ln.w
end

------------------------------------------------------------------------------------------------------------
-- Spotify: PKCE giriş, token, şu an çalan
------------------------------------------------------------------------------------------------------------

local SCOPES = "user-read-currently-playing user-read-playback-state"
local access, accessExp = nil, 0

local function authUrl()
	if not store.verifier then
		store.verifier = randomString(64)
		saveStore()
	end
	return "https://accounts.spotify.com/authorize?"
		.. form({
			{ "response_type", "code" },
			{ "client_id", CONFIG.CLIENT_ID },
			{ "scope", SCOPES },
			{ "redirect_uri", CONFIG.REDIRECT_URI },
			{ "code_challenge_method", "S256" },
			{ "code_challenge", b64url(sha256(store.verifier)) },
		})
end

-- döner: json | nil, hata, httpKodu
local function tokenRequest(fields)
	local r, err = http("POST", "https://accounts.spotify.com/api/token", { ["Content-Type"] = "application/x-www-form-urlencoded" }, form(fields))
	if not r then
		return nil, err
	end
	local j = jdecode(r.body)
	if r.code ~= 200 or type(j) ~= "table" or not j.access_token then
		local why = type(j) == "table" and (j.error or j.error_description) or ("http " .. tostring(r.code))
		return nil, tostring(why), r.code
	end
	return j
end

local function applyTokens(j)
	access = j.access_token
	accessExp = os.clock() + (tonumber(j.expires_in) or 3600) - 60
	if j.refresh_token then
		store.refresh = j.refresh_token
		saveStore()
	end
end

local function exchangeCode(code)
	if not store.verifier then
		return false, "önce bağlantı linkini aç"
	end
	local j, err = tokenRequest({
		{ "grant_type", "authorization_code" },
		{ "code", code },
		{ "redirect_uri", CONFIG.REDIRECT_URI },
		{ "client_id", CONFIG.CLIENT_ID },
		{ "code_verifier", store.verifier },
	})
	if not j then
		return false, err
	end
	applyTokens(j)
	store.verifier = nil
	saveStore()
	return true
end

local function refreshToken()
	local j, err, code = tokenRequest({
		{ "grant_type", "refresh_token" },
		{ "refresh_token", store.refresh },
		{ "client_id", CONFIG.CLIENT_ID },
	})
	if not j then
		if code == 400 and err == "invalid_grant" then
			store.refresh = nil -- izin geri alınmış: yeniden bağlanmak gerek
			saveStore()
		end
		return false, err
	end
	applyTokens(j)
	return true
end

local function getToken()
	if access and os.clock() < accessExp then
		return access
	end
	if not store.refresh then
		return nil
	end
	if refreshToken() then
		return access
	end
	return nil
end

-- {kind = auth | idle | retry | limit | net | track, ...}
local function fetchSpotify()
	local tok = getToken()
	if not tok then
		return { kind = "auth" }
	end
	local t0 = os.clock()
	local r, err = http("GET", "https://api.spotify.com/v1/me/player/currently-playing?additional_types=track,episode", { Authorization = "Bearer " .. tok })
	local t1 = os.clock()
	if not r then
		return { kind = "net", err = err }
	end
	if r.code == 204 then
		return { kind = "idle" }
	elseif r.code == 401 then
		access = nil
		return { kind = "retry" }
	elseif r.code == 429 then
		return { kind = "limit", wait = tonumber(headerOf(r.headers, "retry-after")) or 5 }
	elseif r.code ~= 200 then
		return { kind = "net", err = "http " .. tostring(r.code) }
	end
	local j = jdecode(r.body)
	if type(j) ~= "table" then
		return { kind = "idle" }
	end
	local it = j.item
	if type(it) ~= "table" then
		return { kind = "idle", ad = (j.currently_playing_type == "ad") }
	end
	local artist = ""
	if type(it.artists) == "table" and it.artists[1] then
		artist = tostring(it.artists[1].name or "")
	elseif type(it.show) == "table" then
		artist = tostring(it.show.name or "")
	end
	local title = tostring(it.name or "?")
	return {
		kind = "track",
		id = it.id or it.uri or (title .. "|" .. artist),
		title = title,
		artist = artist,
		album = (type(it.album) == "table" and it.album.name) or "",
		dur = (tonumber(it.duration_ms) or 0) / 1000,
		prog = (tonumber(j.progress_ms) or 0) / 1000,
		playing = (j.is_playing == true),
		episode = (it.type == "episode"),
		at = (t0 + t1) / 2, -- progress_ms yanıtın üretildiği ana ait: istek süresinin ortası
	}
end

------------------------------------------------------------------------------------------------------------
-- relay: telefon bildirimi -> ntfy.sh -> buraya (hesap/client id yok)
-- Telefon bildirim başlığını (şarkı) ve metnini (sanatçı) https://ntfy.sh/<RELAY_TOPIC> adresine POST eder.
--   ntfy "Title" header = şarkı adı, gövde = sanatçı.  (ya da gövde: {"title":"..","artist":"..","pos":12})
------------------------------------------------------------------------------------------------------------

local durCache = {} -- id -> saniye (LRCLIB'den öğrenilir)
local relayState = { mid = nil, startClock = 0 }

local function relayParse(ev)
	local title, body = trim(ev.title), trim(ev.message)
	local artist, pos0 = "", 0
	local j = body:sub(1, 1) == "{" and jdecode(body) or nil
	if type(j) == "table" then
		title = trim(j.title or j.track or title)
		artist = trim(j.artist or j.text or j.subtitle or "")
		pos0 = tonumber(j.pos) or 0
	elseif title ~= "" then
		artist = body
	else
		local a, b = body:match("^(.-)%s+[%-\226\128\147\226\128\148]+%s+(.+)$")
		if a then
			title, artist = a, b
		else
			local l1, l2 = body:match("^([^\n]+)\n+([^\n]+)")
			title, artist = l1 or body, l2 or ""
		end
	end
	return trim(title), trim(artist), pos0
end

local function fetchRelay()
	local url = CONFIG.RELAY_HOST .. "/" .. urlenc(CONFIG.RELAY_TOPIC) .. "/json?poll=1&since=" .. urlenc(CONFIG.RELAY_SINCE)
	local r, err = http("GET", url, { ["User-Agent"] = "SpotifyHUD-Roblox/1.0" })
	if not r then
		return { kind = "net", err = err }
	end
	if r.code == 429 then
		return { kind = "limit", wait = tonumber(headerOf(r.headers, "retry-after")) or 5 }
	elseif r.code ~= 200 then
		return { kind = "net", err = "http " .. tostring(r.code) }
	end
	local last
	for line in tostring(r.body):gmatch("[^\r\n]+") do
		local ev = jdecode(line)
		if type(ev) == "table" and ev.event == "message" then
			if not last or (tonumber(ev.time) or 0) >= (tonumber(last.time) or 0) then
				last = ev
			end
		end
	end
	if not last then
		return { kind = "idle" }
	end
	local title, artist, pos0 = relayParse(last)
	if title == "" then
		return { kind = "idle" }
	end
	-- yeni bildirim = şarkı o an başladı (bildirimin saatinden bugüne geçen süre kadar ilerlemiş say)
	if relayState.mid ~= last.id then
		local age = math.max(0, os.time() - (tonumber(last.time) or os.time()))
		relayState = { mid = last.id, startClock = os.clock() - (pos0 + age) }
	end
	local prog = os.clock() - relayState.startClock
	local id = title .. "|" .. artist
	local dur = durCache[id] or 0
	if (dur > 0 and prog > dur + 3) or prog > 1200 then
		return { kind = "idle" } -- şarkı bitmiş, yeni bildirim gelmedi
	end
	return {
		kind = "track", id = id, title = title, artist = artist, album = "",
		dur = dur, prog = prog, playing = true, episode = false, at = os.clock(),
	}
end

local function fetchNow()
	if CONFIG.SOURCE == "spotify" then
		return fetchSpotify()
	end
	return fetchRelay()
end

------------------------------------------------------------------------------------------------------------
-- LRCLIB: söz
------------------------------------------------------------------------------------------------------------

local LRC_HEADERS = { ["User-Agent"] = "SpotifyHUD-Roblox/1.0" }

local function cleanTitle(t)
	t = t:gsub("%s*[%(%[].-[%)%]]", ""):gsub("%s+%-%s+.*$", "")
	return trim(t)
end

-- döner: {status = "ok"|"plain"|"instr"|"none", lines = {...}, dur = saniye|nil}
local function pickBest(list, t, fa)
	local best, bestScore
	fa = fa:lower()
	for _, c in ipairs(list) do
		if type(c) == "table" and (c.syncedLyrics or c.plainLyrics or c.instrumental) then
			local cd = tonumber(c.duration) or 0
			local score = 0
			local okc = true
			if t.dur > 0 then
				local diff = math.abs(cd - t.dur)
				okc = diff <= 4
				score = diff
			end
			if okc then
				if not (type(c.syncedLyrics) == "string" and c.syncedLyrics ~= "") then
					score = score + 100
				end
				if fa ~= "" and not tostring(c.artistName or ""):lower():find(fa, 1, true) then
					score = score + 50
				end
				if not best or score < bestScore then
					best, bestScore = c, score
				end
			end
		end
	end
	return best
end

local function fetchLyrics(t)
	local j
	local fa = trim(t.artist:match("^([^,&]+)") or t.artist)
	if t.dur > 0 then
		local r = http("GET", "https://lrclib.net/api/get?" .. form({
			{ "track_name", t.title },
			{ "artist_name", t.artist },
			{ "album_name", t.album or "" },
			{ "duration", math.floor(t.dur + 0.5) },
		}), LRC_HEADERS)
		if r and r.code == 200 then
			j = jdecode(r.body)
		end
		if not (type(j) == "table" and (j.syncedLyrics or j.plainLyrics or j.instrumental)) then
			j = nil
		end
	end
	if not j then
		local tries = {
			{ { "track_name", cleanTitle(t.title) }, { "artist_name", t.artist } },
			{ { "track_name", cleanTitle(t.title) }, { "artist_name", fa } },
			{ { "q", cleanTitle(t.title) .. " " .. fa } },
			{ { "q", cleanTitle(t.title) } },
		}
		for _, q in ipairs(tries) do
			local r2 = http("GET", "https://lrclib.net/api/search?" .. form(q), LRC_HEADERS)
			local list = r2 and r2.code == 200 and jdecode(r2.body) or nil
			if type(list) == "table" then
				j = pickBest(list, t, fa)
				if j then
					break
				end
			end
		end
	end
	if not j then
		return { status = "none", lines = {} }
	end
	local d = tonumber(j.duration)
	if type(j.syncedLyrics) == "string" and j.syncedLyrics ~= "" then
		local lines = parseLrc(j.syncedLyrics)
		if #lines > 0 then
			return { status = "ok", lines = lines, dur = d }
		end
	end
	if j.instrumental then
		return { status = "instr", lines = {}, dur = d }
	end
	if type(j.plainLyrics) == "string" and j.plainLyrics ~= "" then
		return { status = "plain", lines = {}, dur = d }
	end
	return { status = "none", lines = {}, dur = d }
end

------------------------------------------------------------------------------------------------------------
-- çalma modeli (yerel saatle ilerletilir, her poll'da düzeltilir)
------------------------------------------------------------------------------------------------------------

local P = { id = nil, title = "", artist = "", album = "", dur = 0, base = 0, at = 0, playing = false, episode = false }
local L = { id = nil, status = "none", lines = {} }
local offset = tonumber(store.offset) or CONFIG.LYRIC_OFFSET
local showLyrics = store.lyrics
if showLyrics == nil then
	showLyrics = CONFIG.SHOW_LYRICS
end
local kick = false
local ui -- arayüz tablosu (aşağıda kurulur)

local function posNow()
	if not P.id then
		return 0
	end
	local p = P.base
	if P.playing then
		p = p + (os.clock() - P.at)
	end
	return clamp(p, 0, P.dur > 0 and P.dur or 1e9)
end

------------------------------------------------------------------------------------------------------------
-- arayüz
------------------------------------------------------------------------------------------------------------

local BG = Color3.fromRGB(14, 14, 20)
local WHITE = Color3.fromRGB(245, 245, 250)
local DIM = Color3.fromRGB(140, 140, 156)
local ACCENT = CONFIG.ACCENT

local function new(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props or {}) do
		local ok, err = pcall(function()
			o[k] = v
		end)
		if not ok then
			warn("[SpotifyHUD] " .. class .. "." .. tostring(k) .. ": " .. tostring(err))
		end
	end
	if parent then
		o.Parent = parent
	end
	return o
end

local function rounded(parent, r)
	return new("UICorner", { CornerRadius = UDim.new(0, r) }, parent)
end

local function connect(signal, fn)
	local c = signal:Connect(fn)
	conns[#conns + 1] = c
	return c
end

local function buildUi()
	local U = { words = {}, floating = {}, lineIdx = -1, wordIdx = -1, curWords = nil }
	local player = Players.LocalPlayer
	while not player do
		task.wait(0.1)
		player = Players.LocalPlayer
	end
	local playerGui = player:WaitForChild("PlayerGui")
	U.playerGui = playerGui
	U.player = player

	local gui = new("ScreenGui", {
		Name = "SpotifyHud",
		ResetOnSpawn = false,
		DisplayOrder = 50,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	pcall(function()
		gui.ScreenInsets = Enum.ScreenInsets.TopbarSafe
	end)
	gui.Parent = playerGui
	U.gui = gui

	-- kapsül
	local cap = new("TextButton", {
		Name = "Capsule",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 6),
		Size = UDim2.fromOffset(320, 48),
		BackgroundColor3 = BG,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
	}, gui)
	rounded(cap, 24)
	new("UIStroke", { Color = Color3.new(1, 1, 1), Transparency = 0.88, Thickness = 1 }, cap)
	U.scaleCap = new("UIScale", { Scale = 1 }, cap)
	U.cap = cap

	U.art = new("Frame", { Name = "Art", Position = UDim2.fromOffset(6, 6), Size = UDim2.fromOffset(36, 36), BackgroundColor3 = ACCENT, BorderSizePixel = 0 }, cap)
	rounded(U.art, 18)
	U.note = new("TextLabel", {
		Name = "Note",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "♪",
		TextColor3 = WHITE,
		Font = Enum.Font.GothamBold,
		TextSize = 18,
	}, U.art)

	U.title = new("TextLabel", {
		Name = "Title",
		Position = UDim2.fromOffset(50, 4),
		Size = UDim2.new(1, -62, 0, 20),
		BackgroundTransparency = 1,
		Text = "Spotify",
		TextColor3 = WHITE,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, cap)
	U.artist = new("TextLabel", {
		Name = "Artist",
		Position = UDim2.fromOffset(50, 23),
		Size = UDim2.new(1, -112, 0, 16),
		BackgroundTransparency = 1,
		Text = "",
		TextColor3 = DIM,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, cap)
	U.time = new("TextLabel", {
		Name = "Time",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 24),
		Size = UDim2.fromOffset(90, 14),
		BackgroundTransparency = 1,
		Text = "",
		TextColor3 = DIM,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Right,
	}, cap)
	local barBack = new("Frame", {
		Name = "Bar",
		Position = UDim2.new(0, 50, 1, -7),
		Size = UDim2.new(1, -64, 0, 2),
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 0.85,
		BorderSizePixel = 0,
	}, cap)
	rounded(barBack, 1)
	U.fill = new("Frame", { Name = "Fill", Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = ACCENT, BorderSizePixel = 0 }, barBack)
	rounded(U.fill, 1)

	-- söz bloğu
	local lyr = new("Frame", {
		Name = "Lyrics",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 62),
		Size = UDim2.new(0, 460, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Visible = false,
	}, gui)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4),
	}, lyr)
	U.scaleLyr = new("UIScale", { Scale = 1 }, lyr)
	U.lyr = lyr
	local function lineLabel(name, order, size)
		return new("TextLabel", {
			Name = name,
			LayoutOrder = order,
			Size = UDim2.new(1, 0, 0, size + 4),
			BackgroundTransparency = 1,
			Text = "",
			TextColor3 = WHITE,
			TextTransparency = 0.5,
			Font = Enum.Font.GothamMedium,
			TextSize = size,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextStrokeColor3 = Color3.new(0, 0, 0),
			TextStrokeTransparency = 0.6,
		}, lyr)
	end
	U.prev = lineLabel("Prev", 1, 13)
	U.row = new("Frame", {
		Name = "Row",
		LayoutOrder = 2,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, lyr)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Wraps = true,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 5),
	}, U.row)
	U.next = lineLabel("Next", 3, 13)

	-- senkron kaydırma: - [söz +0.00s] +
	local ctl = new("Frame", { Name = "Ctl", LayoutOrder = 4, Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1 }, lyr)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
	}, ctl)
	local function smallButton(text, order)
		local b = new("TextButton", {
			Name = "Btn" .. text,
			LayoutOrder = order,
			Size = UDim2.fromOffset(34, 22),
			BackgroundColor3 = BG,
			BackgroundTransparency = 0.25,
			BorderSizePixel = 0,
			AutoButtonColor = true,
			Text = text,
			TextColor3 = WHITE,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
		}, ctl)
		rounded(b, 11)
		return b
	end
	U.minus = smallButton("-", 1)
	U.offLbl = new("TextLabel", {
		Name = "Offset",
		LayoutOrder = 2,
		Size = UDim2.fromOffset(96, 22),
		BackgroundTransparency = 1,
		Text = "",
		TextColor3 = DIM,
		Font = Enum.Font.Gotham,
		TextSize = 11,
	}, ctl)
	U.plus = smallButton("+", 3)

	-- kurulum paneli
	local setup = new("Frame", {
		Name = "Setup",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0, 380, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = BG,
		BackgroundTransparency = 0.03,
		BorderSizePixel = 0,
		Visible = false,
	}, gui)
	rounded(setup, 16)
	new("UIStroke", { Color = Color3.new(1, 1, 1), Transparency = 0.85, Thickness = 1 }, setup)
	new("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12) }, setup)
	new("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) }, setup)
	U.scaleSetup = new("UIScale", { Scale = 1 }, setup)
	U.setup = setup
	new("TextLabel", {
		Name = "H",
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Text = "Spotify'ı bağla (bir kerelik)",
		TextColor3 = WHITE,
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, setup)
	U.steps = new("TextLabel", {
		Name = "Steps",
		LayoutOrder = 2,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text = "",
		TextColor3 = DIM,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
	}, setup)
	local function box(name, order, placeholder)
		local b = new("TextBox", {
			Name = name,
			LayoutOrder = order,
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundColor3 = Color3.fromRGB(30, 30, 40),
			BorderSizePixel = 0,
			Text = "",
			PlaceholderText = placeholder,
			PlaceholderColor3 = DIM,
			TextColor3 = WHITE,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			ClearTextOnFocus = false,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, setup)
		rounded(b, 8)
		new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, b)
		return b
	end
	U.urlBox = box("Url", 3, "bağlantı linki")
	U.codeBox = box("Code", 4, "açılan adresi buraya yapıştır")
	local btnRow = new("Frame", { Name = "Btns", LayoutOrder = 5, Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1 }, setup)
	new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) }, btnRow)
	U.connectBtn = new("TextButton", {
		Name = "Connect",
		LayoutOrder = 1,
		Size = UDim2.new(0.6, -4, 1, 0),
		BackgroundColor3 = ACCENT,
		BorderSizePixel = 0,
		Text = "Bağlan",
		TextColor3 = WHITE,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
	}, btnRow)
	rounded(U.connectBtn, 8)
	U.closeBtn = new("TextButton", {
		Name = "Close",
		LayoutOrder = 2,
		Size = UDim2.new(0.4, -4, 1, 0),
		BackgroundColor3 = Color3.fromRGB(40, 40, 52),
		BorderSizePixel = 0,
		Text = "Kapat",
		TextColor3 = WHITE,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
	}, btnRow)
	rounded(U.closeBtn, 8)
	U.setupMsg = new("TextLabel", {
		Name = "Msg",
		LayoutOrder = 6,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text = "",
		TextColor3 = Color3.fromRGB(255, 140, 140),
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, setup)

	return U
end

-- ölçek: ekran genişliğine göre
local function applyScale()
	if not ui then
		return
	end
	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(844, 390)
	local s = clamp(vp.X / 820, 0.75, 1.25)
	local avail = vp.X / s - 24
	ui.scaleCap.Scale = s
	ui.scaleLyr.Scale = s
	ui.scaleSetup.Scale = s
	ui.cap.Size = UDim2.fromOffset(math.min(320, avail), 48)
	ui.lyr.Position = UDim2.new(0.5, 0, 0, math.floor(62 * s))
	ui.lyr.Size = UDim2.new(0, math.min(460, avail), 0, 0)
	ui.setup.Size = UDim2.new(0, math.min(380, avail), 0, 0)
end

------------------------------------------------------------------------------------------------------------
-- arayüz davranışı
------------------------------------------------------------------------------------------------------------

local status -- kapsülde sanatçı yerine gösterilen kısa durum metni

local function hueColor(s)
	local h = 0
	for i = 1, #s do
		h = (h * 31 + s:byte(i)) % 360
	end
	return Color3.fromHSV(h / 360, 0.55, 0.85)
end

local function refreshCapsule()
	if not ui then
		return
	end
	if P.id then
		ui.title.Text = P.title
		ui.artist.Text = status or P.artist
		ui.art.BackgroundColor3 = hueColor(tostring(P.id))
	else
		ui.title.Text = "Spotify"
		ui.artist.Text = status or "Çalan bir şey yok"
		ui.art.BackgroundColor3 = ACCENT
	end
	ui.lyr.Visible = (showLyrics and P.id ~= nil and not P.episode) and true or false
end

local function clearWords()
	for _, w in ipairs(ui.words) do
		pcall(function()
			w:Destroy()
		end)
	end
	ui.words = {}
	ui.curWords = nil
end

local function addWord(text, order)
	local lbl = new("TextLabel", {
		Name = "W" .. order,
		LayoutOrder = order,
		Size = UDim2.fromOffset(0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = ACCENT,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = text,
		TextColor3 = DIM,
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextStrokeColor3 = Color3.new(0, 0, 0),
		TextStrokeTransparency = 0.7,
	}, ui.row)
	rounded(lbl, 8)
	new("UIPadding", { PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), PaddingTop = UDim.new(0, 1), PaddingBottom = UDim.new(0, 1) }, lbl)
	ui.words[#ui.words + 1] = lbl
	return lbl
end

local function setWordState(i)
	for k, lbl in ipairs(ui.words) do
		if k < i then
			lbl.TextColor3 = WHITE
			lbl.BackgroundTransparency = 1
		elseif k == i then
			lbl.TextColor3 = WHITE
			lbl.BackgroundTransparency = 0
		else
			lbl.TextColor3 = DIM
			lbl.BackgroundTransparency = 1
		end
	end
end

local function lineText(lines, i)
	local ln = lines[i]
	return ln and ln.text or ""
end

-- tek satırlık bilgi (yükleniyor / söz yok ...)
local function showNote(text)
	clearWords()
	ui.prev.Text = ""
	ui.next.Text = ""
	local lbl = addWord(text, 1)
	lbl.TextColor3 = DIM
	lbl.TextSize = 14
	ui.lineIdx = -1
	ui.wordIdx = -1
end

local function renderLine(idx)
	clearWords()
	local lines = L.lines
	local text = lineText(lines, idx)
	if idx >= 1 then
		ui.prev.Text = lineText(lines, idx - 1)
	else
		ui.prev.Text = ""
	end
	local nxt = lineText(lines, idx + 1)
	if idx == 0 and nxt == "" then
		nxt = lineText(lines, 2)
	end
	ui.next.Text = nxt
	if idx >= 1 and text ~= "" then
		local ws = wordsOf(lines, idx)
		ui.curWords = ws
		for i, w in ipairs(ws) do
			addWord(w.s, i)
		end
		setWordState(0)
	else
		local lbl = addWord("♪", 1)
		lbl.TextColor3 = DIM
	end
end

local function floatWord(word)
	if not (CONFIG.FLOATING_WORDS and showLyrics) then
		return
	end
	local char = ui.player.Character
	local head = char and char:FindFirstChild("Head")
	if not head or #ui.floating >= 4 then
		return
	end
	local ascii = not word:find("[\128-\255]")
	local txt = ascii and word:upper() or word
	local bb = new("BillboardGui", {
		Adornee = head,
		Size = UDim2.fromOffset(240, 50),
		StudsOffset = Vector3.new(0, 3, 0),
		AlwaysOnTop = true,
	}, ui.playerGui)
	local lbl = new("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.7),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = txt,
		TextColor3 = WHITE,
		Font = Enum.Font.GothamBlack,
		TextSize = 28,
		TextStrokeColor3 = ACCENT,
		TextStrokeTransparency = 0.2,
		Rotation = math.random(-9, 9),
	}, bb)
	ui.floating[#ui.floating + 1] = bb
	pcall(function()
		TweenService:Create(lbl, TweenInfo.new(1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.fromScale(0.5, -0.4),
			TextTransparency = 1,
			TextStrokeTransparency = 1,
		}):Play()
	end)
	task.delay(1.5, function()
		for i, b in ipairs(ui.floating) do
			if b == bb then
				table.remove(ui.floating, i)
				break
			end
		end
		pcall(function()
			bb:Destroy()
		end)
	end)
end

local function updateLyrics(pos)
	if L.status ~= "ok" then
		return
	end
	local idx = findLine(L.lines, pos)
	if idx ~= ui.lineIdx then
		ui.lineIdx = idx
		ui.wordIdx = -1
		renderLine(idx)
	end
	if ui.curWords then
		local wi = findWord(ui.curWords, pos)
		if wi ~= ui.wordIdx then
			ui.wordIdx = wi
			setWordState(wi)
			if wi >= 1 then
				floatWord(ui.curWords[wi].s)
			end
		end
	end
end

local function showLyricStatus()
	if not ui then
		return
	end
	if L.status == "loading" then
		showNote("sözler yükleniyor...")
	elseif L.status == "plain" then
		showNote("senkron söz yok")
	elseif L.status == "instr" then
		showNote("♪ enstrümantal")
	elseif L.status == "none" then
		showNote(P.episode and "" or "söz bulunamadı")
	elseif L.status == "ok" then
		ui.lineIdx = -1
		ui.wordIdx = -1
	end
end

local function refreshOffsetLabel()
	if ui then
		ui.offLbl.Text = string.format("söz %+.2fs", offset)
	end
end

local function onTrack(r)
	P.id, P.title, P.artist, P.album, P.dur, P.episode = r.id, r.title, r.artist, r.album, r.dur, r.episode
	P.base, P.at, P.playing = r.prog, r.at, r.playing
	P.kicked = false
	L = { id = r.id, status = r.episode and "none" or "loading", lines = {} }
	refreshCapsule()
	showLyricStatus()
	if not r.episode then
		local want = r.id
		task.spawn(function()
			local ok, res = pcall(fetchLyrics, r)
			if not alive or L.id ~= want then
				return
			end
			if not ok then
				warn("[SpotifyHUD] söz hatası: " .. tostring(res))
				res = { status = "none", lines = {} }
			end
			L = { id = want, status = res.status, lines = res.lines }
			if res.dur and res.dur > 0 then
				durCache[want] = res.dur
				if P.id == want and P.dur <= 0 then
					P.dur = res.dur
				end
			end
			showLyricStatus()
		end)
	end
end

local function onIdle(r)
	P.id = nil
	P.playing = false
	P.episode = false
	L = { id = nil, status = "none", lines = {} }
	status = r and r.ad and "Reklam" or nil
	refreshCapsule()
	ui.time.Text = ""
	ui.fill.Size = UDim2.new(0, 0, 1, 0)
end

local function applyTrack(r)
	if r.id ~= P.id then
		onTrack(r)
		return
	end
	local predicted = P.base + (P.playing and (r.at - P.at) or 0)
	if r.playing ~= P.playing or math.abs(r.prog - predicted) > 0.2 then
		P.base, P.at = r.prog, r.at
		P.kicked = false
	end
	P.playing = r.playing
	P.dur = r.dur
end

------------------------------------------------------------------------------------------------------------
-- kurulum paneli akışı
------------------------------------------------------------------------------------------------------------

local function setupText()
	local save = FILE_OK and "" or "\n(Bu executor dosya kaydetmiyor: her açılışta yeniden bağlanman gerekir.)"
	return "1) Aşağıdaki linki tarayıcıda aç (kopyalanmış olabilir).\n2) Spotify'a giriş yap, \"Kabul et\" de.\n3) Sayfa açılmaz, normal: adres çubuğundaki adresi komple kopyala.\n4) Aşağıdaki kutuya yapıştır, Bağlan." .. save
end

local function openSetup()
	if not ui then
		return
	end
	if CONFIG.CLIENT_ID == "" then
		ui.steps.Text = "Script'in başındaki CLIENT_ID boş. developer.spotify.com/dashboard'dan uygulama aç (Redirect URI: " .. CONFIG.REDIRECT_URI .. "), Client ID'yi CLIENT_ID'ye yapıştırıp script'i yeniden çalıştır."
		ui.urlBox.Visible = false
		ui.codeBox.Visible = false
		ui.connectBtn.Visible = false
		ui.setup.Visible = true
		return
	end
	ui.steps.Text = setupText()
	ui.urlBox.Visible = true
	ui.codeBox.Visible = true
	ui.connectBtn.Visible = true
	local url = authUrl()
	ui.authUrl = url
	ui.urlBox.Text = url
	if setclipboard then
		pcall(setclipboard, url)
	end
	ui.setupMsg.Text = ""
	ui.setup.Visible = true
end

local function parseCode(text)
	text = trim(text)
	if text == "" then
		return nil, "kutu boş"
	end
	local err = text:match("[?&]error=([^&%s]+)")
	if err then
		return nil, "Spotify izni vermedi (" .. err .. ")"
	end
	local code = text:match("[?&]code=([^&%s#]+)") or text:match("^([%w%-%._~]+)$")
	if not code then
		return nil, "adreste code= bulunamadı"
	end
	return code
end

local connecting = false
local function onConnect()
	if connecting then
		return
	end
	local code, perr = parseCode(ui.codeBox.Text)
	if not code then
		ui.setupMsg.Text = perr
		return
	end
	connecting = true
	ui.setupMsg.Text = "bağlanıyor..."
	task.spawn(function()
		local ok, res, why = pcall(exchangeCode, code)
		connecting = false
		if not alive then
			return
		end
		if ok and res then
			ui.setup.Visible = false
			ui.codeBox.Text = ""
			status = nil
			kick = true
		else
			ui.setupMsg.Text = "olmadı: " .. tostring(ok and why or res) .. " - linki yeniden açıp tekrar dene"
			-- kod tek kullanımlık: yeni link/verifier ile baştan
			store.verifier = nil
			saveStore()
			ui.urlBox.Text = authUrl()
			if setclipboard then
				pcall(setclipboard, ui.urlBox.Text)
			end
		end
	end)
end

------------------------------------------------------------------------------------------------------------
-- ana döngüler
------------------------------------------------------------------------------------------------------------

local function pollLoop()
	local fails, retries = 0, 0
	while alive do
		local interval = CONFIG.POLL_SECONDS
		local ok, res = pcall(fetchNow)
		if not ok then
			res = { kind = "net", err = tostring(res) }
		end
		if not alive then
			return
		end
		if res.kind == "track" then
			fails, retries = 0, 0
			status = nil
			applyTrack(res)
			refreshCapsule()
			if not res.playing then
				interval = CONFIG.IDLE_POLL_SECONDS
			end
		elseif res.kind == "idle" then
			fails, retries = 0, 0
			status = nil
			onIdle(res)
			interval = CONFIG.IDLE_POLL_SECONDS
		elseif res.kind == "auth" then
			status = "Bağlı değil - dokun"
			onIdle(nil)
			if not ui.setup.Visible and not ui.setupShown then
				ui.setupShown = true
				openSetup()
			end
			interval = 1
		elseif res.kind == "retry" then
			retries = retries + 1
			interval = retries > 2 and 5 or 0.3
		elseif res.kind == "limit" then
			interval = res.wait + 1
		else
			fails = fails + 1
			status = "Bağlantı sorunu, tekrar deniyorum"
			refreshCapsule()
			interval = math.min(30, 3 * fails)
			if res.err and fails == 1 then
				warn("[SpotifyHUD] " .. tostring(res.err))
			end
		end
		local untilT = os.clock() + interval
		while alive and os.clock() < untilT and not kick do
			task.wait(0.2)
		end
		kick = false
	end
end

local function frame()
	local pos = posNow()
	if P.id and P.dur > 0 then
		ui.fill.Size = UDim2.new(clamp(pos / P.dur, 0, 1), 0, 1, 0)
		local s = math.floor(pos)
		if s ~= ui.lastSec then
			ui.lastSec = s
			ui.time.Text = fmtTime(pos) .. " / " .. fmtTime(P.dur)
		end
		-- şarkı bitti: bir sonrakini hemen sor
		if P.playing and not P.kicked and pos >= P.dur - 0.3 then
			P.kicked = true
			kick = true
		end
	end
	if P.id and showLyrics and L.status == "ok" then
		updateLyrics(pos + offset)
	end
end

------------------------------------------------------------------------------------------------------------
-- başlat
------------------------------------------------------------------------------------------------------------

local API = {}

local function destroy()
	alive = false
	for _, c in ipairs(conns) do
		pcall(function()
			c:Disconnect()
		end)
	end
	conns = {}
	if ui then
		pcall(function()
			ui.gui:Destroy()
		end)
		for _, b in ipairs(ui.floating) do
			pcall(function()
				b:Destroy()
			end)
		end
		ui.floating = {}
	end
	if shared.SpotifyHud == API then
		shared.SpotifyHud = nil
	end
end

API.Destroy = destroy
-- test için iç fonksiyonlar (oyunda kullanılmaz)
API._t = {
	sha256 = sha256, b64url = b64url, parseLrc = parseLrc, findLine = findLine, wordTimings = wordTimings,
	findWord = findWord, parseCode = parseCode, authUrl = authUrl, cleanTitle = cleanTitle, fmtTime = fmtTime,
	store = function() return store end, state = function() return P, L end,
}
shared.SpotifyHud = API

ui = buildUi()
applyScale()
refreshOffsetLabel()
refreshCapsule()

local cam = workspace.CurrentCamera
if cam then
	connect(cam:GetPropertyChangedSignal("ViewportSize"), applyScale)
end
connect(RunService.RenderStepped, function()
	if alive then
		local ok, err = pcall(frame)
		if not ok and not ui.frameErr then
			ui.frameErr = true
			warn("[SpotifyHUD] frame: " .. tostring(err))
		end
	end
end)
connect(ui.cap.Activated, function()
	if CONFIG.SOURCE == "spotify" and not store.refresh and CONFIG.CLIENT_ID ~= "" and not access then
		openSetup()
		return
	end
	showLyrics = not showLyrics
	store.lyrics = showLyrics
	saveStore()
	refreshCapsule()
	if showLyrics and L.status ~= "ok" then
		showLyricStatus()
	end
	ui.lineIdx = -1
end)
connect(ui.minus.Activated, function()
	offset = math.floor((offset - 0.25) * 100 + 0.5) / 100
	store.offset = offset
	saveStore()
	refreshOffsetLabel()
end)
connect(ui.plus.Activated, function()
	offset = math.floor((offset + 0.25) * 100 + 0.5) / 100
	store.offset = offset
	saveStore()
	refreshOffsetLabel()
end)
connect(ui.connectBtn.Activated, onConnect)
connect(ui.closeBtn.Activated, function()
	ui.setup.Visible = false
end)
connect(ui.urlBox.FocusLost, function()
	if ui.authUrl then
		ui.urlBox.Text = ui.authUrl
	end
end)

if not HTTP then
	status = "Bu executor HTTP isteği desteklemiyor"
	refreshCapsule()
else
	task.spawn(pollLoop)
end

return API
