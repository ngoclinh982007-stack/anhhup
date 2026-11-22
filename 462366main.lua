-- language: Lua (Luau), target: Roblox mobile executor
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================================================
-- CẤU HÌNH ADMIN
-- ============================================================
local ADMIN_NAME = "TEN_ADMIN_CUA_BAN" -- SỬA THÀNH TÊN ROBLOX CỦA BẠN
local MAP_IMAGE_ID = "" 
local LOGO_IMAGE_ID = "rbxassetid://6031075931"

-- ============================================================
-- LOCAL DB (LƯU FILE)
-- ============================================================
local DB_FILE = "menu_keys_db.json"
local function loadDB()
    local db = {}
    if isfile and isfile(DB_FILE) then
        local ok, data = pcall(function() return readfile(DB_FILE) end)
        if ok and data then
            local ok2, parsed = pcall(function() return HttpService:JSONDecode(data) end)
            if ok2 then db = parsed end
        end
    end
    if not db["ADMIN-VIP"] then db["ADMIN-VIP"] = {expire = 9999999999, hwid = "", locked = false} end
    if not db["FOREVER-VIP"] then db["FOREVER-VIP"] = {expire = 9999999999, hwid = "", locked = false} end
    return db
end

local function saveDB(data)
    if writefile then pcall(function() writefile(DB_FILE, HttpService:JSONEncode(data)) end) end
end

local function getHWID()
    local hwid = "UNKNOWN"
    pcall(function()
        if gethwid then hwid = gethwid()
        elseif syn and syn.get_hwid then hwid = syn.get_hwid()
        else hwid = game:GetService("RbxAnalyticsService"):GetClientId() end
    end)
    return tostring(hwid)
end
local MY_HWID = getHWID()

-- ============================================================
-- UI BUILD
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MyMenuGUI_" .. tostring(math.random(10000, 99999))
ScreenGui.ResetOnSpawn = false; ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = (gethui and gethui()) or CoreGui

-- PANEL
local Panel = Instance.new("Frame")
Panel.Name = "Panel"; Panel.Size = UDim2.new(0, 300, 0, math.min(520, Camera.ViewportSize.Y - 140))
Panel.Position = UDim2.new(0, 75, 0, 80); Panel.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
Panel.BorderSizePixel = 0; Panel.Visible = false; Panel.Parent = ScreenGui
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", Panel).Color = Color3.fromRGB(0, 200, 255)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 36); Title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Title.Text = "  A"; Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.GothamBold; Title.TextSize = 16; Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Panel
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

local TimeLabel = Instance.new("TextLabel")
TimeLabel.Size = UDim2.new(1, -10, 0, 20); TimeLabel.Position = UDim2.new(0, 5, 0, 36)
TimeLabel.BackgroundTransparency = 1; TimeLabel.Text = "Chưa nhập Key"
TimeLabel.TextColor3 = Color3.fromRGB(255, 255, 0); TimeLabel.Font = Enum.Font.Gotham
TimeLabel.TextSize = 12; TimeLabel.TextXAlignment = Enum.TextXAlignment.Left
TimeLabel.Parent = Panel

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28); CloseBtn.Position = UDim2.new(1, -34, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60); CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1); CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Panel
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function() Panel.Visible = false end)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -66); Scroll.Position = UDim2.new(0, 5, 0, 60)
Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 6
Scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0); Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = Panel
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 6)
Instance.new("UIPadding", Scroll).PaddingBottom = UDim.new(0, 8)

-- LOGO
local Logo = Instance.new("ImageButton")
Logo.Size = UDim2.new(0, 50, 0, 50); Logo.Position = UDim2.new(0, 15, 0, 80)
Logo.BackgroundColor3 = Color3.fromRGB(20, 20, 30); Logo.Image = LOGO_IMAGE_ID
Logo.Parent = ScreenGui
Instance.new("UICorner", Logo).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", Logo).Color = Color3.fromRGB(0, 200, 255)

