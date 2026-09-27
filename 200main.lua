-- Crown Menu v7 compact | Roblox Mobile executor
local P=game:GetService("Players");local R=game:GetService("RunService")
local W=game:GetService("Workspace");local U=game:GetService("UserInputService")
local C=W.CurrentCamera;local L=P.LocalPlayer

local function fw(n,d)if writefile then pcall(writefile,n,d)end end
local function fr(n)if isfile and readfile and isfile(n)then local o,d=pcall(readfile,n)if o then return d end end return nil end

local function did()
    local i=fr("crown_device.txt");if i and #i>0 then return i end
    local s=""
    pcall(function()s=s..tostring(game.JobId or"")end)
    pcall(function()s=s..tostring(game.PlaceId or"")end)
    pcall(function()s=s..tostring(L.UserId or"")end)
    pcall(function()s=s..tostring(U.TouchEnabled)end)
    pcall(function()s=s..tostring(U.KeyboardEnabled)end)
    local h=5381
    for i=1,#s do h=((h*33)+s:byte(i))%0x7FFFFFFF end
    local r=string.format("DEV-%08X",h);fw("crown_device.txt",r);return r
end
local DEV=did()

local AK={["ADMIN-1"]=true,["ADMIN-2"]=true}
local PK={["ANHDZ-2012-Kx9@mP!vQ7#L"]=true,["ANHDZ-2012-Zt4$nB&wR6^M"]=true}
local TK={
    ["ANHDZ-2012-Yh7%cF*eD3!J"]=3600,
    ["ANHDZ-2012-Lm2@qA#pV8$N"]=86400,
    ["ANHDZ-2012-Wg5^rT!kS9&X"]=604800,
    ["ANHDZ-2012-Ub3*zE%jH6@Q"]=2592000,
    ["ANHDZ-2012-Pk8!vY$oC4^R"]=31536000,
}

local function lk()
    local d=fr("crown_keys.txt");local t={}
    if not d then return t end
    for l in d:gmatch("[^\r\n]+")do
        local k,dv,ex,du,og=l:match("^([^|]+)|([^|]*)|([^|]*)|([^|]*)|([^|]*)$")
        if k then t[k]={device=dv or"",expire=tonumber(ex)or 0,duration=du or"",originalSec=tonumber(og)or 0}end
    end
    return t
