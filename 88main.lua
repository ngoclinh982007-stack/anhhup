--== ANON MENU V3 - MOBILE OPTIMIZED ==--
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local Cam = workspace.CurrentCamera

--== GUI SETUP ==--
local GUI = Instance.new("ScreenGui")
GUI.Name = "ANON_V3"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.DisplayOrder = 2147483647
GUI.Parent = LP:WaitForChild("PlayerGui")

--== LOGO ==--
local logo = Instance.new("TextButton")
logo.Size = UDim2.new(0, 60, 0, 60)
logo.Position = UDim2.new(0, 20, 0, 100)
logo.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
logo.Text = "A"
logo.TextColor3 = Color3.fromRGB(0, 220, 180)
logo.Font = Enum.Font.GothamBlack
logo.TextSize = 30
logo.Parent = GUI
Instance.new("UICorner", logo).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", logo).Color = Color3.fromRGB(0, 220, 180)

--== PANEL (SHORT & DRAGGABLE) ==--
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 280, 0, 320)
panel.Position = UDim2.new(0.5, -140, 0.5, -160)
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
panel.Visible = false
panel.Active = true
panel.Parent = GUI
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", panel).Color = Color3.fromRGB(0, 220, 180)

-- Thanh kéo (Grip)
local grip = Instance.new("TextButton")
grip.Size = UDim2.new(1, 0, 0, 40)
grip.BackgroundTransparency = 1
grip.Text = "  ANON MENU (Kéo)"
grip.TextColor3 = Color3.fromRGB(0, 220, 180)
grip.Font = Enum.Font.GothamBold
grip.TextSize = 14
grip.TextXAlignment = Enum.TextXAlignment.Left
grip.Parent = panel

-- Nút X
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -35, 0, 5)
close.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255, 100, 100)
close.Font = Enum.Font.GothamBold
close.Parent = panel
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)

-- Scroll list
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -50)
scroll.Position = UDim2.new(0, 10, 0, 45)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 3
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = panel
local ll = Instance.new("UIListLayout", scroll)
ll.Padding = UDim.new(0, 5)
ll.SortOrder = Enum.SortOrder.LayoutOrder
ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0, 0, 0, ll.AbsoluteContentSize.Y + 10)
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

--== UI BUILDERS (DÙNG TEXTBUTTON BẮT CHẠM) ==--
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
    
    b.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Hiệu ứng nhấn
            b.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            task.delay(0.15, function() b.BackgroundColor3 = Color3.fromRGB(35, 35, 45) end)
            if cb then pcall(cb) end
        end
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
        
        -- Mobile: Dùng Jump để bay lên
        if h2 and h2:GetState() == Enum.HumanoidStateType.Jumping then
            dir = dir + Vector3.new(0, 1, 0)
        end

        if dir.Magnitude > 0.05 then
            flyState.bp.Position = r.Position + dir.Unit * flyState.speed * 0.2
        else
            flyState.bp.Position = r.Position
        end
        flyState.bg.CFrame = Cam.CFrame
    end)
end

makeTog("Bay (Xuyên tường)", false, function(s)
    flyState.active = s
    if s then startFly() else stopFly() end
end)

makeBtn("Tốc độ bay: 50", function(b)
    local list = {30, 50, 80, 120, 200}
    local idx = 1
    for i = 1, #list do if list[i] == flyState.speed then idx = (i % #list) + 1 break end end
    flyState.speed = list[idx]
    b.Text = "  Tốc độ bay: " .. flyState.speed
end)

--== CHỨC NĂNG: ESP ==--
local espCache = {}
local function clearESP()
    for _, v in pairs(espCache) do if v.Destroy then v:Destroy() end end
    espCache = {}
end

local function createESP(obj, color, text)
    if espCache[obj] then return end
    local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
    if not part then return end
    
    local bb = Instance.new("BillboardGui", GUI)
    bb.Adornee = part
    bb.Size = UDim2.new(0, 100, 0, 30)
    bb.AlwaysOnTop = true
    local txt = Instance.new("TextLabel", bb)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Text = text
    txt.TextColor3 = color
    txt.TextStrokeTransparency = 0
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 12
    
    local hl = Instance.new("Highlight", GUI)
    hl.Adornee = obj
    hl.FillColor = color
    hl.FillTransparency = 0.5
    hl.OutlineColor = color
    
    espCache[obj] = { bb, hl }
