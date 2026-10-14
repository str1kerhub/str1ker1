--!nocheck
-- ==========================================================================
-- STR1KER MENU v6 — layout HTML, avatar sem bola
-- ==========================================================================

local API = getgenv().Str1kerAPI
if not API then warn("[Menu] Str1kerAPI nao encontrada") return end

local CFG = API.getCfg()
local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local RunService   = game:GetService("RunService")
local Http         = game:GetService("HttpService")
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
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 6); c.Parent = o; return c
end
local function stroke(o, col, th, tr)
    local s = Instance.new("UIStroke")
    s.Color = col; s.Thickness = th or 1
    s.Transparency = tr or 0; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = o; return s
end
local function pad(o, t, r, b, l)
    local p = Instance.new("UIPadding")
    p.PaddingTop=UDim.new(0,t or 0); p.PaddingRight=UDim.new(0,r or 0)
    p.PaddingBottom=UDim.new(0,b or 0); p.PaddingLeft=UDim.new(0,l or 0)
    p.Parent = o
end
local function mkList(p, sp)
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, sp or 6)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = p; return l
end
local function tw(o, time, props, style)
    local t = TweenService:Create(o, TweenInfo.new(time, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    t:Play(); return t
end

local gui = Instance.new("ScreenGui")
gui.Name = "Str1kerMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 100
gui.Parent = CoreGui

-- ═══ BOTAO FLUTUANTE ═══
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 38, 0, 38)
openBtn.Position = UDim2.new(0, 130, 0, 5)
openBtn.BackgroundColor3 = C.accent
openBtn.BorderSizePixel = 0
openBtn.Text = ""
openBtn.AutoButtonColor = false
openBtn.ZIndex = 2
openBtn.Parent = gui
corner(openBtn, 8)
stroke(openBtn, C.accent, 1.5, 0.3)
local openLogo = Instance.new("ImageLabel")
openLogo.Size = UDim2.new(1, 0, 1, 0)
openLogo.BackgroundTransparency = 1
openLogo.Image = LOGO_ID
openLogo.ScaleType = Enum.ScaleType.Fit
openLogo.ZIndex = 3
openLogo.Active = false
openLogo.Parent = openBtn
corner(openLogo, 8)

-- ═══ JANELA ═══
local win = Instance.new("Frame")
win.Name = "Window"
win.Size = UDim2.new(0, 820, 0, 480)
win.Position = UDim2.new(0.5, -410, 0.5, -240)
win.BackgroundColor3 = C.bg
win.BorderSizePixel = 0
win.ClipsDescendants = true
win.Parent = gui
corner(win, 14)
stroke(win, C.border, 1)

local scale = Instance.new("UIScale")
scale.Scale = 1
scale.Parent = win

-- Linha topo
local topLine = Instance.new("Frame")
topLine.Size = UDim2.new(1, -48, 0, 1)
topLine.Position = UDim2.new(0, 24, 0, 0)
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

-- ═══ HEADER ═══
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = C.header
header.BorderSizePixel = 0
header.Parent = win

local headerLine = Instance.new("Frame")
headerLine.Size = UDim2.new(1, 0, 0, 1)
headerLine.Position = UDim2.new(0, 0, 1, -1)
headerLine.BackgroundColor3 = C.border
headerLine.BorderSizePixel = 0
headerLine.Active = false
headerLine.Parent = header

local hLogo = Instance.new("Frame")
hLogo.Size = UDim2.new(0, 32, 0, 32)
hLogo.Position = UDim2.new(0, 16, 0.5, -16)
hLogo.BackgroundColor3 = C.accent
hLogo.BorderSizePixel = 0
hLogo.Active = false
hLogo.ZIndex = 2
hLogo.Parent = header
corner(hLogo, 9)
local hLogoImg = Instance.new("ImageLabel")
hLogoImg.Size = UDim2.new(1, 0, 1, 0)
hLogoImg.BackgroundTransparency = 1
hLogoImg.Image = LOGO_ID
hLogoImg.ScaleType = Enum.ScaleType.Fit
hLogoImg.ZIndex = 3
hLogoImg.Active = false
hLogoImg.Parent = hLogo
corner(hLogoImg, 9)

local hTitle = Instance.new("TextLabel")
hTitle.Size = UDim2.new(0, 300, 0, 18)
hTitle.Position = UDim2.new(0, 58, 0, 8)
hTitle.BackgroundTransparency = 1
hTitle.Font = Enum.Font.GothamBold
hTitle.TextSize = 14
hTitle.TextColor3 = C.text
hTitle.TextXAlignment = Enum.TextXAlignment.Left
hTitle.Text = "STR1KER"
hTitle.Active = false
hTitle.Parent = header

local hSub = Instance.new("TextLabel")
hSub.Size = UDim2.new(0, 300, 0, 12)
hSub.Position = UDim2.new(0, 58, 0, 28)
hSub.BackgroundTransparency = 1
hSub.Font = Enum.Font.Gotham
hSub.TextSize = 9
hSub.TextColor3 = C.textDim
hSub.TextXAlignment = Enum.TextXAlignment.Left
hSub.Text = "PvP · BLOX FRUITS"
hSub.Active = false
hSub.Parent = header

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 28, 0, 28)
minBtn.Position = UDim2.new(1, -70, 0.5, -14)
minBtn.BackgroundColor3 = C.surface
minBtn.BorderSizePixel = 0
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 14
minBtn.TextColor3 = C.textDim
minBtn.Text = "−"
minBtn.AutoButtonColor = false
minBtn.Parent = header
corner(minBtn, 7)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -38, 0.5, -14)
closeBtn.BackgroundColor3 = C.red
closeBtn.BackgroundTransparency = 0.9
closeBtn.BorderSizePixel = 0
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.TextColor3 = C.red
closeBtn.Text = "×"
closeBtn.AutoButtonColor = false
closeBtn.Parent = header
corner(closeBtn, 7)
stroke(closeBtn, C.red, 1, 0.8)

