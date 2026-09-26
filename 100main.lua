-- language: Lua, file: 67main.lua, target: Roblox Mobile (executor)
-- ============================================================
-- CROWN MENU FULL v6 — admin auth vĩnh viễn trong session
-- ============================================================
-- Admin: ADMIN-1 / ADMIN-2
-- Vĩnh viễn: ANHDZ-2012-Kx9@mP!vQ7#L / ANHDZ-2012-Zt4$nB&wR6^M
-- 1 giờ:  ANHDZ-2012-Yh7%cF*eD3!J
-- 1 ngày: ANHDZ-2012-Lm2@qA#pV8$N
-- 1 tuần: ANHDZ-2012-Wg5^rT!kS9&X
-- 1 tháng:ANHDZ-2012-Ub3*zE%jH6@Q
-- 1 năm:  ANHDZ-2012-Pk8!vY$oC4^R
-- ============================================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace  = game:GetService("Workspace")
local UIS        = game:GetService("UserInputService")
local Camera     = Workspace.CurrentCamera
local LP         = Players.LocalPlayer

-- FILESYSTEM
local function fsWrite(name, data)
    if writefile then pcall(writefile, name, data) end
end
local function fsRead(name)
    if isfile and readfile and isfile(name) then
        local ok, d = pcall(readfile, name)
        if ok then return d end
    end
    return nil
end

-- DEVICE ID
local function getDeviceId()
    local id = fsRead("crown_device.txt")
    if id and #id > 0 then return id end
    local seed = ""
    pcall(function() seed = seed .. tostring(game.JobId or "") end)
    pcall(function() seed = seed .. tostring(game.PlaceId or "") end)
    pcall(function() seed = seed .. tostring(LP.UserId or "") end)
    pcall(function() seed = seed .. tostring(UIS.TouchEnabled) end)
    pcall(function() seed = seed .. tostring(UIS.KeyboardEnabled) end)
    pcall(function() seed = seed .. tostring(UIS.GamepadEnabled) end)
    local hash = 5381
    for i = 1, #seed do
        hash = ((hash * 33) + seed:byte(i)) % 0x7FFFFFFF
    end
    local idStr = string.format("DEV-%08X", hash)
    fsWrite("crown_device.txt", idStr)
    return idStr
end
local DEVICE_ID = getDeviceId()

-- KEY SYSTEM
local KEY_FILE = "crown_keys.txt"

local ADMIN_KEYS = {
    ["ADMIN-1"] = true,
    ["ADMIN-2"] = true,
}

local PERM_KEYS = {
    ["ANHDZ-2012-Kx9@mP!vQ7#L"] = true,
    ["ANHDZ-2012-Zt4$nB&wR6^M"] = true,
}

local TIMED_KEYS = {
    ["ANHDZ-2012-Yh7%cF*eD3!J"] = 3600,
    ["ANHDZ-2012-Lm2@qA#pV8$N"] = 86400,
    ["ANHDZ-2012-Wg5^rT!kS9&X"] = 604800,
    ["ANHDZ-2012-Ub3*zE%jH6@Q"] = 2592000,
    ["ANHDZ-2012-Pk8!vY$oC4^R"] = 31536000,
}

local function loadKeys()
    local data = fsRead(KEY_FILE)
    local keys = {}
    if not data then return keys end
    for line in data:gmatch("[^\r\n]+") do
        local key, dev, exp, dur, orig = line:match("^([^|]+)|([^|]*)|([^|]*)|([^|]*)|([^|]*)$")
        if key then
            keys[key] = {
                device = dev or "",
                expire = tonumber(exp) or 0,
                duration = dur or "",
                originalSec = tonumber(orig) or 0,
            }
        end
    end
    return keys
end

local function saveKeys(keys)
    local lines = {}
    for k, v in pairs(keys) do
        table.insert(lines, string.format("%s|%s|%d|%s|%d",
            k, v.device, v.expire, v.duration, v.originalSec or 0))
    end
    fsWrite(KEY_FILE, table.concat(lines, "\n"))
end

