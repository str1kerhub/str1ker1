-- language: Luau, file: aimbot.lua, target: Delta / Krnl / Codex
-- Str1ker Aimbot v6 — silent aim + botão flutuante

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local WS         = game:GetService("Workspace")
local Camera     = WS.CurrentCamera
local LP         = Players.LocalPlayer
local Mouse      = LP:GetMouse()

local Aimbot = {Enabled=false}
Aimbot.Config = {
    MaxDistance    = 500,
    FOVDegrees     = 30,
    PredictionBase = 0.14,
    PingMultiplier = 0.002,
    TeamCheck      = true,
    WallCheck      = true,
    IgnoreFriends  = true,
    TargetPriority = "Crosshair",
    ToggleKey      = Enum.KeyCode.G,
    HitChance      = 100,
    LockTime       = 0.15,
    ShowButton     = true,
}

local current_target = nil
local locked_since   = 0
local friends        = {}

-- ═══════════════ BOTÃO FLUTUANTE ═══════════════
local buttonGui, button, label, dot
local function create_button()
    local parent = (gethui and gethui()) or LP:WaitForChild("PlayerGui")
    buttonGui = Instance.new("ScreenGui")
    buttonGui.Name = "Str1kerAimbotBtn"
    buttonGui.ResetOnSpawn = false
    buttonGui.IgnoreGuiInset = true
    buttonGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    buttonGui.Parent = parent

    button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(130, 40)
    button.Position = UDim2.new(0, 20, 0.5, -20)
    button.BackgroundColor3 = Color3.fromRGB(8, 14, 28)
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.Active = true
    button.Draggable = true
    button.Parent = buttonGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Name = "Border"
    stroke.Color = Color3.fromRGB(96, 165, 250)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3
    stroke.Parent = button

    dot = Instance.new("Frame")
    dot.Size = UDim2.fromOffset(8, 8)
    dot.Position = UDim2.new(0, 12, 0.5, -4)
    dot.BackgroundColor3 = Color3.fromRGB(120, 130, 150)
    dot.BorderSizePixel = 0
    dot.Parent = button
    local dc = Instance.new("UICorner")
    dc.CornerRadius = UDim.new(1, 0)
    dc.Parent = dot

    label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.fromOffset(28, 0)
    label.BackgroundTransparency = 1
    label.Text = "AIMBOT OFF"
    label.TextColor3 = Color3.fromRGB(140, 156, 184)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = button

    button.MouseButton1Click:Connect(function()
        Aimbot.toggle()
    end)
end

local function update_button()
    if not button then return end
    if Aimbot.Enabled then
        button.BackgroundColor3 = Color3.fromRGB(10, 30, 50)
        button.Border.Color = Color3.fromRGB(70, 220, 110)
        dot.BackgroundColor3 = Color3.fromRGB(70, 220, 110)
        label.Text = "AIMBOT ON"
        label.TextColor3 = Color3.fromRGB(240, 244, 252)
    else
        button.BackgroundColor3 = Color3.fromRGB(8, 14, 28)
        button.Border.Color = Color3.fromRGB(96, 165, 250)
        dot.BackgroundColor3 = Color3.fromRGB(120, 130, 150)
        label.Text = "AIMBOT OFF"
        label.TextColor3 = Color3.fromRGB(140, 156, 184)
    end
end

