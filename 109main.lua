-- ngôn ngữ: Lua, tệp: anon_hub_hop_nhat.lua, nền tảng: trình chạy Roblox
-- *BẢN RÚT GỌN — Tối ưu code, giữ nguyên 100% chức năng.*
-- *Đã sửa: Menu cao 380px, vuốt mượt (Active = true), nút TextLabel không chặn vuốt.*

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local MarketplaceService = game:GetService("MarketplaceService")
local Stats = game:GetService("Stats")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local RULE_FILE, CONFIG_FILE = "anon_luat_esp.json", "anon_caidat.json"

-- ============================================================
-- TIỆN DỤNG
-- ============================================================
local function noti(t, n, d) pcall(function() StarterGui:SetCore("SendNotification", {Title=t or "ANON HUB", Text=n or "", Duration=d or 2}) end) end
local function getChar() return LP.Character or LP.CharacterAdded:Wait() end
local function getHum() return getChar():FindFirstChildOfClass("Humanoid") end
local function getHRP() return getChar():FindFirstChild("HumanoidRootPart") end
local function getRoot() return LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") end

local playerSet = {}
local function updatePlayers() playerSet = {}; for _, p in pairs(Players:GetPlayers()) do if p.Character then playerSet[p.Character] = true end end end

-- ============================================================
-- TRẠNG THÁI
-- ============================================================
local S = {
    speed=false, speedVal=60, jump=false, jumpVal=100, fly=false, flySpeed=80,
    noclip=false, infJump=false, antiAfk=true, antiVoid=false, spin=false, spinSpeed=8, bhop=false,
    waterWalk=false, hover=false, hoverHeight=5, clickTp=false, follow=nil, followDist=10, orbit=nil, orbitRad=15, orbitSpeed=3,
    antiFling=false, antiRagdoll=false, antiSlow=false, customGrav=false, gravVal=196.2,
    espP=false, espM=false, espI=false, espTrace=false, espName=false, espHp=false, espDist=false, espBone=false,
    colP=Color3.fromRGB(255,80,80), colM=Color3.fromRGB(255,180,60), colI=Color3.fromRGB(100,255,160), colTrace=Color3.fromRGB(255,100,255), colBone=Color3.fromRGB(255,100,255),
    autoClick=false, autoTool=false, aura=false, auraRange=15, aimbot=false, aimSmooth=0.15, aimFov=150, aimPart="Head",
    trigger=false, trigDelay=0.05, silent=false, silentFov=200, hitbox=false, hitboxSize=2, autoShoot=false, shootDelay=0.05,
    farmHut=false, hutRange=50, farmPrompt=false,
    autoReply=false, replyMsg="Bot đang chơi", spam=false, spamMsg="", spamDelay=2,
    camFree=false, camDist=20, rapidFire=false, rapidDelay=0.05, infAmmo=false, autoRespawn=false, autoEquip=false, logRemote=false,
    rainbow=false, spinCam=false, spinCamSpeed=5, headless=false, giant=false, giantScale=3, tiny=false, tinyScale=0.3,
    rejoin=false, scanInterval=0.15, autoPrompt=false,
}
local Rules = { mob = {}, item = {} }

-- ============================================================
-- LƯU / ĐỌC
-- ============================================================
local function saveAll()
    if not writefile then return end
    pcall(function()
        writefile(RULE_FILE, HttpService:JSONEncode(Rules))
        writefile(CONFIG_FILE, HttpService:JSONEncode({
            speedVal=S.speedVal, jumpVal=S.jumpVal, flySpeed=S.flySpeed, auraRange=S.auraRange,
            aimSmooth=S.aimSmooth, aimFov=S.aimFov, aimPart=S.aimPart, hutRange=S.hutRange, scanInterval=S.scanInterval,
        }))
    end)
end
local function loadAll()
    if not isfile or not readfile then return end
    pcall(function()
        if isfile(RULE_FILE) then
            local d = HttpService:JSONDecode(readfile(RULE_FILE))
            if d.mob then Rules.mob = d.mob end
            if d.item then Rules.item = d.item end
        end
        if isfile(CONFIG_FILE) then
            local c = HttpService:JSONDecode(readfile(CONFIG_FILE))
            for k, v in pairs(c) do if S[k] ~= nil then S[k] = v end end
        end
    end)
end
loadAll()

-- ============================================================
-- KHỚP DẤU HIỆU
-- ============================================================
local function matchSig(obj, sig)
    if not obj or not obj.Parent then return false end
    if sig.class and obj.ClassName ~= sig.class then
        if not obj:FindFirstAncestorOfClass(sig.class) then return false end
    end
    if sig.name and sig.name ~= "" then
        if not string.find(string.lower(obj.Name), string.lower(sig.name), 1, true) then
            local anc = sig.class and obj:FindFirstAncestorOfClass(sig.class)
            if not (anc and string.find(string.lower(anc.Name), string.lower(sig.name), 1, true)) then return false end
        end
    end
    if sig.tags and #sig.tags > 0 then
        local found = false
        for _, t in ipairs(sig.tags) do if CollectionService:HasTag(obj, t) then found = true; break end end
        if not found then return false end
    end
    if sig.attrs then
        for k, v in pairs(sig.attrs) do if obj:GetAttribute(k) ~= v then return false end end
    end
    if sig.folder and sig.folder ~= "" then
        local p, found = obj.Parent, false
        for _ = 1, 6 do
            if not p or p == Workspace or p == game then break end
            if string.lower(p.Name) == string.lower(sig.folder) then found = true; break end
            p = p.Parent
        end
        if not found then return false end
    end
    if sig.hasHum ~= nil then if (obj:FindFirstChildOfClass("Humanoid") ~= nil) ~= sig.hasHum then return false end end
    if sig.size then
        local sz
        if obj:IsA("BasePart") then sz = obj.Size
        elseif obj:IsA("Model") then local pp = obj:FindFirstChildWhichIsA("BasePart"); if pp then sz = pp.Size end end
        if sz and (sz.Magnitude < sig.size.min or sz.Magnitude > sig.size.max) then return false end
    end
    return true
end
local function matchAny(obj, list) for _, sig in ipairs(list) do if matchSig(obj, sig) then return true end end return false end

local function makeSig(obj)
    local model = obj:FindFirstAncestorOfClass("Model") or obj
    local sig = {}
    if obj:IsA("Tool") then sig.class = "Tool"
    elseif model:IsA("Model") then sig.class = "Model"
    elseif obj:IsA("BasePart") then sig.class = "BasePart" end
    local nm = (sig.class == "Model") and model.Name or obj.Name
    local clean = string.gsub(string.gsub(nm, "%d+", ""), "^%s*(.-)%s*$", "%1")
    if #clean >= 2 then sig.name = clean end
    local tags = {}
    for _, t in ipairs(CollectionService:GetTags(obj)) do table.insert(tags, t) end
    if #tags > 0 then sig.tags = tags end
    local attrs = {}
    for k, v in pairs(obj:GetAttributes()) do
        if type(v) == "string" or type(v) == "number" or type(v) == "boolean" then attrs[k] = v end
    end
    if next(attrs) then sig.attrs = attrs end
    local target = (sig.class == "Model") and model or obj
    if target.Parent and target.Parent ~= Workspace and target.Parent:IsA("Folder") then sig.folder = target.Parent.Name end
    if sig.class == "Model" then sig.hasHum = (model:FindFirstChildOfClass("Humanoid") ~= nil) end
    if obj:IsA("BasePart") then
        local sz = obj.Size.Magnitude
        sig.size = { min = sz * 0.7, max = sz * 1.4 }
    end
    return sig
end

-- ============================================================
-- GIAO DIỆN (SIÊU GỌN)
-- ============================================================
local coreGui = (gethui and gethui()) or game:GetService("CoreGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ANON_Hub_ToiGian"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = coreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 280, 0, 380)
Main.Position = UDim2.new(0, 40, 0, 80)
Main.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", Main); stroke.Color = Color3.fromRGB(60, 60, 75)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
TopBar.Parent = Main
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)
local mask = Instance.new("Frame")
mask.Size = UDim2.new(1, 0, 0, 10); mask.Position = UDim2.new(0, 0, 1, -10)
mask.BackgroundColor3 = Color3.fromRGB(26, 26, 34); mask.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0); Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1; Title.Text = "ANON HUB — TỐI GIẢN"
Title.TextColor3 = Color3.fromRGB(230, 230, 240); Title.Font = Enum.Font.GothamBold
Title.TextSize = 12; Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 22, 0, 22); MinBtn.Position = UDim2.new(1, -28, 0, 4)
MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60); MinBtn.Text = "–"
MinBtn.TextColor3 = Color3.fromRGB(220, 220, 230); MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14; MinBtn.Parent = TopBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)

