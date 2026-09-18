warn("[anhhub] mega")
local P,U,RS = game:GetService("Players"),game:GetService("UserInputService"),game:GetService("ReplicatedStorage")
local LP = P.LocalPlayer

-- ============================================
-- CONFIG
-- ============================================
local KEYS = {["ANH-1DAY-A1B2"]=1,["ANH-1DAY-C3D4"]=1,["ANH-1DAY-E5F6"]=1,["ANH-30DAY-G7H8"]=30,["ANH-30DAY-I9J0"]=30,["ANH-365DAY-K1L2"]=365,["ANH-365DAY-M3N4"]=365,["ANH-VIP-O5P6"]=9999,["ANH-DZ-2012VUAHACK"]=9999}
local ADMIN_KEY = "2012BAVCL"
local C = getgenv().AH or {}
getgenv().AH = C
for k,v in pairs({ESPPlayer=false,ESPMob=false,Fly=false,Noclip=false,Speed=false,FlySpeed=100,RunSpeed=50,MaxDist=2000}) do if C[k]==nil then C[k]=v end end
local KF,TF,HF,CF,AF,AHF = "anhhub_key.txt","anhhub_key_time.txt","anhhub_key_hwid.txt","anhhub_custom_keys.txt","anhhub_admin_key.txt","anhhub_admin_hwid.txt"

-- ============================================
-- HELPERS
-- ============================================
local function HWID()
    if gethwid then local ok,h=pcall(gethwid) if ok and h then return tostring(h) end end
    if syn and syn.get_hwid then local ok,h=pcall(syn.get_hwid) if ok and h then return tostring(h) end end
    return "FB_"..tostring(LP.UserId).."_"..(U.TouchEnabled and "m" or "p")
end
local function readF(p) if not readfile or not isfile or not isfile(p) then return nil end local ok,d = pcall(readfile,p) if ok then return d end end
local function writeF(p,d) pcall(function() if writefile then writefile(p,d) end end) end
local function loadCM()
    local m = {}
    local d = readF(CF)
    if d then for line in d:gmatch("[^\r\n]+") do local k,dd,h = line:match("^([^|]+)|(%d+)|(.*)$") if k and dd then m[k]={days=tonumber(dd),hwid=h or ""} end end end
    return m
end
local function writeCM(m)
    local lines = {}
    for k,v in pairs(m) do table.insert(lines, k.."|"..tostring(v.days).."|"..(v.hwid or "")) end
    writeF(CF, table.concat(lines,"\n"))
end
local CM = loadCM()
local customKeys = {}
for k,v in pairs(CM) do if not KEYS[k] then KEYS[k]=v.days end customKeys[k]=v.days end
local function HWIDFor(k)
    if not CM[k] then return "new" end
    local h = CM[k].hwid
    if not h or h=="" then return "new" end
    return h==HWID() and "ok" or "mismatch"
end
local function updateCMHWID(k,h) if CM[k] then CM[k].hwid=h writeCM(CM) end end
local function HWIDCheck()
    if getgenv().AH_Key then local r = HWIDFor(getgenv().AH_Key) if r~="new" then return r end end
    local s = readF(HF)
    if not s or s=="" then return "new" end
    return tostring(s)==tostring(HWID()) and "ok" or "mismatch"
end
local function expired(k)
    if not k or not KEYS[k] then return true end
    local d = KEYS[k]
    if d>=9999 then return false end
    local s = readF(TF)
    if not s then return false end
    local t = tonumber(s)
    if not t then return false end
    return (os.time()-t) > (d*86400)
end
local function saveKey(k)
    writeF(KF,k) writeF(TF,tostring(os.time())) writeF(HF,HWID())
    getgenv().AH_Key = k
    if CM[k] then updateCMHWID(k, HWID()) end
end
local function clearKey()
    writeF(KF,"") writeF(TF,"") writeF(HF,"")
    getgenv().AH_Key = nil
end
local function loadKey()
    if getgenv().AH_Key then
        if expired(getgenv().AH_Key) then clearKey() return nil end
        if HWIDCheck()=="mismatch" then clearKey() return nil end
        return getgenv().AH_Key
    end
    local s = readF(KF)
    if not s then return nil end
    local k = s:gsub("%s+",""):upper()
    if not KEYS[k] then return nil end
    if expired(k) then clearKey() return nil end
    if HWIDFor(k)=="mismatch" then clearKey() return nil end
    if HWIDCheck()=="mismatch" then clearKey() return nil end
    getgenv().AH_Key = k
    return k
