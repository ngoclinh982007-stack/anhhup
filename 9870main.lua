-- language: Lua (Luau), target: Roblox mobile executor (Delta/Fluxus/Hydrogen/Codex)
-- ============================================================
-- ROBLOX MOBILE MULTI-MENU v4
-- Logo toggle · Fly noclip · ESP all (no humanoid needed) · Map TP · Player TP · Anti-ban
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================================================
-- CONFIG
-- ============================================================
local MAP_IMAGE_ID = ""
local LOGO_IMAGE_ID = "rbxassetid://6031075931"

-- ============================================================
-- CLEANUP
-- ============================================================
if _G.__MYMENU_DESTROY then pcall(_G.__MYMENU_DESTROY) end
local connections = {}
local function track(c) table.insert(connections, c); return c end
_G.__MYMENU_DESTROY = function()
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    table.clear(connections)
    for _, v in ipairs(CoreGui:GetChildren()) do
        if v.Name:sub(1, 9) == "MyMenuGUI" then v:Destroy() end
    end
    if _G.__FLY_CONN then pcall(function() _G.__FLY_CONN:Disconnect() end) end
end

-- ============================================================
-- ANTI-BAN (executor-safe)
-- ============================================================
pcall(function()
    if hookfunction and LocalPlayer.Kick then
        local old = LocalPlayer.Kick
        hookfunction(LocalPlayer.Kick, function(self, msg) return old(self, "") end)
    end
end)

local function safeDelay() task.wait(math.random(80, 180) / 1000) end

task.spawn(function()
    local n = 0
    while true do
        pcall(function() RunService.Heartbeat:Wait() end)
        n += 1
        if n % 300 == 0 and _G.__FLYING then
            pcall(function() UserInputService.MouseDeltaSensitivity = UserInputService.MouseDeltaSensitivity end)
        end
    end
end)

pcall(function()
    if getrawmetatable and setreadonly then
        local mt = getrawmetatable(game)
        if mt then setreadonly(mt, false) end
    end
end)

-- ============================================================
-- UI BUILD
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MyMenuGUI_" .. tostring(math.random(10000, 99999))
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = (gethui and gethui()) or CoreGui

-- ============================================================
-- PANEL (phải khai báo trước logo để logo toggle được)
-- ============================================================
local Panel = Instance.new("Frame")
Panel.Name = "Panel"
Panel.Size = UDim2.new(0, 300, 0, math.min(500, Camera.ViewportSize.Y - 140))
Panel.Position = UDim2.new(0, 75, 0, 80)
Panel.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
Panel.BorderSizePixel = 0
Panel.Visible = false
Panel.Parent = ScreenGui
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 10)
local panelStroke = Instance.new("UIStroke", Panel)
panelStroke.Color = Color3.fromRGB(0, 200, 255)
panelStroke.Thickness = 1.5

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 36)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Title.Text = "  A"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Panel
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

-- NÚT X ĐÓNG MENU (góc phải title bar)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.AutoButtonColor = true
CloseBtn.Parent = Panel
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function()
    Panel.Visible = false
end)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -46)
Scroll.Position = UDim2.new(0, 5, 0, 40)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 6
Scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.ScrollingDirection = Enum.ScrollingDirection.Y
Scroll.ScrollBarImageTransparency = 0
Scroll.Parent = Panel
local listLayout = Instance.new("UIListLayout", Scroll)
listLayout.Padding = UDim.new(0, 6)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
local pad = Instance.new("UIPadding", Scroll)
pad.PaddingTop = UDim.new(0, 4)
pad.PaddingBottom = UDim.new(0, 8)