local TabBar = Instance.new("ScrollingFrame")
TabBar.Size = UDim2.new(1, 0, 0, 24); TabBar.Position = UDim2.new(0, 0, 0, 30)
TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 26); TabBar.BorderSizePixel = 0
TabBar.ScrollBarThickness = 0; TabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
TabBar.AutomaticCanvasSize = Enum.AutomaticSize.X; TabBar.ScrollingDirection = Enum.ScrollingDirection.X
TabBar.ScrollingEnabled = true; TabBar.Active = true; TabBar.Parent = Main
local tl = Instance.new("UIListLayout", TabBar)
tl.FillDirection = Enum.FillDirection.Horizontal; tl.Padding = UDim.new(0, 2); tl.SortOrder = Enum.SortOrder.LayoutOrder
local tp = Instance.new("UIPadding", TabBar); tp.PaddingLeft = UDim.new(0, 4); tp.PaddingTop = UDim.new(0, 2)

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -12, 1, -60); Content.Position = UDim2.new(0, 6, 0, 56)
Content.BackgroundTransparency = 1; Content.BorderSizePixel = 0
Content.ScrollBarThickness = 6; Content.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
Content.CanvasSize = UDim2.new(0, 0, 0, 0); Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.ScrollingDirection = Enum.ScrollingDirection.Y; Content.ScrollingEnabled = true
Content.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable; Content.Active = true
Content.Parent = Main
local cl = Instance.new("UIListLayout", Content)
cl.Padding = UDim.new(0, 5); cl.SortOrder = Enum.SortOrder.LayoutOrder

-- kéo thả
local drag, dragStart, startPos
TopBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag = true; dragStart = i.Position; startPos = Main.Position
        i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then drag = false end end)
    end
end)
UIS.InputChanged:Connect(function(i)
    if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

local min = false
MinBtn.MouseButton1Click:Connect(function()
    min = not min
    TweenService:Create(Main, TweenInfo.new(0.2), { Size = min and UDim2.new(0, 280, 0, 30) or UDim2.new(0, 280, 0, 380) }):Play()
    Content.Visible = not min; TabBar.Visible = not min
    MinBtn.Text = min and "+" or "–"
end)

-- ============================================================
-- HÀM GIAO DIỆN TỐI GIẢN
-- ============================================================
local tabs = {}
local function newTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 18); btn.BackgroundColor3 = Color3.fromRGB(35, 35, 44)
    btn.Text = (icon and icon .. " " or "") .. name; btn.TextColor3 = Color3.fromRGB(180, 180, 190)
    btn.Font = Enum.Font.Gotham; btn.TextSize = 9; btn.AutoButtonColor = false; btn.Parent = TabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 1, 0); f.BackgroundTransparency = 1; f.Visible = false; f.Parent = Content
    local fl = Instance.new("UIListLayout", f)
    fl.Padding = UDim.new(0, 4); fl.SortOrder = Enum.SortOrder.LayoutOrder
    tabs[name] = { btn = btn, frame = f }
    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do t.frame.Visible = false; t.btn.BackgroundColor3 = Color3.fromRGB(35, 35, 44) end
        f.Visible = true; btn.BackgroundColor3 = Color3.fromRGB(60, 90, 140)
    end)
    return { btn = btn, frame = f }
end

local function newSection(p, text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 16); l.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    l.Text = "  " .. text; l.TextColor3 = Color3.fromRGB(120, 200, 255)
    l.Font = Enum.Font.GothamBold; l.TextSize = 9; l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = p; Instance.new("UICorner", l).CornerRadius = UDim.new(0, 4)
end

local function newBtn(p, text, cb)
    local b = Instance.new("TextLabel")
    b.Size = UDim2.new(1, 0, 0, 24); b.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    b.Text = text; b.TextColor3 = Color3.fromRGB(210, 210, 220)
    b.Font = Enum.Font.Gotham; b.TextSize = 10; b.Parent = p
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    local pressed = false
    b.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then pressed = true; b.BackgroundColor3 = Color3.fromRGB(38, 38, 48) end end)
    b.InputEnded:Connect(function(i) if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and pressed then b.BackgroundColor3 = Color3.fromRGB(28, 28, 36); pressed = false; cb() end end)
    return b
end

local function newToggle(p, text, def, cb)
    local state = def or false
    local b = Instance.new("TextLabel")
    b.Size = UDim2.new(1, 0, 0, 24); b.BackgroundColor3 = Color3.fromRGB(28, 28, 36); b.Text = ""; b.Parent = p
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    local lbl = Instance.new("TextLabel", b)
    lbl.Size = UDim2.new(1, -50, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0); lbl.BackgroundTransparency = 1
    lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(210, 210, 220); lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 10; lbl.TextXAlignment = Enum.TextXAlignment.Left
    local ind = Instance.new("Frame", b)
    ind.Size = UDim2.new(0, 26, 0, 12); ind.Position = UDim2.new(1, -34, 0.5, -6)
    ind.BackgroundColor3 = state and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(50, 50, 60)
    Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame", ind)
    knob.Size = UDim2.new(0, 10, 0, 10); knob.Position = UDim2.new(0, state and 15 or 1, 0, 1)
    knob.BackgroundColor3 = Color3.fromRGB(230, 230, 240); Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local pressed = false
    b.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then pressed = true end end)
    b.InputEnded:Connect(function(i)
        if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and pressed then
            pressed = false; state = not state
            TweenService:Create(ind, TweenInfo.new(0.15), {BackgroundColor3 = state and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(50, 50, 60)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.15), {Position = UDim2.new(0, state and 15 or 1, 0, 1)}):Play()
            if cb then cb(state) end
        end
    end)
    return b
end

