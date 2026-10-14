--!nocheck
-- ==========================================================================
-- STR1KER MENU v1
-- UI inspirada no Tsuo Hub · conecta na Str1kerAPI
-- ==========================================================================

local LOGO_ID = "rbxassetid://73606056465798"
local API = getgenv().Str1kerAPI
if not API then
    warn("[Menu] Str1kerAPI não encontrada. Carregue o PvP antes.")
    return
end

local CFG = API.getCfg()

local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui      = (gethui and gethui()) or game:GetService("CoreGui")
local LP           = Players.LocalPlayer

-- ------------------------- Paleta -------------------------
local C = {
    bg       = Color3.fromRGB(11, 12, 18),
    sidebar  = Color3.fromRGB(8, 9, 14),
    surface  = Color3.fromRGB(16, 18, 26),
    surface2 = Color3.fromRGB(22, 24, 34),
    accent   = Color3.fromRGB(139, 92, 246),
    accentD  = Color3.fromRGB(60, 40, 110),
    text     = Color3.fromRGB(232, 234, 240),
    textDim  = Color3.fromRGB(120, 128, 150),
    green    = Color3.fromRGB(0, 220, 120),
    red      = Color3.fromRGB(255, 90, 90),
    cyan     = Color3.fromRGB(0, 212, 255),
    stroke   = Color3.fromRGB(28, 31, 48),
}

local function corner(o, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 6); c.Parent = o; return c
end
local function stroke(o, col, th, tr)
    local s = Instance.new("UIStroke"); s.Color = col; s.Thickness = th or 1; s.Transparency = tr or 0; s.Parent = o; return s
end
local function pad(o, t, r, b, l)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, t or 0); p.PaddingRight = UDim.new(0, r or 0)
    p.PaddingBottom = UDim.new(0, b or 0); p.PaddingLeft = UDim.new(0, l or 0)
    p.Parent = o; return p
end
local function mkList(parent, spacing)
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, spacing or 6)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = parent
    return l
end

-- ------------------------- ScreenGui -------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "Str1kerMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 100
gui.Parent = CoreGui

-- ------------------------- Botão toggle (flutuante) -------------------------
local openBtn = Instance.new("ImageButton")
openBtn.Size = UDim2.new(0, 38, 0, 38)
openBtn.Position = UDim2.new(0, 130, 0, 5)
openBtn.BackgroundColor3 = C.bg
openBtn.BorderSizePixel = 0
openBtn.Image = LOGO_ID
openBtn.ScaleType = Enum.ScaleType.Fit
openBtn.AutoButtonColor = false
openBtn.Parent = gui
corner(openBtn, 8)
stroke(openBtn, C.accent, 1.5, 0.3)

-- ------------------------- Janela -------------------------
local win = Instance.new("Frame")
win.Name = "Window"
win.Size = UDim2.new(0, 580, 0, 400)
win.Position = UDim2.new(0.5, -290, 0.5, -200)
win.BackgroundColor3 = C.bg
win.BorderSizePixel = 0
win.ClipsDescendants = true
win.Parent = gui
corner(win, 10)
stroke(win, C.stroke, 1)

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = C.sidebar
header.BorderSizePixel = 0
header.Parent = win

local headerLogo = Instance.new("ImageLabel")
headerLogo.Size = UDim2.new(0, 26, 0, 26)
headerLogo.Position = UDim2.new(0, 12, 0.5, -13)
headerLogo.BackgroundTransparency = 1
headerLogo.Image = LOGO_ID
headerLogo.ScaleType = Enum.ScaleType.Fit
headerLogo.Parent = header

local headerTitle = Instance.new("TextLabel")
headerTitle.Size = UDim2.new(0, 200, 1, 0)
headerTitle.Position = UDim2.new(0, 46, 0, 0)
headerTitle.BackgroundTransparency = 1
headerTitle.Font = Enum.Font.GothamBold
headerTitle.TextSize = 14
headerTitle.TextColor3 = C.accent
headerTitle.TextXAlignment = Enum.TextXAlignment.Left
headerTitle.Text = "STR1KER"
headerTitle.Parent = header