end
local function sk(t)
    local ls={}
    for k,v in pairs(t)do ls[#ls+1]=string.format("%s|%s|%d|%s|%d",k,v.device,v.expire,v.duration,v.originalSec or 0)end
    fw("crown_keys.txt",table.concat(ls,"\n"))
end
local function rk()
    local c="ABCDEFGHJKLMNPQRSTUVWXYZ23456789";local o={}
    for i=1,12 do local x=math.random(1,#c);o[#o+1]=c:sub(x,x)end
    return table.concat(o)
end
local function dl(s)
    if s==3600 then return"1 giờ"end
    if s==86400 then return"1 ngày"end
    if s==604800 then return"1 tuần"end
    if s==2592000 then return"1 tháng"end
    if s==31536000 then return"1 năm"end
    return tostring(s).."s"
end

local function ck(k)
    if AK[k]then
        local t=lk();local e=t[k]
        if not e then t[k]={device=DEV,expire=0,duration="ADMIN",originalSec=0};sk(t);return true,"ADMIN",0 end
        if e.device~=""and e.device~=DEV then return false,"Key admin đã gắn thiết bị khác"end
        if e.device==""then e.device=DEV;t[k]=e;sk(t)end
        return true,"ADMIN",0
    end
    if PK[k]then
        local t=lk();local e=t[k]
        if not e then t[k]={device=DEV,expire=0,duration="PERM",originalSec=0};sk(t);return true,"PERM",0 end
        if e.device~=""and e.device~=DEV then return false,"Key vĩnh viễn đã gắn thiết bị khác"end
        if e.device==""then e.device=DEV;t[k]=e;sk(t)end
        return true,"PERM",0
    end
    local t=lk();local e=t[k]
    if TK[k]and not e then
        t[k]={device=DEV,expire=os.time()+TK[k],duration=dl(TK[k]),originalSec=TK[k]}
        sk(t);return true,dl(TK[k]),t[k].expire
    end
    if not e then return false,"Key không tồn tại"end
    if e.expire>0 and os.time()>e.expire then return false,"Key đã hết hạn"end
    if e.device==""then e.device=DEV;t[k]=e;sk(t)elseif e.device~=DEV then return false,"Key đã dùng trên thiết bị khác"end
    return true,e.duration,e.expire
end

local function rst(k)
    local t=lk();local e=t[k]
    if AK[k]then
        if not e then return false,"Key admin chưa dùng"end
        e.device="";e.expire=0;e.originalSec=0;e.duration="ADMIN";t[k]=e;sk(t)
        return true,"Đã reset key admin"
    end
    if PK[k]then
        if not e then return false,"Key vĩnh viễn chưa dùng"end
        e.device="";e.expire=0;e.originalSec=0;e.duration="PERM";t[k]=e;sk(t)
        return true,"Đã reset key vĩnh viễn"
    end
    if TK[k]then
        if not e then return false,"Key chưa dùng"end
        local s=e.originalSec
        if not s or s<=0 then s=TK[k]end
        e.device="";e.expire=os.time()+s;e.originalSec=s;e.duration=dl(s);t[k]=e;sk(t)
        return true,"Đã reset — hạn mới: "..dl(s)
    end
    if not e then return false,"Key không tồn tại"end
    local s=e.originalSec
    if not s or s<=0 then s=86400 end
    e.device="";e.expire=os.time()+s;e.originalSec=s;t[k]=e;sk(t)
    return true,"Đã reset — hạn mới: "..dl(s)
end

local function sak(k)fw("crown_active.txt",k.."|"..DEV)end
local function cak()fw("crown_active.txt","")end
local function lak()
    local d=fr("crown_active.txt");if not d then return nil end
    local k,dv=d:match("^([^|]+)|([^|]+)$")
    if k and dv==DEV then return k end
    return nil
end

local cfg={
    espMob=true,espPlayer=true,highlight=true,showBox=true,showName=true,showDist=true,showHP=true,showTracer=true,
    maxDist=2000,
    fill=Color3.fromRGB(255,60,60),outline=Color3.fromRGB(255,0,0),nameC=Color3.fromRGB(255,220,100),
    distC=Color3.fromRGB(255,255,255),hpC=Color3.fromRGB(0,255,100),trC=Color3.fromRGB(255,255,255),
    excl={Terrain=true,Camera=true,Baseplate=true,SpawnLocation=true,Ignore=true,Debris=true},
    minParts=1,looseParts=true,skipAnchored=false,
    fly=false,flySpeed=80,vertSpeed=80,camDir=true,flyNoclip=true,
}

local mc,mh;local fBV,fBG
local mv,lv=Vector2.zero,Vector2.zero
local tr={};local upH,dnH=false,false

local function oc(ch)
    mc=ch;mh=ch:WaitForChild("HumanoidRootPart",5)
    if fBV then fBV:Destroy()fBV=nil end
    if fBG then fBG:Destroy()fBG=nil end
end
if L.Character then oc(L.Character)end
L.CharacterAdded:Connect(oc)

local function ipc(i)for _,p in ipairs(P:GetPlayers())do if p.Character==i then return true end end return false end
local function exc(n)for k in pairs(cfg.excl)do if n==k or n:find(k,1,true)then return true end end return false end
local function cp(i)local n=0 for _,c in ipairs(i:GetChildren())do if c:IsA("BasePart")then n=n+1 end end return n end

local function gb(i)
    local mn,mx
    local t=i:IsA("BasePart")and{i}or i:GetDescendants()
    for _,c in ipairs(t)do
        if c:IsA("BasePart")and c.Transparency<1 then
            local p,h=c.Position,c.Size*0.5
            local a,b=p-h,p+h
            if not mn then mn,mx=a,b else
                mn=Vector3.new(math.min(mn.X,a.X),math.min(mn.Y,a.Y),math.min(mn.Z,a.Z))
                mx=Vector3.new(math.max(mx.X,b.X),math.max(mx.Y,b.Y),math.max(mx.Z,b.Z))
            end
        end
    end
    return mn,mx
end

local function w2s(p)local s,o=C:WorldToViewportPoint(p)return Vector2.new(s.X,s.Y),o end
local function gh(i)local h=i:FindFirstChildOfClass("Humanoid")if h then return h.Health,h.MaxHealth end return nil,nil end
local function gdn(i)
    if i:IsA("Model")and ipc(i)then local pl=P:GetPlayerFromCharacter(i)if pl then return pl.Name end end
    return i.Name
end

local function isMob(i)
    if i==L.Character or ipc(i)or exc(i.Name)or not i.Parent then return false end
    if i:IsA("Model")then
        if cp(i)<cfg.minParts then return false end
        if cfg.skipAnchored then
            local a=true
            for _,c in ipairs(i:GetChildren())do if c:IsA("BasePart")and not c.Anchored then a=false break end end
            if a then return false end
        end
        return true
    end
    if i:IsA("BasePart")and cfg.looseParts then
        if i.Anchored and cfg.skipAnchored then return false end
        return true
    end
    return false
end
local function isPlyr(i)if i==L.Character then return false end return ipc(i)end

local function mv_(i)
    local v={}
    local h=Instance.new("Highlight")
    h.FillColor=cfg.fill;h.OutlineColor=cfg.outline
    h.FillTransparency=0.6;h.OutlineTransparency=0
    h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    h.Adornee=i;h.Parent=i;v.hl=h
    v.n=Drawing.new("Text")v.n.Size=14;v.n.Center=true;v.n.Outline=true;v.n.Color=cfg.nameC;v.n.Visible=false
    v.d=Drawing.new("Text")v.d.Size=13;v.d.Center=true;v.d.Outline=true;v.d.Color=cfg.distC;v.d.Visible=false
    v.hp=Drawing.new("Text")v.hp.Size=12;v.hp.Center=true;v.hp.Outline=true;v.hp.Color=cfg.hpC;v.hp.Visible=false
    v.b=Drawing.new("Square")v.b.Thickness=1;v.b.Filled=false;v.b.Transparency=1;v.b.Visible=false
    v.hb=Drawing.new("Line")v.hb.Thickness=4;v.hb.Color=Color3.fromRGB(30,30,30);v.hb.Visible=false
    v.hf=Drawing.new("Line")v.hf.Thickness=4;v.hf.Visible=false
    v.t=Drawing.new("Line")v.t.Thickness=1;v.t.Color=cfg.trC;v.t.Visible=false
    tr[i]=v
end
local function dv_(i)
    if tr[i]then
        local v=tr[i]
        if v.hl then pcall(function()v.hl:Destroy()end)end
        for _,o in ipairs({v.n,v.d,v.hp,v.b,v.hb,v.hf,v.t})do if o then pcall(function()o:Remove()end)end end
        tr[i]=nil
    end
end

local function scan()
    local fd={}
    for _,o in ipairs(W:GetDescendants())do
        local s=false
        if cfg.espMob and isMob(o)then s=true end
        if cfg.espPlayer and isPlyr(o)then s=true end
        if s then fd[o]=true;if not tr[o]then mv_(o)end end
    end
    for i in pairs(tr)do if not fd[i]or not i.Parent then dv_(i)end end
end
task.spawn(function()while task.wait(1.5)do pcall(scan)end end)
W.DescendantAdded:Connect(function(d)
    if d:IsA("Model")or d:IsA("BasePart")then
        task.wait(0.1)
        if d.Parent and not tr[d]then
            if(cfg.espMob and isMob(d))or(cfg.espPlayer and isPlyr(d))then mv_(d)end
        end
    end
end)

local function sf()
    if not mh then return end
    if fBV then fBV:Destroy()end
    if fBG then fBG:Destroy()end
    fBV=Instance.new("BodyVelocity")fBV.MaxForce=Vector3.new(1e5,1e5,1e5)fBV.Velocity=Vector3.zero;fBV.Parent=mh
    fBG=Instance.new("BodyGyro")fBG.MaxTorque=Vector3.new(1e5,1e5,1e5)fBG.P=1000;fBG.D=50;fBG.CFrame=mh.CFrame;fBG.Parent=mh
end
local function stF()
    if fBV then fBV:Destroy()fBV=nil end
    if fBG then fBG:Destroy()fBG=nil end
end
local function aNC()
    if not mc then return end
    for _,p in ipairs(mc:GetDescendants())do if p:IsA("BasePart")and p.CanCollide then p.CanCollide=false end end
end

R.RenderStepped:Connect(function()
    if cfg.fly and mh then
        if not fBV then sf()end
        local d=Vector3.zero
        if cfg.camDir then
            local f=C.CFrame
            d=d+f.LookVector*(-mv.Y)+f.RightVector*mv.X
        else
            local f=mh.CFrame
            d=d+f.LookVector*(-mv.Y)+f.RightVector*mv.X
        end
        local y=0
        if upH then y=y+1 end
        if dnH then y=y-1 end
        y=y-lv.Y
        d=d+Vector3.new(0,y,0)
        if d.Magnitude>1 then d=d.Unit end
        fBV.Velocity=Vector3.new(d.X,0,d.Z)*cfg.flySpeed+Vector3.new(0,d.Y,0)*cfg.vertSpeed
        if fBG then fBG.CFrame=CFrame.new(mh.Position,mh.Position+C.CFrame.LookVector)end
        if cfg.flyNoclip then aNC()end
    elseif fBV then stF()end

    if not mc then mc=L.Character end
    local h=mc and mc:FindFirstChild("HumanoidRootPart")
    if not h then return end
    local ctr=Vector2.new(C.ViewportSize.X/2,C.ViewportSize.Y)
    for i,v in pairs(tr)do
        local off=false
        if not i.Parent then off=true end
        local rp
        if not off then
            if i:IsA("BasePart")then rp=i.Position
            else
                local p=i:FindFirstChild("HumanoidRootPart")or i:FindFirstChild("Root")or i:FindFirstChildWhichIsA("BasePart")
                if p then rp=p.Position else off=true end
            end
        end
        if off then
            if v.hl then v.hl.Enabled=false end
            for _,o in ipairs({v.n,v.d,v.hp,v.b,v.hb,v.hf,v.t})do o.Visible=false end
        else
            local dist=(h.Position-rp).Magnitude
            local far=dist>cfg.maxDist
            local ip=isPlyr(i)
            local col=ip and Color3.fromRGB(100,200,255)or cfg.fill
            local ol=ip and Color3.fromRGB(0,150,255)or cfg.outline
            if v.hl then v.hl.Enabled=cfg.highlight and not far;v.hl.FillColor=col;v.hl.OutlineColor=ol end
            if far then
                for _,o in ipairs({v.n,v.d,v.hp,v.b,v.hb,v.hf,v.t})do o.Visible=false end
            else
                local mn,mx=gb(i)
                if not mn then
                    for _,o in ipairs({v.n,v.d,v.hp,v.b,v.hb,v.hf,v.t})do o.Visible=false end
                else
                    local cx=(mn.X+mx.X)*0.5;local cz=(mn.Z+mx.Z)*0.5
                    local ts,to=w2s(Vector3.new(cx,mx.Y,cz))
                    local bs,bo=w2s(Vector3.new(cx,mn.Y,cz))
                    if not(to and bo)then
                        for _,o in ipairs({v.n,v.d,v.hp,v.b,v.hb,v.hf,v.t})do o.Visible=false end
                    else
                        local cX=(ts.X+bs.X)*0.5
                        local hh=math.abs(bs.Y-ts.Y)
                        local ww=hh*0.6
                        if cfg.showBox and hh>4 then
                            v.b.Visible=true;v.b.Size=Vector2.new(ww,hh)
                            v.b.Position=Vector2.new(cX-ww/2,ts.Y);v.b.Color=ol
                        else v.b.Visible=false end
                        if cfg.showName then
                            v.n.Visible=true;v.n.Text=gdn(i)
                            v.n.Color=ip and Color3.fromRGB(150,220,255)or cfg.nameC
                            v.n.Position=Vector2.new(cX,ts.Y-18)
                        else v.n.Visible=false end
                        if cfg.showDist then
                            v.d.Visible=true;v.d.Text=string.format("[%d]",math.floor(dist))
                            v.d.Position=Vector2.new(cX,bs.Y+4)
                        else v.d.Visible=false end
                        local hp,mhp=gh(i)
                        if cfg.showHP and hp and mhp and mhp>0 then
                            local pct=math.clamp(hp/mhp,0,1)
                            v.hp.Visible=true;v.hp.Text=string.format("%d/%d",math.floor(hp),math.floor(mhp))
                            v.hp.Position=Vector2.new(cX,bs.Y+18)
                            v.hp.Color=Color3.fromRGB(math.floor(255*(1-pct)),math.floor(255*pct),60)
                            local bx=cX-ww/2-8
                            v.hb.Visible=true;v.hb.From=Vector2.new(bx,ts.Y+hh);v.hb.To=Vector2.new(bx,ts.Y)
                            local bh=hh*pct
                            v.hf.Visible=true;v.hf.From=Vector2.new(bx,ts.Y+hh);v.hf.To=Vector2.new(bx,ts.Y+hh-bh)
                            v.hf.Color=Color3.fromRGB(math.floor(255*(1-pct)),math.floor(255*pct),60)
                        else v.hp.Visible=false;v.hf.Visible=false;v.hb.Visible=false end
                        if cfg.showTracer then
                            v.t.Visible=true;v.t.From=ctr;v.t.To=Vector2.new(cX,bs.Y)
                            v.t.Color=ip and Color3.fromRGB(100,200,255)or cfg.trC
                        else v.t.Visible=false end
                    end
                end
            end
        end
    end
end)

local function build(auth)
    local g=Instance.new("ScreenGui")g.Name="CrownMenu";g.ResetOnSpawn=false;g.IgnoreGuiInset=true;g.DisplayOrder=9999
    pcall(function()g.Parent=game:GetService("CoreGui")end)
    if not g.Parent then g.Parent=L:WaitForChild("PlayerGui")end
    local DP=UDim2.new(0,20,0,60)
    local logLock=false;local mnuLock=false

    local lg=Instance.new("TextButton")lg.Size=UDim2.new(0,50,0,50);lg.Position=DP
    lg.BackgroundColor3=Color3.fromRGB(35,25,10);lg.BorderSizePixel=2;lg.BorderColor3=Color3.fromRGB(255,215,0)
    lg.Text="👑";lg.TextColor3=Color3.fromRGB(255,215,0);lg.Font=Enum.Font.GothamBold;lg.TextSize=28
    lg.AutoButtonColor=false;lg.Visible=false;lg.Active=true;lg.Parent=g
    local lc=Instance.new("UICorner")lc.CornerRadius=UDim.new(0.5,0);lc.Parent=lg
    local ls=Instance.new("UIStroke")ls.Color=Color3.fromRGB(255,215,0);ls.Thickness=1.5;ls.Transparency=0.3;ls.Parent=lg

    local fr_=Instance.new("Frame")fr_.Size=UDim2.new(0,230,0,380);fr_.Position=DP
    fr_.BackgroundColor3=Color3.fromRGB(15,18,25);fr_.BorderSizePixel=0;fr_.Active=true;fr_.Parent=g
    local fc=Instance.new("UICorner")fc.CornerRadius=UDim.new(0,8);fc.Parent=fr_
    local fs=Instance.new("UIStroke")fs.Color=Color3.fromRGB(255,215,0);fs.Thickness=1;fs.Transparency=0.5;fs.Parent=fr_

    local tt=Instance.new("Frame")tt.Size=UDim2.new(1,0,0,40)
    tt.BackgroundColor3=Color3.fromRGB(30,25,10);tt.BorderSizePixel=0;tt.Parent=fr_
    local tc_=Instance.new("UICorner")tc_.CornerRadius=UDim.new(0,8);tc_.Parent=tt

    local ll=Instance.new("TextLabel")ll.Size=UDim2.new(0,36,1,0);ll.Position=UDim2.new(0,4,0,0)
    ll.BackgroundTransparency=1;ll.Text="👑";ll.TextColor3=Color3.fromRGB(255,215,0)
    ll.Font=Enum.Font.GothamBold;ll.TextSize=22;ll.Parent=tt

    local nl=Instance.new("TextLabel")nl.Size=UDim2.new(1,-100,1,0);nl.Position=UDim2.new(0,42,0,0)
    nl.BackgroundTransparency=1;nl.Text="CROWN";nl.TextColor3=Color3.fromRGB(255,215,0)
    nl.Font=Enum.Font.GothamBold;nl.TextSize=14;nl.TextXAlignment=Enum.TextXAlignment.Left;nl.Parent=tt

    local lkb=Instance.new("TextButton")lkb.Size=UDim2.new(0,26,0,26);lkb.Position=UDim2.new(1,-62,0,7)
    lkb.BackgroundColor3=Color3.fromRGB(40,40,60);lkb.BorderSizePixel=0;lkb.Text="🔓"
    lkb.TextColor3=Color3.fromRGB(255,255,255);lkb.Font=Enum.Font.GothamBold;lkb.TextSize=13
    lkb.AutoButtonColor=false;lkb.Parent=tt
    local lkc=Instance.new("UICorner")lkc.CornerRadius=UDim.new(0,5);lkc.Parent=lkb

    local cl=Instance.new("TextButton")cl.Size=UDim2.new(0,26,0,26);cl.Position=UDim2.new(1,-32,0,7)
    cl.BackgroundColor3=Color3.fromRGB(60,30,30);cl.BorderSizePixel=0;cl.Text="−"
    cl.TextColor3=Color3.fromRGB(255,255,255);cl.Font=Enum.Font.GothamBold;cl.TextSize=16
    cl.AutoButtonColor=false;cl.Parent=tt
    local clc=Instance.new("UICorner")clc.CornerRadius=UDim.new(0,5);clc.Parent=cl

    local sc=Instance.new("ScrollingFrame")sc.Size=UDim2.new(1,-4,1,-46);sc.Position=UDim2.new(0,2,0,44)
    sc.BackgroundTransparency=1;sc.BorderSizePixel=0;sc.ScrollBarThickness=8
    sc.ScrollBarImageColor3=Color3.fromRGB(255,215,0);sc.CanvasSize=UDim2.new(0,0,0,0)
    sc.AutomaticCanvasSize=Enum.AutomaticSize.Y;sc.ScrollingDirection=Enum.ScrollingDirection.Y
    sc.ScrollingEnabled=true;sc.Active=true;sc.ClipsDescendants=true
    sc.ElasticBehavior=Enum.ElasticBehavior.Never;sc.Parent=fr_
    local sl=Instance.new("UIListLayout")sl.SortOrder=Enum.SortOrder.LayoutOrder;sl.Padding=UDim.new(0,3);sl.Parent=sc
    local sp=Instance.new("UIPadding")sp.PaddingTop=UDim.new(0,4);sp.PaddingLeft=UDim.new(0,4)
    sp.PaddingRight=UDim.new(0,4);sp.PaddingBottom=UDim.new(0,8);sp.Parent=sc

    local function pg(o,p)
        local a,b=o.AbsolutePosition,o.AbsoluteSize
        return p.X>=a.X and p.X<=a.X+b.X and p.Y>=a.Y and p.Y<=a.Y+b.Y
    end

    local dg=false;local ds=Vector2.zero;local sp2=UDim2.new(0,0,0,0);local at=nil
    U.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
            if pg(tt,i.Position)and not pg(lkb,i.Position)and not pg(cl,i.Position)then
                if mnuLock then return end
                dg=true;ds=i.Position;sp2=fr_.Position;at=i
            end
        end
    end)
    U.InputChanged:Connect(function(i)
        if not dg or i~=at or mnuLock then return end
        if i.UserInputType~=Enum.UserInputType.Touch and i.UserInputType~=Enum.UserInputType.MouseMovement then return end
        local d=i.Position-ds
        fr_.Position=UDim2.new(sp2.X.Scale,sp2.X.Offset+d.X,sp2.Y.Scale,sp2.Y.Offset+d.Y)
    end)
    U.InputEnded:Connect(function(i)if dg and i==at then dg=false;at=nil end end)

    local lgd=false;local lgs=Vector2.zero;local lsp=UDim2.new(0,0,0,0);local lat=nil;local lmv=false
    lkb.MouseButton1Click:Connect(function()
        logLock=not logLock;mnuLock=logLock
        lkb.Text=logLock and "🔒"or "🔓"
        lkb.BackgroundColor3=logLock and Color3.fromRGB(150,40,40)or Color3.fromRGB(40,40,60)
    end)
    U.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
            if lg.Visible and pg(lg,i.Position)then
                if logLock then lgd=false;lat=i;lmv=false;lsp=lg.Position;return end
                lgd=true;lgs=i.Position;lsp=lg.Position;lat=i;lmv=false
            end
        end
    end)
    U.InputChanged:Connect(function(i)
        if not lgd or logLock or i~=lat then return end
        if i.UserInputType~=Enum.UserInputType.Touch and i.UserInputType~=Enum.UserInputType.MouseMovement then return end
        local d=i.Position-lgs
        if d.Magnitude>8 then lmv=true end
        lg.Position=UDim2.new(lsp.X.Scale,lsp.X.Offset+d.X,lsp.Y.Scale,lsp.Y.Offset+d.Y)
    end)
    U.InputEnded:Connect(function(i)
        if lat~=i then return end
        if logLock or not lmv then
            fr_.Visible=true;lg.Visible=false;fr_.Position=lg.Position
        end
        lgd=false;lat=nil
    end)
    cl.MouseButton1Click:Connect(function()
        lg.Position=fr_.Position;fr_.Visible=false;lg.Visible=true
    end)

    local function mkT(lb,k,oc2)
        local b=Instance.new("TextButton")b.Size=UDim2.new(1,-4,0,30)
        b.BackgroundColor3=cfg[k]and(oc2 or Color3.fromRGB(140,100,20))or Color3.fromRGB(45,45,55)
        b.BorderSizePixel=0;b.Text=lb;b.TextColor3=Color3.fromRGB(255,255,255)
        b.Font=Enum.Font.GothamBold;b.TextSize=12;b.Parent=sc
        local bc=Instance.new("UICorner")bc.CornerRadius=UDim.new(0,5);bc.Parent=b
        b.MouseButton1Click:Connect(function()
            cfg[k]=not cfg[k]
            b.BackgroundColor3=cfg[k]and(oc2 or Color3.fromRGB(140,100,20))or Color3.fromRGB(45,45,55)
        end)
        return b
    end
    local function mkH(t,c)
        local h=Instance.new("TextLabel")h.Size=UDim2.new(1,-4,0,20);h.BackgroundTransparency=1
        h.Text=t;h.TextColor3=c or Color3.fromRGB(255,215,0);h.Font=Enum.Font.GothamBold
        h.TextSize=11;h.TextXAlignment=Enum.TextXAlignment.Left;h.Parent=sc;return h
    end
    local function mkS(lb,k,mn,mx)
        local w=Instance.new("Frame")w.Size=UDim2.new(1,-4,0,38);w.BackgroundTransparency=1;w.Parent=sc
        local l=Instance.new("TextLabel")l.Size=UDim2.new(1,0,0,16);l.BackgroundTransparency=1
        l.Text=lb..": "..cfg[k];l.TextColor3=Color3.fromRGB(200,200,200);l.Font=Enum.Font.Gotham
        l.TextSize=10;l.TextXAlignment=Enum.TextXAlignment.Left;l.Parent=w
        local b=Instance.new("Frame")b.Size=UDim2.new(1,0,0,20);b.Position=UDim2.new(0,0,0,16)
        b.BackgroundColor3=Color3.fromRGB(40,40,55);b.BorderSizePixel=0;b.Parent=w
        local bc=Instance.new("UICorner")bc.CornerRadius=UDim.new(0,4);bc.Parent=b
        local f=Instance.new("Frame")f.Size=UDim2.new((cfg[k]-mn)/(mx-mn),0,1,0)
        f.BackgroundColor3=Color3.fromRGB(255,215,0);f.BorderSizePixel=0;f.Parent=b
        local fc2=Instance.new("UICorner")fc2.CornerRadius=UDim.new(0,4);fc2.Parent=f
        local ds2=false;local ts=nil
        local function sfx(x)
            local r=math.clamp((x-b.AbsolutePosition.X)/b.AbsoluteSize.X,0,1)
            local v=math.floor(mn+(mx-mn)*r)
            cfg[k]=v;f.Size=UDim2.new(r,0,1,0);l.Text=lb..": "..v
        end
        U.InputBegan:Connect(function(i)
            if(i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1)and pg(b,i.Position)then
                ds2=true;ts=i;sfx(i.Position.X)
            end
        end)
        U.InputChanged:Connect(function(i)if ds2 and i==ts then sfx(i.Position.X)end end)
        U.InputEnded:Connect(function(i)if ds2 and i==ts then ds2=false;ts=nil end end)
    end

    mkH("◆ ESP")
    mkT("ESP Quái","espMob");mkT("ESP Người","espPlayer")
    mkT("Highlight","highlight");mkT("Box","showBox");mkT("Tên","showName")
    mkT("Khoảng cách","showDist");mkT("Số máu","showHP");mkT("Tracer","showTracer")

    mkH("◆ FLY")
    mkT("FLY ON/OFF","fly");mkT("Xuyên tường","flyNoclip")

    local db=Instance.new("TextButton")db.Size=UDim2.new(1,-4,0,26)
    db.BackgroundColor3=Color3.fromRGB(60,60,90);db.BorderSizePixel=0
    db.Text=cfg.camDir and "Bay theo Camera"or "Bay theo Nhân vật"
    db.TextColor3=Color3.fromRGB(255,255,255);db.Font=Enum.Font.Gotham;db.TextSize=11;db.Parent=sc
    local dc=Instance.new("UICorner")dc.CornerRadius=UDim.new(0,5);dc.Parent=db
    db.MouseButton1Click:Connect(function()
        cfg.camDir=not cfg.camDir
        db.Text=cfg.camDir and "Bay theo Camera"or "Bay theo Nhân vật"
    end)
    mkS("Tốc độ bay","flySpeed",20,500)
    mkS("Tốc độ lên/xuống","vertSpeed",20,500)

    mkH("◆ ADMIN")
    local cB=Instance.new("TextButton")cB.Size=UDim2.new(1,-4,0,32)
    cB.BackgroundColor3=Color3.fromRGB(40,120,60);cB.BorderSizePixel=0;cB.Text="➕ TẠO KEY MỚI"
    cB.TextColor3=Color3.fromRGB(255,255,255);cB.Font=Enum.Font.GothamBold;cB.TextSize=12;cB.Parent=sc
    local cBc=Instance.new("UICorner")cBc.CornerRadius=UDim.new(0,5);cBc.Parent=cB

    local chB=Instance.new("TextButton")chB.Size=UDim2.new(1,-4,0,32)
    chB.BackgroundColor3=Color3.fromRGB(180,120,40);chB.BorderSizePixel=0;chB.Text="🔄 ĐỔI KEY (RESET)"
    chB.TextColor3=Color3.fromRGB(255,255,255);chB.Font=Enum.Font.GothamBold;chB.TextSize=12;chB.Parent=sc
    local chBc=Instance.new("UICorner")chBc.CornerRadius=UDim.new(0,5);chBc.Parent=chB

    local lkB=Instance.new("TextButton")lkB.Size=UDim2.new(1,-4,0,32)
    lkB.BackgroundColor3=Color3.fromRGB(60,60,100);lkB.BorderSizePixel=0;lkB.Text="📋 DANH SÁCH KEY"
    lkB.TextColor3=Color3.fromRGB(255,255,255);lkB.Font=Enum.Font.GothamBold;lkB.TextSize=12;lkB.Parent=sc
    local lkBc=Instance.new("UICorner")lkBc.CornerRadius=UDim.new(0,5);lkBc.Parent=lkB

    local adm=false
    local function isAdm()return adm end
    local function reqAdm(cb)
        local pg2=Instance.new("ScreenGui")pg2.Name="AdminPrompt";pg2.ResetOnSpawn=false
        pg2.IgnoreGuiInset=true;pg2.DisplayOrder=10001
        pcall(function()pg2.Parent=game:GetService("CoreGui")end)
        if not pg2.Parent then pg2.Parent=L:WaitForChild("PlayerGui")end
        local b=Instance.new("Frame")b.Size=UDim2.new(0,300,0,240);b.Position=UDim2.new(0.5,-150,0.5,-120)
        b.BackgroundColor3=Color3.fromRGB(25,10,10);b.BorderSizePixel=0;b.Active=true;b.Parent=pg2
        local bc=Instance.new("UICorner")bc.CornerRadius=UDim.new(0,10);bc.Parent=b
        local bs=Instance.new("UIStroke")bs.Color=Color3.fromRGB(255,100,100);bs.Thickness=2;bs.Parent=b
        local ti=Instance.new("TextLabel")ti.Size=UDim2.new(1,0,0,50);ti.BackgroundTransparency=1
        ti.Text="🔐 XÁC THỰC ADMIN";ti.TextColor3=Color3.fromRGB(255,100,100)
        ti.Font=Enum.Font.GothamBold;ti.TextSize=18;ti.Parent=b
        local sb=Instance.new("TextLabel")sb.Size=UDim2.new(1,-20,0,30);sb.Position=UDim2.new(0,10,0,50)
        sb.BackgroundTransparency=1;sb.Text="Chức năng này cần key admin.\nNhập key admin để tiếp tục:"
        sb.TextColor3=Color3.fromRGB(200,200,200);sb.Font=Enum.Font.Gotham;sb.TextSize=11
        sb.TextWrapped=true;sb.Parent=b
        local inp=Instance.new("TextBox")inp.Size=UDim2.new(1,-40,0,40);inp.Position=UDim2.new(0,20,0,88)
        inp.BackgroundColor3=Color3.fromRGB(40,25,25);inp.BorderSizePixel=0;inp.Text=""
        inp.PlaceholderText="Nhập key admin...";inp.TextColor3=Color3.fromRGB(255,255,255)
        inp.PlaceholderColor3=Color3.fromRGB(120,100,100);inp.Font=Enum.Font.Gotham
        inp.TextSize=13;inp.ClearTextOnFocus=false;inp.Parent=b
        local ic=Instance.new("UICorner")ic.CornerRadius=UDim.new(0,6);ic.Parent=inp
        local bt=Instance.new("TextButton")bt.Size=UDim2.new(1,-40,0,40);bt.Position=UDim2.new(0,20,0,138)
        bt.BackgroundColor3=Color3.fromRGB(180,40,40);bt.BorderSizePixel=0;bt.Text="XÁC NHẬN"
        bt.TextColor3=Color3.fromRGB(255,255,255);bt.Font=Enum.Font.GothamBold;bt.TextSize=14;bt.Parent=b
        local btc=Instance.new("UICorner")btc.CornerRadius=UDim.new(0,6);btc.Parent=bt
        local cn=Instance.new("TextButton")cn.Size=UDim2.new(1,-40,0,26);cn.Position=UDim2.new(0,20,0,184)
        cn.BackgroundColor3=Color3.fromRGB(50,50,60);cn.BorderSizePixel=0;cn.Text="Hủy"
        cn.TextColor3=Color3.fromRGB(200,200,200);cn.Font=Enum.Font.Gotham;cn.TextSize=12;cn.Parent=b
        local cnc=Instance.new("UICorner")cnc.CornerRadius=UDim.new(0,5);cnc.Parent=cn
        local st=Instance.new("TextLabel")st.Size=UDim2.new(1,-40,0,20);st.Position=UDim2.new(0,20,0,214)
        st.BackgroundTransparency=1;st.Text="";st.TextColor3=Color3.fromRGB(255,100,100)
        st.Font=Enum.Font.Gotham;st.TextSize=11;st.Parent=b
        local function vf()
            local k=inp.Text:match("^%s*(.-)%s*$")
            if k==""then st.Text="Vui lòng nhập key admin";return end
            if AK[k]then
                local t=lk();local e=t[k]
                if not e then t[k]={device=DEV,expire=0,duration="ADMIN",originalSec=0};sk(t)
                elseif e.device~=""and e.device~=DEV then st.TextColor3=Color3.fromRGB(255,100,100);st.Text="✗ Key admin đã gắn thiết bị khác";return
                elseif e.device==""then e.device=DEV;t[k]=e;sk(t)end
                adm=true;st.TextColor3=Color3.fromRGB(150,255,150);st.Text="✓ Xác thực thành công"
                task.wait(0.4);pg2:Destroy();cb()
            else st.TextColor3=Color3.fromRGB(255,100,100);st.Text="✗ Key admin không đúng"end
        end
        bt.MouseButton1Click:Connect(vf)
        cn.MouseButton1Click:Connect(function()pg2:Destroy()end)
        inp.FocusLost:Connect(function(en)if en then vf()end end)
    end
    local function wAdm(fn)if isAdm()then fn()else reqAdm(fn)end end

    local function mkP(ti,tc)
        local p=Instance.new("Frame")p.Size=UDim2.new(0,290,0,480);p.Position=UDim2.new(0.5,-145,0.5,-240)
        p.BackgroundColor3=Color3.fromRGB(20,15,15);p.BorderSizePixel=0;p.Active=true;p.Parent=g
        local pc=Instance.new("UICorner")pc.CornerRadius=UDim.new(0,8);pc.Parent=p
        local ps=Instance.new("UIStroke")ps.Color=tc;ps.Thickness=2;ps.Parent=p
        local pt=Instance.new("TextLabel")pt.Size=UDim2.new(1,0,0,40);pt.BackgroundColor3=Color3.fromRGB(60,20,20)
        pt.BorderSizePixel=0;pt.Text=ti;pt.TextColor3=tc;pt.Font=Enum.Font.GothamBold
        pt.TextSize=15;pt.Parent=p
        local ptc=Instance.new("UICorner")ptc.CornerRadius=UDim.new(0,8);ptc.Parent=pt
        local cx=Instance.new("TextButton")cx.Size=UDim2.new(0,32,0,32);cx.Position=UDim2.new(1,-38,0,4)
        cx.BackgroundColor3=Color3.fromRGB(150,40,40);cx.BorderSizePixel=0;cx.Text="✕"
        cx.TextColor3=Color3.fromRGB(255,255,255);cx.Font=Enum.Font.GothamBold
        cx.TextSize=16;cx.AutoButtonColor=false;cx.Parent=p
        local cxc=Instance.new("UICorner")cxc.CornerRadius=UDim.new(0,5);cxc.Parent=cx
        cx.MouseButton1Click:Connect(function()p:Destroy()end)
        local sc2=Instance.new("ScrollingFrame")sc2.Size=UDim2.new(1,-8,1,-48);sc2.Position=UDim2.new(0,4,0,44)
        sc2.BackgroundTransparency=1;sc2.BorderSizePixel=0;sc2.ScrollBarThickness=6
        sc2.ScrollBarImageColor3=tc;sc2.CanvasSize=UDim2.new(0,0,0,0)
        sc2.AutomaticCanvasSize=Enum.AutomaticSize.Y;sc2.ScrollingEnabled=true;sc2.Active=true;sc2.Parent=p
        local pl=Instance.new("UIListLayout")pl.SortOrder=Enum.SortOrder.LayoutOrder;pl.Padding=UDim.new(0,6);pl.Parent=sc2
        local pp=Instance.new("UIPadding")pp.PaddingTop=UDim.new(0,4);pp.PaddingLeft=UDim.new(0,4)
        pp.PaddingRight=UDim.new(0,4);pp.PaddingBottom=UDim.new(0,8);pp.Parent=sc2
        return p,sc2
    end

    cB.MouseButton1Click:Connect(function()
        wAdm(function()
            local p,ps=mkP("➕ TẠO KEY MỚI",Color3.fromRGB(80,200,100))
            local dt=Instance.new("TextLabel")dt.Size=UDim2.new(1,0,0,18);dt.BackgroundTransparency=1
            dt.Text="─── Chọn thời hạn ───";dt.TextColor3=Color3.fromRGB(255,180,100)
            dt.Font=Enum.Font.GothamBold;dt.TextSize=12;dt.Parent=ps
            local sd=3600;local dbtns={}
            local durs={{l="1 Giờ",s=3600},{l="1 Ngày",s=86400},{l="1 Tuần",s=604800},{l="1 Tháng",s=2592000},{l="1 Năm",s=31536000}}
            local dr=Instance.new("Frame")dr.Size=UDim2.new(1,0,0,100);dr.BackgroundTransparency=1;dr.Parent=ps
            local dg2=Instance.new("UIGridLayout")dg2.CellSize=UDim2.new(0.5,-4,0,30)
            dg2.CellPadding=UDim2.new(0,4,0,4);dg2.Parent=dr
            local function upH2()for _,x in ipairs(dbtns)do x.b.BackgroundColor3=(x.s==sd)and Color3.fromRGB(200,100,20)or Color3.fromRGB(60,60,60)end end
            for _,d in ipairs(durs)do
                local b=Instance.new("TextButton")b.BackgroundColor3=Color3.fromRGB(60,60,60)
                b.BorderSizePixel=0;b.Text=d.l;b.TextColor3=Color3.fromRGB(255,255,255)
                b.Font=Enum.Font.GothamBold;b.TextSize=12;b.Parent=dr
                local bc=Instance.new("UICorner")bc.CornerRadius=UDim.new(0,5);bc.Parent=b
                b.MouseButton1Click:Connect(function()sd=d.s;upH2()end)
                table.insert(dbtns,{b=b,s=d.s})
            end
            upH2()
            local il=Instance.new("TextLabel")il.Size=UDim2.new(1,0,0,18);il.BackgroundTransparency=1
            il.Text="Nhập key (trống = random 12 ký tự):";il.TextColor3=Color3.fromRGB(220,220,220)
            il.Font=Enum.Font.Gotham;il.TextSize=11;il.TextXAlignment=Enum.TextXAlignment.Left;il.Parent=ps
            local inp=Instance.new("TextBox")inp.Size=UDim2.new(1,0,0,32)
            inp.BackgroundColor3=Color3.fromRGB(40,40,50);inp.BorderSizePixel=0;inp.Text=""
            inp.PlaceholderText="VD: ANHDZ-2012-xxxx";inp.TextColor3=Color3.fromRGB(255,255,255)
            inp.PlaceholderColor3=Color3.fromRGB(120,120,120);inp.Font=Enum.Font.Gotham
            inp.TextSize=13;inp.ClearTextOnFocus=false;inp.Parent=ps
            local ic=Instance.new("UICorner")ic.CornerRadius=UDim.new(0,5);ic.Parent=inp
            local rb=Instance.new("TextButton")rb.Size=UDim2.new(1,0,0,30)
            rb.BackgroundColor3=Color3.fromRGB(60,90,60);rb.BorderSizePixel=0;rb.Text="🎲 Random 12 ký tự"
            rb.TextColor3=Color3.fromRGB(255,255,255);rb.Font=Enum.Font.GothamBold
            rb.TextSize=12;rb.Parent=ps
            local rbc=Instance.new("UICorner")rbc.CornerRadius=UDim.new(0,5);rbc.Parent=rb
            rb.MouseButton1Click:Connect(function()inp.Text=rk()end)
            local cb2=Instance.new("TextButton")cb2.Size=UDim2.new(1,0,0,40)
            cb2.BackgroundColor3=Color3.fromRGB(40,150,60);cb2.BorderSizePixel=0;cb2.Text="✓ TẠO KEY"
            cb2.TextColor3=Color3.fromRGB(255,255,255);cb2.Font=Enum.Font.GothamBold
            cb2.TextSize=14;cb2.Parent=ps
            local cbc2=Instance.new("UICorner")cbc2.CornerRadius=UDim.new(0,5);cbc2.Parent=cb2
            local lg2=Instance.new("TextLabel")lg2.Size=UDim2.new(1,0,0,80)
            lg2.BackgroundTransparency=1;lg2.Text="";lg2.TextColor3=Color3.fromRGB(150,255,150)
            lg2.Font=Enum.Font.Gotham;lg2.TextSize=11;lg2.TextWrapped=true
            lg2.TextXAlignment=Enum.TextXAlignment.Left;lg2.TextYAlignment=Enum.TextYAlignment.Top;lg2.Parent=ps
            cb2.MouseButton1Click:Connect(function()
                local k=inp.Text:match("^%s*(.-)%s*$")
                if k==""then k=rk()end
                if #k<6 then lg2.TextColor3=Color3.fromRGB(255,100,100);lg2.Text="✗ Key phải có ít nhất 6 ký tự";return end
                local t=lk()
                if t[k]or AK[k]or PK[k]then lg2.TextColor3=Color3.fromRGB(255,100,100);lg2.Text="✗ Key đã tồn tại";return end
                t[k]={device="",expire=os.time()+sd,duration=dl(sd),originalSec=sd}
                sk(t);lg2.TextColor3=Color3.fromRGB(150,255,150)
                lg2.Text="✓ Đã tạo: "..k.."\nHạn: "..dl(sd);inp.Text=""
            end)
        end)
    end)

    chB.MouseButton1Click:Connect(function()
        wAdm(function()
            local p,ps=mkP("🔄 ĐỔI KEY (RESET)",Color3.fromRGB(255,180,80))
            local ib=Instance.new("TextLabel")ib.Size=UDim2.new(1,0,0,70)
            ib.BackgroundColor3=Color3.fromRGB(40,30,15);ib.BorderSizePixel=0
            ib.Text="Reset key = xóa liên kết thiết bị\n+ đặt lại thời gian ban đầu\n\n• Key admin reset được\n• Key vĩnh viễn reset được\n• Key có hạn reset được"
            ib.TextColor3=Color3.fromRGB(255,220,150);ib.Font=Enum.Font.Gotham
            ib.TextSize=10;ib.TextWrapped=true;ib.Parent=ps
            local ibc=Instance.new("UICorner")ibc.CornerRadius=UDim.new(0,5);ibc.Parent=ib
            local rt=Instance.new("TextLabel")rt.Size=UDim2.new(1,0,0,20);rt.BackgroundTransparency=1
            rt.Text="─── Nhập key cần reset ───";rt.TextColor3=Color3.fromRGB(255,180,100)
            rt.Font=Enum.Font.GothamBold;rt.TextSize=12;rt.Parent=ps
            local ri=Instance.new("TextBox")ri.Size=UDim2.new(1,0,0,32)
            ri.BackgroundColor3=Color3.fromRGB(40,40,50);ri.BorderSizePixel=0;ri.Text=""
            ri.PlaceholderText="Paste key vào đây...";ri.TextColor3=Color3.fromRGB(255,255,255)
            ri.PlaceholderColor3=Color3.fromRGB(120,120,120);ri.Font=Enum.Font.Gotham
            ri.TextSize=12;ri.ClearTextOnFocus=false;ri.Parent=ps
            local ric=Instance.new("UICorner")ric.CornerRadius=UDim.new(0,5);ric.Parent=ri
            local rB=Instance.new("TextButton")rB.Size=UDim2.new(1,0,0,40)
            rB.BackgroundColor3=Color3.fromRGB(200,100,30);rB.BorderSizePixel=0;rB.Text="↺ RESET KEY"
            rB.TextColor3=Color3.fromRGB(255,255,255);rB.Font=Enum.Font.GothamBold
            rB.TextSize=14;rB.Parent=ps
            local rBc=Instance.new("UICorner")rBc.CornerRadius=UDim.new(0,5);rBc.Parent=rB
            local rl=Instance.new("TextLabel")rl.Size=UDim2.new(1,0,0,80)
            rl.BackgroundTransparency=1;rl.Text="";rl.TextColor3=Color3.fromRGB(255,200,100)
            rl.Font=Enum.Font.Gotham;rl.TextSize=12;rl.TextWrapped=true
            rl.TextXAlignment=Enum.TextXAlignment.Left;rl.TextYAlignment=Enum.TextYAlignment.Top;rl.Parent=ps
            rB.MouseButton1Click:Connect(function()
                local k=ri.Text:match("^%s*(.-)%s*$")
                if k==""then rl.TextColor3=Color3.fromRGB(255,100,100);rl.Text="✗ Chưa nhập key";return end
                local ok,msg=rst(k)
                if ok then rl.TextColor3=Color3.fromRGB(150,255,150);rl.Text="✓ "..msg;ri.Text=""
                else rl.TextColor3=Color3.fromRGB(255,100,100);rl.Text="✗ "..msg end
            end)
        end)
    end)

    lkB.MouseButton1Click:Connect(function()
        wAdm(function()
            local p,ps=mkP("📋 DANH SÁCH KEY",Color3.fromRGB(150,150,255))
            local function rl2()
                for _,c in ipairs(ps:GetChildren())do
                    if(c:IsA("TextLabel")or c:IsA("TextButton"))and c.Name~="RefreshBtn"then c:Destroy()end
                end
                local t=lk();local nw=os.time();local ak={}
                for k in pairs(AK)do ak[k]=t[k]or{device="",expire=0,duration="ADMIN",originalSec=0}end
                for k in pairs(PK)do ak[k]=t[k]or{device="",expire=0,duration="PERM",originalSec=0}end
                for k,s in pairs(TK)do ak[k]=t[k]or{device="",expire=0,duration=dl(s).." (chưa dùng)",originalSec=s}end
                for k,v in pairs(t)do if not ak[k]then ak[k]=v end end
                local cnt=0
                for _ in pairs(ak)do cnt=cnt+1 end
                if cnt==0 then
                    local em=Instance.new("TextLabel")em.Size=UDim2.new(1,0,0,40)
                    em.BackgroundTransparency=1;em.Text="Chưa có key nào";em.TextColor3=Color3.fromRGB(180,180,180)
                    em.Font=Enum.Font.Gotham;em.TextSize=12;em.Parent=ps;return
                end
                for k,info in pairs(ak)do
                    local tl=""
                    if info.expire>0 then
                        local lf=info.expire-nw
                        if lf<=0 then tl="HẾT HẠN"else
                            local h=math.floor(lf/3600);local d=math.floor(h/24)
                            if d>0 then tl=d.."d "..(h%24).."h"
                            elseif h>0 then tl=h.."h "..math.floor((lf%3600)/60).."m"
                            else tl=math.floor(lf/60).." phút"end
                        end
                    else tl="Vĩnh viễn"end
                    local di="chưa dùng"
                    if info.device and info.device~=""then
                        if info.device==DEV then di="máy này"else di="máy khác"end
                    end
                    local cd=Instance.new("TextButton")cd.Size=UDim2.new(1,0,0,58)
                    cd.BackgroundColor3=Color3.fromRGB(30,30,45);cd.BorderSizePixel=0
                    cd.Text="";cd.AutoButtonColor=false;cd.Parent=ps
                    local cdc=Instance.new("UICorner")cdc.CornerRadius=UDim.new(0,5);cdc.Parent=cd
                    local kl=Instance.new("TextLabel")kl.Size=UDim2.new(1,-60,0,20)
                    kl.Position=UDim2.new(0,5,0,2);kl.BackgroundTransparency=1;kl.Text=k
                    kl.TextColor3=Color3.fromRGB(255,215,0);kl.Font=Enum.Font.Code;kl.TextSize=10
                    kl.TextXAlignment=Enum.TextXAlignment.Left;kl.TextTruncate=Enum.TextTruncate.AtEnd;kl.Parent=cd
                    local tyl=Instance.new("TextLabel")tyl.Size=UDim2.new(1,-10,0,14)
                    tyl.Position=UDim2.new(0,5,0,22);tyl.BackgroundTransparency=1
                    tyl.Text="Loại: "..info.duration.." | Hạn: "..tl;tyl.TextColor3=Color3.fromRGB(180,180,180)
                    tyl.Font=Enum.Font.Gotham;tyl.TextSize=9;tyl.TextXAlignment=Enum.TextXAlignment.Left;tyl.Parent=cd
                    local dvl=Instance.new("TextLabel")dvl.Size=UDim2.new(1,-10,0,14)
                    dvl.Position=UDim2.new(0,5,0,36);dvl.BackgroundTransparency=1
                    dvl.Text="Thiết bị: "..di;dvl.TextColor3=Color3.fromRGB(200,200,100)
                    dvl.Font=Enum.Font.Gotham;dvl.TextSize=9;dvl.TextXAlignment=Enum.TextXAlignment.Left;dvl.Parent=cd
                    local cp=Instance.new("TextButton")cp.Size=UDim2.new(0,46,0,20)
                    cp.Position=UDim2.new(1,-50,0,2);cp.BackgroundColor3=Color3.fromRGB(60,60,100)
                    cp.BorderSizePixel=0;cp.Text="Copy";cp.TextColor3=Color3.fromRGB(255,255,255)
                    cp.Font=Enum.Font.GothamBold;cp.TextSize=10;cp.Parent=cd
                    local cpc=Instance.new("UICorner")cpc.CornerRadius=UDim.new(0,4);cpc.Parent=cp
                    cp.MouseButton1Click:Connect(function()
                        if setclipboard then setclipboard(k);cp.Text="✓";task.wait(1);cp.Text="Copy"end
                    end)
                end
            end
            local rfB=Instance.new("TextButton")rfB.Name="RefreshBtn";rfB.Size=UDim2.new(1,0,0,30)
            rfB.BackgroundColor3=Color3.fromRGB(60,60,100);rfB.BorderSizePixel=0;rfB.Text="🔄 Làm mới"
            rfB.TextColor3=Color3.fromRGB(255,255,255);rfB.Font=Enum.Font.GothamBold
            rfB.TextSize=12;rfB.Parent=ps
            local rfBc=Instance.new("UICorner")rfBc.CornerRadius=UDim.new(0,5);rfBc.Parent=rfB
            rfB.MouseButton1Click:Connect(rl2)
            rl2()
        end)
    end)

    local fL=false
    local function mkFC(ic,up)
        local b=Instance.new("TextButton")b.Size=UDim2.new(0,56,0,56)
        if up then b.Position=UDim2.new(1,-76,0.5,-66)else b.Position=UDim2.new(1,-76,0.5,6)end
        b.BackgroundColor3=Color3.fromRGB(35,25,10);b.BackgroundTransparency=0.2
        b.BorderSizePixel=2;b.BorderColor3=Color3.fromRGB(255,215,0);b.Text=ic
        b.TextColor3=Color3.fromRGB(255,215,0);b.Font=Enum.Font.GothamBold;b.TextSize=26
        b.AutoButtonColor=false;b.Visible=false;b.Active=true;b.Parent=g
        local bc=Instance.new("UICorner")bc.CornerRadius=UDim.new(0.5,0);bc.Parent=b
        local hd=false
        U.InputBegan:Connect(function(i)
            if(i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1)
            and b.Visible and pg(b,i.Position)then
                hd=true;if up then upH=true else dnH=true end
            end
        end)
        U.InputEnded:Connect(function(i)
            if(i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1)and hd then
                hd=false;if up then upH=false else dnH=false end
            end
        end)
        return b
    end
    local fU=mkFC("▲",true);local fD=mkFC("▼",false)
    task.spawn(function()
        while task.wait(0.2)do
            local on=cfg.fly
            if fU.Visible~=on then fU.Visible=on;fD.Visible=on end
        end
    end)

    local fdt=nil;local fds=Vector2.zero;local fsp=UDim2.new(0,0,0,0);local fat=nil
    U.InputBegan:Connect(function(i)
        if fL then return end
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
            if fU.Visible and pg(fU,i.Position)then fdt=fU;fds=i.Position;fsp=fU.Position;fat=i
            elseif fD.Visible and pg(fD,i.Position)then fdt=fD;fds=i.Position;fsp=fD.Position;fat=i end
        end
    end)
    U.InputChanged:Connect(function(i)
        if fdt and i==fat and(i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement)then
            local d=i.Position-fds
            fdt.Position=UDim2.new(fsp.X.Scale,fsp.X.Offset+d.X,fsp.Y.Scale,fsp.Y.Offset+d.Y)
        end
    end)
    U.InputEnded:Connect(function(i)if fdt and i==fat then fdt=nil;fat=nil end end)

    local fLB=Instance.new("TextButton")fLB.Size=UDim2.new(0,28,0,28);fLB.Position=UDim2.new(1,-36,0,180)
    fLB.BackgroundColor3=Color3.fromRGB(40,40,60);fLB.BorderSizePixel=0;fLB.Text="🔓"
    fLB.TextColor3=Color3.fromRGB(255,255,255);fLB.Font=Enum.Font.GothamBold;fLB.TextSize=13
    fLB.AutoButtonColor=false;fLB.Visible=false;fLB.Parent=g
    local fLBc=Instance.new("UICorner")fLBc.CornerRadius=UDim.new(0.5,0);fLBc.Parent=fLB
    fLB.MouseButton1Click:Connect(function()
        fL=not fL;fLB.Text=fL and "🔒"or "🔓"
        fLB.BackgroundColor3=fL and Color3.fromRGB(150,40,40)or Color3.fromRGB(40,40,60)
    end)
    task.spawn(function()
        while task.wait(0.2)do
            local on=cfg.fly
            if fLB.Visible~=on then fLB.Visible=on end
        end
    end)

    local cnt=Instance.new("TextLabel")cnt.Size=UDim2.new(1,-4,0,18)
    cnt.BackgroundTransparency=1;cnt.TextColor3=Color3.fromRGB(180,180,180)
    cnt.Font=Enum.Font.Gotham;cnt.TextSize=10;cnt.Text="mobs: 0";cnt.Parent=sc
    task.spawn(function()
        while task.wait(0.5)do
            local n=0
            for _ in pairs(tr)do n=n+1 end
            cnt.Text="mobs: "..n.." | "..auth
        end
    end)