local function newSlider(p, text, min, max, def, cb)
    local h = Instance.new("Frame", p)
    h.Size = UDim2.new(1, 0, 0, 38); h.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    Instance.new("UICorner", h).CornerRadius = UDim.new(0, 4)
    local lbl = Instance.new("TextLabel", h)
    lbl.Size = UDim2.new(1, -12, 0, 16); lbl.Position = UDim2.new(0, 8, 0, 2); lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": " .. tostring(def); lbl.TextColor3 = Color3.fromRGB(210, 210, 220)
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 10; lbl.TextXAlignment = Enum.TextXAlignment.Left
    local bar = Instance.new("Frame", h)
    bar.Size = UDim2.new(1, -16, 0, 6); bar.Position = UDim2.new(0, 8, 0, 26)
    bar.BackgroundColor3 = Color3.fromRGB(50, 50, 60); Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((def - min) / (max - min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(120, 200, 255)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local drag = false
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local pct = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            local val = min + (max - min) * pct
            lbl.Text = text .. ": " .. string.format("%.1f", val)
            if cb then cb(val) end
        end
    end)
end

local function newInput(p, ph, cb)
    local f = Instance.new("Frame", p)
    f.Size = UDim2.new(1, 0, 0, 26); f.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
    local box = Instance.new("TextBox", f)
    box.Size = UDim2.new(1, -12, 1, -4); box.Position = UDim2.new(0, 6, 0, 2)
    box.BackgroundTransparency = 1; box.Text = ""; box.PlaceholderText = ph
    box.TextColor3 = Color3.fromRGB(210, 210, 220); box.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
    box.Font = Enum.Font.Gotham; box.TextSize = 10; box.TextXAlignment = Enum.TextXAlignment.Left
    box.ClearTextOnFocus = false; box.FocusLost:Connect(function() if cb then cb(box.Text) end end)
    return box
end

local function newColor(p, text, def, cb)
    local h = Instance.new("TextLabel")
    h.Size = UDim2.new(1, 0, 0, 24); h.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    Instance.new("UICorner", h).CornerRadius = UDim.new(0, 4)
    local lbl = Instance.new("TextLabel", h)
    lbl.Size = UDim2.new(1, -50, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0); lbl.BackgroundTransparency = 1
    lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(210, 210, 220); lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 10; lbl.TextXAlignment = Enum.TextXAlignment.Left
    local swatch = Instance.new("Frame", h)
    swatch.Size = UDim2.new(0, 20, 0, 12); swatch.Position = UDim2.new(1, -28, 0.5, -6)
    swatch.BackgroundColor3 = def; Instance.new("UICorner", swatch).CornerRadius = UDim.new(0, 3)
    local colors = { Color3.fromRGB(255,80,80), Color3.fromRGB(80,200,255), Color3.fromRGB(100,255,160), Color3.fromRGB(255,200,60), Color3.fromRGB(200,100,255), Color3.fromRGB(255,255,255) }
    local idx = 1
    for i, c in ipairs(colors) do if c == def then idx = i end end
    h.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            idx = (idx % #colors) + 1; swatch.BackgroundColor3 = colors[idx]
            if cb then cb(colors[idx]) end
        end
    end)
end

-- ============================================================
-- ESP ENGINE
-- ============================================================
local function addHL(obj, color, name)
    if not obj or not obj.Parent or obj:FindFirstChild(name) then return end
    local hl = Instance.new("Highlight")
    hl.Name = name; hl.Adornee = obj; hl.FillColor = color
    hl.OutlineColor = Color3.fromRGB(255,255,255); hl.FillTransparency = 0.5
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = obj
end
local function delHL(obj, name) if obj and obj:FindFirstChild(name) then obj[name]:Destroy() end end

local tracerGui = Instance.new("ScreenGui"); tracerGui.Name = "ANON_Trace"; tracerGui.ResetOnSpawn = false; tracerGui.IgnoreGuiInset = true; tracerGui.Parent = coreGui
local tracers = {}
local function updateTracers()
    if not S.espTrace then
        for _, t in pairs(tracers) do if typeof(t) == "Instance" then t:Destroy() elseif t.Remove then pcall(function() t:Remove() end) end end
        tracers = {}; return
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local sp = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if sp.Z > 0 then
                local t = tracers[p]
                if not t then
                    if Drawing then t = Drawing.new("Line"); t.Thickness = 1.5; t.Color = S.colTrace; t.Transparency = 1
                    else t = Instance.new("Frame", tracerGui); t.BorderSizePixel = 0; t.BackgroundColor3 = S.colTrace end
                    tracers[p] = t
                end
                local gx, gy = Camera.ViewportSize.X/2, Camera.ViewportSize.Y
                if Drawing then
                    t.From = Vector2.new(gx, gy); t.To = Vector2.new(sp.X, sp.Y); t.Color = S.colTrace; t.Visible = true
                else
                    local dx, dy = sp.X - gx, sp.Y - gy
                    local len, ang = math.sqrt(dx*dx + dy*dy), math.atan2(dy, dx)
                    t.Position = UDim2.new(0, gx, 0, gy); t.Size = UDim2.new(0, len, 0, 1); t.Rotation = math.deg(ang)
                end
            else
                local t = tracers[p]; if t and Drawing then t.Visible = false end
            end
        end
    end
end

local boneGui = Instance.new("ScreenGui"); boneGui.Name = "ANON_Bone"; boneGui.ResetOnSpawn = false; boneGui.IgnoreGuiInset = true; boneGui.Parent = coreGui
local bones = {}
local function updateBones()
    if not S.espBone then
        for _, ds in pairs(bones) do for _, l in pairs(ds) do if typeof(l) == "Instance" then l:Destroy() elseif l.Remove then pcall(function() l:Remove() end) end end end
        bones = {}; return
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local c = p.Character
            local hrp, head = c:FindFirstChild("HumanoidRootPart"), c:FindFirstChild("Head")
            local rArm, lArm = c:FindFirstChild("RightUpperArm") or c:FindFirstChild("Right Arm"), c:FindFirstChild("LeftUpperArm") or c:FindFirstChild("Left Arm")
            local rLeg, lLeg = c:FindFirstChild("RightUpperLeg") or c:FindFirstChild("Right Leg"), c:FindFirstChild("LeftUpperLeg") or c:FindFirstChild("Left Leg")
            if hrp and head then
                local ds = bones[p] or {}
                local seg = { {hrp, head}, {head, rArm}, {head, lArm}, {hrp, rLeg}, {hrp, lLeg} }
                for i, s in ipairs(seg) do
                    local a, b = s[1], s[2]
                    if a and b then
                        local sa, sb = Camera:WorldToViewportPoint(a.Position), Camera:WorldToViewportPoint(b.Position)
                        if sa.Z > 0 and sb.Z > 0 then
                            local l = ds[i]
                            if not l then
                                if Drawing then l = Drawing.new("Line"); l.Thickness = 1.5; l.Color = S.colBone; l.Transparency = 1
                                else l = Instance.new("Frame", boneGui); l.BorderSizePixel = 0; l.BackgroundColor3 = S.colBone end
                                ds[i] = l
                            end
                            if Drawing then l.From = Vector2.new(sa.X, sa.Y); l.To = Vector2.new(sb.X, sb.Y); l.Color = S.colBone; l.Visible = true
                            else
                                local dx, dy = sb.X - sa.X, sb.Y - sa.Y
                                local len, ang = math.sqrt(dx*dx + dy*dy), math.atan2(dy, dx)
                                l.Position = UDim2.new(0, sa.X, 0, sa.Y); l.Size = UDim2.new(0, len, 0, 1.5); l.Rotation = math.deg(ang)
                            end
                        end
                    end
                end
                bones[p] = ds
            end
        end
    end
end

local labelGui = Instance.new("ScreenGui"); labelGui.Name = "ANON_Label"; labelGui.ResetOnSpawn = false; labelGui.IgnoreGuiInset = true; labelGui.Parent = coreGui
local labels = {}
local function updateLabels()
    if not (S.espName or S.espHp or S.espDist) then
        for _, l in pairs(labels) do l:Destroy() end
        labels = {}; return
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local sp = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if sp.Z > 0 then
                local l = labels[p]
                if not l then
                    l = Instance.new("TextLabel", labelGui); l.BackgroundTransparency = 1
                    l.Font = Enum.Font.GothamBold; l.TextSize = 10; l.TextColor3 = Color3.fromRGB(255,255,255)
                    l.TextStrokeTransparency = 0; l.Size = UDim2.new(0, 200, 0, 40); l.TextXAlignment = Enum.TextXAlignment.Center
                    labels[p] = l
                end
                local lines = {}
                if S.espName then table.insert(lines, p.Name) end
                if S.espHp then
                    local h = p.Character:FindFirstChildOfClass("Humanoid")
                    if h then table.insert(lines, string.format("Máu: %d/%d", h.Health, h.MaxHealth)) end
                end
                if S.espDist then
                    local hrp = getHRP()
                    if hrp then table.insert(lines, string.format("%.0fm", (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude)) end
                end
                l.Text = table.concat(lines, "\n"); l.Position = UDim2.new(0, sp.X - 100, 0, sp.Y - 50); l.Visible = true
            else
                local l = labels[p]; if l then l.Visible = false end
            end
        end
    end
end

local espConn, espOn, lastScan = nil, false, 0
local function startEsp()
    if espOn then return end
    espOn = true
    espConn = RunService.RenderStepped:Connect(function()
        local now = tick()
        if now - lastScan >= S.scanInterval then
            lastScan = now; updatePlayers()
            if S.espP then for _, p in pairs(Players:GetPlayers()) do if p ~= LP and p.Character then addHL(p.Character, S.colP, "ANON_P") end end
            else for _, p in pairs(Players:GetPlayers()) do if p.Character then delHL(p.Character, "ANON_P") end end end
            for _, o in pairs(Workspace:GetDescendants()) do
                if (o:IsA("Model") or o:IsA("BasePart")) and not playerSet[o] then
                    if S.espM and matchAny(o, Rules.mob) then addHL(o, S.colM, "ANON_M")
                    elseif not S.espM then delHL(o, "ANON_M") end
                end
            end
            for _, o in pairs(Workspace:GetDescendants()) do
                if o:IsA("Model") or o:IsA("BasePart") or o:IsA("Tool") then
                    if S.espI and matchAny(o, Rules.item) then addHL(o, S.colI, "ANON_I")
                    elseif not S.espI then delHL(o, "ANON_I") end
                end
            end
        end
        updateTracers(); updateBones(); updateLabels()
    end)
end
local function stopEspIfNeeded()
    if not S.espP and not S.espM and not S.espI and not S.espTrace and not S.espName and not S.espHp and not S.espDist and not S.espBone then
        if espConn then espConn:Disconnect() end; espOn = false
    end
end

-- Học ESP
local learnMode, learnConn = nil, nil
local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(0, 400, 0, 36); hint.Position = UDim2.new(0.5, -200, 0, 60)
hint.BackgroundColor3 = Color3.fromRGB(20, 20, 28); hint.TextColor3 = Color3.fromRGB(120, 255, 160)
hint.Font = Enum.Font.GothamBold; hint.TextSize = 13; hint.Visible = false; hint.Parent = ScreenGui
Instance.new("UICorner", hint).CornerRadius = UDim.new(0, 6)
local hStroke = Instance.new("UIStroke", hint); hStroke.Color = Color3.fromRGB(80, 200, 120); hStroke.Thickness = 2

local function stopLearn() learnMode = nil; hint.Visible = false; if learnConn then learnConn:Disconnect(); learnConn = nil end end
local function startLearn(mode)
    stopLearn(); learnMode = mode
    hint.Text = (mode == "mob") and "🎯 Nhấp QUÁI (ESC dừng)" or "🎯 Nhấp VẬT PHẨM (ESC dừng)"
    hint.Visible = true
    learnConn = UIS.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.KeyCode == Enum.KeyCode.Escape then stopLearn(); return end
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        local m = UIS:GetMouseLocation()
        local ray = Camera:ViewportPointToRay(m.X, m.Y)
        local rp = RaycastParams.new(); rp.FilterType = Enum.RaycastFilterType.Exclude; rp.FilterDescendantsInstances = { getChar(), ScreenGui }
        local res = Workspace:Raycast(ray.Origin, ray.Direction * 1000, rp)
        if res and res.Instance then
            local clicked = res.Instance
            local target = clicked:IsA("Tool") and clicked or clicked:FindFirstAncestorOfClass("Model") or clicked
            local sig = makeSig(target); local j = HttpService:JSONEncode(sig)
            local list = (mode == "mob") and Rules.mob or Rules.item
            for _, e in ipairs(list) do if HttpService:JSONEncode(e) == j then noti("ANON HUB", "Đã có luật"); return end end
            table.insert(list, sig); saveAll()
            if mode == "mob" then S.espM = true else S.espI = true end
            startEsp(); noti("ANON HUB", "✅ Đã học: "..target.Name, 2)
        end
    end)
end

-- ============================================================
-- LOGIC VÒNG LẶP
-- ============================================================
local loops = {}
local function setL(n, fn) if loops[n] then loops[n]:Disconnect(); loops[n] = nil end; if fn then loops[n] = fn() end end

local function applySpeed()
    if S.speed then setL("speed", function() return RunService.Heartbeat:Connect(function() local h = getHum(); if h then h.WalkSpeed = S.speedVal end end) end)
    else setL("speed", nil); local h = getHum(); if h then h.WalkSpeed = 16 end end
end
local function applyJump()
    if S.jump then setL("jump", function() return RunService.Heartbeat:Connect(function() local h = getHum(); if h then h.UseJumpPower = true; h.JumpPower = S.jumpVal end end) end)
    else setL("jump", nil); local h = getHum(); if h then h.JumpPower = 50 end end
end
local function applyFly()
    if S.fly then
        local hrp = getHRP(); if not hrp then return end
        local bv = Instance.new("BodyVelocity", hrp); bv.Name = "ANON_Fly"; bv.MaxForce = Vector3.new(9e9,9e9,9e9); bv.Velocity = Vector3.zero
        setL("fly", function() return RunService.RenderStepped:Connect(function()
            local dir = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
            bv.Velocity = dir.Magnitude > 0 and dir.Unit * S.flySpeed or Vector3.zero
        end) end)
    else setL("fly", nil); local hrp = getHRP(); if hrp then local o = hrp:FindFirstChild("ANON_Fly"); if o then o:Destroy() end end end
end
local function applyNoclip()
    if S.noclip then setL("noclip", function() return RunService.Stepped:Connect(function() local c = LP.Character; if c then for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end) end)
    else setL("noclip", nil) end
end
local function applyInfJump()
    if S.infJump then setL("infJump", function() return UIS.JumpRequest:Connect(function() local h = getHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end) end)
    else setL("infJump", nil) end
end
local function applySpin()
    if S.spin then setL("spin", function() return RunService.Heartbeat:Connect(function() local hrp = getHRP(); if hrp then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(S.spinSpeed), 0) end end) end)
    else setL("spin", nil) end
