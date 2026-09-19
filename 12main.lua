-- language: Lua, file: 14main.lua, target: Roblox (Delta mobile, no-file)
-- Full anhhub + immortal + ESP Mob + ESP Item + key one-time + key random (no file IO)
warn("[anhhub] v14 no-file")
local P = game:GetService("Players")
local U = game:GetService("UserInputService")
local W = game:GetService("Workspace")
local R = game:GetService("RunService")
local LP = P.LocalPlayer

local function gg()
    if getgenv then return getgenv() end
    return _G
end
local G = gg()

-- ============================================
-- CONFIG
-- ============================================
local ADMIN_KEY_1 = "ADMIN-2012BAVCL"
local ADMIN_KEY_2 = "ADMIN-ANHHUB-9999"

-- No-file: khong dung readfile/writefile. Luu het trong G.
if not G.RAM then G.RAM = {} end
local RAM = G.RAM
-- RAM = {
--   currentKey = "...",
--   keyTime = os.time(),
--   keyHWID = "...",
--   adminKey = "...",
--   adminHWID = "...",
--   custom = { [keyStr] = {days=N, hwid="", oneTime=bool, maxSlots=N, slots={"hw1","hw2"}} }
-- }

local function HWID()
    if type(gethwid)=="function" then
        local ok,h = pcall(gethwid)
        if ok and h then return tostring(h) end
    end
    if syn and syn.get_hwid then
        local ok,h = pcall(syn.get_hwid)
        if ok and h then return tostring(h) end
    end
    return "FB_"..tostring(LP.UserId).."_"..(U.TouchEnabled and "m" or "p")
end

