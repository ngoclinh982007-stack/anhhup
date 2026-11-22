-- language: Lua (Luau), target: Roblox mobile executor
-- ============================================================
-- ROBLOX MOBILE MULTI-MENU v5 (Tiếng Việt)
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
-- CẤU HÌNH
-- ============================================================
-- ĐIỀN ID ẢNH BẢN ĐỒ VÀO ĐÂY (ví dụ: "rbxassetid://123456789")
-- Để trống thì chỉ hiện các chấm đen (không có hình nhà cửa)
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
-- CHỐNG BAN CƠ BẢN
-- ============================================================
pcall(function()
    if hookfunction and LocalPlayer.Kick then
        local old = LocalPlayer.Kick
        hookfunction(LocalPlayer.Kick, function(self, msg) return old(self, "") end)
    end
end)
local function safeDelay() task.wait(math.random(80, 180) / 1000) end

-- ============================================================
-- GIAO DIỆN
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MyMenuGUI_" .. tostring(math.random(10000, 99999))
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = (gethui and gethui()) or CoreGui

-- PANEL
local Panel = Instance.new("Frame")
Panel.Name = "Panel"
Panel.Size = UDim2.new(0, 300, 0, math.min(520, Camera.ViewportSize.Y - 140))
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

-- NÚT X ĐÓNG
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = Panel
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function() Panel.Visible = false end)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -46)
Scroll.Position = UDim2.new(0, 5, 0, 40)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 6
Scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.ScrollingDirection = Enum.ScrollingDirection.Y
Scroll.Parent = Panel
local listLayout = Instance.new("UIListLayout", Scroll)
listLayout.Padding = UDim.new(0, 6)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
local pad = Instance.new("UIPadding", Scroll)
pad.PaddingTop = UDim.new(0, 4)
pad.PaddingBottom = UDim.new(0, 8)

-- LOGO
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
        dragging = true; dragStart = input.Position; startPos = Logo.Position; tapStart = input.Position
    end
end)
Logo.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
        if tapStart and (input.Position - tapStart).Magnitude < 10 then
            Panel.Visible = not Panel.Visible
        end
        tapStart = nil
    end
end)
track(UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Logo.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end))

-- UI HELPERS
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
    lbl.Size = UDim2.new(1, -10, 0, 20); lbl.Position = UDim2.new(0, 5, 0, 4)
    lbl.BackgroundTransparency = 1; lbl.Text = label .. ": " .. default
    lbl.TextColor3 = Color3.fromRGB(200, 200, 220); lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = frame
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -20, 0, 14); bar.Position = UDim2.new(0, 10, 0, 30)
    bar.BackgroundColor3 = Color3.fromRGB(40, 40, 55); bar.BorderSizePixel = 0; bar.Parent = frame
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255); fill.BorderSizePixel = 0; fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local active = false
    local function update(input)
        local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * rel)
        fill.Size = UDim2.new(rel, 0, 1, 0); lbl.Text = label .. ": " .. val; callback(val)
    end
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then active = true; update(i) end end)
    track(UserInputService.InputChanged:Connect(function(i) if active and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then update(i) end end))
    track(UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then active = false end end))
    return frame
end

-- ============================================================
-- FLY NOCLIP (Bản mobile có nút Lên/Xuống)
-- ============================================================
local flySpeed = 50
local flying = false
local flyVertical = 0 -- 1 = lên, -1 = xuống, 0 = đứng yên
local flyConn, bodyVelocity, bodyGyro

local function stopFly()
    flying = false; _G.__FLYING = false; flyVertical = 0
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
    flying = true; _G.__FLYING = true
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = false end
    end
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.zero; bodyVelocity.Parent = hrp
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 10000; bodyGyro.D = 500; bodyGyro.Parent = hrp

    flyConn = RunService.RenderStepped:Connect(function()
        if not flying or not hrp.Parent then stopFly(); return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local moveDir = humanoid and humanoid.MoveDirection or Vector3.zero
        local camCF = Camera.CFrame
        local flatMove = Vector3.new(moveDir.X, 0, moveDir.Z)
        local localMove = camCF:VectorToWorldSpace(flatMove)
        
        -- Lấy chiều lên/xuống từ nút bấm
        local vertical = flyVertical * flySpeed
        
        bodyVelocity.Velocity = (localMove * flySpeed) + Vector3.new(0, vertical, 0)
        bodyGyro.CFrame = camCF
    end)
end

local flyBtn = makeButton("✈ BẬT/TẮT BAY XUYÊN TƯỜNG", function() 
    if flying then stopFly() else startFly() end 
end)
makeSlider("Tốc độ bay", 10, 300, 50, function(v) flySpeed = v end)