-- Botões header
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 26, 0, 26)
minBtn.Position = UDim2.new(1, -66, 0.5, -13)
minBtn.BackgroundColor3 = C.surface
minBtn.BorderSizePixel = 0
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 14
minBtn.TextColor3 = C.textDim
minBtn.Text = "−"
minBtn.Parent = header
corner(minBtn, 4)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -34, 0.5, -13)
closeBtn.BackgroundColor3 = C.surface
closeBtn.BorderSizePixel = 0
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13
closeBtn.TextColor3 = C.red
closeBtn.Text = "×"
closeBtn.Parent = header
corner(closeBtn, 4)

-- ------------------------- Sidebar -------------------------
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 130, 1, -40)
sidebar.Position = UDim2.new(0, 0, 0, 40)
sidebar.BackgroundColor3 = C.sidebar
sidebar.BorderSizePixel = 0
sidebar.Parent = win

local sidebarList = mkList(sidebar, 4)
pad(sidebar, 8, 8, 8, 8)

-- ------------------------- Área de conteúdo -------------------------
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -130, 1, -40)
content.Position = UDim2.new(0, 130, 0, 40)
content.BackgroundColor3 = C.bg
content.BorderSizePixel = 0
content.Parent = win

-- Tab pages (containers)
local pages = {}
local tabOrder = {}

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
    mkList(sc, 6)
    pages[name] = sc
    return sc
end

local function switchTab(name)
    for tabName, page in pairs(pages) do
        page.Visible = (tabName == name)
    end
    for _, btn in ipairs(tabOrder) do
        if btn.Name == name then
            btn.BackgroundColor3 = C.surface
            btn.UIStroke.Color = C.accent
            btn.TextColor3 = C.accent
        else
            btn.BackgroundColor3 = C.sidebar
            btn.UIStroke.Color = C.sidebar
            btn.TextColor3 = C.textDim
        end
    end
end

local function newTabButton(name, label)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Size = UDim2.new(1, 0, 0, 34)
    b.BackgroundColor3 = C.sidebar
    b.BorderSizePixel = 0
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.TextColor3 = C.textDim
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Text = "  " .. label
    b.AutoButtonColor = false
    b.Parent = sidebar
    corner(b, 6)
    stroke(b, C.sidebar, 1)
    table.insert(tabOrder, b)
    b.MouseButton1Click:Connect(function() switchTab(name) end)
    return b
end

-- ------------------------- Componentes -------------------------

-- Section header (título de grupo dentro da tab)
local function sectionHeader(page, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextColor3 = C.textDim
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = string.upper(text)
    lbl.Parent = page
    return lbl
end

-- Row base (frame com título à esquerda + espaço para controle à direita)
local function rowBase(page, label, desc)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, desc and 44 or 34)
    row.BackgroundColor3 = C.surface
    row.BorderSizePixel = 0
    row.Parent = page
    corner(row, 6)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -90, 0, 18)
    title.Position = UDim2.new(0, 12, 0, desc and 6 or 8)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.TextColor3 = C.text
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = label
    title.Parent = row

    if desc then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1, -24, 0, 14)
        d.Position = UDim2.new(0, 12, 0, 24)
        d.BackgroundTransparency = 1
        d.Font = Enum.Font.Gotham
        d.TextSize = 10
        d.TextColor3 = C.textDim
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Text = desc
        d.Parent = row
    end
    return row
end

-- Toggle
local function toggle(page, label, initial, callback)
    local row = rowBase(page, label)
    local state = initial == true

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 36, 0, 18)
    bg.Position = UDim2.new(1, -48, 0.5, -9)
    bg.BackgroundColor3 = state and C.accent or C.surface2
    bg.BorderSizePixel = 0
    bg.Parent = row
    corner(bg, 99)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = bg
    corner(knob, 99)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = row

    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(bg, TweenInfo.new(0.15), {
            BackgroundColor3 = state and C.accent or C.surface2
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        }):Play()
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

