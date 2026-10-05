-- language: Luau, file: esp.lua, target: Delta / Krnl / Codex
-- Str1ker ESP v7 — Box via Square, health 6px, skeleton garantido

local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local WS=game:GetService("Workspace")
local Camera=WS.CurrentCamera
local LP=Players.LocalPlayer

local ESP={Enabled=false}
ESP.Config={
    Box=true,BoxColor=Color3.fromRGB(59,130,246),BoxThickness=1.8,
    BoxOutline=true,BoxOutlineColor=Color3.fromRGB(0,0,0),BoxOutlineThickness=4,
    Skeleton=false,SkeletonColor=Color3.fromRGB(240,244,252),SkeletonThickness=2.5,
    Name=true,ShowDisplayName=true,
    Distance=true,
    HealthBar=true,ShowHPText=true,ShowDamageLayer=true,
    Tracer=true,TracerColor=Color3.fromRGB(0,0,0),TracerThickness=3,TracerOutline=true,TracerOutlineColor=Color3.fromRGB(255,255,255),TracerOutlineThickness=5.5,
    ShowPhoto=false,PhotoSize=52,PhotoRing=true,PhotoRingColor=Color3.fromRGB(70,220,110),
    MaxDistance=2000,TeamCheck=true,
}

local DRAW=Drawing or (syn and syn.drawing) or (Krnl and Krnl.Drawing)
if not DRAW then return warn("[ESP] no Drawing API") end

local function n_sq() return DRAW.new("Square") end
local function n_ln() return DRAW.new("Line") end
local function n_tx() return DRAW.new("Text") end
local function n_ci() return DRAW.new("Circle") end

local gui=Instance.new("ScreenGui")
gui.Name="Str1kerESP"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
pcall(function() gui.Parent=gethui() end)
if not gui.Parent then gui.Parent=LP:WaitForChild("PlayerGui") end

local cache={}; local thumb_cache={}

local R15_BONES={
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}
local R6_BONES={
    {"Head","Torso"},
    {"Torso","Left Arm"},{"Torso","Right Arm"},
    {"Torso","Left Leg"},{"Torso","Right Leg"},
}

local function detect_rig(char)
    if char:FindFirstChild("UpperTorso") then return "R15" end
    if char:FindFirstChild("Torso") then return "R6" end
    return nil
end

local function make_photo()
    local wrap=Instance.new("Frame")
    wrap.BackgroundTransparency=1; wrap.ZIndex=5; wrap.Visible=false; wrap.Parent=gui
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
    return wrap,box,stroke,grad,img
end

-- ═══ BOX via Square (2 empilhados) ═══
-- ORDEM: cria OUTLINE primeiro (fica atrás), MAIN depois (fica na frente)
local function make_box()
    local bg=n_sq()
    bg.Filled=false
    bg.Thickness=ESP.Config.BoxOutlineThickness
    bg.Color=ESP.Config.BoxOutlineColor
    bg.Transparency=0
    bg.Visible=false
    bg.From=Vector2.zero
    bg.To=Vector2.zero

    local main=n_sq()
    main.Filled=false
    main.Thickness=ESP.Config.BoxThickness
    main.Color=ESP.Config.BoxColor
    main.Transparency=0
    main.Visible=false
    main.From=Vector2.zero
    main.To=Vector2.zero

    return {bg=bg, main=main}
end

local function draw_box(box,l,t,r,bo)
    box.bg.From=Vector2.new(l,t)
    box.bg.To=Vector2.new(r,bo)
    box.bg.Visible=true
    box.main.From=Vector2.new(l,t)
    box.main.To=Vector2.new(r,bo)
    box.main.Visible=true
end

local function hide_box(box)
    box.bg.Visible=false
    box.main.Visible=false
end

