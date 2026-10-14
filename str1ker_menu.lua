--!nocheck
-- ==========================================================================
-- STR1KER MENU v3 — tema azul + avatar preview
-- ==========================================================================

local API = getgenv().Str1kerAPI
if not API then warn("[Menu] Str1kerAPI nao encontrada") return end

local CFG = API.getCfg()

local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui      = (gethui and gethui()) or game:GetService("CoreGui")
local LP           = Players.LocalPlayer

local LOGO_ID = "rbxassetid://135682258411683"

local C = {
    bg       = Color3.fromRGB(8, 16, 28),
    sidebar  = Color3.fromRGB(10, 20, 36),
    header   = Color3.fromRGB(10, 20, 36),
    surface  = Color3.fromRGB(22, 35, 59),
    surface2 = Color3.fromRGB(15, 39, 68),
    accent   = Color3.fromRGB(59, 130, 246),
    accentD  = Color3.fromRGB(30, 64, 175),
    accentL  = Color3.fromRGB(96, 165, 250),
    text     = Color3.fromRGB(229, 234, 243),
    textDim  = Color3.fromRGB(107, 122, 153),
    green    = Color3.fromRGB(16, 185, 129),
    red      = Color3.fromRGB(239, 68, 68),
    border   = Color3.fromRGB(28, 42, 68),
}

local function corner(o, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6); c.Parent = o; return c
end
local function stroke(o, col, th, tr)
    local s = Instance.new("UIStroke")
    s.Color = col; s.Thickness = th or 1
    s.Transparency = tr or 0; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = o; return s
end
local function pad(o, t, r, b, l)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, t or 0); p.PaddingRight = UDim.new(0, r or 0)
    p.PaddingBottom = UDim.new(0, b or 0); p.PaddingLeft = UDim.new(0, l or 0)
    p.Parent = o
end
local function mkList(p, sp)
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, sp or 6)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = p; return l
end
local function tw(obj, time, props, style, dir)
    local t = TweenService:Create(obj, TweenInfo.new(
        time, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out
    ), props)
    t:Play(); return t
end

-- ==========================================================================
-- GUI
-- ==========================================================================

local gui = Instance.new("ScreenGui")
gui.Name = "Str1kerMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 100
gui.Parent = CoreGui

-- Botao flutuante
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 38, 0, 38)
openBtn.Position = UDim2.new(0, 130, 0, 5)
openBtn.BackgroundColor3 = C.accent
openBtn.BorderSizePixel = 0
openBtn.Text = "S"
openBtn.TextColor3 = Color3.new(1, 1, 1)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 20
openBtn.AutoButtonColor = false
openBtn.ZIndex = 2
openBtn.Parent = gui
corner(openBtn, 8)
stroke(openBtn, C.accent, 1.5, 0.3)

if LOGO_ID and LOGO_ID ~= "" then
    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(1, 0, 1, 0)
    img.BackgroundTransparency = 1
    img.Image = LOGO_ID
    img.ScaleType = Enum.ScaleType.Fit
    img.ZIndex = 3
    img.Active = false
    img.Parent = openBtn
    corner(img, 8)
end

-- Janela principal (780 de largura = mais espaco para o boneco)
local win = Instance.new("Frame")
win.Name = "Window"
win.Size = UDim2.new(0, 780, 0, 460)
win.Position = UDim2.new(0.5, -390, 0.5, -230)
win.BackgroundColor3 = C.bg
win.BorderSizePixel = 0
win.ClipsDescendants = true
win.Parent = gui
corner(win, 12)
stroke(win, C.border, 1)

local scale = Instance.new("UIScale")
scale.Scale = 1
scale.Parent = win