local dragging, dragStart, startPos, tapStart
Logo.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = Logo.Position; tapStart = input.Position
    end
end)
Logo.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
        if tapStart and (input.Position - tapStart).Magnitude < 10 then Panel.Visible = not Panel.Visible end
        tapStart = nil
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Logo.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- UI HELPERS
local COLOR_OFF = Color3.fromRGB(220, 60, 60)
local COLOR_ON = Color3.fromRGB(60, 220, 60)
local COLOR_BG = Color3.fromRGB(30, 30, 45)

local function makeToggle(text, defaultState, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 38); btn.BackgroundColor3 = defaultState and COLOR_ON or COLOR_OFF
    btn.TextColor3 = Color3.new(1, 1, 1); btn.Text = text; btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13; btn.AutoButtonColor = false; btn.Parent = Scroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local state = defaultState
    btn.MouseButton1Click:Connect(function() state = not state; btn.BackgroundColor3 = state and COLOR_ON or COLOR_OFF; callback(state) end)
    return btn
end

local function makeButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 38); btn.BackgroundColor3 = COLOR_BG
    btn.TextColor3 = Color3.fromRGB(230, 230, 240); btn.Text = text; btn.Font = Enum.Font.Gotham
    btn.TextSize = 13; btn.AutoButtonColor = true; btn.Parent = Scroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function makeInput(label, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 38); frame.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    frame.BorderSizePixel = 0; frame.Parent = Scroll
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    local txt = Instance.new("TextBox")
    txt.Size = UDim2.new(1, -10, 1, 0); txt.Position = UDim2.new(0, 5, 0, 0)
    txt.BackgroundTransparency = 1; txt.Text = (default and default ~= "") and tostring(default) or ""
    txt.PlaceholderText = label; txt.TextColor3 = Color3.fromRGB(0, 200, 255)
    txt.Font = Enum.Font.Gotham; txt.TextSize = 13; txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.Parent = frame
    txt.FocusLost:Connect(function() callback(txt.Text) end)
    return txt
end

-- ============================================================
-- HỆ THỐNG KEY
-- ============================================================
local isVerified = false
local myCurrentKey = ""
local myExpireTime = 0

local function updateTimeLabel()
    if not isVerified then
        TimeLabel.Text = "Chưa xác thực Key"; TimeLabel.TextColor3 = Color3.fromRGB(255, 50, 50); return
    end
    local now = os.time(); local left = myExpireTime - now
    if left <= 0 then
        TimeLabel.Text = "KEY ĐÃ HẾT HẠN"; TimeLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        isVerified = false; Panel.Visible = false; if LoginFrame then LoginFrame.Visible = true end; return
    end
    if myExpireTime == 9999999999 then
        TimeLabel.Text = "Key: Vĩnh viễn"; TimeLabel.TextColor3 = Color3.fromRGB(60, 220, 60)
    else
        local days = math.floor(left / 86400); local hours = math.floor((left % 86400) / 3600)
        local mins = math.floor((left % 3600) / 60); local secs = left % 60
        TimeLabel.Text = string.format("Key còn: %dd %dh %dm %ds", days, hours, mins, secs)
        TimeLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    end
end

local function checkKey(key)
    if key == "" then return false, "Vui lòng nhập key" end
    local db = loadDB(); local kdata = db[key]
    if not kdata then return false, "Key không tồn tại" end
    if kdata.locked then return false, "Key này đã bị Admin khóa!" end
    if kdata.hwid ~= "" and kdata.hwid ~= MY_HWID then return false, "Key này đã được kích hoạt trên máy khác!" end
    if kdata.expire ~= 9999999999 and os.time() > kdata.expire then return false, "Key đã hết hạn!" end
    if kdata.hwid == "" then kdata.hwid = MY_HWID; saveDB(db) end
    return true, kdata