end
local function remainText()
    if not getgenv().AH_Key then return "chưa có key" end
    local d = KEYS[getgenv().AH_Key]
    if not d then return "invalid" end
    if d>=9999 then return "VIP — vĩnh viễn" end
    local s = readF(TF)
    if not s then return d.." ngày" end
    local t = tonumber(s)
    if not t then return d.." ngày" end
    local r = d*86400 - (os.time()-t)
    if r<=0 then return "hết hạn" end
    local dd = math.floor(r/86400)
    local hh = math.floor((r%86400)/3600)
    local mm = math.floor((r%3600)/60)
    if dd>0 then return dd.."n "..hh.."h" elseif hh>0 then return hh.."h "..mm.."p" else return mm.."p" end
end
local function adminHWIDCheck()
    local s = readF(AHF)
    if not s or s=="" then return "new" end
    return tostring(s)==tostring(HWID()) and "ok" or "mismatch"
end
local function saveAdmin()
    writeF(AF, ADMIN_KEY)
    writeF(AHF, HWID())
end

-- ============================================
-- KEY GUI
-- ============================================
local function keyGui(cb)
    local PG = LP:WaitForChild("PlayerGui")
    local o = PG:FindFirstChild("anhkey") if o then o:Destroy() end
    local g = Instance.new("ScreenGui")
    g.Name,g.ResetOnSpawn,g.IgnoreGuiInset,g.DisplayOrder,g.Parent = "anhkey",false,true,2147483647,PG
    local f = Instance.new("Frame",g)
    f.Size,f.Position,f.BackgroundColor3 = UDim2.new(0,300,0,190),UDim2.new(0.5,-150,0.5,-95),Color3.fromRGB(0,20,40)
    Instance.new("UICorner",f).CornerRadius = UDim.new(0,10)
    local s = Instance.new("UIStroke",f) s.Color,s.Thickness = Color3.new(0,0.78,1),2
    local t = Instance.new("TextLabel",f)
    t.Size,t.BackgroundColor3,t.BorderSizePixel = UDim2.new(1,0,0,36),Color3.fromRGB(0,40,80),0
    t.Text,t.TextColor3,t.Font,t.TextSize = "🔑 ánh hub — nhập key",Color3.new(0,0.78,1),Enum.Font.GothamBold,13
    Instance.new("UICorner",t).CornerRadius = UDim.new(0,10)
    local i = Instance.new("TextBox",f)
    i.Size,i.Position,i.BackgroundColor3 = UDim2.new(1,-30,0,36),UDim2.new(0,15,0,50),Color3.fromRGB(10,30,60)
    i.PlaceholderText,i.Text,i.TextColor3,i.PlaceholderColor3 = "ANH-XXXX-XXXX","",Color3.new(1,1,1),Color3.fromRGB(100,100,140)
    i.Font,i.TextSize,i.ClearTextOnFocus = Enum.Font.Gotham,13,false
    Instance.new("UICorner",i).CornerRadius = UDim.new(0,6)
    local st = Instance.new("TextLabel",f)
    st.Size,st.Position,st.BackgroundTransparency = UDim2.new(1,-20,0,20),UDim2.new(0,10,0,92),1
    st.Text,st.TextColor3,st.Font,st.TextSize = "",Color3.new(1,0.3,0.3),Enum.Font.Gotham,11
    local info = Instance.new("TextLabel",f)
    info.Size,info.Position,info.BackgroundTransparency = UDim2.new(1,-20,0,20),UDim2.new(0,10,0,112),1
    info.Text,info.TextColor3,info.Font,info.TextSize = "1 ngày | 30 ngày | 365 ngày | VIP",Color3.fromRGB(120,140,160),Enum.Font.Gotham,10
    local b = Instance.new("TextButton",f)
    b.Size,b.Position,b.BackgroundColor3 = UDim2.new(1,-30,0,36),UDim2.new(0,15,0,138),Color3.fromRGB(0,80,120)
    b.Text,b.TextColor3,b.Font,b.TextSize = "XÁC NHẬN",Color3.new(1,1,1),Enum.Font.GothamBold,13
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,6)
    local function try()
        local k = i.Text:gsub("%s+",""):upper()
        if not KEYS[k] then st.TextColor3 = Color3.new(1,0.3,0.3) st.Text = "❌ key không hợp lệ" i.Text = "" return end
        if HWIDFor(k)=="mismatch" then st.TextColor3 = Color3.new(1,0.3,0.3) st.Text = "❌ key dùng thiết bị khác" i.Text = "" return end
        if HWIDCheck()=="mismatch" then st.TextColor3 = Color3.new(1,0.3,0.3) st.Text = "❌ key dùng thiết bị khác" i.Text = "" return end
        st.TextColor3 = Color3.new(0,1,0.3)
        st.Text = "✅ hợp lệ — "..(KEYS[k]>=9999 and "vĩnh viễn" or KEYS[k].." ngày")
        task.wait(0.5) g:Destroy() saveKey(k) cb()
    end
    b.MouseButton1Click:Connect(try)
    i.FocusLost:Connect(function(e) if e then try() end end)
