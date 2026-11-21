--== Roblox Mobile Universal Menu v2 ==--
-- Parent: PlayerGui (ổn định trên mọi executor mobile)
-- Không dùng gethui — tránh bug ẩn GUI

local Players    = game:GetService("Players")
local UIS        = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LogService = game:GetService("LogService")

local LP = Players.LocalPlayer
local Cam = workspace.CurrentCamera
if not Cam then
    repeat task.wait(0.1) until workspace.CurrentCamera
    Cam = workspace.CurrentCamera
end

local PlayerGui = LP:WaitForChild("PlayerGui")

--== GUI ==--
local GUI = Instance.new("ScreenGui")
GUI.Name = "ANON_Menu"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.DisplayOrder = 2147483647
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.Parent = PlayerGui
print("[ANON] GUI parented")

--== LOGO ==--
local logo = Instance.new("TextButton")
logo.Name = "Logo"
logo.Size = UDim2.new(0, 56, 0, 56)
logo.Position = UDim2.new(0, 20, 0, 100)
logo.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
logo.BackgroundTransparency = 0.1
logo.BorderSizePixel = 0
logo.Text = "A"
logo.TextColor3 = Color3.fromRGB(0, 220, 180)
logo.Font = Enum.Font.GothamBlack
logo.TextSize = 28
logo.AutoButtonColor = false
logo.Active = true
logo.ZIndex = 10
logo.Parent = GUI

local lc = Instance.new("UICorner")
lc.CornerRadius = UDim.new(1, 0)
lc.Parent = logo

local ls = Instance.new("UIStroke")
ls.Color = Color3.fromRGB(0, 220, 180)
ls.Thickness = 2
ls.Transparency = 0.3
ls.Parent = logo

--== DRAG ==--
local dragStart, startPos, dragging = nil, nil, false

logo.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart = input.Position
        startPos = logo.Position
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if not dragStart then return end
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        if delta.Magnitude > 5 then
            dragging = true
            logo.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart = nil
    end
end)

--== PANEL ==--
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.new(0, 320, 0, 480)
panel.Position = UDim2.new(0.5, -160, 0.5, -240)
panel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
panel.BorderSizePixel = 0
panel.Visible = false
panel.Active = true
panel.ClipsDescendants = true
panel.ZIndex = 5
panel.Parent = GUI

local pc = Instance.new("UICorner")
pc.CornerRadius = UDim.new(0, 14)
pc.Parent = panel

local ps = Instance.new("UIStroke")
ps.Color = Color3.fromRGB(0, 220, 180)
ps.Thickness = 1.5
ps.Transparency = 0.5
ps.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 44)
title.Position = UDim2.new(0, 10, 0, 8)
title.BackgroundTransparency = 1
title.Text = "ANON MENU"
title.TextColor3 = Color3.fromRGB(0, 220, 180)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 6
title.Parent = panel

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -42, 0, 14)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.ZIndex = 6
closeBtn.Parent = panel

local cc = Instance.new("UICorner")
cc.CornerRadius = UDim.new(0, 8)
cc.Parent = closeBtn

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -70)
scroll.Position = UDim2.new(0, 10, 0, 60)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 220, 180)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ZIndex = 6
scroll.Parent = panel

local ll = Instance.new("UIListLayout")
ll.Padding = UDim.new(0, 6)
ll.SortOrder = Enum.SortOrder.LayoutOrder
ll.Parent = scroll

ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0, 0, 0, ll.AbsoluteContentSize.Y + 8)
end)

logo.MouseButton1Click:Connect(function()
    if not dragging then
        panel.Visible = not panel.Visible
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    panel.Visible = false
end)

--== BUILDERS ==--
local function makeButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    btn.BorderSizePixel = 0
    btn.Text = "  " .. text
    btn.TextColor3 = Color3.fromRGB(230, 230, 240)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.ZIndex = 7
    btn.Parent = scroll

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 8)
    bc.Parent = btn

    btn.MouseButton1Click:Connect(function()
        local ok, err = pcall(callback)
        if not ok then
            warn("[ANON] " .. tostring(err))
        end
    end)

    return btn
end

local function makeToggle(text, default, callback)
    local state = default or false
    local btn = makeButton(text .. "  [OFF]", function()
        state = not state
        btn.Text = "  " .. text .. "  [" .. (state and "ON" or "OFF") .. "]"
        btn.TextColor3 = state
            and Color3.fromRGB(0, 220, 180)
            or  Color3.fromRGB(230, 230, 240)
        callback(state)
    end)
    return btn
end

