-- language: Luau, file: str1ker_pvp.lua, target: Delta / Krnl / Codex
-- Str1ker PvP — aimbot + ESP + attack functions

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local WS         = game:GetService("Workspace")
local RS         = game:GetService("ReplicatedStorage")
local Camera     = WS.CurrentCamera
local LP         = Players.LocalPlayer

local PVP = {Enabled=false}
PVP.Config = {
    -- aimbot
    Aimbot           = false,
    SilentAim        = false,
    AimKey           = Enum.KeyCode.E,
    HoldKey          = true,
    FOV              = 30,
    MaxDistance      = 500,
    TeamCheck        = true,
    VisibleCheck     = false,
    TargetPriority   = "Crosshair",
    Prediction       = 0.165,
    ShowFOV          = true,
    FOVColor         = Color3.fromRGB(80, 150, 255),
    ShowTargetBox    = true,
    ShowTracer       = false,
    TracerColor      = Color3.fromRGB(80, 150, 255),

    -- attack
    AttackNoAnim     = true,
    AoeRange         = 80,
    FastAttack       = false,
    SuperFastAttack  = false,
    AutoClickM1      = false,
    AutoClickDelay   = 0.1,

    -- gun
    GunPredict       = true,

    -- esp
    ESP_Player       = false,
    ESP_PlayerName   = true,
    ESP_PlayerHP     = true,
    ESP_PlayerDist   = true,
    ESP_PlayerTracer = true,
    ESP_PlayerBox    = false,
    ESP_Fruit        = false,
    ESP_Island       = false,
    ESP_Berry        = false,
    ESP_MaxDist      = 3000,
}

local state = {
    current_target = nil,
    locked_since   = 0,
    aim_pos        = nil,
    friends        = {},
    ray_cache      = {},
    drawing        = { players = {}, fruits = {}, islands = {}, berries = {} },
}

-- ═══════════════ BANANA CAT FIRE-SERVER HOOK (silent aim) ═══════════════
-- Foi assim que o Banana Cat fez: intercepta FireServer e troca Vector3/CFrame
-- args do ataque pelo AimPos. É o que realmente funciona no BF.
local mt = getrawmetatable and getrawmetatable(game)
local hook_installed = false
if mt and setreadonly and hookfunction and newcclosure then
    local OldNameCall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local Method = getnamecallmethod and getnamecallmethod() or ""
        local Args = {...}

        if Method == "FireServer"
            and self.Name == "RemoteEvent"
            and PVP.Enabled
            and PVP.Config.SilentAim
            and state.aim_pos
            and tostring(state.aim_pos.X) ~= "nan"
            and not (checkcaller and checkcaller())
        then
            if #Args == 1 and typeof(Args[1]) == "Vector3" then
                Args[1] = state.aim_pos.Position
            elseif #Args == 1 and typeof(Args[1]) == "CFrame" then
                Args[1] = state.aim_pos
            end
        end

        return OldNameCall(self, unpack(Args))
    end)
    setreadonly(mt, true)
    hook_installed = true
end

-- ═══════════════ DRAWING ═══════════════
local DRAW = Drawing or (syn and syn.drawing) or (Krnl and Krnl.Drawing)
local can_draw = DRAW ~= nil

local fov_circle, target_box, target_tracer
if can_draw then
    fov_circle = DRAW.new("Circle")
    fov_circle.Thickness = 1.5
    fov_circle.NumSides = 60
    fov_circle.Filled = false
    fov_circle.Color = PVP.Config.FOVColor
    fov_circle.Visible = false

    target_box = DRAW.new("Square")
    target_box.Thickness = 1.5
    target_box.Filled = false
    target_box.Color = Color3.fromRGB(70, 220, 110)
    target_box.Visible = false

    target_tracer = DRAW.new("Line")
    target_tracer.Thickness = 1.5
    target_tracer.Color = PVP.Config.TracerColor
    target_tracer.Visible = false
end

-- ═══════════════ HELPERS ═══════════════
local function get_hrp()
    local char = LP.Character
    return char and char:FindFirstChild("HumanoidRootPart") or nil
end

local function get_hum(plr)
    local char = plr.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return nil end
    return hum
end

local function w2s(pos)
    local sp, on = Camera:WorldToViewportPoint(pos)
    if not on or sp.Z < 0 then return nil end
    return Vector2.new(sp.X, sp.Y)
end

local function get_fov_px()
    local vp = Camera.ViewportSize
    return math.tan(math.rad(PVP.Config.FOV / 2))
        / math.tan(math.rad(Camera.FieldOfView / 2))
        * (vp.Y / 2)