-- Linha gradient top
local topLine = Instance.new("Frame")
topLine.Size = UDim2.new(1, 0, 0, 1)
topLine.BackgroundColor3 = C.accent
topLine.BorderSizePixel = 0
topLine.Active = false
topLine.ZIndex = 3
topLine.Parent = win
local topGrad = Instance.new("UIGradient")
topGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.5, 0.4),
    NumberSequenceKeypoint.new(1, 1),
})
topGrad.Parent = topLine

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 44)
header.BackgroundColor3 = C.header
header.BorderSizePixel = 0
header.Parent = win

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 12)
headerFix.Position = UDim2.new(0, 0, 1, -12)
headerFix.BackgroundColor3 = C.header
headerFix.BorderSizePixel = 0
headerFix.Active = false
headerFix.Parent = header

-- Logo
local logoWrap = Instance.new("Frame")
logoWrap.Size = UDim2.new(0, 28, 0, 28)
logoWrap.Position = UDim2.new(0, 12, 0.5, -14)
logoWrap.BackgroundTransparency = 1
logoWrap.Active = false
logoWrap.Parent = header

local logoBg = Instance.new("Frame")
logoBg.Size = UDim2.new(1, 0, 1, 0)
logoBg.BackgroundColor3 = C.accent
logoBg.BorderSizePixel = 0
logoBg.Active = false
logoBg.ZIndex = 1
logoBg.Parent = logoWrap
corner(logoBg, 7)

local logoLetter = Instance.new("TextLabel")
logoLetter.Size = UDim2.new(1, 0, 1, 0)
logoLetter.BackgroundTransparency = 1
logoLetter.Font = Enum.Font.GothamBold
logoLetter.TextSize = 15
logoLetter.TextColor3 = Color3.new(1, 1, 1)
logoLetter.Text = "S"
logoLetter.ZIndex = 2
logoLetter.Active = false
logoLetter.Parent = logoWrap

if LOGO_ID and LOGO_ID ~= "" then
    local logoImg = Instance.new("ImageLabel")
    logoImg.Size = UDim2.new(1, 0, 1, 0)
    logoImg.BackgroundTransparency = 1
    logoImg.Image = LOGO_ID
    logoImg.ScaleType = Enum.ScaleType.Fit
    logoImg.ZIndex = 3
    logoImg.Active = false
    logoImg.Parent = logoWrap
    corner(logoImg, 7)
end

local headerTitle = Instance.new("TextLabel")
headerTitle.Size = UDim2.new(0, 220, 1, 0)
headerTitle.Position = UDim2.new(0, 48, 0, 0)
headerTitle.BackgroundTransparency = 1
headerTitle.Font = Enum.Font.GothamBold
headerTitle.TextSize = 14
headerTitle.TextColor3 = C.text
headerTitle.TextXAlignment = Enum.TextXAlignment.Left
headerTitle.Text = "STR1KER"
headerTitle.Active = false
headerTitle.Parent = header

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 26, 0, 26)
minBtn.Position = UDim2.new(1, -66, 0.5, -13)
minBtn.BackgroundColor3 = C.surface
minBtn.BorderSizePixel = 0
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 14
minBtn.TextColor3 = C.textDim
minBtn.Text = "-"
minBtn.AutoButtonColor = false
minBtn.Parent = header
corner(minBtn, 6)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -34, 0.5, -13)
closeBtn.BackgroundColor3 = C.red
closeBtn.BackgroundTransparency = 0.9
closeBtn.BorderSizePixel = 0
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.TextColor3 = C.red
closeBtn.Text = "x"
closeBtn.AutoButtonColor = false
closeBtn.Parent = header
corner(closeBtn, 6)
stroke(closeBtn, C.red, 1, 0.8)

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 130, 1, -44)
sidebar.Position = UDim2.new(0, 0, 0, 44)
sidebar.BackgroundColor3 = C.sidebar
sidebar.BorderSizePixel = 0
sidebar.Parent = win
pad(sidebar, 10, 10, 10, 10)
mkList(sidebar, 6)

-- Content (deixa 200px para o boneco)
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -330, 1, -44)
content.Position = UDim2.new(0, 130, 0, 44)
content.BackgroundColor3 = C.bg
content.BorderSizePixel = 0
content.Parent = win