-- ═══ BODY ═══
local body = Instance.new("Frame")
body.Size = UDim2.new(1, 0, 1, -50)
body.Position = UDim2.new(0, 0, 0, 50)
body.BackgroundTransparency = 1
body.Parent = win

-- ═══ SIDEBAR (150px) ═══
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 150, 1, 0)
sidebar.BackgroundColor3 = C.sidebar
sidebar.BorderSizePixel = 0
sidebar.Parent = body
pad(sidebar, 12, 10, 12, 10)
mkList(sidebar, 4)

-- ═══ CONTENT (flex) ═══
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -380, 1, 0)
content.Position = UDim2.new(0, 150, 0, 0)
content.BackgroundColor3 = C.bg
content.BorderSizePixel = 0
content.Parent = body

local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.new(1, 0, 0, 44)
tabsFrame.BackgroundColor3 = C.header
tabsFrame.BorderSizePixel = 0
tabsFrame.Parent = content

local tabsLine = Instance.new("Frame")
tabsLine.Size = UDim2.new(1, 0, 0, 1)
tabsLine.Position = UDim2.new(0, 0, 1, -1)
tabsLine.BackgroundColor3 = C.border
tabsLine.BorderSizePixel = 0
tabsLine.Active = false
tabsLine.Parent = tabsFrame

local tabsNav = Instance.new("Frame")
tabsNav.Size = UDim2.new(1, -20, 1, 0)
tabsNav.Position = UDim2.new(0, 10, 0, 0)
tabsNav.BackgroundTransparency = 1
tabsNav.Parent = tabsFrame
local tabsLayout = Instance.new("UIListLayout")
tabsLayout.FillDirection = Enum.FillDirection.Horizontal
tabsLayout.Padding = UDim.new(0, 4)
tabsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabsLayout.Parent = tabsNav

local cardsScroll = Instance.new("ScrollingFrame")
cardsScroll.Size = UDim2.new(1, 0, 1, -44)
cardsScroll.Position = UDim2.new(0, 0, 0, 44)
cardsScroll.BackgroundTransparency = 1
cardsScroll.BorderSizePixel = 0
cardsScroll.ScrollBarThickness = 3
cardsScroll.ScrollBarImageColor3 = C.accent
cardsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
cardsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
cardsScroll.Parent = content
pad(cardsScroll, 16, 16, 16, 16)
mkList(cardsScroll, 6)