end
local function applyBhop()
    if S.bhop then setL("bhop", function() return RunService.Heartbeat:Connect(function() local h = getHum(); if h and h.FloorMaterial ~= Enum.Material.Air then h.Jump = true end end) end)
    else setL("bhop", nil) end
end
local function applyAntiAfk()
    if S.antiAfk then
        local vu = LP:FindFirstChildOfClass("VirtualUser") or Instance.new("VirtualUser", LP)
        setL("afk", function() return vu.Idled:Connect(function() vu:CaptureController(); vu:ClickButton2(Vector2.new()) end) end)
    else setL("afk", nil) end
end
local function applyAntiVoid()
    if S.antiVoid then setL("void", function() return RunService.Heartbeat:Connect(function() local hrp = getHRP(); if hrp and hrp.Position.Y < -50 then hrp.CFrame = CFrame.new(0,50,0) end end) end)
    else setL("void", nil) end
end
local function applyWaterWalk()
    if S.waterWalk then setL("water", function() return RunService.Heartbeat:Connect(function() local c = LP.Character; if c then for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CustomPhysicalProperties = PhysicalProperties.new(0.001,0.3,0.5,1,1) end end end end) end)
    else setL("water", nil) end
end
local function applyHover()
    if S.hover then
        local hrp = getHRP(); if not hrp then return end
        local bp = Instance.new("BodyPosition", hrp); bp.Name = "ANON_Hover"; bp.MaxForce = Vector3.new(9e9,9e9,9e9); bp.D = 500; bp.P = 3000
        setL("hover", function() return RunService.Heartbeat:Connect(function()
            local h = getHRP(); if h and h:FindFirstChild("ANON_Hover") then
                local ray = Ray.new(h.Position, Vector3.new(0,-1000,0)); local part = Workspace:FindPartOnRay(ray, LP.Character)
                if part then h.ANON_Hover.Position = part.Position + Vector3.new(0, S.hoverHeight, 0) end
            end
        end) end)
    else setL("hover", nil); local hrp = getHRP(); if hrp then local o = hrp:FindFirstChild("ANON_Hover"); if o then o:Destroy() end end end
end
local function applyClickTp()
    if S.clickTp then setL("clickTp", function() return UIS.InputBegan:Connect(function(i, gp)
        if gp or i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        local m = UIS:GetMouseLocation(); local ray = Camera:ViewportPointToRay(m.X, m.Y)
        local rp = RaycastParams.new(); rp.FilterType = Enum.RaycastFilterType.Exclude; rp.FilterDescendantsInstances = { getChar(), ScreenGui }
        local res = Workspace:Raycast(ray.Origin, ray.Direction * 1000, rp)
        if res and res.Instance then local hrp = getHRP(); if hrp then hrp.CFrame = CFrame.new(res.Position + Vector3.new(0,3,0)) end end
    end) end) else setL("clickTp", nil) end
end
local function applyFollow()
    if S.follow then setL("follow", function() return RunService.Heartbeat:Connect(function()
        local t = Players:FindFirstChild(S.follow)
        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = getHRP(); if hrp then
                local tar = t.Character.HumanoidRootPart.Position
                local des = tar + (hrp.Position - tar).Unit * S.followDist
                hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(des), 0.15)
            end
        end
    end) end) else setL("follow", nil) end
end
local function applyOrbit()
    if S.orbit then
        local t = 0
        setL("orbit", function() return RunService.Heartbeat:Connect(function(dt)
            t = t + dt * S.orbitSpeed
            local tar = Players:FindFirstChild(S.orbit)
            if tar and tar.Character and tar.Character:FindFirstChild("HumanoidRootPart") then
                local c = tar.Character.HumanoidRootPart.Position
                local pos = c + Vector3.new(math.cos(t)*S.orbitRad, 3, math.sin(t)*S.orbitRad)
                local hrp = getHRP(); if hrp then hrp.CFrame = CFrame.new(pos, c) end
            end
        end) end)
    else setL("orbit", nil) end
end
local function applyAntiFling()
    if S.antiFling then setL("antiFling", function() return RunService.Heartbeat:Connect(function()
        local hrp = getRoot(); if hrp then local v = hrp.AssemblyLinearVelocity; if v.Magnitude > 200 then hrp.AssemblyLinearVelocity = v.Unit * 50 end end
    end) end) else setL("antiFling", nil) end
end
local function applyAntiRagdoll()
    if S.antiRagdoll then setL("antiRagdoll", function() return RunService.Heartbeat:Connect(function()
        local h = getHum(); if h and h:GetState() == Enum.HumanoidStateType.Physics then h:ChangeState(Enum.HumanoidStateType.Running) end
    end) end) else setL("antiRagdoll", nil) end
end
local function applyAntiSlow()
    if S.antiSlow then setL("antiSlow", function() return RunService.Heartbeat:Connect(function()
        local h = getHum(); if h then for _, e in pairs(h:GetChildren()) do if e:IsA("StatusEffect") or e.Name == "Slow" then e:Destroy() end end end
    end) end) else setL("antiSlow", nil) end
end
local function applyGrav()
    Workspace.Gravity = S.customGrav and S.gravVal or 196.2
end
local function applyAutoClick()
    if S.autoClick then setL("autoClick", function() return RunService.RenderStepped:Connect(function() VirtualUser:CaptureController(); VirtualUser:ClickButton1(Vector2.new()) end) end)
    else setL("autoClick", nil) end
end
local function applyAutoTool()
    if S.autoTool then setL("autoTool", function() return RunService.Heartbeat:Connect(function() local c = LP.Character; if c then local t = c:FindFirstChildOfClass("Tool"); if t then pcall(function() t:Activate() end) end end end) end)
    else setL("autoTool", nil) end
end
local function applyAura()
    if S.aura then setL("aura", function() return RunService.Heartbeat:Connect(function()
        local c = getChar(); local hrp = getHRP(); if not (c and hrp) then return end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude <= S.auraRange then
                    local t = c:FindFirstChildOfClass("Tool"); if t then pcall(function() t:Activate() end) end
                end
            end
        end
    end) end) else setL("aura", nil) end
end
local function applyAimbot()
    if S.aimbot then setL("aimbot", function() return RunService.RenderStepped:Connect(function()
        local closest, closestD = nil, math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local t = p.Character:FindFirstChild(S.aimPart) or p.Character:FindFirstChild("HumanoidRootPart")
                if t then
                    local sp = Camera:WorldToViewportPoint(t.Position)
                    if sp.Z > 0 then
                        local m = UIS:GetMouseLocation()
                        local d = math.sqrt((sp.X - m.X)^2 + (sp.Y - m.Y)^2)
                        if d < S.aimFov and d < closestD then closest, closestD = t, d end
                    end
                end
            end
        end
        if closest then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, closest.Position), S.aimSmooth) end
    end) end) else setL("aimbot", nil) end
end
local function applyTrigger()
    if S.trigger then setL("trigger", function() return RunService.Heartbeat:Connect(function()
        local m = UIS:GetMouseLocation(); local ray = Camera:ViewportPointToRay(m.X, m.Y)
        local rp = RaycastParams.new(); rp.FilterType = Enum.RaycastFilterType.Exclude; rp.FilterDescendantsInstances = { getChar() }
        local res = Workspace:Raycast(ray.Origin, ray.Direction * 1000, rp)
        if res and res.Instance then
            local c = res.Instance:FindFirstAncestorOfClass("Model"); local plr = c and Players:GetPlayerFromCharacter(c)
            if plr and plr ~= LP then VirtualUser:CaptureController(); VirtualUser:ClickButton1(Vector2.new()); task.wait(S.trigDelay) end
        end
    end) end) else setL("trigger", nil) end
end
local function applySilent()
    if S.silent then setL("silent", function() return RunService.RenderStepped:Connect(function()
        local closest, closestD = nil, math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local t = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
                if t then
                    local sp = Camera:WorldToViewportPoint(t.Position)
                    if sp.Z > 0 then
                        local m = UIS:GetMouseLocation()
                        local d = math.sqrt((sp.X - m.X)^2 + (sp.Y - m.Y)^2)
                        if d < S.silentFov and d < closestD then closest, closestD = t, d end
                    end
                end
            end
        end
        if closest then Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position) end
    end) end) else setL("silent", nil) end