end

local function is_valid_target(plr)
    if plr == LP then return false, "self" end
    if PVP.Config.TeamCheck and plr.Team and LP.Team and plr.Team == LP.Team then
        return false, "team"
    end
    if state.friends[plr.UserId] then return false, "friend" end

    local char = plr.Character
    if not char then return false, "no char" end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false, "dead" end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local my = get_hrp()
    if not hrp or not my then return false, "no hrp" end

    local dist = (hrp.Position - my.Position).Magnitude
    if dist > PVP.Config.MaxDistance then return false, "far" end

    if PVP.Config.VisibleCheck then
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { LP.Character, char }
        local dir = hrp.Position - Camera.CFrame.Position
        if WS:Raycast(Camera.CFrame.Position, dir, params) then
            return false, "wall"
        end
    end

    local sp, on = Camera:WorldToViewportPoint(hrp.Position)
    if not on then return false, "offscreen" end
    local vp = Camera.ViewportSize
    local dx, dy = sp.X - vp.X / 2, sp.Y - vp.Y / 2
    local sdist = math.sqrt(dx * dx + dy * dy)
    if sdist > get_fov_px() then return false, "out fov" end

    return true, dist, sdist
end

-- ═══════════════ TARGET SELECTION ═══════════════
function PVP.ClosestTarget()
    local my = get_hrp()
    if not my then return nil end
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        local ok, dist, sdist = is_valid_target(plr)
        if ok then
            table.insert(list, { plr=plr, dist=dist, sdist=sdist or math.huge })
        end
    end
    if #list == 0 then return nil end
    if PVP.Config.TargetPriority == "Closest" then
        table.sort(list, function(a,b) return a.dist < b.dist end)
    elseif PVP.Config.TargetPriority == "Lowest HP" then
        table.sort(list, function(a,b)
            local ha = a.plr.Character:FindFirstChildOfClass("Humanoid")
            local hb = b.plr.Character:FindFirstChildOfClass("Humanoid")
            return (ha and ha.Health or 9999) < (hb and hb.Health or 9999)
        end)
    else
        table.sort(list, function(a,b) return a.sdist < b.sdist end)
    end
    return list[1]
end

function PVP.ClosestModel() -- retorna o Model direto (formato Banana Cat)
    local t = PVP.ClosestTarget()
    return t and t.plr.Character or nil, t and t.plr or nil
end

-- ═══════════════ AIMBOT LOOP ═══════════════
local aim_key_down = false
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == PVP.Config.AimKey then aim_key_down = true end
end)
UIS.InputEnded:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == PVP.Config.AimKey then aim_key_down = false end
end)

local function aimbot_active()
    if not PVP.Enabled then return false end
    if not PVP.Config.Aimbot and not PVP.Config.SilentAim then return false end
    if PVP.Config.HoldKey then return aim_key_down end
    return true
end

local function predict_position(part)
    local ping = 0.05
    pcall(function()
        ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
    end)
    local lead = PVP.Config.Prediction + ping * 0.5
    local vel = part.AssemblyLinearVelocity or Vector3.zero
    if vel.Magnitude < 1 then vel = Vector3.zero end
    return part.Position + vel * lead
end

RunService.RenderStepped:Connect(function()
    if not aimbot_active() then
        state.current_target = nil
        state.aim_pos = nil
        if fov_circle then fov_circle.Visible = false end
        if target_box then target_box.Visible = false end
        if target_tracer then target_tracer.Visible = false end
        return
    end

    -- lock alvo
    local now = tick()
    if state.current_target and (not state.current_target.Character
        or not state.current_target.Character:FindFirstChild("HumanoidRootPart")) then
        state.current_target = nil
    end
    if not state.current_target or now - state.locked_since > 0.15 then
        local t = PVP.ClosestTarget()
        state.current_target = t and t.plr or nil
        state.locked_since = now
    end

    if not state.current_target then
        state.aim_pos = nil
        if target_box then target_box.Visible = false end
        if target_tracer then target_tracer.Visible = false end
        return
    end

    local char = state.current_target.Character
    if not char then return end
    local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    if not head then return end
    local pos = predict_position(head)

    state.aim_pos = CFrame.new(Camera.CFrame.Position, pos)

    -- aimbot de camera (só se SilentAim estiver off)
    if PVP.Config.Aimbot and not PVP.Config.SilentAim then
        Camera.CFrame = Camera.CFrame:Lerp(state.aim_pos, 0.35)
    end

    -- HUD
    if target_box and PVP.Config.ShowTargetBox then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local top = w2s(head.Position + Vector3.new(0,1,0))
            local bot = w2s(hrp.Position - Vector3.new(0,2.5,0))
            if top and bot then
                local h = math.abs(bot.Y - top.Y)
                local w = math.max(math.abs(bot.X - top.X), h * 0.6)
                target_box.From = Vector2.new(top.X - w/2, top.Y)
                target_box.To   = Vector2.new(top.X + w/2, bot.Y)
                target_box.Visible = true
                if target_tracer and PVP.Config.ShowTracer then
                    local vp = Camera.ViewportSize
                    target_tracer.From = Vector2.new(vp.X/2, vp.Y)
                    target_tracer.To   = Vector2.new(top.X, bot.Y)
                    target_tracer.Visible = true
                end
            end
        end
    end
end)