end

local LoginFrame = Instance.new("Frame")
LoginFrame.Size = UDim2.new(0, 260, 0, 180); LoginFrame.Position = UDim2.new(0.5, -130, 0.5, -90)
LoginFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22); LoginFrame.Parent = ScreenGui
Instance.new("UICorner", LoginFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", LoginFrame).Color = Color3.fromRGB(0, 200, 255)

local lTitle = Instance.new("TextLabel")
lTitle.Size = UDim2.new(1, 0, 0, 40); lTitle.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
lTitle.Text = "NHẬP KEY ĐỂ SỬ DỤNG"; lTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
lTitle.Font = Enum.Font.GothamBold; lTitle.Parent = LoginFrame
Instance.new("UICorner", lTitle).CornerRadius = UDim.new(0, 8)

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(1, -20, 0, 36); keyBox.Position = UDim2.new(0, 10, 0, 55)
keyBox.BackgroundColor3 = Color3.fromRGB(30, 30, 45); keyBox.Text = ""
keyBox.PlaceholderText = "Nhập key vào đây..."; keyBox.TextColor3 = Color3.new(1,1,1)
keyBox.Font = Enum.Font.Gotham; keyBox.Parent = LoginFrame
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 6)

local lMsg = Instance.new("TextLabel")
lMsg.Size = UDim2.new(1, -20, 0, 20); lMsg.Position = UDim2.new(0, 10, 0, 95)
lMsg.BackgroundTransparency = 1; lMsg.Text = ""; lMsg.TextColor3 = Color3.fromRGB(255, 50, 50)
lMsg.Font = Enum.Font.Gotham; lMsg.TextSize = 12; lMsg.Parent = LoginFrame

local loginBtn = Instance.new("TextButton")
loginBtn.Size = UDim2.new(1, -20, 0, 36); loginBtn.Position = UDim2.new(0, 10, 0, 125)
loginBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200); loginBtn.Text = "XÁC NHẬN"
loginBtn.TextColor3 = Color3.new(1,1,1); loginBtn.Font = Enum.Font.GothamBold
loginBtn.Parent = LoginFrame
Instance.new("UICorner", loginBtn).CornerRadius = UDim.new(0, 6)

loginBtn.MouseButton1Click:Connect(function()
    lMsg.Text = "Đang kiểm tra..."; lMsg.TextColor3 = Color3.fromRGB(255, 255, 0); task.wait(0.5)
    local success, res = checkKey(keyBox.Text)
    if success then
        isVerified = true; myCurrentKey = keyBox.Text; myExpireTime = res.expire
        lMsg.Text = "Đăng nhập thành công!"; lMsg.TextColor3 = Color3.fromRGB(60, 220, 60); task.wait(1)
        LoginFrame.Visible = false; Panel.Visible = true; updateTimeLabel()
    else
        lMsg.Text = tostring(res); lMsg.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

task.spawn(function()
    local savedKey = _G.SavedKey or ""
    if savedKey ~= "" then
        local success, res = checkKey(savedKey)
        if success then
            isVerified = true; myCurrentKey = savedKey; myExpireTime = res.expire
            LoginFrame.Visible = false; updateTimeLabel(); Panel.Visible = true
        end
    end
end)

task.spawn(function() while ScreenGui.Parent do task.wait(1); if isVerified then updateTimeLabel() end end end)

-- ============================================================
-- CHỨC NĂNG CƠ BẢN
-- ============================================================
local noclipConn, infJumpConn, godConn, vacConn, autoFindConn
local itemSearchTerm = ""

makeToggle("XUYÊN VẬT THỂ (NOCLIP)", false, function(state)
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    if state then
        noclipConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then for _, v in ipairs(char:GetDescendants()) do if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end end end
        end)
    else
        local char = LocalPlayer.Character
        if char then for _, v in ipairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = true end end end
    end
end)

