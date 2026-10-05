-- language: Luau, file: aimbot.lua, target: Delta / Krnl / Codex
-- Str1ker Aimbot v3 — prediction + adaptive + silent + sticky

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local WS         = game:GetService("Workspace")
local Camera     = WS.CurrentCamera
local LP         = Players.LocalPlayer
local Mouse      = LP:GetMouse()

local Aimbot = {Enabled=false, SilentMode=false}
Aimbot.Config = {
    AimMode          = "Smooth",       -- "Instant" | "Smooth" | "Human"
    Smoothing        = 0.35,
    HitPart          = "Head",         -- "Head" | "Torso" | "Nearest"
    MaxDistance      = 500,
    FOVDegrees       = 25,             -- graus de FOV
    PredictionBase   = 0.14,
    PingMultiplier   = 0.002,
    JitterAim        = true,
    JitterAmount     = 0.5,
    StickyTarget     = true,
    StickyDuration   = 1.8,
    TargetSwitchCD   = 0.15,
    TeamCheck        = true,
    WallCheck        = true,
    IgnoreFriends    = true,
    TargetPriority   = "Crosshair",    -- "Closest" | "Lowest HP" | "Crosshair"
    ToggleKey        = Enum.KeyCode.G,
    AdaptiveSmooth   = true,
    UseCurve         = true,
    BulletSpeed      = 400,
}

local current_target = nil
local sticky_since   = 0
local last_switch    = 0
local friends        = {}