-- FOV circle
RunService.RenderStepped:Connect(function()
    if not fov_circle then return end
    if not PVP.Config.ShowFOV or not (PVP.Config.Aimbot or PVP.Config.SilentAim) then
        fov_circle.Visible = false
        return
    end
    local vp = Camera.ViewportSize
    fov_circle.Position = Vector2.new(vp.X/2, vp.Y/2)
    fov_circle.Radius = get_fov_px()
    fov_circle.Color = PVP.Config.FOVColor
    fov_circle.Visible = true
end)

-- ═══════════════ ESP — PLAYER ═══════════════
local function make_esp_for_player(plr)
    if not can_draw then return end
    local box   = DRAW.new("Square")
    box.Thickness = 1.5
    box.Filled = false
    box.Color = Color3.fromRGB(255, 80, 80)
    box.Visible = false

    local name  = DRAW.new("Text")
    name.Size = 14; name.Center = true; name.Outline = true
    name.Color = Color3.fromRGB(240,244,252); name.OutlineColor = Color3.fromRGB(0,0,0)
    name.Font = 2; name.Visible = false

    local hp    = DRAW.new("Text")
    hp.Size = 12; hp.Center = true; hp.Outline = true
    hp.Color = Color3.fromRGB(70,220,110); hp.OutlineColor = Color3.fromRGB(0,0,0)
    hp.Font = 2; hp.Visible = false

    local dist  = DRAW.new("Text")
    dist.Size = 12; dist.Center = true; dist.Outline = true
    dist.Color = Color3.fromRGB(200,215,235); dist.OutlineColor = Color3.fromRGB(0,0,0)
    dist.Font = 2; dist.Visible = false

    local tracer = DRAW.new("Line")
    tracer.Thickness = 1.5
    tracer.Color = Color3.fromRGB(255, 80, 80)
    tracer.Visible = false

    state.drawing.players[plr] = { box=box, name=name, hp=hp, dist=dist, tracer=tracer }
end

local function remove_esp_for_player(plr)
    local e = state.drawing.players[plr]
    if not e then return end
    for _, obj in pairs(e) do
        pcall(function() obj:Remove() end)
    end
    state.drawing.players[plr] = nil
end

local function render_player_esp(plr)
    if not can_draw then return end
    if plr == LP then return end
    if PVP.Config.TeamCheck and plr.Team and LP.Team and plr.Team == LP.Team then
        local e = state.drawing.players[plr]
        if e then for _, o in pairs(e) do o.Visible = false end end
        return
    end

    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not head or not hum or hum.Health <= 0 then return end

    local my = get_hrp()
    if not my then return end
    local dist = (hrp.Position - my.Position).Magnitude
    if dist > PVP.Config.ESP_MaxDist then
        local e = state.drawing.players[plr]
        if e then for _, o in pairs(e) do o.Visible = false end end
        return
    end

    local e = state.drawing.players[plr]
    if not e then
        make_esp_for_player(plr)
        e = state.drawing.players[plr]
    end

    local top = w2s(head.Position + Vector3.new(0, 1, 0))
    local bot = w2s(hrp.Position - Vector3.new(0, 2.8, 0))
    if not top or not bot then
        for _, o in pairs(e) do o.Visible = false end
        return
    end

    local h = math.abs(bot.Y - top.Y)
    local w = math.max(math.abs(bot.X - top.X), h * 0.55)
    local cx = top.X

    if PVP.Config.ESP_PlayerBox then
        e.box.From = Vector2.new(top.X - w/2, top.Y)
        e.box.To   = Vector2.new(top.X + w/2, bot.Y)
        e.box.Visible = true
    else
        e.box.Visible = false
    end

    if PVP.Config.ESP_PlayerName then
        e.name.Position = Vector2.new(cx, top.Y - 16)
        e.name.Text = plr.DisplayName or plr.Name
        e.name.Visible = true
    else
        e.name.Visible = false
    end

    if PVP.Config.ESP_PlayerHP then
        e.hp.Position = Vector2.new(cx, bot.Y + 4)
        e.hp.Text = string.format("%d/%d", math.floor(hum.Health), math.floor(hum.MaxHealth))
        e.hp.Visible = true
    else
        e.hp.Visible = false
    end

    if PVP.Config.ESP_PlayerDist then
        e.dist.Position = Vector2.new(cx, bot.Y + (PVP.Config.ESP_PlayerHP and 18 or 4))
        e.dist.Text = string.format("[%dm]", math.floor(dist))
        e.dist.Visible = true
    else
        e.dist.Visible = false
    end

    if PVP.Config.ESP_PlayerTracer then
        local vp = Camera.ViewportSize
        e.tracer.From = Vector2.new(vp.X/2, vp.Y)
        e.tracer.To = Vector2.new(cx, bot.Y)
        e.tracer.Visible = true
    else
        e.tracer.Visible = false
    end