-- ==========================================================================
-- CHARACTER PANEL (avatar do usuario)
-- ==========================================================================

local charPanel = Instance.new("Frame")
charPanel.Name = "CharPanel"
charPanel.Size = UDim2.new(0, 200, 1, -44)
charPanel.Position = UDim2.new(1, -200, 0, 44)
charPanel.BackgroundColor3 = C.sidebar
charPanel.BorderSizePixel = 0
charPanel.ClipsDescendants = true
charPanel.Parent = win

-- Glow pulsante atras do avatar
local glow = Instance.new("Frame")
glow.AnchorPoint = Vector2.new(0.5, 0.5)
glow.Size = UDim2.new(0, 160, 0, 160)
glow.Position = UDim2.new(0.5, 0, 0.5, 0)
glow.BackgroundColor3 = C.accent
glow.BackgroundTransparency = 0.78
glow.BorderSizePixel = 0
glow.ZIndex = 1
glow.Active = false
glow.Parent = charPanel
corner(glow, 999)

task.spawn(function()
    while glow.Parent do
        tw(glow, 2.5, {
            BackgroundTransparency = 0.6,
            Size = UDim2.new(0, 185, 0, 185),
        }, Enum.EasingStyle.Sine)
        task.wait(2.5)
        if not glow.Parent then break end
        tw(glow, 2.5, {
            BackgroundTransparency = 0.82,
            Size = UDim2.new(0, 155, 0, 155),
        }, Enum.EasingStyle.Sine)
        task.wait(2.5)
    end
end)

-- Sombra eliptica embaixo do boneco
local shadow = Instance.new("Frame")
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.Size = UDim2.new(0, 100, 0, 10)
shadow.Position = UDim2.new(0.5, 0, 0.86, 0)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.55
shadow.BorderSizePixel = 0
shadow.ZIndex = 2
shadow.Active = false
shadow.Parent = charPanel
corner(shadow, 99)

-- ImageLabel com o avatar (centralizado)
local avatarImg = Instance.new("ImageLabel")
avatarImg.Name = "Avatar"
avatarImg.AnchorPoint = Vector2.new(0.5, 0.5)
avatarImg.Size = UDim2.new(0, 180, 0, 180)
avatarImg.Position = UDim2.new(0.5, 0, 0.5, -15)
avatarImg.BackgroundTransparency = 1
avatarImg.ScaleType = Enum.ScaleType.Fit
avatarImg.ZIndex = 3
avatarImg.Active = false
avatarImg.Parent = charPanel

-- Label embaixo
local charLabel = Instance.new("TextLabel")
charLabel.AnchorPoint = Vector2.new(0.5, 0)
charLabel.Size = UDim2.new(1, 0, 0, 16)
charLabel.Position = UDim2.new(0.5, 0, 1, -22)
charLabel.BackgroundTransparency = 1
charLabel.Font = Enum.Font.GothamBold
charLabel.TextSize = 9
charLabel.TextColor3 = C.textDim
charLabel.TextXAlignment = Enum.TextXAlignment.Center
charLabel.Text = "YOUR SKIN"
charLabel.Active = false
charLabel.ZIndex = 4
charLabel.Parent = charPanel

-- ==========================================================================
-- CARREGA AVATAR
-- ==========================================================================

local function loadAvatar()
    local userId = LP.UserId

    -- Metodo nativo rbxthumb (instantaneo, sem HTTP)
    local rbxthumb = "rbxthumb://type=Avatar&id=" .. userId .. "&w=720&h=720"
    avatarImg.Image = rbxthumb

    -- Timeout de 2s: se falhar, tenta HTTP
    task.delay(2, function()
        if not avatarImg.IsLoaded then
            local Http = game:GetService("HttpService")
            local url = "https://thumbnails.roblox.com/v1/users/avatar?userIds="
                .. userId .. "&size=720x720&format=Png&isCircular=false"
            local ok, res = pcall(function() return game:HttpGet(url) end)
            if ok and res then
                local ok2, data = pcall(function() return Http:JSONDecode(res) end)
                if ok2 and data and data.data and data.data[1] then
                    avatarImg.Image = data.data[1].imageUrl
                end
            end
        end
    end)
