--!nocheck
-- ==========================================================================
-- STR1KER PVP v3.10
-- v3.9 + Spectate UI (botões flutuantes + mini viewport do alvo)
-- ==========================================================================
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local Workspace    = game:GetService("Workspace")
local UIS          = game:GetService("UserInputService")
local Stats        = game:GetService("Stats")
local Http         = game:GetService("HttpService")
local Lighting     = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Camera       = Workspace.CurrentCamera
local LP           = Players.LocalPlayer

local V2, V3, CF = Vector2.new, Vector3.new, CFrame.new
local floor, abs = math.floor, math.abs
local max, min, cl = math.max, math.min, math.clamp

local httpReq = (syn and syn.request) or (http and http.request) or http_request or request
local BACKEND = "https://str1ker-backend.up.railway.app"

if httpReq then
    task.spawn(function()
        local ok, res = pcall(httpReq, { Url = BACKEND .. "/status", Method = "GET" })
        if ok and res and res.StatusCode == 200 then
            local d; pcall(function() d = Http:JSONDecode(res.Body) end)
            if d and d.enabled == false then warn("[Str1ker] desabilitado"); return end
        end
    end)
end
local function logEvent(evt, data)
    if not httpReq then return end
    task.spawn(function()
        pcall(httpReq, {
            Url = BACKEND .. "/log", Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = Http:JSONEncode({ event = evt, data = data, user = LP.Name, t = os.time() }),
        })
    end)
end

-- ══════════════════════════════════════════════════════════════════════════
-- CONFIG
-- ══════════════════════════════════════════════════════════════════════════
local CFG_PATH = "str1ker_cfg.json"
local LEARN_PATH = "str1ker_learn.json"

local DEFAULT_CFG = {
    esp = {
        enabled = true, box = true, health_bar = true, name = true,
        distance = true, level = true, tracer = true, skeleton = false,
        icons = false, icon_weapon = false, icon_head = false,
        icon_pos = "Left of Name", icon_size = 32, icon_spacing = 6,
        icon_bg = true, icon_opacity = 65, text_backdrop = true,
        max_distance = 1500, thickness = 1.5,
        enemy_color = {255, 60, 60}, team_color = {60, 255, 120},
        spectate = false,
        spectate_mode = "Nearest",
        spectate_manual = "",
        -- NOVO v3.10
        spectate_show_button = true,
        spectate_show_mini = true,
        spectate_mini_size = {240, 180},
        spectate_mini_fov = 70,
    },
    aim = {
        enabled = true, mode = "Silent", keybind = "E", aim_part = "Head",
        fov = 120, max_distance = 600, smoothing = 0.35,
        prediction = true, prediction_scale = 1.0, resolver = 0.05,
        aggressive_prediction = false,
        team_check = true, hook_get_target = true,
        smart = false, smart_samples = 8, smart_strafe_lead = 0.05, smart_accel_weight = 0.3,
    },
    dodge = {
        enabled = false,
        auto_ken = true,
        i_frame_window = 0.15,
        use_phasing_burst = true, phasing_burst_count = 2,
        fallback_dash = true, fallback_soru = true, fallback_geppo = false,
        detect_remote = true, detect_velocity = true, detect_range = 40,
        dodge_cooldown = 0.5, ken_recheck_interval = 0.05,
        skip_ken_on_breaker = true,
        learning = true,
        learn_min_samples = 3, learn_promote_cue = 4,
        learn_window_ms = 1000, learn_distance_max = 500,
        log_triggers = false,
        macro = {
            enabled = true,
            reaction_min_ms = 180, reaction_max_ms = 320,
            hold_min_ms = 40, hold_max_ms = 90,
            skip_chance = 0.08, jitter_studs = 3.5,
            actions_per_minute = 55,
            fatigue_after = 14,
            fatigue_duration_min = 3, fatigue_duration_max = 7,
            decision_delay_ms = 30,
            rotate_dash_keys = true, use_native_input = true, add_micro_jitter = true,
            announce_miss = false,
        },
        kentrick = {
            enabled = true,
            hold_window_ms = 420, min_gap_between = 120,
            disable_delay_min = 80, disable_delay_max = 180,
        },
    },
    move = {
        walk_on_water = false,
        super_jump = false, jump_power = 100,
        custom_speed = false, walk_speed = 16,
    },
}

local function deepCopy(t)
    local o = {}
    for k, v in pairs(t) do o[k] = type(v) == "table" and deepCopy(v) or v end
    return o
end

local function loadCfg()
    if not isfile or not readfile then return deepCopy(DEFAULT_CFG) end
    if not isfile(CFG_PATH) then return deepCopy(DEFAULT_CFG) end
    local ok, txt = pcall(readfile, CFG_PATH)
    if not ok or not txt then return deepCopy(DEFAULT_CFG) end
    local ok2, data = pcall(Http.JSONDecode, Http, txt)
    if not ok2 or type(data) ~= "table" then return deepCopy(DEFAULT_CFG) end
    local merged = deepCopy(DEFAULT_CFG)
    for s, v in pairs(data) do
        if type(v) == "table" and merged[s] then
            for k, vv in pairs(v) do
                if type(vv) == "table" and type(merged[s][k]) == "table" then
                    for k2, v3 in pairs(vv) do merged[s][k][k2] = v3 end
                else
                    merged[s][k] = vv
                end
            end
        end
    end
    return merged
end

local function saveCfg()
    if not writefile then return end
    task.spawn(function() pcall(writefile, CFG_PATH, Http:JSONEncode(CFG)) end)
end

local CFG = loadCfg()
getgenv().STR1KER_CFG = CFG

local DrawNew = (Drawing and Drawing.new) or (syn and syn.drawing and syn.drawing.new)
if not DrawNew then warn("[Str1ker] sem Drawing"); return end

-- ══════════════════════════════════════════════════════════════════════════
-- PLAYER CACHE
-- ══════════════════════════════════════════════════════════════════════════
local activePlayers, espStore, skeleton_pool = {}, {}, {}
local function trackPlayer(p) if p ~= LP then activePlayers[p] = true end end
for _, p in ipairs(Players:GetPlayers()) do trackPlayer(p) end
Players.PlayerAdded:Connect(trackPlayer)
Players.PlayerRemoving:Connect(function(p)
    activePlayers[p] = nil
    local s = espStore[p]
    if s then for _, d in pairs(s) do if d then d.Visible = false end end espStore[p] = nil end
    local sk = skeleton_pool[p]
    if sk then for _, l in ipairs(sk) do pcall(function() l:Remove() end) end skeleton_pool[p] = nil end
    if AimSmart and AimSmart.history then AimSmart.history[p] = nil end
end)

-- ══════════════════════════════════════════════════════════════════════════
-- SKELETON ESP
-- ══════════════════════════════════════════════════════════════════════════
local BONES_R6 = {{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}
local BONES_R15 = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}
local function get_skel_pool(plr, count)
    local p = skeleton_pool[plr] or {}; skeleton_pool[plr] = p
    while #p < count do
        local l = DrawNew("Line"); l.Visible = false; l.Thickness = 1; l.Transparency = 1
        l.Color = Color3.fromRGB(59,130,246); table.insert(p, l)
    end
    return p
end
local function hide_skel(plr)
    local p = skeleton_pool[plr]; if not p then return end
    for _, l in ipairs(p) do l.Visible = false end