-- ============================================================
-- LOGO (drag mượt + tap toggle)
-- ============================================================
local Logo = Instance.new("ImageButton")
Logo.Name = "Logo"
Logo.Size = UDim2.new(0, 50, 0, 50)
Logo.Position = UDim2.new(0, 15, 0, 80)
Logo.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Logo.BorderSizePixel = 0
Logo.Image = LOGO_IMAGE_ID
Logo.AutoButtonColor = false
Logo.Active = true
Logo.Parent = ScreenGui
Instance.new("UICorner", Logo).CornerRadius = UDim.new(1, 0)
local logoStroke = Instance.new("UIStroke", Logo)
logoStroke.Color = Color3.fromRGB(0, 200, 255)
logoStroke.Thickness = 2

local dragging = false
local dragStart, startPos
local tapStart = nil

Logo.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Logo.Position
        tapStart = input.Position
    end
end)

Logo.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
        if tapStart then
            local moved = (input.Position - tapStart).Magnitude
            if moved < 10 then
                Panel.Visible = not Panel.Visible
            end
            tapStart = nil
        end
    end
end)

track(UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Logo.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end))

-- ============================================================
-- UI HELPERS
-- ============================================================
local function makeButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    btn.TextColor3 = Color3.fromRGB(230, 230, 240)
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.AutoButtonColor = true
    btn.Parent = Scroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function makeSlider(label, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 52)
    frame.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    frame.BorderSizePixel = 0
    frame.Parent = Scroll
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 20)
    lbl.Position = UDim2.new(0, 5, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = label .. ": " .. default
    lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -20, 0, 14)
    bar.Position = UDim2.new(0, 10, 0, 30)
    bar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    bar.BorderSizePixel = 0
    bar.Parent = frame
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    fill.BorderSizePixel = 0
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local active = false
    local function update(input)
        local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * rel)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        lbl.Text = label .. ": " .. val
        callback(val)
    end
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            active = true; update(i)
        end
    end)
    track(UserInputService.InputChanged:Connect(function(i)
        if active and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            update(i)
        end
    end))
    track(UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            active = false
        end
    end))
    return frame
end

-- ============================================================
-- FLY NOCLIP
-- ============================================================
local flySpeed = 50
local flying = false
local flyConn, bodyVelocity, bodyGyro

local function stopFly()
    flying = false
    _G.__FLYING = false
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
            if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
            hrp.Velocity = Vector3.zero
        end
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = true end
        end
    end
end

local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    flying = true
    _G.__FLYING = true
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = false end
    end
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = hrp
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 10000
    bodyGyro.D = 500
    bodyGyro.Parent = hrp

    flyConn = RunService.RenderStepped:Connect(function()
        if not flying or not hrp.Parent then stopFly(); return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local moveDir = humanoid and humanoid.MoveDirection or Vector3.zero
        local camCF = Camera.CFrame
        local flatMove = Vector3.new(moveDir.X, 0, moveDir.Z)
        local localMove = camCF:VectorToWorldSpace(flatMove)
        local vertical = 0
        local state = humanoid and humanoid:GetState()
        if state == Enum.HumanoidStateType.Jumping then vertical = 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vertical = -1 end
        bodyVelocity.Velocity = (localMove * flySpeed) + Vector3.new(0, vertical * flySpeed, 0)
        bodyGyro.CFrame = camCF
    end)
end

makeButton("✈ BẬT/TẮT FLY NOCLIP", function() if flying then stopFly() else startFly() end end)
makeSlider("Tốc độ bay", 10, 300, 50, function(v) flySpeed = v end)

-- ============================================================
-- ESP — Universal detector (không cần Humanoid)
-- ============================================================
local espFolder = Instance.new("Folder", (gethui and gethui()) or CoreGui)
espFolder.Name = "MyMenuGUI_ESP"

local espObjects = {}
local function createESP(adornee, color, text)
    if not adornee or espObjects[adornee] then return end
    local bb = Instance.new("BillboardGui")
    bb.Name = "ESP_BB"
    bb.Adornee = adornee
    bb.Size = UDim2.new(0, 200, 0, 40)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = espFolder
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Parent = bb
    local hl = Instance.new("Highlight")
    hl.Name = "ESP_HL"
    hl.Adornee = adornee
    hl.FillColor = color
    hl.OutlineColor = color
    hl.FillTransparency = 0.55
    hl.OutlineTransparency = 0
    hl.Parent = espFolder
    espObjects[adornee] = {bb = bb, hl = hl}