-- ═══ CACHE ═══
local function create_cache()
    local c={}
    c.box=make_box()

    c.name=n_tx(); c.name.Size=14; c.name.Center=true; c.name.Outline=true; c.name.Color=Color3.fromRGB(240,244,252); c.name.OutlineColor=Color3.new(0,0,0); c.name.Font=2; c.name.Visible=false
    c.distance=n_tx(); c.distance.Size=12; c.distance.Center=true; c.distance.Outline=true; c.distance.Color=Color3.fromRGB(165,200,255); c.distance.OutlineColor=Color3.new(0,0,0); c.distance.Font=2; c.distance.Visible=false

    -- HEALTH: ordem bg → dmg → fill
    c.hp_bg=n_sq(); c.hp_bg.Filled=true; c.hp_bg.Color=Color3.fromRGB(0,0,0); c.hp_bg.Transparency=0.25; c.hp_bg.Visible=false; c.hp_bg.From=Vector2.zero; c.hp_bg.To=Vector2.zero
    c.hp_dmg=n_sq(); c.hp_dmg.Filled=true; c.hp_dmg.Color=Color3.fromRGB(230,40,40); c.hp_dmg.Transparency=0; c.hp_dmg.Visible=false; c.hp_dmg.From=Vector2.zero; c.hp_dmg.To=Vector2.zero
    c.hp_fill=n_sq(); c.hp_fill.Filled=true; c.hp_fill.Color=Color3.fromRGB(70,220,110); c.hp_fill.Transparency=0; c.hp_fill.Visible=false; c.hp_fill.From=Vector2.zero; c.hp_fill.To=Vector2.zero
    c.hp_text=n_tx(); c.hp_text.Size=11; c.hp_text.Center=true; c.hp_text.Outline=true; c.hp_text.Color=Color3.new(1,1,1); c.hp_text.OutlineColor=Color3.new(0,0,0); c.hp_text.Font=2; c.hp_text.Visible=false

    -- TRACER: outline primeiro, main depois
    c.tracer_o=n_ln(); c.tracer_o.Thickness=ESP.Config.TracerOutlineThickness; c.tracer_o.Color=ESP.Config.TracerOutlineColor; c.tracer_o.Transparency=0; c.tracer_o.Visible=false; c.tracer_o.From=Vector2.zero; c.tracer_o.To=Vector2.zero
    c.tracer=n_ln();   c.tracer.Thickness=ESP.Config.TracerThickness; c.tracer.Color=ESP.Config.TracerColor; c.tracer.Transparency=0; c.tracer.Visible=false; c.tracer.From=Vector2.zero; c.tracer.To=Vector2.zero

    c.head_dot=n_ci(); c.head_dot.Thickness=1; c.head_dot.Filled=true; c.head_dot.Color=Color3.fromRGB(255,80,80); c.head_dot.NumSides=30; c.head_dot.Radius=4; c.head_dot.Visible=false

    c.sk={}
    c.photo_wrap,c.photo_box,c.photo_stroke,c.photo_grad,c.photo_img=make_photo()
    return c
end

local function destroy_cache(c)
    for _,v in pairs(c) do
        if typeof(v)=="Instance" then pcall(function() v:Destroy() end)
        elseif typeof(v)=="userdata" then pcall(function() v:Remove() end)
        elseif type(v)=="table" then
            if v.bg then pcall(function() v.bg:Remove() end); pcall(function() v.main:Remove() end) end
            for _,entry in pairs(v) do
                if type(entry)=="table" and entry.main then
                    pcall(function() entry.main:Remove() end)
                    pcall(function() entry.out:Remove() end)
                elseif typeof(entry)=="userdata" then
                    pcall(function() entry:Remove() end)
                end
            end
        end
    end
end

local function ensure_skeleton(c,count)
    while #c.sk<count do
        local main=n_ln()
        main.Thickness=ESP.Config.SkeletonThickness
        main.Color=ESP.Config.SkeletonColor
        main.Transparency=0
        main.Visible=false
        main.From=Vector2.zero
        main.To=Vector2.zero
        table.insert(c.sk,{main=main})
    end
    for i=count+1,#c.sk do
        c.sk[i].main.Visible=false
    end