end

task.spawn(function()
    if not LP.Character then
        LP.CharacterAdded:Wait()
    end
    task.wait(0.5)
    loadAvatar()
end)

-- Animacao: flutuacao + sway suave + breathing scale
local t = 0
RunService.RenderStepped:Connect(function(dt)
    if not avatarImg or not avatarImg.Parent then return end
    t = t + dt

    -- Flutuacao vertical suave (8px)
    local yOff = math.sin(t * 1.4) * 4

    -- Sway leve (2 graus) - parece estar "vivo"
    local rot = math.sin(t * 0.9) * 2

    -- Breathing scale leve (efeito de respirar)
    local breath = 1 + math.sin(t * 1.4) * 0.015
    local baseSize = 180 * breath

    avatarImg.Position = UDim2.new(0.5, 0, 0.5, -15 + yOff)
    avatarImg.Rotation = rot
    avatarImg.Size = UDim2.new(0, baseSize, 0, baseSize)
end)

-- ==========================================================================
-- COMPONENTES (sidebar, tabs, cards)
-- ==========================================================================

local pages = {}
local tabBtns = {}

local function newPage(name)
    local sc = Instance.new("ScrollingFrame")
    sc.Name = name
    sc.Size = UDim2.new(1, 0, 1, 0)
    sc.BackgroundTransparency = 1
    sc.BorderSizePixel = 0
    sc.ScrollBarThickness = 3
    sc.ScrollBarImageColor3 = C.accent
    sc.CanvasSize = UDim2.new(0, 0, 0, 0)
    sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sc.Visible = false
    sc.Parent = content
    pad(sc, 14, 14, 14, 14)
    mkList(sc, 8)
    pages[name] = sc
    return sc
end

local function switchTab(name)
    for tabName, page in pairs(pages) do
        page.Visible = (tabName == name)
    end
    for _, btn in ipairs(tabBtns) do
        if btn.Name == name then
            tw(btn, 0.15, { BackgroundColor3 = C.surface })
            btn.UIStroke.Color = C.accent
            btn.UIStroke.Transparency = 0
            btn.TextColor3 = C.accent
        else
            tw(btn, 0.15, { BackgroundColor3 = C.sidebar })
            btn.UIStroke.Color = C.sidebar
            btn.UIStroke.Transparency = 1
            btn.TextColor3 = C.textDim
        end
    end
end

local TAB_ICONS = {
    Aimbot = "◎",
    ESP    = "◉",
    Config = "✦",
    Info   = "✧",
}

local function newTabBtn(name, label)
local TAB_ICONS = {
    Aimbot = "◎",
    ESP    = "◉",
    Config = "✦",
    Info   = "✧",
}

local function newTabBtn(name, label)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Size = UDim2.new(1, 0, 0, 36)
    b.BackgroundColor3 = C.sidebar
    b.BorderSizePixel = 0
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.TextColor3 = C.textDim
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Text = "   " .. (TAB_ICONS[name] or "•") .. "    " .. label
    b.AutoButtonColor = false
    b.Parent = sidebar
    corner(b, 7)
    local s = stroke(b, C.sidebar, 1, 1)
    table.insert(tabBtns, b)
    b.MouseButton1Click:Connect(function() switchTab(name) end)
    return b
    end
    b.MouseLeave:Connect(function()
        if pages[name] and pages[name].Visible then return end
        tw(b, 0.15, { BackgroundColor3 = C.sidebar })
        s.Color = C.sidebar
        s.Transparency = 1
    end)
    return b
end