-- ===== KEY RANDOM =====
local function randomChunk(n)
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local out = {}
    for i=1,n do
        local idx = math.random(1, #chars)
        table.insert(out, chars:sub(idx, idx))
    end
    return table.concat(out)
end

local function genKey()
    while true do
        local k = "ANH-DZ-"..randomChunk(12)
        if not KEYS[k] and not isAdminKey(k) then
            return k
        end
    end
end

local ADMIN_KEYS_EXTRA = {}
local function isAdminKey(k)
    if k==ADMIN_KEY_1 or k==ADMIN_KEY_2 then return true end
    if ADMIN_KEYS_EXTRA[k] then return true end
    return false
end

local KEYS = {}
KEYS[genKey()] = {days=9999}
KEYS[genKey()] = {days=9999}

local C = G.AH or {}
G.AH = C
for k,v in pairs({
    ESPPlayer=false,ESPMob=false,Fly=false,Noclip=false,Speed=false,
    FlySpeed=100,RunSpeed=50,MaxDist=2000,ESPName=true,ESPDist=true,
    ESPMobName=true,
    ESPItem=false,
    ESPItemName=true,
    ESPItemMaxDist=1500,
    ESPItemSmart=true,
    IMM_Enabled=false,
    IMM_AntiGrab=true,
    IMM_AntiKnockback=true,
    IMM_AntiStun=true,
    IMM_TeleportOnLowHP=true,
    IMM_LowHPThreshold=35,
    IMM_TeleportDistance=120,
    IMM_AutoHeal=true,
    IMM_HealThreshold=70
}) do
    if C[k]==nil then C[k]=v end
end

-- ============================================
-- HELPERS (no-file)
-- ============================================
local function keyDuration(k)
    local e = KEYS[k]
    if not e then return nil end
    if e.days and e.days>=9999 then return 9999*86400 end
    local s = 0
    if e.hours then s = s + e.hours*3600 end
    if e.days then s = s + e.days*86400 end
    if e.weeks then s = s + e.weeks*7*86400 end
    if e.months then s = s + e.months*30*86400 end
    return s
end
local function isPermanent(k)
    local e = KEYS[k]
    if not e then return false end
    if e.days and e.days>=9999 then return true end
    return false
end
local function isOneTime(k)
    local e = KEYS[k]
    if not e then return false end
    return e.oneTime == true
end
local function getMaxSlots(k)
    local e = KEYS[k]
    if not e then return 0 end
    if not e.oneTime then return math.huge end
    return e.maxSlots or 1
end
local function getSlots(k)
    if not RAM.custom then RAM.custom = {} end
    local entry = RAM.custom[k]
    if not entry then return {} end
    if not entry.slots then entry.slots = {} end
    return entry.slots
end
local function isHWIDUsed(k, hwid)
    local slots = getSlots(k)
    for _, s in ipairs(slots) do
        if s == hwid then return true end
    end
    return false
end
local function HWIDFor(k)
    if not KEYS[k] then return "invalid" end
    local hw = HWID()
    if not isOneTime(k) then
        -- key thuong: check trong RAM.custom
        if not RAM.custom or not RAM.custom[k] then return "new" end
        local h = RAM.custom[k].hwid
        if not h or h=="" then return "new" end
        return h==hw and "ok" or "mismatch"
    end
    local slots = getSlots(k)
    if #slots == 0 then return "new" end
    if isHWIDUsed(k, hw) then return "ok" end
    if #slots >= getMaxSlots(k) then return "mismatch" end
    return "new_slot"
end
local function registerOTSlot(k, hwid)
    if not isOneTime(k) then return end
    if not RAM.custom then RAM.custom = {} end
    if not RAM.custom[k] then RAM.custom[k] = {days=0, hwid="", slots={}} end
    if not RAM.custom[k].slots then RAM.custom[k].slots = {} end
    local slots = RAM.custom[k].slots
    if isHWIDUsed(k, hwid) then return end
    if #slots >= getMaxSlots(k) then return end
    table.insert(slots, hwid)
end
local function HWIDCheck()
    if RAM.currentKey then
        local r = HWIDFor(RAM.currentKey)
        if r~="new" and r~="new_slot" then return r end
    end
    if not RAM.keyHWID or RAM.keyHWID=="" then return "new" end
    return tostring(RAM.keyHWID)==tostring(HWID()) and "ok" or "mismatch"
end
local function expired(k)
    if not k or not KEYS[k] then return true end
    if isPermanent(k) then return false end
    if not RAM.keyTime then return false end
    local dur = keyDuration(k)
    if not dur then return true end
    return (os.time()-RAM.keyTime) > dur
end
local function saveKey(k)
    RAM.currentKey = k
    RAM.keyTime = os.time()
    RAM.keyHWID = HWID()
    if isOneTime(k) then
        registerOTSlot(k, HWID())
    else
        if not RAM.custom then RAM.custom = {} end
        RAM.custom[k] = RAM.custom[k] or {days=0, hwid="", slots={}}
        RAM.custom[k].hwid = HWID()
    end
end
local function clearKey()
    RAM.currentKey = nil
    RAM.keyTime = nil
    RAM.keyHWID = nil
end
local function loadKey()
    if RAM.currentKey then
        if expired(RAM.currentKey) then clearKey() return nil end
        if HWIDCheck()=="mismatch" then clearKey() return nil end
        return RAM.currentKey
    end
    return nil
end
local function remainText()
    if not RAM.currentKey then return "chưa có key" end
    local e = KEYS[RAM.currentKey]
    if not e then return "invalid" end
    if isAdminKey(RAM.currentKey) then return "ADMIN — vĩnh viễn" end
    if isOneTime(RAM.currentKey) then
        local slots = getSlots(RAM.currentKey)
        return "ONE-TIME ("..#slots.."/"..getMaxSlots(RAM.currentKey).." thiết bị)"
    end
    if isPermanent(RAM.currentKey) then return "VIP — vĩnh viễn" end
    if not RAM.keyTime then return "chưa kích hoạt" end
    local dur = keyDuration(RAM.currentKey)
    local r = dur - (os.time()-RAM.keyTime)
    if r<=0 then return "hết hạn" end
    local d = math.floor(r/86400)
    local h = math.floor((r%86400)/3600)
    local m = math.floor((r%3600)/60)
    if d>0 then return d.."n "..h.."h"
    elseif h>0 then return h.."h "..m.."p"
    else return m.."p" end
end
local function adminHWIDCheck()
    if not RAM.adminHWID or RAM.adminHWID=="" then return "new" end
    return tostring(RAM.adminHWID)==tostring(HWID()) and "ok" or "mismatch"
end
local function saveAdmin(k)
    RAM.adminKey = k
    RAM.adminHWID = HWID()
end
local function loadAdmin()
    if not RAM.adminKey or RAM.adminKey=="" then return nil end
    if adminHWIDCheck()=="mismatch" then return nil end
    if isAdminKey(RAM.adminKey) then return RAM.adminKey end
    return nil
end

-- ============================================
-- ESP MOB
-- ============================================
local MOB_KEYWORDS = {
    "pocong","pocongan","hantu","setan","genderuwo","kuntilanak",
    "suster","ningsih","wewe","jailangkung","sundel","kuyang",
    "enemy","mob","boss","monster","npc","beast","dummy",
    "creep","unit","entity","wild","animal","zombie","slime",
    "demon","bandit","pirate","soldier","guard","raider","cult",
    "minion","spawn","hostile","troll","goblin","orc","undead",
    "skeleton","ghost","dragon","wolf","bear","spider","snake",
    "robot","drone","alien","mutant","thief","criminal","villain",
    "killer","stalker","hunter","predator","attacker","invader"
}
local function getMobRef(m)
    return m:FindFirstChild("HumanoidRootPart")
        or m:FindFirstChild("Torso")
        or m:FindFirstChild("UpperTorso")
        or m:FindFirstChild("LowerTorso")
        or m:FindFirstChild("Head")
        or m.PrimaryPart
end
local function isMobModel(m)
    if not m:IsA("Model") then return false end
    for _, p in ipairs(P:GetPlayers()) do
        if p.Character == m then return false end
    end
    local h = m:FindFirstChildOfClass("Humanoid")
    if h and h.Health <= 0 then return false end
    local hasHumanoid = h ~= nil
    local hasAnimCtrl = m:FindFirstChildOfClass("AnimationController") ~= nil
    local hasRef = getMobRef(m) ~= nil
    if not (hasHumanoid or hasAnimCtrl or hasRef) then return false end
    local name = m.Name:lower()
    for _, kw in ipairs(MOB_KEYWORDS) do
        if name:find(kw, 1, true) then return true end
    end
    local par = m.Parent
    if par and par ~= W then
        local pn = par.Name:lower()
        for _, kw in ipairs(MOB_KEYWORDS) do
            if pn:find(kw, 1, true) then return true end
        end
        local par2 = par.Parent
        if par2 and par2 ~= W then
            local pn2 = par2.Name:lower()
            for _, kw in ipairs(MOB_KEYWORDS) do
                if pn2:find(kw, 1, true) then return true end
            end
        end
    end
    return false
end
local function scanMobsDeep(root, depth, maxDepth, out)
    if depth > maxDepth then return end
    for _, obj in ipairs(root:GetChildren()) do
        if obj:IsA("Model") then
            if isMobModel(obj) then table.insert(out, obj) end
        elseif obj:IsA("Folder") then
            scanMobsDeep(obj, depth+1, maxDepth, out)
        end
    end
end
local function scanMobs()
    local found = {}
    scanMobsDeep(W, 0, 3, found)
    return found
end

-- ============================================
-- ESP ITEM
-- ============================================
local ITEM_KEYWORDS = {
    "coin","coins","money","cash","gem","gems","diamond","diamonds",
    "fruit","fruits","bloxfruit","berry","berries",
    "key","keys","chest","chests","crate","crates","box","boxes",
    "weapon","weapons","sword","swords","gun","guns","bow","arrow",
    "tool","tools","item","items","drop","drops","loot",
    "potion","potions","food","meat","bread","apple","banana",
    "crystal","crystals","ore","ores","gold","silver","iron",
    "orb","orbs","shard","shards","stone","stones",
    "star","stars","badge","badges","ticket","tickets",
    "pickup","pickups","collectible","collectibles",
    "token","tokens","seed","seeds","egg","eggs",
    "reward","rewards","prize","prizes","bone","bones",
    "soul","souls","scale","scales","fang","fangs",
    "feather","feathers","hide","leather","cloth","wood",
    "log","logs","ingot","ingots","bar","bars","nugget","nuggets",
    "ammo","bullet","bullets","medkit","medicine","bandage"
}
local ITEM_FOLDER_KEYWORDS = {
    "item","items","loot","drops","drop","pickup","pickups",
    "collectible","collectibles","resource","resources",
    "spawn","spawns","spawner","spawners","reward","rewards",
    "chest","chests","crate","crates","coin","coins",
    "gem","gems","fruit","fruits","tool","tools","weapon","weapons",
    "backpack","inventory","storage","cargo","supply","supplies",
    "treasure","treasures","money","cash","currency","scrap","debris"
}
local ITEM_EXCLUDE = {
    "baseplate","base","floor","ground","terrain","wall","walls",
    "spawn","spawnlocation","spawn_location","checkpoint","lobby",
    "trigger","zone","region","barrier","boundary","invisible",
    "part","parts","block","blocks","platform","platforms",
    "door","doors","window","windows","roof","ceiling","pillar"
}
local function nameMatches(name, list)
    if not name then return false end
    local n = name:lower()
    for _, kw in ipairs(list) do
        if n == kw then return true end
        if n:find(kw, 1, true) then
            if #kw >= 4 then return true end
            if n == kw or n:find("^"..kw.."[_%-%d]") or n:find("[_%-]"..kw.."$") then
                return true
            end
        end
    end
    return false
end
local function isExcludedName(name)
    if not name then return false end
    local n = name:lower()
    for _, kw in ipairs(ITEM_EXCLUDE) do
        if n == kw then return true end
    end
    return false
end
local function isPartOfCharacterOrMob(obj)
    local ancestor = obj
    local guard = 0
    while ancestor and ancestor ~= W and guard < 10 do
        guard = guard + 1
        if ancestor:IsA("Model") then
            for _, p in ipairs(P:GetPlayers()) do
                if p.Character == ancestor then return true end
            end
            if ancestor:FindFirstChildOfClass("Humanoid") then return true end
            if ancestor:FindFirstChildOfClass("AnimationController") then return true end
        end
        ancestor = ancestor.Parent
    end
    return false
end
local function passesPhysicalFilter(part)
    if not part:IsA("BasePart") then return false end
    if part.Anchored ~= true then return false end
    if part.CanCollide == true then return false end
    if part.Size.Magnitude > 40 then return false end
    if part.Transparency >= 0.95 then return false end
    return true
end
local function isItemPart(part, parentModel)
    if not part:IsA("BasePart") then return false end
    if isPartOfCharacterOrMob(part) then return false end
    if isExcludedName(part.Name) then return false end
    if nameMatches(part.Name, ITEM_KEYWORDS) then return true end
    local par = part.Parent
    local guard = 0
    while par and par ~= W and guard < 4 do
        guard = guard + 1
        if nameMatches(par.Name, ITEM_FOLDER_KEYWORDS) then return true end
        if par:IsA("Model") and nameMatches(par.Name, ITEM_KEYWORDS) then return true end
        par = par.Parent
    end
    if C.ESPItemSmart and parentModel then
        local parts = {}
        for _, c in ipairs(parentModel:GetChildren()) do
            if c:IsA("BasePart") then table.insert(parts, c) end
        end
        if #parts >= 1 and #parts <= 8 then
            local allPass = true
            for _, c in ipairs(parts) do
                if not passesPhysicalFilter(c) then allPass = false break end
            end
            if allPass then return true end
        end
    end
    return false
end
local function getItemRef(obj)
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    end
    return nil
end
local function scanItemsDeep(root, depth, maxDepth, out)
    if depth > maxDepth then return end
    for _, obj in ipairs(root:GetChildren()) do
        if obj:IsA("Model") then
            local hasItemPart = false
            for _, c in ipairs(obj:GetChildren()) do
                if c:IsA("BasePart") and isItemPart(c, obj) then
                    hasItemPart = true
                    break
                end
            end
            if hasItemPart then table.insert(out, obj) end
            scanItemsDeep(obj, depth+1, maxDepth, out)
        elseif obj:IsA("BasePart") then
            if isItemPart(obj, obj) then table.insert(out, obj) end
        elseif obj:IsA("Folder") then
            scanItemsDeep(obj, depth+1, maxDepth, out)
        end
    end
end
local function scanItems()
    local found = {}
    scanItemsDeep(W, 0, 4, found)
    return found
end

-- ============================================
-- KEY GUI
-- ============================================
local function keyGui(cb)
    local PG = LP:WaitForChild("PlayerGui")
    local o = PG:FindFirstChild("anhkey") if o then o:Destroy() end
    local g = Instance.new("ScreenGui")
    g.Name,g.ResetOnSpawn,g.IgnoreGuiInset,g.DisplayOrder,g.Parent = "anhkey",false,true,2147483647,PG
    local f = Instance.new("Frame",g)
    f.Size,f.Position,f.BackgroundColor3 = UDim2.new(0,300,0,200),UDim2.new(0.5,-150,0.5,-100),Color3.fromRGB(0,20,40)
    Instance.new("UICorner",f).CornerRadius = UDim.new(0,10)
    local s = Instance.new("UIStroke",f) s.Color,s.Thickness = Color3.new(0,0.78,1),2
    local t = Instance.new("TextLabel",f)
    t.Size,t.BackgroundColor3,t.BorderSizePixel = UDim2.new(1,0,0,36),Color3.fromRGB(0,40,80),0
    t.Text,t.TextColor3,t.Font,t.TextSize = "🔑 ánh hub — nhập key",Color3.new(0,0.78,1),Enum.Font.GothamBold,13
    Instance.new("UICorner",t).CornerRadius = UDim.new(0,10)
    local i = Instance.new("TextBox",f)
    i.Size,i.Position,i.BackgroundColor3 = UDim2.new(1,-30,0,36),UDim2.new(0,15,0,50),Color3.fromRGB(10,30,60)
    i.PlaceholderText,i.Text,i.TextColor3,i.PlaceholderColor3 = "ANH-DZ-XXXXXXXXXXXX","",Color3.new(1,1,1),Color3.fromRGB(100,100,140)
    i.Font,i.TextSize,i.ClearTextOnFocus = Enum.Font.Gotham,13,false
    Instance.new("UICorner",i).CornerRadius = UDim.new(0,6)
    local st = Instance.new("TextLabel",f)
    st.Size,st.Position,st.BackgroundTransparency = UDim2.new(1,-20,0,20),UDim2.new(0,10,0,92),1
    st.Text,st.TextColor3,st.Font,st.TextSize = "",Color3.new(1,0.3,0.3),Enum.Font.Gotham,11
    local info = Instance.new("TextLabel",f)
    info.Size,info.Position,info.BackgroundTransparency = UDim2.new(1,-20,0,20),UDim2.new(0,10,0,112),1
    info.Text,info.TextColor3,info.Font,info.TextSize = "Key do admin cấp",Color3.fromRGB(120,140,160),Enum.Font.Gotham,10
    local b = Instance.new("TextButton",f)
    b.Size,b.Position,b.BackgroundColor3 = UDim2.new(1,-30,0,36),UDim2.new(0,15,0,140),Color3.fromRGB(0,80,120)
    b.Text,b.TextColor3,b.Font,b.TextSize = "XÁC NHẬN",Color3.new(1,1,1),Enum.Font.GothamBold,13
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,6)
    local function try()
        local k = i.Text:gsub("%s+",""):upper()
        if not KEYS[k] then
            st.TextColor3=Color3.new(1,0.3,0.3) st.Text="❌ key không hợp lệ" i.Text="" return
        end
        local hwcheck = HWIDFor(k)
        if hwcheck == "mismatch" then
            st.TextColor3=Color3.new(1,0.3,0.3) st.Text="❌ key đã dùng hết thiết bị" i.Text="" return
        end
        if HWIDCheck()=="mismatch" then
            st.TextColor3=Color3.new(1,0.3,0.3) st.Text="❌ key dùng thiết bị khác" i.Text="" return
        end
        st.TextColor3=Color3.new(0,1,0.3)
        st.Text="✅ hợp lệ"
        task.wait(0.4) g:Destroy() saveKey(k) cb()
    end
    b.MouseButton1Click:Connect(try)
    i.FocusLost:Connect(function(e) if e then try() end end)