end
local function draw_skel(plr, color, thick)
    local char = plr.Character; if not char then hide_skel(plr); return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then hide_skel(plr); return end
    local bones = (hum.RigType == Enum.HumanoidRigType.R6) and BONES_R6 or BONES_R15
    local cache, pool = {}, get_skel_pool(plr, #bones)
    local cam = Camera
    for i, pair in ipairs(bones) do
        if not cache[pair[1]] then cache[pair[1]] = char:FindFirstChild(pair[1]) end
        if not cache[pair[2]] then cache[pair[2]] = char:FindFirstChild(pair[2]) end
        local a, b, l = cache[pair[1]], cache[pair[2]], pool[i]
        if a and b then
            local sa, oa = cam:WorldToViewportPoint(a.Position)
            local sb, ob = cam:WorldToViewportPoint(b.Position)
            if oa and ob and sa.Z > 0 and sb.Z > 0 then
                l.From = V2(sa.X, sa.Y); l.To = V2(sb.X, sb.Y)
                l.Color = color or Color3.fromRGB(59,130,246)
                l.Thickness = thick or 1; l.Visible = true
            else l.Visible = false end
        else l.Visible = false end
    end
end

-- ══════════════════════════════════════════════════════════════════════════
-- ESP INIT
-- ══════════════════════════════════════════════════════════════════════════
local function initESP(p)
    local s = espStore[p]; if s then return s end
    s = {
        box = DrawNew("Square"), box_out = DrawNew("Square"),
        hp_bg = DrawNew("Square"), hp_fill = DrawNew("Square"),
        name = DrawNew("Text"), distance = DrawNew("Text"), level = DrawNew("Text"),
        tracer = DrawNew("Line"),
        icon_wpn = DrawNew("Image"), icon_head = DrawNew("Image"), icon_bg = DrawNew("Square"),
        name_bg = DrawNew("Square"), dist_bg = DrawNew("Square"), level_bg = DrawNew("Square"),
    }
    for _, key in ipairs({"box","box_out"}) do
        if s[key] then s[key].Filled = false; s[key].Thickness = CFG.esp.thickness end
    end
    if s.box_out then s.box_out.Thickness = CFG.esp.thickness + 1; s.box_out.Color = Color3.fromRGB(0,0,0) end
    if s.hp_bg then s.hp_bg.Filled = true; s.hp_bg.Color = Color3.fromRGB(0,0,0); s.hp_bg.Transparency = 0.4 end
    if s.hp_fill then s.hp_fill.Filled = true end
    if s.name then s.name.Size = 14; s.name.Center = true; s.name.Outline = true
        s.name.OutlineColor = Color3.fromRGB(0,0,0); s.name.Font = 2 end
    if s.distance then s.distance.Size = 12; s.distance.Center = true; s.distance.Outline = true
        s.distance.OutlineColor = Color3.fromRGB(0,0,0); s.distance.Font = 2
        s.distance.Color = Color3.fromRGB(180,190,210) end
    if s.level then s.level.Size = 11; s.level.Center = true; s.level.Outline = true
        s.level.OutlineColor = Color3.fromRGB(0,0,0); s.level.Font = 2
        s.level.Color = Color3.fromRGB(200,200,255) end
    for _, key in ipairs({"name_bg","dist_bg","level_bg"}) do
        if s[key] then s[key].Filled = true; s[key].Color = Color3.fromRGB(0,0,0); s[key].Transparency = 0.35 end
    end
    if s.icon_bg then s.icon_bg.Filled = true; s.icon_bg.Color = Color3.fromRGB(0,0,0)
        s.icon_bg.Transparency = CFG.esp.icon_opacity / 100 end
    espStore[p] = s
    return s
end

local toolIconCache, headshotCache = {}, {}
local TOOL_ICON_MAP = {
    ["Katana"] = "rbxassetid://6023426926",
    ["Cutlass"] = "rbxassetid://6023426926",
    ["Dragonstorm"] = "rbxassetid://6034684930",
    ["Skull Guitar"] = "rbxassetid://115614569278562",
    ["Dual Flintlock"] = "rbxassetid://6034684930",
    ["Cannon"] = "rbxassetid://6034684930",
}
local function getToolIcon(name)
    if toolIconCache[name] then return toolIconCache[name] end
    local icon = TOOL_ICON_MAP[name] or "rbxassetid://6023426926"
    toolIconCache[name] = icon; return icon
end
local function getHeadshot(userId)
    if headshotCache[userId] then return headshotCache[userId] end
    if httpReq then
        task.spawn(function()
            local ok, res = pcall(httpReq, {
                Url = "https://thumbnails.roblox.com/v1/users/headshot?userId=" .. userId .. "&size=150x150&format=Png&isCircular=false",
                Method = "GET",
            })
            if ok and res and res.Body then
                local d; pcall(function() d = Http:JSONDecode(res.Body) end)
                if d and d.data and d.data[1] then headshotCache[userId] = d.data[1].imageUrl end
            end
        end)
    end
    return headshotCache[userId]
end

-- ══════════════════════════════════════════════════════════════════════════
-- AIM SMART
-- ══════════════════════════════════════════════════════════════════════════
local AimSmart = { history = {}, MAX = 12 }

local function aim_smart_update()
    if not CFG.aim.smart then return end
    for p in pairs(activePlayers) do
        local c = p.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if hrp then
            local h = AimSmart.history[p]
            if not h then h = {}; AimSmart.history[p] = h end
            table.insert(h, { pos = hrp.Position, vel = hrp.AssemblyLinearVelocity, t = tick() })
            local cap = math.max(3, tonumber(CFG.aim.smart_samples) or 8)
            while #h > cap do table.remove(h, 1) end
        else
            AimSmart.history[p] = nil
        end
    end
end

local function aim_smart_predict(part, plr, ping, scale)
    local base = part.Position
    local raw_v = part.AssemblyLinearVelocity
    if raw_v.Magnitude < 0.5 then return base end
    if not CFG.aim.smart then
        if CFG.aim.aggressive_prediction then
            return base + raw_v * math.max(ping, 0.3) * scale
        end
        return base + raw_v * ping * scale
    end
    local h = AimSmart.history[plr]
    if not h or #h < 3 then return base + raw_v * ping * scale end
    local smooth_v, wsum = V3(0,0,0), 0
    for i, s in ipairs(h) do
        local w = i / #h
        smooth_v = smooth_v + s.vel * w
        wsum = wsum + w
    end
    smooth_v = smooth_v / math.max(wsum, 0.0001)
    local a = V3(0,0,0)
    local last, prev = h[#h], h[#h - 1]
    local dt = last.t - prev.t
    if dt > 0 and dt < 0.5 then a = (last.vel - prev.vel) / dt end
    local changes = 0
    for i = 2, #h do
        local pa, pb = h[i-1].vel, h[i].vel
        if pa.Magnitude > 1 and pb.Magnitude > 1 then
            if pa.Unit:Dot(pb.Unit) < 0.7 then changes = changes + 1 end
        end
    end
    local extra = changes >= 2 and (tonumber(CFG.aim.smart_strafe_lead) or 0.05) or 0
    local lead = ping + extra
    local predicted = base + smooth_v * lead * scale
    local aw = tonumber(CFG.aim.smart_accel_weight) or 0.3
    predicted = predicted + a * 0.5 * lead * lead * aw
    return predicted
end

-- ══════════════════════════════════════════════════════════════════════════
-- SPECTATE (câmera principal)
-- ══════════════════════════════════════════════════════════════════════════
local Spectate = {
    active = false, target = nil,
    saved_subject = nil, saved_type = nil,
}

local function spectate_is_valid(plr)
    if not plr or not plr.Parent then return false end
    local c = plr.Character; if not c then return false end
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    return true
end

local function spectate_start(plr)
    if not spectate_is_valid(plr) then return false end
    if plr == LP then return false end
    if not Spectate.active then
        Spectate.saved_subject = Camera.CameraSubject
        Spectate.saved_type = Camera.CameraType
    end
    Camera.CameraType = Enum.CameraType.Custom
    Camera.CameraSubject = plr.Character:FindFirstChildOfClass("Humanoid")
    Spectate.active = true
    Spectate.target = plr
    return true
end

local function spectate_stop()
    if not Spectate.active then return end
    local myChar = LP.Character
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if myHum then Camera.CameraSubject = myHum end
    Camera.CameraType = Spectate.saved_type or Enum.CameraType.Custom
    Spectate.active = false
    Spectate.target = nil
    Spectate.saved_subject = nil
    Spectate.saved_type = nil
end

local function spectate_pick()
    local mode = CFG.esp.spectate_mode or "Nearest"
    if mode == "Aim Target" then
        if aimTarget and spectate_is_valid(aimTarget) then return aimTarget end
        return nil
    end
    if mode == "Manual" then
        local name = CFG.esp.spectate_manual
        if name and name ~= "" then
            local p = Players:FindFirstChild(name)
            if p and spectate_is_valid(p) then return p end
        end
        return nil
    end
    local best, bestD = nil, math.huge
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myPos = myHRP and myHRP.Position or V3(0,0,0)
    for p in pairs(activePlayers) do
        if spectate_is_valid(p) then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d = (hrp.Position - myPos).Magnitude
                if d < bestD then best, bestD = p, d end
            end
        end
    end
    return best
end

local function spectate_cycle()
    local current = Spectate.target
    local list = {}
    for p in pairs(activePlayers) do
        if spectate_is_valid(p) then table.insert(list, p) end
    end
    if #list == 0 then return end
    local idx = 1
    for i, p in ipairs(list) do
        if p == current then idx = i + 1; break end
    end
    if idx > #list then idx = 1 end
    spectate_start(list[idx])
end

task.spawn(function()
    while task.wait(0.3) do
        if CFG.esp.spectate then
            local tgt = Spectate.target
            if not spectate_is_valid(tgt) then
                local new_tgt = spectate_pick()
                if new_tgt then spectate_start(new_tgt)
                elseif Spectate.active then spectate_stop() end
            end
        else
            if Spectate.active then spectate_stop() end
        end
    end
end)

LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if Spectate.active then
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum and CFG.esp.spectate == false then
            Camera.CameraSubject = hum
        end
    end
end)

-- ══════════════════════════════════════════════════════════════════════════
-- SPECTATE UI — botões flutuantes + mini viewport (NOVO v3.10)
-- ══════════════════════════════════════════════════════════════════════════
local SpectateUI = {
    root = nil,
    btn_main = nil,
    btn_mini = nil,
    mini = nil,
    mini_view = nil,
    mini_title = nil,
    mini_close = nil,
    virtual_cam = nil,
    clone = nil,
    clone_owner = nil,
    main_active = false,     -- botão SPECTATE ativo?
    mini_active = false,     -- janela mini ativa?
}

local function spectate_ui_build()
    if SpectateUI.root then return end
    local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")

    local sg = Instance.new("ScreenGui")
    sg.Name = "Str1kerSpectateUI"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder = 101
    sg.Parent = CoreGui
    SpectateUI.root = sg

    -- helper para borda arredondada
    local function corner(o, r)
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = o
    end
    local function stroke(o, col, th, tr)
        local s = Instance.new("UIStroke"); s.Color = col; s.Thickness = th or 1
        s.Transparency = tr or 0; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Parent = o; return s
    end
    local function grad(o, c1, c2, rot)
        local g = Instance.new("UIGradient"); g.Color = ColorSequence.new(c1, c2)
        g.Rotation = rot or 0; g.Parent = o; return g
    end

    -- ── BOTÃO SPECTATE (câmera principal) ─────────────────────────────────
    local b1 = Instance.new("TextButton")
    b1.Size = UDim2.new(0, 120, 0, 34)
    b1.Position = UDim2.new(1, -138, 0, 20)
    b1.BackgroundColor3 = Color3.fromRGB(15, 30, 51)
    b1.BorderSizePixel = 0
    b1.Font = Enum.Font.GothamBold
    b1.TextSize = 12
    b1.TextColor3 = Color3.fromRGB(96, 165, 250)
    b1.Text = "SPECTATE"
    b1.AutoButtonColor = false
    b1.ZIndex = 5
    b1.Parent = sg
    corner(b1, 8)
    stroke(b1, Color3.fromRGB(38, 68, 112), 1)

    b1.MouseEnter:Connect(function()
        TweenService:Create(b1, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(20, 40, 68),
        }):Play()
    end)
    b1.MouseLeave:Connect(function()
        if not SpectateUI.main_active then
            TweenService:Create(b1, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(15, 30, 51),
            }):Play()
        end
    end)

    SpectateUI.btn_main = b1

    -- ── BOTÃO MINI VIEW ───────────────────────────────────────────────────
    local b2 = Instance.new("TextButton")
    b2.Size = UDim2.new(0, 120, 0, 34)
    b2.Position = UDim2.new(1, -138, 0, 60)
    b2.BackgroundColor3 = Color3.fromRGB(15, 30, 51)
    b2.BorderSizePixel = 0
    b2.Font = Enum.Font.GothamBold
    b2.TextSize = 12
    b2.TextColor3 = Color3.fromRGB(96, 165, 250)
    b2.Text = "MINI VIEW"
    b2.AutoButtonColor = false
    b2.ZIndex = 5
    b2.Parent = sg
    corner(b2, 8)
    stroke(b2, Color3.fromRGB(38, 68, 112), 1)

    b2.MouseEnter:Connect(function()
        TweenService:Create(b2, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(20, 40, 68),
        }):Play()
    end)
    b2.MouseLeave:Connect(function()
        if not SpectateUI.mini_active then
            TweenService:Create(b2, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(15, 30, 51),
            }):Play()
        end
    end)

    SpectateUI.btn_mini = b2

    -- ── MINI WINDOW ───────────────────────────────────────────────────────
    local sizeW = (CFG.esp.spectate_mini_size and CFG.esp.spectate_mini_size[1]) or 240
    local sizeH = (CFG.esp.spectate_mini_size and CFG.esp.spectate_mini_size[2]) or 180

    local mini = Instance.new("Frame")
    mini.Size = UDim2.new(0, sizeW, 0, sizeH + 26)
    mini.Position = UDim2.new(1, -sizeW - 18, 0, 100)
    mini.BackgroundColor3 = Color3.fromRGB(8, 16, 31)
    mini.BorderSizePixel = 0
    mini.Visible = false
    mini.ZIndex = 6
    mini.Parent = sg
    corner(mini, 10)
    stroke(mini, Color3.fromRGB(38, 68, 112), 1)
    SpectateUI.mini = mini

    -- titlebar
    local titlebar = Instance.new("Frame")
    titlebar.Size = UDim2.new(1, 0, 0, 26)
    titlebar.BackgroundColor3 = Color3.fromRGB(10, 20, 36)
    titlebar.BorderSizePixel = 0
    titlebar.ZIndex = 7
    titlebar.Parent = mini
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0, 10)
    tc.Parent = titlebar
    -- corrige cantos de baixo
    local fix = Instance.new("Frame")
    fix.Size = UDim2.new(1, 0, 0, 10)
    fix.Position = UDim2.new(0, 0, 1, -10)
    fix.BackgroundColor3 = Color3.fromRGB(10, 20, 36)
    fix.BorderSizePixel = 0
    fix.ZIndex = 7
    fix.Parent = titlebar

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -32, 1, 0)
    titleLbl.Position = UDim2.new(0, 10, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 11
    titleLbl.TextColor3 = Color3.fromRGB(96, 165, 250)
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Text = "TARGET VIEW"
    titleLbl.ZIndex = 8
    titleLbl.Parent = titlebar
    SpectateUI.mini_title = titleLbl

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.Position = UDim2.new(1, -26, 0.5, -11)
    closeBtn.BackgroundColor3 = Color3.fromRGB(50, 15, 15)
    closeBtn.BorderSizePixel = 0
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 12
    closeBtn.TextColor3 = Color3.fromRGB(239, 68, 68)
    closeBtn.Text = "×"
    closeBtn.AutoButtonColor = false
    closeBtn.ZIndex = 8
    closeBtn.Parent = titlebar
    corner(closeBtn, 6)
    SpectateUI.mini_close = closeBtn

    -- viewport
    local vp = Instance.new("ViewportFrame")
    vp.Size = UDim2.new(1, 0, 1, -26)
    vp.Position = UDim2.new(0, 0, 0, 26)
    vp.BackgroundColor3 = Color3.fromRGB(30, 45, 70)
    vp.BorderSizePixel = 0
    vp.Ambient = Color3.fromRGB(190, 200, 220)
    vp.LightColor = Color3.fromRGB(255, 255, 255)
    vp.LightDirection = Vector3.new(-0.4, -0.6, -0.6)
    vp.ZIndex = 7
    vp.Parent = mini
    SpectateUI.mini_view = vp

    local vc = Instance.new("Camera")
    vc.FieldOfView = (CFG.esp.spectate_mini_fov) or 70
    vp.CurrentCamera = vc
    SpectateUI.virtual_cam = vc

    -- drag do mini window
    local dragOn, dragStart, startPos
    titlebar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragOn = true; dragStart = input.Position; startPos = mini.Position
        end
    end)
    titlebar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragOn = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragOn and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            mini.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        SpectateUI.mini_active = false
        mini.Visible = false
        if SpectateUI.btn_mini then
            TweenService:Create(SpectateUI.btn_mini, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(15, 30, 51),
            }):Play()
        end
    end)
