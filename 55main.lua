--== ANON V5 - LOADER + CORE GỘP 1 FILE ==--
local url = "https://raw.githubusercontent.com/ngoclinh982007-stack/anhhup/main/main.lua"

local ok, code = pcall(function()
    return game:HttpGet(url)
end)

if not ok or not code or #code < 100 then
    warn("[ANON] Khong tai duoc script.")
    return
end

if code:find("ANON V5 - LOADER") then
    -- Đây là chính file loader, không chạy lại (tránh vòng lặp)
    local Players = game:GetService("Players")
    local UIS = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")

    local LP = Players.LocalPlayer
    local Cam = workspace.CurrentCamera

    local GUI = Instance.new("ScreenGui")
    GUI.Name = "ANON_V5"
    GUI.ResetOnSpawn = false
    GUI.IgnoreGuiInset = true
    GUI.DisplayOrder = 2147483647
    GUI.Parent = LP:WaitForChild("PlayerGui")

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

    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 280, 0, 320)
    panel.Position = UDim2.new(0.5, -140, 0.5, -160)
    panel.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    panel.Visible = false
    panel.Active = true
    panel.Parent = GUI
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", panel).Color = Color3.fromRGB(0, 220, 180)

    local grip = Instance.new("TextButton")
    grip.Size = UDim2.new(1, -40, 0, 36)
    grip.BackgroundTransparency = 1
    grip.Text = "  ANON MENU (Keo)"
    grip.TextColor3 = Color3.fromRGB(0, 220, 180)
    grip.Font = Enum.Font.GothamBold
    grip.TextSize = 13
    grip.TextXAlignment = Enum.TextXAlignment.Left
    grip.Parent = panel

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 36, 0, 36)
    close.Position = UDim2.new(1, -42, 0, 0)
    close.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
    close.Text = "X"
    close.TextColor3 = Color3.fromRGB(255, 100, 100)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 18
    close.Parent = panel
    Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -16, 1, -46)
    scroll.Position = UDim2.new(0, 8, 0, 40)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 4
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.Parent = panel
    local ll = Instance.new("UIListLayout", scroll)
    ll.Padding = UDim.new(0, 6)
    ll.SortOrder = Enum.SortOrder.LayoutOrder
    ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, ll.AbsoluteContentSize.Y + 8)
    end)

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

    logo.MouseButton1Click:Connect(function() if not dragging then panel.Visible = not panel.Visible end end)
    close.MouseButton1Click:Connect(function() panel.Visible = false end)

    local function makeBtn(text, cb)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 40)
        b.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        b.Text = "  " .. text
        b.TextColor3 = Color3.fromRGB(230, 230, 240)
        b.Font = Enum.Font.GothamMedium
        b.TextSize = 14
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.AutoButtonColor = false
        b.Parent = scroll
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        b.Activated:Connect(function()
            b.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            task.delay(0.15, function() if b and b.Parent then b.BackgroundColor3 = Color3.fromRGB(35, 35, 45) end end)
            if cb then pcall(cb, b) end
        end)
        return b
    end

    local function makeTog(text, def, cb)
        local state = def or false
        local b = makeBtn(text .. " [TAT]", function()
            state = not state
            b.Text = "  " .. text .. " [" .. (state and "BAT" or "TAT") .. "]"
            b.TextColor3 = state and Color3.fromRGB(0, 220, 180) or Color3.fromRGB(230, 230, 240)
            cb(state)
        end)
        return b
    end

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

    makeTog("Bay / Xuyen tuong", false, function(s)
        flyState.active = s
        if s then startFly() else stopFly() end
    end)

    makeBtn("Toc do bay: 50", function(b)
        local list = {30, 50, 80, 120, 200, 350}
        local idx = 1
        for i = 1, #list do if list[i] == flyState.speed then idx = (i % #list) + 1 break end end
        flyState.speed = list[idx]
        b.Text = "  Toc do bay: " .. flyState.speed
    end)

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
    makeTog("Hien Quai / Nguoi choi", false, function(s)
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
                                createESP(v, Color3.fromRGB(0, 255, 255), "Nguoi choi")
                            elseif v:FindFirstChildOfClass("Humanoid") then
                                createESP(v, Color3.fromRGB(255, 50, 50), "Quai")
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

    local mapGui = nil
    local function openMap()
        if mapGui then mapGui:Destroy() end
        if not getRoot() then return end

        mapGui = Instance.new("Frame", GUI)
        mapGui.Size = UDim2.new(0, 320, 0, 360)
        mapGui.Position = UDim2.new(0.5, -160, 0.5, -180)
        mapGui.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        Instance.new("UICorner", mapGui).CornerRadius = UDim.new(0, 10)
        Instance.new("UIStroke", mapGui).Color = Color3.fromRGB(0, 220, 180)

        local title = Instance.new("TextLabel", mapGui)
        title.Size = UDim2.new(1, -50, 0, 35)
        title.Position = UDim2.new(0, 10, 0, 5)
        title.BackgroundTransparency = 1
        title.Text = "Quet Dia Hinh..."
        title.TextColor3 = Color3.fromRGB(0, 220, 180)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left

        local cBtn = Instance.new("TextButton", mapGui)
        cBtn.Size = UDim2.new(0, 30, 0, 30)
        cBtn.Position = UDim2.new(1, -36, 0, 5)
        cBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
        cBtn.Text = "X"
        cBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        Instance.new("UICorner", cBtn).CornerRadius = UDim.new(0, 6)
        cBtn.MouseButton1Click:Connect(function() mapGui:Destroy() mapGui = nil end)

        local canvas = Instance.new("Frame", mapGui)
        canvas.Size = UDim2.new(1, -20, 1, -50)
        canvas.Position = UDim2.new(0, 10, 0, 40)
        canvas.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        canvas.ClipsDescendants = true
        Instance.new("UICorner", canvas).CornerRadius = UDim.new(0, 6)

        local mapCenter = Vector3.new(0, 0, 0)
        local RANGE = 1000

        task.spawn(function()
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            rayParams.FilterDescendantsInstances = {LP.Character}

            local RES = 40
            local step = (RANGE * 2) / RES

            for x = 1, RES do
                for z = 1, RES do
                    local tX = mapCenter.X + (x * step) - RANGE
                    local tZ = mapCenter.Z + (z * step) - RANGE
                    local rayOrigin = Vector3.new(tX, 1000, tZ)
                    local rayDir = Vector3.new(0, -2000, 0)

                    local rayRes = workspace:Raycast(rayOrigin, rayDir, rayParams)
                    if rayRes then
                        local dot = Instance.new("Frame", canvas)
                        dot.AnchorPoint = Vector2.new(0.5, 0.5)
                        dot.Size = UDim2.new(1/RES, 0, 1/RES, 0)
                        dot.Position = UDim2.new((x-0.5)/RES, 0, (z-0.5)/RES, 0)
                        dot.BackgroundColor3 = Color3.fromRGB(80, 100, 80)
                        dot.BorderSizePixel = 0
                        dot.ZIndex = 2
                    end
                end
            end
            title.Text = "Ban do - Cham de TP"
        end)

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
                    local rp = RaycastParams.new()
                    rp.FilterType = Enum.RaycastFilterType.Exclude
                    rp.FilterDescendantsInstances = {LP.Character}
                    local rRes = workspace:Raycast(Vector3.new(tX, 1000, tZ), Vector3.new(0, -2000, 0), rp)
                    local fY = rRes and (rRes.Position.Y + 5) or 50
                    r.CFrame = CFrame.new(tX, fY, tZ)
                end
            end)
            if pConn then pConn:Disconnect() end
            mapGui:Destroy() mapGui = nil
        end)
    end

    makeBtn("Dich chuyen (Quet Map)", openMap)

    LP.CharacterAdded:Connect(function()
        task.wait(0.5)
        if flyState.active then stopFly() startFly() end
    end)

    print("[ANON V5] Loaded - Raycast Map & Mobile Fixed")
else
    -- Không phải file loader, chạy code trực tiếp
    local func, err = loadstring(code)
    if not func then
        warn("[ANON] Loi cu phap: " .. tostring(err))
        return
    end
    local success, err2 = pcall(func)
    if not success then
        warn("[ANON] Loi thuc thi: " .. tostring(err2))
    end
end