local function randomKey()
    local chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
    local out = {}
    for i = 1, 12 do
        local idx = math.random(1, #chars)
        table.insert(out, chars:sub(idx, idx))
    end
    return table.concat(out)
end

local function durationLabel(sec)
    if sec == 3600 then return "1 giờ" end
    if sec == 86400 then return "1 ngày" end
    if sec == 604800 then return "1 tuần" end
    if sec == 2592000 then return "1 tháng" end
    if sec == 31536000 then return "1 năm" end
    return tostring(sec) .. "s"
end

-- CHECK KEY — admin và perm bind device
local function checkKey(keyInput)
    print("[KEY CHECK]", keyInput, "len:", #keyInput)

    if ADMIN_KEYS[keyInput] then
        local keys = loadKeys()
        local entry = keys[keyInput]

        if not entry then
            keys[keyInput] = {
                device      = DEVICE_ID,
                expire      = 0,
                duration    = "ADMIN",
                originalSec = 0,
            }
            saveKeys(keys)
            return true, "ADMIN", 0
        end
        if entry.device ~= "" and entry.device ~= DEVICE_ID then
            return false, "Key admin đã gắn thiết bị khác"
        end
        if entry.device == "" then
            entry.device = DEVICE_ID
            keys[keyInput] = entry
            saveKeys(keys)
        end
        return true, "ADMIN", 0
    end

    if PERM_KEYS[keyInput] then
        local keys = loadKeys()
        local entry = keys[keyInput]

        if not entry then
            keys[keyInput] = {
                device      = DEVICE_ID,
                expire      = 0,
                duration    = "PERM",
                originalSec = 0,
            }
            saveKeys(keys)
            return true, "PERM", 0
        end
        if entry.device ~= "" and entry.device ~= DEVICE_ID then
            return false, "Key vĩnh viễn đã gắn thiết bị khác"
        end
        if entry.device == "" then
            entry.device = DEVICE_ID
            keys[keyInput] = entry
            saveKeys(keys)
        end
        return true, "PERM", 0
    end

    local keys = loadKeys()
    local entry = keys[keyInput]

    if TIMED_KEYS[keyInput] and not entry then
        keys[keyInput] = {
            device      = DEVICE_ID,
            expire      = os.time() + TIMED_KEYS[keyInput],
            duration    = durationLabel(TIMED_KEYS[keyInput]),
            originalSec = TIMED_KEYS[keyInput],
        }
        saveKeys(keys)
        return true, durationLabel(TIMED_KEYS[keyInput]), keys[keyInput].expire
    end

    if not entry then
        return false, "Key không tồn tại"
    end
    if entry.expire > 0 and os.time() > entry.expire then
        return false, "Key đã hết hạn"
    end
    if entry.device == "" then
        entry.device = DEVICE_ID
        keys[keyInput] = entry
        saveKeys(keys)
    elseif entry.device ~= DEVICE_ID then
        return false, "Key đã dùng trên thiết bị khác"
    end
    return true, entry.duration, entry.expire
end

-- RESET KEY — admin và perm cũng reset được
local function resetKey(keyInput)
    local keys = loadKeys()
    local entry = keys[keyInput]

    if ADMIN_KEYS[keyInput] then
        if not entry then
            return false, "Key admin chưa được dùng — không cần reset"
        end
        entry.device      = ""
        entry.expire      = 0
        entry.originalSec = 0
        entry.duration    = "ADMIN"
        keys[keyInput]    = entry
        saveKeys(keys)
        return true, "Đã reset key admin — dùng được trên máy mới"
    end

    if PERM_KEYS[keyInput] then
        if not entry then
            return false, "Key vĩnh viễn chưa được dùng — không cần reset"
        end
        entry.device      = ""
        entry.expire      = 0
        entry.originalSec = 0
        entry.duration    = "PERM"
        keys[keyInput]    = entry
        saveKeys(keys)
        return true, "Đã reset key vĩnh viễn — dùng được trên máy mới"
    end

    if TIMED_KEYS[keyInput] then
        if not entry then
            return false, "Key chưa được dùng — không cần reset"
        end
        local originalSec = entry.originalSec
        if not originalSec or originalSec <= 0 then
            originalSec = TIMED_KEYS[keyInput]
        end
        entry.device      = ""
        entry.expire      = os.time() + originalSec
        entry.originalSec = originalSec
        entry.duration    = durationLabel(originalSec)
        keys[keyInput]    = entry
        saveKeys(keys)
        return true, "Đã reset — hạn mới: " .. durationLabel(originalSec)
    end

    if not entry then
        return false, "Key không tồn tại"
    end

    local originalSec = entry.originalSec
    if not originalSec or originalSec <= 0 then
        originalSec = 86400
    end

    entry.device      = ""
    entry.expire      = os.time() + originalSec
    entry.originalSec = originalSec
    keys[keyInput]    = entry
    saveKeys(keys)

    return true, "Đã reset — hạn mới: " .. durationLabel(originalSec)
end

local ACTIVE_FILE = "crown_active.txt"

local function saveActiveKey(key)
    fsWrite(ACTIVE_FILE, key .. "|" .. DEVICE_ID)
end

local function loadActiveKey()
    local data = fsRead(ACTIVE_FILE)
    if not data then return nil end
    local key, dev = data:match("^([^|]+)|([^|]+)$")
    if key and dev == DEVICE_ID then return key end
    return nil
end

local function clearActiveKey()
    fsWrite(ACTIVE_FILE, "")
end

-- CONFIG
local cfg = {
    espMob        = true,
    espPlayer     = true,
    highlight     = true,
    showBox       = true,
    showName      = true,
    showDistance  = true,
    showHealth    = true,
    showTracer    = true,
    maxDist       = 2000,
    fillColor     = Color3.fromRGB(255, 60, 60),
    outlineColor  = Color3.fromRGB(255, 0, 0),
    nameColor     = Color3.fromRGB(255, 220, 100),
    distColor     = Color3.fromRGB(255, 255, 255),
    boxColor      = Color3.fromRGB(255, 60, 60),
    healthColor   = Color3.fromRGB(0, 255, 100),
    tracerColor   = Color3.fromRGB(255, 255, 255),
    excludeNames  = {
        ["Terrain"] = true, ["Camera"] = true, ["Baseplate"] = true,
        ["SpawnLocation"] = true, ["Ignore"] = true, ["Debris"] = true,
    },
    minParts        = 1,
    catchLooseParts = true,
    skipAnchored    = false,

    fly            = false,
    flySpeed       = 80,
    verticalSpeed  = 80,
    camDirection   = true,
    flyNoclip      = true,
}

-- STATE
local myChar, myHrp
local flyBV, flyBG
local moveVec, lookVec = Vector2.zero, Vector2.zero
local tracked = {}
local flyUpHeld, flyDownHeld = false, false

local function onChar(char)
    myChar = char
    myHrp  = char:WaitForChild("HumanoidRootPart", 5)
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end
end
if LP.Character then onChar(LP.Character) end
LP.CharacterAdded:Connect(onChar)

-- ESP HELPERS
local function isPlayerChar(inst)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == inst then return true end
    end
    return false
end

local function isExcluded(name)
    for k in pairs(cfg.excludeNames) do
        if name == k or name:find(k, 1, true) then return true end
    end
    return false
end

local function countParts(inst)
    local n = 0
    for _, c in ipairs(inst:GetChildren()) do
        if c:IsA("BasePart") then n = n + 1 end
    end
    return n
end

local function getBounds(inst)
    local minV, maxV
    local targets = inst:IsA("BasePart") and {inst} or inst:GetDescendants()
    for _, c in ipairs(targets) do
        if c:IsA("BasePart") and c.Transparency < 1 then
            local pos, half = c.Position, c.Size * 0.5
            local mn, mx = pos - half, pos + half
            if not minV then
                minV, maxV = mn, mx
            else
                minV = Vector3.new(math.min(minV.X, mn.X), math.min(minV.Y, mn.Y), math.min(minV.Z, mn.Z))
                maxV = Vector3.new(math.max(maxV.X, mx.X), math.max(maxV.Y, mx.Y), math.max(maxV.Z, mx.Z))
            end
        end
    end
    return minV, maxV
end

local function w2s(pos)
    local sp, on = Camera:WorldToViewportPoint(pos)
    return Vector2.new(sp.X, sp.Y), on
end

local function getHealth(inst)
    local hum = inst:FindFirstChildOfClass("Humanoid")
    if hum then return hum.Health, hum.MaxHealth end
    return nil, nil
end

local function getDisplayName(inst)
    if inst:IsA("Model") and isPlayerChar(inst) then
        local plr = Players:GetPlayerFromCharacter(inst)
        if plr then return plr.Name end
    end
    return inst.Name
end

local function isMob(inst)
    if inst == LP.Character then return false end
    if isPlayerChar(inst) then return false end
    if isExcluded(inst.Name) then return false end
    if not inst.Parent then return false end

    if inst:IsA("Model") then
        if countParts(inst) < cfg.minParts then return false end
        if cfg.skipAnchored then
            local allAnchored = true
            for _, c in ipairs(inst:GetChildren()) do
                if c:IsA("BasePart") and not c.Anchored then
                    allAnchored = false break
                end
            end
            if allAnchored then return false end
        end
        return true
    end

    if inst:IsA("BasePart") and cfg.catchLooseParts then
        if inst.Anchored and cfg.skipAnchored then return false end
        return true
    end

    return false
end

local function isPlayer(inst)
    if inst == LP.Character then return false end
    return isPlayerChar(inst)
end

local function makeVisuals(inst)
    local v = {}
    local hl = Instance.new("Highlight")
    hl.FillColor = cfg.fillColor
    hl.OutlineColor = cfg.outlineColor
    hl.FillTransparency = 0.6
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = inst
    hl.Parent = inst
    v.hl = hl

    v.name = Drawing.new("Text")
    v.name.Size = 14; v.name.Center = true; v.name.Outline = true
    v.name.Color = cfg.nameColor; v.name.Visible = false

    v.dist = Drawing.new("Text")
    v.dist.Size = 13; v.dist.Center = true; v.dist.Outline = true
    v.dist.Color = cfg.distColor; v.dist.Visible = false

    v.hp = Drawing.new("Text")
    v.hp.Size = 12; v.hp.Center = true; v.hp.Outline = true
    v.hp.Color = cfg.healthColor; v.hp.Visible = false

    v.box = Drawing.new("Square")
    v.box.Thickness = 1; v.box.Filled = false; v.box.Transparency = 1
    v.box.Color = cfg.boxColor; v.box.Visible = false

    v.hpBarBg = Drawing.new("Line")
    v.hpBarBg.Thickness = 4; v.hpBarBg.Color = Color3.fromRGB(30, 30, 30)
    v.hpBarBg.Visible = false

    v.hpBar = Drawing.new("Line")
    v.hpBar.Thickness = 4; v.hpBar.Color = cfg.healthColor
    v.hpBar.Visible = false

    v.tracer = Drawing.new("Line")
    v.tracer.Thickness = 1; v.tracer.Color = cfg.tracerColor; v.tracer.Visible = false

    tracked[inst] = v
end

local function destroyVisuals(inst)
    if tracked[inst] then
        local v = tracked[inst]
        if v.hl then pcall(function() v.hl:Destroy() end) end
        for _, o in ipairs({v.name, v.dist, v.hp, v.box, v.hpBarBg, v.hpBar, v.tracer}) do
            if o then pcall(function() o:Remove() end) end
        end
        tracked[inst] = nil
    end
end

local function scanAll()
    local found = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local shouldTrack = false
        if cfg.espMob and isMob(obj) then shouldTrack = true end
        if cfg.espPlayer and isPlayer(obj) then shouldTrack = true end
        if shouldTrack then
            found[obj] = true
            if not tracked[obj] then makeVisuals(obj) end
        end
    end
    for inst in pairs(tracked) do
        if not found[inst] or not inst.Parent then destroyVisuals(inst) end
    end
end

task.spawn(function()
    while task.wait(1.5) do
        pcall(scanAll)
    end
end)

Workspace.DescendantAdded:Connect(function(desc)
    if desc:IsA("Model") or desc:IsA("BasePart") then
        task.wait(0.1)
        if desc.Parent and not tracked[desc] then
            if (cfg.espMob and isMob(desc)) or (cfg.espPlayer and isPlayer(desc)) then
                makeVisuals(desc)
            end
        end
    end
end)

-- FLY
local function startFly()
    if not myHrp then return end
    if flyBV then flyBV:Destroy() end
    if flyBG then flyBG:Destroy() end
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = myHrp
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flyBG.P = 1000; flyBG.D = 50
    flyBG.CFrame = myHrp.CFrame
    flyBG.Parent = myHrp
end

local function stopFly()
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end
end

local function applyNoclip()
    if not myChar then return end
    for _, p in ipairs(myChar:GetDescendants()) do
        if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
    end
end

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
    if cfg.fly and myHrp then
        if not flyBV then startFly() end
        local dir = Vector3.zero
        if cfg.camDirection then
            local cf = Camera.CFrame
            dir = dir + cf.LookVector * (-moveVec.Y)
            dir = dir + cf.RightVector * moveVec.X
        else
            local cf = myHrp.CFrame
            dir = dir + cf.LookVector * (-moveVec.Y)
            dir = dir + cf.RightVector * moveVec.X
        end
        local vy = 0
        if flyUpHeld then vy = vy + 1 end
        if flyDownHeld then vy = vy - 1 end
        vy = vy - lookVec.Y
        dir = dir + Vector3.new(0, vy, 0)

        if dir.Magnitude > 1 then dir = dir.Unit end
        flyBV.Velocity = Vector3.new(dir.X, 0, dir.Z) * cfg.flySpeed
                       + Vector3.new(0, dir.Y, 0) * cfg.verticalSpeed
        if flyBG then
            flyBG.CFrame = CFrame.new(myHrp.Position, myHrp.Position + Camera.CFrame.LookVector)
        end
        if cfg.flyNoclip then applyNoclip() end
    elseif flyBV then
        stopFly()
    end

    if not myChar then myChar = LP.Character end
    local hrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)

    for inst, v in pairs(tracked) do
        if not inst.Parent then
            if v.hl then v.hl.Enabled = false end
            for _, o in ipairs({v.name, v.dist, v.hp, v.box, v.hpBarBg, v.hpBar, v.tracer}) do
                o.Visible = false
            end
            continue
        end

        local rootPos
        if inst:IsA("BasePart") then
            rootPos = inst.Position
        else
            local p = inst:FindFirstChild("HumanoidRootPart")
                   or inst:FindFirstChild("Root")
                   or inst:FindFirstChildWhichIsA("BasePart")
            if not p then
                if v.hl then v.hl.Enabled = false end
                for _, o in ipairs({v.name, v.dist, v.hp, v.box, v.hpBarBg, v.hpBar, v.tracer}) do
                    o.Visible = false
                end
                continue
            end
            rootPos = p.Position
        end

        local dist = (hrp.Position - rootPos).Magnitude
        local tooFar = dist > cfg.maxDist

        local isPlyr = isPlayer(inst)
        local color = isPlyr and Color3.fromRGB(100, 200, 255) or cfg.fillColor
        local outline = isPlyr and Color3.fromRGB(0, 150, 255) or cfg.outlineColor

        if v.hl then
            v.hl.Enabled = cfg.highlight and not tooFar
            v.hl.FillColor = color
            v.hl.OutlineColor = outline
        end

        if tooFar then
            for _, o in ipairs({v.name, v.dist, v.hp, v.box, v.hpBarBg, v.hpBar, v.tracer}) do
                o.Visible = false
            end
            continue
        end

        local minV, maxV = getBounds(inst)
        if not minV then
            for _, o in ipairs({v.name, v.dist, v.hp, v.box, v.hpBarBg, v.hpBar, v.tracer}) do
                o.Visible = false
            end
            continue
        end

        local cx = (minV.X + maxV.X) * 0.5
        local cz = (minV.Z + maxV.Z) * 0.5
        local topScr, topOn = w2s(Vector3.new(cx, maxV.Y, cz))
        local botScr, botOn = w2s(Vector3.new(cx, minV.Y, cz))

        if not (topOn and botOn) then
            for _, o in ipairs({v.name, v.dist, v.hp, v.box, v.hpBarBg, v.hpBar, v.tracer}) do
                o.Visible = false
            end
            continue
        end

        local centerX = (topScr.X + botScr.X) * 0.5
        local height = math.abs(botScr.Y - topScr.Y)
        local width = height * 0.6

        if cfg.showBox and height > 4 then
            v.box.Visible = true
            v.box.Size = Vector2.new(width, height)
            v.box.Position = Vector2.new(centerX - width / 2, topScr.Y)
            v.box.Color = outline
        else
            v.box.Visible = false
        end

        if cfg.showName then
            v.name.Visible = true
            v.name.Text = getDisplayName(inst)
            v.name.Color = isPlyr and Color3.fromRGB(150, 220, 255) or cfg.nameColor
            v.name.Position = Vector2.new(centerX, topScr.Y - 18)
        else
            v.name.Visible = false
        end

        if cfg.showDistance then
            v.dist.Visible = true
            v.dist.Text = string.format("[%d]", math.floor(dist))
            v.dist.Position = Vector2.new(centerX, botScr.Y + 4)
        else
            v.dist.Visible = false
        end

        local hp, maxHp = getHealth(inst)
        if cfg.showHealth and hp and maxHp and maxHp > 0 then
            local pct = math.clamp(hp / maxHp, 0, 1)
            v.hp.Visible = true
            v.hp.Text = string.format("%d/%d", math.floor(hp), math.floor(maxHp))
            v.hp.Position = Vector2.new(centerX, botScr.Y + 18)
            v.hp.Color = Color3.fromRGB(
                math.floor(255 * (1 - pct)),
                math.floor(255 * pct),
                60)

            local barX = centerX - width / 2 - 8
            v.hpBarBg.Visible = true
            v.hpBarBg.From = Vector2.new(barX, topScr.Y + height)
            v.hpBarBg.To   = Vector2.new(barX, topScr.Y)

            local barH = height * pct
            v.hpBar.Visible = true
            v.hpBar.From = Vector2.new(barX, topScr.Y + height)
            v.hpBar.To   = Vector2.new(barX, topScr.Y + height - barH)
            v.hpBar.Color = Color3.fromRGB(
                math.floor(255 * (1 - pct)),
                math.floor(255 * pct),
                60)
        else
            v.hp.Visible = false
            v.hpBar.Visible = false
            v.hpBarBg.Visible = false
        end

        if cfg.showTracer then
            v.tracer.Visible = true
            v.tracer.From = center
            v.tracer.To = Vector2.new(centerX, botScr.Y)
            v.tracer.Color = isPlyr and Color3.fromRGB(100, 200, 255) or cfg.tracerColor
        else
            v.tracer.Visible = false
        end
    end
end)

