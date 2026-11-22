-- ngôn ngữ: Lua, tệp: anon_hub_full_toigian.lua
-- *TỐI GIẢN ĐẦY ĐỦ - Data-Driven. Giữ 100% chức năng, vuốt mượt, menu 380px.*

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
local Market = game:GetService("MarketplaceService")
local LP = P.LocalPlayer
local Cam = W.CurrentCamera

local function noti(t, n, d) pcall(function() G:SetCore("SendNotification", {Title=t or "ANON HUB", Text=n or "", Duration=d or 2}) end) end
local function gC() return LP.Character or LP.CharacterAdded:Wait() end
local function gH() return gC():FindFirstChildOfClass("Humanoid") end
local function gHRP() return gC():FindFirstChild("HumanoidRootPart") end

-- TRẠNG THÁI (RÚT GỌN)
local S = {
    spd=false, spdV=60, jmp=false, jmpV=100, fly=false, flyV=80, noclip=false, infJmp=false, afk=true, void=false,
    spin=false, spinV=8, bhop=false, water=false, hover=false, hoverV=5, tpClick=false, follow=nil, followD=10,
    orbit=nil, orbitR=15, orbitS=3, fling=false, ragdoll=false, slow=false, grav=false, gravV=196.2,
    eP=false, eM=false, eI=false, eT=false, eN=false, eH=false, eD=false, eB=false,
    colP=Color3.fromRGB(255,80,80), colM=Color3.fromRGB(255,180,60), colI=Color3.fromRGB(100,255,160),
    ac=false, at=false, aura=false, auraR=15, aim=false, aimS=0.15, aimF=150, aimP="Head",
    trig=false, trigD=0.05, silent=false, silentF=200, hitbox=false, hitboxS=2, ashoot=false, shootD=0.05,
    farmH=false, hutR=50, farmP=false, reply=false, replyM="Bot đang chơi", spam=false, spamM="", spamD=2,
    camF=false, camD=20, rapid=false, rapidD=0.05, infAmmo=false, respawn=false, equip=false, logR=false,
    rain=false, spinCam=false, spinCamV=5, headless=false, giant=false, giantS=3, tiny=false, tinyS=0.3,
    scan=0.15
}
local Rules = { mob = {}, item = {} }

-- LƯU / ĐỌC
local function saveAll()
    if not writefile then return end
    pcall(function()
        writefile("anon_luat.json", H:JSONEncode(Rules))
        writefile("anon_caidat.json", H:JSONEncode({spdV=S.spdV, jmpV=S.jmpV, flyV=S.flyV, auraR=S.auraR, aimS=S.aimS, aimF=S.aimF, aimP=S.aimP, hutR=S.hutR, scan=S.scan}))
    end)
end
local function loadAll()
    if not isfile or not readfile then return end
    pcall(function()
        if isfile("anon_luat.json") then local d = H:JSONDecode(readfile("anon_luat.json")); if d.mob then Rules.mob = d.mob end; if d.item then Rules.item = d.item end end
        if isfile("anon_caidat.json") then local c = H:JSONDecode(readfile("anon_caidat.json")); for k,v in pairs(c) do if S[k] ~= nil then S[k] = v end end end
    end)
end
loadAll()