-- ── ping ──
local function get_ping_sec()
    local ok,p=pcall(function()
        return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    return ok and (p/1000) or 0.05
end

-- ── parte do alvo ──
local function get_hit_part(char,name)
    if name=="Head" then return char:FindFirstChild("Head") end
    if name=="Torso" then return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") end
    if name=="Nearest" then
        local my_hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not my_hrp then return char:FindFirstChild("Head") end
        local best,min_d=nil,math.huge
        for _,p in ipairs(char:GetChildren()) do
            if p:IsA("BasePart") then
                local d=(p.Position-my_hrp.Position).Magnitude
                if d<min_d then min_d,best=d,p end
            end
        end
        return best
    end
    return char:FindFirstChild("Head")
end

-- ── validação ──
local function is_valid(plr)
    if plr==LP then return false end
    if Aimbot.Config.TeamCheck and plr.Team and LP.Team and plr.Team==LP.Team then return false end
    if Aimbot.Config.IgnoreFriends and friends[plr.UserId] then return false end

    local char=plr.Character
    if not char then return false end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health<=0 then return false end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    local my_hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not my_hrp then return false end

    local dist=(hrp.Position-my_hrp.Position).Magnitude
    if dist>Aimbot.Config.MaxDistance then return false end

    -- wall check
    if Aimbot.Config.WallCheck then
        local params=RaycastParams.new()
        params.FilterType=Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances={LP.Character,char}
        local dir=hrp.Position-Camera.CFrame.Position
        local hit=WS:Raycast(Camera.CFrame.Position,dir,params)
        if hit then return false end
    end

    -- fov check (graus → pixels)
    local sp,on=Camera:WorldToViewportPoint(hrp.Position)
    if not on then return false end
    local vp=Camera.ViewportSize
    local dx=sp.X-vp.X/2
    local dy=sp.Y-vp.Y/2
    local sdist=math.sqrt(dx*dx+dy*dy)
    local fov_rad=math.rad(Aimbot.Config.FOVDegrees/2)
    local max_px=math.tan(fov_rad)*(vp.Y/2)/math.tan(math.rad(35))
    if sdist>max_px then return false end

    return true,dist,sdist
end

-- ── seleção ──
local function pick_target()
    local list={}
    for _,plr in ipairs(Players:GetPlayers()) do
        local ok,dist,sdist=is_valid(plr)
        if ok then table.insert(list,{plr=plr,dist=dist,sdist=sdist or math.huge}) end
    end
    if #list==0 then return nil end

    if Aimbot.Config.TargetPriority=="Closest" then
        table.sort(list,function(a,b) return a.dist<b.dist end)
    elseif Aimbot.Config.TargetPriority=="Crosshair" then
        table.sort(list,function(a,b) return a.sdist<b.sdist end)
    elseif Aimbot.Config.TargetPriority=="Lowest HP" then
        table.sort(list,function(a,b)
            local ha=a.plr.Character:FindFirstChildOfClass("Humanoid")
            local hb=b.plr.Character:FindFirstChildOfClass("Humanoid")
            return (ha and ha.Health or 9999)<(hb and hb.Health or 9999)
        end)
    end
    return list[1]
end

-- ── prediction ──
local function predict(part)
    local ping=get_ping_sec()
    local base=Aimbot.Config.PredictionBase
    local vel=part.AssemblyLinearVelocity or Vector3.zero
    local dist=(part.Position-Camera.CFrame.Position).Magnitude
    local lead=base+ping*Aimbot.Config.PingMultiplier*1000
    lead=lead*(1+dist/3000)
    return part.Position+vel*lead
end

-- ── humanização ──
local function apply_curve(cur,target,alpha)
    local t=alpha
    if Aimbot.Config.UseCurve then t=1-(1-t)*(1-t) end
    local lerped=cur:Lerp(target,t)
    if Aimbot.Config.JitterAim then
        local j=Aimbot.Config.JitterAmount*0.008
        lerped=lerped*CFrame.Angles(
            (math.random()-0.5)*j,
            (math.random()-0.5)*j,
            0
        )
    end
    return lerped
end

-- ── loop ──
RunService.RenderStepped:Connect(function()
    if not Aimbot.Enabled or Aimbot.SilentMode then return end
    local now=tick()

    if Aimbot.Config.StickyTarget and current_target then
        if now-sticky_since>Aimbot.Config.StickyDuration then
            current_target=nil
        elseif not is_valid(current_target.plr) then
            current_target=nil
        end
    end

    if not current_target and now-last_switch>Aimbot.Config.TargetSwitchCD then
        current_target=pick_target()
        sticky_since=now
        last_switch=now
    end
    if not current_target then return end

    local char=current_target.plr.Character
    if not char then current_target=nil; return end
    local part=get_hit_part(char,Aimbot.Config.HitPart)
    if not part then return end

    local target_pos=predict(part)
    local target_cf=CFrame.new(Camera.CFrame.Position,target_pos)

    local smooth=Aimbot.Config.Smoothing
    if Aimbot.Config.AdaptiveSmooth then
        local vel=(part.AssemblyLinearVelocity or Vector3.zero).Magnitude
        local sf=math.clamp(vel/100,0,0.6)
        smooth=math.max(0.08,smooth-sf)
    end

    if Aimbot.Config.AimMode=="Instant" then
        Camera.CFrame=target_cf
    else
        Camera.CFrame=apply_curve(Camera.CFrame,target_cf,1-smooth)
    end
end)

-- ── silent aim via Mouse.Hit ──
local mt=getrawmetatable and getrawmetatable(game)
if mt and setreadonly and hookfunction then
    local old=mt.__index
    setreadonly(mt,false)
    mt.__index=newcclosure(function(self,key)
        if self==Mouse and key=="Hit" and Aimbot.Enabled and Aimbot.SilentMode and current_target then
            local char=current_target.plr.Character
            if char then
                local part=get_hit_part(char,Aimbot.Config.HitPart)
                if part then return CFrame.new(Mouse.Origin.Position,predict(part)) end
            end
        end
        return old(self,key)
    end)
    setreadonly(mt,true)
end

-- ── keybind ──
UIS.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode==Aimbot.Config.ToggleKey then Aimbot.toggle() end
end)

function Aimbot.toggle(v)
    Aimbot.Enabled=(v==nil) and not Aimbot.Enabled or v
    if not Aimbot.Enabled then current_target=nil end
end
function Aimbot.set(k,v) Aimbot.Config[k]=v end
function Aimbot.add_friend(plr) friends[plr.UserId]=true end
function Aimbot.remove_friend(plr) friends[plr.UserId]=nil end

_G.Str1kerAimbot=Aimbot
return Aimbot
