-- language: Luau, file: aimbot.lua, target: Delta / Krnl / Codex
-- Str1ker Aimbot v10 — inspirado em scripts open source

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local WS         = game:GetService("Workspace")
local Camera     = WS.CurrentCamera
local LP         = Players.LocalPlayer
local Mouse      = LP:GetMouse()

local Aimbot = {
    Mode = "off", -- "off" | "diagnostic" | "silent"
    Config = {
        Target = {
            MaxDistance = 500,
            Priority    = "Cursor", -- "Closest" | "Cursor" | "Lowest HP"
            LockTime    = 0.15,
        },
        FOV = {
            Degrees = 30,
            ShowCircle = true,
            CircleColor = Color3.fromRGB(80, 150, 255),
        },
        Prediction = {
            Enabled = true,
            Base    = 0.165,   -- mesmo valor do script Da Hood
        },
        Checks = {
            TeamCheck = true,
            WallCheck = false,
            AliveOnly = true,
        },
        Hitbox = "Auto",
        Visuals = {
            ShowCircle    = true,
            ShowTargetBox = true,
            ShowTracer    = true,
            ShowInfoPanel = true,
        },
        Keys = {
            ToggleMode   = Enum.KeyCode.G,
            ToggleSilent = Enum.KeyCode.H,
        },
        ShowButton = true,
    }
}

-- APIs
local API = {
    Drawing = Drawing or (syn and syn.drawing) or (Krnl and Krnl.Drawing),
    Hook    = (getrawmetatable and setreadonly and hookfunction and newcclosure) ~= nil,
    Gethui  = gethui ~= nil,
}
API.CanDraw = API.Drawing ~= nil

local state = {
    current_target = nil,
    locked_since   = 0,
    pos_cache      = nil,
    pos_cache_at   = 0,
    fov_cache      = nil,
    fov_cache_at   = 0,
    ray_cache      = {},
    friends        = {},
}

-- ═══ DRAWING ═══
local draw = {}
if API.CanDraw then
    draw.fov = API.Drawing.new("Circle")
    draw.fov.Thickness = 1.5
    draw.fov.NumSides  = 60
    draw.fov.Filled    = false
    draw.fov.Color     = Aimbot.Config.FOV.CircleColor
    draw.fov.Visible   = false

    draw.box = API.Drawing.new("Square")
    draw.box.Thickness = 1.5
    draw.box.Filled    = false
    draw.box.Color     = Color3.fromRGB(70, 220, 110)
    draw.box.Visible   = false

    draw.tracer = API.Drawing.new("Line")
    draw.tracer.Thickness = 1.5
    draw.tracer.Color     = Color3.fromRGB(70, 220, 110)
    draw.tracer.Visible   = false

    draw.info = {}
    for i = 1, 6 do
        local t = API.Drawing.new("Text")
        t.Size = 13
        t.Font = 2
        t.Outline = true
        t.Color = Color3.fromRGB(240, 244, 252)
        t.OutlineColor = Color3.new(0,0,0)
        t.Visible = false
        draw.info[i] = t
    end
end

-- ═══ BOTÃO ═══
local buttonGui, button, label, dot

local function create_button()
    local parent = API.Gethui and gethui() or LP:WaitForChild("PlayerGui")
    buttonGui = Instance.new("ScreenGui")
    buttonGui.Name = "Str1kerAimBtn"
    buttonGui.ResetOnSpawn = false
    buttonGui.IgnoreGuiInset = true
    buttonGui.Parent = parent

    button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(160, 42)
    button.Position = UDim2.new(0, 20, 0.5, -21)
    button.BackgroundColor3 = Color3.fromRGB(8, 14, 28)
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.Draggable = true
    button.Parent = buttonGui
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 10)

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
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.fromOffset(28, 0)
    label.BackgroundTransparency = 1
    label.Text = "AIM: OFF"
    label.TextColor3 = Color3.fromRGB(140, 156, 184)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = button

    button.MouseButton1Click:Connect(function() Aimbot.cycle_mode() end)
end