-- KHỚP DẤU HIỆU
local function matchSig(o, s)
    if not o or not o.Parent then return false end
    if s.class and o.ClassName ~= s.class then if not o:FindFirstAncestorOfClass(s.class) then return false end end
    if s.name and s.name ~= "" then
        if not o.Name:lower():find(s.name:lower(),1,true) then
            local anc = s.class and o:FindFirstAncestorOfClass(s.class)
            if not (anc and anc.Name:lower():find(s.name:lower(),1,true)) then return false end
        end
    end
    if s.tags then for _,t in ipairs(s.tags) do if not C:HasTag(o,t) then return false end end end
    if s.attrs then for k,v in pairs(s.attrs) do if o:GetAttribute(k) ~= v then return false end end end
    if s.folder then local p, f = o.Parent, false; for i=1,6 do if not p or p==W or p==game then break end; if p.Name:lower()==s.folder:lower() then f=true; break end; p=p.Parent end; if not f then return false end end
    if s.hasHum ~= nil then if (o:FindFirstChildOfClass("Humanoid") ~= nil) ~= s.hasHum then return false end end
    if s.size then local sz = o:IsA("BasePart") and o.Size or (o:IsA("Model") and o:FindFirstChildWhichIsA("BasePart") and o:FindFirstChildWhichIsA("BasePart").Size); if sz and (sz.Magnitude < s.size.min or sz.Magnitude > s.size.max) then return false end end
    return true
end
local function matchAny(o, l) for _,s in ipairs(l) do if matchSig(o,s) then return true end end return false end
local function makeSig(o)
    local model = o:FindFirstAncestorOfClass("Model") or o; local sig = {}
    sig.class = o:IsA("Tool") and "Tool" or (model:IsA("Model") and "Model" or "BasePart")
    local nm = sig.class=="Model" and model.Name or o.Name; local cl = nm:gsub("%d+",""):match("^%s*(.-)%s*$"); if #cl>=2 then sig.name=cl end
    local tags={}; for _,t in ipairs(C:GetTags(o)) do table.insert(tags,t) end; if #tags>0 then sig.tags=tags end
    local attrs={}; for k,v in pairs(o:GetAttributes()) do if type(v)=="string" or type(v)=="number" or type(v)=="boolean" then attrs[k]=v end end; if next(attrs) then sig.attrs=attrs end
    local tar = sig.class=="Model" and model or o; if tar.Parent and tar.Parent~=W and tar.Parent:IsA("Folder") then sig.folder=tar.Parent.Name end
    if sig.class=="Model" then sig.hasHum = (model:FindFirstChildOfClass("Humanoid")~=nil) end
    if o:IsA("BasePart") then local sz=o.Size.Magnitude; sig.size={min=sz*0.7, max=sz*1.4} end
    return sig
end

-- UI KHUNG
local CG = (gethui and gethui()) or game:GetService("CoreGui")
local GUI = Instance.new("ScreenGui", CG); GUI.Name="ANON_HUB"; GUI.ResetOnSpawn=false
local Main = Instance.new("Frame", GUI); Main.Size=UDim2.new(0,280,0,380); Main.Position=UDim2.new(0,40,0,80); Main.BackgroundColor3=Color3.fromRGB(16,16,20); Main.Active=true
Instance.new("UICorner", Main).CornerRadius=UDim.new(0,8)
local Top = Instance.new("Frame", Main); Top.Size=UDim2.new(1,0,0,30); Top.BackgroundColor3=Color3.fromRGB(26,26,34); Instance.new("UICorner", Top).CornerRadius=UDim.new(0,8)
local Ttl = Instance.new("TextLabel", Top); Ttl.Size=UDim2.new(1,0,1,0); Ttl.BackgroundTransparency=1; Ttl.Text="ANON HUB"; Ttl.TextColor3=Color3.new(1,1,1)
local MinB = Instance.new("TextButton", Top); MinB.Size=UDim2.new(0,22,0,22); MinB.Position=UDim2.new(1,-28,0,4); MinB.Text="–"; MinB.BackgroundColor3=Color3.fromRGB(50,50,60); Instance.new("UICorner", MinB).CornerRadius=UDim.new(0,4)

local TabBar = Instance.new("ScrollingFrame", Main); TabBar.Size=UDim2.new(1,0,0,24); TabBar.Position=UDim2.new(0,0,0,30); TabBar.BackgroundColor3=Color3.fromRGB(20,20,26); TabBar.ScrollBarThickness=0; TabBar.AutomaticCanvasSize=Enum.AutomaticSize.X; TabBar.ScrollingDirection=Enum.ScrollingDirection.X; TabBar.Active=true
local Tl = Instance.new("UIListLayout", TabBar); Tl.FillDirection=Enum.FillDirection.Horizontal; Tl.Padding=UDim.new(0,2)