end

RunService.RenderStepped:Connect(function()
    if not PVP.Config.ESP_Player then
        for _, e in pairs(state.drawing.players) do
            for _, o in pairs(e) do o.Visible = false end
        end
        return
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        pcall(render_player_esp, plr)
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    remove_esp_for_player(plr)
end)

-- ═══════════════ ESP — FRUIT ═══════════════
local fruit_mesh_names = {
    ["rbxassetid://15100283484"] = "Light Fruit",
    ["rbxassetid://15116730102"] = "Love Fruit",
    ["rbxassetid://15100273645"] = "Dough Fruit",
    ["rbxassetid://15116967784"] = "Spider Fruit",
    ["rbxassetid://15112263502"] = "Shadow Fruit",
    ["rbxassetid://15104782377"] = "Blade Fruit",
    ["rbxassetid://15106768588"] = "Leopard Fruit",
    ["rbxassetid://15112469964"] = "Falcon Fruit",
    ["rbxassetid://15708895165"] = "T-Rex Fruit",
    ["rbxassetid://19001642259"] = "Dragon (East) Fruit",
    ["rbxassetid://86024571204851"] = "Gas Fruit",
    ["rbxassetid://15100246632"] = "Phoenix Fruit",
    ["rbxassetid://14661873358"] = "Sound Fruit",
    ["rbxassetid://15111584216"] = "Flame Fruit",
    ["rbxassetid://15105281957"] = "Spring Fruit",
    ["rbxassetid://15116740364"] = "Bomb Fruit",
    ["rbxassetid://15104817760"] = "Rubber Fruit",
    ["rbxassetid://15057683975"] = "Spin Fruit",
    ["rbxassetid://15105350415"] = "Magma Fruit",
    ["rbxassetid://15482881956"] = "Kitsune Fruit",
    ["rbxassetid://15100485671"] = "Barrier Fruit",
    ["rbxassetid://18955022385"] = "Dragon (West) Fruit",
    ["rbxassetid://101378450824208"] = "Yeti Fruit",
    ["rbxassetid://15116721173"] = "Pain Fruit",
    ["rbxassetid://11908375285"] = "Spirit Fruit",
    ["rbxassetid://15100433167"] = "Ice Fruit",
    ["rbxassetid://15100299740"] = "Gravity Fruit",
    ["rbxassetid://15107005807"] = "Spike Fruit",
    ["rbxassetid://15116696973"] = "Smoke Fruit",
    ["rbxassetid://15112600534"] = "Diamond Fruit",
    ["rbxassetid://15112333093"] = "Ghost Fruit",
    ["rbxassetid://15057718441"] = "Quake Fruit",
    ["rbxassetid://15111517529"] = "Sand Fruit",
    ["rbxassetid://15100313696"] = "Buddha Fruit",
    ["rbxassetid://15116747420"] = "Rumble Fruit",
    ["rbxassetid://15100384816"] = "Blizzard Fruit",
    ["rbxassetid://15111553409"] = "Dark Fruit",
    ["rbxassetid://14661837634"] = "Mammoth Fruit",
    ["rbxassetid://15100184583"] = "Control Fruit",
}
local fruit_colors = {
    ["Leopard Fruit"] = Color3.fromRGB(255,170,0),
    ["Dragon (East) Fruit"] = Color3.fromRGB(255,0,0),
    ["Dragon (West) Fruit"] = Color3.fromRGB(255,80,80),
    ["Kitsune Fruit"] = Color3.fromRGB(200,100,255),
    ["Spirit Fruit"] = Color3.fromRGB(120,200,255),
    ["Venom Fruit"] = Color3.fromRGB(180,60,200),
    ["Dough Fruit"] = Color3.fromRGB(255,220,180),
    ["Light Fruit"] = Color3.fromRGB(255,255,150),
}