end

local function clearESP()
    for _, obj in pairs(espObjects) do
        pcall(function() obj.bb:Destroy() end)
        pcall(function() obj.hl:Destroy() end)
    end
    table.clear(espObjects)
end

local espStates = { players = false, monsters = false, npcs = false, items = false }

local function isPlayerChar(model)
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl.Character == model then return true end
    end
    return false
end

local function hasPlayerDescendant(model)
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl.Character and model:IsDescendantOf(pl.Character) then return true end
    end
    return false
end

local MONSTER_KEYWORDS = {"monster","enemy","mob","boss","zombie","creep","hostile","undead","demon","slime","skeleton","goblin","orc","troll","wolf","bear","spider","dragon","raider","bandit","thief","ghost","wraith","mutant","beast","creature","brute","grunt","minion","quái","địch","quai","dich"}
local NPC_KEYWORDS = {"npc","vendor","shop","quest","trader","guide","narrator","citizen","villager","merchant","trainer","elder","child","dummy","target"}
local ITEM_KEYWORDS = {"item","pickup","coin","drop","loot","chest","crate","barrel","reward","gem","gold","weapon","sword","gun","food","potion"}

local function nameHas(model, list)
    local n = model.Name:lower()
    for _, k in ipairs(list) do
        if n:find(k, 1, true) then return true end
    end
    return false
end

local function hasHumanoidOrAnim(model)
    return model:FindFirstChildOfClass("Humanoid") ~= nil or model:FindFirstChildOfClass("Animator") ~= nil
end

local function hasTag(model, tags)
    for _, t in ipairs(tags) do
        if CollectionService:HasTag(model, t) then return true end
    end
    return false
end

local function isMonster(model)
    if not model:IsA("Model") then return false end
    if isPlayerChar(model) or hasPlayerDescendant(model) then return false end

    if hasTag(model, {"Enemy","Monster","Mob","Boss","Hostile","HostileMob"}) then return true end

    local hum = model:FindFirstChildOfClass("Humanoid")
    if hum then
        if hum.Health > 0 then return true end
        if hum.MaxHealth and hum.MaxHealth > 0 then return true end
    end

    if nameHas(model, MONSTER_KEYWORDS) then return true end

    if model:GetAttribute("IsEnemy") or model:GetAttribute("Enemy") or model:GetAttribute("Monster") or model:GetAttribute("Hostile") then return true end
    if model:GetAttribute("Health") or model:GetAttribute("HP") or model:GetAttribute("MaxHealth") then return true end

    return false
end

local function isNPC(model)
    if not model:IsA("Model") then return false end
    if isPlayerChar(model) or hasPlayerDescendant(model) then return false end
    if isMonster(model) then return false end

    if hasTag(model, {"NPC","Friendly","Villager"}) then return true end
    if hasHumanoidOrAnim(model) then return true end
    if nameHas(model, NPC_KEYWORDS) then return true end
    if model:GetAttribute("IsNPC") or model:GetAttribute("NPC") then return true end
    return false
end

local function isItem(model)
    if model:IsA("Tool") then return true end
    if not (model:IsA("Model") or model:IsA("BasePart")) then return false end
    if isPlayerChar(model) or hasPlayerDescendant(model) then return false end
    if hasTag(model, {"Item","Pickup","Loot","Coin","Collectible"}) then return true end
    if model:FindFirstChildOfClass("Tool") then return true end
    if nameHas(model, ITEM_KEYWORDS) then return true end
    if model:GetAttribute("IsItem") or model:GetAttribute("Collectible") then return true end
    return false
end

local function findRoot(model)
    if model:IsA("BasePart") then return model end
    return model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("Head")
        or model:FindFirstChild("Torso")
        or model:FindFirstChild("UpperTorso")
        or model.PrimaryPart
        or model:FindFirstChildWhichIsA("BasePart")