makeToggle("NHẢY VÔ HẠN", false, function(state)
    if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
    if state then
        infJumpConn = UserInputService.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            if char then local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end end
        end)
    end
end)

makeToggle("BẤT TỬ (GODMODE)", false, function(state)
    if godConn then godConn:Disconnect(); godConn = nil end
    if state then
        godConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.Health = hum.MaxHealth; for _, v in ipairs(char:GetDescendants()) do if v:IsA("ForceField") or v.Name:lower():find("fire") or v.Name:lower():find("poison") then pcall(function() v:Destroy() end) end end end
            end
        end)
    end
end)

makeToggle("HÚT ĐỒ (VACUUM)", false, function(state)
    if vacConn then vacConn:Disconnect(); vacConn = nil end
    if state then
        vacConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and not obj:IsDescendantOf(char) then
                        local isItem = obj:FindFirstChildOfClass("Tool") or obj.Name:lower():find("item") or obj.Name:lower():find("drop") or obj.Name:lower():find("coin") or obj.Name:lower():find("loot")
                        if isItem and (obj.Position - hrp.Position).Magnitude < 100 then pcall(function() obj.CFrame = hrp.CFrame; obj.CanCollide = false end) end
                    end
                end
            end
        end)
    end
end)

makeInput("Tìm đồ (Anh/Việt)", "", function(txt) itemSearchTerm = txt:lower() end)
makeToggle("TỰ ĐỘNG TÌM & BAY ĐẾN ĐỒ", false, function(state)
    if autoFindConn then autoFindConn:Disconnect(); autoFindConn = nil end
    if state then
        autoFindConn = RunService.Heartbeat:Connect(function()
            if itemSearchTerm == "" then return end
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local hrp = char.HumanoidRootPart
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and not obj:IsDescendantOf(char) then
                    local n = obj.Name:lower(); local pname = obj.Parent and obj.Parent.Name:lower() or ""
                    if n:find(itemSearchTerm) or pname:find(itemSearchTerm) then
                        hrp.CFrame = CFrame.new(obj.Position + Vector3.new(0, 5, 0)); break
                    end
                end
            end
        end)
    end
end)

-- ============================================================
-- NHÂN BẢN ĐỒ (DUPE)
-- ============================================================
local dupeAmount = 1
makeInput("Số lượng nhân bản", dupeAmount, function(v) dupeAmount = tonumber(v) or 1 end)
makeButton("📦 NHÂN BẢN ĐỒ TRONG BA LÔ", function()
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if not bp then return end
    local totalDuped = 0
    for _, tool in ipairs(bp:GetChildren()) do
        if tool:IsA("Tool") then
            for i = 1, dupeAmount do
                pcall(function()
                    local clone = tool:Clone()
                    clone.Parent = LocalPlayer.Character 
                    totalDuped = totalDuped + 1
                end)
            end
        end
    end
    print("[DUPE] Đã cố gắng nhân bản " .. totalDuped .. " món đồ.")
end)

