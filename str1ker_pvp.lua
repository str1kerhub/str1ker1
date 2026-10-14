--!nocheck
-- ==========================================================================
-- STR1KER PVP v3.1 — corrigido
-- Sem acesso direto a Modules.Net · Hook genérico · ESP + Aim + Resolver
-- ==========================================================================

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local Workspace   = game:GetService("Workspace")
local UIS         = game:GetService("UserInputService")
local Stats       = game:GetService("Stats")
local Http        = game:GetService("HttpService")
local Camera      = Workspace.CurrentCamera
local LP          = Players.LocalPlayer

local V2 = Vector2.new
local V3 = Vector3.new
local CF = CFrame.new
local floor, abs = math.floor, math.abs

local httpReq = (syn and syn.request) or (http and http.request) or http_request or request
local isfile_ok, readfile_ok, writefile_ok = isfile, readfile, writefile

-- ==========================================================================
-- BACKEND
-- ==========================================================================

local BACKEND = "https://str1ker-backend.up.railway.app"

local function fetchStatus()
    if not httpReq then return true end
    local ok, res = pcall(httpReq, { Url = BACKEND .. "/status", Method = "GET" })
    if not ok or not res or res.StatusCode ~= 200 then return true end
    local d; pcall(function() d = Http:JSONDecode(res.Body) end)
    return not (d and d.enabled == false)
end

local function logEvent(evt, data)
    if not httpReq then return end
    task.spawn(function()
        pcall(httpReq, {
            Url = BACKEND .. "/log",
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = Http:JSONEncode({ event = evt, data = data, user = LP.Name, t = os.time() }),
        })
    end)
end

if not fetchStatus() then
    warn("[Str1ker] desabilitado pelo servidor")
    return
end

-- ==========================================================================
-- CONFIG
-- ==========================================================================

local CFG_PATH = "str1ker_cfg.json"

local DEFAULT_CFG = {
    esp = {
        enabled = true, box = true, health_bar = true, name = true,
        distance = true, level = true, tracer = true, skeleton = false,
        max_distance = 1500, thickness = 1.5,
        enemy_color = {255, 60, 60}, team_color = {60, 255, 120},
    },
    aim = {
        enabled = true, mode = "Silent",
        keybind = "E",
        aim_part = "Head",
        fov = 120, max_distance = 600,
        smoothing = 0.35,
        prediction = true, prediction_scale = 1.0,
        resolver = 0.05,
        team_check = true, visibility_check = true,
    },
}

local function deepCopy(t)
    local out = {}
    for k, v in pairs(t) do
        out[k] = type(v) == "table" and deepCopy(v) or v
    end
    return out
end

local function loadCfg()
    if not isfile_ok or not readfile_ok then return deepCopy(DEFAULT_CFG) end
    if not isfile(CFG_PATH) then return deepCopy(DEFAULT_CFG) end
    local ok, txt = pcall(readfile, CFG_PATH)
    if not ok or not txt then return deepCopy(DEFAULT_CFG) end
    local ok2, data = pcall(Http.JSONDecode, Http, txt)
    if not ok2 or type(data) ~= "table" then return deepCopy(DEFAULT_CFG) end
    local merged = deepCopy(DEFAULT_CFG)
    for section, values in pairs(data) do
        if type(values) == "table" and merged[section] then
            for k, v in pairs(values) do merged[section][k] = v end
        end
    end
    return merged
end

local function saveCfg()
    if not writefile_ok then return end
    task.spawn(function()
        pcall(writefile, CFG_PATH, Http:JSONEncode(CFG))
    end)
end

local CFG = loadCfg()
getgenv().STR1KER_CFG = CFG

-- ==========================================================================
-- DRAWING
-- ==========================================================================

local DrawNew = (Drawing and Drawing.new)
    or (syn and syn.drawing and syn.drawing.new)
    or (Krnl and Krnl.Drawing and Krnl.Drawing.new)
if not DrawNew then warn("[Str1ker] sem Drawing") return end

local drawingPool = {}
local function D(class)
    local d = drawingPool[class]
    if d then
        drawingPool[class] = nil
        d.Visible = false
        return d
    end
    local ok, obj = pcall(DrawNew, class)
    if not ok then return nil end
    obj.Visible = false
    obj.Transparency = 1
    return obj
