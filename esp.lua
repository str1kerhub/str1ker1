-- language: Luau, file: esp.lua, target: Delta / Krnl / Codex
-- Str1ker ESP v2 — Drawing API + ScreenGui para headshot

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local Workspace   = game:GetService("Workspace")
local Camera      = Workspace.CurrentCamera
local LP          = Players.LocalPlayer

local ESP = {}
ESP.Enabled = false
ESP.Config = {
    Box          = true,
    Name         = true,
    Distance     = true,
    HealthBar    = true,
    Tracer       = true,
    TracerColor  = Color3.fromRGB(59, 130, 246),
    BoxColor     = Color3.fromRGB(59, 130, 246),
    BoxStyle     = "Corners",
    ShowPhoto    = false,
    PhotoSize    = 48,
    MaxDistance  = 2000,
    TeamCheck    = true,
}

-- ── Drawing API ──────────────────────────────────────────────
local DRAW = Drawing or (syn and syn.drawing) or (Krnl and Krnl.Drawing)
if not DRAW then return warn("[ESP] executor sem Drawing API") end

local function new_square() return DRAW.new("Square") end
local function new_line() return DRAW.new("Line") end
local function new_text() return DRAW.new("Text") end
local function new_circle() return DRAW.new("Circle") end

-- ── ScreenGui pra headshot ───────────────────────────────────
local gui = Instance.new("ScreenGui")
gui.Name = "Str1kerESP"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() gui.Parent = gethui() end)
if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

-- ── cache por player ─────────────────────────────────────────
local cache = {}
local thumb_cache = {}

local function create_cache()
    local c = {
        box      = new_square(),
        box_bg   = new_square(),
        name     = new_text(),
        distance = new_text(),
        hp_bg    = new_square(),
        hp_fill  = new_square(),
        tracer   = new_line(),
        head_dot = new_circle(),
        photo    = nil,
    }
    c.box.Thickness   = 1.5
    c.box.Color       = ESP.Config.BoxColor
    c.box.Filled      = false
    c.box.Visible     = false

    c.box_bg.Filled   = true
    c.box_bg.Transparency = 0.85
    c.box_bg.Color    = ESP.Config.BoxColor
    c.box_bg.Visible  = false

    c.name.Size       = 14
    c.name.Center     = true
    c.name.Outline    = true
    c.name.Color      = Color3.fromRGB(240, 244, 252)
    c.name.OutlineColor = Color3.fromRGB(0, 0, 0)
    c.name.Font       = 2
    c.name.Visible    = false

    c.distance.Size   = 12
    c.distance.Center = true
    c.distance.Outline = true
    c.distance.Color  = Color3.fromRGB(165, 200, 255)
    c.distance.OutlineColor = Color3.fromRGB(0, 0, 0)
    c.distance.Font   = 2
    c.distance.Visible = false

    c.hp_bg.Filled    = true
    c.hp_bg.Color     = Color3.fromRGB(0, 0, 0)
    c.hp_bg.Transparency = 0.4
    c.hp_bg.Visible   = false

    c.hp_fill.Filled  = true
    c.hp_fill.Color   = Color3.fromRGB(70, 220, 110)
    c.hp_fill.Visible = false

    c.tracer.Thickness = 1.5
    c.tracer.Color     = ESP.Config.TracerColor
    c.tracer.Transparency = 0.15
    c.tracer.Visible   = false

    c.head_dot.Thickness = 1
    c.head_dot.Filled  = true
    c.head_dot.Color   = Color3.fromRGB(255, 80, 80)
    c.head_dot.NumSides = 30
    c.head_dot.Radius  = 4
    c.head_dot.Visible = false

    return c
end

local function destroy_cache(c)
    for _, v in pairs(c) do
        if typeof(v) == "Instance" then v:Destroy()
        elseif typeof(v) == "userdata" then pcall(function() v:Remove() end) end
    end
end

-- ── thumbnail ────────────────────────────────────────────────
local function get_thumb(userId)
    if thumb_cache[userId] then return thumb_cache[userId] end
    local ok, url = pcall(function()
        return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    end)
    if ok and url then
        thumb_cache[userId] = url
        return url
    end
    return nil
end

-- ── world → screen ───────────────────────────────────────────
local function world_to_screen(pos)
    local sp, on = Camera:WorldToViewportPoint(pos)
    if not on or sp.Z < 0 then return nil end
    return Vector2.new(sp.X, sp.Y)
end

-- ── pega bbox ────────────────────────────────────────────────
local function get_bbox(plr)
    local char = plr.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not head or not hum then return nil end
    if hum.Health <= 0 then return nil end
    return char, hrp, head, hum
end