end

-- ============================================
-- IMMORTAL
-- ============================================
local grabbedParts = {}
local lastVel = Vector3.new(0,0,0)
local lastTp, lastHeal = 0, 0
local function hrp(c) return c and c:FindFirstChild("HumanoidRootPart") end
local function hum(c) return c and c:FindFirstChildOfClass("Humanoid") end
local function applyNoclipImm()
    local c = LP.Character
    if not c then return end
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") and p.CanCollide then
            grabbedParts[p] = true
            p.CanCollide = false
        end
    end
end
local function clearNoclipImm()
    for p in pairs(grabbedParts) do
        if p and p.Parent then pcall(function() p.CanCollide = true end) end
    end
    grabbedParts = {}
end
local function clearGrabConstraints()
    if not C.IMM_AntiGrab then return end
    local c = LP.Character
    if not c then return end
    for _, obj in ipairs(c:GetDescendants()) do
        if obj:IsA("Constraint") and obj.Name:lower():find("grab",1,true) then
            pcall(function() obj:Destroy() end)
        end
    end
end
local function applyAntiKnockback()
    if not C.IMM_AntiKnockback then return end
    local root = hrp(LP.Character)
    if not root then return end
    local v = root.AssemblyLinearVelocity
    local horiz = Vector3.new(v.X, 0, v.Z).Magnitude
    if horiz > 80 then
        root.AssemblyLinearVelocity = Vector3.new(lastVel.X*0.3, v.Y, lastVel.Z*0.3)
    else
        lastVel = Vector3.new(v.X, 0, v.Z)
    end
end
local function applyAntiStun()
    if not C.IMM_AntiStun then return end
    local h = hum(LP.Character)
    if not h then return end
    if h.PlatformStand then h.PlatformStand = false end
    if h.Sit then h.Sit = false end
    if h.WalkSpeed == 0 then h.WalkSpeed = 16 end
end
local function emergencyTeleport()
    if not C.IMM_TeleportOnLowHP then return end
    local root = hrp(LP.Character)
    local h = hum(LP.Character)
    if not root or not h then return end
    local pct = (h.Health / h.MaxHealth) * 100
    if pct > C.IMM_LowHPThreshold then return end
    if tick() - lastTp < 2 then return end
    lastTp = tick()
    local ang = math.random() * math.pi * 2
    root.CFrame = root.CFrame + Vector3.new(
        math.cos(ang) * C.IMM_TeleportDistance,
        30,
        math.sin(ang) * C.IMM_TeleportDistance
    )
end
local function emergencyHeal()
    if not C.IMM_AutoHeal then return end
    local c = LP.Character
    local h = hum(c)
    if not h then return end
    local pct = (h.Health / h.MaxHealth) * 100
    if pct > C.IMM_HealThreshold then return end
    if tick() - lastHeal < 0.3 then return end
    lastHeal = tick()
    local backpack = LP:FindFirstChild("Backpack")
    if not backpack or not c then return end
    for _, item in ipairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            local n = item.Name:lower()
            if n:find("fruit",1,true) or n:find("food",1,true)
               or n:find("potion",1,true) or n:find("heal",1,true) then
                pcall(function()
                    item.Parent = c
                    task.wait(0.05)
                    item:Activate()
                    task.wait(0.05)
                    item.Parent = backpack
                end)
                break
            end
        end
    end
end
local function immortalTick()
    if not C.IMM_Enabled then
        if next(grabbedParts) then clearNoclipImm() end
        return
    end
    applyNoclipImm()
    clearGrabConstraints()
    applyAntiKnockback()
    applyAntiStun()
    emergencyTeleport()
    emergencyHeal()
end