end

-- ==========================================================================
-- PING / PREDIÇÃO
-- ==========================================================================

local cachedPing, lastPingAt = 60, 0
local function getPing()
    if tick() - lastPingAt > 0.5 then
        local ok, v = pcall(function()
            return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        end)
        cachedPing = ok and v or 60
        lastPingAt = tick()
    end
    return cachedPing / 1000
end

local function predict(part)
    if not CFG.aim.prediction then return part.Position end
    local v = part.AssemblyLinearVelocity
    if v.Magnitude < 0.5 then return part.Position end
    return part.Position + v * (getPing() + CFG.aim.resolver) * CFG.aim.prediction_scale
end

-- ==========================================================================
-- PLAYER CACHE
-- ==========================================================================

local activePlayers = {}
local espStore = {}

local function trackPlayer(p)
    if p == LP then return end
    activePlayers[p] = true
end

for _, p in ipairs(Players:GetPlayers()) do trackPlayer(p) end
Players.PlayerAdded:Connect(trackPlayer)
Players.PlayerRemoving:Connect(function(p)
    activePlayers[p] = nil
    local s = espStore[p]
    if s then
        for _, d in pairs(s) do
            if d then d.Visible = false end
        end
        espStore[p] = nil
    end
end)

-- ==========================================================================
-- ESP INIT
-- ==========================================================================

local function initESP(p)
    local s = espStore[p]
    if s then return s end
    s = {
        box      = D("Square"),
        box_out  = D("Square"),
        hp_bg    = D("Square"),
        hp_fill  = D("Square"),
        name     = D("Text"),
        distance = D("Text"),
        level    = D("Text"),
        tracer   = D("Line"),
    }
    if s.box then
        s.box.Filled = false
        s.box.Thickness = CFG.esp.thickness
        s.box_out.Filled = false
        s.box_out.Thickness = CFG.esp.thickness + 1
        s.box_out.Color = Color3.fromRGB(0, 0, 0)
    end
    if s.hp_bg then
        s.hp_bg.Filled = true
        s.hp_bg.Color = Color3.fromRGB(0, 0, 0)
        s.hp_bg.Transparency = 0.4
        s.hp_fill.Filled = true
    end
    if s.name then
        s.name.Size = 14; s.name.Center = true; s.name.Outline = true
        s.name.OutlineColor = Color3.fromRGB(0, 0, 0); s.name.Font = 2
    end
    if s.distance then
        s.distance.Size = 12; s.distance.Center = true; s.distance.Outline = true
        s.distance.OutlineColor = Color3.fromRGB(0, 0, 0); s.distance.Font = 2
        s.distance.Color = Color3.fromRGB(180, 190, 210)
    end
    if s.level then
        s.level.Size = 11; s.level.Center = true; s.level.Outline = true
        s.level.OutlineColor = Color3.fromRGB(0, 0, 0); s.level.Font = 2
        s.level.Color = Color3.fromRGB(200, 200, 255)
    end
    if s.tracer then
        s.tracer.Thickness = 1
    end
    espStore[p] = s
    return s
end

-- ==========================================================================
-- AIM STATE
-- ==========================================================================

local aimTarget, aimLockAt = nil, 0
local LOCK_DURATION = 0.25

local function isValid(p)
    if p == LP then return false end
    local c = p.Character
    if not c then return false end
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
    local camPos = Camera.CFrame.Position
    local mouse = UIS:GetMouseLocation()
    local fov = CFG.aim.fov
    local fovSq = fov * fov
    local maxD = CFG.aim.max_distance

    local best, bestScore = nil, math.huge

    for p in pairs(activePlayers) do
        if isValid(p) then
            local c = p.Character
            local part = c and getPart(c)
            if part then
                local pos = part.Position
                local d = (pos - myPos).Magnitude
                if d <= maxD then
                    local dir = (pos - camPos).Unit
                    if dir:Dot(Camera.CFrame.LookVector) > 0 then
                        local sp, on = Camera:WorldToViewportPoint(pos)
                        if on then
                            local dx, dy = sp.X - mouse.X, sp.Y - mouse.Y
                            local sd = dx * dx + dy * dy
                            if sd <= fovSq then
                                if CFG.aim.visibility_check then
                                    local ray = Ray.new(camPos, pos - camPos)
                                    local ignore = {myChar, c, Camera}
                                    local hit = Workspace:FindPartOnRayWithIgnoreList(ray, ignore)
                                    if not hit or hit:IsDescendantOf(c) then
                                        local score = sd + d * 0.1
                                        if score < bestScore then
                                            best, bestScore = p, score
                                        end
                                    end
                                else
                                    local score = sd + d * 0.1
                                    if score < bestScore then
                                        best, bestScore = p, score
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