end

local function showGate()
    local gt=Instance.new("ScreenGui")gt.Name="CrownKeyGate";gt.ResetOnSpawn=false
    gt.IgnoreGuiInset=true;gt.DisplayOrder=10000
    pcall(function()gt.Parent=game:GetService("CoreGui")end)
    if not gt.Parent then gt.Parent=L:WaitForChild("PlayerGui")end
    local bx=Instance.new("Frame")bx.Size=UDim2.new(0,320,0,260);bx.Position=UDim2.new(0.5,-160,0.5,-130)
    bx.BackgroundColor3=Color3.fromRGB(15,18,25);bx.BorderSizePixel=0;bx.Active=true;bx.Parent=gt
    local bc=Instance.new("UICorner")bc.CornerRadius=UDim.new(0,10);bc.Parent=bx
    local bs=Instance.new("UIStroke")bs.Color=Color3.fromRGB(255,215,0);bs.Thickness=2;bs.Parent=bx
    local ti=Instance.new("TextLabel")ti.Size=UDim2.new(1,0,0,60);ti.BackgroundTransparency=1
    ti.Text="👑 CROWN MENU";ti.TextColor3=Color3.fromRGB(255,215,0);ti.Font=Enum.Font.GothamBold
    ti.TextSize=22;ti.Parent=bx
    local sb=Instance.new("TextLabel")sb.Size=UDim2.new(1,0,0,20);sb.Position=UDim2.new(0,0,0,50)
    sb.BackgroundTransparency=1;sb.Text="Nhập key để sử dụng";sb.TextColor3=Color3.fromRGB(180,180,180)
    sb.Font=Enum.Font.Gotham;sb.TextSize=13;sb.Parent=bx
    local inp=Instance.new("TextBox")inp.Size=UDim2.new(1,-40,0,42);inp.Position=UDim2.new(0,20,0,90)
    inp.BackgroundColor3=Color3.fromRGB(30,35,45);inp.BorderSizePixel=0;inp.Text=""
    inp.PlaceholderText="Dán key vào đây...";inp.TextColor3=Color3.fromRGB(255,255,255)
    inp.PlaceholderColor3=Color3.fromRGB(120,120,120);inp.Font=Enum.Font.Gotham
    inp.TextSize=14;inp.ClearTextOnFocus=false;inp.Parent=bx
    local ic=Instance.new("UICorner")ic.CornerRadius=UDim.new(0,6);ic.Parent=inp
    local bt=Instance.new("TextButton")bt.Size=UDim2.new(1,-40,0,44);bt.Position=UDim2.new(0,20,0,148)
    bt.BackgroundColor3=Color3.fromRGB(200,150,20);bt.BorderSizePixel=0;bt.Text="XÁC NHẬN"
    bt.TextColor3=Color3.fromRGB(20,20,20);bt.Font=Enum.Font.GothamBold;bt.TextSize=15;bt.Parent=bx
    local btc=Instance.new("UICorner")btc.CornerRadius=UDim.new(0,6);btc.Parent=bt
    local st=Instance.new("TextLabel")st.Size=UDim2.new(1,-40,0,40);st.Position=UDim2.new(0,20,0,200)
    st.BackgroundTransparency=1;st.Text="";st.TextColor3=Color3.fromRGB(255,100,100)
    st.Font=Enum.Font.Gotham;st.TextSize=12;st.TextWrapped=true;st.Parent=bx
    local function tl()
        local k=inp.Text:match("^%s*(.-)%s*$")
        if k==""then st.Text="Vui lòng nhập key";return end
        local ok,msg=ck(k)
        if ok then
            sak(k);st.TextColor3=Color3.fromRGB(150,255,150);st.Text="✓ Key hợp lệ — đang mở menu..."
            task.wait(0.5);gt:Destroy();build(msg)
        else st.TextColor3=Color3.fromRGB(255,100,100);st.Text="✗ "..msg end
    end
    bt.MouseButton1Click:Connect(tl)
    inp.FocusLost:Connect(function(en)if en then tl()end end)
end

local sv=lak()
if sv then
    local ok,msg=ck(sv)
    if ok then build(msg)else cak();showGate()end
else showGate()end
