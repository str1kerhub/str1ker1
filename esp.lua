-- language: Luau, file: esp.lua, target: Delta / Krnl / Codex
-- Str1ker ESP v9 — Final

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LP = Players.LocalPlayer

local ESP = {
    Enabled = false,
    Config = {
        -- Box
        Box = true,
        BoxColor = Color3.fromRGB(80, 150, 255),
        BoxThickness = 1.5,
        BoxOutline = true,
        BoxOutlineColor = Color3.fromRGB(0, 0, 0),
        BoxOutlineThickness = 3,

        -- Health Bar
        HealthBar = true,
        HealthBarWidth = 4,
        HealthBarOffset = 6,
        HealthBarOutlineColor = Color3.fromRGB(0, 0, 0),
        HealthBarDamageColor = Color3.fromRGB(230, 40, 40),
        HealthBarHealColor = Color3.fromRGB(70, 220, 110),

        -- Skeleton
        Skeleton = false,
        SkeletonColor = Color3.fromRGB(255, 255, 255),
        SkeletonThickness = 2,
        SkeletonOutline = true,
        SkeletonOutlineColor = Color3.fromRGB(0, 0, 0),
        SkeletonOutlineThickness = 4,

        -- Info
        Name = true,
        ShowDisplayName = true,
        Distance = true,

        -- Tracer
        Tracer = true,
        TracerColor = Color3.fromRGB(80, 150, 255),
        TracerThickness = 1.5,
        TracerOutline = true,
        TracerOutlineColor = Color3.fromRGB(255, 255, 255),
        TracerOutlineThickness = 3,

        -- Photo
        ShowPhoto = false,
        PhotoSize = 52,
        PhotoRingColor = Color3.fromRGB(70, 220, 110),

        -- Filters
        MaxDistance = 2000,
        TeamCheck = true,
    }
}

--// Services & Drawing Check
local DRAWING = Drawing or (syn and syn.drawing) or (Krnl and Krnl.Drawing)
if not DRAWING then
    return warn("[Str1ker ESP] Este executor não suporta a API Drawing.")
end

--// Helper Functions
local function new_square() return DRAWING.new("Square") end
local function new_line() return DRAWING.new("Line") end
local function new_text() return DRAWING.new("Text") end
local function new_circle() return DRAWING.new("Circle") end

--// ScreenGui for Photo
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Str1ker_ESP"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() screenGui.Parent = gethui() end)
if not screenGui.Parent then screenGui.Parent = LP:WaitForChild("PlayerGui") end

--// Main Cache
local espCache = {}
local thumbCache = {}

--// Skeleton Bone Definitions
local SKELETON_R15 = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"},
}