-- NÚT LÊN XUỐNG
local verticalFrame = Instance.new("Frame")
verticalFrame.Size = UDim2.new(1, -10, 0, 38)
verticalFrame.BackgroundTransparency = 1
verticalFrame.Parent = Scroll

local upBtn = Instance.new("TextButton")
upBtn.Size = UDim2.new(0.48, 0, 1, 0)
upBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
upBtn.Text = "⬆ LÊN"
upBtn.TextColor3 = Color3.new(1,1,1)
upBtn.Font = Enum.Font.GothamBold
upBtn.Parent = verticalFrame
Instance.new("UICorner", upBtn).CornerRadius = UDim.new(0, 6)

local downBtn = Instance.new("TextButton")
downBtn.Size = UDim2.new(0.48, 0, 1, 0)
downBtn.Position = UDim2.new(0.52, 0, 0, 0)
downBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
downBtn.Text = "⬇ XUỐNG"
downBtn.TextColor3 = Color3.new(1,1,1)
downBtn.Font = Enum.Font.GothamBold
downBtn.Parent = verticalFrame
Instance.new("UICorner", downBtn).CornerRadius = UDim.new(0, 6)

local function bindHold(btn, val)
    btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then flyVertical = val end end)
    btn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then flyVertical = 0 end end)
end
bindHold(upBtn, 1)
bindHold(downBtn, -1)

-- ============================================================
-- ESP QUÉT MỌI THỨ (Có bộ đếm)
-- ============================================================
local espFolder = Instance.new("Folder", (gethui and gethui()) or CoreGui)
espFolder.Name = "MyMenuGUI_ESP"
local espObjects = {}

local function createESP(adornee, color, text)
    if not adornee or espObjects[adornee] then return end
    local bb = Instance.new("BillboardGui")
    bb.Name = "ESP_BB"; bb.Adornee = adornee; bb.Size = UDim2.new(0, 200, 0, 40)
    bb.StudsOffset = Vector3.new(0, 3, 0); bb.AlwaysOnTop = true; bb.Parent = espFolder
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 1
    label.Text = text; label.TextColor3 = color; label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0, 0, 0); label.Font = Enum.Font.GothamBold
    label.TextScaled = true; label.Parent = bb
    local hl = Instance.new("Highlight")
    hl.Name = "ESP_HL"; hl.Adornee = adornee; hl.FillColor = color
    hl.OutlineColor = color; hl.FillTransparency = 0.55; hl.OutlineTransparency = 0; hl.Parent = espFolder
    espObjects[adornee] = {bb = bb, hl = hl}
end

local function clearESP()
    for _, obj in pairs(espObjects) do pcall(function() obj.bb:Destroy() end); pcall(function() obj.hl:Destroy() end) end
    table.clear(espObjects)
end

local espStates = { players = false, monsters = false, npcs = false, items = false }
local counts = { players = 0, monsters = 0, npcs = 0, items = 0 }

local function isPlayerChar(m) for _, p in ipairs(Players:GetPlayers()) do if p.Character == m then return true end end return false end
local function hasPlayerDesc(m) for _, p in ipairs(Players:GetPlayers()) do if p.Character and m:IsDescendantOf(p.Character) then return true end end return false end

local MONSTER_KEYWORDS = {"monster","enemy","mob","boss","zombie","creep","hostile","undead","demon","slime","skeleton","goblin","orc","troll","wolf","bear","spider","dragon","quái","quai","địch"}
local ITEM_KEYWORDS = {"item","pickup","coin","drop","loot","chest","crate","barrel","reward","gem","gold","weapon","sword","gun","food","potion","collect"}

local function nameHas(m, list) local n = m.Name:lower() for _, k in ipairs(list) do if n:find(k, 1, true) then return true end end return false end
local function hasTag(m, tags) for _, t in ipairs(tags) do if CollectionService:HasTag(m, t) then return true end end return false end

local function isMonster(m)
    if not m:IsA("Model") or isPlayerChar(m) or hasPlayerDesc(m) then return false end
    if hasTag(m, {"Enemy","Monster","Mob","Boss"}) then return true end
    local hum = m:FindFirstChildOfClass("Humanoid")
    if hum and (hum.Health > 0 or (hum.MaxHealth and hum.MaxHealth > 0)) then return true end
    if nameHas(m, MONSTER_KEYWORDS) then return true end
    if m:GetAttribute("Health") or m:GetAttribute("HP") or m:GetAttribute("Enemy") then return true end
    return false
end

local function isNPC(m)
    if not m:IsA("Model") or isPlayerChar(m) or hasPlayerDesc(m) or isMonster(m) then return false end
    if hasTag(m, {"NPC","Friendly","Villager"}) then return true end
    if m:FindFirstChildOfClass("Humanoid") or m:FindFirstChildOfClass("Animator") then return true end
    return false
end