end

local function espLoop()
    while task.wait(1.5) do
        for obj, data in pairs(espCache) do
            if not obj.Parent then
                for _, v in ipairs(data) do v:Destroy() end
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
end

makeTog("Hiện Quái/Người", false, function(s)
    if s then task.spawn(espLoop) else clearESP() end
end)

--== CHỨC NĂNG: DỊCH CHUYỂN (BẢN ĐỒ 3D) ==--
local mapGui = nil
local function openMap()
    if mapGui then mapGui:Destroy() end
    
    mapGui = Instance.new("Frame", GUI)
    mapGui.Size = UDim2.new(1, -40, 0.7, 0)
    mapGui.Position = UDim2.new(0.5, -0.5, 0.5, -0.35)
    mapGui.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Instance.new("UICorner", mapGui).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", mapGui).Color = Color3.fromRGB(0, 220, 180)
    
    local title = Instance.new("TextLabel", mapGui)
    title.Size = UDim2.new(1, -60, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Bản đồ - Chạm để TP"
    title.TextColor3 = Color3.fromRGB(0, 220, 180)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local cBtn = Instance.new("TextButton", mapGui)
    cBtn.Size = UDim2.new(0, 30, 0, 30)
    cBtn.Position = UDim2.new(1, -40, 0, 5)
    cBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
    cBtn.Text = "X"
    cBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    Instance.new("UICorner", cBtn).CornerRadius = UDim.new(0, 6)
    cBtn.MouseButton1Click:Connect(function() mapGui:Destroy() mapGui = nil end)

    -- ViewportFrame để render 3D map
    local vp = Instance.new("ViewportFrame", mapGui)
    vp.Size = UDim2.new(1, -20, 1, -50)
    vp.Position = UDim2.new(0, 10, 0, 45)
    vp.BackgroundColor3 = Color3.fromRGB(25, 30, 35)
    vp.Ambient = Color3.fromRGB(150, 150, 150)
    vp.LightColor = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", vp).CornerRadius = UDim.new(0, 8)
    
    -- Lấy một phần bản đồ (Terrain hoặc Workspace) đưa vào Viewport
    local mapModel = workspace:FindFirstChild("Terrain")
    if not mapModel then
        mapModel = workspace
    end
    
    -- Chỉ lấy các part lớn tránh lag (như Terrain hoặc Baseplate)
    local cloned = mapModel:Clone()
    cloned.Parent = vp
    
    -- Camera nhìn từ trên xuống
    local vpCam = Instance.new("Camera", vp)
    vpCam.FieldOfView = 90
    vp.CurrentCamera = vpCam
    vpCam.CFrame = CFrame.new(Vector3.new(0, 800, 0)) * CFrame.Angles(math.rad(-90), 0, 0)
    
    -- Cho phép chạm để TP
    local touchBtn = Instance.new("TextButton", vp)
    touchBtn.Size = UDim2.new(1, 0, 1, 0)
    touchBtn.BackgroundTransparency = 1
    touchBtn.Text = ""
    touchBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Tính toán vị trí từ tọa độ 2D trên Viewport ra tọa độ 3D
            local abs = vp.AbsolutePosition
            local sz = vp.AbsoluteSize
            local x = (input.Position.X - abs.X) / sz.X - 0.5
            local z = (input.Position.Y - abs.Y) / sz.Y - 0.5
            
            -- Scale: 1 pixel = khoảng 10 studs
            local targetX = x * 2000
            local targetZ = z * 2000
            
            pcall(function()
                getRoot().CFrame = CFrame.new(Vector3.new(targetX, 150, targetZ))
            end)
            mapGui:Destroy() mapGui = nil
        end
    end)
end

makeBtn("Dịch chuyển (Bản đồ 3D)", openMap)

--== RESPAWN ==--
LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if flyState.active then stopFly() startFly() end
end)

print("[ANON V3] Da Load - Menu ngan, ho tro mobile!")