-- ═══ AVATAR PANEL (230px, sem bola) ═══
local charPanel = Instance.new("Frame")
charPanel.Size = UDim2.new(0, 230, 1, 0)
charPanel.Position = UDim2.new(1, -230, 0, 0)
charPanel.BackgroundColor3 = C.sidebar
charPanel.BorderSizePixel = 0
charPanel.ClipsDescendants = true
charPanel.Parent = body

local avatarImg = Instance.new("ImageLabel")
avatarImg.AnchorPoint = Vector2.new(0.5, 0.5)
avatarImg.Size = UDim2.new(0, 190, 0, 190)
avatarImg.Position = UDim2.new(0.5, 0, 0.42, 0)
avatarImg.BackgroundTransparency = 1
avatarImg.ScaleType = Enum.ScaleType.Fit
avatarImg.ZIndex = 3
avatarImg.Active = false
avatarImg.Parent = charPanel

local charNameLbl = Instance.new("TextLabel")
charNameLbl.AnchorPoint = Vector2.new(0.5, 0)
charNameLbl.Size = UDim2.new(1, -20, 0, 20)
charNameLbl.Position = UDim2.new(0.5, 0, 0.75, 0)
charNameLbl.BackgroundTransparency = 1
charNameLbl.Font = Enum.Font.GothamBold
charNameLbl.TextSize = 13
charNameLbl.TextColor3 = C.text
charNameLbl.TextXAlignment = Enum.TextXAlignment.Center
charNameLbl.Text = LP.Name
charNameLbl.Active = false
charNameLbl.Parent = charPanel

local charIdLbl = Instance.new("TextLabel")
charIdLbl.AnchorPoint = Vector2.new(0.5, 0)
charIdLbl.Size = UDim2.new(1, -20, 0, 14)
charIdLbl.Position = UDim2.new(0.5, 0, 0.75, 22)
charIdLbl.BackgroundTransparency = 1
charIdLbl.Font = Enum.Font.Gotham
charIdLbl.TextSize = 10
charIdLbl.TextColor3 = C.textDim
charIdLbl.TextXAlignment = Enum.TextXAlignment.Center
charIdLbl.Text = "ID " .. tostring(LP.UserId)
charIdLbl.Active = false
charIdLbl.Parent = charPanel

-- ═══ CARREGAR AVATAR (rbxthumb → HTTP → Viewport) ═══
local avatarLoaded = false

local function tryRbx()
    avatarImg.Image = "rbxthumb://type=Avatar&id=" .. LP.UserId .. "&w=420&h=420"
    task.wait(2)
    return avatarImg.IsLoaded
end
local function tryHttp()
    local ok, res = pcall(game.HttpGet, game, "https://thumbnails.roblox.com/v1/users/avatar?userIds="
        .. LP.UserId .. "&size=420x420&format=Png&isCircular=false")
    if not ok or not res then return false end
    local d; pcall(function() d = Http:JSONDecode(res) end)
    if not d or not d.data or not d.data[1] then return false end
    avatarImg.Image = d.data[1].imageUrl
    task.wait(2)
    return avatarImg.IsLoaded
end
task.spawn(function()
    if not LP.Character then LP.CharacterAdded:Wait() end
    task.wait(0.5)
    if tryRbx() then avatarLoaded = true; return end
    if tryHttp() then avatarLoaded = true; return end
end)

local t = 0
RunService.RenderStepped:Connect(function(dt)
    if not avatarLoaded then return end
    t = t + dt
    local yOff = math.sin(t * 1.4) * 4
    local rot = math.sin(t * 0.9) * 2
    avatarImg.Position = UDim2.new(0.5, 0, 0.42, yOff)
    avatarImg.Rotation = rot
end)

