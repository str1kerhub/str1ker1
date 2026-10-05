-- language: Luau, file: aimbot.lua, target: Delta / Krnl / Codex
-- Str1ker Aimbot v9 — Modos: OFF / DIAGNOSTIC / SILENT

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local WS         = game:GetService("Workspace")
local Camera     = WS.CurrentCamera
local LP         = Players.LocalPlayer
local Mouse      = LP:GetMouse()

-- ═══════════════════════════════════════════════
--  CONFIG ORGANIZADA
-- ═══════════════════════════════════════════════
local Aimbot = {
    Mode = "off", -- "off" | "diagnostic" | "silent"
    Config = {
        Target = {
            MaxDistance    = 500,
            Priority       = "Crosshair", -- "Closest" | "Crosshair" | "Lowest HP"
            LockTime       = 0.15,
            IgnoreFriends  = true,
        },
        FOV = {
            Degrees        = 30,
            ShowCircle     = true,
            CircleColor    = Color3.fromRGB(80, 150, 255),
            CircleThickness= 1.5,
        },
        Prediction = {
            Enabled        = true,
            Base           = 0.14,
            PingMultiplier = 0.5,
            MaxLead        = 0.35,
        },
        Checks = {
            TeamCheck      = true,
            WallCheck      = false,
            AliveOnly      = true,
        },
        Hitbox = "Auto", -- "Head" | "UpperTorso" | "HumanoidRootPart" | "Auto"
        Visuals = {
            ShowCircle     = true,
            ShowTargetBox  = true,
            ShowTracer     = true,
            ShowInfoPanel  = true,
            InfoPanelPos   = Vector2.new(20, 200),
        },
        Keys = {
            ToggleMode     = Enum.KeyCode.G,  -- alterna OFF → DIAGNOSTIC → SILENT → OFF
            ToggleSilent   = Enum.KeyCode.H,  -- pula direto pro silent
        },
        ShowButton = true,
    }
}

-- ═══════════════════════════════════════════════
--  DETECÇÃO DE APIs (fallbacks)
-- ═══════════════════════════════════════════════
local API = {
    Drawing  = Drawing or (syn and syn.drawing) or (Krnl and Krnl.Drawing),
    Hook     = (getrawmetatable and setreadonly and hookfunction and newcclosure) ~= nil,
    Gethui   = gethui ~= nil,
}
API.CanDraw = API.Drawing ~= nil

-- ═══════════════════════════════════════════════
--  ESTADO
-- ═══════════════════════════════════════════════
local state = {
    current_target   = nil,
    locked_since     = 0,
    target_pos_cache = nil,
    target_cache_at  = 0,
    fov_cache        = nil,
    fov_cache_at     = 0,
    ray_cache        = {},
    friends          = {},
    last_attack_time = 0,
    current_hit_roll = 100,
}

-- ═══════════════════════════════════════════════
--  DRAWING (visual apenas)
-- ═══════════════════════════════════════════════
local draw = {}
if API.CanDraw then
    draw.fov      = API.Drawing.new("Circle")
    draw.fov.Thickness = Aimbot.Config.FOV.CircleThickness
    draw.fov.NumSides  = 60
    draw.fov.Filled    = false
    draw.fov.Color     = Aimbot.Config.FOV.CircleColor
    draw.fov.Visible   = false

    draw.box      = API.Drawing.new("Square")
    draw.box.Thickness = 1.5
    draw.box.Filled    = false
    draw.box.Color     = Color3.fromRGB(70, 220, 110)
    draw.box.Visible   = false

    draw.tracer   = API.Drawing.new("Line")
    draw.tracer.Thickness = 1.5
    draw.tracer.Color     = Color3.fromRGB(70, 220, 110)
    draw.tracer.Visible   = false

    -- painel de info (5 linhas de texto)
    draw.info = {}
    for i = 1, 6 do
        local t = API.Drawing.new("Text")
        t.Size    = 13
        t.Font    = 2
        t.Outline = true
        t.Color   = Color3.fromRGB(240, 244, 252)
        t.OutlineColor = Color3.fromRGB(0, 0, 0)
        t.Visible = false
        draw.info[i] = t
    end
end

-- ═══════════════════════════════════════════════
--  BOTÃO FLUTUANTE
-- ═══════════════════════════════════════════════
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

    button.MouseButton1Click:Connect(function()
        Aimbot.cycle_mode()
    end)
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

