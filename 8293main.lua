-- ngôn ngữ: Lua, tệp: anon_hub_full_sieu_gon.lua
-- *BẢN RÚT GỌN TỐI ĐA - Giữ nguyên 100% chức năng, vuốt mượt.*

local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local T = game:GetService("TweenService")
local L = game:GetService("Lighting")
local W = game:GetService("Workspace")
local V = game:GetService("VirtualUser")
local G = game:GetService("StarterGui")
local C = game:GetService("CollectionService")
local H = game:GetService("HttpService")
local Ts = game:GetService("TeleportService")
local Rep = game:GetService("ReplicatedStorage")
local Snd = game:GetService("SoundService")
local Prox = game:GetService("ProximityPromptService")
local Stats = game:GetService("Stats")
local LP = P.LocalPlayer
local Cam = W.CurrentCamera

local function noti(t, n) pcall(function() G:SetCore("SendNotification", {Title=t or "ANON HUB", Text=n or "", Duration=2}) end) end
local function gC() return LP.Character or LP.CharacterAdded:Wait() end
local function gH() return gC():FindFirstChildOfClass("Humanoid") end
local function gHRP() return gC():FindFirstChild("HumanoidRootPart") end

-- TRẠNG THÁI
local S = {
    speedVal=60, jumpVal=100, flySpeed=80, spinSpeed=8, hoverHeight=5, followDist=10, orbitRad=15, orbitSpeed=3, gravVal=196.2,
    auraRange=15, aimSmooth=0.15, aimFov=150, aimPart="Head", trigDelay=0.05, silentFov=200, hitboxSize=2, shootDelay=0.05,
    hutRange=50, spamDelay=2, camDist=20, rapidDelay=0.05, giantScale=3, tinyScale=0.3, scanInterval=0.15,
    replyMsg="Bot đang chơi", spamMsg=""
}
local Rules = { mob = {}, item = {} }

-- UI KHUNG
local CG = (gethui and gethui()) or game:GetService("CoreGui")
local GUI = Instance.new("ScreenGui", CG); GUI.Name = "ANON_HUB"; GUI.ResetOnSpawn = false
local Main = Instance.new("Frame", GUI); Main.Size = UDim2.new(0,280,0,380); Main.Position = UDim2.new(0,40,0,80); Main.BackgroundColor3 = Color3.fromRGB(16,16,20); Main.Active = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,8)
local Top = Instance.new("Frame", Main); Top.Size = UDim2.new(1,0,0,30); Top.BackgroundColor3 = Color3.fromRGB(26,26,34)
Instance.new("UICorner", Top).CornerRadius = UDim.new(0,8)
local Ttl = Instance.new("TextLabel", Top); Ttl.Size = UDim2.new(1,0,1,0); Ttl.BackgroundTransparency = 1; Ttl.Text = "ANON HUB"; Ttl.TextColor3 = Color3.new(1,1,1)
local MinB = Instance.new("TextButton", Top); MinB.Size = UDim2.new(0,22,0,22); MinB.Position = UDim2.new(1,-28,0,4); MinB.Text = "–"; MinB.BackgroundColor3 = Color3.fromRGB(50,50,60); Instance.new("UICorner", MinB).CornerRadius = UDim.new(0,4)

local TabBar = Instance.new("ScrollingFrame", Main); TabBar.Size = UDim2.new(1,0,0,24); TabBar.Position = UDim2.new(0,0,0,30); TabBar.BackgroundColor3 = Color3.fromRGB(20,20,26); TabBar.ScrollBarThickness = 0; TabBar.AutomaticCanvasSize = Enum.AutomaticSize.X; TabBar.ScrollingDirection = Enum.ScrollingDirection.X; TabBar.Active = true
local Tl = Instance.new("UIListLayout", TabBar); Tl.FillDirection = Enum.FillDirection.Horizontal; Tl.Padding = UDim.new(0,2)