end

local function get_thumb(userId)
    if thumb_cache[userId] then return thumb_cache[userId] end
    local ok,url=pcall(function()
        return Players:GetUserThumbnailAsync(userId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150)
    end)
    if ok and url then thumb_cache[userId]=url; return url end
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
    if not hrp or not head or not hum or hum.Health<=0 then return nil end
    return char,hrp,head,hum
end

local function hp_color(pct)
    if pct>0.66 then return Color3.fromRGB(70,220,110)
    elseif pct>0.33 then return Color3.fromRGB(255,200,60)
    else return Color3.fromRGB(255,60,60) end
end

local function render_skeleton(c,char)
    local rig=detect_rig(char)
    if not rig then return end
    local bones=rig=="R15" and R15_BONES or R6_BONES
    ensure_skeleton(c,#bones)
    for i,conn in ipairs(bones) do
        local p1=char:FindFirstChild(conn[1])
        local p2=char:FindFirstChild(conn[2])
        local entry=c.sk[i]
        if p1 and p2 and p1:IsA("BasePart") and p2:IsA("BasePart") then
            local a=w2s(p1.Position)
            local b=w2s(p2.Position)
            if a and b then
                entry.main.From=a
                entry.main.To=b
                entry.main.Color=ESP.Config.SkeletonColor
                entry.main.Thickness=ESP.Config.SkeletonThickness
                entry.main.Visible=true
            else
                entry.main.Visible=false
            end
        else
            entry.main.Visible=false
        end
    end
end

local function render(plr,c)
    local char,hrp,head,hum=get_bbox(plr)
    if not char then return false end
    local my_hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local dist=my_hrp and (hrp.Position-my_hrp.Position).Magnitude or 0
    if dist>ESP.Config.MaxDistance then return false end
    if ESP.Config.TeamCheck and plr.Team and LP.Team and plr.Team==LP.Team then return false end

    local top=w2s(head.Position+Vector3.new(0,1.2,0))
    local bot=w2s(hrp.Position-Vector3.new(0,2.8,0))
    if not top or not bot then return false end

    local w=math.abs(top.X-bot.X)
    local h=math.abs(top.Y-bot.Y)
    w=math.max(w,h*0.55)
    local left=top.X-w/2
    local right=top.X+w/2
    local cx=top.X
    local topY=top.Y
    local botY=bot.Y

    -- ═══ BOX ═══
    if ESP.Config.Box then
        c.box.bg.Thickness=ESP.Config.BoxOutline ? ESP.Config.BoxOutlineThickness : 0
        c.box.bg.Color=ESP.Config.BoxOutlineColor
        c.box.main.Color=ESP.Config.BoxColor
        c.box.main.Thickness=ESP.Config.BoxThickness
        draw_box(c.box,left,topY,right,botY)
    else
        hide_box(c.box)
    end

    -- ═══ SKELETON ═══
    if ESP.Config.Skeleton then
        render_skeleton(c,char)
    else
        for _,entry in ipairs(c.sk) do entry.main.Visible=false end
    end

    -- ═══ NAME ═══
    if ESP.Config.Name then
        c.name.Visible=true
        c.name.Position=Vector2.new(cx,topY-16)
        c.name.Text=ESP.Config.ShowDisplayName and (plr.DisplayName or plr.Name) or ("@"..plr.Name)
    else
        c.name.Visible=false
    end

    -- ═══ DISTANCE ═══
    if ESP.Config.Distance then
        c.distance.Visible=true
        c.distance.Position=Vector2.new(cx,botY+4)
        c.distance.Text=string.format("[%d m]",math.floor(dist/3.5))
    else
        c.distance.Visible=false
    end

    -- ═══ HEALTH (6px de largura) ═══
    if ESP.Config.HealthBar then
        local pct=math.clamp(hum.Health/hum.MaxHealth,0,1)
        local bLeft=left-11
        local bRight=left-5
        local barH=botY-topY

        -- fundo preto
        c.hp_bg.Visible=true
        c.hp_bg.From=Vector2.new(bLeft,topY)
        c.hp_bg.To=Vector2.new(bRight,botY)

        -- damage vermelho (só aparece quando perdeu vida)
        if ESP.Config.ShowDamageLayer and pct<0.99 then
            c.hp_dmg.Visible=true
            c.hp_dmg.From=Vector2.new(bLeft,topY)
            c.hp_dmg.To=Vector2.new(bRight,topY+barH*(1-pct))
        else
            c.hp_dmg.Visible=false
        end

        -- vida
        c.hp_fill.Visible=true
        c.hp_fill.From=Vector2.new(bLeft,botY-barH*pct)
        c.hp_fill.To=Vector2.new(bRight,botY)
        c.hp_fill.Color=hp_color(pct)

        if ESP.Config.ShowHPText then
            c.hp_text.Visible=true
            c.hp_text.Position=Vector2.new(bLeft-16,(topY+botY)/2)
            c.hp_text.Text=string.format("%d%%",math.floor(pct*100))
            c.hp_text.Color=hp_color(pct)
        else
            c.hp_text.Visible=false
        end
    else
        c.hp_bg.Visible=false; c.hp_dmg.Visible=false; c.hp_fill.Visible=false; c.hp_text.Visible=false
    end

    -- ═══ TRACER ═══
    if ESP.Config.Tracer then
        local vp=Camera.ViewportSize
        local fx,fy=vp.X/2,vp.Y
        c.tracer_o.Visible=true
        c.tracer_o.Color=ESP.Config.TracerOutlineColor
        c.tracer_o.Thickness=ESP.Config.TracerOutlineThickness
        c.tracer_o.From=Vector2.new(fx,fy)
        c.tracer_o.To=Vector2.new(cx,botY)
        c.tracer.Visible=true
        c.tracer.Color=ESP.Config.TracerColor
        c.tracer.Thickness=ESP.Config.TracerThickness
        c.tracer.From=Vector2.new(fx,fy)
        c.tracer.To=Vector2.new(cx,botY)
    else
        c.tracer.Visible=false; c.tracer_o.Visible=false
    end

    -- ═══ HEAD DOT ═══
    if not ESP.Config.ShowPhoto then
        local hp=w2s(head.Position)
        if hp then c.head_dot.Visible=true; c.head_dot.Position=hp
        else c.head_dot.Visible=false end
    else
        c.head_dot.Visible=false
    end

    -- ═══ PHOTO ═══
    if ESP.Config.ShowPhoto then
        local url=get_thumb(plr.UserId)
        if url then c.photo_img.Image=url end
        local size=ESP.Config.PhotoSize
        c.photo_wrap.Size=UDim2.fromOffset(size,size)
        c.photo_wrap.Position=UDim2.fromOffset(math.floor(cx-size/2),math.floor(topY-size-24))
        c.photo_wrap.Visible=true
        if ESP.Config.PhotoRing then
            c.photo_stroke.Transparency=0
            c.photo_stroke.Color=ESP.Config.PhotoRingColor
            c.photo_grad.Color=ColorSequence.new(ESP.Config.PhotoRingColor,Color3.fromRGB(34,211,238))
        else
            c.photo_stroke.Transparency=1
        end
    elseif c.photo_wrap then
        c.photo_wrap.Visible=false
    end

    return true
end

local function hide(c)
    hide_box(c.box)
    c.name.Visible=false; c.distance.Visible=false
    c.hp_bg.Visible=false; c.hp_dmg.Visible=false; c.hp_fill.Visible=false; c.hp_text.Visible=false
    c.tracer.Visible=false; c.tracer_o.Visible=false
    c.head_dot.Visible=false
    for _,entry in ipairs(c.sk) do entry.main.Visible=false end
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