-- ── render ───────────────────────────────────────────────────
local function render_player(plr, c)
    local char, hrp, head, hum = get_bbox(plr)
    if not char then return false end

    local my_char = LP.Character
    local my_hrp = my_char and my_char:FindFirstChild("HumanoidRootPart")
    local dist = my_hrp and (hrp.Position - my_hrp.Position).Magnitude or 0
    if dist > ESP.Config.MaxDistance then return false end

    if ESP.Config.TeamCheck and plr.Team and LP.Team and plr.Team == LP.Team then
        return false
    end

    local top = world_to_screen(head.Position + Vector3.new(0, 1.2, 0))
    local bot = world_to_screen(hrp.Position - Vector3.new(0, 2.8, 0))
    if not top or not bot then return false end

    local w = math.abs(top.X - bot.X)
    local h = math.abs(top.Y - bot.Y)
    w = math.max(w, h * 0.55)

    local left = top.X - w / 2
    local right = top.X + w / 2
    local cx = top.X

    -- BOX
    if ESP.Config.Box then
        c.box.Visible = true
        c.box.Color = ESP.Config.BoxColor
        if ESP.Config.BoxStyle == "Filled" then
            c.box.Filled = true
            c.box.Transparency = 0.75
            c.box_bg.Visible = false
        else
            c.box.Filled = false
            c.box.Transparency = 1
            c.box_bg.Visible = false
        end
        c.box.From = Vector2.new(left, top.Y)
        c.box.To   = Vector2.new(right, bot.Y)
    else
        c.box.Visible = false
        c.box_bg.Visible = false
    end

    -- NAME
    if ESP.Config.Name then
        c.name.Visible = true
        c.name.Position = Vector2.new(cx, top.Y - 14)
        c.name.Text = plr.Name
    else
        c.name.Visible = false
    end

    -- DISTANCE
    if ESP.Config.Distance then
        c.distance.Visible = true
        c.distance.Position = Vector2.new(cx, bot.Y + 4)
        c.distance.Text = string.format("[%d m]", math.floor(dist / 3.5))
    else
        c.distance.Visible = false
    end

    -- HEALTH
    if ESP.Config.HealthBar then
        local hp_pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        c.hp_bg.Visible = true
        c.hp_fill.Visible = true
        c.hp_bg.From = Vector2.new(left - 6, top.Y)
        c.hp_bg.To   = Vector2.new(left - 2, bot.Y)
        c.hp_fill.From = Vector2.new(left - 6, bot.Y - (bot.Y - top.Y) * hp_pct)
        c.hp_fill.To   = Vector2.new(left - 2, bot.Y)
        c.hp_fill.Color = Color3.fromRGB(
            math.floor(255 * (1 - hp_pct)),
            math.floor(220 * hp_pct),
            60
        )
    else
        c.hp_bg.Visible = false
        c.hp_fill.Visible = false
    end

    -- TRACER
    if ESP.Config.Tracer then
        c.tracer.Visible = true
        c.tracer.Color = ESP.Config.TracerColor
        local vp = Camera.ViewportSize
        c.tracer.From = Vector2.new(vp.X / 2, vp.Y)
        c.tracer.To   = Vector2.new(cx, bot.Y)
    else
        c.tracer.Visible = false
    end

    -- HEAD DOT (quando sem foto)
    if not ESP.Config.ShowPhoto then
        local hp = world_to_screen(head.Position)
        if hp then
            c.head_dot.Visible = true
            c.head_dot.Position = hp
        else
            c.head_dot.Visible = false
        end
    else
        c.head_dot.Visible = false
    end

    -- PHOTO
    if ESP.Config.ShowPhoto then
        if not c.photo then
            c.photo = Instance.new("ImageLabel")
            c.photo.BackgroundTransparency = 1
            c.photo.ZIndex = 5
            c.photo.Parent = gui
        end
        local url = get_thumb(plr.UserId)
        if url and c.photo.Image ~= url then
            c.photo.Image = url
        end
        c.photo.Size = UDim2.fromOffset(ESP.Config.PhotoSize, ESP.Config.PhotoSize)
        c.photo.Position = UDim2.fromOffset(
            math.floor(top.X - ESP.Config.PhotoSize / 2),
            math.floor(top.Y - ESP.Config.PhotoSize - 22)
        )
        c.photo.Visible = true
    elseif c.photo then
        c.photo.Visible = false
    end

    return true
end

local function hide_cache(c)
    c.box.Visible = false
    c.box_bg.Visible = false
    c.name.Visible = false
    c.distance.Visible = false
    c.hp_bg.Visible = false
    c.hp_fill.Visible = false
    c.tracer.Visible = false
    c.head_dot.Visible = false
    if c.photo then c.photo.Visible = false end
end

-- ── loop ─────────────────────────────────────────────────────
RunService.RenderStepped:Connect(function()
    if not ESP.Enabled then
        for _, c in pairs(cache) do hide_cache(c) end
        return
    end

    local valid = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local c = cache[plr]
            if not c then
                c = create_cache()
                cache[plr] = c
            end
            local shown = render_player(plr, c)
            if not shown then hide_cache(c) end
            valid[plr] = true
        end
    end

    for plr, c in pairs(cache) do
        if not valid[plr] then
            destroy_cache(c)
            cache[plr] = nil
        end
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if cache[plr] then
        destroy_cache(cache[plr])
        cache[plr] = nil
    end
end)

function ESP.set(key, val) ESP.Config[key] = val end
function ESP.toggle(v)
    ESP.Enabled = (v == nil) and not ESP.Enabled or v
end

_G.Str1kerESP = ESP
return ESP