end

-- Constrói a UI
spectate_ui_build()

-- ── Clone management ──────────────────────────────────────────────────────
local function spectate_clone_set(plr)
    if SpectateUI.clone and SpectateUI.clone_owner == plr then return end
    if SpectateUI.clone then
        pcall(function() SpectateUI.clone:Destroy() end)
        SpectateUI.clone = nil
        SpectateUI.clone_owner = nil
    end
    if not plr or not plr.Character then return end

    local ok, clone = pcall(function() return plr.Character:Clone() end)
    if not ok or not clone then return end

    -- limpa
    for _, inst in ipairs(clone:GetDescendants()) do
        if inst:IsA("Script") or inst:IsA("LocalScript") or inst:IsA("ModuleScript") then
            inst:Destroy()
        end
        if inst:IsA("BasePart") then
            inst.Anchored = true
            inst.CanCollide = false
        end
    end
    local hum = clone:FindFirstChildOfClass("Humanoid")
    if hum then hum:Destroy() end

    clone.Parent = SpectateUI.mini_view
    SpectateUI.clone = clone
    SpectateUI.clone_owner = plr
end

-- ── Button handlers ───────────────────────────────────────────────────────
local function set_button_state(btn, active)
    if not btn then return end
    TweenService:Create(btn, TweenInfo.new(0.15), {
        BackgroundColor3 = active and Color3.fromRGB(30, 64, 175) or Color3.fromRGB(15, 30, 51),
    }):Play()
    btn.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(96, 165, 250)
end

SpectateUI.btn_main.MouseButton1Click:Connect(function()
    if SpectateUI.main_active then
        -- desligar
        SpectateUI.main_active = false
        set_button_state(SpectateUI.btn_main, false)
        CFG.esp.spectate = false
        spectate_stop()
        saveCfg()
    else
        -- ligar
        local tgt = Spectate.target or spectate_pick()
        if not tgt then
            SpectateUI.btn_main.Text = "NO TARGET"
            task.delay(1.2, function() SpectateUI.btn_main.Text = "SPECTATE" end)
            return
        end
        CFG.esp.spectate = true
        spectate_start(tgt)
        SpectateUI.main_active = true
        set_button_state(SpectateUI.btn_main, true)
        saveCfg()
    end
end)

SpectateUI.btn_mini.MouseButton1Click:Connect(function()
    if SpectateUI.mini_active then
        SpectateUI.mini_active = false
        SpectateUI.mini.Visible = false
        set_button_state(SpectateUI.btn_mini, false)
        if SpectateUI.clone then
            pcall(function() SpectateUI.clone:Destroy() end)
            SpectateUI.clone = nil
            SpectateUI.clone_owner = nil
        end
    else
        local tgt = Spectate.target or spectate_pick()
        if not tgt then
            SpectateUI.btn_mini.Text = "NO TARGET"
            task.delay(1.2, function() SpectateUI.btn_mini.Text = "MINI VIEW" end)
            return
        end
        SpectateUI.mini_active = true
        SpectateUI.mini.Visible = true
        set_button_state(SpectateUI.btn_mini, true)
        spectate_clone_set(tgt)
    end
end)

