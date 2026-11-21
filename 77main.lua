--== ANON MENU V4 - MOBILE 100% ==--
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local Cam = workspace.CurrentCamera

--== GUI SETUP ==--
local GUI = Instance.new("ScreenGui")
GUI.Name = "ANON_V4"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.DisplayOrder = 2147483647
GUI.Parent = LP:WaitForChild("PlayerGui")

--== LOGO ==--
local logo = Instance.new("TextButton")
logo.Size = UDim2.new(0, 55, 0, 55)
logo.Position = UDim2.new(0, 20, 0, 100)
logo.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
logo.Text = "A"
logo.TextColor3 = Color3.fromRGB(0, 220, 180)
logo.Font = Enum.Font.GothamBlack
logo.TextSize = 28
logo.Parent = GUI
Instance.new("UICorner", logo).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", logo).Color = Color3.fromRGB(0, 220, 180)

--== PANEL ==--
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 260, 0, 300)
panel.Position = UDim2.new(0.5, -130, 0.5, -150)
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
panel.Visible = false
panel.Active = true
panel.Parent = GUI
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", panel).Color = Color3.fromRGB(0, 220, 180)

-- Thanh kéo
local grip = Instance.new("TextButton")
grip.Size = UDim2.new(1, 0, 0, 36)
grip.BackgroundTransparency = 1
grip.Text = "  ANON MENU (Kéo)"
grip.TextColor3 = Color3.fromRGB(0, 220, 180)
grip.Font = Enum.Font.GothamBold
grip.TextSize = 13
grip.TextXAlignment = Enum.TextXAlignment.Left
grip.Parent = panel

-- Nút X
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 28, 0, 28)
close.Position = UDim2.new(1, -33, 0, 4)
close.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255, 100, 100)
close.Font = Enum.Font.GothamBold
close.Parent = panel
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)

-- Scroll
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -16, 1, -46)
scroll.Position = UDim2.new(0, 8, 0, 40)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 3
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = panel
local ll = Instance.new("UIListLayout", scroll)
ll.Padding = UDim.new(0, 4)
ll.SortOrder = Enum.SortOrder.LayoutOrder
ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0, 0, 0, ll.AbsoluteContentSize.Y + 8)
end)

--== KÉO THẢ ==--
local dragStart, startPos, dragging = nil, nil, false
grip.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart = i.Position; startPos = panel.Position; dragging = false
    end
end)
UIS.InputChanged:Connect(function(i)
    if dragStart and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = i.Position - dragStart
        if delta.Magnitude > 5 then
            dragging = true
            panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then dragStart = nil end
end)

logo.MouseButton1Click:Connect(function()
    if not dragging then panel.Visible = not panel.Visible end
end)
close.MouseButton1Click:Connect(function() panel.Visible = false end)

--== UI BUILDERS (DÙNG TEXTBUTTON CHUẨN) ==--
local function makeBtn(text, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 36)
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    b.Text = "  " .. text
    b.TextColor3 = Color3.fromRGB(230, 230, 240)
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 13
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.AutoButtonColor = false
    b.Parent = scroll
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    
    -- SỬA LỖI MOBILE: Dùng MouseButton1Click thay vì InputBegan để tránh xung đột Scroll
    b.MouseButton1Click:Connect(function()
        b.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        task.delay(0.1, function() b.BackgroundColor3 = Color3.fromRGB(35, 35, 45) end)
        if cb then pcall(cb, b) end
    end)
    return b
end

local function makeTog(text, def, cb)
    local state = def or false
    local b = makeBtn(text .. " [TẮT]", function()
        state = not state
        b.Text = "  " .. text .. " [" .. (state and "BẬT" or "TẮT") .. "]"
        b.TextColor3 = state and Color3.fromRGB(0, 220, 180) or Color3.fromRGB(230, 230, 240)
        cb(state)
    end)
    return b
end

--== CHỨC NĂNG: FLY + NOCLIP ==--
local flyState = { active = false, speed = 50, conn = nil, bp = nil, bg = nil }
local function getRoot() return LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") end

local function stopFly()
    flyState.active = false
    if flyState.conn then flyState.conn:Disconnect() end
    if flyState.bp then flyState.bp:Destroy() end
    if flyState.bg then flyState.bg:Destroy() end
    local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if h then h.PlatformStand = false end
end