local function isItem(m)
    if isPlayerChar(m) or hasPlayerDesc(m) then return false end
    if hasTag(m, {"Item","Pickup","Loot","Coin","Weapon"}) then return true end
    if m:IsA("Tool") or m:FindFirstChildOfClass("Tool") or m:FindFirstChildWhichIsA("Tool") then return true end
    if m:IsA("MeshPart") or m:IsA("Part") then 
        if m.Parent and m.Parent:IsA("Folder") and nameHas(m.Parent, ITEM_KEYWORDS) then return true end
    end
    if m:IsA("Model") and nameHas(m, ITEM_KEYWORDS) then return true end
    return false
end

local function findRoot(m)
    if m:IsA("BasePart") then return m end
    return m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Head") or m:FindFirstChild("Torso") or m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
end

local function scanAll()
    clearESP()
    local seen = {}
    counts.players = 0; counts.monsters = 0; counts.npcs = 0; counts.items = 0

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local root = findRoot(obj)
            if root and not seen[obj] then
                if espStates.players then
                    for _, pl in ipairs(Players:GetPlayers()) do
                        if pl.Character == obj then
                            createESP(root, Color3.fromRGB(0, 255, 100), "[P] " .. pl.Name)
                            seen[obj] = true; counts.players = counts.players + 1
                        end
                    end
                end
                if not seen[obj] and espStates.monsters and isMonster(obj) then
                    createESP(root, Color3.fromRGB(255, 50, 50), "[QUÁI] " .. obj.Name)
                    seen[obj] = true; counts.monsters = counts.monsters + 1
                end
                if not seen[obj] and espStates.npcs and isNPC(obj) then
                    createESP(root, Color3.fromRGB(255, 220, 0), "[NPC] " .. obj.Name)
                    seen[obj] = true; counts.npcs = counts.npcs + 1
                end
                if not seen[obj] and espStates.items and isItem(obj) then
                    createESP(root, Color3.fromRGB(0, 200, 255), "[ĐỒ] " .. obj.Name)
                    seen[obj] = true; counts.items = counts.items + 1
                end
            end
        elseif (obj:IsA("Part") or obj:IsA("MeshPart")) and not seen[obj] then
            if espStates.monsters and (nameHas(obj, MONSTER_KEYWORDS) or obj:GetAttribute("Enemy")) then
                createESP(obj, Color3.fromRGB(255, 50, 50), "[QUÁI] " .. obj.Name)
                seen[obj] = true; counts.monsters = counts.monsters + 1
            elseif espStates.items and (nameHas(obj, ITEM_KEYWORDS) or hasTag(obj, {"Item","Loot"})) then
                createESP(obj, Color3.fromRGB(0, 200, 255), "[ĐỒ] " .. obj.Name)
                seen[obj] = true; counts.items = counts.items + 1
            end
        end
    end

    -- Cập nhật số lượng lên nút
    espBtns.players.Text = (espStates.players and "✅" or "❌") .. " Người chơi (" .. counts.players .. ")"
    espBtns.monsters.Text = (espStates.monsters and "✅" or "❌") .. " Quái (" .. counts.monsters .. ")"
    espBtns.npcs.Text = (espStates.npcs and "✅" or "❌") .. " NPC (" .. counts.npcs .. ")"
    espBtns.items.Text = (espStates.items and "✅" or "❌") .. " Vật phẩm (" .. counts.items .. ")"
end

local espBtns = {}
espBtns.players = makeButton("❌ Người chơi (0)", function() espStates.players = not espStates.players; scanAll() end)
espBtns.monsters = makeButton("❌ Quái (0)", function() espStates.monsters = not espStates.monsters; scanAll() end)
espBtns.npcs = makeButton("❌ NPC (0)", function() espStates.npcs = not espStates.npcs; scanAll() end)
espBtns.items = makeButton("❌ Vật phẩm (0)", function() espStates.items = not espStates.items; scanAll() end)

task.spawn(function()
    while ScreenGui.Parent do
        task.wait(3)
        if espStates.players or espStates.monsters or espStates.npcs or espStates.items then scanAll() end
    end
end)

