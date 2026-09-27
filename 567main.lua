-- Crown v14 GUI-ESP | không cần Drawing API | Roblox Mobile
local P=game:GetService("Players");local R=game:GetService("RunService")
local W=game:GetService("Workspace");local U=game:GetService("UserInputService")
local C=W.CurrentCamera;local L=P.LocalPlayer

local function fw(n,d)if writefile then pcall(writefile,n,d)end end
local function fr(n)if isfile and readfile and isfile(n)then local o,d=pcall(readfile,n)if o then return d end end end
local function did()
    local i=fr("crown_device.txt");if i and #i>0 then return i end
    local s=""
    for _,v in ipairs({game.JobId,game.PlaceId,L.UserId,U.TouchEnabled,U.KeyboardEnabled})do pcall(function()s=s..tostring(v or"")end)end
    local h=5381
    for i=1,#s do h=((h*33)+s:byte(i))%0x7FFFFFFF end
    local r=string.format("DEV-%08X",h);fw("crown_device.txt",r);return r
end
local DEV=did()

local AK={["ADMIN-1"]=true,["ADMIN-2"]=true}
local PK={["ANHDZ-2012-Kx9@mP!vQ7#L"]=true,["ANHDZ-2012-Zt4$nB&wR6^M"]=true}
local TK={["ANHDZ-2012-Yh7%cF*eD3!J"]=3600,["ANHDZ-2012-Lm2@qA#pV8$N"]=86400,["ANHDZ-2012-Wg5^rT!kS9&X"]=604800,["ANHDZ-2012-Ub3*zE%jH6@Q"]=2592000,["ANHDZ-2012-Pk8!vY$oC4^R"]=31536000}

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
    if s==3600 then return"1h"end if s==86400 then return"1 ngày"end
    if s==604800 then return"1 tuần"end if s==2592000 then return"1 tháng"end
    if s==31536000 then return"1 năm"end return s.."s"
end

local function ck(k)
    if AK[k]or PK[k]then
        local t=lk();local e=t[k]
        local isA=AK[k]
        if not e then t[k]={device=DEV,expire=0,duration=isA and"ADMIN"or"PERM",originalSec=0};sk(t);return true,isA and"ADMIN"or"PERM",0 end
        if e.device~=""and e.device~=DEV then return false,isA and"Key admin đã gắn thiết bị khác"or"Key vĩnh viễn đã gắn thiết bị khác"end
        if e.device==""then e.device=DEV;t[k]=e;sk(t)end
        return true,isA and"ADMIN"or"PERM",0
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
    if AK[k]or PK[k]then
        if not e then return false,"Key chưa dùng"end
        e.device="";e.expire=0;e.originalSec=0;e.duration=AK[k]and"ADMIN"or"PERM";t[k]=e;sk(t)
        return true,"Đã reset "..(AK[k]and"key admin"or"key vĩnh viễn")
    end
    if not e then
        if TK[k]then return false,"Key chưa dùng"end
        return false,"Key không tồn tại"
    end
    local s=e.originalSec
    if not s or s<=0 then s=TK[k]or 86400 end
    e.device="";e.expire=os.time()+s;e.originalSec=s;e.duration=dl(s);t[k]=e;sk(t)
    return true,"Đã reset — hạn mới: "..dl(s)
end

local function sak(k)fw("crown_active.txt",k.."|"..DEV)end
local function cak()fw("crown_active.txt","")end
local function lak()
    local d=fr("crown_active.txt");if not d then return end
    local k,dv=d:match("^([^|]+)|([^|]+)$")
    if k and dv==DEV then return k end
end

local cfg={espMob=false,espPlayer=false,highlight=false,showBox=false,showName=false,showDist=false,showHP=false,showSkel=false,
    maxDist=2000,fill=Color3.fromRGB(255,60,60),outline=Color3.fromRGB(255,0,0),nameC=Color3.fromRGB(255,220,100),
    distC=Color3.fromRGB(255,255,255),hpC=Color3.fromRGB(0,255,100),
    excl={Terrain=true,Camera=true,Baseplate=true,SpawnLocation=true,Ignore=true,Debris=true},
    minParts=1,looseParts=true,skipAnchored=false,
    fly=false,flySpeed=80,vertSpeed=80,camDir=true,flyNoclip=true}

local mc,mh;local fBV,fBG
local mv,lv=Vector2.zero,Vector2.zero
local upH,dnH=false,false

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

-- ========== GUI ESP LAYER ==========
local espGui=Instance.new("ScreenGui")
espGui.Name="CrownESP"
espGui.ResetOnSpawn=false
espGui.IgnoreGuiInset=true
espGui.DisplayOrder=5000
pcall(function()espGui.Parent=game:GetService("CoreGui")end)
if not espGui.Parent then espGui.Parent=L:WaitForChild("PlayerGui")end

local tracked={}