-- BUILD MENU
local function buildMenu(authLevel)
    local gui = Instance.new("ScreenGui")
    gui.Name = "CrownMenu"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 9999
    pcall(function() gui.Parent = game:GetService("CoreGui") end)
    if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

    local DEFAULT_POS = UDim2.new(0, 20, 0, 60)

    local logoLocked = false
    local menuLocked = false

    -- LOGO
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "LogoBtn"
    toggleBtn.Size = UDim2.new(0, 50, 0, 50)
    toggleBtn.Position = DEFAULT_POS
    toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 25, 10)
    toggleBtn.BorderSizePixel = 2
    toggleBtn.BorderColor3 = Color3.fromRGB(255, 215, 0)
    toggleBtn.Text = "👑"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 28
    toggleBtn.AutoButtonColor = false
    toggleBtn.Visible = false
    toggleBtn.Active = true
    toggleBtn.Parent = gui

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0.5, 0)
    tc.Parent = toggleBtn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 215, 0)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3
    stroke.Parent = toggleBtn

    -- FRAME
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 230, 0, 380)
    frame.Position = DEFAULT_POS
    frame.BackgroundColor3 = Color3.fromRGB(15, 18, 25)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Parent = gui

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0, 8)
    fc.Parent = frame

    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = Color3.fromRGB(255, 215, 0)
    frameStroke.Thickness = 1
    frameStroke.Transparency = 0.5
    frameStroke.Parent = frame

    -- TITLE
    local title = Instance.new("Frame")
    title.Name = "TitleBar"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(30, 25, 10)
    title.BorderSizePixel = 0
    title.Parent = frame

    local titleC = Instance.new("UICorner")
    titleC.CornerRadius = UDim.new(0, 8)
    titleC.Parent = title

    local logoLbl = Instance.new("TextLabel")
    logoLbl.Size = UDim2.new(0, 36, 1, 0)
    logoLbl.Position = UDim2.new(0, 4, 0, 0)
    logoLbl.BackgroundTransparency = 1
    logoLbl.Text = "👑"
    logoLbl.TextColor3 = Color3.fromRGB(255, 215, 0)
    logoLbl.Font = Enum.Font.GothamBold
    logoLbl.TextSize = 22
    logoLbl.Parent = title

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -100, 1, 0)
    nameLbl.Position = UDim2.new(0, 42, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = "CROWN"
    nameLbl.TextColor3 = Color3.fromRGB(255, 215, 0)
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 14
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = title

    local lockBtn = Instance.new("TextButton")
    lockBtn.Size = UDim2.new(0, 26, 0, 26)
    lockBtn.Position = UDim2.new(1, -62, 0, 7)
    lockBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    lockBtn.BorderSizePixel = 0
    lockBtn.Text = "🔓"
    lockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    lockBtn.Font = Enum.Font.GothamBold
    lockBtn.TextSize = 13
    lockBtn.AutoButtonColor = false
    lockBtn.Parent = title
    local lockC = Instance.new("UICorner")
    lockC.CornerRadius = UDim.new(0, 5)
    lockC.Parent = lockBtn

    local collapse = Instance.new("TextButton")
    collapse.Size = UDim2.new(0, 26, 0, 26)
    collapse.Position = UDim2.new(1, -32, 0, 7)
    collapse.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
    collapse.BorderSizePixel = 0
    collapse.Text = "−"
    collapse.TextColor3 = Color3.fromRGB(255, 255, 255)
    collapse.Font = Enum.Font.GothamBold
    collapse.TextSize = 16
    collapse.AutoButtonColor = false
    collapse.Parent = title
    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0, 5)
    cc.Parent = collapse

    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "Content"
    scroll.Size = UDim2.new(1, -4, 1, -46)
    scroll.Position = UDim2.new(0, 2, 0, 44)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 8
    scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 215, 0)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ScrollingDirection = Enum.ScrollingDirection.Y
    scroll.ScrollingEnabled = true
    scroll.Active = true
    scroll.ClipsDescendants = true
    scroll.ElasticBehavior = Enum.ElasticBehavior.Never
    scroll.Parent = frame

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 3)
    contentLayout.Parent = scroll

    local contentPad = Instance.new("UIPadding")
    contentPad.PaddingTop = UDim.new(0, 4)
    contentPad.PaddingLeft = UDim.new(0, 4)
    contentPad.PaddingRight = UDim.new(0, 4)
    contentPad.PaddingBottom = UDim.new(0, 8)
    contentPad.Parent = scroll

    local function pointInGui(obj, point)
        local ap, as = obj.AbsolutePosition, obj.AbsoluteSize
        return point.X >= ap.X and point.X <= ap.X + as.X
           and point.Y >= ap.Y and point.Y <= ap.Y + as.Y
    end

    -- DRAG MENU
    local dragging = false
    local dragStart = Vector2.zero
    local startPos = UDim2.new(0, 0, 0, 0)
    local activeTouch = nil

    UIS.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if pointInGui(title, input.Position)
            and not pointInGui(lockBtn, input.Position)
            and not pointInGui(collapse, input.Position) then
                if menuLocked then return end
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                activeTouch = input
            end
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input ~= activeTouch then return end
        if menuLocked then return end
        if input.UserInputType ~= Enum.UserInputType.Touch
        and input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local d = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end)
    UIS.InputEnded:Connect(function(input)
        if dragging and input == activeTouch then
            dragging = false
            activeTouch = nil
        end
    end)

    -- DRAG LOGO + TAP
    local logoDrag = false
    local logoDragStart = Vector2.zero
    local logoStartPos = UDim2.new(0, 0, 0, 0)
    local logoActiveTouch = nil
    local logoMoved = false

    lockBtn.MouseButton1Click:Connect(function()
        logoLocked = not logoLocked
        menuLocked = logoLocked
        lockBtn.Text = logoLocked and "🔒" or "🔓"
        lockBtn.BackgroundColor3 = logoLocked and Color3.fromRGB(150, 40, 40) or Color3.fromRGB(40, 40, 60)
    end)

    UIS.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if toggleBtn.Visible and pointInGui(toggleBtn, input.Position) then
                if logoLocked then
                    logoDrag = false
                    logoActiveTouch = input
                    logoMoved = false
                    logoStartPos = toggleBtn.Position
                    return
                end
                logoDrag = true
                logoDragStart = input.Position
                logoStartPos = toggleBtn.Position
                logoActiveTouch = input
                logoMoved = false
            end
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if not logoDrag then return end
        if logoLocked then return end
        if input ~= logoActiveTouch then return end
        if input.UserInputType ~= Enum.UserInputType.Touch
        and input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local d = input.Position - logoDragStart
        if d.Magnitude > 8 then logoMoved = true end
        toggleBtn.Position = UDim2.new(
            logoStartPos.X.Scale, logoStartPos.X.Offset + d.X,
            logoStartPos.Y.Scale, logoStartPos.Y.Offset + d.Y)
    end)
    UIS.InputEnded:Connect(function(input)
        if logoActiveTouch ~= input then return end
        if logoLocked or not logoMoved then
            frame.Visible = true
            toggleBtn.Visible = false
            frame.Position = toggleBtn.Position
        end
        logoDrag = false
        logoActiveTouch = nil
    end)

    collapse.MouseButton1Click:Connect(function()
        toggleBtn.Position = frame.Position
        frame.Visible = false
        toggleBtn.Visible = true
    end)

    -- UI MAKERS
    local function makeToggle(label, key, onColor)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -4, 0, 30)
        btn.BackgroundColor3 = cfg[key] and (onColor or Color3.fromRGB(140, 100, 20)) or Color3.fromRGB(45, 45, 55)
        btn.BorderSizePixel = 0
        btn.Text = label
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.Parent = scroll
        local bc = Instance.new("UICorner")
        bc.CornerRadius = UDim.new(0, 5)
        bc.Parent = btn
        btn.MouseButton1Click:Connect(function()
            cfg[key] = not cfg[key]
            btn.BackgroundColor3 = cfg[key] and (onColor or Color3.fromRGB(140, 100, 20)) or Color3.fromRGB(45, 45, 55)
        end)
        return btn
    end

    local function makeHeader(text, color)
        local h = Instance.new("TextLabel")
        h.Size = UDim2.new(1, -4, 0, 20)
        h.BackgroundTransparency = 1
        h.Text = text
        h.TextColor3 = color or Color3.fromRGB(255, 215, 0)
        h.Font = Enum.Font.GothamBold
        h.TextSize = 11
        h.TextXAlignment = Enum.TextXAlignment.Left
        h.Parent = scroll
        return h
    end

    local function makeSlider(label, key, min, max)
        local wrap = Instance.new("Frame")
        wrap.Size = UDim2.new(1, -4, 0, 38)
        wrap.BackgroundTransparency = 1
        wrap.Parent = scroll

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 16)
        lbl.BackgroundTransparency = 1
        lbl.Text = label .. ": " .. cfg[key]
        lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = wrap

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1, 0, 0, 20)
        bar.Position = UDim2.new(0, 0, 0, 16)
        bar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        bar.BorderSizePixel = 0
        bar.Parent = wrap
        local barC = Instance.new("UICorner")
        barC.CornerRadius = UDim.new(0, 4)
        barC.Parent = bar

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((cfg[key] - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
        fill.BorderSizePixel = 0
        fill.Parent = bar
        local fillC = Instance.new("UICorner")
        fillC.CornerRadius = UDim.new(0, 4)
        fillC.Parent = fill

        local dragS = false
        local touchS = nil
        local function setFromX(x)
            local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * rel)
            cfg[key] = val
            fill.Size = UDim2.new(rel, 0, 1, 0)
            lbl.Text = label .. ": " .. val
        end

        UIS.InputBegan:Connect(function(i)
            if (i.UserInputType == Enum.UserInputType.Touch
            or i.UserInputType == Enum.UserInputType.MouseButton1)
            and pointInGui(bar, i.Position) then
                dragS = true
                touchS = i
                setFromX(i.Position.X)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragS and i == touchS then setFromX(i.Position.X) end
        end)
        UIS.InputEnded:Connect(function(i)
            if dragS and i == touchS then dragS = false touchS = nil end
        end)
    end

    -- BUILD CONTENT
    makeHeader("◆ ESP")
    makeToggle("ESP Quái", "espMob")
    makeToggle("ESP Người", "espPlayer")
    makeToggle("Highlight", "highlight")
    makeToggle("Box", "showBox")
    makeToggle("Tên", "showName")
    makeToggle("Khoảng cách", "showDistance")
    makeToggle("Số máu", "showHealth")
    makeToggle("Tracer", "showTracer")

    makeHeader("◆ FLY")
    makeToggle("FLY ON/OFF", "fly")
    makeToggle("Xuyên tường", "flyNoclip")

    local dirBtn = Instance.new("TextButton")
    dirBtn.Size = UDim2.new(1, -4, 0, 26)
    dirBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    dirBtn.BorderSizePixel = 0
    dirBtn.Text = cfg.camDirection and "Bay theo Camera" or "Bay theo Nhân vật"
    dirBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    dirBtn.Font = Enum.Font.Gotham
    dirBtn.TextSize = 11
    dirBtn.Parent = scroll
    local dc = Instance.new("UICorner")
    dc.CornerRadius = UDim.new(0, 5)
    dc.Parent = dirBtn
    dirBtn.MouseButton1Click:Connect(function()
        cfg.camDirection = not cfg.camDirection
        dirBtn.Text = cfg.camDirection and "Bay theo Camera" or "Bay theo Nhân vật"
    end)

    makeSlider("Tốc độ bay", "flySpeed", 20, 500)
    makeSlider("Tốc độ lên/xuống", "verticalSpeed", 20, 500)

    -- ADMIN SECTION
    makeHeader("◆ ADMIN")

    local createKeyBtn = Instance.new("TextButton")
    createKeyBtn.Size = UDim2.new(1, -4, 0, 32)
    createKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 60)
    createKeyBtn.BorderSizePixel = 0
    createKeyBtn.Text = "➕ TẠO KEY MỚI"
    createKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    createKeyBtn.Font = Enum.Font.GothamBold
    createKeyBtn.TextSize = 12
    createKeyBtn.Parent = scroll
    local ckb = Instance.new("UICorner")
    ckb.CornerRadius = UDim.new(0, 5)
    ckb.Parent = createKeyBtn

    local changeKeyBtn = Instance.new("TextButton")
    changeKeyBtn.Size = UDim2.new(1, -4, 0, 32)
    changeKeyBtn.BackgroundColor3 = Color3.fromRGB(180, 120, 40)
    changeKeyBtn.BorderSizePixel = 0
    changeKeyBtn.Text = "🔄 ĐỔI KEY (RESET)"
    changeKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    changeKeyBtn.Font = Enum.Font.GothamBold
    changeKeyBtn.TextSize = 12
    changeKeyBtn.Parent = scroll
    local ckb2 = Instance.new("UICorner")
    ckb2.CornerRadius = UDim.new(0, 5)
    ckb2.Parent = changeKeyBtn

    local listKeyBtn = Instance.new("TextButton")
    listKeyBtn.Size = UDim2.new(1, -4, 0, 32)
    listKeyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
    listKeyBtn.BorderSizePixel = 0
    listKeyBtn.Text = "📋 DANH SÁCH KEY"
    listKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    listKeyBtn.Font = Enum.Font.GothamBold
    listKeyBtn.TextSize = 12
    listKeyBtn.Parent = scroll
    local lkb = Instance.new("UICorner")
    lkb.CornerRadius = UDim.new(0, 5)
    lkb.Parent = listKeyBtn

    -- XÁC THỰC ADMIN — 1 lần duy nhất trong session
    local adminVerified = false

    local function isAdminSessionValid()
        return adminVerified
    end

    local function requestAdminKey(onSuccess)
        local promptGui = Instance.new("ScreenGui")
        promptGui.Name = "AdminPrompt"
        promptGui.ResetOnSpawn = false
        promptGui.IgnoreGuiInset = true
        promptGui.DisplayOrder = 10001
        pcall(function() promptGui.Parent = game:GetService("CoreGui") end)
        if not promptGui.Parent then promptGui.Parent = LP:WaitForChild("PlayerGui") end

        local box = Instance.new("Frame")
        box.Size = UDim2.new(0, 300, 0, 240)
        box.Position = UDim2.new(0.5, -150, 0.5, -120)
        box.BackgroundColor3 = Color3.fromRGB(25, 10, 10)
        box.BorderSizePixel = 0
        box.Active = true
        box.Parent = promptGui
        local bc = Instance.new("UICorner")
        bc.CornerRadius = UDim.new(0, 10)
        bc.Parent = box
        local bs = Instance.new("UIStroke")
        bs.Color = Color3.fromRGB(255, 100, 100)
        bs.Thickness = 2
        bs.Parent = box

        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, 0, 0, 50)
        t.BackgroundTransparency = 1
        t.Text = "🔐 XÁC THỰC ADMIN"
        t.TextColor3 = Color3.fromRGB(255, 100, 100)
        t.Font = Enum.Font.GothamBold
        t.TextSize = 18
        t.Parent = box

        local sub = Instance.new("TextLabel")
        sub.Size = UDim2.new(1, -20, 0, 30)
        sub.Position = UDim2.new(0, 10, 0, 50)
        sub.BackgroundTransparency = 1
        sub.Text = "Chức năng này cần key admin.\nNhập key admin để tiếp tục:"
        sub.TextColor3 = Color3.fromRGB(200, 200, 200)
        sub.Font = Enum.Font.Gotham
        sub.TextSize = 11
        sub.TextWrapped = true
        sub.Parent = box

        local input = Instance.new("TextBox")
        input.Size = UDim2.new(1, -40, 0, 40)
        input.Position = UDim2.new(0, 20, 0, 88)
        input.BackgroundColor3 = Color3.fromRGB(40, 25, 25)
        input.BorderSizePixel = 0
        input.Text = ""
        input.PlaceholderText = "Nhập key admin..."
        input.TextColor3 = Color3.fromRGB(255, 255, 255)
        input.PlaceholderColor3 = Color3.fromRGB(120, 100, 100)
        input.Font = Enum.Font.Gotham
        input.TextSize = 13
        input.ClearTextOnFocus = false
        input.Parent = box
        local ic = Instance.new("UICorner")
        ic.CornerRadius = UDim.new(0, 6)
        ic.Parent = input

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -40, 0, 40)
        btn.Position = UDim2.new(0, 20, 0, 138)
        btn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        btn.BorderSizePixel = 0
        btn.Text = "XÁC NHẬN"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.Parent = box
        local bbc = Instance.new("UICorner")
        bbc.CornerRadius = UDim.new(0, 6)
        bbc.Parent = btn

        local cancel = Instance.new("TextButton")
        cancel.Size = UDim2.new(1, -40, 0, 26)
        cancel.Position = UDim2.new(0, 20, 0, 184)
        cancel.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        cancel.BorderSizePixel = 0
        cancel.Text = "Hủy"
        cancel.TextColor3 = Color3.fromRGB(200, 200, 200)
        cancel.Font = Enum.Font.Gotham
        cancel.TextSize = 12
        cancel.Parent = box
        local cbc = Instance.new("UICorner")
        cbc.CornerRadius = UDim.new(0, 5)
        cbc.Parent = cancel

        local status = Instance.new("TextLabel")
        status.Size = UDim2.new(1, -40, 0, 20)
        status.Position = UDim2.new(0, 20, 0, 214)
        status.BackgroundTransparency = 1
        status.Text = ""
        status.TextColor3 = Color3.fromRGB(255, 100, 100)
        status.Font = Enum.Font.Gotham
        status.TextSize = 11
        status.Parent = box

        local function tryVerify()
            local k = input.Text:match("^%s*(.-)%s*$")
            if k == "" then
                status.Text = "Vui lòng nhập key admin"
                return
            end
            if ADMIN_KEYS[k] then
                local keys = loadKeys()
                local entry = keys[k]
                if not entry then
                    keys[k] = {
                        device      = DEVICE_ID,
                        expire      = 0,
                        duration    = "ADMIN",
                        originalSec = 0,
                    }
                    saveKeys(keys)
                elseif entry.device ~= "" and entry.device ~= DEVICE_ID then
                    status.TextColor3 = Color3.fromRGB(255, 100, 100)
                    status.Text = "✗ Key admin đã gắn thiết bị khác"
                    return
                elseif entry.device == "" then
                    entry.device = DEVICE_ID
                    keys[k] = entry
                    saveKeys(keys)
                end

                adminVerified = true
                status.TextColor3 = Color3.fromRGB(150, 255, 150)
                status.Text = "✓ Xác thực thành công"
                task.wait(0.4)
                promptGui:Destroy()
                onSuccess()
            else
                status.TextColor3 = Color3.fromRGB(255, 100, 100)
                status.Text = "✗ Key admin không đúng"
            end
        end

        btn.MouseButton1Click:Connect(tryVerify)
        cancel.MouseButton1Click:Connect(function() promptGui:Destroy() end)
        input.FocusLost:Connect(function(enter)
            if enter then tryVerify() end
        end)
    end

    local function withAdminAuth(actionFn)
        if isAdminSessionValid() then
            actionFn()
        else
            requestAdminKey(actionFn)
        end
    end

    local function makePanel(titleText, titleColor)
        local panel = Instance.new("Frame")
        panel.Size = UDim2.new(0, 290, 0, 480)
        panel.Position = UDim2.new(0.5, -145, 0.5, -240)
        panel.BackgroundColor3 = Color3.fromRGB(20, 15, 15)
        panel.BorderSizePixel = 0
        panel.Active = true
        panel.Parent = gui
        local pc = Instance.new("UICorner")
        pc.CornerRadius = UDim.new(0, 8)
        pc.Parent = panel
        local ps = Instance.new("UIStroke")
        ps.Color = titleColor
        ps.Thickness = 2
        ps.Parent = panel

        local pTitle = Instance.new("TextLabel")
        pTitle.Size = UDim2.new(1, 0, 0, 40)
        pTitle.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
        pTitle.BorderSizePixel = 0
        pTitle.Text = titleText
        pTitle.TextColor3 = titleColor
        pTitle.Font = Enum.Font.GothamBold
        pTitle.TextSize = 15
        pTitle.Parent = panel
        local ptc = Instance.new("UICorner")
        ptc.CornerRadius = UDim.new(0, 8)
        ptc.Parent = pTitle

        local closeX = Instance.new("TextButton")
        closeX.Size = UDim2.new(0, 32, 0, 32)
        closeX.Position = UDim2.new(1, -38, 0, 4)
        closeX.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        closeX.BorderSizePixel = 0
        closeX.Text = "✕"
        closeX.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeX.Font = Enum.Font.GothamBold
        closeX.TextSize = 16
        closeX.AutoButtonColor = false
        closeX.Parent = panel
        local cx = Instance.new("UICorner")
        cx.CornerRadius = UDim.new(0, 5)
        cx.Parent = closeX
        closeX.MouseButton1Click:Connect(function() panel:Destroy() end)

        local pScroll = Instance.new("ScrollingFrame")
        pScroll.Size = UDim2.new(1, -8, 1, -48)
        pScroll.Position = UDim2.new(0, 4, 0, 44)
        pScroll.BackgroundTransparency = 1
        pScroll.BorderSizePixel = 0
        pScroll.ScrollBarThickness = 6
        pScroll.ScrollBarImageColor3 = titleColor
        pScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        pScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        pScroll.ScrollingEnabled = true
        pScroll.Active = true
        pScroll.Parent = panel

        local pLayout = Instance.new("UIListLayout")
        pLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pLayout.Padding = UDim.new(0, 6)
        pLayout.Parent = pScroll

        local pPad = Instance.new("UIPadding")
        pPad.PaddingTop = UDim.new(0, 4)
        pPad.PaddingLeft = UDim.new(0, 4)
        pPad.PaddingRight = UDim.new(0, 4)
        pPad.PaddingBottom = UDim.new(0, 8)
        pPad.Parent = pScroll

        return panel, pScroll
    end

    -- NÚT 1: TẠO KEY
    createKeyBtn.MouseButton1Click:Connect(function()
        withAdminAuth(function()
            local panel, pScroll = makePanel("➕ TẠO KEY MỚI", Color3.fromRGB(80, 200, 100))

            local durTitle = Instance.new("TextLabel")
            durTitle.Size = UDim2.new(1, 0, 0, 18)
            durTitle.BackgroundTransparency = 1
            durTitle.Text = "─── Chọn thời hạn ───"
            durTitle.TextColor3 = Color3.fromRGB(255, 180, 100)
            durTitle.Font = Enum.Font.GothamBold
            durTitle.TextSize = 12
            durTitle.Parent = pScroll

            local selectedDur = 3600
            local durButtons = {}
            local durations = {
                {label = "1 Giờ",   sec = 3600},
                {label = "1 Ngày",  sec = 86400},
                {label = "1 Tuần",  sec = 604800},
                {label = "1 Tháng", sec = 2592000},
                {label = "1 Năm",   sec = 31536000},
            }

            local durRow = Instance.new("Frame")
            durRow.Size = UDim2.new(1, 0, 0, 100)
            durRow.BackgroundTransparency = 1
            durRow.Parent = pScroll
            local durGrid = Instance.new("UIGridLayout")
            durGrid.CellSize = UDim2.new(0.5, -4, 0, 30)
            durGrid.CellPadding = UDim2.new(0, 4, 0, 4)
            durGrid.Parent = durRow

            local function updateHL()
                for _, b in ipairs(durButtons) do
                    b.btn.BackgroundColor3 = (b.sec == selectedDur)
                        and Color3.fromRGB(200, 100, 20)
                        or Color3.fromRGB(60, 60, 60)
                end
            end

            for _, d in ipairs(durations) do
                local b = Instance.new("TextButton")
                b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                b.BorderSizePixel = 0
                b.Text = d.label
                b.TextColor3 = Color3.fromRGB(255, 255, 255)
                b.Font = Enum.Font.GothamBold
                b.TextSize = 12
                b.Parent = durRow
                local bc = Instance.new("UICorner")
                bc.CornerRadius = UDim.new(0, 5)
                bc.Parent = b
                b.MouseButton1Click:Connect(function()
                    selectedDur = d.sec
                    updateHL()
                end)
                table.insert(durButtons, {btn = b, sec = d.sec})
            end
            updateHL()

            local inputLbl = Instance.new("TextLabel")
            inputLbl.Size = UDim2.new(1, 0, 0, 18)
            inputLbl.BackgroundTransparency = 1
            inputLbl.Text = "Nhập key (trống = random 12 ký tự):"
            inputLbl.TextColor3 = Color3.fromRGB(220, 220, 220)
            inputLbl.Font = Enum.Font.Gotham
            inputLbl.TextSize = 11
            inputLbl.TextXAlignment = Enum.TextXAlignment.Left
            inputLbl.Parent = pScroll

            local input = Instance.new("TextBox")
            input.Size = UDim2.new(1, 0, 0, 32)
            input.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            input.BorderSizePixel = 0
            input.Text = ""
            input.PlaceholderText = "VD: ANHDZ-2012-xxxx"
            input.TextColor3 = Color3.fromRGB(255, 255, 255)
            input.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
            input.Font = Enum.Font.Gotham
            input.TextSize = 13
            input.ClearTextOnFocus = false
            input.Parent = pScroll
            local ic = Instance.new("UICorner")
            ic.CornerRadius = UDim.new(0, 5)
            ic.Parent = input

            local randomBtn = Instance.new("TextButton")
            randomBtn.Size = UDim2.new(1, 0, 0, 30)
            randomBtn.BackgroundColor3 = Color3.fromRGB(60, 90, 60)
            randomBtn.BorderSizePixel = 0
            randomBtn.Text = "🎲 Random 12 ký tự"
            randomBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            randomBtn.Font = Enum.Font.GothamBold
            randomBtn.TextSize = 12
            randomBtn.Parent = pScroll
            local rbc = Instance.new("UICorner")
            rbc.CornerRadius = UDim.new(0, 5)
            rbc.Parent = randomBtn
            randomBtn.MouseButton1Click:Connect(function()
                input.Text = randomKey()
            end)

            local createBtn = Instance.new("TextButton")
            createBtn.Size = UDim2.new(1, 0, 0, 40)
            createBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 60)
            createBtn.BorderSizePixel = 0
            createBtn.Text = "✓ TẠO KEY"
            createBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            createBtn.Font = Enum.Font.GothamBold
            createBtn.TextSize = 14
            createBtn.Parent = pScroll
            local cbc = Instance.new("UICorner")
            cbc.CornerRadius = UDim.new(0, 5)
            cbc.Parent = createBtn

            local logLbl = Instance.new("TextLabel")
            logLbl.Size = UDim2.new(1, 0, 0, 80)
            logLbl.BackgroundTransparency = 1
            logLbl.Text = ""
            logLbl.TextColor3 = Color3.fromRGB(150, 255, 150)
            logLbl.Font = Enum.Font.Gotham
            logLbl.TextSize = 11
            logLbl.TextWrapped = true
            logLbl.TextXAlignment = Enum.TextXAlignment.Left
            logLbl.TextYAlignment = Enum.TextYAlignment.Top
            logLbl.Parent = pScroll

            createBtn.MouseButton1Click:Connect(function()
                local k = input.Text:match("^%s*(.-)%s*$")
                if k == "" then k = randomKey() end
                if #k < 6 then
                    logLbl.TextColor3 = Color3.fromRGB(255, 100, 100)
                    logLbl.Text = "✗ Key phải có ít nhất 6 ký tự"
                    return
                end
                local keys = loadKeys()
                if keys[k] or ADMIN_KEYS[k] or PERM_KEYS[k] then
                    logLbl.TextColor3 = Color3.fromRGB(255, 100, 100)
                    logLbl.Text = "✗ Key đã tồn tại"
                    return
                end
                keys[k] = {
                    device = "",
                    expire = os.time() + selectedDur,
                    duration = durationLabel(selectedDur),
                    originalSec = selectedDur,
                }
                saveKeys(keys)
                logLbl.TextColor3 = Color3.fromRGB(150, 255, 150)
                logLbl.Text = "✓ Đã tạo: " .. k .. "\nHạn: " .. durationLabel(selectedDur)
                input.Text = ""
            end)
        end)
    end)

    -- NÚT 2: ĐỔI KEY (RESET)
    changeKeyBtn.MouseButton1Click:Connect(function()
        withAdminAuth(function()
            local panel, pScroll = makePanel("🔄 ĐỔI KEY (RESET)", Color3.fromRGB(255, 180, 80))

            local infoLbl = Instance.new("TextLabel")
            infoLbl.Size = UDim2.new(1, 0, 0, 70)
            infoLbl.BackgroundColor3 = Color3.fromRGB(40, 30, 15)
            infoLbl.BorderSizePixel = 0
            infoLbl.Text = "Reset key = xóa liên kết thiết bị\n+ đặt lại thời gian ban đầu\n\n• Key admin reset được\n• Key vĩnh viễn reset được\n• Key có hạn reset được"
            infoLbl.TextColor3 = Color3.fromRGB(255, 220, 150)
            infoLbl.Font = Enum.Font.Gotham
            infoLbl.TextSize = 10
            infoLbl.TextWrapped = true
            infoLbl.Parent = pScroll
            local ilc = Instance.new("UICorner")
            ilc.CornerRadius = UDim.new(0, 5)
            ilc.Parent = infoLbl

            local resetTitle = Instance.new("TextLabel")
            resetTitle.Size = UDim2.new(1, 0, 0, 20)
            resetTitle.BackgroundTransparency = 1
            resetTitle.Text = "─── Nhập key cần reset ───"
            resetTitle.TextColor3 = Color3.fromRGB(255, 180, 100)
            resetTitle.Font = Enum.Font.GothamBold
            resetTitle.TextSize = 12
            resetTitle.Parent = pScroll

            local resetInput = Instance.new("TextBox")
            resetInput.Size = UDim2.new(1, 0, 0, 32)
            resetInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            resetInput.BorderSizePixel = 0
            resetInput.Text = ""
            resetInput.PlaceholderText = "Paste key vào đây..."
            resetInput.TextColor3 = Color3.fromRGB(255, 255, 255)
            resetInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
            resetInput.Font = Enum.Font.Gotham
            resetInput.TextSize = 12
            resetInput.ClearTextOnFocus = false
            resetInput.Parent = pScroll
            local ric = Instance.new("UICorner")
            ric.CornerRadius = UDim.new(0, 5)
            ric.Parent = resetInput

            local resetKeyBtn = Instance.new("TextButton")
            resetKeyBtn.Size = UDim2.new(1, 0, 0, 40)
            resetKeyBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 30)
            resetKeyBtn.BorderSizePixel = 0
            resetKeyBtn.Text = "↺ RESET KEY"
            resetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            resetKeyBtn.Font = Enum.Font.GothamBold
            resetKeyBtn.TextSize = 14
            resetKeyBtn.Parent = pScroll
            local rkc = Instance.new("UICorner")
            rkc.CornerRadius = UDim.new(0, 5)
            rkc.Parent = resetKeyBtn

            local resetLog = Instance.new("TextLabel")
            resetLog.Size = UDim2.new(1, 0, 0, 80)
            resetLog.BackgroundTransparency = 1
            resetLog.Text = ""
            resetLog.TextColor3 = Color3.fromRGB(255, 200, 100)
            resetLog.Font = Enum.Font.Gotham
            resetLog.TextSize = 12
            resetLog.TextWrapped = true
            resetLog.TextXAlignment = Enum.TextXAlignment.Left
            resetLog.TextYAlignment = Enum.TextYAlignment.Top
            resetLog.Parent = pScroll

            resetKeyBtn.MouseButton1Click:Connect(function()
                local k = resetInput.Text:match("^%s*(.-)%s*$")
                if k == "" then
                    resetLog.TextColor3 = Color3.fromRGB(255, 100, 100)
                    resetLog.Text = "✗ Chưa nhập key"
                    return
                end
                local ok, msg = resetKey(k)
                if ok then
                    resetLog.TextColor3 = Color3.fromRGB(150, 255, 150)
                    resetLog.Text = "✓ " .. msg
                    resetInput.Text = ""
                else
                    resetLog.TextColor3 = Color3.fromRGB(255, 100, 100)
                    resetLog.Text = "✗ " .. msg
                end
            end)
        end)
    end)

    -- NÚT 3: DANH SÁCH KEY
    listKeyBtn.MouseButton1Click:Connect(function()
        withAdminAuth(function()
            local panel, pScroll = makePanel("📋 DANH SÁCH KEY", Color3.fromRGB(150, 150, 255))

            local function refreshList()
                for _, c in ipairs(pScroll:GetChildren()) do
                    if (c:IsA("TextLabel") or c:IsA("TextButton"))
                    and c.Name ~= "RefreshBtn" then
                        c:Destroy()
                    end
                end

                local keys = loadKeys()
                local now = os.time()
                local allKeys = {}

                for k in pairs(ADMIN_KEYS) do
                    allKeys[k] = keys[k] or { device = "", expire = 0, duration = "ADMIN", originalSec = 0 }
                end
                for k in pairs(PERM_KEYS) do
                    allKeys[k] = keys[k] or { device = "", expire = 0, duration = "PERM", originalSec = 0 }
                end
                for k, sec in pairs(TIMED_KEYS) do
                    allKeys[k] = keys[k] or { device = "", expire = 0, duration = durationLabel(sec) .. " (chưa dùng)", originalSec = sec }
                end
                for k, v in pairs(keys) do
                    if not allKeys[k] then
                        allKeys[k] = v
                    end
                end

                local count = 0
                for _ in pairs(allKeys) do count = count + 1 end

                if count == 0 then
                    local empty = Instance.new("TextLabel")
                    empty.Size = UDim2.new(1, 0, 0, 40)
                    empty.BackgroundTransparency = 1
                    empty.Text = "Chưa có key nào"
                    empty.TextColor3 = Color3.fromRGB(180, 180, 180)
                    empty.Font = Enum.Font.Gotham
                    empty.TextSize = 12
                    empty.Parent = pScroll
                    return
                end

                for key, info in pairs(allKeys) do
                    local timeLeft = ""
                    if info.expire > 0 then
                        local left = info.expire - now
                        if left <= 0 then
                            timeLeft = "HẾT HẠN"
                        else
                            local h = math.floor(left / 3600)
                            local d = math.floor(h / 24)
                            if d > 0 then
                                timeLeft = d .. "d " .. (h % 24) .. "h"
                            elseif h > 0 then
                                timeLeft = h .. "h " .. math.floor((left % 3600) / 60) .. "m"
                            else
                                timeLeft = math.floor(left / 60) .. " phút"
                            end
                        end
                    else
                        timeLeft = "Vĩnh viễn"
                    end

                    local deviceInfo = "chưa dùng"
                    if info.device and info.device ~= "" then
                        if info.device == DEVICE_ID then
                            deviceInfo = "máy này"
                        else
                            deviceInfo = "máy khác"
                        end
                    end

                    local card = Instance.new("TextButton")
                    card.Size = UDim2.new(1, 0, 0, 58)
                    card.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
                    card.BorderSizePixel = 0
                    card.Text = ""
                    card.AutoButtonColor = false
                    card.Parent = pScroll
                    local cardC = Instance.new("UICorner")
                    cardC.CornerRadius = UDim.new(0, 5)
                    cardC.Parent = card

                    local keyLbl = Instance.new("TextLabel")
                    keyLbl.Size = UDim2.new(1, -60, 0, 20)
                    keyLbl.Position = UDim2.new(0, 5, 0, 2)
                    keyLbl.BackgroundTransparency = 1
                    keyLbl.Text = key
                    keyLbl.TextColor3 = Color3.fromRGB(255, 215, 0)
                    keyLbl.Font = Enum.Font.Code
                    keyLbl.TextSize = 10
                    keyLbl.TextXAlignment = Enum.TextXAlignment.Left
                    keyLbl.TextTruncate = Enum.TextTruncate.AtEnd
                    keyLbl.Parent = card

                    local typeLbl = Instance.new("TextLabel")
                    typeLbl.Size = UDim2.new(1, -10, 0, 14)
                    typeLbl.Position = UDim2.new(0, 5, 0, 22)
                    typeLbl.BackgroundTransparency = 1
                    typeLbl.Text = "Loại: " .. info.duration .. " | Hạn: " .. timeLeft
                    typeLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
                    typeLbl.Font = Enum.Font.Gotham
                    typeLbl.TextSize = 9
                    typeLbl.TextXAlignment = Enum.TextXAlignment.Left
                    typeLbl.Parent = card

                    local devLbl = Instance.new("TextLabel")
                    devLbl.Size = UDim2.new(1, -10, 0, 14)
                    devLbl.Position = UDim2.new(0, 5, 0, 36)
                    devLbl.BackgroundTransparency = 1
                    devLbl.Text = "Thiết bị: " .. deviceInfo
                    devLbl.TextColor3 = Color3.fromRGB(200, 200, 100)
                    devLbl.Font = Enum.Font.Gotham
                    devLbl.TextSize = 9
                    devLbl.TextXAlignment = Enum.TextXAlignment.Left
                    devLbl.Parent = card

                    local copyBtn = Instance.new("TextButton")
                    copyBtn.Size = UDim2.new(0, 46, 0, 20)
                    copyBtn.Position = UDim2.new(1, -50, 0, 2)
                    copyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
                    copyBtn.BorderSizePixel = 0
                    copyBtn.Text = "Copy"
                    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    copyBtn.Font = Enum.Font.GothamBold
                    copyBtn.TextSize = 10
                    copyBtn.Parent = card
                    local cbc2 = Instance.new("UICorner")
                    cbc2.CornerRadius = UDim.new(0, 4)
                    cbc2.Parent = copyBtn
                    copyBtn.MouseButton1Click:Connect(function()
                        if setclipboard then
                            setclipboard(key)
                            copyBtn.Text = "✓"
                            task.wait(1)
                            copyBtn.Text = "Copy"
                        end
                    end)
                end
            end

            local refreshBtn = Instance.new("TextButton")
            refreshBtn.Name = "RefreshBtn"
            refreshBtn.Size = UDim2.new(1, 0, 0, 30)
            refreshBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
            refreshBtn.BorderSizePixel = 0
            refreshBtn.Text = "🔄 Làm mới danh sách"
            refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            refreshBtn.Font = Enum.Font.GothamBold
            refreshBtn.TextSize = 12
            refreshBtn.Parent = pScroll
            local rbc2 = Instance.new("UICorner")
            rbc2.CornerRadius = UDim.new(0, 5)
            rbc2.Parent = refreshBtn
            refreshBtn.MouseButton1Click:Connect(refreshList)

            refreshList()
        end)
    end)

    -- FLY CONTROLS
    local flyCtrlLocked = false

    local function makeFlyControl(icon, isUp)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 56, 0, 56)
        if isUp then
            b.Position = UDim2.new(1, -76, 0.5, -66)
        else
            b.Position = UDim2.new(1, -76, 0.5, 6)
        end
        b.BackgroundColor3 = Color3.fromRGB(35, 25, 10)
        b.BackgroundTransparency = 0.2
        b.BorderSizePixel = 2
        b.BorderColor3 = Color3.fromRGB(255, 215, 0)
        b.Text = icon
        b.TextColor3 = Color3.fromRGB(255, 215, 0)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 26
        b.AutoButtonColor = false
        b.Visible = false
        b.Active = true
        b.Parent = gui
        local bc = Instance.new("UICorner")
        bc.CornerRadius = UDim.new(0.5, 0)
        bc.Parent = b

        local held = false
        UIS.InputBegan:Connect(function(i)
            if (i.UserInputType == Enum.UserInputType.Touch
            or i.UserInputType == Enum.UserInputType.MouseButton1)
            and b.Visible and pointInGui(b, i.Position) then
                held = true
                if isUp then flyUpHeld = true else flyDownHeld = true end
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if (i.UserInputType == Enum.UserInputType.Touch
            or i.UserInputType == Enum.UserInputType.MouseButton1) and held then
                held = false
                if isUp then flyUpHeld = false else flyDownHeld = false end
            end
        end)

        return b
    end

    local flyUpBtn = makeFlyControl("▲", true)
    local flyDownBtn = makeFlyControl("▼", false)

    task.spawn(function()
        while task.wait(0.2) do
            local on = cfg.fly
            if flyUpBtn.Visible ~= on then
                flyUpBtn.Visible = on
                flyDownBtn.Visible = on
            end
        end
    end)

    local flyDragTarget = nil
    local flyDragStart = Vector2.zero
    local flyStartPos = UDim2.new(0, 0, 0, 0)
    local flyActiveTouch = nil

    UIS.InputBegan:Connect(function(i)
        if flyCtrlLocked then return end
        if i.UserInputType == Enum.UserInputType.Touch
        or i.UserInputType == Enum.UserInputType.MouseButton1 then
            if flyUpBtn.Visible and pointInGui(flyUpBtn, i.Position) then
                flyDragTarget = flyUpBtn
                flyDragStart = i.Position
                flyStartPos = flyUpBtn.Position
                flyActiveTouch = i
            elseif flyDownBtn.Visible and pointInGui(flyDownBtn, i.Position) then
                flyDragTarget = flyDownBtn
                flyDragStart = i.Position
                flyStartPos = flyDownBtn.Position
                flyActiveTouch = i
            end
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if flyDragTarget and i == flyActiveTouch
        and (i.UserInputType == Enum.UserInputType.Touch
        or i.UserInputType == Enum.UserInputType.MouseMovement) then
            local d = i.Position - flyDragStart
            flyDragTarget.Position = UDim2.new(
                flyStartPos.X.Scale, flyStartPos.X.Offset + d.X,
                flyStartPos.Y.Scale, flyStartPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if flyDragTarget and i == flyActiveTouch then
            flyDragTarget = nil
            flyActiveTouch = nil
        end
    end)

    local flyLockBtn = Instance.new("TextButton")
    flyLockBtn.Size = UDim2.new(0, 28, 0, 28)
    flyLockBtn.Position = UDim2.new(1, -36, 0, 180)
    flyLockBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    flyLockBtn.BorderSizePixel = 0
    flyLockBtn.Text = "🔓"
    flyLockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    flyLockBtn.Font = Enum.Font.GothamBold
    flyLockBtn.TextSize = 13
    flyLockBtn.AutoButtonColor = false
    flyLockBtn.Visible = false
    flyLockBtn.Parent = gui
    local flc = Instance.new("UICorner")
    flc.CornerRadius = UDim.new(0.5, 0)
    flc.Parent = flyLockBtn

    flyLockBtn.MouseButton1Click:Connect(function()
        flyCtrlLocked = not flyCtrlLocked
        flyLockBtn.Text = flyCtrlLocked and "🔒" or "🔓"
        flyLockBtn.BackgroundColor3 = flyCtrlLocked and Color3.fromRGB(150, 40, 40) or Color3.fromRGB(40, 40, 60)
    end)

    task.spawn(function()
        while task.wait(0.2) do
            local on = cfg.fly
            if flyLockBtn.Visible ~= on then
                flyLockBtn.Visible = on
            end
        end
    end)

    local countLbl = Instance.new("TextLabel")
    countLbl.Size = UDim2.new(1, -4, 0, 18)
    countLbl.BackgroundTransparency = 1
    countLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    countLbl.Font = Enum.Font.Gotham
    countLbl.TextSize = 10
    countLbl.Text = "mobs: 0"
    countLbl.Parent = scroll

    task.spawn(function()
        while task.wait(0.5) do
            local n = 0
            for _ in pairs(tracked) do n = n + 1 end
            countLbl.Text = "mobs: " .. n .. " | " .. authLevel
        end
    end)
end

-- KEY GATE
local function showKeyGate()
    local gate = Instance.new("ScreenGui")
    gate.Name = "CrownKeyGate"
    gate.ResetOnSpawn = false
    gate.IgnoreGuiInset = true
    gate.DisplayOrder = 10000
    pcall(function() gate.Parent = game:GetService("CoreGui") end)
    if not gate.Parent then gate.Parent = LP:WaitForChild("PlayerGui") end

    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 320, 0, 260)
    box.Position = UDim2.new(0.5, -160, 0.5, -130)
    box.BackgroundColor3 = Color3.fromRGB(15, 18, 25)
    box.BorderSizePixel = 0
    box.Active = true
    box.Parent = gate
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 10)
    bc.Parent = box
    local bs = Instance.new("UIStroke")
    bs.Color = Color3.fromRGB(255, 215, 0)
    bs.Thickness = 2
    bs.Parent = box

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 0, 60)
    t.BackgroundTransparency = 1
    t.Text = "👑 CROWN MENU"
    t.TextColor3 = Color3.fromRGB(255, 215, 0)
    t.Font = Enum.Font.GothamBold
    t.TextSize = 22
    t.Parent = box

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, 0, 0, 20)
    sub.Position = UDim2.new(0, 0, 0, 50)
    sub.BackgroundTransparency = 1
    sub.Text = "Nhập key để sử dụng"
    sub.TextColor3 = Color3.fromRGB(180, 180, 180)
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 13
    sub.Parent = box

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -40, 0, 42)
    input.Position = UDim2.new(0, 20, 0, 90)
    input.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
    input.BorderSizePixel = 0
    input.Text = ""
    input.PlaceholderText = "Dán key vào đây..."
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    input.Font = Enum.Font.Gotham
    input.TextSize = 14
    input.ClearTextOnFocus = false
    input.Parent = box
    local ic = Instance.new("UICorner")
    ic.CornerRadius = UDim.new(0, 6)
    ic.Parent = input

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -40, 0, 44)
    btn.Position = UDim2.new(0, 20, 0, 148)
    btn.BackgroundColor3 = Color3.fromRGB(200, 150, 20)
    btn.BorderSizePixel = 0
    btn.Text = "XÁC NHẬN"
    btn.TextColor3 = Color3.fromRGB(20, 20, 20)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.Parent = box
    local bbc = Instance.new("UICorner")
    bbc.CornerRadius = UDim.new(0, 6)
    bbc.Parent = btn

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -40, 0, 40)
    status.Position = UDim2.new(0, 20, 0, 200)
    status.BackgroundTransparency = 1
    status.Text = ""
    status.TextColor3 = Color3.fromRGB(255, 100, 100)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = box

    local function tryLogin()
        local k = input.Text:match("^%s*(.-)%s*$")
        if k == "" then
            status.Text = "Vui lòng nhập key"
            return
        end
        local ok, msg = checkKey(k)
        if ok then
            saveActiveKey(k)
            status.TextColor3 = Color3.fromRGB(150, 255, 150)
            status.Text = "✓ Key hợp lệ — đang mở menu..."
            task.wait(0.5)
            gate:Destroy()
            buildMenu(msg)
        else
            status.TextColor3 = Color3.fromRGB(255, 100, 100)
            status.Text = "✗ " .. msg
        end
    end

    btn.MouseButton1Click:Connect(tryLogin)
    input.FocusLost:Connect(function(enter)
        if enter then tryLogin() end
    end)
end

-- KHỞI ĐỘNG
local savedKey = loadActiveKey()
if savedKey then
    local ok, msg = checkKey(savedKey)
    if ok then
        buildMenu(msg)
    else
        clearActiveKey()
        showKeyGate()
    end
else
    showKeyGate()
end