-- ==========================================================================
-- SILENT AIM (hook genérico)
-- ==========================================================================

if getrawmetatable and setreadonly and newcclosure then
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if CFG.aim.enabled and aimTarget
           and (CFG.aim.mode == "Silent" or CFG.aim.mode == "Both")
           and method == "FireServer" then
            local c = aimTarget.Character
            local part = c and getPart(c)
            if part then
                local pp = predict(part)
                local args = {...}
                local changed = false
                for i = 1, #args do
                    local t = typeof(args[i])
                    if t == "Vector3" then
                        args[i] = pp; changed = true
                    elseif t == "CFrame" then
                        args[i] = CF(pp); changed = true
                    end
                end
                if changed then
                    return oldNamecall(self, unpack(args))
                end
            end
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end

-- ==========================================================================
-- RENDER LOOP
-- ==========================================================================

local espEnabled = CFG.esp.enabled
local aimEnabled = CFG.aim.enabled

local frameCounter = 0
local TEXT_UPDATE_EVERY = 3

RunService.RenderStepped:Connect(function()
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then
        for _, s in pairs(espStore) do
            for _, d in pairs(s) do if d and d.Visible then d.Visible = false end end
        end
        return
    end
    local myPos = myHRP.Position

    frameCounter = (frameCounter + 1) % TEXT_UPDATE_EVERY
    local doText = (frameCounter == 0)

    if espEnabled then
        local enemyCol = CFG.esp.enemy_color
        local teamCol  = CFG.esp.team_color
        local maxD     = CFG.esp.max_distance

        for p in pairs(activePlayers) do
            local s = espStore[p]
            if not s then s = initESP(p) end
            local c = p.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            local hrp = c and c:FindFirstChild("HumanoidRootPart")

            if not c or not h or not hrp or h.Health <= 0 then
                for _, d in pairs(s) do if d and d.Visible then d.Visible = false end end
                continue
            end

            local pos = hrp.Position
            local dist = (pos - myPos).Magnitude
            if dist > maxD then
                for _, d in pairs(s) do if d and d.Visible then d.Visible = false end end
                continue
            end

            local headPos = pos + V3(0, 3, 0)
            local feetPos = pos - V3(0, 2.5, 0)

            local hS, hOn = Camera:WorldToViewportPoint(headPos)
            local fS, fOn = Camera:WorldToViewportPoint(feetPos)

            if not hOn or not fOn then
                for _, d in pairs(s) do if d and d.Visible then d.Visible = false end end
                continue
            end

            local isEnemy = true
            if p.Team and LP.Team then isEnemy = (p.Team ~= LP.Team) end
            local baseColor = isEnemy
                and Color3.fromRGB(enemyCol[1], enemyCol[2], enemyCol[3])
                or  Color3.fromRGB(teamCol[1], teamCol[2], teamCol[3])

            local height = abs(hS.Y - fS.Y)
            local width  = height * 0.6
            local x = hS.X - width * 0.5
            local y = hS.Y

            if CFG.esp.box then
                s.box.Size = V2(width, height)
                s.box.Position = V2(x, y)
                s.box.Color = baseColor
                s.box.Visible = true

                s.box_out.Size = V2(width + 2, height + 2)
                s.box_out.Position = V2(x - 1, y - 1)
                s.box_out.Visible = true
            else
                s.box.Visible = false
                s.box_out.Visible = false
            end

            if CFG.esp.health_bar then
                local ratio = h.Health / h.MaxHealth
                s.hp_bg.Size = V2(3, height)
                s.hp_bg.Position = V2(x - 8, y)
                s.hp_bg.Visible = true

                local col = Color3.fromRGB(0, 230, 100)
                if ratio < 0.3 then col = Color3.fromRGB(255, 50, 50)
                elseif ratio < 0.6 then col = Color3.fromRGB(255, 200, 0) end

                s.hp_fill.Size = V2(3, height * ratio)
                s.hp_fill.Position = V2(x - 8, y + height * (1 - ratio))
                s.hp_fill.Color = col
                s.hp_fill.Visible = true
            else
                s.hp_bg.Visible = false
                s.hp_fill.Visible = false
            end

            if doText then
                if CFG.esp.name then
                    s.name.Text = p.Name
                    s.name.Position = V2(hS.X, y - 32)
                    s.name.Color = baseColor
                    s.name.Visible = true
                else s.name.Visible = false end

                if CFG.esp.distance then
                    s.distance.Text = floor(dist) .. "m"
                    s.distance.Position = V2(hS.X, y - 18)
                    s.distance.Visible = true
                else s.distance.Visible = false end

                if CFG.esp.level then
                    local dd = p:FindFirstChild("Data")
                    local lv = dd and dd:FindFirstChild("Level") and dd.Level.Value or "?"
                    s.level.Text = "Lv " .. tostring(lv)
                    s.level.Position = V2(hS.X, y + height + 4)
                    s.level.Visible = true
                else s.level.Visible = false end
            end

            if CFG.esp.tracer then
                s.tracer.From = V2(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y)
                s.tracer.To = V2(fS.X, fS.Y)
                s.tracer.Color = baseColor
                s.tracer.Visible = true
            else
                s.tracer.Visible = false
            end
        end
    else
        for _, s in pairs(espStore) do
            for _, d in pairs(s) do if d and d.Visible then d.Visible = false end end
        end
    end

    if aimEnabled then
        if aimTarget and (tick() - aimLockAt) < LOCK_DURATION then
            if not isValid(aimTarget) then aimTarget = nil end
        else
            aimTarget = pickTarget()
            if aimTarget then aimLockAt = tick() end
        end

        if aimTarget and (CFG.aim.mode == "Camera" or CFG.aim.mode == "Both") then
            local c = aimTarget.Character
            local part = c and getPart(c)
            if part then
                local target = CF(predict(part))
                Camera.CFrame = Camera.CFrame:Lerp(target, 1 - CFG.aim.smoothing)
            end
        end
    end
end)

