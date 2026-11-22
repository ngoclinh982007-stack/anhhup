-- language: Lua (Luau), target: Roblox mobile executor
-- ============================================================
-- ULTIMATE MEGA MENU v26 (100% Features, Compact)
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")

local LP = Players.LocalPlayer
local Cam = Workspace.CurrentCamera
local LOGO = "rbxassetid://6031075931"

local SG = Instance.new("ScreenGui")
SG.Name = "MyMenu_" .. math.random(1000,9999)
SG.ResetOnSpawn = false; SG.IgnoreGuiInset = true
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.Parent = (gethui and gethui()) or CoreGui

local C_OFF = Color3.fromRGB(220, 60, 60)
local C_ON = Color3.fromRGB(60, 220, 60)
local C_BG = Color3.fromRGB(30, 30, 45)

local function mkT(parent, txt, def, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 34); b.BackgroundColor3 = def and C_ON or C_OFF
    b.TextColor3 = Color3.new(1,1,1); b.Text = txt; b.Font = Enum.Font.GothamBold
    b.TextSize = 12; b.AutoButtonColor = false; b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    local s = def
    b.MouseButton1Click:Connect(function() s = not s; b.BackgroundColor3 = s and C_ON or C_OFF; cb(s) end)
end

local function mkB(parent, txt, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 34); b.BackgroundColor3 = C_BG
    b.TextColor3 = Color3.fromRGB(230,230,240); b.Text = txt; b.Font = Enum.Font.Gotham
    b.TextSize = 12; b.AutoButtonColor = true; b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(cb)
end

local function mkI(parent, lbl, def, cb)
    local f = Instance.new("Frame"); f.Size = UDim2.new(1, -10, 0, 34)
    f.BackgroundColor3 = Color3.fromRGB(22,22,32); f.BorderSizePixel = 0; f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    local t = Instance.new("TextBox"); t.Size = UDim2.new(1, -10, 1, 0); t.Position = UDim2.new(0,5,0,0)
    t.BackgroundTransparency = 1; t.Text = (def and tostring(def)) or ""
    t.PlaceholderText = lbl; t.TextColor3 = Color3.fromRGB(0,200,255); t.Font = Enum.Font.Gotham
    t.TextSize = 12; t.TextXAlignment = Enum.TextXAlignment.Left; t.Parent = f
    t.FocusLost:Connect(function() cb(t.Text) end)
end

local function mkH(parent, txt)
    local h = Instance.new("TextLabel")
    h.Size = UDim2.new(1, -10, 0, 20); h.BackgroundTransparency = 1
    h.Text = txt; h.TextColor3 = Color3.fromRGB(255,255,0); h.Font = Enum.Font.GothamBold
    h.TextSize = 12; h.TextXAlignment = Enum.TextXAlignment.Left; h.Parent = parent
end

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 320, 0, math.min(550, Cam.ViewportSize.Y - 100))
Panel.Position = UDim2.new(0, 60, 0, 60); Panel.BackgroundColor3 = Color3.fromRGB(15,15,22)
Panel.BorderSizePixel = 0; Panel.Visible = false; Panel.Parent = SG
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", Panel).Color = Color3.fromRGB(0,200,255)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 36); Title.BackgroundColor3 = Color3.fromRGB(25,25,35)
Title.Text = "  MEGA MENU"; Title.TextColor3 = Color3.fromRGB(0,200,255)
Title.Font = Enum.Font.GothamBold; Title.TextSize = 16; Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Panel
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

local X = Instance.new("TextButton")
X.Size = UDim2.new(0, 28, 0, 28); X.Position = UDim2.new(1, -34, 0, 4)
X.BackgroundColor3 = Color3.fromRGB(220, 60, 60); X.Text = "X"
X.TextColor3 = Color3.new(1,1,1); X.Font = Enum.Font.GothamBold; X.Parent = Panel
Instance.new("UICorner", X).CornerRadius = UDim.new(0, 6)
X.MouseButton1Click:Connect(function() Panel.Visible = false end)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -46); Scroll.Position = UDim2.new(0, 5, 0, 40)
Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 6
Scroll.ScrollBarImageColor3 = Color3.fromRGB(0,200,255)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0); Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = Panel
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 5)
Instance.new("UIPadding", Scroll).PaddingBottom = UDim.new(0, 8)

local Logo = Instance.new("ImageButton")
Logo.Size = UDim2.new(0, 50, 0, 50); Logo.Position = UDim2.new(0, 15, 0, 80)
Logo.BackgroundColor3 = Color3.fromRGB(20, 20, 30); Logo.Image = LOGO
Logo.Parent = SG
Instance.new("UICorner", Logo).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", Logo).Color = Color3.fromRGB(0, 200, 255)

