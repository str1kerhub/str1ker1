-- language: Luau, file: esp.lua, target: Delta / Krnl / Codex
-- Str1ker ESP v3 — Drawing + headshot com moldura circular

local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local WS=game:GetService("Workspace")
local Camera=WS.CurrentCamera
local LP=Players.LocalPlayer

local ESP={Enabled=false}
ESP.Config={
    Box=true,BoxStyle="Corners",BoxColor=Color3.fromRGB(59,130,246),BoxThickness=1.6,
    Name=true,ShowDisplayName=true,
    Distance=true,
    HealthBar=true,ShowHPText=true,
    Tracer=true,TracerColor=Color3.fromRGB(59,130,246),TracerThickness=2.5,TracerGlow=true,
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

local function create_cache()
    local c={}
    c.box=n_sq(); c.box.Thickness=ESP.Config.BoxThickness; c.box.Color=ESP.Config.BoxColor; c.box.Filled=false; c.box.Visible=false
    c.box_glow=n_sq(); c.box_glow.Thickness=3.5; c.box_glow.Color=ESP.Config.BoxColor; c.box_glow.Filled=false; c.box_glow.Transparency=0.85; c.box_glow.Visible=false
    c.box_bg=n_sq(); c.box_bg.Filled=true; c.box_bg.Transparency=0.85; c.box_bg.Color=ESP.Config.BoxColor; c.box_bg.Visible=false
    c.name=n_tx(); c.name.Size=14; c.name.Center=true; c.name.Outline=true; c.name.Color=Color3.fromRGB(240,244,252); c.name.OutlineColor=Color3.new(0,0,0); c.name.Font=2; c.name.Visible=false
    c.distance=n_tx(); c.distance.Size=12; c.distance.Center=true; c.distance.Outline=true; c.distance.Color=Color3.fromRGB(165,200,255); c.distance.OutlineColor=Color3.new(0,0,0); c.distance.Font=2; c.distance.Visible=false
    c.hp_bg=n_sq(); c.hp_bg.Filled=true; c.hp_bg.Color=Color3.new(0,0,0); c.hp_bg.Transparency=0.4; c.hp_bg.Visible=false
    c.hp_fill=n_sq(); c.hp_fill.Filled=true; c.hp_fill.Color=Color3.fromRGB(70,220,110); c.hp_fill.Visible=false
    c.hp_text=n_tx(); c.hp_text.Size=11; c.hp_text.Center=true; c.hp_text.Outline=true; c.hp_text.Color=Color3.new(1,1,1); c.hp_text.OutlineColor=Color3.new(0,0,0); c.hp_text.Font=2; c.hp_text.Visible=false
    c.tracer_glow=n_ln(); c.tracer_glow.Thickness=5; c.tracer_glow.Color=ESP.Config.TracerColor; c.tracer_glow.Transparency=0.75; c.tracer_glow.Visible=false
    c.tracer=n_ln(); c.tracer.Thickness=ESP.Config.TracerThickness; c.tracer.Color=ESP.Config.TracerColor; c.tracer.Transparency=0; c.tracer.Visible=false
    c.head_dot=n_ci(); c.head_dot.Thickness=1; c.head_dot.Filled=true; c.head_dot.Color=Color3.fromRGB(255,80,80); c.head_dot.NumSides=30; c.head_dot.Radius=4; c.head_dot.Visible=false
    c.photo_wrap,c.photo_box,c.photo_stroke,c.photo_grad,c.photo_img=make_photo()
    return c
end

local function destroy_cache(c)
    for _,v in pairs(c) do
        if typeof(v)=="Instance" then pcall(function() v:Destroy() end)
        elseif typeof(v)=="userdata" then pcall(function() v:Remove() end) end
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

    if ESP.Config.Box then
        c.box.Visible=true
        c.box.Color=ESP.Config.BoxColor
        c.box.Thickness=ESP.Config.BoxThickness
        c.box.From=Vector2.new(left,top.Y)
        c.box.To=Vector2.new(right,bot.Y)
        if ESP.Config.BoxStyle=="Filled" then
            c.box.Filled=true; c.box.Transparency=0.75
        else
            c.box.Filled=false; c.box.Transparency=1
        end
        c.box_glow.Visible=true
        c.box_glow.Color=ESP.Config.BoxColor
        c.box_glow.From=Vector2.new(left-1,top.Y-1)
        c.box_glow.To=Vector2.new(right+1,bot.Y+1)
    else
        c.box.Visible=false; c.box_glow.Visible=false; c.box_bg.Visible=false
    end

    if ESP.Config.Name then
        c.name.Visible=true
        c.name.Position=Vector2.new(cx,top.Y-16)
        c.name.Text=ESP.Config.ShowDisplayName and (plr.DisplayName or plr.Name) or ("@"..plr.Name)
    else
        c.name.Visible=false
    end

    if ESP.Config.Distance then
        c.distance.Visible=true
        c.distance.Position=Vector2.new(cx,bot.Y+4)
        c.distance.Text=string.format("[%d m]",math.floor(dist/3.5))
    else
        c.distance.Visible=false
    end

    if ESP.Config.HealthBar then
        local pct=math.clamp(hum.Health/hum.MaxHealth,0,1)
        c.hp_bg.Visible=true
        c.hp_fill.Visible=true
        c.hp_bg.From=Vector2.new(left-7,top.Y)
        c.hp_bg.To=Vector2.new(left-3,bot.Y)
        c.hp_fill.From=Vector2.new(left-7,bot.Y-(bot.Y-top.Y)*pct)
        c.hp_fill.To=Vector2.new(left-3,bot.Y)
        c.hp_fill.Color=hp_color(pct)
        if ESP.Config.ShowHPText then
            c.hp_text.Visible=true
            c.hp_text.Position=Vector2.new(left-22,(top.Y+bot.Y)/2)
            c.hp_text.Text=string.format("%d%%",math.floor(pct*100))
            c.hp_text.Color=hp_color(pct)
        else
            c.hp_text.Visible=false
        end
    else
        c.hp_bg.Visible=false; c.hp_fill.Visible=false; c.hp_text.Visible=false
    end

    if ESP.Config.Tracer then
        local vp=Camera.ViewportSize
        local fx,fy=vp.X/2,vp.Y
        local tx,ty=cx,bot.Y
        c.tracer.Visible=true
        c.tracer.Color=ESP.Config.TracerColor
        c.tracer.Thickness=ESP.Config.TracerThickness
        c.tracer.From=Vector2.new(fx,fy)
        c.tracer.To=Vector2.new(tx,ty)
        if ESP.Config.TracerGlow then
            c.tracer_glow.Visible=true
            c.tracer_glow.Color=ESP.Config.TracerColor
            c.tracer_glow.From=Vector2.new(fx,fy)
            c.tracer_glow.To=Vector2.new(tx,ty)
        else
            c.tracer_glow.Visible=false
        end
    else
        c.tracer.Visible=false; c.tracer_glow.Visible=false
    end

    if not ESP.Config.ShowPhoto then
        local hp=w2s(head.Position)
        if hp then c.head_dot.Visible=true; c.head_dot.Position=hp
        else c.head_dot.Visible=false end
    else
        c.head_dot.Visible=false
    end

    if ESP.Config.ShowPhoto then
        local url=get_thumb(plr.UserId)
        if url then c.photo_img.Image=url end
        local size=ESP.Config.PhotoSize
        c.photo_wrap.Size=UDim2.fromOffset(size,size)
        c.photo_wrap.Position=UDim2.fromOffset(math.floor(top.X-size/2),math.floor(top.Y-size-24))
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
    c.box.Visible=false; c.box_glow.Visible=false; c.box_bg.Visible=false
    c.name.Visible=false; c.distance.Visible=false
    c.hp_bg.Visible=false; c.hp_fill.Visible=false; c.hp_text.Visible=false
    c.tracer.Visible=false; c.tracer_glow.Visible=false
    c.head_dot.Visible=false
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