local function resolve_fruit_name(inst)
    if inst.ClassName == "Tool" then return inst.Name end
    local found_meshes = {}
    for _, d in ipairs(inst:GetDescendants()) do
        if d:IsA("MeshPart") then table.insert(found_meshes, d.MeshId) end
    end
    for mesh, name in pairs(fruit_mesh_names) do
        if table.find(found_meshes, mesh) then return name end
    end
    return nil
end

local function get_ground_fruit()
    for _, inst in ipairs(WS:GetChildren()) do
        if (inst:IsA("Tool") or inst:IsA("Model")) and inst.Name:find("Fruit") then
            return inst
        end
    end
end

RunService.RenderStepped:Connect(function()
    if not PVP.Config.ESP_Fruit or not can_draw then
        for inst, e in pairs(state.drawing.fruits) do
            if e.text then e.text.Visible = false end
            if e.box then e.box.Visible = false end
        end
        return
    end

    local inst = get_ground_fruit()
    if not inst then return end
    local handle = inst:FindFirstChild("Handle")
    if not handle then return end

    local key = inst
    local e = state.drawing.fruits[key]
    if not e then
        local text = DRAW.new("Text")
        text.Size = 18; text.Center = true; text.Outline = true
        text.OutlineColor = Color3.fromRGB(0,0,0); text.Font = 2
        local box = DRAW.new("Square")
        box.Filled = true; box.Transparency = 0.4
        box.Color = Color3.fromRGB(0,0,0)
        e = { text=text, box=box }
        state.drawing.fruits[key] = e
    end

    local fruit_name = resolve_fruit_name(inst) or "Fruit"
    local color = fruit_colors[fruit_name] or Color3.fromRGB(255,255,255)
    local sp, on = Camera:WorldToViewportPoint(handle.Position)
    if on and sp.Z > 0 then
        local my = get_hrp()
        local dist = my and (handle.Position - my.Position).Magnitude or 0
        e.text.Text = fruit_name .. " [" .. math.floor(dist) .. "m]"
        e.text.Position = Vector2.new(sp.X, sp.Y - 20)
        e.text.Color = color
        e.text.Visible = true

        local bounds = e.text.TextBounds
        e.box.Position = Vector2.new(e.text.Position.X - bounds.X/2 - 4, e.text.Position.Y - 2)
        e.box.Size = Vector2.new(bounds.X + 8, bounds.Y + 4)
        e.box.Visible = true
    else
        e.text.Visible = false
        e.box.Visible = false
    end
end)

-- ═══════════════ ESP — ISLAND ═══════════════
RunService.RenderStepped:Connect(function()
    if not PVP.Config.ESP_Island or not can_draw then
        for _, e in pairs(state.drawing.islands) do
            if e.text then e.text.Visible = false end
        end
        return
    end

    local locs = WS:FindFirstChild("_WorldOrigin") and WS._WorldOrigin:FindFirstChild("Locations")
    if not locs then return end

    for _, loc in ipairs(locs:GetChildren()) do
        local cf = loc:GetAttribute("CFrame")
        if cf then
            local e = state.drawing.islands[loc]
            if not e then
                local text = DRAW.new("Text")
                text.Size = 16; text.Center = true; text.Outline = true
                text.Color = Color3.fromRGB(180, 220, 255)
                text.OutlineColor = Color3.fromRGB(0,0,0)
                text.Font = 2
                e = { text=text }
                state.drawing.islands[loc] = e
            end
            local sp, on = Camera:WorldToViewportPoint(cf.Position)
            if on and sp.Z > 0 then
                local my = get_hrp()
                local dist = my and (cf.Position - my.Position).Magnitude or 0
                e.text.Text = loc.Name .. " [" .. math.floor(dist) .. "m]"
                e.text.Position = Vector2.new(sp.X, sp.Y)
                e.text.Visible = true
            else
                e.text.Visible = false
            end
        end
    end
end)

-- ═══════════════ ESP — BERRY ═══════════════
local berry_colors = {
    Azure = Color3.fromRGB(0, 170, 255),
    Magma = Color3.fromRGB(255, 80, 0),
    Green = Color3.fromRGB(0, 255, 100),
    Pale = Color3.fromRGB(200, 200, 200),
    Purple = Color3.fromRGB(170, 0, 255),
    Yellow = Color3.fromRGB(255, 220, 0),
    Blue = Color3.fromRGB(0, 80, 255),
    Red = Color3.fromRGB(255, 0, 0),
    Pink = Color3.fromRGB(255, 100, 180),
    White = Color3.fromRGB(255, 255, 255),
}
local function get_berry_color(inst)
    local attrs = inst:GetAttributes()
    for name, _ in pairs(attrs) do
        for key, color in pairs(berry_colors) do
            if string.find(string.lower(name), string.lower(key)) then
                return color, name
            end
        end
    end
    return Color3.fromRGB(255,255,255), "Berry"