-- ── Update loop da mini window ────────────────────────────────────────────
RunService.RenderStepped:Connect(function()
    -- sync botão SPECTATE com espectate global
    if SpectateUI.main_active and not CFG.esp.spectate then
        SpectateUI.main_active = false
        set_button_state(SpectateUI.btn_main, false)
    end

    if not SpectateUI.mini_active or not SpectateUI.mini.Visible then return end

    -- pega alvo atual (ou nearest se spectate não estiver ativo)
    local tgt = Spectate.target
    if not spectate_is_valid(tgt) then
        tgt = spectate_pick()
        if tgt then
            Spectate.target = tgt
        end
    end

    if not tgt then
        SpectateUI.mini_title.Text = "NO TARGET"
        return
    end

    SpectateUI.mini_title.Text = "TARGET: " .. tgt.Name

    -- atualiza clone se mudou de alvo
    if SpectateUI.clone_owner ~= tgt then
        spectate_clone_set(tgt)
    end

    -- atualiza posição do clone
    if SpectateUI.clone and SpectateUI.clone_owner == tgt then
        local char = tgt.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local ok = pcall(function()
                SpectateUI.clone:PivotTo(hrp.CFrame)
            end)
            if not ok then
                -- fallback: seta CFrame por partes
                for _, part in ipairs(SpectateUI.clone:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local orig = char:FindFirstChild(part.Name)
                        if orig and orig:IsA("BasePart") then
                            part.CFrame = orig.CFrame
                        end
                    end
                end
            end
        end
    end

    -- posiciona câmera virtual atrás da cabeça do alvo
    local char = tgt.Character
    local head = char and char:FindFirstChild("Head")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if head and hrp then
        local cam = SpectateUI.virtual_cam
        if cam then
            local lookDir = head.CFrame.LookVector
            local camPos = head.Position - lookDir * 8 + V3(0, 2.5, 0)
            cam.CFrame = CFrame.lookAt(camPos, head.Position + lookDir * 2)
        end
    end
end)

-- Aplica visibilidade dos botões baseado no cfg
task.spawn(function()
    while task.wait(0.5) do
        if SpectateUI.btn_main then
            SpectateUI.btn_main.Visible = CFG.esp.spectate_show_button and true or false
        end
        if SpectateUI.btn_mini then
            SpectateUI.btn_mini.Visible = CFG.esp.spectate_show_mini and true or false
        end
        if not CFG.esp.spectate_show_mini and SpectateUI.mini_active then
            SpectateUI.mini_active = false
            SpectateUI.mini.Visible = false
        end
    end
end)

-- ══════════════════════════════════════════════════════════════════════════
-- SELF-LEARNING CORE
-- ══════════════════════════════════════════════════════════════════════════
local Learn = {
    data = {}, attacks = {}, damage = {}, parts = {},
    last_humanoid = nil, last_health = nil,
}

task.spawn(function()
    if not isfile or not readfile then return end
    if not isfile(LEARN_PATH) then return end
    local ok, txt = pcall(readfile, LEARN_PATH)
    if not ok or not txt then return end
    local ok2, data = pcall(Http.JSONDecode, Http, txt)
    if ok2 and type(data) == "table" then
        Learn.data = data
        local count = 0
        for _ in pairs(data) do count = count + 1 end
        if count > 0 then print(("[Str1ker] dodge: %d remotes carregados"):format(count)) end
    end
end)

local function saveLearn()
    if not writefile then return end
    task.spawn(function() pcall(writefile, LEARN_PATH, Http:JSONEncode(Learn.data)) end)
end

local function getStats(remote)
    if not Learn.data[remote] then
        Learn.data[remote] = {
            latency_samples = {}, avg_latency = nil,
            hits = 0, misses = 0, dodges = 0,
            cues = {}, known_cues = {},
            distance_samples = {}, distance_avg = nil,
            category_hint = "unknown",
        }
    end
    return Learn.data[remote]
end

local function pruneBuffers()
    local now = tick()
    local win = CFG.dodge.learn_window_ms / 1000
    local i = 1
    while i <= #Learn.attacks do
        if now - Learn.attacks[i].t > win then table.remove(Learn.attacks, i) else i = i + 1 end
    end
    i = 1
    while i <= #Learn.damage do
        if now - Learn.damage[i].t > win then table.remove(Learn.damage, i) else i = i + 1 end
    end
    i = 1
    while i <= #Learn.parts do
        if now - Learn.parts[i].t > win then table.remove(Learn.parts, i) else i = i + 1 end
    end
end

local function observePart(part)
    if not CFG.dodge.learning then return end
    if not part or not part:IsA("BasePart") then return end
    local char = LP.Character
    if char and part:IsDescendantOf(char) then return end
    local ancestor = part:FindFirstAncestorOfClass("Model")
    while ancestor do
        if ancestor:FindFirstChildOfClass("Humanoid") then return end
        ancestor = ancestor:FindFirstAncestorOfClass("Model")
    end
    local n = part.Name
    if n == "Handle" or n == "Head" or n == "Torso" or n == "HumanoidRootPart" then return end
    if string.find(n, "Accessory") or string.find(n, "Hat") or string.find(n, "Mesh") then return end
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local dist = (part.Position - myHRP.Position).Magnitude
    if dist > CFG.dodge.learn_distance_max then return end
    table.insert(Learn.parts, { t = tick(), name = part.Name, pos = part.Position })
    if #Learn.parts > 60 then table.remove(Learn.parts, 1) end
end

-- ══════════════════════════════════════════════════════════════════════════
-- MACRO LAYER
-- ══════════════════════════════════════════════════════════════════════════
local NativeInput = {
    keypress = rawget(_G, "keypress"),
    keyrelease = rawget(_G, "keyrelease"),
}
NativeInput.hasmethod = (NativeInput.keypress and NativeInput.keyrelease) and true or false

local Macro = {
    minute_start = tick(), actions_this_minute = 0, consecutive_dodges = 0,
    fatigue_until = 0, last_action = 0, dash_key_index = 1, active_keys = {},
}

local function macro_reaction()
    local mn = CFG.dodge.macro.reaction_min_ms / 1000
    local mx = CFG.dodge.macro.reaction_max_ms / 1000
    return mn + math.random() * (mx - mn)
end
local function macro_hold()
    local mn = CFG.dodge.macro.hold_min_ms / 1000
    local mx = CFG.dodge.macro.hold_max_ms / 1000
    return mn + math.random() * (mx - mn)
end
local function macro_should_skip() return math.random() < CFG.dodge.macro.skip_chance end
local function macro_update_budget()
    local now = tick()
    if now - Macro.minute_start >= 60 then
        Macro.minute_start = now
        Macro.actions_this_minute = 0
        if Macro.consecutive_dodges >= CFG.dodge.macro.fatigue_after then
            local fmin = CFG.dodge.macro.fatigue_duration_min
            local fmax = CFG.dodge.macro.fatigue_duration_max
            Macro.fatigue_until = now + fmin + math.random() * (fmax - fmin)
            Macro.consecutive_dodges = 0
        end
    end
end
local function macro_can_act()
    local now = tick()
    if not CFG.dodge.macro.enabled then return true end
    if now < Macro.fatigue_until then return false, "fatigue" end
    if Macro.actions_this_minute >= CFG.dodge.macro.actions_per_minute then return false, "budget" end
    if now - Macro.last_action < 0.12 then return false, "cooldown" end
    return true
end

local function macro_press(keycode, custom_hold)
    if not keycode then return false end
    local ok, reason = macro_can_act()
    if not ok then
        if CFG.dodge.log_triggers then print(("[Str1ker] macro skip: %s"):format(reason)) end
        return false
    end
    Macro.actions_this_minute = Macro.actions_this_minute + 1
    Macro.consecutive_dodges = Macro.consecutive_dodges + 1
    Macro.last_action = tick()
    local hold = custom_hold or macro_hold()
    if CFG.dodge.macro.use_native_input and NativeInput.hasmethod then
        pcall(function()
            NativeInput.keypress(keycode)
            task.delay(hold, function()
                pcall(function() NativeInput.keyrelease(keycode) end)
            end)
        end)
        return true
    end
    pcall(function()
        local vim = game:GetService("VirtualInputManager")
        if not vim then return end
        vim:SendKeyEvent(true, keycode, false, game)
        task.delay(hold, function()
            pcall(function() vim:SendKeyEvent(false, keycode, false, game) end)
        end)
    end)
    return true
end

local DASH_ROTATION = { Enum.KeyCode.R, Enum.KeyCode.R, Enum.KeyCode.Space }
local function macro_next_dash_key()
    if not CFG.dodge.macro.rotate_dash_keys then return Enum.KeyCode.R end
    Macro.dash_key_index = Macro.dash_key_index + 1
    if Macro.dash_key_index > #DASH_ROTATION then Macro.dash_key_index = 1 end
    return DASH_ROTATION[Macro.dash_key_index]
end

local function macro_jitter_target(base_target, threat_pos)
    if not CFG.dodge.macro.add_micro_jitter then return base_target end
    local jitter = CFG.dodge.macro.jitter_studs
    local axis = base_target - threat_pos
    if axis.Magnitude < 0.5 then return base_target end
    local dir = axis.Unit
    local perp = V3(-dir.Z, 0, dir.X)
    local lateral = (math.random() - 0.5) * 2 * jitter
    local vertical = math.random() < 0.25 and math.random(0, 4) or 0
    return base_target + perp * lateral + V3(0, vertical, 0)
end

local KenTrick = { is_on = false, last_toggle = 0, pending_disable = nil, toggle_count = 0 }
local function kentrick_schedule_disable()
    if KenTrick.pending_disable then pcall(function() task.cancel(KenTrick.pending_disable) end) end
    local dmin = CFG.dodge.kentrick.disable_delay_min / 1000
    local dmax = CFG.dodge.kentrick.disable_delay_max / 1000
    local delay = CFG.dodge.kentrick.hold_window_ms / 1000 + dmin + math.random() * (dmax - dmin)
    KenTrick.pending_disable = task.delay(delay, function()
        if KenTrick.is_on then
            macro_press(Enum.KeyCode.J, 0.05)
            KenTrick.is_on = false
            KenTrick.pending_disable = nil
            KenTrick.toggle_count = KenTrick.toggle_count + 1
            if CFG.dodge.log_triggers then print("[Str1ker] kentrick: OFF") end
        end
    end)
end
local function kentrick_activate()
    if not CFG.dodge.kentrick.enabled then return false end
    local now = tick()
    local min_gap = CFG.dodge.kentrick.min_gap_between / 1000
    if now - KenTrick.last_toggle < min_gap then return false end
    if KenTrick.is_on then kentrick_schedule_disable(); return true end
    if KenTrick.pending_disable then
        pcall(function() task.cancel(KenTrick.pending_disable) end)
        KenTrick.pending_disable = nil
    end
    if not macro_press(Enum.KeyCode.J, 0.05) then return false end
    KenTrick.is_on = true
    KenTrick.last_toggle = now
    KenTrick.toggle_count = KenTrick.toggle_count + 1
    if CFG.dodge.log_triggers then print("[Str1ker] kentrick: ON") end
    kentrick_schedule_disable()
    return true
end
local function kentrick_force_off()
    if not KenTrick.is_on then return end
    if KenTrick.pending_disable then
        pcall(function() task.cancel(KenTrick.pending_disable) end)
        KenTrick.pending_disable = nil
    end
    macro_press(Enum.KeyCode.J, 0.05)
    KenTrick.is_on = false
    KenTrick.toggle_count = KenTrick.toggle_count + 1
end

local Phasing = { last_use = 0 }
local function macro_activate_phasing()
    if tick() - Phasing.last_use < 10 then return false end
    local ok = macro_press(Enum.KeyCode.G, 0.06)
    if ok then Phasing.last_use = tick(); return true end
    return false
end

local function macro_physical_dodge(threat_pos)
    local myChar = LP.Character; if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart"); if not myRoot then return end
    local hum = myChar:FindFirstChildOfClass("Humanoid"); if not hum then return end
    task.delay(macro_reaction(), function()
        local ok = macro_can_act(); if not ok then return end
        local currentPos = myRoot.Position
        local away = currentPos - threat_pos
        if away.Magnitude < 0.1 then away = V3(0, 0, 1) end
        away = away.Unit
        local target = currentPos + away * 25
        target = macro_jitter_target(target, threat_pos)
        local dash_key = macro_next_dash_key()
        macro_press(dash_key, macro_hold())
        task.delay(0.04 + math.random() * 0.03, function()
            pcall(function() hum:MoveTo(target) end)
        end)
    end)
end

-- ══════════════════════════════════════════════════════════════════════════
-- OBSERVERS
-- ══════════════════════════════════════════════════════════════════════════
local Dodge = {
    last_dodge = 0, incoming_direct = {},
    status = "idle", pending_confirm = nil,
}

function correlateDamage()
    if #Learn.damage == 0 then return end
    local dmg = Learn.damage[#Learn.damage]
    if not dmg then return end
    local candidates = {}
    for _, atk in ipairs(Learn.attacks) do
        if dmg.t - atk.t >= 0 and dmg.t - atk.t <= CFG.dodge.learn_window_ms / 1000 then
            table.insert(candidates, atk)
        end
    end
    if #candidates == 0 or #candidates > 2 then return end
    table.sort(candidates, function(a, b) return a.t > b.t end)
    local atk = candidates[1]
    local latency_ms = (dmg.t - atk.t) * 1000
    if latency_ms < 0 or latency_ms > 1500 then return end
    local stats = getStats(atk.remote)
    table.insert(stats.latency_samples, latency_ms)
    if #stats.latency_samples > 30 then table.remove(stats.latency_samples, 1) end
    local sum = 0
    for _, s in ipairs(stats.latency_samples) do sum = sum + s end
    stats.avg_latency = sum / #stats.latency_samples
    stats.hits = stats.hits + 1
    local cue_lo = dmg.t - 0.5
    local cue_hi = dmg.t - 0.1
    for _, p in ipairs(Learn.parts) do
        if p.t >= cue_lo and p.t <= cue_hi then
            stats.cues[p.name] = (stats.cues[p.name] or 0) + 1
        end
    end
    for name, count in pairs(stats.cues) do
        if count >= CFG.dodge.learn_promote_cue then stats.known_cues[name] = count end
    end
    if not stats.category_hint or stats.category_hint == "unknown" then
        if #stats.latency_samples >= CFG.dodge.learn_min_samples then
            if stats.avg_latency and stats.avg_latency < 150 then stats.category_hint = "physical"
            elseif stats.avg_latency and stats.avg_latency > 300 then stats.category_hint = "ken" end
        end
    end
    saveLearn()
end

function markDodge(remote)
    if not remote then return end
    local stats = getStats(remote)
    stats.dodges = stats.dodges + 1
    if stats.dodges >= 3 and stats.hits <= stats.dodges / 3 then stats.category_hint = "ken" end
    saveLearn()
end

local function getDecision(remote)
    local stats = Learn.data[remote]
    if not stats then return "physical", 0 end
    local conf = #stats.latency_samples
    if conf < CFG.dodge.learn_min_samples then return "physical", conf end
    if stats.category_hint == "physical" then return "physical", conf end
    if stats.category_hint == "ken" then return "ken", conf end
    local total = stats.hits + stats.dodges
    if total == 0 then return "physical", 0 end
    local ratio = stats.dodges / total
    if ratio > 0.6 then return "ken", conf end
    if ratio < 0.2 then return "physical", conf end
    return "physical", conf
end

local function macro_do_dodge(remote, threat_pos, mode)
    if macro_should_skip() then
        if CFG.dodge.macro.announce_miss and CFG.dodge.log_triggers then
            print(("[Str1ker] macro miss: %s"):format(tostring(remote)))
        end
        return false
    end
    if mode == "phasing" then
        if macro_activate_phasing() then return true end
        macro_physical_dodge(threat_pos); return false
    end
    if mode == "ken" then
        if CFG.dodge.kentrick.enabled and kentrick_activate() then return true end
        if CFG.dodge.auto_ken then
            if macro_press(Enum.KeyCode.J, 0.05) then return true end
        end
        macro_physical_dodge(threat_pos); return false
    end
    if mode == "ken_then_physical" then
        local used = false
        if CFG.dodge.kentrick.enabled then used = kentrick_activate() end
        task.delay(0.25 + math.random() * 0.1, function() macro_physical_dodge(threat_pos) end)
        return used
    end
    macro_physical_dodge(threat_pos); return false
end

-- ══════════════════════════════════════════════════════════════════════════
-- AIM TARGET
-- ══════════════════════════════════════════════════════════════════════════
local cachedPing, lastPingAt = 60, 0
local function getPing()
    if tick() - lastPingAt > 0.5 then
        local ok, v = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
        cachedPing = ok and v or 60; lastPingAt = tick()
    end
    return cachedPing / 1000
end

local aimTarget, aimLockAt = nil, 0
local LOCK_DURATION = 0.25

local function isValid(p)
    if p == LP then return false end
    local c = p.Character; if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return false end
    if CFG.aim.team_check and p.Team and LP.Team and p.Team == LP.Team then return false end
    return true
end

local function getPart(char)
    local ap = CFG.aim.aim_part
    if ap == "Head" then return char:FindFirstChild("Head") end
    if ap == "Torso" then return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") end
    return char:FindFirstChild("HumanoidRootPart")
end

local function pickTarget()
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    local myPos = myHRP.Position
    local mouse = UIS:GetMouseLocation()
    local fovSq = CFG.aim.fov * CFG.aim.fov
    local best, bestScore = nil, math.huge
    for p in pairs(activePlayers) do
        if isValid(p) then
            local c = p.Character
            local part = c and getPart(c)
            if part then
                local pos = part.Position
                local d = (pos - myPos).Magnitude
                if d <= CFG.aim.max_distance then
                    local sp, on = Camera:WorldToViewportPoint(pos)
                    if on then
                        local dx, dy = sp.X - mouse.X, sp.Y - mouse.Y
                        local sd = dx*dx + dy*dy
                        if sd <= fovSq then
                            local score = sd + d * 0.1
                            if score < bestScore then best, bestScore = p, score end
                        end
                    end
                end
            end
        end
    end
    return best
end

-- ══════════════════════════════════════════════════════════════════════════
-- HOOKS
-- ══════════════════════════════════════════════════════════════════════════
local function startObservers()
    if getrawmetatable and setreadonly and newcclosure then
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" and self:IsA("RemoteEvent") then
                if CFG.aim.enabled and aimTarget and (CFG.aim.mode == "Silent" or CFG.aim.mode == "Both") then
                    local c = aimTarget.Character
                    local part = c and (c:FindFirstChild("Head") or c:FindFirstChild("UpperTorso") or c:FindFirstChild("HumanoidRootPart"))
                    if part then
                        local ping = getPing() + CFG.aim.resolver
                        local pp = aim_smart_predict(part, aimTarget, ping, CFG.aim.prediction_scale)
                        local args = {...}
                        local changed = false
                        for i = 1, #args do
                            local t = typeof(args[i])
                            if t == "Vector3" then args[i] = pp; changed = true
                            elseif t == "CFrame" then args[i] = CF(pp); changed = true end
                        end
                        if changed then
                            if CFG.dodge.enabled and CFG.dodge.learning then
                                local myChar = LP.Character
                                local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                                table.insert(Learn.attacks, {
                                    t = tick(), remote = self.Name, args = args,
                                    attacker_pos = myHRP and myHRP.Position or nil,
                                })
                                if #Learn.attacks > 40 then table.remove(Learn.attacks, 1) end
                            end
                            return oldNamecall(self, unpack(args))
                        end
                    end
                end
                if CFG.dodge.enabled and CFG.dodge.detect_remote and CFG.dodge.learning then
                    local args = {...}
                    local hasVec = false
                    for _, a in ipairs(args) do
                        local t = typeof(a)
                        if t == "Vector3" or t == "CFrame" then hasVec = true; break end
                    end
                    if hasVec then
                        local myChar = LP.Character
                        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                        table.insert(Learn.attacks, {
                            t = tick(), remote = self.Name, args = args,
                            attacker_pos = myHRP and myHRP.Position or nil,
                        })
                        if #Learn.attacks > 40 then table.remove(Learn.attacks, 1) end
                        table.insert(Dodge.incoming_direct, {
                            t = tick(), remote = self.Name, args = args,
                        })
                        if #Dodge.incoming_direct > 15 then table.remove(Dodge.incoming_direct, 1) end
                    end
                end
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end

    local function hookHumanoid(hum)
        if Learn.last_humanoid == hum then return end
        if Learn.last_humanoid then pcall(function() Learn.last_humanoid.HealthChanged:Disconnect() end) end
        Learn.last_humanoid = hum
        Learn.last_health = hum.Health
        hum.HealthChanged:Connect(function(newHp)
            local old = Learn.last_health or newHp
            if newHp < old then
                table.insert(Learn.damage, { t = tick(), old = old, new = newHp, drop = old - newHp })
                if #Learn.damage > 20 then table.remove(Learn.damage, 1) end
                pcall(correlateDamage)
                kentrick_force_off()
            end
            Learn.last_health = newHp
        end)
    end
    local function bindCharacter()
        local char = LP.Character; if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hookHumanoid(hum) end
    end
    if LP.Character then bindCharacter() end
    LP.CharacterAdded:Connect(function() task.wait(0.5); bindCharacter() end)

    local partBuffer = {}
    Workspace.DescendantAdded:Connect(function(inst)
        if not CFG.dodge.enabled or not CFG.dodge.learning then return end
        if not inst:IsA("BasePart") then return end
        table.insert(partBuffer, inst)
    end)
    task.spawn(function()
        while task.wait(0.05) do
            if CFG.dodge.enabled and CFG.dodge.learning then
                local count = #partBuffer
                for i = 1, count do
                    local inst = partBuffer[i]
                    if inst and inst.Parent then observePart(inst) end
                end
                for i = count, 1, -1 do partBuffer[i] = nil end
                pruneBuffers()
            else
                partBuffer = {}
            end
        end
    end)
end

-- ══════════════════════════════════════════════════════════════════════════
-- DODGE LOOP
-- ══════════════════════════════════════════════════════════════════════════
task.spawn(function()
    while task.wait(CFG.dodge.ken_recheck_interval) do
        if not CFG.dodge.enabled then continue end
        local now = tick()
        if now - Dodge.last_dodge < CFG.dodge.dodge_cooldown then continue end
        local myChar = LP.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then continue end
        local myPos = myHRP.Position

        for _, p in ipairs(Learn.parts) do
            if now - p.t < 0.3 then
                local dist = (p.pos - myPos).Magnitude
                if dist < 60 then
                    for remote, stats in pairs(Learn.data) do
                        if stats.known_cues and stats.known_cues[p.name] then
                            if CFG.dodge.log_triggers then
                                print(("[Str1ker] cue: %s → %s"):format(p.name, remote))
                            end
                            local mode = getDecision(remote)
                            macro_do_dodge(remote, p.pos, mode)
                            Dodge.last_dodge = tick()
                            Dodge.status = "predictive_" .. remote
                            Dodge.pending_confirm = { remote = remote, t = tick() }
                            break
                        end
                    end
                end
            end
        end

        for idx = #Dodge.incoming_direct, 1, -1 do
            local atk = Dodge.incoming_direct[idx]
            if now - atk.t > 1.0 then table.remove(Dodge.incoming_direct, idx)
            elseif now - atk.t <= CFG.dodge.i_frame_window + 0.1 then
                local threat_pos
                for _, a in ipairs(atk.args) do
                    if typeof(a) == "Vector3" then threat_pos = a; break
                    elseif typeof(a) == "CFrame" then threat_pos = a.Position; break end
                end
                if not threat_pos then threat_pos = myPos end
                local mode, conf = getDecision(atk.remote)
                if CFG.dodge.log_triggers then
                    print(("[Str1ker] react: %s (conf=%d) → %s"):format(atk.remote, conf, mode))
                end
                macro_do_dodge(atk.remote, threat_pos, mode)
                Dodge.last_dodge = tick()
                Dodge.status = "reactive_" .. mode .. "_" .. atk.remote
                Dodge.pending_confirm = { remote = atk.remote, t = tick() }
                break
            end
        end

        if Dodge.pending_confirm then
            local pc = Dodge.pending_confirm
            if now - pc.t > 0.6 then
                markDodge(pc.remote)
                Dodge.pending_confirm = nil
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do macro_update_budget() end
end)

LP.CharacterAdded:Connect(function()
    task.wait(0.3)
    KenTrick.is_on = false
    KenTrick.pending_disable = nil
end)

startObservers()

-- ══════════════════════════════════════════════════════════════════════════
-- GLOBALS READER
-- ══════════════════════════════════════════════════════════════════════════
local Glb = {
    last_buso = 0, last_ken = 0, last_v3 = 0, last_v4 = 0,
    last_fruit_check = 0, last_store_check = 0,
}

local CombatFrameworkR = nil
pcall(function()
    CombatFrameworkR = require(LP.PlayerScripts.CombatFramework)
end)

local function getCombatController()
    local cf = CombatFrameworkR
    if not cf then return nil end
    return cf.activeController
end

local function fastAttackOnce()
    if not (getgenv().Usefastattack or getgenv().SuperFastAttack) then return end
    local ctrl = getCombatController()
    if not ctrl then return end
    pcall(function()
        ctrl.hitboxMagnitude = getgenv().SuperFastAttack and 60 or 55
        ctrl.timeToNextAttack = 0
        ctrl.attacking = false
        ctrl.increment = 3
        ctrl.blocking = false
        ctrl.timeToNextBlock = 0
        if ctrl.attack then ctrl:attack() end
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Sit = false end
    end)
end

local function autoBuso()
    if not getgenv().Str1kerAutoBuso then return end
    local now = tick()
    if now - Glb.last_buso < 2 then return end
    Glb.last_buso = now
    local char = LP.Character; if not char then return end
    if char:FindFirstChild("HasBuso") then return end
    for _, v in ipairs(char:GetChildren()) do
        if string.find(v.Name, "_BusoLayer") then return end
    end
    pcall(function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
    end)
end

local function autoKen()
    if not getgenv().Str1kerAutoKen then return end
    if CFG.dodge.enabled and CFG.dodge.kentrick.enabled then return end
    local now = tick()
    if now - Glb.last_ken < 3 then return end
    Glb.last_ken = now
    if Lighting:FindFirstChild("Blur") and Lighting.Blur.Enabled then return end
    pcall(function()
        local vim = game:GetService("VirtualInputManager")
        vim:SendKeyEvent(true, Enum.KeyCode.J, false, game)
        task.wait(0.05)
        vim:SendKeyEvent(false, Enum.KeyCode.J, false, game)
    end)
end

local function autoV3()
    if not getgenv().Str1kerAutoV3 then return end
    local now = tick()
    if now - Glb.last_v3 < 2 then return end
    Glb.last_v3 = now
    pcall(function()
        game:GetService("ReplicatedStorage").Remotes.CommE:FireServer("ActivateAbility")
    end)
end

local function autoV4()
    if not getgenv().Str1kerAutoV4 then return end
    local char = LP.Character; if not char then return end
    local energy = char:FindFirstChild("RaceEnergy")
    local transformed = char:FindFirstChild("RaceTransformed")
    if not energy or energy.Value < 1 then return end
    if transformed and transformed.Value then return end
    local aw = LP.Backpack:FindFirstChild("Awakening") or char:FindFirstChild("Awakening")
    if aw and aw:FindFirstChild("RemoteFunction") then
        pcall(function() aw.RemoteFunction:InvokeServer(true) end)
    end
end

local function detectActiveBox()
    local ok, banner = pcall(function()
        local bc = require(game:GetService("ReplicatedStorage").Controllers.BannerClient)
        if bc and bc.TryGetBannerItemIfActiveAsync then
            local item = bc.TryGetBannerItemIfActiveAsync()
            if item and item.BoxName then return item.BoxName end
        end
    end)
    if ok and banner then return banner end
    return "DLCBoxData"
end

local function canSpinFruit()
    local CommF = game:GetService("ReplicatedStorage").Remotes.CommF_
    local boxName = detectActiveBox()
    local ok, ticketCost, freeSpins, requiredTicket = pcall(function()
        return CommF:InvokeServer("Cousin", "Check", boxName)
    end)
    if not ok then return false, boxName end
    local cost = tonumber(ticketCost) or 0
    local spins = tonumber(freeSpins) or 0
    local req = tonumber(requiredTicket) or 1
    if spins < req or cost < req then return false, boxName end
    local ok2, timeOk = pcall(function()
        return CommF:InvokeServer("Cousin", "CheckTime", boxName)
    end)
    if not ok2 or timeOk ~= true then return false, boxName end
    return true, boxName
end

local function spinRandomFruit()
    if not getgenv().Str1kerRandomFruit then return end
    local now = tick()
    if now - Glb.last_fruit_check < 5 then return end
    Glb.last_fruit_check = now
    local pg = LP:FindFirstChild("PlayerGui")
    if pg then
        local sw = pg:FindFirstChild("SpinnerWindow")
        if sw and sw.Enabled then
            local closeBtn = sw:FindFirstChild("AboveSpinner")
                and sw.AboveSpinner:FindFirstChild("Navigation")
                and sw.AboveSpinner.Navigation:FindFirstChild("CloseButton")
            if closeBtn and closeBtn.Visible then
                pcall(function()
                    for _, conn in pairs(getconnections(closeBtn.MouseButton1Click)) do
                        conn.Function()
                    end
                end)
            end
            return
        end
    end
    local canSpin, boxName = canSpinFruit()
    if not canSpin then return end
    pcall(function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Cousin", boxName)
    end)
end

local function storeAllFruits()
    if not getgenv().Str1kerAutoStore then return end
    local now = tick()
    if now - Glb.last_store_check < 3 then return end
    Glb.last_store_check = now
    local CommF = game:GetService("ReplicatedStorage").Remotes.CommF_
    local containers = { LP.Backpack, LP.Character }
    for _, container in ipairs(containers) do
        if container then
            for _, tool in ipairs(container:GetChildren()) do
                if tool:IsA("Tool") and string.find(tool.Name, "Fruit") and not tool:FindFirstChild("Str1kerStored") then
                    local originalName = tool:GetAttribute("OriginalName") or tool.Name
                    local fruitId = originalName
                    if not string.find(fruitId, "-") then
                        fruitId = fruitId:gsub(" Fruit", "") .. "-" .. fruitId:gsub(" Fruit", "")
                    else
                        fruitId = fruitId:gsub(" Fruit", "")
                    end
                    pcall(function()
                        CommF:InvokeServer("StoreFruit", fruitId, tool)
                    end)
                    local marker = Instance.new("IntValue")
                    marker.Name = "Str1kerStored"
                    marker.Parent = tool
                    task.wait(1.5)
                end
            end
        end
    end
end

task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            fastAttackOnce()
            autoBuso()
            autoKen()
            autoV3()
            autoV4()
            spinRandomFruit()
            storeAllFruits()
        end)
    end
end)

