-- language: Luau, file: esp.lua, target: Delta / Krnl / Codex
-- Str1ker ESP v8 — limpo

local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local WS=game:GetService("Workspace")
local Camera=WS.CurrentCamera
local LP=Players.LocalPlayer

local ESP={Enabled=false}
ESP.Config={
    Box=true,
    BoxColor=Color3.fromRGB(80,150,255),
    BoxThickness=1.5,
    HealthBar=true,
    HealthBarWidth=4,
    Name=true,
    ShowDisplayName=true,
    Distance=true,
    Skeleton=false,
    SkeletonColor=Color3.fromRGB(255,255,255),
    SkeletonThickness=2,
    Tracer=true,
    TracerColor=Color3.fromRGB(80,150,255),
    TracerThickness=1.5,
    ShowPhoto=false,
    PhotoSize=52,
    PhotoRingColor=Color3.fromRGB(70,220,110),
    MaxDistance=2000,
    TeamCheck=true,
}

local DRAW=Drawing or (syn and syn.drawing) or (Krnl and Krnl.Drawing)
if not DRAW then return warn("[ESP] no Drawing") end
local function n_sq() return DRAW.new("Square") end
local function n_ln() return DRAW.new("Line") end
local function n_tx() return DRAW.new("Text") end
local function n_ci() return DRAW.new("Circle") end

local gui=Instance.new("ScreenGui")
gui.Name="Str1kerESP"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
pcall(function() gui.Parent=gethui() end)
if not gui.Parent then gui.Parent=LP:WaitForChild("PlayerGui") end

local cache={}
local thumb_cache={}

-- ── SKELETON BONES ──
local R15={
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},
}
local R6={
    {"Head","Torso"},
    {"Torso","Left Arm"},{"Torso","Right Arm"},
    {"Torso","Left Leg"},{"Torso","Right Leg"},
}

local function get_rig(char)
    if char:FindFirstChild("UpperTorso") then return R15 end
    if char:FindFirstChild("Torso") then return R6 end
    return nil
end

-- ── PHOTO ──
local function make_photo()
    local wrap=Instance.new("Frame")
    wrap.BackgroundTransparency=1; wrap.Visible=false; wrap.ZIndex=5; wrap.Parent=gui
    local box=Instance.new("Frame")
    box.Size=UDim2.fromScale(1,1); box.BackgroundColor3=Color3.fromRGB(8,14,28); box.BorderSizePixel=0; box.Parent=wrap
    Instance.new("UICorner",box).CornerRadius=UDim.new(1,0)
    local stroke=Instance.new("UIStroke")
    stroke.Color=ESP.Config.PhotoRingColor; stroke.Thickness=2; stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; stroke.Parent=box
    local grad=Instance.new("UIGradient")
    grad.Color=ColorSequence.new(ESP.Config.PhotoRingColor,Color3.fromRGB(34,211,238)); grad.Rotation=45; grad.Parent=stroke
    local img=Instance.new("ImageLabel")
    img.Size=UDim2.new(1,-6,1,-6); img.Position=UDim2.fromOffset(3,3); img.BackgroundTransparency=1; img.Parent=box
    Instance.new("UICorner",img).CornerRadius=UDim.new(1,0)
    return wrap,stroke,grad,img
end

-- ── CACHE ──
local function create_cache()
    local c={}

    -- BOX: 1 Square simples
    c.box=n_sq()
    c.box.Filled=false
    c.box.Transparency=1
    c.box.Thickness=ESP.Config.BoxThickness
    c.box.Color=ESP.Config.BoxColor
    c.box.Visible=false
    c.box.From=Vector2.zero
    c.box.To=Vector2.zero

    -- NAME
    c.name=n_tx()
    c.name.Size=14
    c.name.Center=true
    c.name.Outline=true
    c.name.Color=Color3.fromRGB(240,244,252)
    c.name.OutlineColor=Color3.new(0,0,0)
    c.name.Font=2
    c.name.Visible=false

    -- DISTANCE
    c.dist=n_tx()
    c.dist.Size=12
    c.dist.Center=true
    c.dist.Outline=true
    c.dist.Color=Color3.fromRGB(200,215,235)
    c.dist.OutlineColor=Color3.new(0,0,0)
    c.dist.Font=2
    c.dist.Visible=false

    -- HP BACKGROUND (preto)
    c.hp_bg=n_sq()
    c.hp_bg.Filled=true
    c.hp_bg.Color=Color3.new(0,0,0)
    c.hp_bg.Transparency=0.3
    c.hp_bg.Visible=false
    c.hp_bg.From=Vector2.zero
    c.hp_bg.To=Vector2.zero

    -- HP DAMAGE (vermelho — vida perdida)
    c.hp_dmg=n_sq()
    c.hp_dmg.Filled=true
    c.hp_dmg.Color=Color3.fromRGB(230,40,40)
    c.hp_dmg.Transparency=0
    c.hp_dmg.Visible=false
    c.hp_dmg.From=Vector2.zero
    c.hp_dmg.To=Vector2.zero

    -- HP FILL (verde — vida atual)
    c.hp=n_sq()
    c.hp.Filled=true
    c.hp.Color=Color3.fromRGB(70,220,110)
    c.hp.Transparency=0
    c.hp.Visible=false
    c.hp.From=Vector2.zero
    c.hp.To=Vector2.zero

    -- TRACER
    c.tracer=n_ln()
    c.tracer.Thickness=ESP.Config.TracerThickness
    c.tracer.Color=ESP.Config.TracerColor
    c.tracer.Transparency=0
    c.tracer.Visible=false
    c.tracer.From=Vector2.zero
    c.tracer.To=Vector2.zero

    -- HEAD DOT
    c.dot=n_ci()
    c.dot.Filled=true
    c.dot.Radius=3
    c.dot.NumSides=20
    c.dot.Color=Color3.fromRGB(255,80,80)
    c.dot.Visible=false

    -- SKELETON POOL
    c.sk={}

    -- PHOTO
    c.photo_wrap,c.photo_stroke,c.photo_grad,c.photo_img=make_photo()

    return c