end

-- ============================================
-- TOOL
-- ============================================
local function runTool()
    local T,M,S = {},{},{}
    local fU,fD = false,false
    local hrp = function(c) return c and c:FindFirstChild("HumanoidRootPart") end
    LP.CharacterAdded:Connect(function() S={} end)
    game:GetService("RunService").RenderStepped:Connect(function(dt)
        local cam = WS.CurrentCamera
        if not cam then return end
        if dt>0.1 then dt=0.1 end
        for _,p in pairs(P:GetPlayers()) do
            if p~=LP then
                local c=p.Character local h=c and hrp(c) local t=T[p]
                local hum = c and c:FindFirstChildOfClass("Humanoid")
                if not C.ESPPlayer or not h or not hum or hum.Health<=0 then
                    if t then pcall(function() t.hl:Destroy() end) if t.bb then pcall(function() t.bb:Destroy() end) end T[p]=nil end
                elseif not t then
                    local tm = (p.Team and LP.Team and p.Team==LP.Team)
                    local col = tm and Color3.new(0,0.78,1) or Color3.new(1,0.23,0.23)
                    local hl=Instance.new("Highlight",c)
                    hl.FillColor=col hl.OutlineColor=col hl.FillTransparency=0.5 hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                    local bb=Instance.new("BillboardGui",c)
                    bb.Size=UDim2.new(0,180,0,50) bb.StudsOffset=Vector3.new(0,3,0) bb.AlwaysOnTop=true
                    local n=Instance.new("TextLabel",bb)
                    n.Size=UDim2.new(1,0,0,22) n.BackgroundTransparency=1 n.TextColor3=col n.TextStrokeTransparency=0 n.Font=Enum.Font.GothamBold n.TextScaled=true
                    local d=Instance.new("TextLabel",bb)
                    d.Size=UDim2.new(1,0,0,18) d.Position=UDim2.new(0,0,0,22) d.BackgroundTransparency=1 d.TextColor3=Color3.new(1,0.84,0) d.TextStrokeTransparency=0 d.Font=Enum.Font.Gotham d.TextScaled=true
                    T[p]={hl=hl,bb=bb,n=n,d=d}
                else
                    local dist=(h.Position-cam.CFrame.Position).Magnitude
                    local tm=(p.Team and LP.Team and p.Team==LP.Team)
                    local col = tm and Color3.new(0,0.78,1) or Color3.new(1,0.23,0.23)
                    t.hl.FillColor=col t.hl.OutlineColor=col t.n.TextColor3=col
                    t.n.Text=(p.DisplayName or p.Name)..(tm and " [Đội]" or "")
                    t.d.Text=math.floor(dist).." st"
                    local vis=dist<=C.MaxDist
                    t.hl.Enabled=vis t.bb.Enabled=vis
                end
            end
        end
        if C.ESPMob then
            for _,n in ipairs({"Enemies","Mobs","Bosses","Monsters","NPCs","SeaBeasts"}) do
                local f=WS:FindFirstChild(n)
                if f then for _,m in pairs(f:GetChildren()) do
                    if m:IsA("Model") then
                        if not hrp(m) then if M[m] then pcall(function() M[m]:Destroy() end) M[m]=nil end
                        elseif not M[m] then
                            local hl=Instance.new("Highlight",m)
                            hl.FillColor=Color3.new(1,0.55,0) hl.OutlineColor=Color3.new(1,0.55,0)
                            hl.FillTransparency=0.5 hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                            M[m]=hl
                        end
                    end
                end end
            end
        elseif next(M) then for m,t in pairs(M) do pcall(function() t:Destroy() end) M[m]=nil end end
        if C.Fly then
            local c=LP.Character local root=c and hrp(c) local hum=c and c:FindFirstChildOfClass("Humanoid")
            if root and hum then
                local v=root.AssemblyLinearVelocity
                root.AssemblyLinearVelocity=Vector3.new(v.X,0,v.Z)
                local md=hum.MoveDirection
                if md.Magnitude>0.01 then root.CFrame=root.CFrame+md.Unit*C.FlySpeed*dt end
                if fU or U:IsKeyDown(Enum.KeyCode.Space) then root.CFrame=root.CFrame+Vector3.new(0,1,0)*C.FlySpeed*dt end
                if fD or U:IsKeyDown(Enum.KeyCode.LeftShift) then root.CFrame=root.CFrame-Vector3.new(0,1,0)*C.FlySpeed*dt end
            end
        end
        if C.Noclip then
            local c=LP.Character
            if c then for _,p in pairs(c:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then S[p]=true p.CanCollide=false end
            end end
        elseif next(S) then
            for p in pairs(S) do if p and p.Parent then pcall(function() p.CanCollide=true end) end end
            S={}
        end
        local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            if C.Speed then if hum.WalkSpeed~=C.RunSpeed then hum.WalkSpeed=C.RunSpeed end
            else if hum.WalkSpeed~=16 then hum.WalkSpeed=16 end end
        end
    end)

    if not LP.Character then LP.CharacterAdded:Wait() end
    task.wait(1)
    local PG=LP:WaitForChild("PlayerGui")
    local o=PG:FindFirstChild("anhhub") if o then o:Destroy() end
    local gui=Instance.new("ScreenGui")
    gui.Name,gui.ResetOnSpawn,gui.IgnoreGuiInset,gui.DisplayOrder,gui.Parent="anhhub",false,true,999999,PG
    local logo=Instance.new("TextButton",gui)
    logo.Size,logo.AnchorPoint,logo.Position=UDim2.new(0,90,0,90),Vector2.new(0.5,0.5),UDim2.new(0.5,0,0.5,0)
    logo.BackgroundColor3,logo.Text,logo.TextColor3,logo.Font,logo.TextSize=Color3.new(0,0,0),"ánh hub",Color3.new(0,0.78,1),Enum.Font.GothamBlack,12
    Instance.new("UICorner",logo).CornerRadius=UDim.new(1,0)
    local stk=Instance.new("UIStroke",logo) stk.Color,stk.Thickness=Color3.new(0,0.78,1),2
    local menu=Instance.new("ScrollingFrame",gui)
    menu.Size,menu.Position,menu.BackgroundColor3,menu.BorderSizePixel=UDim2.new(0,240,0,500),UDim2.new(0,20,0,100),Color3.fromRGB(0,20,40),0
    menu.Visible,menu.Active,menu.ScrollBarThickness,menu.ScrollBarImageColor3=false,false,8,Color3.new(0,0.78,1)
    menu.CanvasSize,menu.AutomaticCanvasSize=UDim2.new(0,0,0,900),Enum.AutomaticSize.None
    Instance.new("UICorner",menu).CornerRadius=UDim.new(0,10)
    local lay=Instance.new("UIListLayout",menu)
    lay.SortOrder,lay.Padding,lay.HorizontalAlignment=Enum.SortOrder.LayoutOrder,UDim.new(0,4),Enum.HorizontalAlignment.Center
    local pd=Instance.new("UIPadding",menu)
    pd.PaddingTop,pd.PaddingLeft,pd.PaddingRight,pd.PaddingBottom=UDim.new(0,40),UDim.new(0,6),UDim.new(0,6),UDim.new(0,6)
    local infoBar = Instance.new("TextLabel",menu)
    infoBar.Size = UDim2.new(1,0,0,28)
    infoBar.LayoutOrder = -100
    infoBar.BackgroundColor3 = Color3.fromRGB(0,60,120)
    infoBar.BorderSizePixel = 0
    infoBar.Text = "⏱ Key: "..remainText()
    infoBar.TextColor3 = Color3.fromRGB(0,220,255)
    infoBar.Font = Enum.Font.GothamBold
    infoBar.TextSize = 12
    Instance.new("UICorner", infoBar).CornerRadius = UDim.new(0,6)
    task.spawn(function()
        while infoBar.Parent do task.wait(30) pcall(function() infoBar.Text = "⏱ Key: "..remainText() end) end
    end)
    local function tg(l,k)
        local b=Instance.new("TextButton",menu)
        b.Size,b.BackgroundColor3,b.TextColor3,b.Font,b.TextSize,b.TextXAlignment=UDim2.new(1,0,0,36),C[k] and Color3.fromRGB(0,60,120) or Color3.fromRGB(10,30,60),Color3.new(0,0.78,1),Enum.Font.Gotham,12,Enum.TextXAlignment.Left
        b.Text="  "..l.." : "..(C[k] and "BẬT" or "TẮT")
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
        b.MouseButton1Click:Connect(function()
            C[k]=not C[k] b.Text="  "..l.." : "..(C[k] and "BẬT" or "TẮT")
            b.BackgroundColor3=C[k] and Color3.fromRGB(0,60,120) or Color3.fromRGB(10,30,60)
        end)
    end
    tg("Định vị người chơi","ESPPlayer") tg("Định vị quái","ESPMob")
    tg("Bay xuyên tường","Fly") tg("Xuyên tường (noclip)","Noclip") tg("Chạy nhanh","Speed")

    -- Nút Admin Panel
    local ap = Instance.new("TextButton", menu)
    ap.Size, ap.BackgroundColor3 = UDim2.new(1,0,0,36), Color3.fromRGB(120,0,80)
    ap.Text, ap.TextColor3, ap.Font, ap.TextSize, ap.TextXAlignment = "  ⚙ Admin Panel", Color3.new(1,0.6,0.8), Enum.Font.GothamBold, 12, Enum.TextXAlignment.Left
    Instance.new("UICorner", ap).CornerRadius = UDim.new(0,6)
    ap.MouseButton1Click:Connect(function()
        local PG2 = LP:WaitForChild("PlayerGui")
        local o2 = PG2:FindFirstChild("admingui") if o2 then o2:Destroy() end
        local g = Instance.new("ScreenGui")
        g.Name,g.ResetOnSpawn,g.IgnoreGuiInset,g.DisplayOrder,g.Parent = "admingui",false,true,2147483646,PG2
        local f = Instance.new("Frame",g)
        f.Size,f.Position,f.BackgroundColor3 = UDim2.new(0,300,0,200),UDim2.new(0.5,-150,0.5,-100),Color3.fromRGB(20,0,40)
        Instance.new("UICorner",f).CornerRadius = UDim.new(0,10)
        local fs = Instance.new("UIStroke",f) fs.Color,fs.Thickness = Color3.new(1,0,0.5),2
        local t = Instance.new("TextLabel",f)
        t.Size,t.BackgroundColor3,t.BorderSizePixel = UDim2.new(1,0,0,36),Color3.fromRGB(60,0,40),0
        t.Text,t.TextColor3,t.Font,t.TextSize = "⚙ Admin",Color3.new(1,0.3,0.6),Enum.Font.GothamBold,13
        Instance.new("UICorner",t).CornerRadius = UDim.new(0,10)
        local cl = Instance.new("TextButton",f)
        cl.Size,cl.Position,cl.BackgroundColor3 = UDim2.new(0,26,0,26),UDim2.new(1,-30,0,5),Color3.fromRGB(180,50,50)
        cl.Text,cl.TextColor3,cl.Font,cl.TextSize,cl.ZIndex = "X",Color3.new(1,1,1),Enum.Font.GothamBold,13,5
        Instance.new("UICorner",cl).CornerRadius = UDim.new(0,6)
        cl.MouseButton1Click:Connect(function() g:Destroy() end)
        local i = Instance.new("TextBox",f)
        i.Size,i.Position,i.BackgroundColor3 = UDim2.new(1,-30,0,36),UDim2.new(0,15,0,50),Color3.fromRGB(10,30,60)
        i.PlaceholderText,i.Text = "admin key...",""
        i.TextColor3,i.PlaceholderColor3 = Color3.new(1,1,1),Color3.fromRGB(100,100,140)
        i.Font,i.TextSize,i.ClearTextOnFocus = Enum.Font.Gotham,13,false
        Instance.new("UICorner",i).CornerRadius = UDim.new(0,6)
        local sv = readF(AF)
        if sv and sv~="" and adminHWIDCheck()=="ok" then i.Text = sv end
        local st = Instance.new("TextLabel",f)
        st.Size,st.Position,st.BackgroundTransparency = UDim2.new(1,-20,0,20),UDim2.new(0,10,0,92),1
        st.Text,st.TextColor3,st.Font,st.TextSize = "",Color3.new(1,0.3,0.3),Enum.Font.Gotham,11
        local b = Instance.new("TextButton",f)
        b.Size,b.Position,b.BackgroundColor3 = UDim2.new(1,-30,0,36),UDim2.new(0,15,0,120),Color3.fromRGB(120,0,80)
        b.Text,b.TextColor3,b.Font,b.TextSize = "XÁC NHẬN",Color3.new(1,1,1),Enum.Font.GothamBold,13
        Instance.new("UICorner",b).CornerRadius = UDim.new(0,6)
        b.MouseButton1Click:Connect(function()
            local k = i.Text:gsub("%s+",""):upper()
            if k ~= ADMIN_KEY:upper() then st.TextColor3=Color3.new(1,0.3,0.3) st.Text="❌ sai admin" i.Text="" return end
            if adminHWIDCheck()=="mismatch" then st.TextColor3=Color3.new(1,0.3,0.3) st.Text="❌ admin dùng máy khác" i.Text="" return end
            saveAdmin()
            st.TextColor3 = Color3.new(0,1,0.3) st.Text = "✅ admin OK"
            task.wait(0.5) g:Destroy()
            -- list key
            local g2 = Instance.new("ScreenGui")
            g2.Name,g2.ResetOnSpawn,g2.IgnoreGuiInset,g2.DisplayOrder,g2.Parent = "keylistgui",false,true,2147483645,PG2
            local f2 = Instance.new("Frame",g2)
            f2.Size,f2.Position,f2.BackgroundColor3 = UDim2.new(0,320,0,400),UDim2.new(0.5,-160,0.5,-200),Color3.fromRGB(20,0,40)
            Instance.new("UICorner",f2).CornerRadius = UDim.new(0,10)
            local fs2 = Instance.new("UIStroke",f2) fs2.Color,fs2.Thickness = Color3.new(1,0,0.5),2
            local t2 = Instance.new("TextLabel",f2)
            t2.Size,t2.BackgroundColor3,t2.BorderSizePixel = UDim2.new(1,0,0,36),Color3.fromRGB(60,0,40),0
            t2.Text,t2.TextColor3,t2.Font,t2.TextSize = "📋 Danh sách key",Color3.new(1,0.3,0.6),Enum.Font.GothamBold,12
            Instance.new("UICorner",t2).CornerRadius = UDim.new(0,10)
            local cl2 = Instance.new("TextButton",f2)
            cl2.Size,cl2.Position,cl2.BackgroundColor3 = UDim2.new(0,26,0,26),UDim2.new(1,-30,0,5),Color3.fromRGB(180,50,50)
            cl2.Text,cl2.TextColor3,cl2.Font,cl2.TextSize,cl2.ZIndex = "X",Color3.new(1,1,1),Enum.Font.GothamBold,13,5
            Instance.new("UICorner",cl2).CornerRadius = UDim.new(0,6)
            cl2.MouseButton1Click:Connect(function() g2:Destroy() end)
            local st2 = Instance.new("TextLabel",f2)
            st2.Size,st2.Position,st2.BackgroundTransparency = UDim2.new(1,-20,0,24),UDim2.new(0,10,0,42),1
            st2.Text,st2.TextColor3,st2.Font,st2.TextSize = "",Color3.new(0,1,0.3),Enum.Font.GothamBold,11
            local list = Instance.new("ScrollingFrame",f2)
            list.Size,list.Position = UDim2.new(1,-20,1,-80),UDim2.new(0,10,0,70)
            list.BackgroundTransparency,list.BorderSizePixel = 1,0
            list.ScrollBarThickness = 6
            list.CanvasSize,list.AutomaticCanvasSize = UDim2.new(0,0,0,0),Enum.AutomaticSize.Y
            Instance.new("UIListLayout",list).Padding = UDim.new(0,4)
            for keyStr, days in pairs(KEYS) do
                local kb = Instance.new("TextButton",list)
                kb.Size,kb.BackgroundColor3 = UDim2.new(1,-5,0,30),Color3.fromRGB(0,40,80)
                kb.Text = "  "..keyStr.." — "..(days>=9999 and "VIP" or days.." ngày")
                kb.TextColor3,kb.Font,kb.TextSize,kb.TextXAlignment = Color3.new(0,0.78,1),Enum.Font.Gotham,11,Enum.TextXAlignment.Left
                Instance.new("UICorner",kb).CornerRadius = UDim.new(0,4)
                kb.MouseButton1Click:Connect(function()
                    writeF(HF,"") writeF(TF,tostring(os.time()))
                    if CM[keyStr] then CM[keyStr].hwid = "" writeCM(CM) end
                    st2.Text = "✅ Đã reset "..keyStr
                end)
            end
        end)
    end)

    -- Đổi key
    local swap = Instance.new("TextButton", menu)
    swap.Size, swap.BackgroundColor3 = UDim2.new(1,0,0,36), Color3.fromRGB(120,80,0)
    swap.Text, swap.TextColor3, swap.Font, swap.TextSize, swap.TextXAlignment = "  🔄 Đổi key", Color3.new(1,0.75,0), Enum.Font.GothamBold, 12, Enum.TextXAlignment.Left
    Instance.new("UICorner", swap).CornerRadius = UDim.new(0,6)
    swap.MouseButton1Click:Connect(function()
        local PG2 = LP:WaitForChild("PlayerGui")
        local o2 = PG2:FindFirstChild("swapgui") if o2 then o2:Destroy() end
        local g = Instance.new("ScreenGui")
        g.Name,g.ResetOnSpawn,g.IgnoreGuiInset,g.DisplayOrder,g.Parent = "swapgui",false,true,2147483647,PG2
        local f = Instance.new("Frame",g)
        f.Size,f.Position,f.BackgroundColor3 = UDim2.new(0,300,0,200),UDim2.new(0.5,-150,0.5,-100),Color3.fromRGB(0,20,40)
        Instance.new("UICorner",f).CornerRadius = UDim.new(0,10)
        local fs = Instance.new("UIStroke",f) fs.Color,fs.Thickness = Color3.new(1,0.6,0),2
        local t = Instance.new("TextLabel",f)
        t.Size,t.BackgroundColor3,t.BorderSizePixel = UDim2.new(1,0,0,36),Color3.fromRGB(80,40,0),0
        t.Text,t.TextColor3,t.Font,t.TextSize = "🔄 Đổi key",Color3.new(1,0.75,0),Enum.Font.GothamBold,13
        Instance.new("UICorner",t).CornerRadius = UDim.new(0,10)
        local cl = Instance.new("TextButton",f)
        cl.Size,cl.Position,cl.BackgroundColor3 = UDim2.new(0,26,0,26),UDim2.new(1,-30,0,5),Color3.fromRGB(180,50,50)
        cl.Text,cl.TextColor3,cl.Font,cl.TextSize,cl.ZIndex = "X",Color3.new(1,1,1),Enum.Font.GothamBold,13,5
        Instance.new("UICorner",cl).CornerRadius = UDim.new(0,6)
        cl.MouseButton1Click:Connect(function() g:Destroy() end)
        local info2 = Instance.new("TextLabel",f)
        info2.Size,info2.Position,info2.BackgroundTransparency = UDim2.new(1,-20,0,20),UDim2.new(0,10,0,44),1
        info2.Text = "Key: "..(getgenv().AH_Key or "chưa có")
        info2.TextColor3,info2.Font,info2.TextSize,info2.TextXAlignment = Color3.fromRGB(150,150,180),Enum.Font.Gotham,11,Enum.TextXAlignment.Left
        local i = Instance.new("TextBox",f)
        i.Size,i.Position,i.BackgroundColor3 = UDim2.new(1,-30,0,36),UDim2.new(0,15,0,70),Color3.fromRGB(10,30,60)