-- ══════════════════════════════════════════════════════════════════════════
-- WALK ON WATER / MOVE
-- ══════════════════════════════════════════════════════════════════════════
local waterPlatform = nil
local function ensureWaterPlatform()
    if waterPlatform and waterPlatform.Parent then return waterPlatform end
    local p = Workspace:FindFirstChild("Str1kerWaterWalk")
    if p then waterPlatform = p; return p end
    p = Instance.new("Part")
    p.Name = "Str1kerWaterWalk"
    p.Size = V3(1e6, 1, 1e6)
    p.Transparency = 1
    p.Anchored = true
    p.CanCollide = false
    p.Parent = Workspace
    waterPlatform = p
    return p
end
local function updateWalkOnWater()
    if not CFG.move.walk_on_water then
        if waterPlatform and waterPlatform.Parent then waterPlatform.CanCollide = false end
        return
    end
    local myChar = LP.Character; if not myChar then return end
    local hum = myChar:FindFirstChildOfClass("Humanoid")
    local hrp = myChar:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    local platform = ensureWaterPlatform()
    if hum.Sit then platform.CanCollide = false; return end
    if hrp.Position.Y < -60 then platform.CanCollide = false; return end
    platform.CanCollide = true
    platform.Position = V3(hrp.Position.X, -5, hrp.Position.Z)