end
local function applyHitbox()
    if S.hitbox then setL("hitbox", function() return RunService.Heartbeat:Connect(function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Size = Vector3.new(S.hitboxSize*2, S.hitboxSize*2, S.hitboxSize*2) end
            end
        end
    end) end)
    else
        setL("hitbox", nil)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then local hrp = p.Character:FindFirstChild("HumanoidRootPart"); if hrp then hrp.Size = Vector3.new(2,2,1) end end
        end
    end
end
local function applyAutoShoot()
    if S.autoShoot then setL("autoShoot", function() return RunService.Heartbeat:Connect(function()
        local m = UIS:GetMouseLocation(); local ray = Camera:ViewportPointToRay(m.X, m.Y)
        local rp = RaycastParams.new(); rp.FilterType = Enum.RaycastFilterType.Exclude; rp.FilterDescendantsInstances = { getChar() }
        local res = Workspace:Raycast(ray.Origin, ray.Direction * 1000, rp)
        if res and res.Instance then
            local c = res.Instance:FindFirstAncestorOfClass("Model"); local plr = c and Players:GetPlayerFromCharacter(c)
            if plr and plr ~= LP then VirtualUser:CaptureController(); VirtualUser:ClickButton1(Vector2.new()); task.wait(S.shootDelay) end
        end
    end) end) else setL("autoShoot", nil) end
end
local function applyFarmHut()
    if S.farmHut then setL("farmHut", function() return RunService.Heartbeat:Connect(function()
        local hrp = getHRP(); if not hrp then return end
        for _, o in pairs(Workspace:GetDescendants()) do
            if (o:IsA("Model") or o:IsA("BasePart")) and matchAny(o, Rules.item) then
                local pos
                if o:IsA("BasePart") then pos = o.Position
                else local pp = o:FindFirstChildWhichIsA("BasePart"); if pp then pos = pp.Position end end
                if pos then
                    local d = (hrp.Position - pos).Magnitude
                    if d <= S.hutRange and d > 1 then hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(pos + Vector3.new(0,2,0)), 0.15) end
                end
            end
        end
    end) end) else setL("farmHut", nil) end
end
local function applyFarmPrompt()
    if S.farmPrompt or S.autoPrompt then setL("farmPrompt", function() return ProximityPromptService.PromptShown:Connect(function(p)
        if p.Enabled then task.wait(0.1); pcall(function() p:InputHoldBegin() end); task.wait(p.HoldDuration + 0.05); pcall(function() p:InputHoldEnd() end) end
    end) end) else setL("farmPrompt", nil) end