local function sectionHeader(page, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.TextColor3 = C.textDim
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = string.upper(text)
    lbl.Active = false
    lbl.Parent = page
    return lbl
end

local function rowBase(page, label, desc)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, desc and 48 or 38)
    row.BackgroundColor3 = C.surface
    row.BorderSizePixel = 0
    row.Parent = page
    corner(row, 7)
    stroke(row, C.border, 1, 0.3)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -100, 0, 18)
    title.Position = UDim2.new(0, 12, 0, desc and 6 or 10)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.TextColor3 = C.text
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = label
    title.Active = false
    title.Parent = row

    if desc then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1, -24, 0, 14)
        d.Position = UDim2.new(0, 12, 0, 26)
        d.BackgroundTransparency = 1
        d.Font = Enum.Font.Gotham
        d.TextSize = 10
        d.TextColor3 = C.textDim
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Text = desc
        d.Active = false
        d.Parent = row
    end
    return row
end

local function toggle(page, label, initial, callback)
    local row = rowBase(page, label)
    local state = initial == true

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 36, 0, 18)
    bg.Position = UDim2.new(1, -48, 0.5, -9)
    bg.BackgroundColor3 = state and C.accent or C.surface2
    bg.BorderSizePixel = 0
    bg.Active = false
    bg.Parent = row
    corner(bg, 99)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Active = false
    knob.Parent = bg
    corner(knob, 99)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = row

    btn.MouseButton1Click:Connect(function()
        state = not state
        tw(bg, 0.15, { BackgroundColor3 = state and C.accent or C.surface2 })
        tw(knob, 0.15, {
            Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        })
        if callback then callback(state) end
    end)

    return {
        Set = function(v)
            state = v == true
            bg.BackgroundColor3 = state and C.accent or C.surface2
            knob.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        end
    }
end