local function update_button()
    if not button then return end
    if Aimbot.Mode == "silent" then
        button.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
        button.Border.Color = Color3.fromRGB(255, 80, 80)
        dot.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        label.Text = "AIM: SILENT"
        label.TextColor3 = Color3.fromRGB(255, 200, 200)
    elseif Aimbot.Mode == "diagnostic" then
        button.BackgroundColor3 = Color3.fromRGB(10, 30, 50)
        button.Border.Color = Color3.fromRGB(70, 220, 110)
        dot.BackgroundColor3 = Color3.fromRGB(70, 220, 110)
        label.Text = "AIM: DIAGNOSTIC"
        label.TextColor3 = Color3.fromRGB(200, 240, 210)
    else
        button.BackgroundColor3 = Color3.fromRGB(8, 14, 28)
        button.Border.Color = Color3.fromRGB(96, 165, 250)
        dot.BackgroundColor3 = Color3.fromRGB(120, 130, 150)
        label.Text = "AIM: OFF"
        label.TextColor3 = Color3.fromRGB(140, 156, 184)
    end
end

-- ═══ HELPERS ═══
local function get_ping_sec()
    local ok, p = pcall(function()
        return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    return (ok and p and p > 0) and (p/1000) or 0.05
end

local function get_part_for(char)
    local m = Aimbot.Config.Hitbox
    if m == "Head" then return char:FindFirstChild("Head") end
    if m == "UpperTorso" then return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") end
    if m == "HumanoidRootPart" then return char:FindFirstChild("HumanoidRootPart") end
    return char:FindFirstChild("Head")
        or char:FindFirstChild("UpperTorso")
        or char:FindFirstChild("Torso")
        or char:FindFirstChild("HumanoidRootPart")
end

local function get_fov_px()
    local now = tick()
    if state.fov_cache and (now - state.fov_cache_at) < 0.5 then return state.fov_cache end
    local vp = Camera.ViewportSize
    local px = math.tan(math.rad(Aimbot.Config.FOV.Degrees/2)) / math.tan(math.rad(Camera.FieldOfView/2)) * (vp.Y/2)
    state.fov_cache = px
    state.fov_cache_at = now
    return px
end

local function raycast_clear(plr, char)
    local now = tick()
    local c = state.ray_cache[plr.UserId]
    if c and (now - c.at) < 0.15 then return c.result end
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    if not torso then
        state.ray_cache[plr.UserId] = { result = false, at = now }
        return false
    end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LP.Character, char }
    local dir = torso.Position - Camera.CFrame.Position
    local hit = WS:Raycast(Camera.CFrame.Position, dir, params)
    local clear = (hit == nil)
    state.ray_cache[plr.UserId] = { result = clear, at = now }
    return clear
end

local function is_valid(plr)
    local cfg = Aimbot.Config
    if plr == LP then return false end
    if cfg.Checks.TeamCheck and plr.Team and LP.Team and plr.Team == LP.Team then return false end

    local char = plr.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if cfg.Checks.AliveOnly and (not hum or hum.Health <= 0) then return false end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local my_hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not my_hrp then return false end

    local dist = (hrp.Position - my_hrp.Position).Magnitude
    if dist > cfg.Target.MaxDistance then return false, dist end

    if cfg.Checks.WallCheck and not raycast_clear(plr, char) then return false, dist end

    local sp, on = Camera:WorldToViewportPoint(hrp.Position)
    if not on then return false, dist end
    local vp = Camera.ViewportSize
    local dx, dy = sp.X - vp.X/2, sp.Y - vp.Y/2
    local sdist = math.sqrt(dx*dx + dy*dy)
    if sdist > get_fov_px() then return false, dist, sdist end

    return true, dist, sdist
end

local function pick_target()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        local ok, dist, sdist = is_valid(plr)
        if ok then table.insert(list, { plr=plr, dist=dist, sdist=sdist or math.huge }) end
    end
    if #list == 0 then return nil end

    -- Prioridade "Cursor" — inspirado no Da Hood, usa a posição real do mouse
    if Aimbot.Config.Target.Priority == "Cursor" then
        local mouse_pos = UIS:GetMouseLocation()
        table.sort(list, function(a, b)
            local ca = a.plr.Character
            local cb = b.plr.Character
            local spa = ca and Camera:WorldToViewportPoint(ca:FindFirstChild("HumanoidRootPart").Position)
            local spb = cb and Camera:WorldToViewportPoint(cb:FindFirstChild("HumanoidRootPart").Position)
            if not spa or not spb then return false end
            local da = (Vector2.new(spa.X, spa.Y) - mouse_pos).Magnitude
            local db = (Vector2.new(spb.X, spb.Y) - mouse_pos).Magnitude
            return da < db
        end)
    elseif Aimbot.Config.Target.Priority == "Closest" then
        table.sort(list, function(a, b) return a.dist < b.dist end)
    elseif Aimbot.Config.Target.Priority == "Lowest HP" then
        table.sort(list, function(a, b)
            local ha = a.plr.Character and a.plr.Character:FindFirstChildOfClass("Humanoid")
            local hb = b.plr.Character and b.plr.Character:FindFirstChildOfClass("Humanoid")
            return (ha and ha.Health or 9999) < (hb and hb.Health or 9999)
        end)
    end
    return list[1]