end

local function scanAll()
    clearESP()
    local seen = {}

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local root = findRoot(obj)
            if root and not seen[obj] then
                if espStates.players then
                    for _, pl in ipairs(Players:GetPlayers()) do
                        if pl.Character == obj then
                            createESP(root, Color3.fromRGB(0, 255, 100), "[P] " .. pl.Name)
                            seen[obj] = true
                        end
                    end
                end
                if not seen[obj] and espStates.monsters and isMonster(obj) then
                    createESP(root, Color3.fromRGB(255, 50, 50), "[MONSTER] " .. obj.Name)
                    seen[obj] = true
                end
                if not seen[obj] and espStates.npcs and isNPC(obj) then
                    createESP(root, Color3.fromRGB(255, 220, 0), "[NPC] " .. obj.Name)
                    seen[obj] = true
                end
                if not seen[obj] and espStates.items and isItem(obj) then
                    createESP(root, Color3.fromRGB(0, 200, 255), "[ITEM] " .. obj.Name)
                    seen[obj] = true
                end
            end
        end
    end

    if espStates.monsters or espStates.npcs or espStates.items then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not seen[obj] then
                if obj:GetAttribute("Health") or obj:GetAttribute("HP") or obj:GetAttribute("IsEnemy")
                   or obj:GetAttribute("Enemy") or obj:GetAttribute("IsNPC")
                   or hasTag(obj, {"Enemy","Monster","NPC","Item","Pickup"})
                   or nameHas(obj, MONSTER_KEYWORDS)
                   or nameHas(obj, NPC_KEYWORDS)
                   or nameHas(obj, ITEM_KEYWORDS)
                then
                    if espStates.monsters and (obj:GetAttribute("Health") or obj:GetAttribute("HP") or hasTag(obj, {"Enemy","Monster"}) or nameHas(obj, MONSTER_KEYWORDS)) then
                        createESP(obj, Color3.fromRGB(255, 50, 50), "[MONSTER] " .. obj.Name)
                    elseif espStates.npcs and (hasTag(obj, {"NPC"}) or nameHas(obj, NPC_KEYWORDS)) then
                        createESP(obj, Color3.fromRGB(255, 220, 0), "[NPC] " .. obj.Name)
                    elseif espStates.items and (hasTag(obj, {"Item","Pickup"}) or nameHas(obj, ITEM_KEYWORDS)) then
                        createESP(obj, Color3.fromRGB(0, 200, 255), "[ITEM] " .. obj.Name)
                    end
                    seen[obj] = true
                end
            end
        end
    end
end

makeButton("👤 ESP PLAYERS", function() espStates.players = not espStates.players; scanAll() end)
makeButton("👹 ESP MONSTERS", function() espStates.monsters = not espStates.monsters; scanAll() end)
makeButton("🧍 ESP NPCs", function() espStates.npcs = not espStates.npcs; scanAll() end)
makeButton("💰 ESP ITEMS", function() espStates.items = not espStates.items; scanAll() end)

task.spawn(function()
    while ScreenGui.Parent do
        task.wait(3)
        if espStates.players or espStates.monsters or espStates.npcs or espStates.items then
            scanAll()
        end
    end
end)

-- ============================================================
-- MAP TELEPORT
-- ============================================================
local function computeWorldBounds()
    if _G.__MAP_BOUNDS then return _G.__MAP_BOUNDS end
    local minX, maxX, minZ, maxZ = math.huge, -math.huge, math.huge, -math.huge
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local isChar = false
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl.Character and obj:IsDescendantOf(pl.Character) then isChar = true; break end
            end
            if not isChar then
                local p = obj.Position
                minX = math.min(minX, p.X); maxX = math.max(maxX, p.X)
                minZ = math.min(minZ, p.Z); maxZ = math.max(maxZ, p.Z)
            end
        end
    end
    if minX == math.huge then minX, maxX, minZ, maxZ = -500, 500, -500, 500 end
    local padX = (maxX - minX) * 0.05
    local padZ = (maxZ - minZ) * 0.05
    _G.__MAP_BOUNDS = { minX = minX - padX, maxX = maxX + padX, minZ = minZ - padZ, maxZ = maxZ + padZ }
    return _G.__MAP_BOUNDS