local function slider(page, label, minV, maxV, initial, step, callback)
    step = step or 0.01
    local row = rowBase(page, label)
    row.Size = UDim2.new(1, 0, 0, 52)

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 70, 0, 18)
    valLbl.Position = UDim2.new(1, -80, 0, 8)
    valLbl.BackgroundTransparency = 1
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 12
    valLbl.TextColor3 = C.accent
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Text = tostring(initial)
    valLbl.Active = false
    valLbl.Parent = row

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -24, 0, 6)
    bar.Position = UDim2.new(0, 12, 1, -14)
    bar.BackgroundColor3 = C.surface2
    bar.BorderSizePixel = 0
    bar.Parent = row
    corner(bar, 99)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((initial - minV) / (maxV - minV), 0, 1, 0)
    fill.BackgroundColor3 = C.accent
    fill.BorderSizePixel = 0
    fill.Active = false
    fill.Parent = bar
    corner(fill, 99)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new((initial - minV) / (maxV - minV), 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    knob.Active = false
    knob.Parent = bar
    corner(knob, 99)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = bar

    local dragging = false
    local function update(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = minV + (maxV - minV) * rel
        val = math.floor(val / step) * step
        val = math.clamp(val, minV, maxV)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, 0, 0.5, 0)
        valLbl.Text = step < 1 and string.format("%.2f", val) or tostring(math.floor(val))
        if callback then callback(val) end
    end

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                         or input.UserInputType == Enum.UserInputType.Touch) then
            update(input.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function dropdown(page, label, options, initial, callback)
    local row = rowBase(page, label)
    local currentIdx = 1
    for i, v in ipairs(options) do
        if v == initial then currentIdx = i break end
    end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 120, 0, 26)
    btn.Position = UDim2.new(1, -132, 0.5, -13)
    btn.BackgroundColor3 = C.surface2
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = C.text
    btn.Text = options[currentIdx] .. "  ▾"
    btn.AutoButtonColor = false
    btn.ZIndex = 5
    btn.Parent = row
    corner(btn, 5)
    stroke(btn, C.border, 1)

    local listOpen = false
    local listFrame

    local function closeList()
        if listFrame then listFrame:Destroy() listFrame = nil end
        listOpen = false
    end

    btn.MouseButton1Click:Connect(function()
        if listOpen then closeList() return end
        listOpen = true
        listFrame = Instance.new("Frame")
        listFrame.Size = UDim2.new(0, 140, 0, #options * 26 + 8)
        listFrame.Position = UDim2.new(1, -152, 0, 38)
        listFrame.BackgroundColor3 = C.surface
        listFrame.BorderSizePixel = 0
        listFrame.ZIndex = 10
        listFrame.Parent = row.Parent
        corner(listFrame, 7)
        stroke(listFrame, C.accent, 1, 0.5)
        pad(listFrame, 4, 4, 4, 4)
        mkList(listFrame, 2)

        for i, opt in ipairs(options) do
            local o = Instance.new("TextButton")
            o.Size = UDim2.new(1, 0, 0, 24)
            o.BackgroundColor3 = (i == currentIdx) and C.accentD or C.surface
            o.BorderSizePixel = 0
            o.Font = Enum.Font.Gotham
            o.TextSize = 11
            o.TextColor3 = C.text
            o.Text = opt
            o.TextXAlignment = Enum.TextXAlignment.Left
            o.AutoButtonColor = false
            o.ZIndex = 11
            o.Parent = listFrame
            corner(o, 4)
            pad(o, 0, 0, 0, 8)
            o.MouseButton1Click:Connect(function()
                currentIdx = i
                btn.Text = opt .. "  ▾"
                if callback then callback(opt) end
                closeList()
            end)
        end
    end)
end

-- ==========================================================================
-- TABS
-- ==========================================================================

newTabBtn("Aimbot", "Aimbot")
local aimPage = newPage("Aimbot")
sectionHeader(aimPage, "Aimbot - principal")
toggle(aimPage, "Aimbot habilitado", CFG.aim.enabled, function(v) API.setAim(v) end)
dropdown(aimPage, "Modo", {"Silent", "Camera", "Both"}, CFG.aim.mode, function(v) API.setMode(v) end)
dropdown(aimPage, "Parte do alvo", {"Head", "Torso", "HumanoidRootPart"}, CFG.aim.aim_part, function(v) API.setAimPart(v) end)
sectionHeader(aimPage, "Ajuste fino")
slider(aimPage, "FOV (px)", 20, 400, CFG.aim.fov, 1, function(v) API.setFov(v) end)
slider(aimPage, "Distancia maxima", 50, 1500, CFG.aim.max_distance, 10, function(v) CFG.aim.max_distance = v API.saveCfg() end)
slider(aimPage, "Smoothing", 0, 0.95, CFG.aim.smoothing, 0.05, function(v) API.setSmoothing(v) end)
slider(aimPage, "Resolver", 0, 0.20, CFG.aim.resolver, 0.01, function(v) API.setResolver(v) end)
sectionHeader(aimPage, "Checks")
toggle(aimPage, "Team check", CFG.aim.team_check, function(v) CFG.aim.team_check = v API.saveCfg() end)
toggle(aimPage, "Visibility check", CFG.aim.visibility_check, function(v) CFG.aim.visibility_check = v API.saveCfg() end)
toggle(aimPage, "Predicao de movimento", CFG.aim.prediction, function(v) CFG.aim.prediction = v API.saveCfg() end)

newTabBtn("ESP", "ESP")
local espPage = newPage("ESP")
sectionHeader(espPage, "ESP - principal")
toggle(espPage, "ESP habilitado", CFG.esp.enabled, function(v) API.setESP(v) end)
toggle(espPage, "Box", CFG.esp.box, function(v) CFG.esp.box = v API.saveCfg() end)
toggle(espPage, "Health bar", CFG.esp.health_bar, function(v) CFG.esp.health_bar = v API.saveCfg() end)
toggle(espPage, "Nome", CFG.esp.name, function(v) CFG.esp.name = v API.saveCfg() end)
toggle(espPage, "Distancia", CFG.esp.distance, function(v) CFG.esp.distance = v API.saveCfg() end)
toggle(espPage, "Level", CFG.esp.level, function(v) CFG.esp.level = v API.saveCfg() end)
toggle(espPage, "Tracer", CFG.esp.tracer, function(v) CFG.esp.tracer = v API.saveCfg() end)
toggle(espPage, "Skeleton", CFG.esp.skeleton, function(v) CFG.esp.skeleton = v API.saveCfg() end)
sectionHeader(espPage, "Alcance")
slider(espPage, "Distancia maxima ESP", 200, 3000, CFG.esp.max_distance, 50, function(v) API.setMaxDist(v) end)

newTabBtn("Config", "Config")
local cfgPage = newPage("Config")
sectionHeader(cfgPage, "Configuracao")

local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(1, 0, 0, 36)
saveBtn.BackgroundColor3 = C.surface
saveBtn.BorderSizePixel = 0
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 12
saveBtn.TextColor3 = C.accent
saveBtn.Text = "SALVAR CONFIG"
saveBtn.AutoButtonColor = false
saveBtn.Parent = cfgPage
corner(saveBtn, 7)
stroke(saveBtn, C.accentD, 1)
saveBtn.MouseButton1Click:Connect(function()
    API.saveCfg()
    saveBtn.Text = "SALVO!"
    saveBtn.TextColor3 = C.green
    task.delay(1, function()
        saveBtn.Text = "SALVAR CONFIG"
        saveBtn.TextColor3 = C.accent
    end)
end)

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, 0, 0, 80)
info.BackgroundColor3 = C.surface
info.BorderSizePixel = 0
info.Font = Enum.Font.Gotham
info.TextSize = 11
info.TextColor3 = C.textDim
info.TextWrapped = true
info.Text = "\n  Toggle menu: K\n  Toggle ESP: F1\n  Toggle Aimbot: E (padrao)\n"
info.TextXAlignment = Enum.TextXAlignment.Left
info.TextYAlignment = Enum.TextYAlignment.Top
info.Active = false
info.Parent = cfgPage
corner(info, 7)
stroke(info, C.border, 1, 0.3)