end

RunService.RenderStepped:Connect(function()
    if not PVP.Config.ESP_Berry or not can_draw then
        for _, e in pairs(state.drawing.berries) do
            if e.text then e.text.Visible = false end
        end
        return
    end

    local bushes = game:GetService("CollectionService"):GetTagged("BerryBush")
    for _, bush in ipairs(bushes) do
        local cf_attr = bush.Parent:GetAttribute("CFrame") or bush:GetAttribute("CFrame")
        if cf_attr then
            local e = state.drawing.berries[bush]
            if not e then
                local text = DRAW.new("Text")
                text.Size = 14; text.Center = true; text.Outline = true
                text.OutlineColor = Color3.fromRGB(0,0,0)
                text.Font = 2
                e = { text=text }
                state.drawing.berries[bush] = e
            end
            local color, bname = get_berry_color(bush)
            local sp, on = Camera:WorldToViewportPoint(cf_attr.Position)
            if on and sp.Z > 0 then
                local my = get_hrp()
                local dist = my and (cf_attr.Position - my.Position).Magnitude or 0
                e.text.Text = bname .. " [" .. math.floor(dist) .. "m]"
                e.text.Position = Vector2.new(sp.X, sp.Y - 20)
                e.text.Color = color
                e.text.Visible = true
            else
                e.text.Visible = false
            end
        end
    end
end)

-- ═══════════════ ATTACK FUNCTIONS ═══════════════
local Net          = RS:FindFirstChild("Modules") and RS.Modules:FindFirstChild("Net")
local CombatUtil   = RS:FindFirstChild("Modules") and RS.Modules:FindFirstChild("CombatUtil")
local RegisterAttack = Net and Net:FindFirstChild("RE/RegisterAttack")
local RegisterHit    = Net and Net.RemoteEvent and (pcall(function() return Net:RemoteEvent("RegisterHit", true) end) and Net:RemoteEvent("RegisterHit", true) or nil)

local function get_register_hit()
    if RegisterHit then return RegisterHit end
    pcall(function()
        RegisterHit = Net:RemoteEvent("RegisterHit", true)
    end)
    return RegisterHit
end

local function get_rig_of_part(part)
    if CombatUtil then
        local ok, rig = pcall(function() return CombatUtil:GetRigOfHitPart(part) end)
        if ok and rig then return rig end
    end
    for _, c in ipairs(WS:FindFirstChild("Characters") and WS.Characters:GetChildren() or {}) do
        if part:IsDescendantOf(c) then return c end
    end
    for _, e in ipairs(WS:FindFirstChild("Enemies") and WS.Enemies:GetChildren() or {}) do
        if part:IsDescendantOf(e) then return e end
    end
    return nil
end

local function get_parts_in_range(model, origin, range)
    local found = {}
    for _, part in ipairs(model:GetChildren()) do
        if part:IsA("BasePart") and (part.Position - origin).Magnitude <= range then
            table.insert(found, part)
        end
    end
    return found
end

-- getBladeHits — retorna lista de peças hittadas
function PVP.getBladeHits(char, origin, range, includePlayers)
    local hits = {}
    local list = {}
    for _, e in ipairs(WS.Enemies:GetChildren()) do table.insert(list, e) end
    if includePlayers then
        for _, c in ipairs(WS.Characters:GetChildren()) do table.insert(list, c) end
    end

    for _, model in ipairs(list) do
        if model:IsDescendantOf(WS) and model ~= char and model:FindFirstChild("HumanoidRootPart") then
            local hrp = model.HumanoidRootPart
            local player_bonus = includePlayers and Players:GetPlayerFromCharacter(model) and range or range
            local positions = { hrp.Position }
            if hrp.Size.Y > 5 then
                table.insert(positions, (hrp.CFrame * CFrame.new(0, -hrp.Size.Y * 1.5 + 3, 0)).Position)
            end
            for _, p in ipairs(positions) do
                if (p - origin[1].Position).Magnitude < 10 + player_bonus + hrp.Size.X / 2 then
                    for _, part in ipairs(get_parts_in_range(model, origin[1].Position, player_bonus + hrp.Size.X / 2)) do
                        table.insert(hits, part)
                    end
                    break
                end
            end
        end
    end
    return hits