--== HELPERS ==--
local function getRoot()
    if LP.Character then
        return LP.Character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function getHumanoid()
    if LP.Character then
        return LP.Character:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

--== FLY ==--
local fly = {
    active = false,
    noclip = false,
    speed = 50,
    conn = nil,
    bp = nil,
    bg = nil,
    noclipConn = nil,
}

local function startFly()
    local root = getRoot()
    if not root then return end

    local bp = Instance.new("BodyPosition")
    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bp.P = 15000
    bp.D = 500
    bp.Position = root.Position
    bp.Parent = root

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 5000
    bg.D = 500
    bg.CFrame = root.CFrame
    bg.Parent = root

    fly.bp = bp
    fly.bg = bg

    local hum = getHumanoid()
    if hum then hum.PlatformStand = true end

    fly.conn = RunService.RenderStepped:Connect(function()
        if not fly.active then return end
        local r = getRoot()
        if not r or not fly.bp then return end

        local camCF = Cam.CFrame
        local moveDir = Vector3.zero
        local hum2 = getHumanoid()

        if hum2 then
            moveDir = hum2.MoveDirection
        end

        if moveDir.Magnitude < 0.1 then
            local kb = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then kb = kb + camCF.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then kb = kb - camCF.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then kb = kb - camCF.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then kb = kb + camCF.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then kb = kb + Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then kb = kb - Vector3.new(0, 1, 0) end
            moveDir = kb
        end

        if hum2 then
            if hum2:GetState() == Enum.HumanoidStateType.Jumping then
                moveDir = moveDir + Vector3.new(0, 1, 0)
            end
        end

        if moveDir.Magnitude > 0.05 then
            fly.bp.Position = r.Position + moveDir.Unit * fly.speed * 0.1
        else
            fly.bp.Position = r.Position
        end

        fly.bg.CFrame = camCF
    end)
end

local function stopFly()
    if fly.conn then
        fly.conn:Disconnect()
        fly.conn = nil
    end
    if fly.bp then
        fly.bp:Destroy()
        fly.bp = nil
    end
    if fly.bg then
        fly.bg:Destroy()
        fly.bg = nil
    end
    local hum = getHumanoid()
    if hum then
        hum.PlatformStand = false
        pcall(function()
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end)
    end
end

makeToggle("Fly (joystick)", false, function(s)
    fly.active = s
    if s then
        startFly()
    else
        stopFly()
    end
end)

makeToggle("Noclip", false, function(s)
    fly.noclip = s
    if s then
        if fly.noclipConn then fly.noclipConn:Disconnect() end
        fly.noclipConn = RunService.Stepped:Connect(function()
            if not fly.noclip then return end
            local char = LP.Character
            if not char then return end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    p.CanCollide = false
                end
            end
        end)
    else
        if fly.noclipConn then
            fly.noclipConn:Disconnect()
            fly.noclipConn = nil
        end
    end
end)