end

-- ═══ PREDICTION — igual ao Da Hood (CFrame + Velocity * lead) ═══
local function predict(part)
    if not Aimbot.Config.Prediction.Enabled then return part.Position end
    local lead = Aimbot.Config.Prediction.Base
    local ping = get_ping_sec()
    -- soma efeito do ping
    lead = lead + ping * 0.5
    lead = math.clamp(lead, 0.05, 0.35)

    local vel = part.AssemblyLinearVelocity or part.Velocity or Vector3.zero
    if vel.Magnitude < 1 then vel = Vector3.zero end

    -- CRUCIAL: usa CFrame em vez de Position (padrão dos scripts open source)
    local predicted = part.CFrame + (vel * lead)
    return predicted.Position
end

local function update_target()
    if Aimbot.Mode == "off" then state.current_target = nil; return end
    local now = tick()

    if state.current_target then
        local char = state.current_target.plr.Character
        if not char then
            state.current_target = nil
        else
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then state.current_target = nil end
        end
    end

    if state.current_target and (now - state.locked_since) < Aimbot.Config.Target.LockTime then return end

    if not state.current_target then
        state.current_target = pick_target()
        state.locked_since = now
        state.pos_cache = nil
    end
end

local function get_target_pos()
    if not state.current_target then return nil end
    local now = tick()
    if state.pos_cache and (now - state.pos_cache_at) < 0.05 then return state.pos_cache end
    local char = state.current_target.plr.Character
    if not char then return nil end
    local part = get_part_for(char)
    if not part then return nil end
    local pos = predict(part)
    state.pos_cache = pos
    state.pos_cache_at = now
    return pos
end

-- ═══ RENDER ═══
local function render_visuals()
    if not API.CanDraw then return end
    local show = Aimbot.Mode ~= "off"
    local vp = Camera.ViewportSize

    if show and Aimbot.Config.Visuals.ShowCircle then
        draw.fov.Visible = true
        draw.fov.Position = Vector2.new(vp.X/2, vp.Y/2)
        draw.fov.Radius = get_fov_px()
        draw.fov.Color = Aimbot.Config.FOV.CircleColor
    else
        draw.fov.Visible = false
    end

    local t = state.current_target
    if show and t then
        local char = t.plr.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            if hrp and head then
                local top = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,1,0))
                local bot = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,2.5,0))
                if top.Z > 0 and bot.Z > 0 then
                    local h = math.abs(bot.Y - top.Y)
                    local w = math.max(math.abs(bot.X - top.X), h * 0.6)
                    if Aimbot.Config.Visuals.ShowTargetBox then
                        draw.box.Visible = true
                        draw.box.From = Vector2.new(top.X - w/2, top.Y)
                        draw.box.To = Vector2.new(top.X + w/2, bot.Y)
                    else draw.box.Visible = false end
                    if Aimbot.Config.Visuals.ShowTracer then
                        draw.tracer.Visible = true
                        draw.tracer.From = Vector2.new(vp.X/2, vp.Y)
                        draw.tracer.To = Vector2.new(top.X, bot.Y)
                    else draw.tracer.Visible = false end
                end
            end
        end
    else
        draw.box.Visible = false
        draw.tracer.Visible = false
    end

    if show and Aimbot.Config.Visuals.ShowInfoPanel then
        local lines = { "MODE: " .. Aimbot.Mode:upper() }
        if t then
            local char = t.plr.Character
            local my_hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local dist = (my_hrp and hrp) and (hrp.Position - my_hrp.Position).Magnitude or 0
            table.insert(lines, "TARGET: " .. t.plr.Name)
            table.insert(lines, string.format("DIST: %d studs", math.floor(dist)))
            table.insert(lines, string.format("PING: %dms", math.floor(get_ping_sec() * 1000)))
            table.insert(lines, "PART: " .. Aimbot.Config.Hitbox)
            table.insert(lines, string.format("FOV: %d deg | %dpx", Aimbot.Config.FOV.Degrees, math.floor(get_fov_px())))
        else
            table.insert(lines, "TARGET: none")
            table.insert(lines, string.format("PING: %dms", math.floor(get_ping_sec() * 1000)))
            table.insert(lines, string.format("FOV: %d deg", Aimbot.Config.FOV.Degrees))
        end
        for i, line in ipairs(lines) do
            local tt = draw.info[i]
            if tt then
                tt.Visible = true
                tt.Text = line
                tt.Position = Vector2.new(20, 200 + (i-1)*16)
            end
        end
        for i = #lines+1, 6 do if draw.info[i] then draw.info[i].Visible = false end end
    else
        for i=1,6 do if draw.info[i] then draw.info[i].Visible = false end end
    end