newTabBtn("Info", "Info")
local infoPage = newPage("Info")
sectionHeader(infoPage, "Sobre")

local about = Instance.new("TextLabel")
about.Size = UDim2.new(1, 0, 0, 140)
about.BackgroundColor3 = C.surface
about.BorderSizePixel = 0
about.Font = Enum.Font.Gotham
about.TextSize = 11
about.TextColor3 = C.textDim
about.TextWrapped = true
about.Text = "\n  STR1KER - v3\n  PvP hub para Blox Fruits\n\n  Features:\n  - Silent Aim + Resolver\n  - Predicao de movimento\n  - ESP completo\n  - Config persistente\n\n  discord.gg/str1ker"
about.TextXAlignment = Enum.TextXAlignment.Left
about.TextYAlignment = Enum.TextYAlignment.Top
about.Active = false
about.Parent = infoPage
corner(about, 7)
stroke(about, C.border, 1, 0.3)

-- ==========================================================================
-- COMPORTAMENTO
-- ==========================================================================

switchTab("Aimbot")

-- Drag
local dragging, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = win.Position
    end
end)
header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                     or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        win.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- Minimize / Close / Open
local minimized = false
local fullSize = UDim2.new(0, 780, 0, 460)
local minSize  = UDim2.new(0, 780, 0, 44)

local function openMenu()
    if win.Visible then return end
    win.Visible = true
    scale.Scale = 0.9
    tw(scale, 0.3, { Scale = 1 }, Enum.EasingStyle.Back)
end
local function closeMenu()
    if not win.Visible then return end
    tw(scale, 0.2, { Scale = 0.9 })
    task.delay(0.18, function()
        win.Visible = false
        scale.Scale = 1
    end)
end

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    win.Size = minimized and minSize or fullSize
    sidebar.Visible = not minimized
    content.Visible = not minimized
    charPanel.Visible = not minimized
    minBtn.Text = minimized and "+" or "-"
end)

closeBtn.MouseButton1Click:Connect(closeMenu)

openBtn.MouseButton1Click:Connect(function()
    if win.Visible then closeMenu() else openMenu() end
end)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.K then
        if win.Visible then closeMenu() else openMenu() end
    end
end)

win.Visible = true