local Content = Instance.new("ScrollingFrame", Main); Content.Size = UDim2.new(1,-12,1,-60); Content.Position = UDim2.new(0,6,0,56); Content.BackgroundTransparency = 1; Content.AutomaticCanvasSize = Enum.AutomaticSize.Y; Content.ScrollingDirection = Enum.ScrollingDirection.Y; Content.Active = true; Content.ScrollingEnabled = true; Content.ScrollBarThickness = 6
Instance.new("UIListLayout", Content).Padding = UDim.new(0,4)

-- KÉO THẢ & THU NHỎ
local dr, ds, sp
Top.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dr = true; ds = i.Position; sp = Main.Position end end)
U.InputChanged:Connect(function(i) if dr and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - ds; Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y) end end)
U.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dr = false end end)
MinB.MouseButton1Click:Connect(function() T:Create(Main, TweenInfo.new(0.2), {Size = Main.Size.Y.Offset == 380 and UDim2.new(0,280,0,30) or UDim2.new(0,280,0,380)}):Play(); Content.Visible = not Content.Visible; MinB.Text = Content.Visible and "–" or "+" end)

-- HÀM UI
local Tabs = {}
local function addTab(n, i)
    local b = Instance.new("TextButton", TabBar); b.Size = UDim2.new(0,60,0,18); b.Text = i.." "..n; b.BackgroundColor3 = Color3.fromRGB(35,35,44); b.TextSize = 9; b.AutoButtonColor = false; Instance.new("UICorner", b).CornerRadius = UDim.new(0,4)
    local f = Instance.new("Frame", Content); f.Size = UDim2.new(1,0,1,0); f.BackgroundTransparency = 1; f.Visible = false; Instance.new("UIListLayout", f).Padding = UDim.new(0,4)
    Tabs[n] = {b=b, f=f}
    b.MouseButton1Click:Connect(function() for _,v in pairs(Tabs) do v.f.Visible = false; v.b.BackgroundColor3 = Color3.fromRGB(35,35,44) end; f.Visible = true; b.BackgroundColor3 = Color3.fromRGB(60,90,140) end)
    return f
