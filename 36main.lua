-- language: Lua, file: 27main_fixed.lua, target: Roblox Mobile (executor)
-- Crown Menu 👑 — Mob ESP universal + Fly đa hướng + lưu vị trí menu.
-- Đã sửa hết lỗi cú pháp từ file gốc trên GitHub.

-- ============================================================
-- SERVICES
-- ============================================================
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace  = game:GetService("Workspace")
local UIS        = game:GetService("UserInputService")
local Camera     = Workspace.CurrentCamera
local LP         = Players.LocalPlayer

-- ============================================================
-- CONFIG
-- ============================================================
local cfg = {
    espEnabled    = true,
    highlight     = true,
    showBox       = true,
    showName      = true,
    showDistance  = true,
    showTracer    = false,
    maxDist       = 2000,
    fillColor     = Color3.fromRGB(255, 60, 60),
    outlineColor  = Color3.fromRGB(255, 0, 0),
    nameColor     = Color3.fromRGB(255, 220, 100),
    distColor     = Color3.fromRGB(255, 255, 255),
    boxColor      = Color3.fromRGB(255, 60, 60),
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
}

-- ============================================================
-- POSITION SAVE/LOAD
-- ============================================================
local SAVE_FILE = "crown_menu_pos.txt"

local function savePosition(pos)
    local data = string.format("%d,%d", pos.X.Offset, pos.Y.Offset)
    if writefile then pcall(writefile, SAVE_FILE, data) end
    _G.CROWN_POS = pos
end

local function loadPosition(default)
    if isfile and readfile and isfile(SAVE_FILE) then
        local ok, data = pcall(readfile, SAVE_FILE)
        if ok and data then
            local x, y = data:match("(-?%d+),(-?%d+)")
            if x and y then
                return UDim2.new(0, tonumber(x), 0, tonumber(y))
            end
        end
    end
    if _G.CROWN_POS then return _G.CROWN_POS end
    return default
end

-- ============================================================
-- STATE
-- ============================================================
local myChar, myHrp
local flyBV, flyBG
local moveVec, lookVec = Vector2.zero, Vector2.zero
local tracked = {}

local function onChar(char)
    myChar = char
    myHrp  = char:WaitForChild("HumanoidRootPart", 5)
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end
end
if LP.Character then onChar(LP.Character) end
LP.CharacterAdded:Connect(onChar)

-- ============================================================
-- ESP HELPERS
-- ============================================================
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

    v.box = Drawing.new("Square")
    v.box.Thickness = 1; v.box.Filled = false; v.box.Transparency = 1
    v.box.Color = cfg.boxColor; v.box.Visible = false

    v.tracer = Drawing.new("Line")
    v.tracer.Thickness = 1; v.tracer.Color = cfg.outlineColor; v.tracer.Visible = false

    tracked[inst] = v
end

local function destroyVisuals(inst)
    if tracked[inst] then
        local v = tracked[inst]
        if v.hl then pcall(function() v.hl:Destroy() end) end
        for _, o in ipairs({v.name, v.dist, v.box, v.tracer}) do
            if o then pcall(function() o:Remove() end) end
        end
        tracked[inst] = nil
    end
end

local function scanMobs()
    local found = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if isMob(obj) then
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
        if cfg.espEnabled then pcall(scanMobs) end
    end
end)

Workspace.DescendantAdded:Connect(function(desc)
    if not cfg.espEnabled then return end
    if desc:IsA("Model") or desc:IsA("BasePart") then
        task.wait(0.1)
        if desc.Parent and not tracked[desc] and isMob(desc) then
            makeVisuals(desc)
        end
    end
end)

-- ============================================================
-- FLY
-- ============================================================
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