local function startFly()
    local root = getRoot()
    if not root then return end
    flyState.bp = Instance.new("BodyPosition", root)
    flyState.bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyState.bp.P = 15000; flyState.bp.D = 1000
    flyState.bg = Instance.new("BodyGyro", root)
    flyState.bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    flyState.bg.P = 5000; flyState.bg.D = 500
    
    local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if h then h.PlatformStand = true end

    flyState.conn = RunService.RenderStepped:Connect(function()
        if not flyState.active then return end
        local r = getRoot()
        if not r or not flyState.bp then return end
        local dir = Vector3.zero
        local h2 = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if h2 then dir = h2.MoveDirection end
        
        if h2 and h2:GetState() == Enum.HumanoidStateType.Jumping then
            dir = dir + Vector3.new(0, 1, 0)
        end

        if dir.Magnitude > 0.05 then
            flyState.bp.Position = r.Position + dir.Unit * flyState.speed * 0.15
        else
            flyState.bp.Position = r.Position
        end
        flyState.bg.CFrame = Cam.CFrame
    end)
end

makeTog("Bay / Xuyên tường", false, function(s)
    flyState.active = s
    if s then startFly() else stopFly() end
end)

makeBtn("Tốc độ bay: 50", function(b)
    local list = {30, 50, 80, 120, 200, 350}
    local idx = 1
    for i = 1, #list do if list[i] == flyState.speed then idx = (i % #list) + 1 break end end
    flyState.speed = list[idx]
    b.Text = "  Tốc độ bay: " .. flyState.speed
end)

--== CHỨC NĂNG: ESP ==--
local espCache = {}
local function clearESP()
    for obj, data in pairs(espCache) do
        for _, v in ipairs(data) do 
            if v and v.Destroy then pcall(function() v:Destroy() end) end
        end
    end
    espCache = {}
end

local function createESP(obj, color, text)
    if espCache[obj] then return end
    local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
    if not part then return end
    
    local bb = Instance.new("BillboardGui", GUI)
    bb.Adornee = part
    bb.Size = UDim2.new(0, 80, 0, 25)
    bb.AlwaysOnTop = true
    local txt = Instance.new("TextLabel", bb)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Text = text
    txt.TextColor3 = color
    txt.TextStrokeTransparency = 0
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 11
    
    local hl = Instance.new("Highlight", GUI)
    hl.Adornee = obj
    hl.FillColor = color
    hl.FillTransparency = 0.5
    hl.OutlineColor = color
    
    espCache[obj] = { bb, hl }
end

local espRunning = false
makeTog("Hiện Quái / Người chơi", false, function(s)
    if s then
        if espRunning then return end
        espRunning = true
        task.spawn(function()
            while espRunning do
                task.wait(1.5)
                for obj, data in pairs(espCache) do
                    if not obj or not obj.Parent then
                        for _, v in ipairs(data) do pcall(function() v:Destroy() end) end
                        espCache[obj] = nil
                    end
                end
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("Model") and not espCache[v] and v ~= LP.Character then
                        if Players:GetPlayerFromCharacter(v) then
                            createESP(v, Color3.fromRGB(0, 255, 255), "Người chơi")
                        elseif v:FindFirstChildOfClass("Humanoid") then
                            createESP(v, Color3.fromRGB(255, 50, 50), "Quái")
                        end
                    end
                end
            end
        end)
    else
        espRunning = false
        task.wait(1.6)
        clearESP()
    end
end)