end

local function destroy_cache(c)
    local to_remove={c.box,c.name,c.dist,c.hp_bg,c.hp_dmg,c.hp,c.tracer,c.dot}
    for _,entry in ipairs(c.sk) do table.insert(to_remove,entry) end
    for _,ln in ipairs(to_remove) do
        if typeof(ln)=="userdata" then pcall(function() ln:Remove() end) end
    end
    if c.photo_wrap then c.photo_wrap:Destroy() end
end

local function ensure_sk(c,count)
    while #c.sk<count do
        local ln=n_ln()
        ln.Thickness=ESP.Config.SkeletonThickness
        ln.Color=ESP.Config.SkeletonColor
        ln.Transparency=0
        ln.Visible=false
        ln.From=Vector2.zero
        ln.To=Vector2.zero
        table.insert(c.sk,ln)
    end
    for i=count+1,#c.sk do c.sk[i].Visible=false end
end

local function get_thumb(uid)
    if thumb_cache[uid] then return thumb_cache[uid] end
    local ok,url=pcall(function()
        return Players:GetUserThumbnailAsync(uid,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150)
    end)
    if ok and url then thumb_cache[uid]=url; return url end
    return nil
end

local function w2s(pos)
    local sp,on=Camera:WorldToViewportPoint(pos)
    if not on or sp.Z<0 then return nil end
    return Vector2.new(sp.X,sp.Y)
end

local function get_bbox(plr)
    local char=plr.Character
    if not char then return nil end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    local head=char:FindFirstChild("Head")
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hrp or not head or not hum then return nil end
    if hum.Health<=0 then return nil end
    return char,hrp,head,hum
end

local function hp_color(pct)
    if pct>0.66 then return Color3.fromRGB(70,220,110) end
    if pct>0.33 then return Color3.fromRGB(255,200,60) end
    return Color3.fromRGB(255,60,60)
end