local speedBtn = makeButton("Speed: 50", function()
    local list = {16, 30, 50, 80, 120, 200, 350}
    local idx = 1
    for i = 1, #list do
        if list[i] == fly.speed then
            idx = (i % #list) + 1
            break
        end
    end
    fly.speed = list[idx]
    speedBtn.Text = "  Speed: " .. fly.speed
end)

--== ESP ==--
local espFolder = Instance.new("Folder")
espFolder.Name = "ESP_Highlights"
espFolder.Parent = GUI

local espCache = {}
local espOn = { mobs = false, players = false, npcs = false, items = false }

local function createESP(obj, color, labelText)
    if espCache[obj] then return end

    local hl = Instance.new("Highlight")
    hl.FillColor = color
    hl.FillTransparency = 0.6
    hl.OutlineColor = color
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = obj
    hl.Parent = espFolder

    local part = nil
    if obj:IsA("Model") then
        part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    elseif obj:IsA("BasePart") then
        part = obj
    end

    if not part then
        hl:Destroy()
        return
    end

    local bb = Instance.new("BillboardGui")
    bb.Adornee = part
    bb.Size = UDim2.new(0, 200, 0, 40)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = espFolder

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = color
    lbl.TextStrokeTransparency = 0
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.Parent = bb

    espCache[obj] = { hl = hl, bb = bb }
end

local function clearESP()
    for _, d in pairs(espCache) do
        if d.hl then d.hl:Destroy() end
        if d.bb then d.bb:Destroy() end
    end
    espCache = {}
end

local function isMonster(obj)
    if obj == LP.Character then return false end
    if not obj:IsA("Model") then return false end
    if Players:GetPlayerFromCharacter(obj) then return false end

    local hum = obj:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health > 0 then return true end

    local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    if part then
        if obj:FindFirstChild("Head") then return true end
        local n = obj.Name:lower()
        if n:find("mob") or n:find("enemy") or n:find("boss")
        or n:find("monster") or n:find("zombie") then
            return true
        end
    end
    return false
end

task.spawn(function()
    while task.wait(1) do
        if not espOn.mobs and not espOn.players and not espOn.npcs and not espOn.items then
            clearESP()
        end

        if espOn.mobs then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if isMonster(obj) and not espCache[obj] then
                    createESP(obj, Color3.fromRGB(255, 60, 60), "MOB " .. obj.Name)
                end
            end
        end

        if espOn.players then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LP and plr.Character and not espCache[plr.Character] then
                    createESP(plr.Character, Color3.fromRGB(80, 200, 255), "PLAYER " .. plr.Name)
                end
            end
        end

        if espOn.npcs then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Model")
                and not Players:GetPlayerFromCharacter(obj)
                and not espCache[obj] then
                    local n = obj.Name:lower()
                    if n:find("npc") or n:find("villager") or n:find("trader") then
                        createESP(obj, Color3.fromRGB(255, 220, 80), "NPC " .. obj.Name)
                    end
                end
            end
        end

        if espOn.items then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if (obj:IsA("Tool") or obj:IsA("Model") or obj:IsA("MeshPart"))
                and not espCache[obj] then
                    local n = obj.Name:lower()
                    if n:find("item") or n:find("chest") or n:find("loot")
                    or n:find("pickup") or n:find("coin") then
                        createESP(obj, Color3.fromRGB(120, 255, 120), "ITEM " .. obj.Name)
                    end
                end
            end
        end
    end
end)

makeToggle("ESP Mob",    false, function(s) espOn.mobs    = s end)
makeToggle("ESP Player", false, function(s) espOn.players = s end)
makeToggle("ESP NPC",    false, function(s) espOn.npcs    = s end)
makeToggle("ESP Item",   false, function(s) espOn.items   = s end)

--== TP PLAYER ==--
local tpFrame = nil

local function showTPPlayer()
    if tpFrame then tpFrame:Destroy() end

    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 260, 0, 320)
    f.Position = UDim2.new(0.5, -130, 0.5, -160)
    f.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    f.BorderSizePixel = 0
    f.ZIndex = 20
    f.Parent = GUI

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0, 12)
    fc.Parent = f

    local fs = Instance.new("UIStroke")
    fs.Color = Color3.fromRGB(0, 220, 180)
    fs.Parent = f

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -20, 0, 30)
    t.Position = UDim2.new(0, 10, 0, 8)
    t.BackgroundTransparency = 1
    t.Text = "Chon nguoi choi de TP"
    t.TextColor3 = Color3.fromRGB(0, 220, 180)
    t.Font = Enum.Font.GothamBold
    t.TextSize = 14
    t.ZIndex = 21
    t.Parent = f

    local sc = Instance.new("ScrollingFrame")
    sc.Size = UDim2.new(1, -20, 1, -50)
    sc.Position = UDim2.new(0, 10, 0, 42)
    sc.BackgroundTransparency = 1
    sc.ScrollBarThickness = 4
    sc.CanvasSize = UDim2.new(0, 0, 0, 0)
    sc.ZIndex = 21
    sc.Parent = f

    local sl = Instance.new("UIListLayout")
    sl.Padding = UDim.new(0, 4)
    sl.Parent = sc

    sl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sc.CanvasSize = UDim2.new(0, 0, 0, sl.AbsoluteContentSize.Y)
    end)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 32)
            b.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
            b.BorderSizePixel = 0
            b.Text = plr.Name
            b.TextColor3 = Color3.fromRGB(230, 230, 240)
            b.Font = Enum.Font.GothamMedium
            b.TextSize = 13
            b.ZIndex = 22
            b.Parent = sc

            local bc = Instance.new("UICorner")
            bc.CornerRadius = UDim.new(0, 6)
            bc.Parent = b

            b.MouseButton1Click:Connect(function()
                pcall(function()
                    local root = getRoot()
                    local target = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                    if root and target then
                        root.CFrame = target.CFrame + Vector3.new(0, 3, 0)
                    end
                end)
                f:Destroy()
                tpFrame = nil
            end)
        end
    end

    tpFrame = f
end

makeButton("TP den nguoi choi", showTPPlayer)

--== TP MAP ==--
local mapFrame = nil