local drag, ds, sp, tap
Logo.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag=true; ds=i.Position; sp=Logo.Position; tap=i.Position end end)
Logo.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag=false; if tap and (i.Position-tap).Magnitude < 10 then Panel.Visible = not Panel.Visible end; tap=nil end end)
UIS.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - ds; Logo.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y) end end)

-- 1. DI CHUYỂN
mkH(Scroll, "--- DI CHUYỂN ---")
mkT(Scroll, "XUYÊN VẬT THỂ (NOCLIP)", false, function(s)
    local c
    if s then c = RunService.Stepped:Connect(function() local ch = LP.Character; if ch then for _, v in ipairs(ch:GetDescendants()) do if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end end end end) else if c then c:Disconnect() end; local ch = LP.Character; if ch then for _, v in ipairs(ch:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = true end end end end
end)
mkT(Scroll, "NHẢY VÔ HẠN", false, function(s)
    local c
    if s then c = UIS.JumpRequest:Connect(function() local ch = LP.Character; if ch then local h = ch:FindFirstChildOfClass("Humanoid"); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end) else if c then c:Disconnect() end end
end)
mkT(Scroll, "BẤT TỬ (GODMODE)", false, function(s)
    local c
    if s then c = RunService.Heartbeat:Connect(function() local ch = LP.Character; if ch then local h = ch:FindFirstChildOfClass("Humanoid"); if h then h.Health = h.MaxHealth end end end) else if c then c:Disconnect() end end
end)
mkT(Scroll, "SPEED HACK", false, function(s) local ch = LP.Character; if ch and ch:FindFirstChildOfClass("Humanoid") then ch.Humanoid.WalkSpeed = s and 150 or 16 end end)
mkT(Scroll, "TÀNG HÌNH (INVISIBLE)", false, function(s)
    local ch = LP.Character; if not ch then return end
    for _, v in ipairs(ch:GetDescendants()) do
        if v:IsA("BasePart") then v.Transparency = s and 1 or 0 end
        if v:IsA("Decal") then v.Transparency = s and 1 or 0 end
    end
end)

-- 2. COMBAT
mkH(Scroll, "--- CHIẾN ĐẤU ---")
mkT(Scroll, "AUTO FARM", false, function(s)
    local c
    if s then c = RunService.Heartbeat:Connect(function()
        local ch = LP.Character; if not ch or not ch:FindFirstChild("HumanoidRootPart") then return end
        local cl, d = nil, math.huge
        for _, o in ipairs(Workspace:GetDescendants()) do
            if o:IsA("Model") and o:FindFirstChild("HumanoidRootPart") and o:FindFirstChildOfClass("Humanoid") and o.Name ~= LP.Name then
                local h = o:FindFirstChildOfClass("Humanoid")
                if h.Health > 0 then local di = (o.HumanoidRootPart.Position - ch.HumanoidRootPart.Position).Magnitude; if di < d then cl, d = o, di end end
            end
        end
        if cl and d < 50 then local t = ch:FindFirstChildOfClass("Tool"); if t then pcall(function() t:Activate() end) end end
    end) else if c then c:Disconnect() end end
end)
mkT(Scroll, "AUTO CLICK", false, function(s)
    local c
    if s then c = RunService.Heartbeat:Connect(function() local ch = LP.Character; if ch then local t = ch:FindFirstChildOfClass("Tool"); if t then pcall(function() t:Activate() end) end end end) else if c then c:Disconnect() end end
end)
mkT(Scroll, "MỞ RỘNG HITBOX", false, function(s)
    local ch = LP.Character; if ch and ch:FindFirstChild("HumanoidRootPart") then ch.HumanoidRootPart.Size = s and Vector3.new(10,10,10) or Vector3.new(2,2,1) end
end)

-- 3. UTILITY
mkH(Scroll, "--- TIỆN ÍCH ---")
mkT(Scroll, "FOV 120", false, function(s) Cam.FieldOfView = s and 120 or 70 end)
mkT(Scroll, "XÓA SƯƠNG MÙ", false, function(s) Lighting.FogEnd = s and math.huge or Lighting.FogEnd end)
mkT(Scroll, "FULLBRIGHT", false, function(s) Lighting.Ambient = s and Color3.fromRGB(255,255,255) or Lighting.Ambient; Lighting.OutdoorAmbient = s and Color3.fromRGB(255,255,255) or Lighting.OutdoorAmbient end)
mkT(Scroll, "AUTO HỒI MÁU", false, function(s)
    local c
    if s then c = RunService.Heartbeat:Connect(function()
        local ch = LP.Character; if ch then local h = ch:FindFirstChildOfClass("Humanoid"); if h and h.Health < h.MaxHealth then for _, t in ipairs(LP.Backpack:GetChildren()) do if t:IsA("Tool") and (t.Name:lower():find("heal") or t.Name:lower():find("potion")) then t.Parent = ch; t:Activate() end end end end
    end) else if c then c:Disconnect() end end
end)

-- 4. ESP
mkH(Scroll, "--- ESP ---")
local EF = Instance.new("Folder", (gethui and gethui()) or CoreGui); EF.Name = "ESP_Folder"
local EO = {}
local ES = { p=false, m=false, i=false }
local function clr() for _, o in pairs(EO) do pcall(function() o.b:Destroy() end); pcall(function() o.h:Destroy() end) end; table.clear(EO) end
local function addE(ad, col, txt)
    if not ad or EO[ad] then return end
    local b = Instance.new("BillboardGui"); b.Adornee = ad; b.Size = UDim2.new(0,200,0,40); b.StudsOffset = Vector3.new(0,3,0); b.AlwaysOnTop = true; b.Parent = EF
    local l = Instance.new("TextLabel"); l.Size = UDim2.new(1,0,1,0); l.BackgroundTransparency = 1; l.Text = txt; l.TextColor3 = col; l.TextStrokeTransparency = 0; l.Font = Enum.Font.GothamBold; l.TextScaled = true; l.Parent = b
    local h = Instance.new("Highlight"); h.Adornee = ad; h.FillColor = col; h.OutlineColor = col; h.FillTransparency = 0.55; h.Parent = EF
    EO[ad] = {b=b, h=h}
end
local function isPC(m) for _, p in ipairs(Players:GetPlayers()) do if p.Character == m then return true end end return false end
local function isM(m) return m:IsA("Model") and not isPC(m) and m:FindFirstChildOfClass("Humanoid") ~= nil end
local function isI(m) return m:IsA("Tool") or m.Name:lower():find("item") or m.Name:lower():find("coin") end
local function sAll()
    clr()
    for _, o in ipairs(Workspace:GetDescendants()) do
        local r = o:IsA("Model") and (o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")) or (o:IsA("BasePart") and o)
        if r then
            if ES.p then for _, p in ipairs(Players:GetPlayers()) do if p.Character == o then addE(r, Color3.fromRGB(0,255,100), "[P] "..p.Name) end end end
            if ES.m and isM(o) then addE(r, Color3.fromRGB(255,50,50), "[QUÁI] "..o.Name) end
            if ES.i and isI(o) then addE(r, Color3.fromRGB(0,200,255), "[ĐỒ] "..o.Name) end
        end
    end
end
mkT(Scroll, "ESP NGƯỜI CHƠI", false, function(s) ES.p=s; sAll() end)
mkT(Scroll, "ESP QUÁI", false, function(s) ES.m=s; sAll() end)
mkT(Scroll, "ESP VẬT PHẨM", false, function(s) ES.i=s; sAll() end)
task.spawn(function() while SG.Parent do task.wait(3); if ES.p or ES.m or ES.i then sAll() end end end)

-- 5. TELEPORT
mkH(Scroll, "--- TELEPORT ---")
local function tp(pos) local ch = LP.Character; if ch and ch:FindFirstChild("HumanoidRootPart") then ch.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0,5,0)) end end
mkB(Scroll, "📍 LƯU VỊ TRÍ", function() if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then _G.SAVED = LP.Character.HumanoidRootPart.Position end end)
mkB(Scroll, "🚀 QUAY LẠI VỊ TRÍ", function() if _G.SAVED then tp(_G.SAVED) end end)
mkB(Scroll, "🧑 DỊCH CHUYỂN NGƯỜI CHƠI", function()
    local lf = Instance.new("Frame"); lf.Size = UDim2.new(0,260,0,350); lf.Position = UDim2.new(0.5,-130,0.5,-175); lf.BackgroundColor3 = Color3.fromRGB(15,15,22); lf.Parent = SG
    Instance.new("UICorner", lf).CornerRadius = UDim.new(0,8)
    local t = Instance.new("TextLabel"); t.Size = UDim2.new(1,0,0,32); t.BackgroundColor3 = Color3.fromRGB(25,25,35); t.Text = "CHỌN NGƯỜI"; t.TextColor3 = Color3.fromRGB(0,200,255); t.Font = Enum.Font.GothamBold; t.Parent = lf
    local c = Instance.new("TextButton"); c.Size = UDim2.new(0,28,0,28); c.Position = UDim2.new(1,-30,0,2); c.BackgroundColor3 = Color3.fromRGB(200,50,50); c.Text = "X"; c.TextColor3 = Color3.new(1,1,1); c.Parent = lf; c.MouseButton1Click:Connect(function() lf:Destroy() end)
    local s = Instance.new("ScrollingFrame"); s.Size = UDim2.new(1,-10,1,-40); s.Position = UDim2.new(0,5,0,35); s.BackgroundTransparency = 1; s.CanvasSize = UDim2.new(0,0,0,0); s.AutomaticCanvasSize = Enum.AutomaticSize.Y; s.Parent = lf
    Instance.new("UIListLayout", s).Padding = UDim.new(0,5)
    for _, p in ipairs(Players:GetPlayers()) do if p ~= LP then local b = Instance.new("TextButton"); b.Size = UDim2.new(1,-10,0,36); b.BackgroundColor3 = Color3.fromRGB(30,30,45); b.Text = p.Name; b.TextColor3 = Color3.new(1,1,1); b.Parent = s; Instance.new("UICorner", b).CornerRadius = UDim.new(0,5); b.MouseButton1Click:Connect(function() if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then tp(p.Character.HumanoidRootPart.Position); lf:Destroy() end end) end end
end)