local SKELETON_R6 = {
    {"Head", "Torso"},
    {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
    {"Torso", "Left Leg"}, {"Torso", "Right Leg"},
}

--// Functions
local function getRigType(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if humanoid.RigType == Enum.HumanoidRigType.R6 then
            return SKELETON_R6
        elseif humanoid.RigType == Enum.HumanoidRigType.R15 then
            return SKELETON_R15
        end
    end
    return nil
end

local function createPhotoElements()
    local container = Instance.new("Frame")
    container.BackgroundTransparency = 1
    container.Visible = false
    container.ZIndex = 5
    container.Parent = screenGui

    local background = Instance.new("Frame")
    background.Size = UDim2.fromScale(1, 1)
    background.BackgroundColor3 = Color3.fromRGB(8, 14, 28)
    background.BorderSizePixel = 0
    background.Parent = container
    Instance.new("UICorner", background).CornerRadius = UDim.new(1, 0)

    local ring = Instance.new("UIStroke")
    ring.Color = ESP.Config.PhotoRingColor
    ring.Thickness = 2
    ring.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ring.Parent = background

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(ESP.Config.PhotoRingColor, Color3.fromRGB(34, 211, 238))
    gradient.Rotation = 45
    gradient.Parent = ring

    local image = Instance.new("ImageLabel")
    image.Size = UDim2.new(1, -6, 1, -6)
    image.Position = UDim2.fromOffset(3, 3)
    image.BackgroundTransparency = 1
    image.Parent = background
    Instance.new("UICorner", image).CornerRadius = UDim.new(1, 0)

    return container, ring, gradient, image
end

local function createCacheEntry()
    local c = {}

    -- 1. Box
    c.BoxOutline = new_square()
    c.BoxOutline.Filled = false
    c.BoxOutline.Color = ESP.Config.BoxOutlineColor
    c.BoxOutline.Thickness = ESP.Config.BoxOutlineThickness
    c.BoxOutline.Visible = false
    c.BoxOutline.From = Vector2.zero
    c.BoxOutline.To = Vector2.zero

    c.Box = new_square()
    c.Box.Filled = false
    c.Box.Color = ESP.Config.BoxColor
    c.Box.Thickness = ESP.Config.BoxThickness
    c.Box.Visible = false
    c.Box.From = Vector2.zero
    c.Box.To = Vector2.zero

    -- 2. Health Bar (Ordem: bg, dmg, fill)
    c.HealthBarBg = new_square()
    c.HealthBarBg.Filled = true
    c.HealthBarBg.Color = Color3.new(0, 0, 0)
    c.HealthBarBg.Transparency = 0.3
    c.HealthBarBg.Visible = false
    c.HealthBarBg.From = Vector2.zero
    c.HealthBarBg.To = Vector2.zero

    c.HealthBarDamage = new_square()
    c.HealthBarDamage.Filled = true
    c.HealthBarDamage.Color = ESP.Config.HealthBarDamageColor
    c.HealthBarDamage.Transparency = 0
    c.HealthBarDamage.Visible = false
    c.HealthBarDamage.From = Vector2.zero
    c.HealthBarDamage.To = Vector2.zero

    c.HealthBarFill = new_square()
    c.HealthBarFill.Filled = true
    c.HealthBarFill.Color = ESP.Config.HealthBarHealColor
    c.HealthBarFill.Transparency = 0
    c.HealthBarFill.Visible = false
    c.HealthBarFill.From = Vector2.zero
    c.HealthBarFill.To = Vector2.zero

    -- 3. Text
    c.Name = new_text()
    c.Name.Size = 14
    c.Name.Center = true
    c.Name.Outline = true
    c.Name.Color = Color3.fromRGB(240, 244, 252)
    c.Name.OutlineColor = Color3.new(0, 0, 0)
    c.Name.Font = Drawing.Fonts.Plex
    c.Name.Visible = false

    c.Distance = new_text()
    c.Distance.Size = 12
    c.Distance.Center = true
    c.Distance.Outline = true
    c.Distance.Color = Color3.fromRGB(200, 215, 235)
    c.Distance.OutlineColor = Color3.new(0, 0, 0)
    c.Distance.Font = Drawing.Fonts.Plex
    c.Distance.Visible = false

    -- 4. Tracer (Ordem: outline, main)
    c.TracerOutline = new_line()
    c.TracerOutline.Thickness = ESP.Config.TracerOutlineThickness
    c.TracerOutline.Color = ESP.Config.TracerOutlineColor
    c.TracerOutline.Transparency = 0
    c.TracerOutline.Visible = false
    c.TracerOutline.From = Vector2.zero
    c.TracerOutline.To = Vector2.zero

    c.Tracer = new_line()
    c.Tracer.Thickness = ESP.Config.TracerThickness
    c.Tracer.Color = ESP.Config.TracerColor
    c.Tracer.Transparency = 0
    c.Tracer.Visible = false
    c.Tracer.From = Vector2.zero
    c.Tracer.To = Vector2.zero

    -- 5. Head Dot
    c.HeadDot = new_circle()
    c.HeadDot.Filled = true
    c.HeadDot.Radius = 3
    c.HeadDot.NumSides = 20
    c.HeadDot.Color = Color3.fromRGB(255, 80, 80)
    c.HeadDot.Visible = false

    -- 6. Skeleton (Pool)
    c.SkeletonLines = {}

    -- 7. Photo
    c.PhotoContainer, c.PhotoRing, c.PhotoGradient, c.PhotoImage = createPhotoElements()

    return c
end

local function destroyCacheEntry(c)
    -- Remove all Drawing objects
    local drawings = {
        c.Box, c.BoxOutline,
        c.HealthBarBg, c.HealthBarDamage, c.HealthBarFill,
        c.Name, c.Distance,
        c.Tracer, c.TracerOutline, c.HeadDot
    }
    for _, v in ipairs(drawings) do
        if typeof(v) == "userdata" then pcall(function() v:Remove() end) end
    end
    for _, line in ipairs(c.SkeletonLines) do
        if typeof(line) == "userdata" then pcall(function() line:Remove() end) end
    end
    -- Destroy Photo Instance
    if c.PhotoContainer then
        c.PhotoContainer:Destroy()
    end
end

local function ensureSkeletonPool(c, count)
    while #c.SkeletonLines < count do
        local line = new_line()
        line.Thickness = ESP.Config.SkeletonThickness
        line.Color = ESP.Config.SkeletonColor
        line.Transparency = 0
        line.Visible = false
        line.From = Vector2.zero
        line.To = Vector2.zero
        table.insert(c.SkeletonLines, line)
    end
    for i = count + 1, #c.SkeletonLines do
        c.SkeletonLines[i].Visible = false
    end
end

local function getThumbnail(userId)
    if thumbCache[userId] then return thumbCache[userId] end
    local success, url = pcall(function()
        return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    end)
    if success and url then
        thumbCache[userId] = url
        return url
    end
    return nil
end

local function worldToScreen(position)
    local screenPoint, onScreen = Camera:WorldToViewportPoint(position)
    if not onScreen or screenPoint.Z < 0 then return nil end
    return Vector2.new(screenPoint.X, screenPoint.Y)
end

local function getBoundingBox(plr)
    local char = plr.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not head or not hum or hum.Health <= 0 then return nil end
    return char, hrp, head, hum
end

local function getHealthColor(pct)
    if pct > 0.66 then return ESP.Config.HealthBarHealColor end
    if pct > 0.33 then return Color3.fromRGB(255, 200, 60) end
    return Color3.fromRGB(255, 60, 60)
end

local function renderSkeleton(c, char)
    local rig = getRigType(char)
    if not rig then return end

    ensureSkeletonPool(c, #rig)

    for i, connection in ipairs(rig) do
        local part1 = char:FindFirstChild(connection[1])
        local part2 = char:FindFirstChild(connection[2])
        local line = c.SkeletonLines[i]

        if part1 and part2 and part1:IsA("BasePart") and part2:IsA("BasePart") then
            local screen1 = worldToScreen(part1.Position)
            local screen2 = worldToScreen(part2.Position)

            if screen1 and screen2 then
                line.From = screen1
                line.To = screen2
                line.Color = ESP.Config.SkeletonColor
                line.Thickness = ESP.Config.SkeletonThickness
                line.Visible = true
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    end
end

local function hideAllElements(c)
    c.Box.Visible = false
    c.BoxOutline.Visible = false
    c.HealthBarBg.Visible = false
    c.HealthBarDamage.Visible = false
    c.HealthBarFill.Visible = false
    c.Name.Visible = false
    c.Distance.Visible = false
    c.Tracer.Visible = false
    c.TracerOutline.Visible = false
    c.HeadDot.Visible = false
    for _, line in ipairs(c.SkeletonLines) do line.Visible = false end
    if c.PhotoContainer then c.PhotoContainer.Visible = false end
end

local function renderESP(plr, c)
    local char, hrp, head, hum = getBoundingBox(plr)
    if not char then return false end

    -- Filters
    local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return false end

    local distance = (hrp.Position - myHrp.Position).Magnitude
    if distance > ESP.Config.MaxDistance then return false end

    if ESP.Config.TeamCheck and plr.Team and LP.Team and plr.Team == LP.Team then return false end

    -- World to Screen
    local topPos = worldToScreen(head.Position + Vector3.new(0, 1.2, 0))
    local bottomPos = worldToScreen(hrp.Position - Vector3.new(0, 2.8, 0))
    if not topPos or not bottomPos then return false end

    -- Calculate Box Size
    local height = math.abs(topPos.Y - bottomPos.Y)
    local width = math.max(math.abs(topPos.X - bottomPos.X), height * 0.55)

    local left = topPos.X - width / 2
    local right = topPos.X + width / 2
    local topY = topPos.Y
    local bottomY = bottomPos.Y

    --// 1. BOX
    if ESP.Config.Box then
        -- Outline
        if ESP.Config.BoxOutline then
            c.BoxOutline.From = Vector2.new(left - 1, topY - 1)
            c.BoxOutline.To = Vector2.new(right + 1, bottomY + 1)
            c.BoxOutline.Color = ESP.Config.BoxOutlineColor
            c.BoxOutline.Thickness = ESP.Config.BoxOutlineThickness
            c.BoxOutline.Visible = true
        else
            c.BoxOutline.Visible = false
        end

        -- Main Box
        c.Box.From = Vector2.new(left, topY)
        c.Box.To = Vector2.new(right, bottomY)
        c.Box.Color = ESP.Config.BoxColor
        c.Box.Thickness = ESP.Config.BoxThickness
        c.Box.Visible = true
    else
        c.Box.Visible = false
        c.BoxOutline.Visible = false
    end

    --// 2. SKELETON
    if ESP.Config.Skeleton then
        renderSkeleton(c, char)
    else
        for _, line in ipairs(c.SkeletonLines) do line.Visible = false end
    end

    --// 3. HEALTH BAR
    if ESP.Config.HealthBar then
        local healthPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        local barWidth = ESP.Config.HealthBarWidth
        local barLeft = left - ESP.Config.HealthBarOffset - barWidth
        local barRight = left - ESP.Config.HealthBarOffset
        local barHeight = bottomY - topY

        -- Background
        c.HealthBarBg.From = Vector2.new(barLeft, topY)
        c.HealthBarBg.To = Vector2.new(barRight, bottomY)
        c.HealthBarBg.Visible = true

        -- Damage Layer (only if health < 100%)
        if healthPct < 0.99 then
            c.HealthBarDamage.From = Vector2.new(barLeft, topY)
            c.HealthBarDamage.To = Vector2.new(barRight, topY + barHeight * (1 - healthPct))
            c.HealthBarDamage.Visible = true
        else
            c.HealthBarDamage.Visible = false
        end

        -- Health Fill
        c.HealthBarFill.From = Vector2.new(barLeft, bottomY - barHeight * healthPct)
        c.HealthBarFill.To = Vector2.new(barRight, bottomY)
        c.HealthBarFill.Color = getHealthColor(healthPct)
        c.HealthBarFill.Visible = true
    else
        c.HealthBarBg.Visible = false
        c.HealthBarDamage.Visible = false
        c.HealthBarFill.Visible = false
    end

    --// 4. NAME
    if ESP.Config.Name then
        c.Name.Visible = true
        c.Name.Position = Vector2.new(topPos.X, topY - 16)
        c.Name.Text = ESP.Config.ShowDisplayName and plr.DisplayName or plr.Name
    else
        c.Name.Visible = false
    end

    --// 5. DISTANCE
    if ESP.Config.Distance then
        c.Distance.Visible = true
        c.Distance.Position = Vector2.new(topPos.X, bottomY + 4)
        c.Distance.Text = string.format("[%d m]", math.floor(distance / 3.5))
    else
        c.Distance.Visible = false
    end

    --// 6. TRACER
    if ESP.Config.Tracer then
        local viewport = Camera.ViewportSize
        local tracerStart = Vector2.new(viewport.X / 2, viewport.Y)
        local tracerEnd = Vector2.new(topPos.X, bottomY)

        -- Outline
        if ESP.Config.TracerOutline then
            c.TracerOutline.From = tracerStart
            c.TracerOutline.To = tracerEnd
            c.TracerOutline.Color = ESP.Config.TracerOutlineColor
            c.TracerOutline.Thickness = ESP.Config.TracerOutlineThickness
            c.TracerOutline.Visible = true
        else
            c.TracerOutline.Visible = false
        end

        -- Main Tracer
        c.Tracer.From = tracerStart
        c.Tracer.To = tracerEnd
        c.Tracer.Color = ESP.Config.TracerColor
        c.Tracer.Thickness = ESP.Config.TracerThickness
        c.Tracer.Visible = true
    else
        c.Tracer.Visible = false
        c.TracerOutline.Visible = false
    end

    --// 7. HEAD DOT
    if not ESP.Config.ShowPhoto then
        local headScreenPos = worldToScreen(head.Position)
        if headScreenPos then
            c.HeadDot.Position = headScreenPos
            c.HeadDot.Visible = true
        else
            c.HeadDot.Visible = false
        end
    else
        c.HeadDot.Visible = false
    end

    --// 8. PHOTO
    if ESP.Config.ShowPhoto then
        local url = getThumbnail(plr.UserId)
        if url and c.PhotoImage.Image ~= url then
            c.PhotoImage.Image = url
        end
        local size = ESP.Config.PhotoSize
        c.PhotoContainer.Size = UDim2.fromOffset(size, size)
        c.PhotoContainer.Position = UDim2.fromOffset(math.floor(topPos.X - size / 2), math.floor(topY - size - 24))
        c.PhotoContainer.Visible = true
        c.PhotoRing.Color = ESP.Config.PhotoRingColor
        c.PhotoGradient.Color = ColorSequence.new(ESP.Config.PhotoRingColor, Color3.fromRGB(34, 211, 238))
    elseif c.PhotoContainer then
        c.PhotoContainer.Visible = false
    end

    return true
end

--// Main Loop
RunService.RenderStepped:Connect(function()
    if not ESP.Enabled then
        for _, c in pairs(espCache) do
            hideAllElements(c)
        end
        return
    end

    local activePlayers = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local c = espCache[plr]
            if not c then
                c = createCacheEntry()
                espCache[plr] = c
            end
            if not renderESP(plr, c) then
                hideAllElements(c)
            end
            activePlayers[plr] = true
        end
    end

    -- Cleanup for players who left
    for plr, c in pairs(espCache) do
        if not activePlayers[plr] then
            destroyCacheEntry(c)
            espCache[plr] = nil
        end
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if espCache[plr] then
        destroyCacheEntry(espCache[plr])
        espCache[plr] = nil
    end
end)

--// API
function ESP.set(key, value)
    ESP.Config[key] = value
end

function ESP.toggle(state)
    if state == nil then
        ESP.Enabled = not ESP.Enabled
    else
        ESP.Enabled = state
    end
end

_G.Str1kerESP = ESP
return ESP