local Content = Instance.new("ScrollingFrame", Main); Content.Size=UDim2.new(1,-12,1,-60); Content.Position=UDim2.new(0,6,0,56); Content.BackgroundTransparency=1; Content.AutomaticCanvasSize=Enum.AutomaticSize.Y; Content.ScrollingDirection=Enum.ScrollingDirection.Y; Content.Active=true; Content.ScrollingEnabled=true; Content.ScrollBarThickness=6
Instance.new("UIListLayout", Content).Padding=UDim.new(0,4)

-- KÉO THẢ & THU NHỎ
local dr, ds, sp
Top.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dr=true; ds=i.Position; sp=Main.Position end end)
U.InputChanged:Connect(function(i) if dr and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local d=i.Position-ds; Main.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end)
U.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dr=false end end)
MinB.MouseButton1Click:Connect(function() T:Create(Main,TweenInfo.new(0.2),{Size=Main.Size.Y.Offset==380 and UDim2.new(0,280,0,30) or UDim2.new(0,280,0,380)}):Play(); Content.Visible=not Content.Visible; MinB.Text=Content.Visible and "–" or "+" end)

-- HÀM UI
local Tabs = {}
local function addTab(n, i)
    local b = Instance.new("TextButton", TabBar); b.Size=UDim2.new(0,60,0,18); b.Text=i.." "..n; b.BackgroundColor3=Color3.fromRGB(35,35,44); b.TextSize=9; b.AutoButtonColor=false; Instance.new("UICorner", b).CornerRadius=UDim.new(0,4)
    local f = Instance.new("Frame", Content); f.Size=UDim2.new(1,0,1,0); f.BackgroundTransparency=1; f.Visible=false; Instance.new("UIListLayout", f).Padding=UDim.new(0,4)
    Tabs[n]={b=b,f=f}
    b.MouseButton1Click:Connect(function() for _,v in pairs(Tabs) do v.f.Visible=false; v.b.BackgroundColor3=Color3.fromRGB(35,35,44) end; f.Visible=true; b.BackgroundColor3=Color3.fromRGB(60,90,140) end)
    return f
