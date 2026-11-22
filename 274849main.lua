-- language: Lua (Luau), target: Roblox mobile executor
-- ============================================================
-- HỆ THỐNG KEY: Lưu file cục bộ (Local File)
-- Tài khoản Admin mặc định: Nhập tên bạn vào ADMIN_NAME bên dưới.
-- Key có sẵn: "ADMIN-VIP" và "FOREVER-VIP"
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

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
    
    -- Khởi tạo key mặc định nếu chưa có
    local now = os.time()
    if not db["ADMIN-VIP"] then
        db["ADMIN-VIP"] = {expire = 9999999999, hwid = "", locked = false}
    end
    if not db["FOREVER-VIP"] then
        db["FOREVER-VIP"] = {expire = 9999999999, hwid = "", locked = false}
    end
    return db
end

local function saveDB(data)
    if writefile then
        pcall(function() writefile(DB_FILE, HttpService:JSONEncode(data)) end)
    end
end

-- Lấy HWID (Định danh thiết bị)
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
-- HỆ THỐNG KEY (LOCAL DB)
-- ============================================================
local isVerified = false
local myCurrentKey = ""
local myExpireTime = 0

local function updateTimeLabel()
    if not isVerified then
        TimeLabel.Text = "Chưa xác thực Key"
        TimeLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        return
    end
    local now = os.time()
    local left = myExpireTime - now
    if left <= 0 then
        TimeLabel.Text = "KEY ĐÃ HẾT HẠN"
        TimeLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        isVerified = false
        Panel.Visible = false
        if LoginFrame then LoginFrame.Visible = true end
        return
    end
    if myExpireTime == 9999999999 then
        TimeLabel.Text = "Key: Vĩnh viễn"
        TimeLabel.TextColor3 = Color3.fromRGB(60, 220, 60)
    else
        local days = math.floor(left / 86400)
        local hours = math.floor((left % 86400) / 3600)
        local mins = math.floor((left % 3600) / 60)
        local secs = left % 60
        TimeLabel.Text = string.format("Key còn: %dd %dh %dm %ds", days, hours, mins, secs)
        TimeLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    end
end

local function checkKey(key)
    if key == "" then return false, "Vui lòng nhập key" end
    local db = loadDB()
    local kdata = db[key]
    
    if not kdata then return false, "Key không tồn tại" end
    if kdata.locked then return false, "Key này đã bị Admin khóa!" end
    
    -- Kiểm tra HWID
    if kdata.hwid ~= "" and kdata.hwid ~= MY_HWID then
        return false, "Key này đã được kích hoạt trên máy khác!"
    end
    
    if kdata.expire ~= 9999999999 and os.time() > kdata.expire then
        return false, "Key đã hết hạn!"
    end
    
    -- Cập nhật HWID nếu lần đầu dùng
    if kdata.hwid == "" then
        kdata.hwid = MY_HWID
        saveDB(db)
    end
    
    return true, kdata
end

-- Màn hình đăng nhập
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
    lMsg.Text = "Đang kiểm tra..."
    lMsg.TextColor3 = Color3.fromRGB(255, 255, 0)
    task.wait(0.5)
    local success, res = checkKey(keyBox.Text)
    if success then
        isVerified = true
        myCurrentKey = keyBox.Text
        myExpireTime = res.expire
        lMsg.Text = "Đăng nhập thành công!"
        lMsg.TextColor3 = Color3.fromRGB(60, 220, 60)
        task.wait(1)
        LoginFrame.Visible = false
        Panel.Visible = true
        updateTimeLabel()
    else
        lMsg.Text = tostring(res)
        lMsg.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

-- Tự động đăng nhập nếu đã lưu
task.spawn(function()
    local savedKey = _G.SavedKey or ""
    if savedKey ~= "" then
        local success, res = checkKey(savedKey)
        if success then
            isVerified = true; myCurrentKey = savedKey; myExpireTime = res.expire
            LoginFrame.Visible = false; updateTimeLabel()
            Panel.Visible = true
        end
    end
end)

task.spawn(function()
    while ScreenGui.Parent do
        task.wait(1)
        if isVerified then updateTimeLabel() end
    end
end)

-- ============================================================
-- CHỨC NĂNG GAME (CHỈ CHẠY KHI VERIFIED)
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
-- ADMIN PANEL (CHỈ ADMIN MỚI THẤY)
-- ============================================================
local keyListFrame
task.spawn(function()
    task.wait(1)
    if LocalPlayer.Name ~= ADMIN_NAME then return end
    
    local adminBtn = makeButton("⚙️ QUẢN LÝ KEY (ADMIN)", function()
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
            local input = createBox.Text:lower()
            local secs = 86400
            if input == "vĩnh viễn" or input == "forever" then secs = 9999999999
            elseif input:find("d") then secs = tonumber(input:match("%d+")) * 86400
            elseif input:find("m") then secs = tonumber(input:match("%d+")) * 2592000
            elseif input:find("y") then secs = tonumber(input:match("%d+")) * 31536000 end
            
            local db = loadDB()
            local newKey = "KEY-" .. tostring(math.random(100000, 999999))
            db[newKey] = { expire = os.time() + secs, hwid = "", locked = false }
            saveDB(db)
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
                        local db2 = loadDB()
                        if db2[k] then db2[k].locked = not db2[k].locked; saveDB(db2) end
                    end)
                end
            end
        end)
    end)
end)