-- ============================================================
-- TRỘM ĐỒ THỦ CÔNG
-- ============================================================
local function buildStealUI()
    local stealGui = Instance.new("Frame")
    stealGui.Name = "MyMenuGUI_Steal"
    stealGui.Size = UDim2.new(0, 280, 0, 400)
    stealGui.Position = UDim2.new(0.5, -140, 0.5, -200)
    stealGui.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    stealGui.BorderSizePixel = 0
    stealGui.Parent = ScreenGui
    Instance.new("UICorner", stealGui).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", stealGui).Color = Color3.fromRGB(0, 200, 255)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 0, 32); t.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    t.Text = "CHỌN NGƯỜI ĐỂ XEM TÚI ĐỒ"; t.TextColor3 = Color3.fromRGB(0, 200, 255)
    t.Font = Enum.Font.GothamBold; t.TextSize = 14; t.Parent = stealGui
    Instance.new("UICorner", t).CornerRadius = UDim.new(0, 8)

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 28, 0, 28); close.Position = UDim2.new(1, -30, 0, 2)
    close.BackgroundColor3 = Color3.fromRGB(200, 50, 50); close.Text = "X"
    close.TextColor3 = Color3.new(1,1,1); close.Font = Enum.Font.GothamBold; close.Parent = stealGui
    Instance.new("UICorner", close).CornerRadius = UDim.new(0, 4)
    close.MouseButton1Click:Connect(function() stealGui:Destroy() end)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -50); scroll.Position = UDim2.new(0, 5, 0, 40)
    scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 6; scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0); scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; scroll.Parent = stealGui
    Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5)

    local function showPlayers()
        t.Text = "CHỌN NGƯỜI ĐỂ XEM TÚI ĐỒ"
        for _, v in ipairs(scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer then
                local b = Instance.new("TextButton")
                b.Size = UDim2.new(1, -10, 0, 36); b.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
                b.TextColor3 = Color3.fromRGB(230, 230, 240); b.Text = pl.Name
                b.Font = Enum.Font.Gotham; b.TextSize = 13; b.Parent = scroll
                Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
                b.MouseButton1Click:Connect(function() showTools(pl) end)
            end
        end
    end

    local function showTools(targetPlayer)
        t.Text = "TÚI ĐỒ CỦA: " .. targetPlayer.Name
        for _, v in ipairs(scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        
        local backBtn = Instance.new("TextButton")
        backBtn.Size = UDim2.new(1, -10, 0, 30); backBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        backBtn.TextColor3 = Color3.new(1,1,1); backBtn.Text = "< QUAY LẠI"
        backBtn.Font = Enum.Font.Gotham; backBtn.TextSize = 13; backBtn.Parent = scroll
        Instance.new("UICorner", backBtn).CornerRadius = UDim.new(0, 5)
        backBtn.MouseButton1Click:Connect(showPlayers)

        local theirBackpack = targetPlayer:FindFirstChild("Backpack")
        local found = false
        if theirBackpack then
            for _, tool in ipairs(theirBackpack:GetChildren()) do
                if tool:IsA("Tool") then
                    found = true
                    local b = Instance.new("TextButton")
                    b.Size = UDim2.new(1, -10, 0, 36); b.BackgroundColor3 = Color3.fromRGB(40, 60, 40)
                    b.TextColor3 = Color3.new(1,1,1); b.Text = "Lấy: " .. tool.Name
                    b.Font = Enum.Font.Gotham; b.TextSize = 13; b.Parent = scroll
                    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
                    b.MouseButton1Click:Connect(function()
                        local myBackpack = LocalPlayer:FindFirstChild("Backpack")
                        if myBackpack then
                            pcall(function()
                                tool.Parent = myBackpack
                                b.Text = "Đã lấy (hoặc bị chặn)"
                                b.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                            end)
                        end
                    end)
                end
            end
        end

        if not found then
            local err = Instance.new("TextLabel")
            err.Size = UDim2.new(1, -10, 0, 36); err.BackgroundTransparency = 1
            err.TextColor3 = Color3.fromRGB(200, 50, 50); err.Text = "Không có đồ hoặc game chặn xem."
            err.Font = Enum.Font.Gotham; err.TextSize = 13; err.Parent = scroll
        end
    end
    showPlayers()
end
makeButton("🕵️ MỞ BẢNG TRỘM ĐỒ", buildStealUI)

-- ============================================================
-- ESP & MAP TELEPORT & PLAYER TP
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

    espBtns.players.Text = (espStates.players and "✅" or "❌") .. " Người chơi (" .. counts.players .. ")"
    espBtns.monsters.Text = (espStates.monsters and "✅" or "❌") .. " Quái (" .. counts.monsters .. ")"
    espBtns.npcs.Text = (espStates.npcs and "✅" or "❌") .. " NPC (" .. counts.npcs .. ")"
    espBtns.items.Text = (espStates.items and "✅" or "❌") .. " Vật phẩm (" .. counts.items .. ")"
end

local espBtns = {}
espBtns.players = makeToggle("❌ Người chơi (0)", false, function(s) espStates.players = s; scanAll() end)
espBtns.monsters = makeToggle("❌ Quái (0)", false, function(s) espStates.monsters = s; scanAll() end)
espBtns.npcs = makeToggle("❌ NPC (0)", false, function(s) espStates.npcs = s; scanAll() end)
espBtns.items = makeToggle("❌ Vật phẩm (0)", false, function(s) espStates.items = s; scanAll() end)

task.spawn(function() while ScreenGui.Parent do task.wait(3); if espStates.players or espStates.monsters or espStates.npcs or espStates.items then scanAll() end end end)

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
    task.wait(math.random(80, 180) / 1000)
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
        if char and char:FindFirstChild("HumanoidRootPart") then addDot(char.HumanoidRootPart.Position, Color3.fromRGB(0, 255, 100), 9) end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and isMonster(obj) then local root = findRoot(obj); if root then addDot(root.Position, Color3.fromRGB(255, 50, 50), 5) end end
        end
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then addDot(pl.Character.HumanoidRootPart.Position, Color3.fromRGB(255, 220, 0), 6) end
        end
    end

    refreshMarkers()
    task.spawn(function() while mapGui.Parent do task.wait(1); refreshMarkers() end end)

    canvas.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local relX = (input.Position.X - canvas.AbsolutePosition.X) / canvas.AbsoluteSize.X
            local relZ = (input.Position.Y - canvas.AbsolutePosition.Y) / canvas.AbsoluteSize.Y
            if relX < 0 or relX > 1 or relZ < 0 or relZ > 1 then return end
            local wx = bounds.minX + relX * rangeX; local wz = bounds.minZ + relZ * rangeZ
            local rp = RaycastParams.new(); rp.FilterDescendantsInstances = {LocalPlayer.Character}; rp.FilterType = Enum.RaycastFilterType.Exclude
            local hit = Workspace:Raycast(Vector3.new(wx, 500, wz), Vector3.new(0, -1000, 0), rp)
            local y = hit and hit.Position.Y + 5 or 50
            teleportTo(Vector3.new(wx, y, wz)); mapGui:Destroy()
        end
    end)
end
makeButton("🗺 BẢN ĐỒ DỊCH CHUYỂN", buildMapPanel)
makeButton("🔄 LÀM MỚI BẢN ĐỒ", function() _G.__MAP_BOUNDS = nil; print("[MAP] Đã làm mới") end)

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
                        teleportTo(pl.Character.HumanoidRootPart.Position); listGui:Destroy()
                    end
                end)
            end
        end
    end
    rebuild(); task.spawn(function() while listGui.Parent do task.wait(2); rebuild() end end)