-- ═══ HELPERS DE CARD ═══
local function cardBase(parent, label, desc)
    -- Row como TextButton → toda a área clicável
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, desc and 50 or 40)
    row.BackgroundColor3 = C.surface
    row.BorderSizePixel = 0
    row.Text = ""
    row.AutoButtonColor = false
    row.ZIndex = 1
    row.Parent = parent
    corner(row, 9)
    stroke(row, C.border, 1, 0.3)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -100, 0, 16)
    title.Position = UDim2.new(0, 14, 0, desc and 8 or 11)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.TextColor3 = C.text
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = label
    title.Active = false
    title.ZIndex = 2
    title.Parent = row

    if desc then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1, -24, 0, 14)
        d.Position = UDim2.new(0, 14, 0, 27)
        d.BackgroundTransparency = 1
        d.Font = Enum.Font.Gotham
        d.TextSize = 10
        d.TextColor3 = C.textDim
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Text = desc
        d.Active = false
        d.ZIndex = 2
        d.Parent = row
    end
    return row
end

local function mkToggle(parent, label, initial, callback)
    local row = cardBase(parent, label, nil)
    local on = initial == true

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 38, 0, 20)
    track.Position = UDim2.new(1, -52, 0.5, -10)
    track.BackgroundColor3 = on and C.accent or C.surface2
    track.BorderSizePixel = 0
    track.ZIndex = 2
    track.Active = false
    track.Parent = row
    corner(track, 99)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = on and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.ZIndex = 3
    knob.Active = false
    knob.Parent = track
    corner(knob, 99)

    row.MouseButton1Click:Connect(function()
        on = not on
        tw(track, 0.18, { BackgroundColor3 = on and C.accent or C.surface2 })
        tw(knob, 0.18, { Position = on and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8) })
        if callback then callback(on) end
    end)
end

local function mkSlider(parent, label, minV, maxV, initial, step, callback)
    step = step or 0.01
    local row = cardBase(parent, label, nil)
    row.Size = UDim2.new(1, 0, 0, 52)
    row.AutoButtonColor = false

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 70, 0, 16)
    valLbl.Position = UDim2.new(1, -84, 0, 9)
    valLbl.BackgroundTransparency = 1
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 11
    valLbl.TextColor3 = C.accent
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Text = step < 1 and string.format("%.2f", initial) or tostring(math.floor(initial))
    valLbl.Active = false
    valLbl.ZIndex = 2
    valLbl.Parent = row

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -28, 0, 5)
    bar.Position = UDim2.new(0, 14, 1, -14)
    bar.BackgroundColor3 = C.surface2
    bar.BorderSizePixel = 0
    bar.Active = false
    bar.ZIndex = 2
    bar.Parent = row
    corner(bar, 99)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((initial - minV) / (maxV - minV), 0, 1, 0)
    fill.BackgroundColor3 = C.accent
    fill.BorderSizePixel = 0
    fill.Active = false
    fill.ZIndex = 3
    fill.Parent = bar
    corner(fill, 99)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new((initial - minV) / (maxV - minV), 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.ZIndex = 4
    knob.Active = false
    knob.Parent = bar
    corner(knob, 99)

    local dragging = false
    local function update(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local v = minV + (maxV - minV) * rel
        v = math.floor(v / step) * step
        v = math.clamp(v, minV, maxV)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, 0, 0.5, 0)
        valLbl.Text = step < 1 and string.format("%.2f", v) or tostring(math.floor(v))
        if callback then callback(v) end
    end
    row.InputBegan:Connect(function(input)
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

local function mkDropdown(parent, label, options, initial, callback)
    local row = cardBase(parent, label, nil)
    local currentIdx = 1
    for i, v in ipairs(options) do if v == initial then currentIdx = i break end end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 120, 0, 26)
    btn.Position = UDim2.new(1, -134, 0.5, -13)
    btn.BackgroundColor3 = C.surface2
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = C.text
    btn.Text = options[currentIdx] .. "  ▾"
    btn.AutoButtonColor = false
    btn.ZIndex = 5
    btn.Parent = row
    corner(btn, 6)
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
        listFrame.Position = UDim2.new(1, -154, 0, 40)
        listFrame.BackgroundColor3 = C.surface
        listFrame.BorderSizePixel = 0
        listFrame.ZIndex = 20
        listFrame.Parent = row
        corner(listFrame, 8)
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
            o.ZIndex = 21
            o.Parent = listFrame
            corner(o, 4)
            pad(o, 0, 0, 0, 10)
            o.MouseButton1Click:Connect(function()
                currentIdx = i
                btn.Text = opt .. "  ▾"
                if callback then callback(opt) end
                closeList()
            end)
        end
    end)