end
local function applyMove()
    local myChar = LP.Character; if not myChar then return end
    local hum = myChar:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if CFG.move.custom_speed then hum.WalkSpeed = tonumber(CFG.move.walk_speed) or 16 end
    if CFG.move.super_jump then
        hum.JumpPower = tonumber(CFG.move.jump_power) or 50
        hum.UseJumpPower = true
    end
end

-- ══════════════════════════════════════════════════════════════════════════
-- RENDER LOOP
-- ══════════════════════════════════════════════════════════════════════════
local espEnabled = CFG.esp.enabled
local aimEnabled = CFG.aim.enabled
local frameCounter = 0
local TEXT_UPDATE_EVERY = 3

RunService.RenderStepped:Connect(function()
    if CFG.aim.smart and CFG.aim.enabled then
        pcall(aim_smart_update)
    end

    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then
        for _, s in pairs(espStore) do for _, d in pairs(s) do if d and d.Visible then d.Visible = false end end end
        return
    end
    local myPos = myHRP.Position
    frameCounter = (frameCounter + 1) % TEXT_UPDATE_EVERY
    local doText = (frameCounter == 0)

    if espEnabled then
        local maxD = CFG.esp.max_distance
        local enemyCol = CFG.esp.enemy_color
        local teamCol = CFG.esp.team_color
        for p in pairs(activePlayers) do
            local s = espStore[p] or initESP(p)
            local c = p.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            local hrp = c and c:FindFirstChild("HumanoidRootPart")
            if not c or not h or h.Health <= 0 or not hrp then
                for _, d in pairs(s) do if d and d.Visible then d.Visible = false end end
                hide_skel(p); continue
            end
            local pos = hrp.Position
            local dist = (pos - myPos).Magnitude
            if dist > maxD then
                for _, d in pairs(s) do if d and d.Visible then d.Visible = false end end
                hide_skel(p); continue
            end
            local hS, hOn = Camera:WorldToViewportPoint(pos + V3(0, 3, 0))
            local fS, fOn = Camera:WorldToViewportPoint(pos - V3(0, 2.5, 0))
            if not hOn or not fOn then
                for _, d in pairs(s) do if d and d.Visible then d.Visible = false end end
                hide_skel(p); continue
            end
            local isEnemy = true
            if p.Team and LP.Team then isEnemy = (p.Team ~= LP.Team) end
            local baseColor = isEnemy and Color3.fromRGB(enemyCol[1],enemyCol[2],enemyCol[3]) or Color3.fromRGB(teamCol[1],teamCol[2],teamCol[3])
            local height = abs(hS.Y - fS.Y)
            local width = height * 0.6
            local x = hS.X - width * 0.5
            local y = hS.Y

            if CFG.esp.box then
                s.box.Size = V2(width, height); s.box.Position = V2(x, y)
                s.box.Color = baseColor; s.box.Visible = true
                s.box_out.Size = V2(width+2, height+2); s.box_out.Position = V2(x-1, y-1); s.box_out.Visible = true
            else s.box.Visible = false; s.box_out.Visible = false end

            if CFG.esp.health_bar then
                local ratio = h.Health / h.MaxHealth
                s.hp_bg.Size = V2(3, height); s.hp_bg.Position = V2(x-8, y); s.hp_bg.Visible = true
                local col = Color3.fromRGB(0,230,100)
                if ratio < 0.3 then col = Color3.fromRGB(255,50,50)
                elseif ratio < 0.6 then col = Color3.fromRGB(255,200,0) end
                s.hp_fill.Size = V2(3, height * ratio); s.hp_fill.Position = V2(x-8, y + height*(1-ratio))
                s.hp_fill.Color = col; s.hp_fill.Visible = true
            else s.hp_bg.Visible = false; s.hp_fill.Visible = false end

            if doText then
                local use_bg = CFG.esp.text_backdrop
                if CFG.esp.name then
                    s.name.Text = p.Name; s.name.Position = V2(hS.X, y - 32)
                    s.name.Color = baseColor; s.name.Visible = true
                    if use_bg and s.name_bg then
                        local tb = s.name.TextBounds
                        s.name_bg.Size = V2(tb.X + 6, tb.Y + 2)
                        s.name_bg.Position = V2(hS.X - (tb.X/2) - 3, y - 32 - 1)
                        s.name_bg.Visible = true
                    elseif s.name_bg then s.name_bg.Visible = false end
                else s.name.Visible = false; if s.name_bg then s.name_bg.Visible = false end end
                if CFG.esp.distance then
                    s.distance.Text = floor(dist) .. "m"; s.distance.Position = V2(hS.X, y - 18); s.distance.Visible = true
                    if use_bg and s.dist_bg then
                        local tb = s.distance.TextBounds
                        s.dist_bg.Size = V2(tb.X + 6, tb.Y + 2)
                        s.dist_bg.Position = V2(hS.X - (tb.X/2) - 3, y - 18 - 1)
                        s.dist_bg.Visible = true
                    elseif s.dist_bg then s.dist_bg.Visible = false end
                else s.distance.Visible = false; if s.dist_bg then s.dist_bg.Visible = false end end
                if CFG.esp.level then
                    local dd = p:FindFirstChild("Data")
                    local lv = dd and dd:FindFirstChild("Level") and dd.Level.Value or "?"
                    s.level.Text = "Lv " .. tostring(lv); s.level.Position = V2(hS.X, y + height + 4); s.level.Visible = true
                    if use_bg and s.level_bg then
                        local tb = s.level.TextBounds
                        s.level_bg.Size = V2(tb.X + 6, tb.Y + 2)
                        s.level_bg.Position = V2(hS.X - (tb.X/2) - 3, y + height + 4 - 1)
                        s.level_bg.Visible = true
                    elseif s.level_bg then s.level_bg.Visible = false end
                else s.level.Visible = false; if s.level_bg then s.level_bg.Visible = false end end
            end

            if CFG.esp.tracer then
                s.tracer.From = V2(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y)
                s.tracer.To = V2(fS.X, fS.Y); s.tracer.Color = baseColor; s.tracer.Visible = true
            else s.tracer.Visible = false end

            if CFG.esp.icons then
                local iconY = y
                if CFG.esp.icon_pos == "Above Name" then iconY = y - 52
                elseif CFG.esp.icon_pos == "Below Name" then iconY = y + height + 20
                elseif CFG.esp.icon_pos == "Left of Name" then iconY = y - 32
                elseif CFG.esp.icon_pos == "Right of Name" then iconY = y - 32 end
                local iconX = hS.X
                if CFG.esp.icon_pos == "Left of Name" then iconX = hS.X - width - 20
                elseif CFG.esp.icon_pos == "Right of Name" then iconX = hS.X + width + 20 end
                local size = CFG.esp.icon_size
                if CFG.esp.icon_bg and s.icon_bg then
                    s.icon_bg.Size = V2(size+4, size+4)
                    s.icon_bg.Position = V2(iconX-(size/2)-2, iconY-(size/2)-2)
                    s.icon_bg.Visible = true
                elseif s.icon_bg then s.icon_bg.Visible = false end
                if CFG.esp.icon_head and s.icon_head then
                    local url = getHeadshot(p.UserId)
                    if url then
                        s.icon_head.Size = V2(size, size)
                        s.icon_head.Position = V2(iconX-(size/2), iconY-(size/2))
                        s.icon_head.Image = url; s.icon_head.Visible = true
                    else s.icon_head.Visible = false end
                elseif s.icon_head then s.icon_head.Visible = false end
                if CFG.esp.icon_weapon and s.icon_wpn then
                    local tool = c:FindFirstChildOfClass("Tool")
                    if tool then
                        s.icon_wpn.Size = V2(size, size)
                        s.icon_wpn.Position = V2(iconX-(size/2) + size + CFG.esp.icon_spacing, iconY-(size/2))
                        s.icon_wpn.Image = getToolIcon(tool.Name); s.icon_wpn.Visible = true
                    else s.icon_wpn.Visible = false end
                elseif s.icon_wpn then s.icon_wpn.Visible = false end
            else
                if s.icon_bg then s.icon_bg.Visible = false end
                if s.icon_head then s.icon_head.Visible = false end
                if s.icon_wpn then s.icon_wpn.Visible = false end
            end

            if CFG.esp.skeleton then draw_skel(p, baseColor, 1) else hide_skel(p) end
        end
    else
        for _, s in pairs(espStore) do for _, d in pairs(s) do if d and d.Visible then d.Visible = false end end end
        for p in pairs(activePlayers) do hide_skel(p) end
    end

    if aimEnabled then
        if aimTarget and (tick() - aimLockAt) < LOCK_DURATION then
            if not isValid(aimTarget) then aimTarget = nil end
        else
            aimTarget = pickTarget()
            if aimTarget then aimLockAt = tick() end
        end
        if aimTarget and (CFG.aim.mode == "Camera" or CFG.aim.mode == "Both") then
            if not Spectate.active then
                local c = aimTarget.Character
                local part = c and getPart(c)
                if part then
                    local ping = getPing() + CFG.aim.resolver
                    local pp = aim_smart_predict(part, aimTarget, ping, 1)
                    Camera.CFrame = Camera.CFrame:Lerp(CF(pp), 1 - CFG.aim.smoothing)
                end
            end
        end
    end

    updateWalkOnWater()
    applyMove()
end)