-- ============================================================
-- MAIN LOOP
-- ============================================================
RunService.RenderStepped:Connect(function()
    -- FLY
    if cfg.fly and myHrp then
        if not flyBV then startFly() end
        local dir = Vector3.zero
        if cfg.camDirection then
            local cf = Camera.CFrame
            dir = dir + cf.LookVector * (-moveVec.Y)
            dir = dir + cf.RightVector * moveVec.X
            dir = dir + Vector3.new(0, -lookVec.Y, 0)
        else
            local cf = myHrp.CFrame
            dir = dir + cf.LookVector * (-moveVec.Y)
            dir = dir + cf.RightVector * moveVec.X
            dir = dir + Vector3.new(0, -lookVec.Y, 0)
        end
        if dir.Magnitude > 1 then dir = dir.Unit end
        flyBV.Velocity = Vector3.new(dir.X, 0, dir.Z) * cfg.flySpeed
                       + Vector3.new(0, dir.Y, 0) * cfg.verticalSpeed
        if flyBG then
            flyBG.CFrame = CFrame.new(myHrp.Position, myHrp.Position + Camera.CFrame.LookVector)
        end
        applyNoclip()
    elseif flyBV then
        stopFly()
    end

    -- ESP
    if not cfg.espEnabled then return end
    if not myChar then myChar = LP.Character end
    local hrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)

    for inst, v in pairs(tracked) do
        if not inst.Parent then
            if v.hl then v.hl.Enabled = false end
            v.name.Visible = false; v.dist.Visible = false
            v.box.Visible = false; v.tracer.Visible = false
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
                v.name.Visible = false; v.dist.Visible = false
                v.box.Visible = false; v.tracer.Visible = false
                continue
            end
            rootPos = p.Position
        end

        local dist = (hrp.Position - rootPos).Magnitude
        local tooFar = dist > cfg.maxDist

        if v.hl then v.hl.Enabled = cfg.highlight and not tooFar end

        if tooFar then
            v.name.Visible = false; v.dist.Visible = false
            v.box.Visible = false; v.tracer.Visible = false
            continue
        end

        local minV, maxV = getBounds(inst)
        if not minV then
            v.name.Visible = false; v.dist.Visible = false
            v.box.Visible = false; v.tracer.Visible = false
            continue
        end

        local cx = (minV.X + maxV.X) * 0.5
        local cz = (minV.Z + maxV.Z) * 0.5
        local topScr, topOn = w2s(Vector3.new(cx, maxV.Y, cz))
        local botScr, botOn = w2s(Vector3.new(cx, minV.Y, cz))

        if not (topOn and botOn) then
            v.name.Visible = false; v.dist.Visible = false
            v.box.Visible = false; v.tracer.Visible = false
            continue
        end

        local centerX = (topScr.X + botScr.X) * 0.5
        local height = math.abs(botScr.Y - topScr.Y)
        local width = height * 0.6

        if cfg.showBox and height > 4 then
            v.box.Visible = true
            v.box.Size = Vector2.new(width, height)
            v.box.Position = Vector2.new(centerX - width / 2, topScr.Y)
        else
            v.box.Visible = false
        end

        if cfg.showName then
            v.name.Visible = true
            v.name.Text = inst.Name
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

        if cfg.showTracer then
            v.tracer.Visible = true
            v.tracer.From = center
            v.tracer.To = Vector2.new(centerX, botScr.Y)
        else
            v.tracer.Visible = false
        end
    end
end)

-- ============================================================
-- GUI
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "CrownMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 9999
pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

local DEFAULT_POS = UDim2.new(0, 20, 0, 100)

-- Nút logo 👑
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 56, 0, 56)
toggleBtn.Position = loadPosition(DEFAULT_POS)
toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 25, 10)
toggleBtn.BorderSizePixel = 2
toggleBtn.BorderColor3 = Color3.fromRGB(255, 215, 0)
toggleBtn.Text = "👑"
toggleBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 32
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

-- Menu chính
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 230, 0, 440)
frame.Position = loadPosition(DEFAULT_POS)
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

-- Title
local title = Instance.new("TextButton")
title.Size = UDim2.new(1, 0, 0, 44)
title.BackgroundColor3 = Color3.fromRGB(30, 25, 10)
title.BorderSizePixel = 0
title.Text = ""
title.AutoButtonColor = false
title.Parent = frame

local titleC = Instance.new("UICorner")
titleC.CornerRadius = UDim.new(0, 8)
titleC.Parent = title

local logoLbl = Instance.new("TextLabel")
logoLbl.Size = UDim2.new(0, 40, 1, 0)
logoLbl.Position = UDim2.new(0, 4, 0, 0)
logoLbl.BackgroundTransparency = 1
logoLbl.Text = "👑"
logoLbl.TextColor3 = Color3.fromRGB(255, 215, 0)
logoLbl.Font = Enum.Font.GothamBold
logoLbl.TextSize = 26
logoLbl.Parent = title

local nameLbl = Instance.new("TextLabel")
nameLbl.Size = UDim2.new(1, -100, 1, 0)
nameLbl.Position = UDim2.new(0, 48, 0, 0)
nameLbl.BackgroundTransparency = 1
nameLbl.Text = "CROWN MENU"
nameLbl.TextColor3 = Color3.fromRGB(255, 215, 0)
nameLbl.Font = Enum.Font.GothamBold
nameLbl.TextSize = 15
nameLbl.TextXAlignment = Enum.TextXAlignment.Left
nameLbl.Parent = title

local collapse = Instance.new("TextButton")
collapse.Size = UDim2.new(0, 32, 0, 32)
collapse.Position = UDim2.new(1, -38, 0, 6)
collapse.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
collapse.BorderSizePixel = 0
collapse.Text = "−"
collapse.TextColor3 = Color3.fromRGB(255, 255, 255)
collapse.Font = Enum.Font.GothamBold
collapse.TextSize = 18
collapse.AutoButtonColor = false
collapse.Parent = title