end
makeButton("🧑 DỊCH CHUYỂN ĐẾN NGƯỜI CHƠI", buildPlayerList)

-- ============================================================
-- ADMIN PANEL (CHỈ ADMIN MỚI THẤY)
-- ============================================================
local keyListFrame
task.spawn(function()
    task.wait(1)
    if LocalPlayer.Name ~= ADMIN_NAME then return end
    
    makeButton("⚙️ QUẢN LÝ KEY (ADMIN)", function()
        if keyListFrame then keyListFrame:Destroy() end
        keyListFrame = Instance.new("Frame")
        keyListFrame.Size = UDim2.new(1, -40, 1, -100); keyListFrame.Position = UDim2.new(0, 20, 0, 60)
        keyListFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15); keyListFrame.Parent = ScreenGui
        Instance.new("UICorner", keyListFrame).CornerRadius = UDim.new(0, 8)
        
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, 0, 0, 30); t.Text = "QUẢN LÝ KEY"; t.TextColor3 = Color3.fromRGB(0,200,255)
        t.Font = Enum.Font.GothamBold; t.Parent = keyListFrame
        
        local close = Instance.new("TextButton")
        close.Size = UDim2.new(0, 30, 0, 30); close.Position = UDim2.new(1, -35, 0, 5); close.Text = "X"
        close.BackgroundColor3 = Color3.fromRGB(200,50,50); close.TextColor3 = Color3.new(1,1,1); close.Parent = keyListFrame
        close.MouseButton1Click:Connect(function() keyListFrame:Destroy() end)
        
        local s = Instance.new("ScrollingFrame")
        s.Size = UDim2.new(1, -10, 1, -80); s.Position = UDim2.new(0, 5, 0, 40); s.BackgroundTransparency = 1
        s.CanvasSize = UDim2.new(0,0,0,0); s.AutomaticCanvasSize = Enum.AutomaticSize.Y; s.Parent = keyListFrame
        Instance.new("UIListLayout", s).Padding = UDim.new(0, 5)
        
        local createBox = Instance.new("TextBox")
        createBox.Size = UDim2.new(1, -10, 0, 35); createBox.PlaceholderText = "Nhập thời gian (1d, 7d, 1m, 1y, vv)"
        createBox.BackgroundColor3 = Color3.fromRGB(30,30,45); createBox.TextColor3 = Color3.new(1,1,1)
        createBox.Parent = s
        Instance.new("UICorner", createBox).CornerRadius = UDim.new(0,6)
        
        local createBtn = Instance.new("TextButton")
        createBtn.Size = UDim2.new(1, -10, 0, 35); createBtn.BackgroundColor3 = Color3.fromRGB(0,150,200)
        createBtn.Text = "TẠO KEY MỚI"; createBtn.TextColor3 = Color3.new(1,1,1); createBtn.Font = Enum.Font.GothamBold
        createBtn.Parent = s
        Instance.new("UICorner", createBtn).CornerRadius = UDim.new(0,6)
        
        createBtn.MouseButton1Click:Connect(function()
            local input = createBox.Text:lower(); local secs = 86400
            if input == "vĩnh viễn" or input == "forever" then secs = 9999999999
            elseif input:find("d") then secs = tonumber(input:match("%d+")) * 86400
            elseif input:find("m") then secs = tonumber(input:match("%d+")) * 2592000
            elseif input:find("y") then secs = tonumber(input:match("%d+")) * 31536000 end
            
            local db = loadDB(); local newKey = "KEY-" .. tostring(math.random(100000, 999999))
            db[newKey] = { expire = os.time() + secs, hwid = "", locked = false }; saveDB(db)
            createBox.Text = "Đã tạo: " .. newKey
        end)
        
        task.spawn(function()
            while keyListFrame and keyListFrame.Parent do
                task.wait(2)
                local db = loadDB()
                for _, v in ipairs(s:GetChildren()) do if v:IsA("TextButton") and v.Text ~= "TẠO KEY MỚI" then v:Destroy() end end
                for k, v in pairs(db) do
                    local b = Instance.new("TextButton")
                    b.Size = UDim2.new(1, -10, 0, 50); b.BackgroundColor3 = v.locked and Color3.fromRGB(100,0,0) or Color3.fromRGB(30,30,45)
                    b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Gotham; b.TextSize = 12
                    b.Text = k .. "\n" .. (v.locked and "ĐÃ KHÓA" or "Hoạt động") .. " | " .. (v.hwid ~= "" and "Máy: " .. v.hwid:sub(1,8) or "Chưa kết nối")
                    b.Parent = s
                    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
                    b.MouseButton1Click:Connect(function()
                        local db2 = loadDB(); if db2[k] then db2[k].locked = not db2[k].locked; saveDB(db2) end
                    end)
                end
            end
        end)
    end)
end)