local function render_skeleton(c,char)
    local rig=get_rig(char)
    if not rig then return end
    ensure_sk(c,#rig)
    for i,conn in ipairs(rig) do
        local p1=char:FindFirstChild(conn[1])
        local p2=char:FindFirstChild(conn[2])
        local ln=c.sk[i]
        if p1 and p2 and p1:IsA("BasePart") and p2:IsA("BasePart") then
            local a=w2s(p1.Position)
            local b=w2s(p2.Position)
            if a and b then
                ln.From=a
                ln.To=b
                ln.Color=ESP.Config.SkeletonColor
                ln.Thickness=ESP.Config.SkeletonThickness
                ln.Visible=true
            else
                ln.Visible=false
            end
        else
            ln.Visible=false
        end
    end
end

local function render(plr,c)
    local char,hrp,head,hum=get_bbox(plr)
    if not char then return false end

    local my_hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not my_hrp then return false end
    local dist=(hrp.Position-my_hrp.Position).Magnitude
    if dist>ESP.Config.MaxDistance then return false end
    if ESP.Config.TeamCheck and plr.Team and LP.Team and plr.Team==LP.Team then return false end

    local top=w2s(head.Position+Vector3.new(0,1.2,0))
    local bot=w2s(hrp.Position-Vector3.new(0,2.8,0))
    if not top or not bot then return false end

    local w=math.abs(top.X-bot.X)
    local h=math.abs(top.Y-bot.Y)
    w=math.max(w,h*0.6)

    local left=top.X-w/2
    local right=top.X+w/2
    local cx=top.X
    local topY=top.Y
    local botY=bot.Y

    -- BOX
    if ESP.Config.Box then
        c.box.From=Vector2.new(left,topY)
        c.box.To=Vector2.new(right,botY)
        c.box.Color=ESP.Config.BoxColor
        c.box.Thickness=ESP.Config.BoxThickness
        c.box.Visible=true
    else
        c.box.Visible=false
    end

    -- SKELETON
    if ESP.Config.Skeleton then
        render_skeleton(c,char)
    else
        for _,ln in ipairs(c.sk) do ln.Visible=false end
    end

    -- NAME
    if ESP.Config.Name then
        c.name.Visible=true
        c.name.Position=Vector2.new(cx,topY-16)
        c.name.Text=ESP.Config.ShowDisplayName and (plr.DisplayName or plr.Name) or ("@"..plr.Name)
    else
        c.name.Visible=false
    end

    -- DISTANCE
    if ESP.Config.Distance then
        c.dist.Visible=true
        c.dist.Position=Vector2.new(cx,botY+4)
        c.dist.Text=string.format("[%d studs]",math.floor(dist))
    else
        c.dist.Visible=false
    end

    -- HEALTH BAR (três camadas)
    if ESP.Config.HealthBar then
        local pct=math.clamp(hum.Health/hum.MaxHealth,0,1)
        local bw=ESP.Config.HealthBarWidth
        local bLeft=left-bw-3
        local bRight=left-3
        local barH=botY-topY

        -- bg preto
        c.hp_bg.From=Vector2.new(bLeft,topY)
        c.hp_bg.To=Vector2.new(bRight,botY)
        c.hp_bg.Visible=true

        -- camada vermelha (o que já perdeu)
        if pct<1 then
            c.hp_dmg.From=Vector2.new(bLeft,topY)
            c.hp_dmg.To=Vector2.new(bRight,topY+barH*(1-pct))
            c.hp_dmg.Visible=true
        else
            c.hp_dmg.Visible=false
        end

        -- fill verde
        c.hp.From=Vector2.new(bLeft,botY-barH*pct)
        c.hp.To=Vector2.new(bRight,botY)
        c.hp.Color=hp_color(pct)
        c.hp.Visible=true
    else
        c.hp_bg.Visible=false
        c.hp_dmg.Visible=false
        c.hp.Visible=false
    end

    -- TRACER
    if ESP.Config.Tracer then
        local vp=Camera.ViewportSize
        c.tracer.From=Vector2.new(vp.X/2,vp.Y)
        c.tracer.To=Vector2.new(cx,botY)
        c.tracer.Color=ESP.Config.TracerColor
        c.tracer.Thickness=ESP.Config.TracerThickness
        c.tracer.Visible=true
    else
        c.tracer.Visible=false
    end

    -- HEAD DOT
    if not ESP.Config.ShowPhoto then
        local hp=w2s(head.Position)
        if hp then
            c.dot.Position=hp
            c.dot.Visible=true
        else
            c.dot.Visible=false
        end
    else
        c.dot.Visible=false
    end

    -- PHOTO
    if ESP.Config.ShowPhoto then
        local url=get_thumb(plr.UserId)
        if url and c.photo_img.Image~=url then c.photo_img.Image=url end
        local size=ESP.Config.PhotoSize
        c.photo_wrap.Size=UDim2.fromOffset(size,size)
        c.photo_wrap.Position=UDim2.fromOffset(math.floor(cx-size/2),math.floor(topY-size-24))
        c.photo_wrap.Visible=true
        c.photo_stroke.Color=ESP.Config.PhotoRingColor
        c.photo_grad.Color=ColorSequence.new(ESP.Config.PhotoRingColor,Color3.fromRGB(34,211,238))
    elseif c.photo_wrap then
        c.photo_wrap.Visible=false
    end

    return true
end

local function hide(c)
    c.box.Visible=false
    c.name.Visible=false
    c.dist.Visible=false
    c.hp_bg.Visible=false
    c.hp_dmg.Visible=false
    c.hp.Visible=false
    c.tracer.Visible=false
    c.dot.Visible=false
    for _,ln in ipairs(c.sk) do ln.Visible=false end
    if c.photo_wrap then c.photo_wrap.Visible=false end
end

RunService.RenderStepped:Connect(function()
    if not ESP.Enabled then
        for _,c in pairs(cache) do hide(c) end
        return
    end
    local valid={}
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LP then
            local c=cache[plr]
            if not c then c=create_cache(); cache[plr]=c end
            if not render(plr,c) then hide(c) end
            valid[plr]=true
        end
    end
    for plr,c in pairs(cache) do
        if not valid[plr] then destroy_cache(c); cache[plr]=nil end
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if cache[plr] then destroy_cache(cache[plr]); cache[plr]=nil end
end)

function ESP.set(k,v) ESP.Config[k]=v end
function ESP.toggle(v) ESP.Enabled=(v==nil) and not ESP.Enabled or v end

_G.Str1kerESP=ESP
return ESP