end

local function teleportTo(pos)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    safeDelay()
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
end

local function buildMapPanel()
    local bounds = computeWorldBounds()
    local rangeX = bounds.maxX - bounds.minX
    local rangeZ = bounds.maxZ - bounds.minZ

    local mapGui = Instance.new("Frame")
    mapGui.Name = "MyMenuGUI_Map"
    mapGui.Size = UDim2.new(1, -40, 1, -100)
    mapGui.Position = UDim2.new(0, 20, 0, 60)
    mapGui.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    mapGui.BorderSizePixel = 0
    mapGui.Parent = ScreenGui
    Instance.new("UICorner", mapGui).CornerRadius = UDim.new(0, 8)

    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, -50, 0, 30)
    header.Position = UDim2.new(0, 10, 0, 15)
    header.BackgroundTransparency = 1
    header.Text = MAP_IMAGE_ID ~= "" and "CHẠM ẢNH MAP ĐỂ DỊCH CHUYỂN" or
        ("BOUNDS: " .. math.floor(bounds.minX) .. "," .. math.floor(bounds.minZ) .. " → " .. math.floor(bounds.maxX) .. "," .. math.floor(bounds.maxZ))
    header.TextColor3 = Color3.fromRGB(0, 200, 255)
    header.Font = Enum.Font.GothamBold
    header.TextSize = 13
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = mapGui

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 40, 0, 40)
    close.Position = UDim2.new(1, -45, 0, 5)
    close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    close.Text = "X"; close.TextColor3 = Color3.new(1,1,1)
    close.Font = Enum.Font.GothamBold
    close.Parent = mapGui
    Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)
    close.MouseButton1Click:Connect(function() mapGui:Destroy() end)

    local canvas = Instance.new("Frame")
    canvas.Size = UDim2.new(1, -20, 1, -60)
    canvas.Position = UDim2.new(0, 10, 0, 50)
    canvas.BackgroundColor3 = Color3.fromRGB(20, 30, 40)
    canvas.BorderSizePixel = 0
    canvas.ClipsDescendants = true
    canvas.Parent = mapGui
    Instance.new("UICorner", canvas).CornerRadius = UDim.new(0, 6)

    if MAP_IMAGE_ID ~= "" then
        local img = Instance.new("ImageLabel")
        img.Size = UDim2.new(1, 0, 1, 0)
        img.BackgroundTransparency = 1
        img.Image = MAP_IMAGE_ID
        img.ScaleType = Enum.ScaleType.Stretch
        img.Parent = canvas
    end

    local markers = Instance.new("Frame")
    markers.Size = UDim2.new(1, 0, 1, 0)
    markers.BackgroundTransparency = 1
    markers.Parent = canvas

    local function worldToRel(p) return (p.X - bounds.minX) / rangeX, (p.Z - bounds.minZ) / rangeZ end

    local function addDot(worldPos, color, size)
        local rx, rz = worldToRel(worldPos)
        local d = Instance.new("Frame")
        d.Size = UDim2.new(0, size, 0, size)
        d.AnchorPoint = Vector2.new(0.5, 0.5)
        d.Position = UDim2.new(rx, 0, rz, 0)
        d.BackgroundColor3 = color
        d.BorderSizePixel = 0
        d.Parent = markers
        Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
    end

    local function refreshMarkers()
        for _, v in ipairs(markers:GetChildren()) do v:Destroy() end
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            addDot(char.HumanoidRootPart.Position, Color3.fromRGB(0, 255, 100), 9)
        end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and isMonster(obj) then
                local root = findRoot(obj)
                if root then addDot(root.Position, Color3.fromRGB(255, 50, 50), 5) end
            end
        end
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                addDot(pl.Character.HumanoidRootPart.Position, Color3.fromRGB(255, 220, 0), 6)
            end
        end
    end

    refreshMarkers()
    task.spawn(function() while mapGui.Parent do task.wait(1); refreshMarkers() end end)

    canvas.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local relX = (input.Position.X - canvas.AbsolutePosition.X) / canvas.AbsoluteSize.X
            local relZ = (input.Position.Y - canvas.AbsolutePosition.Y) / canvas.AbsoluteSize.Y
            if relX < 0 or relX > 1 or relZ < 0 or relZ > 1 then return end
            local wx = bounds.minX + relX * rangeX
            local wz = bounds.minZ + relZ * rangeZ
            local rp = RaycastParams.new()
            rp.FilterDescendantsInstances = {LocalPlayer.Character}
            rp.FilterType = Enum.RaycastFilterType.Exclude
            local hit = Workspace:Raycast(Vector3.new(wx, 500, wz), Vector3.new(0, -1000, 0), rp)
            local y = hit and hit.Position.Y + 5 or 50
            teleportTo(Vector3.new(wx, y, wz))
            mapGui:Destroy()
        end
    end)