--== CHỨC NĂNG: BẢN ĐỒ 2D MINIMAP ==--
local mapGui = nil
local function openMap()
    if mapGui then mapGui:Destroy() end
    if not getRoot() then return end
    
    mapGui = Instance.new("Frame", GUI)
    mapGui.Size = UDim2.new(0, 320, 0, 340)
    mapGui.Position = UDim2.new(0.5, -160, 0.5, -170)
    mapGui.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Instance.new("UICorner", mapGui).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", mapGui).Color = Color3.fromRGB(0, 220, 180)
    
    local title = Instance.new("TextLabel", mapGui)
    title.Size = UDim2.new(1, -50, 0, 35)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "Bản đồ - Chạm để TP"
    title.TextColor3 = Color3.fromRGB(0, 220, 180)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local cBtn = Instance.new("TextButton", mapGui)
    cBtn.Size = UDim2.new(0, 28, 0, 28)
    cBtn.Position = UDim2.new(1, -33, 0, 4)
    cBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
    cBtn.Text = "X"
    cBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    Instance.new("UICorner", cBtn).CornerRadius = UDim.new(0, 6)
    cBtn.MouseButton1Click:Connect(function() mapGui:Destroy() mapGui = nil end)

    -- Frame chứa nội dung 2D
    local canvas = Instance.new("Frame", mapGui)
    canvas.Size = UDim2.new(1, -20, 1, -50)
    canvas.Position = UDim2.new(0, 10, 0, 40)
    canvas.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
    canvas.ClipsDescendants = true
    Instance.new("UICorner", canvas).CornerRadius = UDim.new(0, 6)
    
    -- Vẽ các Part lớn thành hình vuông (như bản đồ)
    local mapCenter = Vector3.new(0, 0, 0)
    local RANGE = 1000 -- Quét bán kính 1000 studs
    
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Size.X > 10 and v.Size.Z > 10 and v ~= getRoot() then
            local relX = (v.Position.X - mapCenter.X) / RANGE
            local relZ = (v.Position.Z - mapCenter.Z) / RANGE
            if math.abs(relX) <= 1 and math.abs(relZ) <= 1 then
                local dot = Instance.new("Frame", canvas)
                dot.AnchorPoint = Vector2.new(0.5, 0.5)
                -- Scale size to map
                dot.Size = UDim2.new(v.Size.X / (RANGE * 2), 0, v.Size.Z / (RANGE * 2), 0)
                dot.Position = UDim2.new(0.5 + relX * 0.5, 0, 0.5 + relZ * 0.5, 0)
                dot.BackgroundColor3 = Color3.fromRGB(80, 90, 100)
                dot.BorderSizePixel = 0
                dot.ZIndex = 2
            end
        end
    end
    
    -- Vẽ người chơi hiện tại
    local pMarker = Instance.new("Frame", canvas)
    pMarker.AnchorPoint = Vector2.new(0.5, 0.5)
    pMarker.Size = UDim2.new(0, 8, 0, 8)
    pMarker.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    pMarker.ZIndex = 3
    Instance.new("UICorner", pMarker).CornerRadius = UDim.new(1, 0)
    
    local pConn
    pConn = RunService.RenderStepped:Connect(function()
        if not mapGui or not mapGui.Parent then
            if pConn then pConn:Disconnect() end
            return
        end
        local r = getRoot()
        if not r then return end
        local rx = (r.Position.X - mapCenter.X) / RANGE
        local rz = (r.Position.Z - mapCenter.Z) / RANGE
        if math.abs(rx) <= 1 and math.abs(rz) <= 1 then
            pMarker.Position = UDim2.new(0.5 + rx * 0.5, 0, 0.5 + rz * 0.5, 0)
        end
    end)
    
    -- Chạm để dịch chuyển
    local touchBtn = Instance.new("TextButton", canvas)
    touchBtn.Size = UDim2.new(1, 0, 1, 0)
    touchBtn.BackgroundTransparency = 1
    touchBtn.Text = ""
    touchBtn.ZIndex = 4
    
    touchBtn.MouseButton1Click:Connect(function()
        local pos = UIS:GetMouseLocation()
        local abs = canvas.AbsolutePosition
        local sz = canvas.AbsoluteSize
        local rx = (pos.X - abs.X) / sz.X - 0.5
        local rz = (pos.Y - abs.Y) / sz.Y - 0.5
        
        local tX = mapCenter.X + rx * 2 * RANGE
        local tZ = mapCenter.Z + rz * 2 * RANGE
        
        pcall(function()
            local r = getRoot()
            if r then
                -- TP và dò tìm mặt đất (Raycast) để không bị rơi
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {LP.Character}
                local rayOrigin = Vector3.new(tX, 1000, tZ)
                local rayDir = Vector3.new(0, -2000, 0)
                local rayRes = workspace:Raycast(rayOrigin, rayDir, rayParams)
                
                local finalY = 50
                if rayRes then finalY = rayRes.Position.Y + 5 end
                
                r.CFrame = CFrame.new(tX, finalY, tZ)
            end
        end)
        if pConn then pConn:Disconnect() end
        mapGui:Destroy() mapGui = nil
    end)
end

makeBtn("Dịch chuyển (Bản đồ 2D)", openMap)

--== RESPAWN ==--
LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if flyState.active then stopFly() startFly() end
end)

print("[ANON V4] Loaded - Mobile Fixed")