-- 6. FARM & ITEM
mkH(Scroll, "--- ITEM ---")
mkT(Scroll, "HÚT ĐỒ (VACUUM)", false, function(s)
    local c
    if s then c = RunService.Heartbeat:Connect(function()
        local ch = LP.Character; if ch and ch:FindFirstChild("HumanoidRootPart") then local h = ch.HumanoidRootPart; for _, o in ipairs(Workspace:GetDescendants()) do if o:IsA("BasePart") and not o:IsDescendantOf(ch) and (o.Name:lower():find("item") or o.Name:lower():find("drop")) and (o.Position - h.Position).Magnitude < 100 then o.CFrame = h.CFrame end end end
    end) else if c then c:Disconnect() end end
end)
local iST = ""
mkI(Scroll, "Tên đồ cần tìm", "", function(t) iST = t:lower() end)
mkT(Scroll, "BAY ĐẾN ĐỒ", false, function(s)
    local c
    if s then c = RunService.Heartbeat:Connect(function()
        if iST == "" then return end
        local ch = LP.Character; if ch and ch:FindFirstChild("HumanoidRootPart") then for _, o in ipairs(Workspace:GetDescendants()) do if o:IsA("BasePart") and not o:IsDescendantOf(ch) and o.Name:lower():find(iST) then ch.HumanoidRootPart.CFrame = CFrame.new(o.Position + Vector3.new(0,5,0)); break end end end
    end) else if c then c:Disconnect() end end
end)
local dAmt = 1
mkI(Scroll, "Số lượng nhân bản", dAmt, function(v) dAmt = tonumber(v) or 1 end)
mkB(Scroll, "📦 NHÂN BẢN ĐỒ", function()
    local bp = LP:FindFirstChild("Backpack"); if not bp then return end
    for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then for i=1,dAmt do pcall(function() local cl = t:Clone(); cl.Parent = LP.Character end) end end end
end)