-- ═══════════════════════════════════════════════
--  HELPERS
-- ═══════════════════════════════════════════════
local function get_ping_sec()
    local ok, p = pcall(function()
        return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    if ok and type(p) == "number" and p > 0 then
        return p / 1000
    end
    return 0.05
end

local function get_part_for(char)
    local mode = Aimbot.Config.Hitbox
    if mode == "Head" then return char:FindFirstChild("Head") end
    if mode == "UpperTorso" then
        return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    end
    if mode == "HumanoidRootPart" then return char:FindFirstChild("HumanoidRootPart") end
    -- Auto
    return char:FindFirstChild("Head")
        or char:FindFirstChild("UpperTorso")
        or char:FindFirstChild("Torso")
        or char:FindFirstChild("HumanoidRootPart")
end

local function get_fov_radius_px()
    local now = tick()
    if state.fov_cache and (now - state.fov_cache_at) < 0.5 then
        return state.fov_cache
    end
    local vp = Camera.ViewportSize
    local cam_fov = math.rad(Camera.FieldOfView / 2)
    local cfg_fov = math.rad(Aimbot.Config.FOV.Degrees / 2)
    local px = math.tan(cfg_fov) / math.tan(cam_fov) * (vp.Y / 2)
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

-- retorna ok, dist, sdist, reason
local function is_valid(plr)
    local cfg = Aimbot.Config

    if plr == LP then return false, nil, nil, "self" end
    if cfg.Checks.TeamCheck and plr.Team and LP.Team and plr.Team == LP.Team then
        return false, nil, nil, "team"
    end
    if cfg.Target.IgnoreFriends and state.friends[plr.UserId] then
        return false, nil, nil, "friend"
    end

    local char = plr.Character
    if not char then return false, nil, nil, "no char" end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if cfg.Checks.AliveOnly and (not hum or hum.Health <= 0) then
        return false, nil, nil, "dead"
    end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local my_hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not my_hrp then return false, nil, nil, "no hrp" end

    local dist = (hrp.Position - my_hrp.Position).Magnitude
    if dist > cfg.Target.MaxDistance then
        return false, dist, nil, "far ("..math.floor(dist)..")"
    end

    if cfg.Checks.WallCheck and not raycast_clear(plr, char) then
        return false, dist, nil, "walled"
    end

    local sp, on = Camera:WorldToViewportPoint(hrp.Position)
    if not on then return false, dist, nil, "offscreen" end

    local vp = Camera.ViewportSize
    local dx, dy = sp.X - vp.X / 2, sp.Y - vp.Y / 2
    local sdist = math.sqrt(dx * dx + dy * dy)
    if sdist > get_fov_radius_px() then
        return false, dist, sdist, "out fov"
    end

    return true, dist, sdist, "ok"
end

local function pick_target()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        local ok, dist, sdist = is_valid(plr)
        if ok then
            table.insert(list, { plr = plr, dist = dist, sdist = sdist or math.huge })
        end
    end
    if #list == 0 then return nil end

    local p = Aimbot.Config.Target.Priority
    if p == "Closest" then
        table.sort(list, function(a, b) return a.dist < b.dist end)
    elseif p == "Crosshair" then
        table.sort(list, function(a, b) return a.sdist < b.sdist end)
    elseif p == "Lowest HP" then
        table.sort(list, function(a, b)
            local ha = a.plr.Character and a.plr.Character:FindFirstChildOfClass("Humanoid")
            local hb = b.plr.Character and b.plr.Character:FindFirstChildOfClass("Humanoid")
            return (ha and ha.Health or 9999) < (hb and hb.Health or 9999)
        end)
    end
    return list[1]
end

local function predict(part)
    if not Aimbot.Config.Prediction.Enabled then return part.Position end
    local ping_sec = get_ping_sec()
    local base = Aimbot.Config.Prediction.Base
    local vel = part.AssemblyLinearVelocity or Vector3.zero
    if vel.Magnitude < 1 then vel = Vector3.zero end

    local dist = (part.Position - Camera.CFrame.Position).Magnitude

    local lead = base + ping_sec * Aimbot.Config.Prediction.PingMultiplier
    lead = math.clamp(lead, 0.05, Aimbot.Config.Prediction.MaxLead)

    local dist_mult = math.clamp(1 + dist / 3000, 1, 1.5)
    lead = lead * dist_mult

    return part.Position + vel * lead
end

local function roll_hit()
    local now = tick()
    if (now - state.last_attack_time) > 0.5 then
        state.current_hit_roll = math.random(1, 100)
        state.last_attack_time = now
    end
end

-- ═══════════════════════════════════════════════
--  SELEÇÃO DE ALVO (compartilhada entre modos)
-- ═══════════════════════════════════════════════
local function update_target()
    if Aimbot.Mode == "off" then
        state.current_target = nil
        return
    end

    local now = tick()

    -- valida alvo atual
    if state.current_target then
        local char = state.current_target.plr.Character
        if not char then
            state.current_target = nil
        else
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then
                state.current_target = nil
            end
        end
    end

    -- lock de alvo
    if state.current_target and (now - state.locked_since) < Aimbot.Config.Target.LockTime then
        return
    end

    if not state.current_target then
        state.current_target = pick_target()
        state.locked_since = now
        state.target_pos_cache = nil
    end
end

local function get_target_pos()
    if not state.current_target then return nil end
    local now = tick()
    if state.target_pos_cache and (now - state.target_cache_at) < 0.05 then
        return state.target_pos_cache
    end
    local char = state.current_target.plr.Character
    if not char then return nil end
    local part = get_part_for(char)
    if not part then return nil end
    local pos = predict(part)
    state.target_pos_cache = pos
    state.target_cache_at = now
    return pos
end

-- ═══════════════════════════════════════════════
--  RENDER VISUAL (diagnostic + silent)
-- ═══════════════════════════════════════════════
local function render_visuals()
    if not API.CanDraw then return end

    local show_any = Aimbot.Mode ~= "off"
    local vp = Camera.ViewportSize

    -- FOV circle
    if show_any and Aimbot.Config.FOV.ShowCircle and Aimbot.Config.Visuals.ShowCircle then
        draw.fov.Visible = true
        draw.fov.Position = Vector2.new(vp.X / 2, vp.Y / 2)
        draw.fov.Radius = get_fov_radius_px()
        draw.fov.Color = Aimbot.Config.FOV.CircleColor
        draw.fov.Thickness = Aimbot.Config.FOV.CircleThickness
    else
        draw.fov.Visible = false
    end

    -- target box + tracer
    local t = state.current_target
    if show_any and t then
        local char = t.plr.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            if hrp and head then
                local top = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
                local bot = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 2.5, 0))
                if top.Z > 0 and bot.Z > 0 then
                    local h = math.abs(bot.Y - top.Y)
                    local w = math.max(math.abs(bot.X - top.X), h * 0.6)
                    local left = top.X - w / 2
                    local right = top.X + w / 2

                    if Aimbot.Config.Visuals.ShowTargetBox then
                        draw.box.Visible = true
                        draw.box.From = Vector2.new(left, top.Y)
                        draw.box.To = Vector2.new(right, bot.Y)
                    else
                        draw.box.Visible = false
                    end

                    if Aimbot.Config.Visuals.ShowTracer then
                        draw.tracer.Visible = true
                        draw.tracer.From = Vector2.new(vp.X / 2, vp.Y)
                        draw.tracer.To = Vector2.new(top.X, bot.Y)
                    else
                        draw.tracer.Visible = false
                    end
                end
            end
        end
    else
        draw.box.Visible = false
        draw.tracer.Visible = false
    end

    -- info panel
    if show_any and Aimbot.Config.Visuals.ShowInfoPanel then
        local lines = {}
        table.insert(lines, "MODE: " .. Aimbot.Mode:upper())
        if t then
            local char = t.plr.Character
            local dist = 0
            local my_hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if my_hrp and hrp then
                dist = (hrp.Position - my_hrp.Position).Magnitude
            end
            table.insert(lines, "TARGET: " .. t.plr.Name)
            table.insert(lines, string.format("DIST: %d studs", math.floor(dist)))
            table.insert(lines, string.format("PING: %dms", math.floor(get_ping_sec() * 1000)))
            table.insert(lines, "PART: " .. Aimbot.Config.Hitbox)
            table.insert(lines, string.format("FOV: %d° | %dpx", Aimbot.Config.FOV.Degrees, math.floor(get_fov_radius_px())))
        else
            table.insert(lines, "TARGET: none")
            table.insert(lines, string.format("PING: %dms", math.floor(get_ping_sec() * 1000)))
            table.insert(lines, string.format("FOV: %d° | %dpx", Aimbot.Config.FOV.Degrees, math.floor(get_fov_radius_px())))
            table.insert(lines, "API Hook: " .. (API.Hook and "ON" or "OFF"))
        end

        for i, line in ipairs(lines) do
            local t2 = draw.info[i]
            if t2 then
                t2.Visible = true
                t2.Text = line
                t2.Position = Aimbot.Config.Visuals.InfoPanelPos + Vector2.new(0, (i - 1) * 16)
            end
        end
        for i = #lines + 1, 6 do
            if draw.info[i] then draw.info[i].Visible = false end
        end
    else
        for i = 1, 6 do
            if draw.info[i] then draw.info[i].Visible = false end
        end
    end