-- ============================================================
-- BẢN ĐỒ (MAP TELEPORT)
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
    _G.__MAP_BOUNDS = { minX = minX, maxX = maxX, minZ = minZ, maxZ = maxZ }
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
    mapGui.BorderSizePixel = 0; mapGui.Parent = ScreenGui
    Instance.new("UICorner", mapGui).CornerRadius = UDim.new(0, 8)

    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, -50, 0, 30); header.Position = UDim2.new(0, 10, 0, 15)
    header.BackgroundTransparency = 1; header.Text = "CHẠM VÀO BẢN ĐỒ ĐỂ DỊCH CHUYỂN"
    header.TextColor3 = Color3.fromRGB(0, 200, 255); header.Font = Enum.Font.GothamBold
    header.TextSize = 13; header.TextXAlignment = Enum.TextXAlignment.Left; header.Parent = mapGui

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 40, 0, 40); close.Position = UDim2.new(1, -45, 0, 5)
    close.BackgroundColor3 = Color3.fromRGB(200, 50, 50); close.Text = "X"
    close.TextColor3 = Color3.new(1,1,1); close.Font = Enum.Font.GothamBold; close.Parent = mapGui
    Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)
    close.MouseButton1Click:Connect(function() mapGui:Destroy() end)

    local canvas = Instance.new("Frame")
    canvas.Size = UDim2.new(1, -20, 1, -60); canvas.Position = UDim2.new(0, 10, 0, 50)
    canvas.BackgroundColor3 = Color3.fromRGB(20, 30, 40); canvas.BorderSizePixel = 0
    canvas.ClipsDescendants = true; canvas.Parent = mapGui
    Instance.new("UICorner", canvas).CornerRadius = UDim.new(0, 6)

    if MAP_IMAGE_ID ~= "" then
        local img = Instance.new("ImageLabel")
        img.Size = UDim2.new(1, 0, 1, 0); img.BackgroundTransparency = 1
        img.Image = MAP_IMAGE_ID; img.ScaleType = Enum.ScaleType.Stretch; img.Parent = canvas
    end

    local markers = Instance.new("Frame")
    markers.Size = UDim2.new(1, 0, 1, 0); markers.BackgroundTransparency = 1; markers.Parent = canvas

    local function worldToRel(p) return (p.X - bounds.minX) / rangeX, (p.Z - bounds.minZ) / rangeZ end

    local function addDot(worldPos, color, size)
        local rx, rz = worldToRel(worldPos)
        local d = Instance.new("Frame")
        d.Size = UDim2.new(0, size, 0, size); d.AnchorPoint = Vector2.new(0.5, 0.5)
        d.Position = UDim2.new(rx, 0, rz, 0); d.BackgroundColor3 = color; d.BorderSizePixel = 0
        d.Parent = markers; Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
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
            rp.FilterDescendantsInstances = {LocalPlayer.Character}; rp.FilterType = Enum.RaycastFilterType.Exclude
            local hit = Workspace:Raycast(Vector3.new(wx, 500, wz), Vector3.new(0, -1000, 0), rp)
            local y = hit and hit.Position.Y + 5 or 50
            teleportTo(Vector3.new(wx, y, wz))
            mapGui:Destroy()
        end
    end)
end

makeButton("🗺 BẢN ĐỒ DỊCH CHUYỂN", buildMapPanel)
makeButton("🔄 LÀM MỚI BẢN ĐỒ", function() _G.__MAP_BOUNDS = nil; print("[MAP] Đã làm mới") end)

-- ============================================================
-- DỊCH CHUYỂN NGƯỜI CHƠI
-- ============================================================
local function buildPlayerList()
    local listGui = Instance.new("Frame")
    listGui.Name = "MyMenuGUI_PlayerList"; listGui.Size = UDim2.new(0, 260, 0, 350)
    listGui.Position = UDim2.new(0.5, -130, 0.5, -175); listGui.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    listGui.BorderSizePixel = 0; listGui.Parent = ScreenGui
    Instance.new("UICorner", listGui).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", listGui).Color = Color3.fromRGB(0, 200, 255)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 0, 32); t.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    t.Text = "CHỌN NGƯỜI CHƠI"; t.TextColor3 = Color3.fromRGB(0, 200, 255)
    t.Font = Enum.Font.GothamBold; t.TextSize = 14; t.Parent = listGui
    Instance.new("UICorner", t).CornerRadius = UDim.new(0, 8)

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 28, 0, 28); close.Position = UDim2.new(1, -30, 0, 2)
    close.BackgroundColor3 = Color3.fromRGB(200, 50, 50); close.Text = "X"
    close.TextColor3 = Color3.new(1,1,1); close.Font = Enum.Font.GothamBold; close.Parent = listGui
    Instance.new("UICorner", close).CornerRadius = UDim.new(0, 4)
    close.MouseButton1Click:Connect(function() listGui:Destroy() end)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -50); scroll.Position = UDim2.new(0, 5, 0, 40)
    scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 6; scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0); scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; scroll.Parent = listGui
    Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5)

    local function rebuild()
        for _, v in ipairs(scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer then
                local b = Instance.new("TextButton")
                b.Size = UDim2.new(1, -10, 0, 36); b.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
                b.TextColor3 = Color3.fromRGB(230, 230, 240); b.Text = pl.Name
                b.Font = Enum.Font.Gotham; b.TextSize = 13; b.Parent = scroll
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
-- CLEANUP
-- ============================================================
track(LocalPlayer.CharacterAdded:Connect(function()
    if flying then stopFly() end
end))