-- Slider
local function slider(page, label, minV, maxV, initial, step, callback)
    step = step or 0.01
    local row = rowBase(page, label)
    row.Size = UDim2.new(1, 0, 0, 52)

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 60, 0, 18)
    valLbl.Position = UDim2.new(1, -70, 0, 8)
    valLbl.BackgroundTransparency = 1
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 12
    valLbl.TextColor3 = C.accent
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Text = tostring(initial)
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
    fill.Parent = bar
    corner(fill, 99)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new((initial - minV) / (maxV - minV), 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    knob.Parent = bar
    corner(knob, 99)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Dropdown
local function dropdown(page, label, options, initial, callback)
    local row = rowBase(page, label)
    local currentIdx = 1
    for i, v in ipairs(options) do
        if v == initial then currentIdx = i break end
    end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 110, 0, 24)
    btn.Position = UDim2.new(1, -122, 0.5, -12)
    btn.BackgroundColor3 = C.surface2
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = C.text
    btn.Text = options[currentIdx] .. " ▾"
    btn.Parent = row
    corner(btn, 4)

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
        listFrame.Size = UDim2.new(0, 140, 0, #options * 24 + 8)
        listFrame.Position = UDim2.new(1, -152, 0, 34)
        listFrame.BackgroundColor3 = C.surface
        listFrame.BorderSizePixel = 0
        listFrame.ZIndex = 5
        listFrame.Parent = row.Parent
        corner(listFrame, 6)
        stroke(listFrame, C.accent, 1, 0.5)
        pad(listFrame, 4, 4, 4, 4)
        mkList(listFrame, 2)

        for i, opt in ipairs(options) do
            local o = Instance.new("TextButton")
            o.Size = UDim2.new(1, 0, 0, 22)
            o.BackgroundColor3 = (i == currentIdx) and C.accentD or C.surface
            o.BorderSizePixel = 0
            o.Font = Enum.Font.Gotham
            o.TextSize = 11
            o.TextColor3 = C.text
            o.Text = opt
            o.TextXAlignment = Enum.TextXAlignment.Left
            o.Parent = listFrame
            corner(o, 4)
            pad(o, 0, 0, 0, 8)
            o.MouseButton1Click:Connect(function()
                currentIdx = i
                btn.Text = opt .. " ▾"
                if callback then callback(opt) end
                closeList()
            end)
        end
    end)
end

-- ------------------------- Construção das tabs -------------------------

-- AIMBOT
newTabButton("Aimbot", "Aimbot")
local aimPage = newPage("Aimbot")

sectionHeader(aimPage, "Aimbot · principal")
toggle(aimPage, "Aimbot habilitado", CFG.aim.enabled, function(v) API.setAim(v) end)
dropdown(aimPage, "Modo", { "Silent", "Camera", "Both" }, CFG.aim.mode, function(v) API.setMode(v) end)
dropdown(aimPage, "Parte do alvo", { "Head", "Torso", "HumanoidRootPart" }, CFG.aim.aim_part, function(v) API.setAimPart(v) end)

sectionHeader(aimPage, "Ajuste fino")
slider(aimPage, "FOV (px)", 20, 400, CFG.aim.fov, 1, function(v) API.setFov(v) end)
slider(aimPage, "Distância máxima", 50, 1500, CFG.aim.max_distance, 10, function(v) CFG.aim.max_distance = v API.saveCfg() end)
slider(aimPage, "Smoothing", 0, 0.95, CFG.aim.smoothing, 0.05, function(v) API.setSmoothing(v) end)
slider(aimPage, "Resolver", 0, 0.20, CFG.aim.resolver, 0.01, function(v) API.setResolver(v) end)

sectionHeader(aimPage, "Checks")
toggle(aimPage, "Team check", CFG.aim.team_check, function(v) CFG.aim.team_check = v API.saveCfg() end)
toggle(aimPage, "Visibility check", CFG.aim.visibility_check, function(v) CFG.aim.visibility_check = v API.saveCfg() end)
toggle(aimPage, "Predição de movimento", CFG.aim.prediction, function(v) CFG.aim.prediction = v API.saveCfg() end)