-- 7. MEME & FUN
mkH(Scroll, "--- MEME & FUN ---")
mkT(Scroll, "ĐẢO NGƯỢC ĐIỀU KHIỂN", false, function(s)
    local c
    if s then c = RunService.RenderStepped:Connect(function()
        local ch = LP.Character; if ch and ch:FindFirstChildOfClass("Humanoid") then
            local m = ch.Humanoid.MoveDirection
            if m.Magnitude > 0 then ch.Humanoid:Move(-m, false) end
        end
    end) else if c then c:Disconnect() end end
end)
mkT(Scroll, "PHÓNG TO NHÂN VẬT (GIANT)", false, function(s)
    local ch = LP.Character; if not ch then return end
    for _, v in ipairs(ch:GetDescendants()) do if v:IsA("BasePart") then v.Size = s and v.Size * 2 or v.Size / 2 end end
end)
local spamTxt = ""
mkI(Scroll, "Tin nhắn spam", "", function(t) spamTxt = t end)
mkT(Scroll, "SPAM CHAT", false, function(s)
    local c
    if s then c = task.spawn(function()
        while s do
            if spamTxt ~= "" then pcall(function() game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(spamTxt, "All") end) end
            task.wait(0.5)
        end
    end) else if c then task.cancel(c) end end
end)
local musicId = ""
mkI(Scroll, "ID Nhạc (rbxassetid)", "", function(t) musicId = t end)
mkB(Scroll, "PHÁT NHẠC", function()
    if musicId ~= "" then
        local snd = Instance.new("Sound", LP.Character.HumanoidRootPart)
        snd.SoundId = "rbxassetid://" .. musicId; snd:Play()
    end
end)
