-- language: Luau, file: esp.lua, target: Delta / Krnl / Codex
-- Str1ker ESP v3 — Drawing API + headshot com moldura circular

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local Workspace   = game:GetService("Workspace")
local Camera      = Workspace.CurrentCamera
local LP          = Players.LocalPlayer

local ESP = {}
ESP.Enabled = false
ESP.Config = {
    Box          = true,
    BoxStyle     = "Corners",
    BoxColor     = Color3.fromRGB(59, 130, 246),
    BoxThickness = 1.6,
    Name         = true,
    ShowDisplayName = true,       -- true = DisplayName, false = @username
    Distance     = true,
    HealthBar    = true,
    ShowHPText   = true,
    Tracer       = true,
    TracerColor  = Color3.fromRGB(59, 130, 246),
    TracerThickness = 2.5,
    TracerGlow   = true,
    ShowPhoto    = false,
    PhotoSize    = 52,
    PhotoRing    = true,          -- moldura ao redor da foto
    PhotoRingColor = Color3.fromRGB(70, 220, 110),  -- verde por padrão
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

-- ── cache ────────────────────────────────────────────────────
local cache = {}
local thumb_cache = {}

local function make_photo_container()
    local wrap = Instance.new("Frame")
    wrap.BackgroundTransparency = 1
    wrap.ZIndex = 5
    wrap.Visible = false
    wrap.Parent = gui

    -- container da foto com moldura
    local box = Instance.new("Frame")
    box.Name = "PhotoBox"
    box.Size = UDim2.fromScale(1, 1)
    box.BackgroundColor3 = Color3.fromRGB(8, 14, 28)
    box.BorderSizePixel = 0
    box.Parent = wrap

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = box

    local stroke = Instance.new("UIStroke")
    stroke.Name = "Ring"
    stroke.Color = ESP.Config.PhotoRingColor
    stroke.Thickness = 2
    stroke.Transparency = 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = box

    -- gradient no stroke pra efeito premium
    local grad = Instance.new("UIGradient")
    grad.Name = "RingGrad"
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, ESP.Config.PhotoRingColor),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(34, 211, 238)),
    })
    grad.Rotation = 45
    grad.Parent = stroke

    -- foto
    local img = Instance.new("ImageLabel")
    img.Name = "Photo"
    img.Size = UDim2.new(1, -6, 1, -6)
    img.Position = UDim2.fromOffset(3, 3)
    img.BackgroundTransparency = 1
    img.Parent = box

    local imgCorner = Instance.new("UICorner")
    imgCorner.CornerRadius = UDim.new(1, 0)
    imgCorner.Parent = img

    return wrap, box, stroke, grad, img
end

local function create_cache()
    local c = {}

    -- box principal
    c.box = new_square()
    c.box.Thickness   = ESP.Config.BoxThickness
    c.box.Color       = ESP.Config.BoxColor
    c.box.Filled      = false
    c.box.Visible     = false

    -- box glow (atrás, mais grosso, mais transparente)
    c.box_glow = new_square()
    c.box_glow.Thickness = 3
    c.box_glow.Color = ESP.Config.BoxColor
    c.box_glow.Filled = false
    c.box_glow.Transparency = 0.85
    c.box_glow.Visible = false

    -- box preenchido (modo "Filled")
    c.box_bg = new_square()
    c.box_bg.Filled = true
    c.box_bg.Transparency = 0.85
    c.box_bg.Color = ESP.Config.BoxColor
    c.box_bg.Visible = false

    -- name
    c.name = new_text()
    c.name.Size       = 14
    c.name.Center     = true
    c.name.Outline    = true
    c.name.Color      = Color3.fromRGB(240, 244, 252)
    c.name.OutlineColor = Color3.fromRGB(0, 0, 0)
    c.name.Font       = 2
    c.name.Visible    = false

    -- distance
    c.distance = new_text()
    c.distance.Size   = 12
    c.distance.Center = true
    c.distance.Outline = true
    c.distance.Color  = Color3.fromRGB(165, 200, 255)
    c.distance.OutlineColor = Color3.fromRGB(0, 0, 0)
    c.distance.Font   = 2
    c.distance.Visible = false

    -- hp bg
    c.hp_bg = new_square()
    c.hp_bg.Filled    = true
    c.hp_bg.Color     = Color3.fromRGB(0, 0, 0)
    c.hp_bg.Transparency = 0.4
    c.hp_bg.Visible   = false

    -- hp fill
    c.hp_fill = new_square()
    c.hp_fill.Filled  = true
    c.hp_fill.Color   = Color3.fromRGB(70, 220, 110)
    c.hp_fill.Visible = false

    -- hp text (porcentagem)
    c.hp_text = new_text()
    c.hp_text.Size    = 11
    c.hp_text.Center  = true
    c.hp_text.Outline = true
    c.hp_text.Color   = Color3.fromRGB(255, 255, 255)
    c.hp_text.OutlineColor = Color3.fromRGB(0, 0, 0)
    c.hp_text.Font    = 2
    c.hp_text.Visible = false

    -- tracer glow (linha grossa atrás)
    c.tracer_glow = new_line()
    c.tracer_glow.Thickness = 5
    c.tracer_glow.Color = ESP.Config.TracerColor
    c.tracer_glow.Transparency = 0.75
    c.tracer_glow.Visible = false

    -- tracer principal
    c.tracer = new_line()
    c.tracer.Thickness = ESP.Config.TracerThickness
    c.tracer.Color     = ESP.Config.TracerColor
    c.tracer.Transparency = 0
    c.tracer.Visible   = false

    -- head dot
    c.head_dot = new_circle()
    c.head_dot.Thickness = 1
    c.head_dot.Filled  = true
    c.head_dot.Color   = Color3.fromRGB(255, 80, 80)
    c.head_dot.NumSides = 30
    c.head_dot.Radius  = 4
    c.head_dot.Visible = false

    -- photo
    c.photo_wrap, c.photo_box, c.photo_stroke, c.photo_grad, c.photo_img = make_photo_container()

    return c
end

local function destroy_cache(c)
    for k, v in pairs(c) do
        if typeof(v) == "Instance" then
            pcall(function() v:Destroy() end)
        elseif typeof(v) == "userdata" then
            pcall(function() v:Remove() end)
        end
    end
end

-- ── thumbnail ────────────────────────────────────────────────
local function get_thumb(userId)
    if thumb_cache[userId] then return thumb_cache[userId] end
    local ok, url = pcall(function()
        return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    end)
    if ok and url then
        thumb_cache[userId] = url
        return url
    end
    return nil
end