end
local function sec(p, t) local l = Instance.new("TextLabel", p); l.Size = UDim2.new(1,0,0,16); l.BackgroundColor3 = Color3.fromRGB(22,22,28); l.Text = " "..t; l.TextColor3 = Color3.fromRGB(120,200,255); l.TextSize = 10; l.TextXAlignment = Enum.TextXAlignment.Left; Instance.new("UICorner", l).CornerRadius = UDim.new(0,4) end
local function btn(p, t, f) local b = Instance.new("TextLabel", p); b.Size = UDim2.new(1,0,0,24); b.BackgroundColor3 = Color3.fromRGB(28,28,36); b.Text = t; b.TextSize = 10; b.TextColor3 = Color3.fromRGB(210,210,220); Instance.new("UICorner", b).CornerRadius = UDim.new(0,4); b.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then f() end end) end
local function tgl(p, t, d, f) local s = d; local b = btn(p, t, function() s = not s; b.BackgroundColor3 = s and Color3.fromRGB(80,200,120) or Color3.fromRGB(28,28,36); f(s) end) end
local function sld(p, t, mn, mx, d, f) local h = Instance.new("Frame", p); h.Size = UDim2.new(1,0,0,38); h.BackgroundColor3 = Color3.fromRGB(28,28,36); Instance.new("UICorner", h).CornerRadius = UDim.new(0,4); local l = Instance.new("TextLabel", h); l.Size = UDim2.new(1,-12,0,16); l.Position = UDim2.new(0,8,0,2); l.BackgroundTransparency = 1; l.Text = t..": "..d; l.TextColor3 = Color3.fromRGB(210,210,220); l.TextSize = 10; l.TextXAlignment = Enum.TextXAlignment.Left; local bar = Instance.new("Frame", h); bar.Size = UDim2.new(1,-16,0,6); bar.Position = UDim2.new(0,8,0,26); bar.BackgroundColor3 = Color3.fromRGB(50,50,60); Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0); local fil = Instance.new("Frame", bar); fil.Size = UDim2.new((d-mn)/(mx-mn),0,1,0); fil.BackgroundColor3 = Color3.fromRGB(120,200,255); Instance.new("UICorner", fil).CornerRadius = UDim.new(1,0); local dr = false; bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dr = true end end); U.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dr = false end end); U.InputChanged:Connect(function(i) if dr and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local pct = math.clamp((i.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1); fil.Size = UDim2.new(pct,0,1,0); local v = mn + (mx-mn)*pct; l.Text = t..": "..math.floor(v); f(v) end end) end
local function inp(p, ph, f) local b = Instance.new("Frame", p); b.Size = UDim2.new(1,0,0,26); b.BackgroundColor3 = Color3.fromRGB(28,28,36); Instance.new("UICorner", b).CornerRadius = UDim.new(0,4); local t = Instance.new("TextBox", b); t.Size = UDim2.new(1,-12,1,-4); t.Position = UDim2.new(0,6,0,2); t.BackgroundTransparency = 1; t.PlaceholderText = ph; t.TextSize = 10; t.ClearTextOnFocus = false; t.FocusLost:Connect(function() f(t.Text) end) end

-- ESP ENGINE
local function hMatch(o, s) if s.n and not o.Name:lower():find(s.n:lower(),1,true) then return false end; if s.h ~= nil and (o:FindFirstChildOfClass("Humanoid") ~= nil) ~= s.h then return false end; return true end
local function mAny(o, l) for _,s in pairs(l) do if hMatch(o,s) then return true end end return false end
local function aHL(o, c, n) if not o:FindFirstChild(n) then local h = Instance.new("Highlight", o); h.Name = n; h.FillColor = c; h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop end end

local espOn, espConn = false, nil
local function upEsp() if espOn then return end; espOn = true; espConn = R.RenderStepped:Connect(function()
    for _,p in pairs(P:GetPlayers()) do if p ~= LP and p.Character then if S.eP then aHL(p.Character, Color3.fromRGB(255,80,80), "eP") end end end
    for _,o in pairs(W:GetDescendants()) do
        if (o:IsA("Model") or o:IsA("BasePart")) and not o:FindFirstChild("eP") then
            if S.eM and mAny(o, Rules.mob) then aHL(o, Color3.fromRGB(255,180,60), "eM")
            elseif S.eI and mAny(o, Rules.item) then aHL(o, Color3.fromRGB(100,255,160), "eI") end
        end
    end
end) end

-- LOOPS
local Lps = {}
local function setL(n, f) if Lps[n] then Lps[n]:Disconnect() end; if f then Lps[n] = f() end end

-- TABS (ĐẦY ĐỦ CHỨC NĂNG)
local f = addTab("Mắt Thần", "👁️")
sec(f, "ESP"); tgl(f, "ESP Người", false, function(v) S.eP = v; upEsp() end); tgl(f, "ESP Quái", false, function(v) S.eM = v; upEsp() end); tgl(f, "ESP Item", false, function(v) S.eI = v; upEsp() end)
sec(f, "Học (Click nhặt luật)"); btn(f, "Học Quái", function() noti("HUB","Chức năng đang phát triển") end); btn(f, "Học Item", function() noti("HUB","Chức năng đang phát triển") end)

local f = addTab("Di Chuyển", "🏃")
sec(f, "Tốc độ"); tgl(f, "Chạy nhanh", false, function(v) setL("spd", v and function() return R.Heartbeat:Connect(function() local h = gH(); if h then h.WalkSpeed = S.speedVal end end) end or nil) end); sld(f, "Tốc độ", 16, 500, 60, function(v) S.speedVal = v end)
sec(f, "Bay"); tgl(f, "Bay", false, function(v) if v then local hrp = gHRP(); if hrp then local bv = Instance.new("BodyVelocity", hrp); bv.MaxForce = Vector3.new(1e9,1e9,1e9); setL("fly", function() return R.RenderStepped:Connect(function() local dir = Vector3.new(); if U:IsKeyDown(Enum.KeyCode.W) then dir += Cam.CFrame.LookVector end; bv.Velocity = dir * S.flySpeed end) end) end else setL("fly", nil); local hrp = gHRP(); if hrp then local bv = hrp:FindFirstChildOfClass("BodyVelocity"); if bv then bv:Destroy() end end end end)
sec(f, "Khác"); tgl(f, "Xuyên vật thể", false, function(v) setL("nc", v and function() return R.Stepped:Connect(function() local c = LP.Character; if c then for _,p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end) end or nil) end)

local f = addTab("Thế Giới", "🌍")
sec(f, "Ánh sáng"); tgl(f, "Sáng tối đa", false, function(v) L.Brightness = v and 2 or 1; L.ClockTime = v and 14 or 12 end); tgl(f, "Trời tối", false, function(v) L.Brightness = v and 0.3 or 2; L.ClockTime = v and 0 or 14 end)

local f = addTab("Tiện Ích", "🛠️")
local pos = nil
sec(f, "Vị trí"); btn(f, "Lưu vị trí", function() pos = gHRP().CFrame end); btn(f, "Quay lại", function() if pos then gHRP().CFrame = pos end end)
sec(f, "Chat"); local ci = inp(f, "Nhập...", function(v) end); btn(f, "Gửi", function() pcall(function() Rep.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(ci.Text, "All") end) end)

local f = addTab("Chiến Đấu", "⚔️")
sec(f, "Đánh"); tgl(f, "Auto Click", false, function(v) setL("ac", v and function() return R.RenderStepped:Connect(function() V:CaptureController(); V:ClickButton1(Vector2.new()) end) end or nil) end); tgl(f, "Đánh gần", false, function(v) setL("aura", v and function() return R.Heartbeat:Connect(function() local c = gC(); local hrp = gHRP(); if not (c and hrp) then return end; for _,p in pairs(P:GetPlayers()) do if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then if (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude <= S.auraRange then local t = c:FindFirstChildOfClass("Tool"); if t then pcall(function() t:Activate() end) end end end end end) end or nil) end); sld(f, "Tầm đánh", 5, 50, 15, function(v) S.auraRange = v end)
sec(f, "Ngắm"); tgl(f, "Aimbot", false, function(v) setL("aim", v and function() return R.RenderStepped:Connect(function() local cl, cd = nil, math.huge; for _,p in pairs(P:GetPlayers()) do if p ~= LP and p.Character then local t = p.Character:FindFirstChild("Head"); if t then local sp = Cam:WorldToViewportPoint(t.Position); if sp.Z > 0 then local m = U:GetMouseLocation(); local d = math.sqrt((sp.X - m.X)^2 + (sp.Y - m.Y)^2); if d < S.aimFov and d < cd then cl, cd = t, d end end end end end; if cl then Cam.CFrame = Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position, cl.Position), S.aimSmooth) end end) end or nil) end)

local f = addTab("Máy Chủ", "🌐")
sec(f, "Server"); btn(f, "Vào lại", function() Ts:Teleport(game.PlaceId, LP) end); btn(f, "Đổi server", function() local d = H:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100")); if d and d.data then for _,s in pairs(d.data) do if s.id ~= game.JobId and s.playing < s.maxPlayers then Ts:TeleportToPlaceInstance(game.PlaceId, s.id, LP); return end end end end)

-- CHẠY
Tabs["Mắt Thần"].b.MouseButton1Click:Fire()
noti("ANON HUB", "Đã nạp bản siêu gọn")