local function showMap()
    if mapFrame then
        mapFrame:Destroy()
        mapFrame = nil
    end

    local root = getRoot()
    if not root then return end

    local origin = root.Position
    local sp = workspace:FindFirstChildOfClass("SpawnLocation")
    if sp then origin = sp.Position end

    local RANGE = 500
    local SIZE = 300
    local px = origin.X - RANGE
    local pz = origin.Z - RANGE
    local w = RANGE * 2
    local h = RANGE * 2

    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, SIZE, 0, SIZE + 40)
    f.Position = UDim2.new(0.5, -SIZE/2, 0.5, -SIZE/2 - 20)
    f.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    f.BorderSizePixel = 0
    f.ZIndex = 20
    f.Parent = GUI

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0, 12)
    fc.Parent = f

    local fs = Instance.new("UIStroke")
    fs.Color = Color3.fromRGB(0, 220, 180)
    fs.Parent = f

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -50, 0, 30)
    t.Position = UDim2.new(0, 10, 0, 6)
    t.BackgroundTransparency = 1
    t.Text = "Bam vao ban do de TP"
    t.TextColor3 = Color3.fromRGB(0, 220, 180)
    t.Font = Enum.Font.GothamBold
    t.TextSize = 13
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = 21
    t.Parent = f

    local mapBtn = Instance.new("TextButton")
    mapBtn.Size = UDim2.new(0, SIZE - 10, 0, SIZE - 10)
    mapBtn.Position = UDim2.new(0, 5, 0, 36)
    mapBtn.BackgroundColor3 = Color3.fromRGB(15, 30, 25)
    mapBtn.BorderSizePixel = 0
    mapBtn.Text = ""
    mapBtn.AutoButtonColor = false
    mapBtn.ClipsDescendants = true
    mapBtn.ZIndex = 21
    mapBtn.Parent = f

    local mc = Instance.new("UICorner")
    mc.CornerRadius = UDim.new(0, 8)
    mc.Parent = mapBtn

    local marker = Instance.new("Frame")
    marker.Size = UDim2.new(0, 8, 0, 8)
    marker.AnchorPoint = Vector2.new(0.5, 0.5)
    marker.BackgroundColor3 = Color3.fromRGB(80, 200, 255)
    marker.BorderSizePixel = 0
    marker.ZIndex = 22
    marker.Parent = mapBtn

    local mk = Instance.new("UICorner")
    mk.CornerRadius = UDim.new(1, 0)
    mk.Parent = marker

    local conn = nil
    conn = RunService.RenderStepped:Connect(function()
        if not f.Parent then
            if conn then conn:Disconnect() end
            return
        end
        local r = getRoot()
        if not r then return end
        local rx = (r.Position.X - px) / w
        local rz = (r.Position.Z - pz) / h
        if rx >= 0 and rx <= 1 and rz >= 0 and rz <= 1 then
            marker.Position = UDim2.new(rx, 0, rz, 0)
        end
    end)

    mapBtn.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Touch
        and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end
        local pos = input.Position
        local abs = mapBtn.AbsolutePosition
        local sz = mapBtn.AbsoluteSize
        local rx = (pos.X - abs.X) / sz.X
        local rz = (pos.Y - abs.Y) / sz.Y
        if rx >= 0 and rx <= 1 and rz >= 0 and rz <= 1 then
            local target = Vector3.new(px + rx * w, origin.Y + 50, pz + rz * h)
            pcall(function()
                local r = getRoot()
                if r then r.CFrame = CFrame.new(target + Vector3.new(0, 10, 0)) end
            end)
        end
    end)

    local cb = Instance.new("TextButton")
    cb.Size = UDim2.new(0, 30, 0, 30)
    cb.Position = UDim2.new(1, -36, 0, 6)
    cb.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
    cb.BorderSizePixel = 0
    cb.Text = "X"
    cb.TextColor3 = Color3.fromRGB(255, 100, 100)
    cb.Font = Enum.Font.GothamBold
    cb.TextSize = 16
    cb.ZIndex = 22
    cb.Parent = f

    local cbc = Instance.new("UICorner")
    cbc.CornerRadius = UDim.new(0, 6)
    cbc.Parent = cb

    cb.MouseButton1Click:Connect(function()
        if conn then conn:Disconnect() end
        f:Destroy()
        mapFrame = nil
    end)

    mapFrame = f
end

makeButton("Dich chuyen ban do", showMap)

--== RESPAWN ==--
LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if fly.active then
        stopFly()
        task.wait(0.1)
        startFly()
    end
end)

print("[ANON] Menu loaded OK")