end
local function applyAutoReply()
    if S.autoReply then setL("autoReply", function() return LP.Chatted:Connect(function()
        pcall(function() if ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") then ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(S.replyMsg, "All") end end)
    end) end) else setL("autoReply", nil) end
end
local function applySpam()
    if S.spam and S.spamMsg ~= "" then setL("spam", function() return task.spawn(function()
        while S.spam and S.spamMsg ~= "" do
            pcall(function() if ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") then ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(S.spamMsg, "All") end end)
            task.wait(S.spamDelay)
        end
    end) end) else setL("spam", nil) end
end
local function applyCamFree()
    if S.camFree then setL("camFree", function() return RunService.RenderStepped:Connect(function()
        local hrp = getHRP(); if hrp then local dir = Camera.CFrame.LookVector; Camera.CFrame = CFrame.new(hrp.Position - dir * S.camDist) * Camera.CFrame.Rotation end
    end) end) else setL("camFree", nil) end
end
local function applyRapid()
    if S.rapidFire then setL("rapid", function() return RunService.Heartbeat:Connect(function()
        local c = LP.Character; if c then local t = c:FindFirstChildOfClass("Tool"); if t then pcall(function() t:Activate() end); task.wait(S.rapidDelay) end end
    end) end) else setL("rapid", nil) end
end
local function applyInfAmmo()
    if S.infAmmo then setL("infAmmo", function() return RunService.Heartbeat:Connect(function()
        local c = LP.Character; if c then for _, o in pairs(c:GetDescendants()) do
            if o:IsA("IntValue") and (o.Name:lower():find("ammo") or o.Name:lower():find("clip")) then o.Value = 9999 end
        end end
    end) end) else setL("infAmmo", nil) end
end
local function applyRespawn()
    if S.autoRespawn then setL("respawn", function() return LP.CharacterAdded:Connect(function() task.wait(1); noti("ANON HUB", "Đã hồi sinh", 1) end) end)
    else setL("respawn", nil) end
end
local function applyEquip()
    if S.autoEquip then setL("equip", function() return RunService.Heartbeat:Connect(function()
        local c = LP.Character; local bp = LP:FindFirstChildOfClass("Backpack")
        if c and bp and not c:FindFirstChildOfClass("Tool") then
            local t = bp:FindFirstChildOfClass("Tool"); if t then pcall(function() c.Humanoid:EquipTool(t) end) end
        end
    end) end) else setL("equip", nil) end
end
local function applyLogRemote()
    if S.logRemote and hookmetamethod and getnamecallmethod then
        local old
        old = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
                if self:IsA("RemoteEvent") or self:IsA("RemoteFunction") then print("[REMOTE]", os.date("%H:%M:%S"), self:GetFullName(), method) end
            end
            return old(self, ...)
        end)
        noti("ANON HUB", "Đã hook remote", 2)
    end
end
local function applyRainbow()
    if S.rainbow then setL("rainbow", function()
        local hue = 0
        return RunService.Heartbeat:Connect(function()
            hue = (hue + 0.005) % 1; local c = Color3.fromHSV(hue, 1, 1)
            local ch = LP.Character; if ch then for _, p in pairs(ch:GetDescendants()) do if p:IsA("BasePart") then p.Color = c end end end
        end)
    end) else setL("rainbow", nil) end
end
local function applySpinCam()
    if S.spinCam then setL("spinCam", function() return RunService.RenderStepped:Connect(function() Camera.CFrame = Camera.CFrame * CFrame.Angles(0, math.rad(S.spinCamSpeed), 0) end) end)
    else setL("spinCam", nil) end
end
local function applyScale()
    local ch = LP.Character; if ch then
        local h = ch:FindFirstChildOfClass("Humanoid")
        if h then
            for _, n in ipairs({"BodyDepthScale","BodyWidthScale","BodyHeightScale","BodyHeadScale"}) do
                local o = h:FindFirstChild(n) or Instance.new("NumberValue", h)
                o.Name = n
                if S.giant then o.Value = S.giantScale elseif S.tiny then o.Value = S.tinyScale else o.Value = 1 end
            end
        end
    end
end

-- ============================================================
-- CÁC TAB
-- ============================================================

-- 1. ESP
local tEsp = newTab("Mắt Thần", "👁️"); local c = tEsp.frame
newSection(c, "👁️ BẬT ESP")
newToggle(c, "ESP người chơi", false, function(v) S.espP = v; if v then startEsp() else stopEspIfNeeded() end end)
newToggle(c, "ESP quái", false, function(v) S.espM = v; if v then startEsp() else stopEspIfNeeded() end end)
newToggle(c, "ESP vật phẩm", false, function(v) S.espI = v; if v then startEsp() else stopEspIfNeeded() end end)
newSection(c, "🎨 NÂNG CAO")
newToggle(c, "Đường nối", false, function(v) S.espTrace = v; if v then startEsp() else stopEspIfNeeded() end end)
newToggle(c, "Hiện tên", false, function(v) S.espName = v; if v then startEsp() else stopEspIfNeeded() end end)
newToggle(c, "Hiện máu", false, function(v) S.espHp = v; if v then startEsp() else stopEspIfNeeded() end end)
newToggle(c, "Hiện khoảng cách", false, function(v) S.espDist = v; if v then startEsp() else stopEspIfNeeded() end end)
newToggle(c, "ESP xương", false, function(v) S.espBone = v; if v then startEsp() else stopEspIfNeeded() end end)
newSection(c, "🎓 HỌC TỰ ĐỘNG")
newBtn(c, "🎯 Học QUÁI", function() startLearn("mob") end)
newBtn(c, "🎯 Học VẬT PHẨM", function() startLearn("item") end)
newSection(c, "🎨 Màu sắc")
newColor(c, "Màu người chơi", S.colP, function(x) S.colP = x end)
newColor(c, "Màu quái", S.colM, function(x) S.colM = x end)
newColor(c, "Màu vật phẩm", S.colI, function(x) S.colI = x end)
newColor(c, "Màu đường nối", S.colTrace, function(x) S.colTrace = x end)
newColor(c, "Màu xương", S.colBone, function(x) S.colBone = x end)
newSection(c, "📋 QUẢN LÝ LUẬT")
local ruleLbl = Instance.new("TextLabel", c); ruleLbl.Size = UDim2.new(1,0,0,26); ruleLbl.BackgroundColor3 = Color3.fromRGB(22,22,28)
ruleLbl.TextColor3 = Color3.fromRGB(160,220,160); ruleLbl.Font = Enum.Font.Code; ruleLbl.TextSize = 9; ruleLbl.TextWrapped = true
ruleLbl.Parent = c; Instance.new("UICorner", ruleLbl).CornerRadius = UDim.new(0,4)
local function updRule() ruleLbl.Text = "Quái: "..#Rules.mob.." | Vật phẩm: "..#Rules.item end
updRule()
newBtn(c, "📋 Xem luật (F9)", function()
    print("QUÁI:"); for i,r in ipairs(Rules.mob) do print(i, HttpService:JSONEncode(r)) end
    print("VẬT PHẨM:"); for i,r in ipairs(Rules.item) do print(i, HttpService:JSONEncode(r)) end
end)
newBtn(c, "🗑️ Xóa quái cuối", function() if #Rules.mob > 0 then table.remove(Rules.mob); saveAll(); updRule() end end)
newBtn(c, "🗑️ Xóa vật phẩm cuối", function() if #Rules.item > 0 then table.remove(Rules.item); saveAll(); updRule() end end)
newBtn(c, "🧹 Xóa tất cả", function() Rules.mob = {}; Rules.item = {}; saveAll(); updRule() end)
newBtn(c, "🧹 Xóa highlight", function()
    for _,o in pairs(Workspace:GetDescendants()) do
        for _,n in ipairs({"ANON_P","ANON_M","ANON_I"}) do if o:FindFirstChild(n) then o[n]:Destroy() end end
    end
end)

-- 2. NHÂN VẬT
local tNv = newTab("Nhân Vật", "🏃"); local c = tNv.frame
newSection(c, "🏃 Di chuyển")
newToggle(c, "Chạy nhanh", false, function(v) S.speed = v; applySpeed() end)
newSlider(c, "Tốc độ chạy", 16, 500, S.speedVal, function(v) S.speedVal = v end)
newToggle(c, "Nhảy cao", false, function(v) S.jump = v; applyJump() end)
newSlider(c, "Lực nhảy", 50, 1000, S.jumpVal, function(v) S.jumpVal = v end)
newToggle(c, "Nhảy vô hạn", false, function(v) S.infJump = v; applyInfJump() end)
newToggle(c, "Nhảy liên tục", false, function(v) S.bhop = v; applyBhop() end)
newSection(c, "✈️ Bay")
newToggle(c, "Bay lượn", false, function(v) S.fly = v; applyFly() end)
newSlider(c, "Tốc độ bay", 10, 500, S.flySpeed, function(v) S.flySpeed = v end)
newSection(c, "🎯 Khác")
newToggle(c, "Xoay người", false, function(v) S.spin = v; applySpin() end)
newSlider(c, "Tốc độ xoay", 1, 50, S.spinSpeed, function(v) S.spinSpeed = v end)
newToggle(c, "Xuyên vật thể", false, function(v) S.noclip = v; applyNoclip() end)
newToggle(c, "Chống rơi map", false, function(v) S.antiVoid = v; applyAntiVoid() end)
newToggle(c, "Chống AFK", true, function(v) S.antiAfk = v; applyAntiAfk() end)
newBtn(c, "🔄 Hồi sinh", function() local ch = getChar(); if ch then ch:BreakJoints() end end)

-- 3. THẾ GIỚI
local tTg = newTab("Thế Giới", "🌍"); local c = tTg.frame
newSection(c, "🌍 Ánh sáng")
newToggle(c, "Sáng tối đa", false, function(v)
    if v then Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.GlobalShadows = false; Lighting.OutdoorAmbient = Color3.fromRGB(200,200,200)
    else Lighting.GlobalShadows = true; Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128) end
end)
newToggle(c, "Trời tối", false, function(v) Lighting.Brightness = v and 0.3 or 2; Lighting.ClockTime = v and 0 or 14 end)
newToggle(c, "Sương mù dày", false, function(v) Lighting.FogEnd = v and 100 or 100000 end)
newSection(c, "⏰ Thời gian")
newBtn(c, "☀️ Bình minh", function() Lighting.ClockTime = 6 end)
newBtn(c, "🌇 Hoàng hôn", function() Lighting.ClockTime = 18 end)
newBtn(c, "🌙 Nửa đêm", function() Lighting.ClockTime = 0 end)
newSection(c, "🔊 Âm thanh")
newBtn(c, "🔇 Tắt", function() pcall(function() SoundService.Volume = 0 end) end)
newBtn(c, "🔊 Bật", function() pcall(function() SoundService.Volume = 1 end) end)

-- 4. TIỆN ÍCH
local tTi = newTab("Tiện Ích", "🛠️"); local c = tTi.frame
newSection(c, "📍 Dịch chuyển")
local savedPos = nil
newBtn(c, "💾 Lưu vị trí", function() local hrp = getHRP(); if hrp then savedPos = hrp.CFrame; noti("ANON HUB", "Đã lưu") end end)
newBtn(c, "⏪ Quay lại", function() local hrp = getHRP(); if hrp and savedPos then hrp.CFrame = savedPos end end)
local nameIn = ""
newInput(c, "Tên người chơi...", function(v) nameIn = v end)
newBtn(c, "🚀 Tới người chơi", function()
    local t = Players:FindFirstChild(nameIn)
    if t and t.Character then local hrp = getHRP(); local thrp = t.Character:FindFirstChild("HumanoidRootPart")
        if hrp and thrp then hrp.CFrame = thrp.CFrame * CFrame.new(0,0,5) end
    else noti("ANON HUB", "Không tìm thấy") end
end)
newBtn(c, "👥 Kéo người chơi tới", function()
    local hrp = getHRP(); if not hrp then return end
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0,0,-3)
        end
    end
end)
newSection(c, "💬 Trò chuyện")
local chatIn = newInput(c, "Tin nhắn...", function(v) end)
newBtn(c, "📤 Gửi", function()
    local m = chatIn.Text
    if m and m ~= "" then pcall(function() if ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") then ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(m, "All") end end) end
end)
newToggle(c, "Tự động trả lời", false, function(v) S.autoReply = v; applyAutoReply() end)
newInput(c, "Nội dung trả lời", function(v) S.replyMsg = v end)
newToggle(c, "Spam chat", false, function(v) S.spam = v; applySpam() end)
newInput(c, "Nội dung spam", function(v) S.spamMsg = v; if S.spam then applySpam() end end)
newSlider(c, "Chu kỳ spam (giây)", 1, 10, 2, function(v) S.spamDelay = v; if S.spam then applySpam() end end)
newSection(c, "📋 Sao chép")
newBtn(c, "📋 Tên nhân vật", function() if setclipboard then setclipboard(LP.Name) end end)
newBtn(c, "📋 Job ID", function() if setclipboard then setclipboard(game.JobId) end end)
newBtn(c, "📋 Place ID", function() if setclipboard then setclipboard(tostring(game.PlaceId)) end end)

-- 5. CHIẾN ĐẤU
local tCd = newTab("Chiến Đấu", "⚔️"); local c = tCd.frame
newSection(c, "⚔️ TỰ ĐỘNG")
newToggle(c, "Tự động bấm", false, function(v) S.autoClick = v; applyAutoClick() end)
newToggle(c, "Tự động tool", false, function(v) S.autoTool = v; applyAutoTool() end)
newToggle(c, "Đánh gần", false, function(v) S.aura = v; applyAura() end)
newSlider(c, "Phạm vi đánh", 5, 50, S.auraRange, function(v) S.auraRange = v end)
newSection(c, "🎯 NGẮM TỰ ĐỘNG")
newToggle(c, "Ngắm tự động", false, function(v) S.aimbot = v; applyAimbot() end)
newSlider(c, "Độ mượt", 0.01, 1, S.aimSmooth, function(v) S.aimSmooth = v end)
newSlider(c, "Phạm vi ngắm", 10, 500, S.aimFov, function(v) S.aimFov = v end)
newBtn(c, "🎯 Nhắm đầu", function() S.aimPart = "Head"; noti("ANON HUB", "Nhắm: Đầu") end)
newBtn(c, "🎯 Nhắm thân", function() S.aimPart = "HumanoidRootPart"; noti("ANON HUB", "Nhắm: Thân") end)
newSection(c, "⚡ TỰ ĐỘNG BẮN")
newToggle(c, "Tự động bắn", false, function(v) S.autoShoot = v; applyAutoShoot() end)
newSlider(c, "Độ trễ", 0.01, 1, S.shootDelay, function(v) S.shootDelay = v end)

-- 6. NÔNG TRẠI
local tFarm = newTab("Nông Trại", "🌾"); local c = tFarm.frame
newSection(c, "🌾 TỰ ĐỘNG")
newToggle(c, "Tự động hút", false, function(v) S.farmHut = v; applyFarmHut() end)
newSlider(c, "Phạm vi hút", 10, 200, S.hutRange, function(v) S.hutRange = v end)
newToggle(c, "Tự động gợi ý", false, function(v) S.farmPrompt = v; applyFarmPrompt() end)

-- 7. NÂNG CAO
local tNc = newTab("Nâng Cao", "⚙️"); local c = tNc.frame
newSection(c, "⚙️ HITBOX")
newToggle(c, "Mở rộng hitbox", false, function(v) S.hitbox = v; applyHitbox() end)
newSlider(c, "Kích thước", 1, 10, S.hitboxSize, function(v) S.hitboxSize = v end)
newSection(c, "🎯 SILENT AIM")
newToggle(c, "Silent aim", false, function(v) S.silent = v; applySilent() end)
newSlider(c, "Phạm vi", 50, 500, S.silentFov, function(v) S.silentFov = v end)
newSection(c, "📡 MẠNG")
newToggle(c, "Ghi log remote (F9)", false, function(v) S.logRemote = v; applyLogRemote() end)
newSection(c, "🎥 CAMERA")
newToggle(c, "Camera tự do", false, function(v) S.camFree = v; applyCamFree() end)
newSlider(c, "Khoảng cách", 5, 100, S.camDist, function(v) S.camDist = v end)
newSection(c, "🔧 TOOL")
newToggle(c, "Bắn nhanh", false, function(v) S.rapidFire = v; applyRapid() end)
newSlider(c, "Độ trễ nhanh", 0.01, 0.5, S.rapidDelay, function(v) S.rapidDelay = v end)
newToggle(c, "Đạn vô hạn", false, function(v) S.infAmmo = v; applyInfAmmo() end)
newSection(c, "⚙️ TỰ ĐỘNG KHÁC")
newToggle(c, "Tự động hồi sinh", false, function(v) S.autoRespawn = v; applyRespawn() end)
newToggle(c, "Tự động trang bị", false, function(v) S.autoEquip = v; applyEquip() end)

-- 8. MÁY CHỦ
local tSv = newTab("Máy Chủ", "🌐"); local c = tSv.frame
newSection(c, "🌐")
newBtn(c, "🔄 Vào lại", function() TeleportService:Teleport(game.PlaceId, LP) end)
newBtn(c, "🎲 Chuyển server", function()
    local d = {}
    pcall(function() d = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100")) end)
    if d and d.data then for _,s in pairs(d.data) do if s.id ~= game.JobId and s.playing < s.maxPlayers then TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LP); return end end end
    noti("ANON HUB", "Không tìm thấy server")
end)
newBtn(c, "📋 Liệt kê server", function()
    local d = {}
    pcall(function() d = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100")) end)
    if d and d.data then for i,s in ipairs(d.data) do print(i, s.id, s.playing.."/"..s.maxPlayers, s.ping.."ms") end end
end)
newToggle(c, "Tự động vào lại", false, function(v) S.rejoin = v end)
newSection(c, "📊 Trạng thái")
local statLbl = Instance.new("TextLabel", c); statLbl.Size = UDim2.new(1,0,0,48); statLbl.BackgroundColor3 = Color3.fromRGB(22,22,28)
statLbl.TextColor3 = Color3.fromRGB(160,220,160); statLbl.Font = Enum.Font.Code; statLbl.TextSize = 9; statLbl.TextWrapped = true
statLbl.Parent = c; Instance.new("UICorner", statLbl).CornerRadius = UDim.new(0,4)
task.spawn(function()
    while statLbl.Parent do
        local ping = "?"
        pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()).."ms" end)
        local fps = 0
        pcall(function() fps = math.floor(1/RunService.RenderStepped:Wait()) end)
        statLbl.Text = string.format("Người: %d | Ping: %s | FPS: %d\nGame: %s\nJob: %s", #Players:GetPlayers(), ping, fps, tostring(game.PlaceId), string.sub(game.JobId,1,12).."...")
        task.wait(1)
    end
end)

-- 9. GIAO DIỆN
local tGui = newTab("Giao Diện", "🎨"); local c = tGui.frame
newSection(c, "🎨")
newBtn(c, "🎯 Ẩn/Hiện", function() Main.Visible = not Main.Visible end)
newBtn(c, "📌 Trái trên", function() Main.Position = UDim2.new(0,20,0,20) end)
newBtn(c, "📌 Phải trên", function() Main.Position = UDim2.new(1,-300,0,20) end)
newBtn(c, "📌 Giữa", function() Main.Position = UDim2.new(0.5,-140,0.5,-230) end)
newBtn(c, "🔍 Đổi kích thước", function()
    local w = Main.Size.X.Offset
    local n = (w == 280) and 320 or (w == 320) and 360 or 280
    TweenService:Create(Main, TweenInfo.new(0.2), {Size = UDim2.new(0, n, 0, Main.Size.Y.Offset)}):Play()
end)
newBtn(c, "❌ Đóng menu", function() ScreenGui:Destroy() end)

-- 10. CHẨN ĐOÁN
local tDbg = newTab("Chẩn Đoán", "🔧"); local c = tDbg.frame
newSection(c, "🔧")
newBtn(c, "🖱️ Nhấp in info", function()
    local conn
    conn = UIS.InputBegan:Connect(function(i, gp)
        if gp or i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        local m = UIS:GetMouseLocation(); local ray = Camera:ViewportPointToRay(m.X, m.Y)
        local rp = RaycastParams.new(); rp.FilterType = Enum.RaycastFilterType.Exclude; rp.FilterDescendantsInstances = { getChar(), ScreenGui }
        local res = Workspace:Raycast(ray.Origin, ray.Direction * 1000, rp)
        if res and res.Instance then
            local o = res.Instance; local model = o:FindFirstAncestorOfClass("Model") or o
            print("=== DEBUG ==="); print("Part:", o:GetFullName(), "|", o.ClassName)
            print("Model:", model:GetFullName(), "|", model.ClassName)
            print("Humanoid:", model:FindFirstChildOfClass("Humanoid") ~= nil)
            print("Size:", o.Size, "| Pos:", o.Position)
            print("Attrs:"); for k,v in pairs(o:GetAttributes()) do print("  ", k, "=", tostring(v)) end
            print("Tags:", table.concat(CollectionService:GetTags(o), ", "))
            print("Parent chain:"); local p = o
            for _ = 1, 8 do if not p or p == game then break end; print("  ", p.Name, "("..p.ClassName..")"); p = p.Parent end
            print("=== END ===")
        end
    end)
    task.delay(30, function() if conn then conn:Disconnect() end end)
end)
newBtn(c, "📊 Liệt kê Model", function()
    local n = 0
    for _,o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") then n = n + 1; print(o.Name, "Hum="..tostring(o:FindFirstChildOfClass("Humanoid") ~= nil), "|", o:GetFullName()) end end
    print("Tổng:", n)
end)
newBtn(c, "🔍 Liệt kê Tool", function()
    local n = 0
    for _,o in pairs(game:GetDescendants()) do if o:IsA("Tool") then n = n + 1; print(o:GetFullName()) end end
    print("Tổng:", n)
end)

-- 11. GIẢI TRÍ
local tFun = newTab("Giải Trí", "🎉"); local c = tFun.frame
newSection(c, "🌈 Hiệu ứng")
newToggle(c, "Cầu vồng", false, function(v) S.rainbow = v; applyRainbow() end)
newToggle(c, "Xoay camera", false, function(v) S.spinCam = v; applySpinCam() end)
newSlider(c, "Tốc độ xoay cam", 1, 30, S.spinCamSpeed, function(v) S.spinCamSpeed = v end)
newSection(c, "📏 Kích thước")
newToggle(c, "Không đầu", false, function(v)
    local ch = LP.Character; if ch and v then local h = ch:FindFirstChild("Head"); if h then h.Transparency = 1; local f = h:FindFirstChild("face"); if f then f:Destroy() end end end
end)
newToggle(c, "Khổng lồ (x3)", false, function(v) S.giant = v; S.tiny = false; applyScale() end)
newSlider(c, "Tỷ lệ lớn", 1.5, 10, S.giantScale, function(v) S.giantScale = v; if S.giant then applyScale() end end)
newToggle(c, "Tí hon (x0.3)", false, function(v) S.tiny = v; S.giant = false; applyScale() end)
newSlider(c, "Tỷ lệ nhỏ", 0.1, 1, S.tinyScale, function(v) S.tinyScale = v; if S.tiny then applyScale() end end)
newSection(c, "🔊")
newBtn(c, "🎵 Bật nhạc nền", function()
    local s = Instance.new("Sound", SoundService); s.Name = "ANON_BGM"; s.SoundId = "rbxassetid://1837879082"; s.Looped = true; s.Volume = 0.3; s:Play()
end)
newBtn(c, "🔊 Âm thanh test", function()
    local s = Instance.new("Sound", Workspace); s.SoundId = "rbxassetid://131961136"; s.Volume = 5; s:Play(); task.delay(3, function() s:Destroy() end)
end)
newBtn(c, "🎨 Đổi màu ngẫu nhiên", function()
    local ch = LP.Character; if ch then for _,p in pairs(ch:GetDescendants()) do if p:IsA("BasePart") then p.Color = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255)) end end end
end)