local cc = Instance.new("UICorner")
cc.CornerRadius = UDim.new(0, 6)
cc.Parent = collapse

-- Kéo menu
local drag, dragStart, startPos
title.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        drag = true
        dragStart = i.Position
        startPos = frame.Position
    end
end)
title.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        drag = false
        savePosition(frame.Position)
    end
end)
UIS.InputChanged:Connect(function(i)
    if drag and (i.UserInputType == Enum.UserInputType.MouseMovement
    or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                   startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- Kéo logo 👑
local tDrag, tDragStart, tStartPos
toggleBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        tDrag = true
        tDragStart = i.Position
        tStartPos = toggleBtn.Position
    end
end)
toggleBtn.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        tDrag = false
        savePosition(toggleBtn.Position)
    end
end)
UIS.InputChanged:Connect(function(i)
    if tDrag and (i.UserInputType == Enum.UserInputType.MouseMovement
    or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - tDragStart
        toggleBtn.Position = UDim2.new(tStartPos.X.Scale, tStartPos.X.Offset + d.X,
                                       tStartPos.Y.Scale, tStartPos.Y.Offset + d.Y)
    end
end)

-- Thu gọn
local collapsed = false
collapse.MouseButton1Click:Connect(function()
    collapsed = true
    toggleBtn.Position = frame.Position
    frame.Visible = false
    toggleBtn.Visible = true
    savePosition(toggleBtn.Position)
end)

-- Mở từ logo (tap vs drag)
local downPos = nil
toggleBtn.MouseButton1Down:Connect(function()
    downPos = UIS:GetMouseLocation()
end)
toggleBtn.MouseButton1Up:Connect(function()
    if downPos and (UIS:GetMouseLocation() - downPos).Magnitude < 10 then
        collapsed = false
        frame.Visible = true
        toggleBtn.Visible = false
        frame.Position = toggleBtn.Position
        savePosition(frame.Position)
    end
end)

-- Reset vị trí
local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(1, -12, 0, 28)
resetBtn.Position = UDim2.new(0, 6, 0, frame.Size.Y.Offset - 34)
resetBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
resetBtn.BorderSizePixel = 0
resetBtn.Text = "↺ Reset vị trí"
resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetBtn.Font = Enum.Font.Gotham
resetBtn.TextSize = 11
resetBtn.Parent = frame

local rc = Instance.new("UICorner")
rc.CornerRadius = UDim.new(0, 5)
rc.Parent = resetBtn

resetBtn.MouseButton1Click:Connect(function()
    frame.Position = DEFAULT_POS
    toggleBtn.Position = DEFAULT_POS
    savePosition(DEFAULT_POS)
end)

-- Build content
local function makeToggle(y, key, label, onColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 34)
    btn.Position = UDim2.new(0, 6, 0, y)
    btn.BackgroundColor3 = cfg[key] and (onColor or Color3.fromRGB(140, 100, 20)) or Color3.fromRGB(45, 45, 55)
    btn.BorderSizePixel = 0
    btn.Text = label
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = frame
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 5)
    bc.Parent = btn
    btn.MouseButton1Click:Connect(function()
        cfg[key] = not cfg[key]
        btn.BackgroundColor3 = cfg[key] and (onColor or Color3.fromRGB(140, 100, 20)) or Color3.fromRGB(45, 45, 55)
    end)
    return y + 38
end

local function makeHeader(y, text, color)
    local h = Instance.new("TextLabel")
    h.Size = UDim2.new(1, -12, 0, 20)
    h.Position = UDim2.new(0, 6, 0, y)
    h.BackgroundTransparency = 1
    h.Text = text
    h.TextColor3 = color or Color3.fromRGB(255, 215, 0)
    h.Font = Enum.Font.GothamBold
    h.TextSize = 12
    h.TextXAlignment = Enum.TextXAlignment.Left
    h.Parent = frame
    return y + 24
end

local function makeSlider(y, key, label, min, max)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -12, 0, 18)
    lbl.Position = UDim2.new(0, 6, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Text = label .. ": " .. cfg[key]
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -12, 0, 22)
    bar.Position = UDim2.new(0, 6, 0, y + 18)
    bar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    bar.BorderSizePixel = 0
    bar.Parent = frame
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
    local function setFromX(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * rel)
        cfg[key] = val
        fill.Size = UDim2.new(rel, 0, 1, 0)
        lbl.Text = label .. ": " .. val
    end

    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragS = true
            setFromX(i.Position.X)
        end
    end)
    bar.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragS = false
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragS and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then
            setFromX(i.Position.X)
        end
    end)
    return y + 44
end