-- ══════════════════════════════════════════════════════════════════════════
-- KEYBINDS
-- ══════════════════════════════════════════════════════════════════════════
local kbEsp = Enum.KeyCode.F1
local kbAim = Enum.KeyCode[CFG.aim.keybind] or Enum.KeyCode.E
local kbSpectateCycle = Enum.KeyCode.F2
local kbSpectateStop = Enum.KeyCode.F3

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == kbEsp then
        espEnabled = not espEnabled; CFG.esp.enabled = espEnabled; saveCfg()
    elseif input.KeyCode == kbAim then
        aimEnabled = not aimEnabled; CFG.aim.enabled = aimEnabled; saveCfg()
    elseif input.KeyCode == kbSpectateCycle then
        if CFG.esp.spectate then spectate_cycle() end
    elseif input.KeyCode == kbSpectateStop then
        if Spectate.active then
            CFG.esp.spectate = false
            spectate_stop()
            saveCfg()
        end
    end
end)

-- ══════════════════════════════════════════════════════════════════════════
-- EXPORT LEARN TABLE
-- ══════════════════════════════════════════════════════════════════════════
local function exportLearnTable()
    local lines = {}
    table.insert(lines, "-- STR1KER LEARNED TABLE — " .. os.date("%Y-%m-%d %H:%M:%S"))
    table.insert(lines, "-- remote | categoria | estagios | timing_ms | distancia | cue_visual | nota")
    local sorted = {}
    for remote, stats in pairs(Learn.data) do
        table.insert(sorted, { remote = remote, stats = stats })
    end
    table.sort(sorted, function(a, b) return a.remote < b.remote end)
    for _, row in ipairs(sorted) do
        local s = row.stats
        local cat = s.category_hint or "unknown"
        local timing = s.avg_latency and string.format("%.0f", s.avg_latency) or "?"
        local dist = s.distance_avg and string.format("%.0f", s.distance_avg) or "?"
        local cue = "-"
        for name, _ in pairs(s.known_cues or {}) do cue = name; break end
        local nota = string.format("hits=%d dodges=%d conf=%d", s.hits or 0, s.dodges or 0, #(s.latency_samples or {}))
        table.insert(lines, string.format("%s | %s | - | %s | %s | %s | %s", row.remote, cat, timing, dist, cue, nota))
    end
    return table.concat(lines, "\n")
end

-- ══════════════════════════════════════════════════════════════════════════
-- API
-- ══════════════════════════════════════════════════════════════════════════
getgenv().Str1kerAPI = {
    setESP = function(v) espEnabled = v; CFG.esp.enabled = v; saveCfg() end,
    setAim = function(v) aimEnabled = v; CFG.aim.enabled = v; saveCfg() end,
    setResolver = function(v) CFG.aim.resolver = v; saveCfg() end,
    setFov = function(v) CFG.aim.fov = v; saveCfg() end,
    setSmoothing = function(v) CFG.aim.smoothing = v; saveCfg() end,
    setAimPart = function(v) CFG.aim.aim_part = v; saveCfg() end,
    setMode = function(v) CFG.aim.mode = v; saveCfg() end,
    setMaxDist = function(v) CFG.esp.max_distance = v; saveCfg() end,
    setSkeleton = function(v) CFG.esp.skeleton = v; saveCfg() end,
    setDodge = function(v) CFG.dodge.enabled = v; saveCfg() end,
    setLearning = function(v) CFG.dodge.learning = v; saveCfg() end,
    setDodgeLog = function(v) CFG.dodge.log_triggers = v; saveCfg() end,
    setWalkOnWater = function(v) CFG.move.walk_on_water = v; saveCfg() end,
    setSuperJump = function(v) CFG.move.super_jump = v; saveCfg() end,
    setJumpPower = function(v) CFG.move.jump_power = v; saveCfg() end,
    setCustomSpeed = function(v) CFG.move.custom_speed = v; saveCfg() end,
    setWalkSpeed = function(v) CFG.move.walk_speed = v; saveCfg() end,
    setMacroEnabled = function(v) CFG.dodge.macro.enabled = v; saveCfg() end,
    setKenTrick = function(v) CFG.dodge.kentrick.enabled = v; saveCfg() end,
    setSkipChance = function(v) CFG.dodge.macro.skip_chance = v; saveCfg() end,
    setActionsPerMinute = function(v) CFG.dodge.macro.actions_per_minute = v; saveCfg() end,
    setReactionRange = function(mn, mx) CFG.dodge.macro.reaction_min_ms = mn; CFG.dodge.macro.reaction_max_ms = mx; saveCfg() end,
    setAimSmart = function(v) CFG.aim.smart = v; saveCfg() end,
    setAimSmartSamples = function(v) CFG.aim.smart_samples = v; saveCfg() end,
    setAimSmartStrafeLead = function(v) CFG.aim.smart_strafe_lead = v; saveCfg() end,
    setAimSmartAccelWeight = function(v) CFG.aim.smart_accel_weight = v; saveCfg() end,
    setSpectate = function(v)
        CFG.esp.spectate = v
        if not v then spectate_stop() end
        saveCfg()
    end,
    setSpectateMode = function(m)
        CFG.esp.spectate_mode = m
        if CFG.esp.spectate then
            local new_tgt = spectate_pick()
            if new_tgt then spectate_start(new_tgt) end
        end
        saveCfg()
    end,
    setSpectateManual = function(name)
        CFG.esp.spectate_manual = name
        if CFG.esp.spectate and CFG.esp.spectate_mode == "Manual" then
            local p = Players:FindFirstChild(name)
            if p then spectate_start(p) end
        end
        saveCfg()
    end,
    setSpectateShowButton = function(v)
        CFG.esp.spectate_show_button = v; saveCfg()
    end,
    setSpectateShowMini = function(v)
        CFG.esp.spectate_show_mini = v; saveCfg()
    end,
    setSpectateMiniFov = function(v)
        CFG.esp.spectate_mini_fov = v
        if SpectateUI.virtual_cam then SpectateUI.virtual_cam.FieldOfView = v end
        saveCfg()
    end,
    spectateCycle = function() spectate_cycle() end,
    spectateStop = function() CFG.esp.spectate = false; spectate_stop(); saveCfg() end,
    spectateCurrent = function() return Spectate.target and Spectate.target.Name or nil end,
    -- UI da Spectate
    spectateUIOpenMain = function()
        SpectateUI.btn_main.MouseButton1Click:Fire()
    end,
    spectateUIOpenMini = function()
        SpectateUI.btn_mini.MouseButton1Click:Fire()
    end,
    spectateUIStatus = function()
        return {
            main = SpectateUI.main_active,
            mini = SpectateUI.mini_active,
            target = Spectate.target and Spectate.target.Name or nil,
        }
    end,
    -- infra
    macroStatus = function()
        return {
            fatigue_until = Macro.fatigue_until,
            actions_this_minute = Macro.actions_this_minute,
            consecutive = Macro.consecutive_dodges,
            ken_trick_on = KenTrick.is_on,
            toggle_count = KenTrick.toggle_count,
        }
    end,
    macroForceOff = function() kentrick_force_off() end,
    learnStats = function() return Learn.data end,
    learnExport = function()
        local text = exportLearnTable()
        if setclipboard then setclipboard(text) end
        return text
    end,
    learnSave = function() saveLearn(); return true end,
    learnWipe = function() Learn.data = {}; saveLearn(); return true end,
    getCfg = function() return CFG end,
    saveCfg = saveCfg,
    log = logEvent,
    dodgeStatus = function() return Dodge.status end,
}

task.spawn(function()
    while task.wait(60) do
        if CFG.dodge.learning then saveLearn() end
    end
end)

logEvent("session_start", { place = game.PlaceId })
