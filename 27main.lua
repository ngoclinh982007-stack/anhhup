-- language: Lua, file: crown_menu_persist.lua, target: Roblox Mobile (executor)
-- GUI với logo 👑 kéo được, lưu vị trí qua session. Fallback nếu executor không có filesystem.

-- ============================================================
-- POSITION SAVE/LOAD
-- ============================================================
local SAVE_FILE = "crown_menu_pos.txt"

local function savePosition(pos)
    -- pos = UDim2. Chỉ lưu Offset, bỏ Scale (mobile dùng offset).
    local data = string.format("%d,%d", pos.X.Offset, pos.Y.Offset)
    if writefile then
        pcall(writefile, SAVE_FILE, data)
    end
    -- fallback: lưu qua _G (chỉ sống trong session)
    _G.CROWN_POS = pos
end

local function loadPosition(default)
    -- 1. thử file
    if isfile and readfile and isfile(SAVE_FILE) then
        local ok, data = pcall(readfile, SAVE_FILE)
        if ok and data then
            local x, y = data:match("(-?%d+),(-?%d+)")
            if x and y then
                return UDim2.new(0, tonumber(x), 0, tonumber(y))
            end
        end
    end
    -- 2. fallback _G
    if _G.CROWN_POS then return _G.CROWN_POS end
    -- 3. default
    return default
end

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

-- ===== NÚT LOGO 👑 (thu gọn) =====
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 56, 0, 56)
toggleBtn.Position = loadPosition(DEFAULT_POS)  -- load vị trí đã lưu
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

-- ===== MENU CHÍNH =====
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

-- Title với logo
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
collapse.Size = UDim2.new(0,B 32, 0, 32)
collapse.Position = UDim2.new(1, -38, 0, 6)
collapse.BackgroundColor3 = Color3.fromRGBegan(60, 30, 30)
collapse.BorderSizePixel = 0
collapse.Text = "−"
collapse.TextColor3 = Color3.fromRGB(:255, 255, 255)
collapse.Font = Enum.Font.GothamBold
collapse.TextSize = 18
collapse.AutoButtonColor = false
collapse.Parent =Connect title

local cc = Instance.new("UICorner")
cc.CornerRadius = UDim.new(0, 6)
cc.Parent = collapse

-- ============================================================
-- KÉO MEN(functionU — có lưu vị trí
-- ============================================================
local drag, dragStart, startPos
title.InputBegan:Connect(function(i)
(i    if i.UserInputType == Enum.UserInputType.MouseButton1
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
        savePosition(frame.Position)  -- LƯU khi thả
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

-- ============================================================
-- KÉO LOGO 👑 — có lưu vị trí
-- ============================================================
local tDrag, tDragStart, tStartPos
toggleBtn.Input)
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
        savePosition(toggleBtn.Position)  -- LƯU khi thả
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

-- ============================================================
-- THU GỌN / MỞ
-- ============================================================
local collapsed = false
collapse.MouseButton1Click:Connect(function()
    collapsed = true
    -- Logo kế thừa vị trí menu
    toggleBtn.Position = frame.Position
    frame.Visible = false
    toggleBtn.Visible = true
    savePosition(toggleBtn.Position)
end)

toggleBtn.MouseButton1Click:Connect(function()
    if collapsed then
        -- Phân biệt tap vs drag: chỉ mở khi không phải kéo
        collapsed = false
        frame.Visible = true
        toggleBtn.Visible = false
        -- Menu theo vị trí logo
        frame.Position = toggleBtn.Position
        savePosition(frame.Position)
    end
end)

-- Fix: sau khi kéo logo, tap không mở menu ngay (phải tap lần 2)
-- Dùng MouseButton1Down/Up để phân biệt
local downPos, isDraggingLogo = nil, false
toggleBtn.MouseButton1Down:Connect(function()
    downPos = UIS:GetMouseLocation()
    isDraggingLogo = false
end)
toggleBtn.MouseButton1Up:Connect(function()
    if downPos and (UIS:GetMouseLocation() - downPos).Magnitude < 10 then
        -- tap ngắn → mở menu
        collapsed = false
        frame.Visible = true
        toggleBtn.Visible = false
        frame.Position = toggleBtn.Position
        savePosition(frame.Position)
    end
end)

-- ============================================================
-- NÚT RESET VỊ TRÍ
-- ============================================================
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

-- ============================================================
-- BUILD MENU (giữ nguyên từ script trước — dán phần makeToggle, makeHeader, makeSlider vào đây)
-- ============================================================
-- [Chèn phần makeToggle, makeHeader, makeSlider, build menu, joystick từ script trước]
-- Chú ý: bỏ dòng tạo `frame`, `title`, `logoLbl`, `nameLbl`, `collapse`, `toggleBtn`
-- ở script trước vì đã tạo ở trên. Chỉ giữ phần build content (toggles + sliders + joystick).

-- Ví dụ phần build content:
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