-- ==========================================================================
-- KEYBINDS
-- ==========================================================================

local kbEsp = Enum.KeyCode.F1
local kbAim = Enum.KeyCode[CFG.aim.keybind] or Enum.KeyCode.E

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == kbEsp then
        espEnabled = not espEnabled
        CFG.esp.enabled = espEnabled
        saveCfg()
    elseif input.KeyCode == kbAim then
        aimEnabled = not aimEnabled
        CFG.aim.enabled = aimEnabled
        saveCfg()
    end
end)

-- ==========================================================================
-- API PARA O MENU
-- ==========================================================================

getgenv().Str1kerAPI = {
    setESP       = function(v) espEnabled = v; CFG.esp.enabled = v; saveCfg() end,
    setAim       = function(v) aimEnabled = v; CFG.aim.enabled = v; saveCfg() end,
    setResolver  = function(v) CFG.aim.resolver = v; saveCfg() end,
    setFov       = function(v) CFG.aim.fov = v; saveCfg() end,
    setSmoothing = function(v) CFG.aim.smoothing = v; saveCfg() end,
    setAimPart   = function(v) CFG.aim.aim_part = v; saveCfg() end,
    setMode      = function(v) CFG.aim.mode = v; saveCfg() end,
    setMaxDist   = function(v) CFG.esp.max_distance = v; saveCfg() end,
    getCfg       = function() return CFG end,
    saveCfg      = saveCfg,
    log          = logEvent,
}

logEvent("session_start", { place = game.PlaceId, executor = (identifyexecutor and identifyexecutor()) or "unknown" })