local function mkESP(inst)
    local v={}
    local hl=Instance.new("Highlight")
    hl.FillColor=cfg.fill;hl.OutlineColor=cfg.outline
    hl.FillTransparency=0.6;hl.OutlineTransparency=0
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee=inst;hl.Parent=inst;v.hl=hl

    local box=Instance.new("Frame")
    box.BackgroundTransparency=1
    box.BorderSizePixel=1
    box.BorderColor3=cfg.outline
    box.Visible=false
    box.ZIndex=9998
    box.Parent=espGui
    v.box=box

    local name=Instance.new("TextLabel")
    name.BackgroundTransparency=1
    name.TextColor3=cfg.nameC
    name.Font=Enum.Font.GothamBold
    name.TextSize=13
    name.TextStrokeTransparency=0
    name.TextStrokeColor3=Color3.new(0,0,0)
    name.Visible=false
    name.ZIndex=9999
    name.Parent=espGui
    v.name=name

    local dist=Instance.new("TextLabel")
    dist.BackgroundTransparency=1
    dist.TextColor3=cfg.distC
    dist.Font=Enum.Font.Gotham
    dist.TextSize=11
    dist.TextStrokeTransparency=0
    dist.TextStrokeColor3=Color3.new(0,0,0)
    dist.Visible=false
    dist.ZIndex=9999
    dist.Parent=espGui
    v.dist=dist

    local hpBarBg=Instance.new("Frame")
    hpBarBg.BackgroundColor3=Color3.fromRGB(20,20,20)
    hpBarBg.BorderSizePixel=0
    hpBarBg.Visible=false
    hpBarBg.ZIndex=9998
    hpBarBg.Parent=espGui
    v.hb=hpBarBg

    local hpBar=Instance.new("Frame")
    hpBar.BackgroundColor3=Color3.fromRGB(0,255,0)
    hpBar.BorderSizePixel=0
    hpBar.Visible=false
    hpBar.ZIndex=9999
    hpBar.Parent=espGui
    v.hf=hpBar

    tracked[inst]=v
end

local function rmESP(inst)
    if tracked[inst]then
        local v=tracked[inst]
        if v.hl then pcall(function()v.hl:Destroy()end)end
        if v.box then pcall(function()v.box:Destroy()end)end
        if v.name then pcall(function()v.name:Destroy()end)end
        if v.dist then pcall(function()v.dist:Destroy()end)end
        if v.hb then pcall(function()v.hb:Destroy()end)end
        if v.hf then pcall(function()v.hf:Destroy()end)end
        tracked[inst]=nil
    end
end

local function hideAll(v)
    if v.hl then v.hl.Enabled=false end
    v.box.Visible=false;v.name.Visible=false;v.dist.Visible=false
    v.hb.Visible=false;v.hf.Visible=false
end

local function scan()
    local fd={}
    for _,o in ipairs(W:GetDescendants())do
        local s=false
        if cfg.espMob and isMob(o)then s=true end
        if cfg.espPlayer and isPlyr(o)then s=true end
        if s then fd[o]=true;if not tracked[o]then mkESP(o)end end
    end
    for i in pairs(tracked)do
        if not fd[i]or not i.Parent then rmESP(i)end
    end
end
task.spawn(function()while task.wait(1.5)do pcall(scan)end end)
W.DescendantAdded:Connect(function(d)
    if d:IsA("Model")or d:IsA("BasePart")then
        task.wait(0.1)
        if d.Parent and not tracked[d]then
            if(cfg.espMob and isMob(d))or(cfg.espPlayer and isPlyr(d))then mkESP(d)end
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
        local cf=cfg.camDir and C.CFrame or mh.CFrame
        local hum=mc and mc:FindFirstChildOfClass("Humanoid")
        if hum and hum.MoveDirection.Magnitude>0.01 then
            d=d+cf.LookVector*hum.MoveDirection.Z+cf.RightVector*hum.MoveDirection.X
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
    local vs=C.ViewportSize
    for i,v in pairs(tracked)do
        local rp
        if not i.Parent then rp=nil
        elseif i:IsA("BasePart")then rp=i.Position
        else
            local p=i:FindFirstChild("HumanoidRootPart")or i:FindFirstChild("Root")or i:FindFirstChildWhichIsA("BasePart")
            rp=p and p.Position or nil
        end
        if not rp then hideAll(v)
        else
            local dist=(h.Position-rp).Magnitude
            local far=dist>cfg.maxDist
            if far then hideAll(v)
            else
                local ip=isPlyr(i)
                local col=ip and Color3.fromRGB(100,200,255)or cfg.fill
                local ol=ip and Color3.fromRGB(0,150,255)or cfg.outline
                if v.hl then v.hl.Enabled=cfg.highlight;v.hl.FillColor=col;v.hl.OutlineColor=ol end
                local mn,mx=gb(i)
                if not mn then hideAll(v)
                else
                    local cx=(mn.X+mx.X)*0.5;local cz=(mn.Z+mx.Z)*0.5
                    local ts,to=w2s(Vector3.new(cx,mx.Y,cz))
                    local bs,bo=w2s(Vector3.new(cx,mn.Y,cz))
                    if not(to and bo)then hideAll(v)
                    elseif to.X<-100 or to.X>vs.X+100 or to.Y<-100 or to.Y>vs.Y+100 then hideAll(v)
                    else
                        local cX=(ts.X+bs.X)*0.5
                        local hh=math.abs(bs.Y-ts.Y)
                        local ww=hh*0.6
                        -- BOX
                        if cfg.showBox and hh>4 then
                            v.box.Visible=true
                            v.box.Size=UDim2.new(0,ww,0,hh)
                            v.box.Position=UDim2.new(0,cX-ww/2,0,ts.Y)
                            v.box.BorderColor3=ol
                        else v.box.Visible=false end
                        -- NAME
                        if cfg.showName then
                            v.name.Visible=true
                            v.name.Text=gdn(i)
                            v.name.TextColor3=ip and Color3.fromRGB(150,220,255)or cfg.nameC
                            v.name.Size=UDim2.new(0,200,0,16)
                            v.name.Position=UDim2.new(0,cX-100,0,ts.Y-18)
                        else v.name.Visible=false end
                        -- DIST
                        if cfg.showDist then
                            v.dist.Visible=true
                            v.dist.Text="["..math.floor(dist).."]"
                            v.dist.Size=UDim2.new(0,100,0,14)
                            v.dist.Position=UDim2.new(0,cX-50,0,bs.Y+2)
                        else v.dist.Visible=false end
                        -- HP
                        local hp,mhp=gh(i)
                        if cfg.showHP and hp and mhp and mhp>0 then
                            local pct=math.clamp(hp/mhp,0,1)
                            local bx=cX-ww/2-6
                            v.hb.Visible=true
                            v.hb.Size=UDim2.new(0,4,0,hh)
                            v.hb.Position=UDim2.new(0,bx,0,ts.Y)
                            v.hf.Visible=true
                            v.hf.Size=UDim2.new(0,4,0,hh*pct)
                            v.hf.Position=UDim2.new(0,bx,0,ts.Y+hh-hh*pct)
                            v.hf.BackgroundColor3=Color3.fromRGB(math.floor(255*(1-pct)),math.floor(255*pct),60)
                        else
                            v.hb.Visible=false;v.hf.Visible=false
                        end
                    end
                end
            end
        end
    end
end)