end

-- AttackAOE — retorna lista {rig, part} de válidos
function PVP.AttackAOE(range, includePlayers)
    local char = LP.Character
    local my_hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not my_hrp then return nil end

    local hits = PVP.getBladeHits(char, { my_hrp }, range or PVP.Config.AoeRange, includePlayers)
    local vuln_parts = {
        RightUpperArm = true, RightLowerArm = true, RightHand = true,
        RightUpperLeg = true, RightLowerLeg = true, RightFoot = true,
        LeftUpperArm = true, LeftLowerArm = true, LeftHand = true,
        LeftUpperLeg = true, LeftLowerLeg = true, LeftFoot = true,
        UpperTorso = true, LowerTorso = true, Head = true,
    }
    local result = {}
    local seen = {}
    for _, part in ipairs(hits) do
        local rig = get_rig_of_part(part)
        if rig and not seen[rig] and vuln_parts[part.Name] then
            if CombatUtil and CombatUtil:IsVulnerable(rig) then
                local summoner = rig:FindFirstChild("Summoner")
                local my_summoner = char:FindFirstChild("Summoner")
                local is_self = rig == char
                local is_own_summon = my_summoner and rig == my_summoner.Value.Character
                local is_their_summon = summoner and Players:GetPlayerFromCharacter(char) == summoner.Value
                if not is_self and not is_own_summon and not is_their_summon then
                    table.insert(result, { rig, part })
                    seen[rig] = true
                end
            end
        end
    end
    return #result > 0 and result or nil
end

-- AttackFunction — dispara o hit pros alvos
function PVP.Attack(range, includePlayers)
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    if char:FindFirstChild("Stun") and char.Stun.Value ~= 0 then return end

    local targets = PVP.AttackAOE(range or PVP.Config.AoeRange, includePlayers)
    if not targets then return end

    local hit = get_register_hit()
    if not hit then return end
    if RegisterAttack then RegisterAttack:FireServer(0) end
    local first = table.remove(targets, 1)
    hit:FireServer(first[2], targets)
end

-- Attack melee com animação (usa combat framework cache)
function PVP.AttackMelee(range)
    local char = LP.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    local targets = PVP.AttackAOE(range or PVP.Config.AoeRange, false)
    if not targets then return end
    PVP.Attack(range or PVP.Config.AoeRange, false)
end

-- Fruit M1
function PVP.UseFruitM1(target, useBoat)
    local char = LP.Character
    if not char then return false end
    local fruit_name = nil
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") and t.Name:find("Fruit") then
            fruit_name = t.Name
            break
        end
    end
    if not fruit_name then
        local backpack = LP:FindFirstChild("Backpack")
        for _, t in ipairs(backpack and backpack:GetChildren() or {}) do
            if t:IsA("Tool") and t.Name:find("Fruit") then
                hum:EquipTool(t)
                fruit_name = t.Name
                break
            end
        end
    end
    if not fruit_name then return false end
    local tool = char:FindFirstChild(fruit_name)
    if not tool then return false end

    local lcr = tool:FindFirstChild("LeftClickRemote")
    local rf  = tool:FindFirstChild("RemoteFunction")
    local re  = tool:FindFirstChild("RemoteEvent")

    if lcr and fruit_name == "Mammoth-Mammoth" then
        lcr:FireServer(target.Position)
        return true
    end
    if lcr then
        local combo = math.random(1, 5)
        lcr:FireServer(target.Position, combo)
        return true
    end
    if rf then
        rf:InvokeServer("TAP")
        if re then re:FireServer(target.Position) end
        return true
    end
    return false
end