end

local function mkHeader(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.TextColor3 = C.textDim
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = string.upper(text)
    lbl.Active = false
    lbl.Parent = parent
    return lbl
end

-- ═══ SIDEBAR TABS + TABS + PAGES ═══
local pages = {}
local tabBtns = {}
local catBtns = {}

local CATEGORIES = {
    { name = "Aimbot",   icon = "◎" },
    { name = "ESP",      icon = "◉" },
    { name = "Config",   icon = "✦" },
    { name = "Info",     icon = "✧" },
}

local function switchCat(name)
    for cn, page in pairs(pages) do page.Visible = (cn == name) end
    for _, b in ipairs(catBtns) do
        if b.Name == name then
            tw(b, 0.15, { BackgroundColor3 = C.surface })
            b.UIStroke.Color = C.accent
            b.UIStroke.Transparency = 0
            b.TextColor3 = C.accent
        else
            tw(b, 0.15, { BackgroundColor3 = C.sidebar })
            b.UIStroke.Color = C.sidebar
            b.UIStroke.Transparency = 1
            b.TextColor3 = C.textDim
        end
    end
end

local function newCatBtn(def)
    local b = Instance.new("TextButton")
    b.Name = def.name
    b.Size = UDim2.new(1, 0, 0, 34)
    b.BackgroundColor3 = C.sidebar
    b.BorderSizePixel = 0
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.TextColor3 = C.textDim
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Text = "  " .. def.icon .. "   " .. def.name
    b.AutoButtonColor = false
    b.Parent = sidebar
    corner(b, 7)
    local s = stroke(b, C.sidebar, 1, 1)
    b.UIStroke = s
    table.insert(catBtns, b)
    b.MouseButton1Click:Connect(function() switchCat(def.name) end)
end

for _, def in ipairs(CATEGORIES) do newCatBtn(def) end

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
    sc.Parent = cardsScroll
    pad(sc, 0, 0, 0, 0)
    mkList(sc, 6)
    pages[name] = sc
    return sc
end

-- Páginas
newCatBtn -- placeholder to keep line count

-- Aimbot
local aimPage = newPage("Aimbot")
mkHeader(aimPage, "Aimbot — Principal")
mkToggle(aimPage, "Aimbot habilitado", CFG.aim.enabled, function(v) API.setAim(v) end)
mkDropdown(aimPage, "Modo", {"Silent", "Camera", "Both"}, CFG.aim.mode, function(v) API.setMode(v) end)
mkDropdown(aimPage, "Parte do alvo", {"Head", "Torso", "HumanoidRootPart"}, CFG.aim.aim_part, function(v) API.setAimPart(v) end)

mkHeader(aimPage, "Ajuste fino")
mkSlider(aimPage, "FOV (px)", 20, 400, CFG.aim.fov, 1, function(v) API.setFov(v) end)
mkSlider(aimPage, "Distância máxima", 50, 1500, CFG.aim.max_distance, 10, function(v) CFG.aim.max_distance = v; API.saveCfg() end)
mkSlider(aimPage, "Smoothing", 0, 0.95, CFG.aim.smoothing, 0.05, function(v) API.setSmoothing(v) end)
mkSlider(aimPage, "Resolver", 0, 0.20, CFG.aim.resolver, 0.01, function(v) API.setResolver(v) end)

mkHeader(aimPage, "Checks")
mkToggle(aimPage, "Team check", CFG.aim.team_check, function(v) CFG.aim.team_check = v; API.saveCfg() end)
mkToggle(aimPage, "Visibility check", CFG.aim.visibility_check, function(v) CFG.aim.visibility_check = v; API.saveCfg() end)
mkToggle(aimPage, "Predição de movimento", CFG.aim.prediction, function(v) CFG.aim.prediction = v; API.saveCfg() end)

-- ESP
local espPage = newPage("ESP")
mkHeader(espPage, "ESP — Principal")
mkToggle(espPage, "ESP habilitado", CFG.esp.enabled, function(v) API.setESP(v) end)
mkToggle(espPage, "Box", CFG.esp.box, function(v) CFG.esp.box = v; API.saveCfg() end)
mkToggle(espPage, "Health bar", CFG.esp.health_bar, function(v) CFG.esp.health_bar = v; API.saveCfg() end)
mkToggle(espPage, "Nome", CFG.esp.name, function(v) CFG.esp.name = v; API.saveCfg() end)
mkToggle(espPage, "Distância", CFG.esp.distance, function(v) CFG.esp.distance = v; API.saveCfg() end)
mkToggle(espPage, "Level", CFG.esp.level, function(v) CFG.esp.level = v; API.saveCfg() end)
mkToggle(espPage, "Tracer", CFG.esp.tracer, function(v) CFG.esp.tracer = v; API.saveCfg() end)
mkToggle(espPage, "Skeleton", CFG.esp.skeleton, function(v) CFG.esp.skeleton = v; API.saveCfg() end)

mkHeader(espPage, "Alcance")
mkSlider(espPage, "Distância máxima ESP", 200, 3000, CFG.esp.max_distance, 50, function(v) API.setMaxDist(v) end)

-- Config
local cfgPage = newPage("Config")
mkHeader(cfgPage, "Configuração")

local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(1, 0, 0, 38)
saveBtn.BackgroundColor3 = C.surface
saveBtn.BorderSizePixel = 0
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 12
saveBtn.TextColor3 = C.accent
saveBtn.Text = "SALVAR CONFIG"
saveBtn.AutoButtonColor = false
saveBtn.Parent = cfgPage
corner(saveBtn, 8)
stroke(saveBtn, C.accentD, 1)
saveBtn.MouseButton1Click:Connect(function()
    API.saveCfg()
    saveBtn.Text = "SALVO!"
    saveBtn.TextColor3 = C.green
    task.delay(1, function() saveBtn.Text = "SALVAR CONFIG"; saveBtn.TextColor3 = C.accent end)
end)

local kbind = Instance.new("TextLabel")
kbind.Size = UDim2.new(1, 0, 0, 80)
kbind.BackgroundColor3 = C.surface
kbind.BorderSizePixel = 0
kbind.Font = Enum.Font.Gotham
kbind.TextSize = 11
kbind.TextColor3 = C.textDim
kbind.TextWrapped = true
kbind.Text = "\n  Toggle menu: K\n  Toggle ESP: F1\n  Toggle Aimbot: E"
kbind.TextXAlignment = Enum.TextXAlignment.Left
kbind.TextYAlignment = Enum.TextYAlignment.Top
kbind.Active = false
kbind.Parent = cfgPage
corner(kbind, 8)
stroke(kbind, C.border, 1, 0.3)

-- Info
local infoPage = newPage("Info")
mkHeader(infoPage, "Sobre")
local about = Instance.new("TextLabel")
about.Size = UDim2.new(1, 0, 0, 140)
about.BackgroundColor3 = C.surface
about.BorderSizePixel = 0
about.Font = Enum.Font.Gotham
about.TextSize = 11
about.TextColor3 = C.textDim
about.TextWrapped = true
about.Text = "\n  STR1KER v6\n  PvP hub para Blox Fruits\n\n  · Silent Aim + Resolver\n  · ESP completo\n  · Predição de movimento\n  · Config persistente"
about.TextXAlignment = Enum.TextXAlignment.Left
about.TextYAlignment = Enum.TextYAlignment.Top
about.Active = false
about.Parent = infoPage
corner(about, 8)
stroke(about, C.border, 1, 0.3)

-- ═══ COMPORTAMENTO ═══
switchCat("Aimbot")

local dragging, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = win.Position
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
        win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                 startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local minimized = false
local fullSize = UDim2.new(0, 820, 0, 480)
local minSize  = UDim2.new(0, 820, 0, 50)
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    win.Size = minimized and minSize or fullSize
    body.Visible = not minimized
    minBtn.Text = minimized and "+" or "−"
end)

local function openMenu()
    if win.Visible then return end
    win.Visible = true
    scale.Scale = 0.92
    tw(scale, 0.28, { Scale = 1 }, Enum.EasingStyle.Back)
end
local function closeMenu()
    if not win.Visible then return end
    tw(scale, 0.2, { Scale = 0.92 })
    task.delay(0.18, function() win.Visible = false; scale.Scale = 1 end)
end

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