end

makeButton("🗺 MAP TELEPORT", buildMapPanel)
makeButton("🔄 RESET BOUNDS", function()
    _G.__MAP_BOUNDS = nil
    print("[MAP] bounds cleared")
end)

-- ============================================================
-- PLAYER TELEPORT
-- ============================================================
local function buildPlayerList()
    local listGui = Instance.new("Frame")
    listGui.Name = "MyMenuGUI_PlayerList"
    listGui.Size = UDim2.new(0, 260, 0, 350)
    listGui.Position = UDim2.new(0.5, -130, 0.5, -175)
    listGui.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    listGui.BorderSizePixel = 0
    listGui.Parent = ScreenGui
    Instance.new("UICorner", listGui).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", listGui).Color = Color3.fromRGB(0, 200, 255)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 0, 32)
    t.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    t.Text = "CHỌN NGƯỜI CHƠI"
    t.TextColor3 = Color3.fromRGB(0, 200, 255)
    t.Font = Enum.Font.GothamBold
    t.TextSize = 14
    t.Parent = listGui
    Instance.new("UICorner", t).CornerRadius = UDim.new(0, 8)

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 28, 0, 28)
    close.Position = UDim2.new(1, -30, 0, 2)
    close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    close.Text = "X"; close.TextColor3 = Color3.new(1,1,1)
    close.Font = Enum.Font.GothamBold
    close.Parent = listGui
    Instance.new("UICorner", close).CornerRadius = UDim.new(0, 4)
    close.MouseButton1Click:Connect(function() listGui:Destroy() end)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -50)
    scroll.Position = UDim2.new(0, 5, 0, 40)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 6
    scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = listGui
    Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5)

    local function rebuild()
        for _, v in ipairs(scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer then
                local b = Instance.new("TextButton")
                b.Size = UDim2.new(1, -10, 0, 36)
                b.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
                b.TextColor3 = Color3.fromRGB(230, 230, 240)
                b.Text = pl.Name
                b.Font = Enum.Font.Gotham
                b.TextSize = 13
                b.Parent = scroll
                Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
                b.MouseButton1Click:Connect(function()
                    if pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                        teleportTo(pl.Character.HumanoidRootPart.Position)
                        listGui:Destroy()
                    end
                end)
            end
        end
    end
    rebuild()
    task.spawn(function() while listGui.Parent do task.wait(2); rebuild() end end)
end

makeButton("🧑 DỊCH CHUYỂN ĐẾN NGƯỜI CHƠI", buildPlayerList)

-- ============================================================
-- CLEANUP on respawn
-- ============================================================
track(LocalPlayer.CharacterAdded:Connect(function()
    if flying then stopFly() end
end))