end

-- ═══ HOOK — inspirado no script Da Hood (mais robusto) ═══
local hook_installed = false
if API.Hook then
    local mt = getrawmetatable(game)
    local old_index = mt.__index
    local old_namecall = mt.__namecall
    setreadonly(mt, false)

    mt.__index = newcclosure(function(self, key)
        -- checkcaller evita loop infinito quando o próprio script lê
        if checkcaller and checkcaller() then
            return old_index(self, key)
        end

        if self == Mouse and Aimbot.Mode == "silent" then
            local ok, res = pcall(function()
                local pos = get_target_pos()
                if pos then
                    if key == "Hit" then
                        return CFrame.new(Mouse.Origin.Position, pos)
                    elseif key == "UnitRay" then
                        return Ray.new(Mouse.Origin.Position, (pos - Mouse.Origin.Position).Unit)
                    elseif key == "Target" then
                        local char = state.current_target and state.current_target.plr.Character
                        if char then return get_part_for(char) end
                    end
                end
                return old_index(self, key)
            end)
            return ok and res or old_index(self, key)
        end
        return old_index(self, key)
    end)

    -- __namecall — usado por BF pra disparar remote de ataque
    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        if Aimbot.Mode == "silent" and checkcaller and not checkcaller() then
            local ok, res = pcall(function()
                return old_namecall(self, unpack(args))
            end)
            return ok and res or old_namecall(self, unpack(args))
        end
        return old_namecall(self, unpack(args))
    end)

    setreadonly(mt, true)
    hook_installed = true
end

-- ═══ LOOPS ═══
task.spawn(function()
    while true do update_target(); task.wait(0.1) end
end)

RunService.RenderStepped:Connect(render_visuals)

RunService.Heartbeat:Connect(function()
    local now = tick()
    for uid, c in pairs(state.ray_cache) do
        if (now - c.at) > 1 then state.ray_cache[uid] = nil end
    end
end)

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Aimbot.Config.Keys.ToggleMode then Aimbot.cycle_mode() end
    if input.KeyCode == Aimbot.Config.Keys.ToggleSilent then Aimbot.set_mode("silent") end
end)

-- ═══ API ═══
function Aimbot.set_mode(m)
    Aimbot.Mode = m
    state.current_target = nil
    state.pos_cache = nil
    update_button()
end

function Aimbot.cycle_mode()
    if Aimbot.Mode == "off" then Aimbot.set_mode("diagnostic")
    elseif Aimbot.Mode == "diagnostic" then Aimbot.set_mode("silent")
    else Aimbot.set_mode("off") end
end

function Aimbot.set(key, value)
    local parts = {}
    for p in key:gmatch("[^%.]+") do table.insert(parts, p) end
    local tbl = Aimbot.Config
    for i=1, #parts-1 do tbl = tbl[parts[i]]; if not tbl then return end end
    tbl[parts[#parts]] = value
end

function Aimbot.is_hook_installed() return hook_installed end
function Aimbot.destroy_button() if buttonGui then buttonGui:Destroy() end end

if Aimbot.Config.ShowButton then
    create_button()
    update_button()
end

if not API.Hook then
    warn("[Str1ker Aimbot] Hook indisponivel — SILENT nao funciona")
end

_G.Str1kerAimbot = Aimbot
return Aimbot