-- Gun shoot
function PVP.ShootM1(target)
    local char = LP.Character
    if not char then return end
    local gun_name = nil
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") and t.ToolTip == "Gun" then gun_name = t.Name; break end
    end
    if not gun_name then return end
    local gun = char:FindFirstChild(gun_name)
    if not gun then return end

    local CombatUtil2 = CombatUtil
    if CombatUtil2 and CombatUtil2:IsGunReloading(gun) then return end

    -- Skull Guitar / Dragonstorm TAP
    if gun_name == "Skull Guitar" then
        local re = gun:FindFirstChild("RemoteEvent")
        if re then re:FireServer("TAP", target.Position) end
        return
    end
    if gun_name == "Dragonstorm" then
        local ok = pcall(function()
            local controller = require(RS.Controllers.CombatController).Attack
            local ups = getupvalues(controller)
            local hash_func = ups[9]
            local a, b2, c, d, e, f, g = debug.getupvalue(hash_func, 15), debug.getupvalue(hash_func, 13),
                debug.getupvalue(hash_func, 16), debug.getupvalue(hash_func, 17),
                debug.getupvalue(hash_func, 14), debug.getupvalue(hash_func, 12),
                debug.getupvalue(hash_func, 18)
            local result = ((e * b2 + d * a) % c * c + d * b2) % d
            local inc = math.floor(result / c)
            local rem = result - inc * c
            g = g + 1
            debug.setupvalue(hash_func, 15, a)
            debug.setupvalue(hash_func, 13, b2)
            debug.setupvalue(hash_func, 16, c)
            debug.setupvalue(hash_func, 17, d)
            debug.setupvalue(hash_func, 14, inc)
            debug.setupvalue(hash_func, 12, rem)
            debug.setupvalue(hash_func, 18, g)
            RS.Remotes.Validator2:FireServer(math.floor(result / d * 16777215), g)
            Net:FindFirstChild("RE/ShootGunEvent"):FireServer(target.Position, { target })
        end)
        return
    end

    -- fallback genérico
    local re = gun:FindFirstChild("RemoteEvent")
    if re then re:FireServer(target.Position) end
end

-- Spam gun específico
function PVP.SpamSkullGuitar(target)
    local char = LP.Character
    if not char then return end
    local gun = char:FindFirstChild("Skull Guitar")
    if not gun then return end
    if CombatUtil and CombatUtil:IsGunReloading(gun) then return end
    local re = gun:FindFirstChild("RemoteEvent")
    if re then re:FireServer("TAP", target.Position) end
end

function PVP.SpamDragonstorm(target)
    PVP.ShootM1(target)
end

-- Auto Click M1 (loop)
task.spawn(function()
    while task.wait(PVP.Config.AutoClickDelay or 0.1) do
        if PVP.Enabled and PVP.Config.AutoClickM1 and PVP.Config.SilentAim then
            local t = state.current_target
            if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                pcall(PVP.Attack, PVP.Config.AoeRange, true)
            end
        end
    end
end)

-- ═══════════════ FAST ATTACK (CombatFramework) ═══════════════
local CombatFrameworkR
pcall(function()
    local cf = require(LP.PlayerScripts:WaitForChild("CombatFramework"))
    if type(getupvalues) == "function" then
        local ups = getupvalues(cf)
        CombatFrameworkR = ups and ups[2]
    elseif debug and debug.getupvalues then
        local ups = debug.getupvalues(cf)
        CombatFrameworkR = ups and ups[2]
    end
end)

local function get_combat_controller()
    return CombatFrameworkR and CombatFrameworkR.activeController or nil
end

local function fast_attack_once()
    if not (PVP.Config.FastAttack or PVP.Config.SuperFastAttack) then return end
    local controller = get_combat_controller()
    if not controller then return end
    pcall(function()
        controller.hitboxMagnitude = PVP.Config.SuperFastAttack and 60 or 55
        controller.timeToNextAttack = 0
        controller.attacking = false
        controller.increment = 3
        controller.blocking = false
        controller.timeToNextBlock = 0
        if controller.attack then controller:attack() end
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Sit = false end
    end)
end

task.spawn(function()
    while task.wait() do
        if PVP.Enabled then
            pcall(fast_attack_once)
        end
    end
end)

-- ═══════════════ API PÚBLICA ═══════════════
function PVP.set(k, v)
    local parts = {}
    for p in k:gmatch("[^%.]+") do table.insert(parts, p) end
    local tbl = PVP.Config
    for i = 1, #parts - 1 do
        tbl = tbl[parts[i]]
        if not tbl then return end
    end
    tbl[parts[#parts]] = v
end

function PVP.toggle(v)
    PVP.Enabled = (v == nil) and not PVP.Enabled or v
end

function PVP.set_aim_key(keycode)
    PVP.Config.AimKey = keycode
end

function PVP.add_friend(plr) state.friends[plr.UserId] = true end
function PVP.remove_friend(plr) state.friends[plr.UserId] = nil end
function PVP.is_hook_installed() return hook_installed end
function PVP.get_current_target() return state.current_target end

-- carrega amigos do Roblox automaticamente
task.spawn(function()
    pcall(function()
        local list = Players:GetFriendsAsync(LP.UserId)
        while true do
            for _, f in ipairs(list:GetCurrentPage()) do
                state.friends[f.Id] = true
            end
            if list.IsFinished then break end
            list:AdvanceToNextPageAsync()
        end
    end)
end)

_G.Str1kerPVP = PVP
return PVP