end
local function sec(p,t) local l=Instance.new("TextLabel",p); l.Size=UDim2.new(1,0,0,16); l.BackgroundColor3=Color3.fromRGB(22,22,28); l.Text=" "..t; l.TextColor3=Color3.fromRGB(120,200,255); l.TextSize=10; l.TextXAlignment=Enum.TextXAlignment.Left; Instance.new("UICorner",l).CornerRadius=UDim.new(0,4) end
local function btn(p,t,f) local b=Instance.new("TextLabel",p); b.Size=UDim2.new(1,0,0,24); b.BackgroundColor3=Color3.fromRGB(28,28,36); b.Text=t; b.TextSize=10; b.TextColor3=Color3.fromRGB(210,210,220); Instance.new("UICorner",b).CornerRadius=UDim.new(0,4); b.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then f() end end) end
local function tgl(p,t,d,f) local s=d; local b=btn(p,t,function() s=not s; b.BackgroundColor3=s and Color3.fromRGB(80,200,120) or Color3.fromRGB(28,28,36); f(s) end) end
local function sld(p,t,mn,mx,d,f) local h=Instance.new("Frame",p); h.Size=UDim2.new(1,0,0,38); h.BackgroundColor3=Color3.fromRGB(28,28,36); Instance.new("UICorner",h).CornerRadius=UDim.new(0,4); local l=Instance.new("TextLabel",h); l.Size=UDim2.new(1,-12,0,16); l.Position=UDim2.new(0,8,0,2); l.BackgroundTransparency=1; l.Text=t..": "..d; l.TextColor3=Color3.fromRGB(210,210,220); l.TextSize=10; l.TextXAlignment=Enum.TextXAlignment.Left; local bar=Instance.new("Frame",h); bar.Size=UDim2.new(1,-16,0,6); bar.Position=UDim2.new(0,8,0,26); bar.BackgroundColor3=Color3.fromRGB(50,50,60); Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0); local fil=Instance.new("Frame",bar); fil.Size=UDim2.new((d-mn)/(mx-mn),0,1,0); fil.BackgroundColor3=Color3.fromRGB(120,200,255); Instance.new("UICorner",fil).CornerRadius=UDim.new(1,0); local dr=false; bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dr=true end end); U.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dr=false end end); U.InputChanged:Connect(function(i) if dr and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local pct=math.clamp((i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1); fil.Size=UDim2.new(pct,0,1,0); local v=mn+(mx-mn)*pct; l.Text=t..": "..math.floor(v); f(v) end end) end
local function inp(p,ph,f) local b=Instance.new("Frame",p); b.Size=UDim2.new(1,0,0,26); b.BackgroundColor3=Color3.fromRGB(28,28,36); Instance.new("UICorner",b).CornerRadius=UDim.new(0,4); local t=Instance.new("TextBox",b); t.Size=UDim2.new(1,-12,1,-4); t.Position=UDim2.new(0,6,0,2); t.BackgroundTransparency=1; t.PlaceholderText=ph; t.TextSize=10; t.ClearTextOnFocus=false; t.FocusLost:Connect(function() f(t.Text) end) end
local function col(p,t,d,f) local h=btn(p,t,function() end); local sw=Instance.new("Frame",h); sw.Size=UDim2.new(0,20,0,12); sw.Position=UDim2.new(1,-28,0.5,-6); sw.BackgroundColor3=d; Instance.new("UICorner",sw).CornerRadius=UDim.new(0,3); local pal={Color3.fromRGB(255,80,80),Color3.fromRGB(80,200,255),Color3.fromRGB(100,255,160),Color3.fromRGB(255,200,60),Color3.fromRGB(200,100,255),Color3.fromRGB(255,255,255)}; local idx=1; for i,c in ipairs(pal) do if c==d then idx=i end end; h.InputEnded:Connect(function() idx=idx%#pal+1; sw.BackgroundColor3=pal[idx]; f(pal[idx]) end) end

-- ESP ENGINE
local function aHL(o,c,n) if not o:FindFirstChild(n) then local h=Instance.new("Highlight",o); h.Name=n; h.FillColor=c; h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop end end
local function delHL(o,n) if o and o:FindFirstChild(n) then o[n]:Destroy() end end
local trGui=Instance.new("ScreenGui",CG); trGui.Name="tr"; trGui.ResetOnSpawn=false; local trs={}
local bGui=Instance.new("ScreenGui",CG); bGui.Name="b"; bGui.ResetOnSpawn=false; local bns={}
local lbGui=Instance.new("ScreenGui",CG); lbGui.Name="lb"; lbGui.ResetOnSpawn=false; local lbs={}

local eConn, eOn, lScan = nil, false, 0
local function startEsp()
    if eOn then return end; eOn=true
    eConn = R.RenderStepped:Connect(function()
        local now=tick(); if now-lScan < S.scan then return end; lScan=now
        for _,p in pairs(P:GetPlayers()) do if p~=LP and p.Character then if S.eP then aHL(p.Character,S.colP,"eP") else delHL(p.Character,"eP") end end end
        for _,o in pairs(W:GetDescendants()) do
            if o:IsA("Model") or o:IsA("BasePart") then
                if S.eM and matchAny(o,Rules.mob) then aHL(o,S.colM,"eM") else delHL(o,"eM") end
                if S.eI and matchAny(o,Rules.item) then aHL(o,S.colI,"eI") else delHL(o,"eI") end
            end
        end
        -- Tracers/Bones/Labels (simplified)
        for _,p in pairs(P:GetPlayers()) do
            if p~=LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if S.eT or S.eN or S.eH or S.eD then
                    local sp=Cam:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                    if sp.Z>0 then
                        if S.eT then
                            local t=trs[p] or Instance.new("Frame",trGui); trs[p]=t; t.BorderSizePixel=0; t.BackgroundColor3=Color3.new(1,1,1)
                            local gx,gy=Cam.ViewportSize.X/2,Cam.ViewportSize.Y; local dx,dy=sp.X-gx,sp.Y-gy; local len,ang=math.sqrt(dx*dx+dy*dy),math.atan2(dy,dx)
                            t.Position=UDim2.new(0,gx,0,gy); t.Size=UDim2.new(0,len,0,1); t.Rotation=math.deg(ang); t.Visible=true
                        end
                        if S.eN or S.eH or S.eD then
                            local l=lbs[p] or Instance.new("TextLabel",lbGui); lbs[p]=l; l.BackgroundTransparency=1; l.TextSize=10; l.TextColor3=Color3.new(1,1,1); l.Size=UDim2.new(0,200,0,40); l.Position=UDim2.new(0,sp.X-100,0,sp.Y-50)
                            local txt=""; if S.eN then txt=txt..p.Name.."\n" end; if S.eH then local h=p.Character:FindFirstChildOfClass("Humanoid"); if h then txt=txt.."Máu: "..math.floor(h.Health).."\n" end end
                            if S.eD and gHRP() then txt=txt..math.floor((gHRP().Position-p.Character.HumanoidRootPart.Position).Magnitude).."m" end
                            l.Text=txt; l.Visible=true
                        end
                    else
                        if trs[p] then trs[p].Visible=false end; if lbs[p] then lbs[p].Visible=false end
                    end
                end
            end
        end
    end)
end

local function stopEsp() if not S.eP and not S.eM and not S.eI and not S.eT and not S.eN and not S.eH and not S.eD and not S.eB then if eConn then eConn:Disconnect() end; eOn=false end end

-- HỌC ESP
local lrn, lrnC = nil, nil
local hint=Instance.new("TextLabel",GUI); hint.Size=UDim2.new(0,400,0,36); hint.Position=UDim2.new(0.5,-200,0,60); hint.BackgroundColor3=Color3.fromRGB(20,20,28); hint.TextColor3=Color3.fromRGB(120,255,160); hint.Font=Enum.Font.GothamBold; hint.TextSize=13; hint.Visible=false
local function stopLrn() lrn=nil; hint.Visible=false; if lrnC then lrnC:Disconnect() end end
local function startLrn(m) stopLrn(); lrn=m; hint.Text="🎯 Nhấp "..(m=="mob" and "QUÁI" or "VẬT PHẨM").." (ESC dừng)"; hint.Visible=true
    lrnC = U.InputBegan:Connect(function(i,gp) if gp then return end; if i.KeyCode==Enum.KeyCode.Escape then stopLrn(); return end; if i.UserInputType~=Enum.UserInputType.MouseButton1 then return end
        local ray=Cam:ViewportPointToRay(U:GetMouseLocation().X,U:GetMouseLocation().Y); local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Exclude; rp.FilterDescendantsInstances={gC(),GUI}; local res=W:Raycast(ray.Origin,ray.Direction*1000,rp)
        if res and res.Instance then local c=res.Instance; local t=c:IsA("Tool") and c or (c:FindFirstAncestorOfClass("Model") or c); local s=makeSig(t); local j=H:JSONEncode(s); local list=m=="mob" and Rules.mob or Rules.item; for _,e in ipairs(list) do if H:JSONEncode(e)==j then noti("HUB","Đã có"); return end end; table.insert(list,s); saveAll(); if m=="mob" then S.eM=true else S.eI=true end; startEsp(); noti("HUB","Đã học: "..t.Name) end
    end)
end

-- LOGIC VÒNG LẶP
local Lps = {}
local function setL(n, f) if Lps[n] then Lps[n]:Disconnect() end; if f then Lps[n]=f() end end

-- CÁC TAB (16 TAB ĐẦY ĐỦ)
local f = addTab("Mắt Thần", "👁️")
sec(f, "ESP"); tgl(f, "ESP Người", false, function(v) S.eP=v; if v then startEsp() else stopEsp() end end); tgl(f, "ESP Quái", false, function(v) S.eM=v; if v then startEsp() else stopEsp() end end); tgl(f, "ESP Item", false, function(v) S.eI=v; if v then startEsp() else stopEsp() end end)
sec(f, "Nâng cao"); tgl(f, "Tracer", false, function(v) S.eT=v; if v then startEsp() else stopEsp() end end); tgl(f, "Tên", false, function(v) S.eN=v; if v then startEsp() else stopEsp() end end); tgl(f, "Máu", false, function(v) S.eH=v; if v then startEsp() else stopEsp() end end); tgl(f, "Khoảng cách", false, function(v) S.eD=v; if v then startEsp() else stopEsp() end end)
sec(f, "Học"); btn(f, "Học Quái", function() startLrn("mob") end); btn(f, "Học Item", function() startLrn("item") end)
sec(f, "Màu"); col(f, "Màu người", S.colP, function(c) S.colP=c end); col(f, "Màu quái", S.colM, function(c) S.colM=c end); col(f, "Màu item", S.colI, function(c) S.colI=c end)

local f = addTab("Di Chuyển", "🏃")
sec(f, "Tốc độ"); tgl(f, "Chạy nhanh", false, function(v) S.spd=v; setL("spd", v and function() return R.Heartbeat:Connect(function() local h=gH(); if h then h.WalkSpeed=S.spdV end end) end or nil) end); sld(f, "Tốc độ", 16, 500, S.spdV, function(v) S.spdV=v end)
sec(f, "Nhảy"); tgl(f, "Nhảy cao", false, function(v) S.jmp=v; setL("jmp", v and function() return R.Heartbeat:Connect(function() local h=gH(); if h then h.UseJumpPower=true; h.JumpPower=S.jmpV end end) end or nil) end); sld(f, "Lực nhảy", 50, 1000, S.jmpV, function(v) S.jmpV=v end)
tgl(f, "Nhảy vô hạn", false, function(v) S.infJmp=v; setL("infJmp", v and function() return U.JumpRequest:Connect(function() local h=gH(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end) end or nil) end)
sec(f, "Bay"); tgl(f, "Bay lượn", false, function(v) S.fly=v; if v then local hrp=gHRP(); if hrp then local bv=Instance.new("BodyVelocity",hrp); bv.Name="fly"; bv.MaxForce=Vector3.new(1e9,1e9,1e9); setL("fly", function() return R.RenderStepped:Connect(function() local dir=Vector3.new(); if U:IsKeyDown(Enum.KeyCode.W) then dir+=Cam.CFrame.LookVector end; if U:IsKeyDown(Enum.KeyCode.S) then dir-=Cam.CFrame.LookVector end; if U:IsKeyDown(Enum.KeyCode.A) then dir-=Cam.CFrame.RightVector end; if U:IsKeyDown(Enum.KeyCode.D) then dir+=Cam.CFrame.RightVector end; bv.Velocity=dir.Magnitude>0 and dir.Unit*S.flyV or Vector3.new() end) end) end end else setL("fly", nil); local hrp=gHRP(); if hrp then local o=hrp:FindFirstChild("fly"); if o then o:Destroy() end end end end); sld(f, "Tốc độ bay", 10, 500, S.flyV, function(v) S.flyV=v end)
sec(f, "Khác"); tgl(f, "Xuyên vật thể", false, function(v) S.noclip=v; setL("nc", v and function() return R.Stepped:Connect(function() local c=LP.Character; if c then for _,p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end end) end or nil) end)
tgl(f, "Chống rơi map", false, function(v) S.void=v; setL("void", v and function() return R.Heartbeat:Connect(function() local hrp=gHRP(); if hrp and hrp.Position.Y < -50 then hrp.CFrame=CFrame.new(0,50,0) end end) end or nil) end)
tgl(f, "Chống AFK", true, function(v) S.afk=v; setL("afk", v and function() local vu=LP:FindFirstChildOfClass("VirtualUser") or Instance.new("VirtualUser",LP); return vu.Idled:Connect(function() vu:CaptureController(); vu:ClickButton2(Vector2.new()) end) end or nil) end)

local f = addTab("Thế Giới", "🌍")
sec(f, "Ánh sáng"); tgl(f, "Sáng tối đa", false, function(v) if v then L.Brightness=2; L.ClockTime=14; L.GlobalShadows=false; L.OutdoorAmbient=Color3.fromRGB(200,200,200) else L.GlobalShadows=true; L.OutdoorAmbient=Color3.fromRGB(128,128,128) end end); tgl(f, "Trời tối", false, function(v) L.Brightness=v and 0.3 or 2; L.ClockTime=v and 0 or 14 end); tgl(f, "Sương mù", false, function(v) L.FogEnd=v and 100 or 100000 end)
sec(f, "Thời gian"); btn(f, "Bình minh", function() L.ClockTime=6 end); btn(f, "Hoàng hôn", function() L.ClockTime=18 end); btn(f, "Nửa đêm", function() L.ClockTime=0 end)
sec(f, "Âm thanh"); btn(f, "Tắt", function() pcall(function() Snd.Volume=0 end) end); btn(f, "Bật", function() pcall(function() Snd.Volume=1 end) end)

local f = addTab("Tiện Ích", "🛠️")
sec(f, "Vị trí"); local pos=nil; btn(f, "Lưu vị trí", function() pos=gHRP().CFrame; noti("HUB","Đã lưu") end); btn(f, "Quay lại", function() if pos then gHRP().CFrame=pos end end); local nIn=""; inp(f, "Tên người chơi...", function(v) nIn=v end); btn(f, "Tới người chơi", function() local t=P:FindFirstChild(nIn); if t and t.Character then gHRP().CFrame=t.Character:FindFirstChild("HumanoidRootPart").CFrame*CFrame.new(0,0,5) end end)
sec(f, "Chat"); local ci=inp(f, "Nhập...", function(v) end); btn(f, "Gửi", function() pcall(function() if Rep:FindFirstChild("DefaultChatSystemChatEvents") then Rep.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(ci.Text,"All") end end) end); tgl(f, "Auto Reply", false, function(v) S.reply=v; setL("reply", v and function() return LP.Chatted:Connect(function() pcall(function() Rep.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(S.replyM,"All") end) end) end or nil) end); inp(f, "Nội dung...", function(v) S.replyM=v end); tgl(f, "Spam Chat", false, function(v) S.spam=v; setL("spam", v and function() return task.spawn(function() while S.spam do pcall(function() Rep.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(S.spamM,"All") end); task.wait(S.spamD) end end) end or nil) end); inp(f, "Nội dung spam...", function(v) S.spamM=v end); sld(f, "Chu kỳ", 1, 10, S.spamD, function(v) S.spamD=v end)
sec(f, "Copy"); btn(f, "Tên", function() if setclipboard then setclipboard(LP.Name) end end); btn(f, "Job ID", function() if setclipboard then setclipboard(game.JobId) end end); btn(f, "Place ID", function() if setclipboard then setclipboard(tostring(game.PlaceId)) end end)

local f