-- Build toggles + sliders
local y = 50
y = makeHeader(y, "◆ MOB ESP")
y = makeToggle(y, "espEnabled",   "ESP ON/OFF")
y = makeToggle(y, "highlight",    "Highlight")
y = makeToggle(y, "showBox",      "Box")
y = makeToggle(y, "showName",     "Tên")
y = makeToggle(y, "showDistance", "Khoảng cách")
y = makeToggle(y, "showTracer",   "Tracer")

y = makeHeader(y + 4, "◆ FLY")
y = makeToggle(y, "fly", "FLY ON/OFF")

local dirBtn = Instance.new("TextButton")
dirBtn.Size = UDim2.new(1, -12, 0, 30)
dirBtn.Position = UDim2.new(0, 6, 0, y)
dirBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
dirBtn.BorderSizePixel = 0
dirBtn.Text = cfg.camDirection and "Bay theo Camera" or "Bay theo Nhân vật"
dirBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dirBtn.Font = Enum.Font.Gotham
dirBtn.TextSize = 12
dirBtn.Parent = frame
local dc = Instance.new("UICorner")
dc.CornerRadius = UDim.new(0, 5)
dc.Parent = dirBtn
dirBtn.MouseButton1Click:Connect(function()
    cfg.camDirection = not cfg.camDirection
    dirBtn.Text = cfg.camDirection and "Bay theo Camera" or "Bay theo Nhân vật"
end)
y = y + 34

y = makeSlider(y, "flySpeed",      "Tốc độ bay",       20, 500)
y = makeSlider(y, "verticalSpeed", "Tốc độ lên/xuống", 20, 500)

-- ============================================================
-- JOYSTICK ẢO
-- ============================================================
local function makeJoystick(side, onUpdate)
    local size = 130
    local base = Instance.new("Frame")
    base.Size = UDim2.new(0, size, 0, size)
    base.AnchorPoint = Vector2.new(0.5, 0.5)
    base.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    base.BackgroundTransparency = 0.88
    base.BorderSizePixel = 2
    base.BorderColor3 = Color3.fromRGB(255, 215, 0)
    base.Visible = false
    base.Active = true
    base.Parent = gui

    if side == "left" then
        base.Position = UDim2.new(0, 110, 1, -140)
    else
        base.Position = UDim2.new(1, -110, 1, -140)
    end

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 52, 0, 52)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(0.5, 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    knob.BackgroundTransparency = 0.2
    knob.BorderSizePixel = 0
    knob.Parent = base

    local c1 = Instance.new("UICorner")
    c1.CornerRadius = UDim.new(0.5, 0)
    c1.Parent = base
    local c2 = Instance.new("UICorner")
    c2.CornerRadius = UDim.new(0.5, 0)
    c2.Parent = knob

    local active, center, touchId = false, Vector2.zero, nil

    local function update(pos)
        local delta = pos - center
        local maxR = size / 2 - 26
        if delta.Magnitude > maxR then
            delta = delta.Unit * maxR
        end
        knob.Position = UDim2.new(0.5, delta.X, 0.5, delta.Y)
        onUpdate(Vector2.new(delta.X / maxR, delta.Y / maxR))
    end

    local function reset()
        knob.Position = UDim2.new(0.5, 0, 0.5, 0)
        onUpdate(Vector2.zero)
        active, touchId = false, nil
    end

    base.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch
        or i.UserInputType == Enum.UserInputType.MouseButton1 then
            active = true
            touchId = i
            center = base.AbsolutePosition + base.AbsoluteSize / 2
            update(i.Position)
        end
    end)

    UIS.InputChanged:Connect(function(i)
        if active and i == touchId
        and (i.UserInputType == Enum.UserInputType.Touch
        or i.UserInputType == Enum.UserInputType.MouseMovement) then
            update(i.Position)
        end
    end)

    UIS.InputEnded:Connect(function(i)
        if active and i == touchId then reset() end
    end)

    return base
end

local leftJoy = makeJoystick("left", function(v) moveVec = v end)
local rightJoy = makeJoystick("right", function(v) lookVec = v end)

task.spawn(function()
    while task.wait(0.2) do
        local on = cfg.fly
        if leftJoy.Visible ~= on then
            leftJoy.Visible = on
            rightJoy.Visible = on
        end
    end
end)

-- Đếm mob
local countLbl = Instance.new("TextLabel")
countLbl.Size = UDim2.new(1, -12, 0, 18)
countLbl.Position = UDim2.new(0, 6, 0, y)
countLbl.BackgroundTransparency = 1
countLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
countLbl.Font = Enum.Font.Gotham
countLbl.TextSize = 11
countLbl.Text = "mobs: 0"
countLbl.Parent = frame

task.spawn(function()
    while task.wait(0.5) do
        local n = 0
        for _ in pairs(tracked) do n = n + 1 end
        countLbl.Text = "mobs: " .. n
    end
end)