-- ═══════════════ HELPERS ═══════════════
local function get_ping_sec()
    local ok,p=pcall(function()
        return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    return ok and (p/1000) or 0.05
end

local function get_torso(char)
    return char:FindFirstChild("UpperTorso")
        or char:FindFirstChild("Torso")
        or char:FindFirstChild("HumanoidRootPart")
end

local function is_valid(plr)
    if plr==LP then return false end
    if Aimbot.Config.TeamCheck and plr.Team and LP.Team and plr.Team==LP.Team then return false end
    if Aimbot.Config.IgnoreFriends and friends[plr.UserId] then return false end

    local char=plr.Character
    if not char then return false end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health<=0 then return false end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    local my=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not my then return false end

    local dist=(hrp.Position-my.Position).Magnitude
    if dist>Aimbot.Config.MaxDistance then return false end

    if Aimbot.Config.WallCheck then
        local params=RaycastParams.new()
        params.FilterType=Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances={LP.Character,char}
        local dir=hrp.Position-Camera.CFrame.Position
        local hit=WS:Raycast(Camera.CFrame.Position,dir,params)
        if hit then return false end
    end

    local sp,on=Camera:WorldToViewportPoint(hrp.Position)
    if not on then return false end
    local vp=Camera.ViewportSize
    local dx,dy=sp.X-vp.X/2,sp.Y-vp.Y/2
    local sdist=math.sqrt(dx*dx+dy*dy)
    local fov_rad=math.rad(Aimbot.Config.FOVDegrees/2)
    local max_px=math.tan(fov_rad)*(vp.Y/2)/math.tan(math.rad(35))
    if sdist>max_px then return false end
    return true,dist,sdist
end

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

local function predict(part)
    local ping=get_ping_sec()
    local base=Aimbot.Config.PredictionBase
    local vel=part.AssemblyLinearVelocity or Vector3.zero
    local dist=(part.Position-Camera.CFrame.Position).Magnitude
    local lead=base+ping*Aimbot.Config.PingMultiplier*1000
    lead=lead*(1+dist/3000)
    return part.Position+vel*lead
end

local function get_silent_target_pos()
    if not Aimbot.Enabled then return nil end
    local now=tick()

    if current_target and (now-locked_since)<Aimbot.Config.LockTime then
        -- mantém
    else
        if current_target and not is_valid(current_target.plr) then current_target=nil end
        if not current_target then
            current_target=pick_target()
            locked_since=now
        end
    end

    if not current_target then return nil end

    if Aimbot.Config.HitChance<100 then
        if math.random(1,100)>Aimbot.Config.HitChance then return nil end
    end

    local char=current_target.plr.Character
    if not char then return nil end
    local part=get_torso(char)
    if not part then return nil end
    return predict(part)
end

-- ═══════════════ HOOKS ═══════════════
local mt=getrawmetatable and getrawmetatable(game)
if mt and setreadonly and hookfunction then
    local old_index=mt.__index
    setreadonly(mt,false)
    mt.__index=newcclosure(function(self,key)
        if self==Mouse then
            local pos=get_silent_target_pos()
            if pos then
                if key=="Hit" then
                    return CFrame.new(Mouse.Origin.Position,pos)
                elseif key=="UnitRay" then
                    return Ray.new(Mouse.Origin.Position,(pos-Mouse.Origin.Position).Unit)
                elseif key=="Target" then
                    local char=current_target and current_target.plr.Character
                    if char then return get_torso(char) end
                end
            end
        end
        return old_index(self,key)
    end)
    setreadonly(mt,true)
end

RunService.Heartbeat:Connect(function()
    if not Aimbot.Enabled then current_target=nil; return end
    if current_target and not is_valid(current_target.plr) then current_target=nil end
end)

UIS.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode==Aimbot.Config.ToggleKey then Aimbot.toggle() end
end)

-- ═══════════════ API ═══════════════
function Aimbot.toggle(v)
    Aimbot.Enabled=(v==nil) and not Aimbot.Enabled or v
    if not Aimbot.Enabled then current_target=nil end
    update_button()
end

function Aimbot.set(k,v) Aimbot.Config[k]=v end
function Aimbot.add_friend(plr) friends[plr.UserId]=true end
function Aimbot.remove_friend(plr) friends[plr.UserId]=nil end

function Aimbot.destroy_button()
    if buttonGui then buttonGui:Destroy() end
end

-- ═══════════════ BOOT ═══════════════
if Aimbot.Config.ShowButton then
    create_button()
    update_button()
end

_G.Str1kerAimbot=Aimbot
return Aimbot