-- 12. DI CHUYỂN
local tMove = newTab("Di Chuyển", "🏊"); local c = tMove.frame
newSection(c, "🌊 Nước / Dung nham")
newToggle(c, "Đi trên nước", false, function(v) S.waterWalk = v; applyWaterWalk() end)
newSection(c, "🪁 Lơ lửng")
newToggle(c, "Lơ lửng", false, function(v) S.hover = v; applyHover() end)
newSlider(c, "Độ cao lơ lửng", 1, 50, S.hoverHeight, function(v) S.hoverHeight = v end)
newSection(c, "📍 Teleport")
newToggle(c, "Nhấp để teleport", false, function(v) S.clickTp = v; applyClickTp() end)
newSection(c, "👥 Follow / Orbit")
newInput(c, "Tên follow...", function(v) S.follow = v ~= "" and v or nil; applyFollow() end)
newSlider(c, "Khoảng cách follow", 3, 50, S.followDist, function(v) S.followDist = v end)
newInput(c, "Tên orbit...", function(v) S.orbit = v ~= "" and v or nil; applyOrbit() end)
newSlider(c, "Bán kính orbit", 5, 100, S.orbitRad, function(v) S.orbitRad = v end)
newSlider(c, "Tốc độ orbit", 0.5, 20, S.orbitSpeed, function(v) S.orbitSpeed = v end)