local function build(auth,keyExpire)
    local g=Instance.new("ScreenGui")g.Name="CrownMenu";g.ResetOnSpawn=false;g.IgnoreGuiInset=true;g.DisplayOrder=9999
    pcall(function()g.Parent=game:GetService("CoreGui")end)
    if not g.Parent then g.Parent=L:WaitForChild("PlayerGui")end
    local DP=UDim2.new(0,20,0,60)
    local logLock=false;local mnuLock=false

    local function cnr(o,r)local c=Instance.new("UICorner")c.CornerRadius=UDim.new(0,r or 4);c.Parent=o return c end
    local function stk(o,c,t)local s=Instance.new("UIStroke")s.Color=c;s.Thickness=t or 1;s.Parent=o return s end
    local function pg(o,p)
        local a,b=o.AbsolutePosition,o.AbsoluteSize
        return p.X>=a.X and p.X<=a.X+b.X and p.Y>=a.Y and p.Y<=a.Y+b.Y
    end
    local function mkEl(cls,props,parent)
        local o=Instance.new(cls)
        for k,v in pairs(props)do o[k]=v end
        o.Parent=parent;return o
    end
    local GOLD=Color3.fromRGB(255,215,0)

    local lg=mkEl("TextButton",{Size=UDim2.new(0,42,0,42),Position=DP,BackgroundColor3=Color3.fromRGB(35,25,10),
        BorderSizePixel=2,BorderColor3=GOLD,Text="👑",TextColor3=GOLD,Font=Enum.Font.GothamBold,TextSize=22,
        AutoButtonColor=false,Visible=false,Active=true},g)
    cnr(lg,0.5);stk(lg,GOLD,1.5)

    local fr_=mkEl("Frame",{Size=UDim2.new(0,200,0,290),Position=DP,BackgroundColor3=Color3.fromRGB(15,18,25),
        BorderSizePixel=0,Active=true},g)
    cnr(fr_,8);stk(fr_,GOLD,1)

    local tt=mkEl("Frame",{Size=UDim2.new(1,0,0,32),BackgroundColor3=Color3.fromRGB(30,25,10),BorderSizePixel=0},fr_)
    cnr(tt,8)

    mkEl("TextLabel",{Size=UDim2.new(0,28,1,0),Position=UDim2.new(0,2,0,0),
        BackgroundTransparency=1,Text="👑",TextColor3=GOLD,Font=Enum.Font.GothamBold,TextSize=18},tt)

    mkEl("TextLabel",{Size=UDim2.new(1,-90,0,14),Position=UDim2.new(0,32,0,2),
        BackgroundTransparency=1,Text="CROWN",TextColor3=GOLD,Font=Enum.Font.GothamBold,
        TextSize=11,TextXAlignment=Enum.TextXAlignment.Left},tt)

    local timeLbl=mkEl("TextLabel",{Size=UDim2.new(1,-90,0,12),Position=UDim2.new(0,32,0,17),
        BackgroundTransparency=1,Text="",Font=Enum.Font.GothamBold,TextSize=9,
        TextXAlignment=Enum.TextXAlignment.Left},tt)

    if auth=="ADMIN"then timeLbl.Text="⏱ ADMIN";timeLbl.TextColor3=Color3.fromRGB(255,150,150)
    elseif auth=="PERM"then timeLbl.Text="⏱ PERM";timeLbl.TextColor3=Color3.fromRGB(150,200,255)
    elseif keyExpire and keyExpire>0 then
        task.spawn(function()
            while timeLbl.Parent do
                local left=keyExpire-os.time()
                if left<=0 then timeLbl.Text="⏱ HẾT HẠN";timeLbl.TextColor3=Color3.fromRGB(255,60,60)
                else
                    local d,h,m,s=math.floor(left/86400),math.floor((left%86400)/3600),math.floor((left%3600)/60),left%60
                    local txt
                    if d>0 then txt=string.format("%dd%dh%dm",d,h,m)
                    elseif h>0 then txt=string.format("%dh%dm%ds",h,m,s)
                    elseif m>0 then txt=string.format("%dm%ds",m,s)
                    else txt=string.format("%ds",s)end
                    timeLbl.Text="⏱ "..txt
                    timeLbl.TextColor3=left>86400 and Color3.fromRGB(150,255,150)or left>3600 and Color3.fromRGB(200,255,100)or left>60 and Color3.fromRGB(255,220,100)or Color3.fromRGB(255,150,100)
                end
                task.wait(1)
            end
        end)
    end

    local lkb=mkEl("TextButton",{Size=UDim2.new(0,22,0,22),Position=UDim2.new(1,-52,0,5),
        BackgroundColor3=Color3.fromRGB(40,40,60),BorderSizePixel=0,Text="🔓",
        TextColor3=Color3.fromRGB(255,255,255),Font=Enum.Font.GothamBold,TextSize=11,AutoButtonColor=false},tt)
    cnr(lkb,4)

    local cl=mkEl("TextButton",{Size=UDim2.new(0,22,0,22),Position=UDim2.new(1,-26,0,5),
        BackgroundColor3=Color3.fromRGB(60,30,30),BorderSizePixel=0,Text="−",
        TextColor3=Color3.fromRGB(255,255,255),Font=Enum.Font.GothamBold,TextSize=14,AutoButtonColor=false},tt)
    cnr(cl,4)

    local sc=mkEl("ScrollingFrame",{Size=UDim2.new(1,-4,1,-36),Position=UDim2.new(0,2,0,34),
        BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=6,ScrollBarImageColor3=GOLD,
        CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollingDirection=Enum.ScrollingDirection.Y,ScrollingEnabled=true,Active=true,
        ClipsDescendants=true,ElasticBehavior=Enum.ElasticBehavior.Never},fr_)
    mkEl("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,2)},sc)
    mkEl("UIPadding",{PaddingTop=UDim.new(0,3),PaddingLeft=UDim.new(0,3),
        PaddingRight=UDim.new(0,3),PaddingBottom=UDim.new(0,30)},sc)

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
        if logLock or not lmv then fr_.Visible=true;lg.Visible=false;fr_.Position=lg.Position end
        lgd=false;lat=nil
    end)
    cl.MouseButton1Click:Connect(function()
        lg.Position=fr_.Position;fr_.Visible=false;lg.Visible=true
    end)

    local function mkT(lb,k)
        local b=mkEl("TextButton",{Size=UDim2.new(1,-4,0,22),
            BackgroundColor3=cfg[k]and Color3.fromRGB(140,100,20)or Color3.fromRGB(45,45,55),
            BorderSizePixel=0,Text=lb,TextColor3=Color3.fromRGB(255,255,255),
            Font=Enum.Font.GothamBold,TextSize=10},sc)
        cnr(b,4)
        b.MouseButton1Click:Connect(function()
            cfg[k]=not cfg[k]
            b.BackgroundColor3=cfg[k]and Color3.fromRGB(140,100,20)or Color3.fromRGB(45,45,55)
        end)
    end
    local function mkH(t)
        mkEl("TextLabel",{Size=UDim2.new(1,-4,0,16),BackgroundTransparency=1,Text=t,
            TextColor3=GOLD,Font=Enum.Font.GothamBold,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left},sc)
    end
    local function mkS(lb,k,mn,mx)
        local w=mkEl("Frame",{Size=UDim2.new(1,-4,0,28),BackgroundTransparency=1},sc)
        local l=mkEl("TextLabel",{Size=UDim2.new(1,0,0,12),BackgroundTransparency=1,
            Text=lb..": "..cfg[k],TextColor3=Color3.fromRGB(200,200,200),Font=Enum.Font.Gotham,
            TextSize=8,TextXAlignment=Enum.TextXAlignment.Left},w)
        local b=mkEl("Frame",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,0,12),
            BackgroundColor3=Color3.fromRGB(40,40,55),BorderSizePixel=0},w)
        cnr(b,3)
        local f=mkEl("Frame",{Size=UDim2.new((cfg[k]-mn)/(mx-mn),0,1,0),BackgroundColor3=GOLD,BorderSizePixel=0},b)
        cnr(f,3)
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
    mkT("Khoảng cách","showDist");mkT("Số máu","showHP")

    mkH("◆ FLY")
    mkT("FLY ON/OFF","fly");mkT("Xuyên tường","flyNoclip")

    local db=mkEl("TextButton",{Size=UDim2.new(1,-4,0,20),BackgroundColor3=Color3.fromRGB(60,60,90),
        BorderSizePixel=0,Text=cfg.camDir and"Bay theo Camera"or"Bay theo Nhân vật",
        TextColor3=Color3.fromRGB(255,255,255),Font=Enum.Font.Gotham,TextSize=9},sc)
    cnr(db,4)
    db.MouseButton1Click:Connect(function()
        cfg.camDir=not cfg.camDir
        db.Text=cfg.camDir and"Bay theo Camera"or"Bay theo Nhân vật"
    end)
    mkS("Tốc độ bay","flySpeed",20,500)
    mkS("Tốc độ lên/xuống","vertSpeed",20,500)

    mkH("◆ ADMIN")
    local function mkBtn(txt,col)
        local b=mkEl("TextButton",{Size=UDim2.new(1,-4,0,22),BackgroundColor3=col,
            BorderSizePixel=0,Text=txt,TextColor3=Color3.fromRGB(255,255,255),
            Font=Enum.Font.GothamBold,TextSize=9},sc)
        cnr(b,4);return b
    end
    local cB=mkBtn("➕ TẠO KEY",Color3.fromRGB(40,120,60))
    local chB=mkBtn("🔄 RESET KEY",Color3.fromRGB(180,120,40))
    local lkB=mkBtn("📋 DS KEY",Color3.fromRGB(60,60,100))

    local adm=false
    local function reqAdm(cb)
        local pg2=mkEl("ScreenGui",{Name="AdminPrompt",ResetOnSpawn=false,
            IgnoreGuiInset=true,DisplayOrder=10001},nil)
        pcall(function()pg2.Parent=game:GetService("CoreGui")end)
        if not pg2.Parent then pg2.Parent=L:WaitForChild("PlayerGui")end
        local b=mkEl("Frame",{Size=UDim2.new(0,260,0,200),Position=UDim2.new(0.5,-130,0.5,-100),
            BackgroundColor3=Color3.fromRGB(25,10,10),BorderSizePixel=0,Active=true},pg2)
        cnr(b,10);stk(b,Color3.fromRGB(255,100,100),2)
        mkEl("TextLabel",{Size=UDim2.new(1,0,0,40),BackgroundTransparency=1,
            Text="🔐 XÁC THỰC ADMIN",TextColor3=Color3.fromRGB(255,100,100),
            Font=Enum.Font.GothamBold,TextSize=15},b)
        mkEl("TextLabel",{Size=UDim2.new(1,-20,0,24),Position=UDim2.new(0,10,0,40),
            BackgroundTransparency=1,Text="Nhập key admin để tiếp tục",
            TextColor3=Color3.fromRGB(200,200,200),Font=Enum.Font.Gotham,TextSize=10,
            TextWrapped=true},b)
        local inp=mkEl("TextBox",{Size=UDim2.new(1,-40,0,32),Position=UDim2.new(0,20,0,68),
            BackgroundColor3=Color3.fromRGB(40,25,25),BorderSizePixel=0,Text="",
            PlaceholderText="Nhập key admin...",TextColor3=Color3.fromRGB(255,255,255),
            PlaceholderColor3=Color3.fromRGB(120,100,100),Font=Enum.Font.Gotham,
            TextSize=12,ClearTextOnFocus=false},b)
        cnr(inp,6)
        local bt=mkEl("TextButton",{Size=UDim2.new(1,-40,0,32),Position=UDim2.new(0,20,0,108),
            BackgroundColor3=Color3.fromRGB(180,40,40),BorderSizePixel=0,Text="XÁC NHẬN",
            TextColor3=Color3.fromRGB(255,255,255),Font=Enum.Font.GothamBold,TextSize=12},b)
        cnr(bt,6)
        local cn=mkEl("TextButton",{Size=UDim2.new(1,-40,0,22),Position=UDim2.new(0,20,0,146),
            BackgroundColor3=Color3.fromRGB(50,50,60),BorderSizePixel=0,Text="Hủy",
            TextColor3=Color3.fromRGB(200,200,200),Font=Enum.Font.Gotham,TextSize=10},b)
        cnr(cn,5)
        local st=mkEl("TextLabel",{Size=UDim2.new(1,-40,0,18),Position=UDim2.new(0,20,0,172),
            BackgroundTransparency=1,Text="",TextColor3=Color3.fromRGB(255,100,100),
            Font=Enum.Font.Gotham,TextSize=9},b)
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
    local function wAdm(fn)if adm then fn()else reqAdm(fn)end end

    local function mkP(ti,tc)
        local p=mkEl("Frame",{Size=UDim2.new(0,250,0,360),Position=UDim2.new(0.5,-125,0.5,-180),
            BackgroundColor3=Color3.fromRGB(20,15,15),BorderSizePixel=0,Active=true},g)
        cnr(p,8);stk(p,tc,2)
        local pt=mkEl("TextLabel",{Size=UDim2.new(1,0,0,32),BackgroundColor3=Color3.fromRGB(60,20,20),
            BorderSizePixel=0,Text=ti,TextColor3=tc,Font=Enum.Font.GothamBold,TextSize=12},p)
        cnr(pt,8)
        local cx=mkEl("TextButton",{Size=UDim2.new(0,26,0,26),Position=UDim2.new(1,-30,0,3),
            BackgroundColor3=Color3.fromRGB(150,40,40),BorderSizePixel=0,Text="✕",
            TextColor3=Color3.fromRGB(255,255,255),Font=Enum.Font.GothamBold,TextSize=14,
            AutoButtonColor=false},p)
        cnr(cx,5)
        cx.MouseButton1Click:Connect(function()p:Destroy()end)
        local sc2=mkEl("ScrollingFrame",{Size=UDim2.new(1,-8,1,-40),Position=UDim2.new(0,4,0,36),
            BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=6,ScrollBarImageColor3=tc,
            CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
            ScrollingEnabled=true,Active=true,ScrollingDirection=Enum.ScrollingDirection.Y,
            ClipsDescendants=true,ElasticBehavior=Enum.ElasticBehavior.Never},p)
        mkEl("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,5)},sc2)
        mkEl("UIPadding",{PaddingTop=UDim.new(0,4),PaddingLeft=UDim.new(0,4),
            PaddingRight=UDim.new(0,4),PaddingBottom=UDim.new(0,50)},sc2)
        return p,sc2
    end

    local function mkLbl(par,txt,col)
        mkEl("TextLabel",{Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,Text=txt,
            TextColor3=col,Font=Enum.Font.GothamBold,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left},par)
    end
    local function mkInp(par,ph,dark)
        local i=mkEl("TextBox",{Size=UDim2.new(1,0,0,28),
            BackgroundColor3=dark and Color3.fromRGB(40,25,25)or Color3.fromRGB(40,40,50),
            BorderSizePixel=0,Text="",PlaceholderText=ph,TextColor3=Color3.fromRGB(255,255,255),
            PlaceholderColor3=Color3.fromRGB(120,120,120),Font=Enum.Font.Gotham,
            TextSize=11,ClearTextOnFocus=false},par)
        cnr(i,4);return i
    end

    cB.MouseButton1Click:Connect(function()
        wAdm(function()
            local p,ps=mkP("➕ TẠO KEY MỚI",Color3.fromRGB(80,200,100))
            mkLbl(ps,"─── Chọn thời hạn ───",Color3.fromRGB(255,180,100))
            local sd=3600;local dbtns={}
            local durs={{l="1h",s=3600},{l="1 Ngày",s=86400},{l="1 Tuần",s=604800},{l="1 Tháng",s=2592000},{l="1 Năm",s=31536000}}
            local dr=mkEl("Frame",{Size=UDim2.new(1,0,0,88),BackgroundTransparency=1},ps)
            mkEl("UIGridLayout",{CellSize=UDim2.new(0.5,-4,0,26),CellPadding=UDim2.new(0,4,0,4)},dr)
            local function upH2()for _,x in ipairs(dbtns)do x.b.BackgroundColor3=(x.s==sd)and Color3.fromRGB(200,100,20)or Color3.fromRGB(60,60,60)end end
            for _,d in ipairs(durs)do
                local b=mkEl("TextButton",{BackgroundColor3=Color3.fromRGB(60,60,60),
                    BorderSizePixel=0,Text=d.l,TextColor3=Color3.fromRGB(255,255,255),
                    Font=Enum.Font.GothamBold,TextSize=10},dr)
                cnr(b,4)
                b.MouseButton1Click:Connect(function()sd=d.s;upH2()end)
                table.insert(dbtns,{b=b,s=d.s})
            end
            upH2()
            mkLbl(ps,"Key (trống = random):",Color3.fromRGB(220,220,220))
            local inp=mkInp(ps,"VD: ANHDZ-2012-xxxx")
            local rb=mkEl("TextButton",{Size=UDim2.new(1,0,0,24),BackgroundColor3=Color3.fromRGB(60,90,60),
                BorderSizePixel=0,Text="🎲 Random 12 ký tự",TextColor3=Color3.fromRGB(255,255,255),
                Font=Enum.Font.GothamBold,TextSize=10},ps)
            cnr(rb,4)
            rb.MouseButton1Click:Connect(function()inp.Text=rk()end)
            local cb2=mkEl("TextButton",{Size=UDim2.new(1,0,0,30),BackgroundColor3=Color3.fromRGB(40,150,60),
                BorderSizePixel=0,Text="✓ TẠO KEY",TextColor3=Color3.fromRGB(255,255,255),
                Font=Enum.Font.GothamBold,TextSize=12},ps)
            cnr(cb2,4)
            local lg2=mkEl("TextLabel",{Size=UDim2.new(1,0,0,36),BackgroundTransparency=1,Text="",
                TextColor3=Color3.fromRGB(150,255,150),Font=Enum.Font.Gotham,TextSize=9,
                TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left},ps)
            local rb2=mkEl("Frame",{Size=UDim2.new(1,0,0,68),BackgroundColor3=Color3.fromRGB(25,35,25),
                BorderSizePixel=0,Visible=false},ps)
            cnr(rb2,4)
            local rkl=mkEl("TextLabel",{Size=UDim2.new(1,-10,0,18),Position=UDim2.new(0,5,0,3),
                BackgroundTransparency=1,Text="",TextColor3=GOLD,Font=Enum.Font.Code,
                TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},rb2)
            local rdl=mkEl("TextLabel",{Size=UDim2.new(1,-10,0,14),Position=UDim2.new(0,5,0,21),
                BackgroundTransparency=1,Text="",TextColor3=Color3.fromRGB(150,255,150),
                Font=Enum.Font.Gotham,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left},rb2)
            local cpb=mkEl("TextButton",{Size=UDim2.new(1,-10,0,26),Position=UDim2.new(0,5,0,38),
                BackgroundColor3=Color3.fromRGB(60,90,60),BorderSizePixel=0,Text="📋 COPY KEY",
                TextColor3=Color3.fromRGB(255,255,255),Font=Enum.Font.GothamBold,TextSize=10},rb2)
            cnr(cpb,4)
            local lastKey=""
            cpb.MouseButton1Click:Connect(function()
                if lastKey==""then return end
                if setclipboard then
                    setclipboard(lastKey)
                    cpb.Text="✓ ĐÃ COPY!";cpb.BackgroundColor3=Color3.fromRGB(40,150,60)
                    task.wait(1.5);cpb.Text="📋 COPY KEY";cpb.BackgroundColor3=Color3.fromRGB(60,90,60)
                else cpb.Text="✗ Không hỗ trợ" end
            end)
            cb2.MouseButton1Click:Connect(function()
                local k=inp.Text:match("^%s*(.-)%s*$")
                if k==""then k=rk()end
                if #k<6 then lg2.TextColor3=Color3.fromRGB(255,100,100);lg2.Text="✗ Key phải có ít nhất 6 ký tự";return end
                local t=lk()
                if t[k]or AK[k]or PK[k]then lg2.TextColor3=Color3.fromRGB(255,100,100);lg2.Text="✗ Key đã tồn tại";return end
                t[k]={device="",expire=os.time()+sd,duration=dl(sd),originalSec=sd}
                sk(t);lastKey=k
                lg2.TextColor3=Color3.fromRGB(150,255,150);lg2.Text="✓ Đã tạo key thành công!"
                rb2.Visible=true;rkl.Text=k;rdl.Text="Hạn: "..dl(sd).." • Chưa dùng";inp.Text=""
            end)
        end)
    end)

    chB.MouseButton1Click:Connect(function()
        wAdm(function()
            local p,ps=mkP("🔄 RESET KEY",Color3.fromRGB(255,180,80))
            local ib=mkEl("TextLabel",{Size=UDim2.new(1,0,0,44),BackgroundColor3=Color3.fromRGB(40,30,15),
                BorderSizePixel=0,Text="Reset = xóa liên kết thiết bị + đặt lại thời gian.\nCần xác thực admin trước khi reset.",
                TextColor3=Color3.fromRGB(255,220,150),Font=Enum.Font.Gotham,TextSize=9,TextWrapped=true},ps)
            cnr(ib,4)
            mkLbl(ps,"─── 1. Xác thực admin ───",Color3.fromRGB(255,100,100))
            local ai=mkInp(ps,"Nhập key admin (ADMIN-1/2)",true)
            local ab=mkEl("TextButton",{Size=UDim2.new(1,0,0,28),BackgroundColor3=Color3.fromRGB(180,40,40),
                BorderSizePixel=0,Text="🔐 XÁC THỰC",TextColor3=Color3.fromRGB(255,255,255),
                Font=Enum.Font.GothamBold,TextSize=11},ps)
            cnr(ab,4)
            local al=mkEl("TextLabel",{Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,Text="",
                TextColor3=Color3.fromRGB(255,100,100),Font=Enum.Font.Gotham,TextSize=9},ps)
            mkLbl(ps,"─── 2. Nhập key cần reset ───",Color3.fromRGB(255,180,100))
            local ri=mkInp(ps,"Paste key vào đây...")
            local rB=mkEl("TextButton",{Size=UDim2.new(1,0,0,30),BackgroundColor3=Color3.fromRGB(200,100,30),
                BorderSizePixel=0,Text="↺ RESET KEY",TextColor3=Color3.fromRGB(255,255,255),
                Font=Enum.Font.GothamBold,TextSize=11},ps)
            cnr(rB,4)
            local rl=mkEl("TextLabel",{Size=UDim2.new(1,0,0,80),BackgroundTransparency=1,Text="",
                TextColor3=Color3.fromRGB(255,200,100),Font=Enum.Font.Gotham,TextSize=10,
                TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top},ps)
            local ok2=false
            ab.MouseButton1Click:Connect(function()
                local k=ai.Text:match("^%s*(.-)%s*$")
                if k==""then al.TextColor3=Color3.fromRGB(255,100,100);al.Text="✗ Nhập key admin";return end
                if AK[k]then
                    local t=lk();local e=t[k]
                    if not e then t[k]={device=DEV,expire=0,duration="ADMIN",originalSec=0};sk(t)
                    elseif e.device~=""and e.device~=DEV then al.TextColor3=Color3.fromRGB(255,100,100);al.Text="✗ Key admin đã gắn máy khác";return
                    elseif e.device==""then e.device=DEV;t[k]=e;sk(t)end
                    ok2=true;al.TextColor3=Color3.fromRGB(150,255,150);al.Text="✓ OK — có thể reset"
                else al.TextColor3=Color3.fromRGB(255,100,100);al.Text="✗ Key admin không đúng"end
            end)
            rB.MouseButton1Click:Connect(function()
                if not ok2 then rl.TextColor3=Color3.fromRGB(255,100,100);rl.Text="✗ Phải xác thực admin trước";return end
                local k=ri.Text:match("^%s*(.-)%s*$")
                if k==""then rl.TextColor3=Color3.fromRGB(255,100,100);rl.Text="✗ Chưa nhập key";return end
                local ok3,msg=rst(k)
                if ok3 then rl.TextColor3=Color3.fromRGB(150,255,150);rl.Text="✓ "..msg;ri.Text=""
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
                for k,info in pairs(ak)do
                    local tl=""
                    if info.expire>0 then
                        local lf=info.expire-nw
                        if lf<=0 then tl="HẾT HẠN"else
                            local h=math.floor(lf/3600);local d=math.floor(h/24)
                            if d>0 then tl=d.."d"..(h%24).."h"
                            elseif h>0 then tl=h.."h"..math.floor((lf%3600)/60).."m"
                            else tl=math.floor(lf/60).."p"end
                        end
                    else tl="Vĩnh viễn"end
                    local di="chưa dùng"
                    if info.device and info.device~=""then di=info.device==DEV and"máy này"or"máy khác"end
                    local cd=mkEl("TextButton",{Size=UDim2.new(1,0,0,44),BackgroundColor3=Color3.fromRGB(30,30,45),
                        BorderSizePixel=0,Text="",AutoButtonColor=false},ps)
                    cnr(cd,4)
                    mkEl("TextLabel",{Size=UDim2.new(1,-50,0,16),Position=UDim2.new(0,5,0,2),
                        BackgroundTransparency=1,Text=k,TextColor3=GOLD,Font=Enum.Font.Code,
                        TextSize=8,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},cd)
                    mkEl("TextLabel",{Size=UDim2.new(1,-10,0,12),Position=UDim2.new(0,5,0,17),
                        BackgroundTransparency=1,Text=info.duration.." | "..tl,
                        TextColor3=Color3.fromRGB(180,180,180),Font=Enum.Font.Gotham,
                        TextSize=7,TextXAlignment=Enum.TextXAlignment.Left},cd)
                    mkEl("TextLabel",{Size=UDim2.new(1,-10,0,12),Position=UDim2.new(0,5,0,28),
                        BackgroundTransparency=1,Text="Thiết bị: "..di,
                        TextColor3=Color3.fromRGB(200,200,100),Font=Enum.Font.Gotham,
                        TextSize=7,TextXAlignment=Enum.TextXAlignment.Left},cd)
                    local cpb=mkEl("TextButton",{Size=UDim2.new(0,40,0,16),Position=UDim2.new(1,-44,0,2),
                        BackgroundColor3=Color3.fromRGB(60,60,100),BorderSizePixel=0,Text="Copy",
                        TextColor3=Color3.fromRGB(255,255,255),Font=Enum.Font.GothamBold,TextSize=8},cd)
                    cnr(cpb,3)
                    cpb.MouseButton1Click:Connect(function()
                        if setclipboard then setclipboard(k);cpb.Text="✓";task.wait(1);cpb.Text="Copy"end
                    end)
                end
            end
            local rfB=mkEl("TextButton",{Name="RefreshBtn",Size=UDim2.new(1,0,0,24),
                BackgroundColor3=Color3.fromRGB(60,60,100),BorderSizePixel=0,Text="🔄 Làm mới",
                TextColor3=Color3.fromRGB(255,255,255),Font=Enum.Font.GothamBold,TextSize=10},ps)
            cnr(rfB,4)
            rfB.MouseButton1Click:Connect(rl2)
            rl2()
        end)
    end)

    local fL=false
    local function mkFC(ic,up)
        local b=mkEl("TextButton",{Size=UDim2.new(0,44,0,44),
            Position=up and UDim2.new(1,-64,0.5,-52)or UDim2.new(1,-64,0.5,8),
            BackgroundColor3=Color3.fromRGB(35,25,10),BackgroundTransparency=0.2,
            BorderSizePixel=2,BorderColor3=GOLD,Text=ic,TextColor3=GOLD,
            Font=Enum.Font.GothamBold,TextSize=22,AutoButtonColor=false,Visible=false,Active=true},g)
        cnr(b,0.5)
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

    local fdt,fds,fsp,fat=nil,Vector2.zero,UDim2.new(0,0,0,0),nil
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

    local fLB=mkEl("TextButton",{Size=UDim2.new(0,24,0,24),Position=UDim2.new(1,-32,0,150),
        BackgroundColor3=Color3.fromRGB(40,40,60),BorderSizePixel=0,Text="🔓",
        TextColor3=Color3.fromRGB(255,255,255),Font=Enum.Font.GothamBold,TextSize=11,
        AutoButtonColor=false,Visible=false},g)
    cnr(fLB,0.5)
    fLB.MouseButton1Click:Connect(function()
        fL=not fL;fLB.Text=fL and"🔒"or"🔓"
        fLB.BackgroundColor3=fL and Color3.fromRGB(150,40,40)or Color3.fromRGB(40,40,60)
    end)
    task.spawn(function()
        while task.wait(0.2)do
            local on=cfg.fly
            if fLB.Visible~=on then fLB.Visible=on end
        end
    end)

    local cnt=mkEl("TextLabel",{Size=UDim2.new(1,-4,0,14),BackgroundTransparency=1,
        TextColor3=Color3.fromRGB(180,180,180),Font=Enum.Font.Gotham,TextSize=8,Text="mobs: 0"},sc)
    task.spawn(function()
        while task.wait(0.5)do
            local n=0
            for _ in pairs(tracked)do n=n+1 end
            cnt.Text="mobs: "..n.." | "..auth
        end
    end)
end

local function showGate()
    local gt=Instance.new("ScreenGui")gt.Name="CrownKeyGate";gt.ResetOnSpawn=false
    gt.IgnoreGuiInset=true;gt.DisplayOrder=10000
    pcall(function()gt.Parent=game:GetService("CoreGui")end)
    if not gt.Parent then gt.Parent=L:WaitForChild("PlayerGui")end
    local bx=Instance.new("Frame")bx.Size=UDim2.new(0,280,0,220);bx.Position=UDim2.new(0.5,-140,0.5,-110)
    bx.BackgroundColor3=Color3.fromRGB(15,18,25);bx.BorderSizePixel=0;bx.Active=true;bx.Parent=gt
    local bc=Instance.new("UICorner")bc.CornerRadius=UDim.new(0,10);bc.Parent=bx
    local bs=Instance.new("UIStroke")bs.Color=Color3.fromRGB(255,215,0);bs.Thickness=2;bs.Parent=bx
    local ti=Instance.new("TextLabel")ti.Size=UDim2.new(1,0,0,48);ti.BackgroundTransparency=1
    ti.Text="👑 CROWN MENU";ti.TextColor3=Color3.fromRGB(255,215,0);ti.Font=Enum.Font.GothamBold
    ti.TextSize=18;ti.Parent=bx
    local sb=Instance.new("TextLabel")sb.Size=UDim2.new(1,0,0,16);sb.Position=UDim2.new(0,0,0,42)
    sb.BackgroundTransparency=1;sb.Text="Nhập key để sử dụng";sb.TextColor3=Color3.fromRGB(180,180,180)
    sb.Font=Enum.Font.Gotham;sb.TextSize=11;sb.Parent=bx
    local inp=Instance.new("TextBox")inp.Size=UDim2.new(1,-40,0,34);inp.Position=UDim2.new(0,20,0,72)
    inp.BackgroundColor3=Color3.fromRGB(30,35,45);inp.BorderSizePixel=0;inp.Text=""
    inp.PlaceholderText="Dán key vào đây...";inp.TextColor3=Color3.fromRGB(255,255,255)
    inp.PlaceholderColor3=Color3.fromRGB(120,120,120);inp.Font=Enum.Font.Gotham
    inp.TextSize=12;inp.ClearTextOnFocus=false;inp.Parent=bx
    local ic=Instance.new("UICorner")ic.CornerRadius=UDim.new(0,6);ic.Parent=inp
    local bt=Instance.new("TextButton")bt.Size=UDim2.new(1,-40,0,36);bt.Position=UDim2.new(0,20,0,120)
    bt.BackgroundColor3=Color3.fromRGB(200,150,20);bt.BorderSizePixel=0;bt.Text="XÁC NHẬN"
    bt.TextColor3=Color3.fromRGB(20,20,20);bt.Font=Enum.Font.GothamBold;bt.TextSize=13;bt.Parent=bx
    local btc=Instance.new("UICorner")btc.CornerRadius=UDim.new(0,6);btc.Parent=bt
    local st=Instance.new("TextLabel")st.Size=UDim2.new(1,-40,0,32);st.Position=UDim2.new(0,20,0,164)
    st.BackgroundTransparency=1;st.Text="";st.TextColor3=Color3.fromRGB(255,100,100)
    st.Font=Enum.Font.Gotham;st.TextSize=10;st.TextWrapped=true;st.Parent=bx
    local function tl()
        local k=inp.Text:match("^%s*(.-)%s*$")
        if k==""then st.Text="Vui lòng nhập key";return end
        local ok,msg,exp=ck(k)
        if ok then
            sak(k);st.TextColor3=Color3.fromRGB(150,255,150);st.Text="✓ Key hợp lệ..."
            task.wait(0.5);gt:Destroy();build(msg,exp)
        else st.TextColor3=Color3.fromRGB(255,100,100);st.Text="✗ "..msg end
    end
    bt.MouseButton1Click:Connect(tl)
    inp.FocusLost:Connect(function(en)if en then tl()end end)
end

local sv=lak()
if sv then
    local ok,msg,exp=ck(sv)
    if ok then build(msg,exp)else cak();showGate()end
else showGate()end