-- ESP
newTabButton("ESP", "ESP")
local espPage = newPage("ESP")

sectionHeader(espPage, "ESP · principal")
toggle(espPage, "ESP habilitado", CFG.esp.enabled, function(v) API.setESP(v) end)
toggle(espPage, "Box", CFG.esp.box, function(v) CFG.esp.box = v API.saveCfg() end)
toggle(espPage, "Health bar", CFG.esp.health_bar, function(v) CFG.esp.health_bar = v API.saveCfg() end)
toggle(espPage, "Nome", CFG.esp.name, function(v) CFG.esp.name = v API.saveCfg() end)
toggle(espPage, "Distância", CFG.esp.distance, function(v) CFG.esp.distance = v API.saveCfg() end)
toggle(espPage, "Level", CFG.esp.level, function(v) CFG.esp.level = v API.saveCfg() end)
toggle(espPage, "Tracer", CFG.esp.tracer, function(v) CFG.esp.tracer = v API.saveCfg() end)
toggle(espPage, "Skeleton", CFG.esp.skeleton, function(v) CFG.esp.skeleton = v API.saveCfg() end)

sectionHeader(espPage, "Alcance")
slider(espPage, "Distância máxima ESP", 200, 3000, CFG.esp.max_distance, 50, function(v) API.setMaxDist(v) end)

-- CONFIG
newTabButton("Config", "Config")
local cfgPage = newPage("Config")

sectionHeader(cfgPage, "Configuração")

local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(1, 0, 0, 34)
saveBtn.BackgroundColor3 = C.surface
saveBtn.BorderSizePixel = 0
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 12
saveBtn.TextColor3 = C.accent
saveBtn.Text = "Salvar config"
saveBtn.Parent = cfgPage
corner(saveBtn, 6)
stroke(saveBtn, C.accent, 1, 0.5)
saveBtn.MouseButton1Click:Connect(function()
    API.saveCfg()
    saveBtn.Text = "Salvo!"
    task.delay(1, function() saveBtn.Text = "Salvar config" end)
end)

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, 0, 0, 60)
info.BackgroundColor3 = C.surface
info.BorderSizePixel = 0
info.Font = Enum.Font.Gotham
info.TextSize = 11
info.TextColor3 = C.textDim
info.TextWrapped = true
info.Text = "\n  Toggle menu: K\n  Toggle ESP: F1\n  Toggle Aimbot: E (padrão)\n"
info.TextXAlignment = Enum.TextXAlignment.Left
info.Parent = cfgPage
corner(info, 6)

-- INFO
newTabButton("Info", "Info")
local infoPage = newPage("Info")

sectionHeader(infoPage, "Sobre")

local about = Instance.new("TextLabel")
about.Size = UDim2.new(1, 0, 0, 120)
about.BackgroundColor3 = C.surface
about.BorderSizePixel = 0
about.Font = Enum.Font.Gotham
about.TextSize = 11
about.TextColor3 = C.textDim
about.TextWrapped = true
about.Text = "\n  STR1KER v3\n  PvP hub para Blox Fruits\n\n  Features:\n  · Silent Aim\n  · ESP completo\n  · Resolver\n  · Predição\n\n  discord.gg/str1ker"
about.TextXAlignment = Enum.TextXAlignment.Left
about.Parent = infoPage
corner(about, 6)

-- Mostra a tab Aimbot por padrão
switchTab("Aimbot")

-- ------------------------- Drag / minimize / close -------------------------
local dragging, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = win.Position
    end
end)
header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Minimize
local minimized = false
local fullSize = UDim2.new(0, 580, 0, 400)
local minSize = UDim2.new(0, 580, 0, 40)
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    win.Size = minimized and minSize or fullSize
    sidebar.Visible = not minimized
    content.Visible = not minimized
    minBtn.Text = minimized and "+" or "−"
end)

-- Close
closeBtn.MouseButton1Click:Connect(function()
    win.Visible = false
end)

-- Toggle via botão flutuante ou keybind
local function toggleMenu()
    win.Visible = not 