-- 13. CHỐNG
local tAnti = newTab("Chống", "🛡️"); local c = tAnti.frame
newSection(c, "🛡️ Hiệu ứng xấu")
newToggle(c, "Chống bị đẩy", false, function(v) S.antiFling = v; applyAntiFling() end)
newToggle(c, "Chống ragdoll", false, function(v) S.antiRagdoll = v; applyAntiRagdoll() end)
newToggle(c, "Chống làm chậm", false, function(v) S.antiSlow = v; applyAntiSlow() end)
newSection(c, "🌍 Trọng lực")
newToggle(c, "Chỉnh trọng lực", false, function(v) S.customGrav = v; applyGrav() end)
newSlider(c, "Giá trị", 0, 500, S.gravVal, function(v) S.gravVal = v; if S.customGrav then applyGrav() end end)
newSection(c, "⚠️ Cảnh báo")
local warn = Instance.new("TextLabel", c); warn.Size = UDim2.new(1,0,0,50); warn.BackgroundColor3 = Color3.fromRGB(30,20,20)
warn.TextColor3 = Color3.fromRGB(255,180,180); warn.Font = Enum.Font.Gotham; warn.TextSize = 9; warn.TextWrapped = true
warn.Text = "Chống đá / ban thật sự KHÔNG THỂ làm phía client. Cần bypass thật."
warn.Parent = c; Instance.new("UICorner", warn).CornerRadius = UDim.new(0,4)

-- 14. CÔNG CỤ
local tTool = newTab("Công Cụ", "🧰"); local c = tTool.frame
newSection(c, "🧰 THÔNG TIN")
newBtn(c, "📊 Info Game (F9)", function()
    print("=== GAME ==="); pcall(function() print("Tên:", MarketplaceService:GetProductInfo(game.PlaceId).Name) end)
    print("PlaceId:", game.PlaceId, "| JobId:", game.JobId); print("Số người:", #Players:GetPlayers()); print("Trọng lực:", Workspace.Gravity)
end)
newBtn(c, "👥 Danh sách người chơi", function()
    for i,p in ipairs(Players:GetPlayers()) do
        local c = p.Character; local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local pos = hrp and string.format("X=%.0f Y=%.0f Z=%.0f", hrp.Position.X, hrp.Position.Y, hrp.Position.Z) or "?"
        local h = c and c:FindFirstChildOfClass("Humanoid"); local hp = h and (math.floor(h.Health).."/"..math.floor(h.MaxHealth)) or "?"
        print(i, p.Name, "| HP:", hp, "|", pos)
    end
end)
newBtn(c, "📦 Túi đồ", function()
    print("=== TÚI ĐỒ ===")
    local bp = LP:FindFirstChildOfClass("Backpack"); if bp then for _,t in pairs(bp:GetChildren()) do if t:IsA("Tool") then print(" -", t.Name) end end end
    local ch = LP.Character; if ch then for _,t in pairs(ch:GetChildren()) do if t:IsA("Tool") then print(" - (cầm)", t.Name) end end end
end)
newSection(c, "📋 SAO CHÉP")
newBtn(c, "📋 Tên người gần nhất", function()
    local hrp = getHRP(); if not hrp then return end
    local g, dG = nil, math.huge
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if d < dG then g, dG = p, d end
        end
    end
    if g then if setclipboard then setclipboard(g.Name) end; noti("ANON HUB", "Copy: "..g.Name, 3) end
end)
newBtn(c, "📋 Toạ độ", function()
    local hrp = getHRP(); if not hrp then return end
    local s = string.format("X=%.0f Y=%.0f Z=%.0f", hrp.Position.X, hrp.Position.Y, hrp.Position.Z)
    if setclipboard then setclipboard(s) end; noti("ANON HUB", s, 3)
end)
newSection(c, "✂️ CẮT / DÁN")
local cutPos = nil
newBtn(c, "✂️ Cắt vị trí", function() local hrp = getHRP(); if hrp then cutPos = {pos = hrp.Position, look = hrp.CFrame.LookVector}; noti("ANON HUB", "Đã cắt") end end)
newBtn(c, "📌 Dán vị trí", function()
    if not cutPos then noti("ANON HUB", "Chưa cắt"); return end
    local hrp = getHRP(); if hrp then hrp.CFrame = CFrame.lookAt(cutPos.pos, cutPos.pos + cutPos.look) end
end)

-- 15. PHÂN TÍCH
local tAnalyze = newTab("Phân Tích", "🔬"); local c = tAnalyze.frame
newSection(c, "🔬 PHÂN TÍCH")
newBtn(c, "📁 Folder Workspace", function()
    for _,f in pairs(Workspace:GetChildren()) do print(" ", f.ClassName, "|", f.Name, "| Số con:", #f:GetChildren()) end
end)
newBtn(c, "📡 RemoteEvent / Function", function()
    local n = 0
    for _,o in pairs(game:GetDescendants()) do if o:IsA("RemoteEvent") or o:IsA("RemoteFunction") then n = n + 1; print(" ", o.ClassName, "|", o:GetFullName()) end end
    print("Tổng:", n)
end)
newBtn(c, "🎒 Mọi Tool", function()
    local n = 0
    for _,o in pairs(game:GetDescendants()) do if o:IsA("Tool") then n = n + 1; print(o:GetFullName()) end end
    print("Tổng:", n)
end)
newBtn(c, "🧍 Model có Humanoid", function()
    local n = 0
    for _,o in pairs(Workspace:GetDescendants()) do if o:IsA("Model") and o:FindFirstChildOfClass("Humanoid") then n = n + 1; print(o.Name, "|", o:GetFullName()) end end
    print("Tổng:", n)
end)
newBtn(c, "🎨 Model không Humanoid", function()
    local n = 0
    for _,o in pairs(Workspace:GetDescendants()) do
        if o:IsA("Model") and not o:FindFirstChildOfClass("Humanoid") then
            local pp = o:FindFirstChildWhichIsA("BasePart")
            if pp and pp.Size.Magnitude < 30 then n = n + 1; print(o.Name, "|", o:GetFullName()) end
        end
    end
    print("Tổng:", n)
end)

-- 16. TIỆN ÍCH 2
local tUtil2 = newTab("Tiện Ích 2", "🎯"); local c = tUtil2.frame
newSection(c, "🎯 ĐÁNH DẤU")
newBtn(c, "🔴 Đánh dấu người chơi", function()
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hl = p.Character:FindFirstChild("ANON_Mark") or Instance.new("Highlight", p.Character)
            hl.Name = "ANON_Mark"; hl.FillColor = Color3.fromRGB(255,0,0); hl.FillTransparency = 0.5
        end
    end
    noti("ANON HUB", "Đã đánh dấu")
end)
newBtn(c, "🧹 Xoá đánh dấu", function()
    for _,o in pairs(Workspace:GetDescendants()) do if o:FindFirstChild("ANON_Mark") then o.ANON_Mark:Destroy() end end
end)
newSection(c, "📍 TELEPORT")
newBtn(c, "📍 Bay lên 100m", function() local hrp = getHRP(); if hrp then hrp.CFrame = hrp.CFrame + Vector3.new(0,100,0) end end)
newBtn(c, "📍 Bay xuống đất", function()
    local hrp = getHRP(); if hrp then
        local ray = Ray.new(hrp.Position, Vector3.new(0,-1000,0)); local part, pos = Workspace:FindPartOnRay(ray, LP.Character)
        if part then hrp.CFrame = CFrame.new(pos + Vector3.new(0,3,0)) end
    end
end)
newBtn(c, "📍 Bay tới tâm", function() local hrp = getHRP(); if hrp then hrp.CFrame = CFrame.new(0,50,0) end end)
newSection(c, "🎮 TƯƠNG TÁC")
newBtn(c, "🖱️ Kích hoạt gợi ý gần", function()
    local hrp = getHRP(); if not hrp then return end
    local n = 0
    for _,o in pairs(Workspace:GetDescendants()) do
        if o:IsA("ProximityPrompt") then
            local par = o.Parent
            if par and par:IsA("BasePart") and (par.Position - hrp.Position).Magnitude < 30 and o.Enabled then
                pcall(function() o:InputHoldBegin(); task.wait(o.HoldDuration + 0.1); o:InputHoldEnd() end); n = n + 1
            end
        end
    end
    noti("ANON HUB", "Đã kích hoạt "..n.." gợi ý", 3)
end)
newSection(c, "🔧 ĐỔI THUỘC TÍNH")
local attrIn = ""
newInput(c, "Tên thuộc tính (VD: WalkSpeed)", function(v) attrIn = v end)
newBtn(c, "🔧 Đổi thành 999", function()
    if attrIn == "" then return end
    local h = getHum(); if h then pcall(function() h[attrIn] = 999; noti("ANON HUB", "Đã đổi "..attrIn, 2) end) end
end)

-- ============================================================
-- KHỞI ĐỘNG
-- ============================================================
tEsp.btn.MouseButton1Click:Fire()
if S.antiAfk then applyAntiAfk() end
if S.speed then applySpeed() end
if S.jump then applyJump() end
noti("ANON HUB TỐI GIẢN", "Đã nạp — 16 tab", 4)
print("[ANON HUB TỐI GIẢN] Đã nạp.")