end

-- ═══════════════════════════════════════════════
--  HOOK (só em modo silent)
-- ═══════════════════════════════════════════════
local hook_installed = false
if API.Hook then
    local mt = getrawmetatable(game)
    local old_index = mt.__index
    setreadonly(mt, false)
    mt.__index = newcclosure(function(self, key)
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
    setreadonly(mt, true)
    hook_installed = true
end

-- ═══════════════════════════════════════════════
--  LOOPS
-- ═══════════════════════════════════════════════

-- seleção de alvo a cada 10 Hz (não a cada frame)
task.spawn(function()
    while true do
        update_target()
        task.wait(0.1)
    end
end)

-- render a cada frame
RunService.RenderStepped:Connect(function()
    render_visuals()
end)

-- limpa cache
RunService.Heartbeat:Connect(function()
    local now = tick()
    for uid, c in pairs(state.ray_cache) do
        if (now - c.at) > 1 then state.ray_cache[uid] = nil end
    end
end)

-- teclas
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Aimbot.Config.Keys.ToggleMode then Aimbot.cycle_mode() end
    if input.KeyCode == Aimbot.Config.Keys.ToggleSilent then Aimbot.set_mode("silent") end
end)

-- ═══════════════════════════════════════════════
--  API PÚBLICA
-- ═══════════════════════════════════════════════
function Aimbot.set_mode(m)
    Aimbot.Mode = m
    state.current_target = nil
    state.target_pos_cache = nil
    update_button()
end

f