-- ============================================
-- TOOL
-- ============================================
local function runTool()
    local T,M,I = {},{},{}
    local Saved = {}
    local fU,fD = false,false
    local hrp2 = function(c) return c and c:FindFirstChild("HumanoidRootPart") end
    LP.CharacterAdded:Connect(function() Saved={} grabbedParts={} end)
    local lastMobScan = 0
    local mobCache = {}
    local lastItemScan = 0
    local itemCache = {}

    R.Heartbeat:Connect(function(dt)
        local cam = W.CurrentCamera
        if not cam then return end
        if dt>0.1 then dt=0.1 end
        pcall(immortalTick)

        for _,p in pairs(P:GetPlayers()) do
            if p~=LP then
                local c = p.Character
                local h = c and hrp2(c)
                local t = T[p]
                local hum2 = c and c:FindFirstChildOfClass("Humanoid")
                if not C.ESPPlayer or not h or not hum2 or hum2.Health<=0 then
                    if t then
                        pcall(function() t.hl:Destroy() end)
                        if t.bb then pcall(function() t.bb:Destroy() end) end
                        T[p]=nil
                    end
                elseif not t then
                    local tm=(p.Team and LP.Team and p.Team==LP.Team)
                    local col = tm and Color3.new(0,0.78,1) or Color3.new(1,0.23,0.23)
                    local hl=Instance.new("Highlight",c)
                    hl.FillColor=col hl.OutlineColor=col hl.FillTransparency=0.5
                    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                    local bb=Instance.new("BillboardGui",c)
                    bb.Size=UDim2.new(0,180,0,50) bb.StudsOffset=Vector3.new(0,3,0) bb.AlwaysOnTop=true
                    local n=Instance.new("TextLabel",bb)
                    n.Size=UDim2.new(1,0,0,22) n.BackgroundTransparency=1 n.TextColor3=col
                    n.TextStrokeTransparency=0 n.Font=Enum.Font.GothamBold n.TextScaled=true
                    local d=Instance.new("TextLabel",bb)
                    d.Size=UDim2.new(1,0,0,18) d.Position=UDim2.new(0,0,0,22)
                    d.BackgroundTransparency=1 d.TextColor3=Color3.new(1,0.84,0)
                    d.TextStrokeTransparency=0 d.Font=Enum.Font.Gotham d.TextScaled=true
                    T[p]={hl=hl,bb=bb,n=n,d=d}
                else
                    local dist=(h.Position-cam.CFrame.Position).Magnitude
                    local tm=(p.Team and LP.Team and p.Team==LP.Team)
                    local col = tm and Color3.new(0,0.78,1) or Color3.new(1,0.23,0.23)
                    t.hl.FillColor=col t.hl.OutlineColor=col
                    if C.ESPName then t.n.TextColor3=col t.n.Text=(p.DisplayName or p.Name)..(tm and " [Đội]" or "")
                    else t.n.Text="" end
                    if C.ESPDist then t.d.Text=math.floor(dist).." st" else t.d.Text="" end
                    local vis=dist<=C.MaxDist
                    t.hl.Enabled=vis t.bb.Enabled=vis
                end
            end
        end

        if C.ESPMob then
            if tick() - lastMobScan > 1.5 then
                lastMobScan = tick()
                mobCache = scanMobs()
            end
            local seen = {}
            for _, m in ipairs(mobCache) do
                if m.Parent then
                    seen[m] = true
                    if not M[m] then
                        local hl = Instance.new("Highlight", m)
                        hl.FillColor = Color3.new(1,0.55,0)
                        hl.OutlineColor = Color3.new(1,0.55,0)
                        hl.FillTransparency = 0.5
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        local bb = Instance.new("BillboardGui", m)
                        bb.Size = UDim2.new(0,160,0,20)
                        bb.StudsOffset = Vector3.new(0, 3, 0)
                        bb.AlwaysOnTop = true
                        local n = Instance.new("TextLabel", bb)
                        n.Size = UDim2.new(1,0,1,0)
                        n.BackgroundTransparency = 1
                        n.TextColor3 = Color3.new(1,0.55,0)
                        n.TextStrokeTransparency = 0
                        n.Font = Enum.Font.GothamBold
                        n.TextScaled = true
                        M[m] = {hl=hl, bb=bb, n=n}
                    end
                end
            end
            for m, data in pairs(M) do
                if not seen[m] or not m.Parent then
                    pcall(function() data.hl:Destroy() end)
                    if data.bb then pcall(function() data.bb:Destroy() end) end
                    M[m] = nil
                else
                    local ref = getMobRef(m)
                    if ref then
                        local dist = (ref.Position - cam.CFrame.Position).Magnitude
                        if C.ESPMobName then
                            data.n.Text = m.Name.." ["..math.floor(dist).." st]"
                        else
                            data.n.Text = ""
                        end
                        local vis = dist <= C.MaxDist
                        data.hl.Enabled = vis
                        data.bb.Enabled = vis
                    end
                end
            end
        elseif next(M) then
            for m, data in pairs(M) do
                pcall(function() data.hl:Destroy() end)
                if data.bb then pcall(function() data.bb:Destroy() end) end
                M[m] = nil
            end
        end

        if C.ESPItem then
            if tick() - lastItemScan > 1.5 then
                lastItemScan = tick()
                itemCache = scanItems()
            end
            local seen = {}
            for _, it in ipairs(itemCache) do
                if it.Parent then
                    seen[it] = true
                    if not I[it] then
                        local ref = getItemRef(it)
                        if ref then
                            local hl = Instance.new("Highlight", it)
                            hl.FillColor = Color3.new(0,1,0.5)
                            hl.OutlineColor = Color3.new(0,1,0.5)
                            hl.FillTransparency = 0.5
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            local bb = Instance.new("BillboardGui", it)
                            bb.Size = UDim2.new(0,160,0,20)
                            bb.StudsOffset = Vector3.new(0, 3, 0)
                            bb.AlwaysOnTop = true
                            local n = Instance.new("TextLabel", bb)
                            n.Size = UDim2.new(1,0,1,0)
                            n.BackgroundTransparency = 1
                            n.TextColor3 = Color3.new(0,1,0.5)
                            n.TextStrokeTransparency = 0
                            n.Font = Enum.Font.GothamBold
                            n.TextScaled = true
                            I[it] = {hl=hl, bb=bb, n=n}
                        end
                    end
                end
            end
            for it, data in pairs(I) do
                if not seen[it] or not it.Parent then
                    pcall(function() data.hl:Destroy() end)
                    if data.bb then pcall(function() data.bb:Destroy() end) end
                    I[it] = nil
                else
                    local ref = getItemRef(it)
                    if ref then
                        local dist = (ref.Position - cam.CFrame.Position).Magnitude
                        if C.ESPItemName then
                            data.n.Text = it.Name.." ["..math.floor(dist).." st]"
                        else
                            data.n.Text = ""
                        end
                        local vis = dist <= C.ESPItemMaxDist
                        data.hl.Enabled = vis
                        data.bb.Enabled = vis
                    end
                end
            end
        elseif next(I) then
            for it, data in pairs(I) do
                pcall(function() data.hl:Destroy() end)
                if data.bb then pcall(function() data.bb:Destroy() end) end
                I[it] = nil
            end
        end

        if C.Fly then
            local c=LP.Character
            local root=c and hrp2(c)
            local hum2=c and c:FindFirstChildOfClass("Humanoid")
            if root and hum2 then
                local v=root.AssemblyLinearVelocity
                root.AssemblyLinearVelocity=Vector3.new(v.X,0,v.Z)
                local md=hum2.MoveDirection
                if md.Magnitude>0.01 then
                    root.CFrame=root.CFrame+md.Unit*C.FlySpeed*dt
                end
                if fU or U:IsKeyDown(Enum.KeyCode.Space) then
                    root.CFrame=root.CFrame+Vector3.new(0,1,0)*C.FlySpeed*dt
                end
                if fD or U:IsKeyDown(Enum.KeyCode.LeftShift) then
                    root.CFrame=root.CFrame-Vector3.new(0,1,0)*C.FlySpeed*dt
                end
            end
        end

        if C.Noclip then
            local c=LP.Character
            if c then
                for _,p in pairs(c:GetDescendants()) do
                    if p:IsA("BasePart") and p.CanCollide then
                        Saved[p]=true p.CanCollide=false
                    end
                end
            end
        elseif next(Saved) then
            for p in pairs(Saved) do
                if p and p.Parent then pcall(function() p.CanCollide=true end) end
            end
            Saved={}
        end

        local hum2=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum2 then
            if C.Speed then
                if hum2.WalkSpeed~=C.RunSpeed then hum2.WalkSpeed=C.RunSpeed end
            else
                if hum2.WalkSpeed~=16 then hum2.WalkSpeed=16 end
            end
        end
    end)

    if not LP.Character then LP.CharacterAdded:Wait() end
    task.wait(1)
    local PG=LP:WaitForChild("PlayerGui")
    local o=PG:FindFirstChild("anhhub") if o then o:Destroy() end

    local gui=Instance.new("ScreenGui")
    gui.Name,gui.ResetOnSpawn,gui.IgnoreGuiInset,gui.DisplayOrder,gui.Parent="anhhub",false,true,999999,PG

    local logo=Instance.new("TextButton",gui)
    logo.Size,logo.AnchorPoint,logo.Position=UDim2.new(0,90,0,90),Vector2.new(0.5,0.5),UDim2.new(0.5,0,0.5,0)
    logo.BackgroundColor3,logo.Text,logo.TextColor3,logo.Font,logo.TextSize=Color3.new(0,0,0),"ánh hub",Color3.new(0,0.78,1),Enum.Font.GothamBlack,12
    Instance.new("UICorner",logo).CornerRadius=UDim.new(1,0)
    local stk=Instance.new("UIStroke",logo) stk.Color,stk.Thickness=Color3.new(0,0.78,1),2

    local menu=Instance.new("ScrollingFrame",gui)
    menu.Size,menu.Position,menu.BackgroundColor3,menu.BorderSizePixel=UDim2.new(0,250,0,480),UDim2.new(0,20,0,100),Color3.fromRGB(0,20,40),0
    menu.Visible,menu.Active,menu.ScrollBarThickness,menu.ScrollBarImageColor3=false,false,8,Color3.new(0,0.78,1)
    menu.CanvasSize,menu.AutomaticCanvasSize=UDim2.new(0,0,0,1900),Enum.AutomaticSize.None
    Instance.new("UICorner",menu).CornerRadius=UDim.new(0,10)
    local lay=Instance.new("UIListLayout",menu)
    lay.SortOrder,lay.Padding,lay.HorizontalAlignment=Enum.SortOrder.LayoutOrder,UDim.new(0,4),Enum.HorizontalAlignment.Center
    local pd=Instance.new("UIPadding",menu)
    pd.PaddingTop,pd.PaddingLeft,pd.PaddingRight,pd.PaddingBottom=UDim.new(0,6),UDim.new(0,6),UDim.new(0,6),UDim.new(0,6)

    local infoBar = Instance.new("TextLabel",menu)
    infoBar.Size = UDim2.new(1,0,0,30)
    infoBar.LayoutOrder = -100
    infoBar.BackgroundColor3 = Color3.fromRGB(0,60,120)
    infoBar.BorderSizePixel = 0
    infoBar.Text = "⏱ "..(RAM.currentKey or "?").." — "..remainText()
    infoBar.TextColor3 = Color3.fromRGB(0,220,255)
    infoBar.Font = Enum.Font.GothamBold
    infoBar.TextSize = 11
    infoBar.TextWrapped = true
    Instance.new("UICorner", infoBar).CornerRadius = UDim.new(0,6)

    task.spawn(function()
        while infoBar.Parent do
            task.wait(15)
            pcall(function()
                infoBar.Text = "⏱ "..(RAM.currentKey or "?").." — "..remainText()
                if RAM.currentKey and expired(RAM.currentKey) then
                    clearKey()
                    infoBar.Text = "⏱ key hết hạn — nhập lại"
                end
            end)
        end
    end)

    local function tg(l,k,colorOn)
        local b=Instance.new("TextButton",menu)
        local onCol = colorOn or Color3.fromRGB(0,60,120)
        b.Size,b.BackgroundColor3,b.TextColor3,b.Font,b.TextSize,b.TextXAlignment=
            UDim2.new(1,0,0,36),
            C[k] and onCol or Color3.fromRGB(10,30,60),
            Color3.new(0,0.78,1),Enum.Font.Gotham,12,Enum.TextXAlignment.Left
        b.Text="  "..l.." : "..(C[k] and "BẬT" or "TẮT")
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
        b.MouseButton1Click:Connect(function()
            C[k]=not C[k]
            b.Text="  "..l.." : "..(C[k] and "BẬT" or "TẮT")
            b.BackgroundColor3=C[k] and onCol or Color3.fromRGB(10,30,60)
        end)
    end
    tg("Định vị người chơi","ESPPlayer")
    tg("Hiện tên","ESPName")
    tg("Hiện khoảng cách","ESPDist")
    tg("Định vị quái (scan động)","ESPMob")
    tg("Hiện tên quái","ESPMobName")

    local itemHeader = Instance.new("TextLabel",menu)
    itemHeader.Size = UDim2.new(1,0,0,28)
    itemHeader.BackgroundColor3 = Color3.fromRGB(0,100,50)
    itemHeader.BorderSizePixel = 0
    itemHeader.Text = "📦 ĐỊNH VỊ ĐỒ"
    itemHeader.TextColor3 = Color3.fromRGB(0.5,1,0.6)
    itemHeader.Font = Enum.Font.GothamBold
    itemHeader.TextSize = 12
    Instance.new("UICorner", itemHeader).CornerRadius = UDim.new(0,6)

    tg("BẬT ĐỊNH VỊ ĐỒ","ESPItem",Color3.fromRGB(0,120,60))
    tg("Hiện tên đồ","ESPItemName",Color3.fromRGB(0,100,50))
    tg("Lọc thông minh","ESPItemSmart",Color3.fromRGB(0,140,80))

    tg("Bay đa hướng","Fly")
    tg("Xuyên tường (noclip)","Noclip")
    tg("Chạy nhanh","Speed")

    local immHeader = Instance.new("TextLabel",menu)
    immHeader.Size = UDim2.new(1,0,0,28)
    immHeader.BackgroundColor3 = Color3.fromRGB(0,80,40)
    immHeader.BorderSizePixel = 0
    immHeader.Text = "🛡 BẤT TỬ / ANTI-DEATH"
    immHeader.TextColor3 = Color3.fromRGB(0.5,1,0.5)
    immHeader.Font = Enum.Font.GothamBold
    immHeader.TextSize = 12
    Instance.new("UICorner", immHeader).CornerRadius = UDim.new(0,6)

    tg("BẬT BẤT TỬ","IMM_Enabled",Color3.fromRGB(0,120,40))
    tg("Anti-Grab","IMM_AntiGrab",Color3.fromRGB(0,80,40))
    tg("Anti-Knockback","IMM_AntiKnockback",Color3.fromRGB(0,80,40))
    tg("Anti-Stun","IMM_AntiStun",Color3.fromRGB(0,80,40))
    tg("Teleport khi HP thấp","IMM_TeleportOnLowHP",Color3.fromRGB(0,80,40))
    tg("Auto-Heal khẩn cấp","IMM_AutoHeal",Color3.fromRGB(0,80,40))

    local function sl(l,k,mn,mx,col)
        local s=Instance.new("Frame",menu)
        s.Size,s.BackgroundColor3=UDim2.new(1,0,0,46),Color3.fromRGB(10,30,60)
        Instance.new("UICorner",s).CornerRadius=UDim.new(0,6)
        local lb=Instance.new("TextLabel",s)
        lb.Size,lb.Position,lb.BackgroundTransparency,lb.Text=UDim2.new(1,-10,0,18),UDim2.new(0,8,0,2),1,l..": "..C[k]
        lb.TextColor3,lb.Font,lb.TextSize,lb.TextXAlignment=Color3.new(0,0.78,1),Enum.Font.Gotham,12,Enum.TextXAlignment.Left
        local bar=Instance.new("Frame",s)
        bar.Size,bar.Position,bar.BackgroundColor3=UDim2.new(1,-20,0,6),UDim2.new(0,10,0,28),Color3.fromRGB(30,60,90)
        Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)
        local fl=Instance.new("Frame",bar)
        fl.Size,fl.BackgroundColor3=UDim2.new((C[k]-mn)/(mx-mn),0,1,0),col
        Instance.new("UICorner",fl).CornerRadius=UDim.new(1,0)
        local dr=false
        bar.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dr=true end
        end)
        U.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dr=false end
        end)
        U.InputChanged:Connect(function(i)
            if dr and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                local r=math.clamp((i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
                C[k]=math.floor(mn+(mx-mn)*r) fl.Size=UDim2.new(r,0,1,0) lb.Text=l..": "..C[k]
            end
        end)
    end
    sl("Tốc độ bay","FlySpeed",50,3000,Color3.new(0,0.78,1))
    sl("Tốc độ chạy","RunSpeed",16,1000,Color3.new(0,1,0.5))
    sl("Khoảng cách ESP","MaxDist",100,5000,Color3.new(1,0.6,0))
    sl("Khoảng cách đồ","ESPItemMaxDist",100,5000,Color3.new(0,1,0.5))
    sl("Ngưỡng HP thấp (%)","IMM_LowHPThreshold",5,90,Color3.new(0.5,1,0.5))
    sl("Khoảng cách teleport","IMM_TeleportDistance",30,500,Color3.new(0.5,1,0.5))
    sl("Ngưỡng tự hồi máu (%)","IMM_HealThreshold",30,100,Color3.new(0.5,1,0.5))

    local bU=Instance.new("TextButton",gui)
    bU.Size,bU.Position,bU.BackgroundColor3=UDim2.new(0,55,0,55),UDim2.new(1,-75,0,200),Color3.fromRGB(0,120,80)
    bU.Text,bU.TextColor3,bU.TextSize,bU.Font="↑",Color3.new(1,1,1),26,Enum.Font.GothamBold
    Instance.new("UICorner",bU).CornerRadius=UDim.new(1,0)
    local bD=Instance.new("TextButton",gui)
    bD.Size,bD.Position,bD.BackgroundColor3=UDim2.new(0,55,0,55),UDim2.new(1,-75,0,265),Color3.fromRGB(120,40,60)
    bD.Text,bD.TextColor3,bD.TextSize,bD.Font="↓",Color3.new(1,1,1),26,Enum.Font.GothamBold
    Instance.new("UICorner",bD).CornerRadius=UDim.new(1,0)
    bU.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then fU=true end
    end)
    bU.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then fU=false end
    end)
    bD.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then fD=true end
    end)
    bD.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then fD=false end
    end)

    local dr,s0,o0,mv=false,nil,nil,false
    logo.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dr,mv=true,false s0=Vector2.new(logo.AbsolutePosition.X,logo.AbsolutePosition.Y) o0=s0
        end
    end)
    U.InputChanged:Connect(function(i)
        if dr and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local dx,dy=i.Position.X-s0.X,i.Position.Y-s0.Y
            if math.abs(dx)>4 or math.abs(dy)>4 then mv=true end
            logo.Position=UDim2.new(0,o0.X+dx,0,o0.Y+dy)
        end
    end)
    U.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dr=false end
    end)
    logo.MouseButton1Click:Connect(function()
        if mv then return end
        menu.Visible=not menu.Visible menu.Active=menu.Visible
    end)

    -- DOI KEY
    local swap = Instance.new("TextButton", menu)
    swap.Size, swap.BackgroundColor3 = UDim2.new(1,0,0,36), Color3.fromRGB(120,80,0)
    swap.Text, swap.TextColor3, swap.Font, swap.TextSize, swap.TextXAlignment =
        "  🔄 Đổi key", Color3.new(1,0.75,0), Enum.Font.GothamBold, 12, Enum.TextXAlignment.Left
    Instance.new("UICorner", swap).CornerRadius = UDim.new(0,6)
    swap.MouseButton1Click:Connect(function()
        local PG2 = LP:WaitForChild("PlayerGui")
        local o2 = PG2:FindFirstChild("swapgui") if o2 then o2:Destroy() end
        local g = Instance.new("ScreenGui")
        g.Name,g.ResetOnSpawn,g.IgnoreGuiInset,g.DisplayOrder,g.Parent = "swapgui",false,true,2147483647,PG2
        local f = Instance.new("Frame",g)
        f.Size,f.Position,f.BackgroundColor3 = UDim2.new(0,300,0,180),UDim2.new(0.5,-150,0.5,-90),Color3.fromRGB(0,20,40)
        Instance.new("UICorner",f).CornerRadius = UDim.new(0,10)
        local fs = Instance.new("UIStroke",f) fs.Color,fs.Thickness = Color3.new(1,0.6,0),2
        local t = Instance.new("TextLabel",f)
        t.Size,t.BackgroundColor3,t.BorderSizePixel = UDim2.new(1,0,0,36),Color3.fromRGB(80,40,0),0
        t.Text,t.TextColor3,t.Font,t.TextSize = "🔄 Đổi key",Color3.new(1,0.75,0),Enum.Font.GothamBold,13
        Instance.new("UICorner",t).CornerRadius = UDim.new(0,10)
        local cl = Instance.new("TextButton",f)
        cl.Size,cl.Position,cl.BackgroundColor3 = UDim2.new(0,26,0,26),UDim2.new(1,-30,0,5),Color3.fromRGB(180,50,50)
        cl.Text,cl.TextColor3,cl.Font,cl.TextSize,cl.ZIndex = "X",Color3.new(1,1,1),Enum.Font.GothamBold,13,5
        Instance.new("UICorner",cl).CornerRadius = UDim.new(0,6)
        cl.MouseButton1Click:Connect(function() g:Destroy() end)
        local i = Instance.new("TextBox",f)
        i.Size,i.Position,i.BackgroundColor3 = UDim2.new(1,-30,0,36),UDim2.new(0,15,0,60),Color3.fromRGB(10,30,60)
        i.PlaceholderText = "nhập key mới..."
        i.Text,i.TextColor3,i.PlaceholderColor3 = "",Color3.new(1,1,1),Color3.fromRGB(100,100,140)
        i.Font,i.TextSize,i.ClearTextOnFocus = Enum.Font.Gotham,13,false
        Instance.new("UICorner",i).CornerRadius = UDim.new(0,6)
        local b = Instance.new("TextButton",f)
        b.Size,b.Position,b.BackgroundColor3 = UDim2.new(1,-30,0,36),UDim2.new(0,15,0,110),Color3.fromRGB(120,80,0)
        b.Text,b.TextColor3,b.Font,b.TextSize = "XÁC NHẬN",Color3.new(1,1,1),Enum.Font.GothamBold,13
        Instance.new("UICorner",b).CornerRadius = UDim.new(0,6)
        local st = Instance.new("TextLabel",f)
        st.Size,st.Position,st.BackgroundTransparency = UDim2.new(1,-20,0,20),UDim2.new(0,10,0,150),1
        st.Text,st.TextColor3,st.Font,st.TextSize = "",Color3.new(1,0.3,0.3),Enum.Font.Gotham,11
        b.MouseButton1Click:Connect(function()
            local k = i.Text:gsub("%s+",""):upper()
            if not KEYS[k] then st.TextColor3=Color3.new(1,0.3,0.3) st.Text="❌ key không hợp lệ" return end
            local hwcheck = HWIDFor(k)
            if hwcheck == "mismatch" then st.TextColor3=Color3.new(1,0.3,0.3) st.Text="❌ key đã dùng hết thiết bị" return end
            saveKey(k)
            st.TextColor3 = Color3.new(0,1,0.3) st.Text = "✅ đã đổi key"
            task.wait(0.5) g:Destroy()
        end)
    end)

    -- ADMIN PANEL
    local ap = Instance.new("TextButton", menu)
    ap.Size, ap.BackgroundColor3 = UDim2.new(1,0,0,36), Color3.fromRGB(120,0,80)
    ap.Text, ap.TextColor3, ap.Font, ap.TextSize, ap.TextXAlignment =
        "  ⚙ Admin (reset/tạo key)", Color3.new(1,0.6,0.8), Enum.Font.GothamBold, 12, Enum.TextXAlignment.Left
    Instance.new("UICorner", ap).CornerRadius = UDim.new(0,6)
    ap.MouseButton1Click:Connect(function()
        local PG2 = LP:WaitForChild("PlayerGui")
        local o2 = PG2:FindFirstChild("admingui") if o2 then o2:Destroy() end
        local g = Instance.new("ScreenGui")
        g.Name,g.ResetOnSpawn,g.IgnoreGuiInset,g.DisplayOrder,g.Parent = "admingui",false,true,2147483646,PG2
        local f = Instance.new("Frame",g)
        f.Size,f.Position,f.BackgroundColor3 = UDim2.new(0,340,0,240),UDim2.new(0.5,-170,0.5,-120),Color3.fromRGB(20,0,40)
        Instance.new("UICorner",f).CornerRadius = UDim.new(0,10)
        local fs = Instance.new("UIStroke",f) fs.Color,fs.Thickness = Color3.new(1,0,0.5),2
        local t = Instance.new("TextLabel",f)
        t.Size,t.BackgroundColor3,t.BorderSizePixel = UDim2.new(1,0,0,36),Color3.fromRGB(60,0,40),0
        t.Text,t.TextColor3,t.Font,t.TextSize = "⚙ Admin Panel",Color3.new(1,0.3,0.6),Enum.Font.GothamBold,13
        Instance.new("UICorner",t).CornerRadius = UDim.new(0,10)
        local cl = Instance.new("TextButton",f)
        cl.Size,cl.Position,cl.BackgroundColor3 = UDim2.new(0,26,0,26),UDim2.new(1,-30,0,5),Color3.fromRGB(180,50,50)
        cl.Text,cl.TextColor3,cl.Font,cl.TextSize,cl.ZIndex = "X",Color3.new(1,1,1),Enum.Font.GothamBold,13,5
        Instance.new("UICorner",cl).CornerRadius = UDim.new(0,6)
        cl.MouseButton1Click:Connect(function() g:Destroy() end)
        local i = Instance.new("TextBox",f)
        i.Size,i.Position,i.BackgroundColor3 = UDim2.new(1,-30,0,36),UDim2.new(0,15,0,50),Color3.fromRGB(10,30,60)
        i.PlaceholderText,i.Text = "admin key...",""
        i.TextColor3,i.PlaceholderColor3 = Color3.new(1,1,1),Color3.fromRGB(100,100,140)
        i.Font,i.TextSize,i.ClearTextOnFocus = Enum.Font.Gotham,13,false
        Instance.new("UICorner",i).CornerRadius = UDim.new(0,6)
        local sv = loadAdmin()
        if sv then i.Text = sv end
        local st = Instance.new("TextLabel",f)
        st.Size,st.Position,st.BackgroundTransparency = UDim2.new(1,-20,0,20),UDim2.new(0,10,0,92),1
        st.Text,st.TextColor3,st.Font,st.TextSize = "",Color3.new(1,0.3,0.3),Enum.Font.Gotham,11
        local b = Instance.new("TextButton",f)
        b.Size,b.Position,b.BackgroundColor3 = UDim2.new(1,-30,0,36),UDim2.new(0,15,0,140),Color3.fromRGB(120,0,80)
        b.Text,b.TextColor3,b.Font,b.TextSize = "XÁC NHẬN ADMIN",Color3.new(1,1,1),Enum.Font.GothamBold,13
        Instance.new("UICorner",b).CornerRadius = UDim.new(0,6)
        b.MouseButton1Click:Connect(function()
            local k = i.Text:gsub("%s+",""):upper()
            if not isAdminKey(k) then
                st.TextColor3=Color3.new(1,0.3,0.3) st.Text="❌ sai admin" i.Text="" return
            end
            if adminHWIDCheck()=="mismatch" then
                st.TextColor3=Color3.new(1,0.3,0.3) st.Text="❌ admin dùng máy khác" i.Text="" return
            end
            saveAdmin(k)
            st.TextColor3=Color3.new(0,1,0.3) st.Text="✅ admin OK"
            task.wait(0.4) g:Destroy()

            local g2 = Instance.new("ScreenGui")
            g2.Name,g2.ResetOnSpawn,g2.IgnoreGuiInset,g2.DisplayOrder,g2.Parent = "adminfullgui",false,true,2147483645,PG2

            local f2 = Instance.new("ScrollingFrame",g2)
            f2.Size = UDim2.new(0,360,0,520)
            f2.Position = UDim2.new(0.5,-180,0.5,-260)
            f2.BackgroundColor3 = Color3.fromRGB(20,0,40)
            f2.BorderSizePixel = 0
            f2.ScrollBarThickness = 8
            f2.ScrollBarImageColor3 = Color3.new(1,0.3,0.6)
            f2.CanvasSize = UDim2.new(0,0,0,900)
            f2.ScrollingDirection = Enum.ScrollingDirection.Y
            f2.ClipsDescendants = true
            f2.Active = true
            Instance.new("UICorner",f2).CornerRadius = UDim.new(0,10)
            local fs2 = Instance.new("UIStroke",f2) fs2.Color,fs2.Thickness = Color3.new(1,0,0.5),2

            local t2 = Instance.new("TextLabel",f2)
            t2.Size,t2.Position,t2.BackgroundColor3,t2.BorderSizePixel =
                UDim2.new(1,0,0,36),UDim2.new(0,0,0,0),Color3.fromRGB(60,0,40),0
            t2.Text,t2.TextColor3,t2.Font,t2.TextSize = "📋 Quản lý key",Color3.new(1,0.3,0.6),Enum.Font.GothamBold,12
            Instance.new("UICorner",t2).CornerRadius = UDim.new(0,10)

            local cl2 = Instance.new("TextButton",f2)
            cl2.Size,cl2.Position,cl2.BackgroundColor3 = UDim2.new(0,26,0,26),UDim2.new(1,-30,0,5),Color3.fromRGB(180,50,50)
            cl2.Text,cl2.TextColor3,cl2.Font,cl2.TextSize,cl2.ZIndex = "X",Color3.new(1,1,1),Enum.Font.GothamBold,13,5
            Instance.new("UICorner",cl2).CornerRadius = UDim.new(0,6)
            cl2.MouseButton1Click:Connect(function() g2:Destroy() end)

            local nLbl = Instance.new("TextLabel",f2)
            nLbl.Size,nLbl.Position,nLbl.BackgroundTransparency = UDim2.new(1,-20,0,18),UDim2.new(0,10,0,44),1
            nLbl.Text,nLbl.TextColor3,nLbl.Font,nLbl.TextSize,nLbl.TextXAlignment =
                "Ghi chú key (không bắt buộc):",Color3.new(0,0.78,1),Enum.Font.Gotham,11,Enum.TextXAlignment.Left
            local ni = Instance.new("TextBox",f2)
            ni.Size,ni.Position,ni.BackgroundColor3 = UDim2.new(1,-20,0,32),UDim2.new(0,10,0,62),Color3.fromRGB(10,30,60)
            ni.PlaceholderText,ni.Text = "VD: cho Nam",""
            ni.TextColor3,ni.PlaceholderColor3 = Color3.new(1,1,1),Color3.fromRGB(100,100,140)
            ni.Font,ni.TextSize,ni.ClearTextOnFocus = Enum.Font.Gotham,12,false
            Instance.new("UICorner",ni).CornerRadius = UDim.new(0,6)

            local otCheck = Instance.new("TextButton",f2)
            otCheck.Size,otCheck.Position,otCheck.BackgroundColor3 = UDim2.new(1,-20,0,28),UDim2.new(0,10,0,96),Color3.fromRGB(10,30,60)
            otCheck.Text,otCheck.TextColor3,otCheck.Font,otCheck.TextSize = "  [ ] Key 1 lần / 1 thiết bị",Color3.new(0.7,0.7,0.7),Enum.Font.Gotham,11
            otCheck.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner",otCheck).CornerRadius = UDim.new(0,6)
            local otEnabled = false
            otCheck.MouseButton1Click:Connect(function()
                otEnabled = not otEnabled
                otCheck.Text = "  ["..(otEnabled and "X" or " ").."] Key 1 lần / 1 thiết bị"
                otCheck.TextColor3 = otEnabled and Color3.new(0,1,0.5) or Color3.new(0.7,0.7,0.7)
            end)

            local opts = {
                {l="1 giờ",            e={hours=1},   admin=false},
                {l="1 ngày",           e={days=1},    admin=false},
                {l="1 tuần",           e={weeks=1},   admin=false},
                {l="1 tháng",          e={months=1},  admin=false},
                {l="1 năm",            e={months=12}, admin=false},
                {l="VIP vĩnh viễn",    e={days=9999}, admin=false},
                {l="ADMIN vĩnh viễn",  e={days=9999}, admin=true},
            }
            local sel = opts[1]

            local db = Instance.new("TextButton",f2)
            db.Size,db.Position,db.BackgroundColor3 = UDim2.new(1,-20,0,30),UDim2.new(0,10,0,128),Color3.fromRGB(0,40,80)
            db.Text,db.TextColor3,db.Font,db.TextSize = "  "..sel.l.."  ▾",Color3.new(0,0.78,1),Enum.Font.Gotham,11
            db.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner",db).CornerRadius = UDim.new(0,6)

            local dl
            db.MouseButton1Click:Connect(function()
                if dl then dl:Destroy() dl=nil return end
                dl = Instance.new("Frame",f2)
                dl.Size,dl.Position,dl.BackgroundColor3 = UDim2.new(1,-20,0,#opts*26),UDim2.new(0,10,0,160),Color3.fromRGB(10,20,40)
                dl.ZIndex = 6
                Instance.new("UICorner",dl).CornerRadius = UDim.new(0,6)
                Instance.new("UIListLayout",dl)
                for _,o in ipairs(opts) do
                    local ob = Instance.new("TextButton",dl)
                    ob.Size,ob.BackgroundTransparency,ob.Text = UDim2.new(1,0,0,26),1,"  "..o.l
                    ob.TextColor3,ob.Font,ob.TextSize,ob.TextXAlignment,ob.ZIndex =
                        o.admin and Color3.new(1,0.5,0.8) or Color3.new(0,0.78,1),
                        Enum.Font.Gotham,11,Enum.TextXAlignment.Left,7
                    ob.MouseButton1Click:Connect(function()
                        sel = o db.Text = "  "..o.l.."  ▾"
                        if dl then dl:Destroy() dl=nil end
                    end)
                end
            end)

            local cb = Instance.new("TextButton",f2)
            cb.Size,cb.Position,cb.BackgroundColor3 = UDim2.new(1,-20,0,32),UDim2.new(0,10,0,164),Color3.fromRGB(0,100,60)
            cb.Text,cb.TextColor3,cb.Font,cb.TextSize = "TẠO KEY",Color3.new(1,1,1),Enum.Font.GothamBold,12
            Instance.new("UICorner",cb).CornerRadius = UDim.new(0,6)

            local cs = Instance.new("TextLabel",f2)
            cs.Size,cs.Position,cs.BackgroundTransparency = UDim2.new(1,-20,0,80),UDim2.new(0,10,0,202),1
            cs.Text,cs.TextColor3,cs.Font,cs.TextSize,cs.TextWrapped,cs.TextXAlignment = "",Color3.new(0,1,0.3),Enum.Font.Gotham,10,true,Enum.TextXAlignment.Left

            cb.MouseButton1Click:Connect(function()
                local note = ni.Text:gsub("%s+","")
                local newK
                if sel.admin then
                    if note=="" then cs.TextColor3=Color3.new(1,0.3,0.3) cs.Text="❌ admin key cần ghi chú tên" return end
                    newK = "ADMIN-"..note:upper()
                else
                    newK = genKey()
                end
                if KEYS[newK] then cs.TextColor3=Color3.new(1,0.3,0.3) cs.Text="❌ key tồn tại, thử lại" return end
                if newK==ADMIN_KEY_1 or newK==ADMIN_KEY_2 then cs.TextColor3=Color3.new(1,0.3,0.3) cs.Text="❌ trùng admin gốc" return end
                if sel.admin then
                    ADMIN_KEYS_EXTRA[newK] = true
                end
                local keyEntry = sel.e
                if otEnabled and not sel.admin then
                    keyEntry.oneTime = true
                    keyEntry.maxSlots = 1
                    if not RAM.custom then RAM.custom = {} end
                    RAM.custom[newK] = {days=(sel.e.days or 0), hwid="", slots={}}
                end
                KEYS[newK] = keyEntry
                if not otEnabled then
                    if not RAM.custom then RAM.custom = {} end
                    RAM.custom[newK] = {days=(sel.e.days or 0), hwid=HWID(), slots={}}
                end
                cs.TextColor3=Color3.new(0,1,0.3)
                cs.Text = (sel.admin and "✅ ADMIN KEY: " or (otEnabled and "✅ ONE-TIME KEY: " or "✅ KEY: ")).."\n"..newK.."\nHạn: "..sel.l
                ni.Text = ""
            end)

            local lLbl = Instance.new("TextLabel",f2)
            lLbl.Size,lLbl.Position,lLbl.BackgroundTransparency = UDim2.new(1,-20,0,18),UDim2.new(0,10,0,290),1
            lLbl.Text,lLbl.TextColor3,lLbl.Font,lLbl.TextSize,lLbl.TextXAlignment =
                "Danh sách key (bấm để reset / +1 slot):",Color3.new(0,0.78,1),Enum.Font.Gotham,11,Enum.TextXAlignment.Left

            local list = Instance.new("Frame",f2)
            list.Size,list.Position = UDim2.new(1,-20,0,440),UDim2.new(0,10,0,312)
            list.BackgroundTransparency = 1
            local listLay = Instance.new("UIListLayout",list)
            listLay.Padding = UDim.new(0,3)

            for keyStr, e in pairs(KEYS) do
                local tag = ""
                if isAdminKey(keyStr) then tag = "[ADMIN] "
                elseif isOneTime(keyStr) then tag = "[1-TIME] "
                elseif e.days and e.days>=9999 then tag = "[VIP] "
                end
                local label = tag..keyStr.." — "
                if e.days and e.days>=9999 then label = label.."vĩnh viễn"
                elseif e.hours then label = label..e.hours.."h"
                elseif e.days then label = label..e.days.."n"
                elseif e.weeks then label = label..e.weeks.."w"
                elseif e.months then label = label..e.months.."m" end
                if isOneTime(keyStr) then
                    local slots = getSlots(keyStr)
                    label = label.." ("..#slots.."/"..getMaxSlots(keyStr).." tb)"
                end
                local kb = Instance.new("TextButton",list)
                kb.Size = UDim2.new(1,-5,0,26)
                if tag=="[ADMIN] " then kb.BackgroundColor3 = Color3.fromRGB(80,0,60)
                elseif tag=="[1-TIME] " then kb.BackgroundColor3 = Color3.fromRGB(0,60,60)
                else kb.BackgroundColor3 = Color3.fromRGB(0,40,80) end
                kb.Text = "  "..label
                if tag=="[ADMIN] " then kb.TextColor3 = Color3.new(1,0.6,0.9)
                elseif tag=="[1-TIME] " then kb.TextColor3 = Color3.new(0.5,1,1)
                else kb.TextColor3 = Color3.new(0,0.78,1) end
                kb.Font,kb.TextSize,kb.TextXAlignment = Enum.Font.Gotham,10,Enum.TextXAlignment.Left
                Instance.new("UICorner",kb).CornerRadius = UDim.new(0,4)
                kb.MouseButton1Click:Connect(function()
                    if not RAM.custom then RAM.custom = {} end
                    if isOneTime(keyStr) then
                        if not RAM.custom[keyStr] then RAM.custom[keyStr] = {days=0, hwid="", slots={}} end
                        if not RAM.custom[keyStr].slots then RAM.custom[keyStr].slots = {} end
                        table.insert(RAM.custom[keyStr].slots, "")
                        local n = #RAM.custom[keyStr].slots
                        cs.TextColor3=Color3.new(0,1,0.3)
                        cs.Text="✅ Key "..keyStr.." +1 slot (tổng "..n..")"
                    else
                        if RAM.custom[keyStr] then RAM.custom[keyStr].hwid = "" end
                        cs.TextColor3=Color3.new(0,1,0.3)
                        cs.Text="✅ Đã reset HWID "..keyStr
                    end
                end)
            end

            task.defer(function()
                local total = 312 + 30
                for _ in pairs(KEYS) do total = total + 29 end
                f2.CanvasSize = UDim2.new(0,0,0,math.max(900,total))
            end)
        end)
    end)
end

-- ============================================
-- CHAY
-- ============================================
local existingKey = loadKey()
if existingKey then
    runTool()
else
    keyGui(function()
        runTool()
    end)
end
