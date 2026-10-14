--!nocheck
-- ==========================================================================
-- STR1KER OWNER PANEL v4 — logo em tudo + presets + listar keys
-- ==========================================================================

local OWNER_NAME   = "ws_pix"
local BACKEND_URL  = "https://str1ker-backend.up.railway.app"
local ADMIN_SECRET = "C:f1I=)60({L"
local LOGO_ID      = "rbxassetid://135682258411683"

local Players = game:GetService("Players")
local Http    = game:GetService("HttpService")
local UIS     = game:GetService("UserInputService")
local Tween   = game:GetService("TweenService")
local LP      = Players.LocalPlayer

if LP.Name ~= OWNER_NAME then return end

local httpReq = (syn and syn.request) or (http and http.request)
             or http_request or request
if not httpReq then warn("[Owner] sem request()") return end

-- ═══════════════════════════════════════════════════════════════════════════
-- PALETA
-- ═══════════════════════════════════════════════════════════════════════════
local C = {
    bg       = Color3.fromRGB(8, 16, 28),
    header   = Color3.fromRGB(10, 20, 36),
    surface  = Color3.fromRGB(22, 35, 59),
    surface2 = Color3.fromRGB(15, 39, 68),
    accent   = Color3.fromRGB(59, 130, 246),
    accentD  = Color3.fromRGB(30, 64, 175),
    accentL  = Color3.fromRGB(96, 165, 250),
    cyan     = Color3.fromRGB(6, 182, 212),
    text     = Color3.fromRGB(229, 234, 243),
    textDim  = Color3.fromRGB(107, 122, 153),
    green    = Color3.fromRGB(16, 185, 129),
    red      = Color3.fromRGB(239, 68, 68),
    yellow   = Color3.fromRGB(245, 158, 11),
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
    local t = Tween:Create(o, TweenInfo.new(time, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    t:Play(); return t
end

-- ═══════════════════════════════════════════════════════════════════════════
-- API
-- ═══════════════════════════════════════════════════════════════════════════
local function api(path, method, body)
    local ok, res = pcall(httpReq, {
        Url = BACKEND_URL .. path,
        Method = method or "GET",
        Headers = {
            ["Content-Type"]   = "application/json",
            ["x-admin-secret"] = ADMIN_SECRET,
        },
        Body = body and Http:JSONEncode(body) or nil,
    })
    if not ok or not res then return nil, "rede offline" end
    local dec; pcall(function() dec = Http:JSONDecode(res.Body) end)
    if res.StatusCode == 401 then return nil, "secret inválido (401)" end
    if res.StatusCode == 404 then return nil, "endpoint não existe (404)" end
    if res.StatusCode ~= 200 then return nil, "erro " .. tostring(res.StatusCode) end
    if not dec then return nil, "resposta inválida" end
    return dec, nil
end

-- ═══════════════════════════════════════════════════════════════════════════
-- GUI
-- ═══════════════════════════════════════════════════════════════════════════
local parentGui = (gethui and gethui()) or game:GetService("CoreGui")

local gui = Instance.new("ScreenGui")
gui.Name = "Str1kerOwnerPanel"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999
gui.Parent = parentGui

-- Botão flutuante (com glow + logo)
local btnGlow = Instance.new("Frame")
btnGlow.Size = UDim2.new(0, 46, 0, 46)
btnGlow.Position = UDim2.new(0, 82, 0, 1)
btnGlow.BackgroundColor3 = C.accent
btnGlow.BackgroundTransparency = 0.75
btnGlow.BorderSizePixel = 0
btnGlow.Active = false
btnGlow.ZIndex = 0
btnGlow.Parent = gui
corner(btnGlow, 12)

task.spawn(function()
    while btnGlow.Parent do
        tw(btnGlow, 2, { BackgroundTransparency = 0.5 }, Enum.EasingStyle.Sine)
        task.wait(2); if not btnGlow.Parent then break end
        tw(btnGlow, 2, { BackgroundTransparency = 0.75 }, Enum.EasingStyle.Sine)
        task.wait(2)
    end
end)

local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 38, 0, 38)
openBtn.Position = UDim2.new(0, 86, 0, 5)
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

local openLogo = Instance.new("ImageLabel")
openLogo.Size = UDim2.new(1, 0, 1, 0)
openLogo.BackgroundTransparency = 1
openLogo.Image = LOGO_ID
openLogo.ScaleType = Enum.ScaleType.Fit
openLogo.ZIndex = 3
openLogo.Active = false
openLogo.Parent = openBtn
corner(openLogo, 8)

-- Painel
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.new(0, 460, 0, 0)
panel.Position = UDim2.new(0, 8, 0, 50)
panel.BackgroundColor3 = C.bg
panel.BorderSizePixel = 0
panel.AutomaticSize = Enum.AutomaticSize.Y
panel.Visible = false
panel.Parent = gui
corner(panel, 14)
stroke(panel, C.border, 1)

local scale = Instance.new("UIScale")
scale.Scale = 1
scale.Parent = panel

-- Linha topo
local topLine = Instance.new("Frame")
topLine.Size = UDim2.new(1, -56, 0, 2)
topLine.Position = UDim2.new(0, 28, 0, 0)
topLine.BackgroundColor3 = C.accent
topLine.BorderSizePixel = 0
topLine.ZIndex = 3
topLine.Parent = panel
corner(topLine, 1)
local topGrad = Instance.new("UIGradient")
topGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.5, 0.3),
    NumberSequenceKeypoint.new(1, 1),
})
topGrad.Parent = topLine

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 60)
header.BackgroundColor3 = C.header
header.BorderSizePixel = 0
header.Parent = panel
corner(header, 14)

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 14)
headerFix.Position = UDim2.new(0, 0, 1, -14)
headerFix.BackgroundColor3 = C.header
headerFix.BorderSizePixel = 0
headerFix.Active = false
headerFix.Parent = header

-- Logo header (com glow pulsante)
local logoWrap = Instance.new("Frame")
logoWrap.Size = UDim2.new(0, 40, 0, 40)
logoWrap.Position = UDim2.new(0, 14, 0.5, -20)
logoWrap.BackgroundTransparency = 1
logoWrap.Parent = header

local logoGlow = Instance.new("Frame")
logoGlow.Size = UDim2.new(1, 10, 1, 10)
logoGlow.Position = UDim2.new(0, -5, 0, -5)
logoGlow.BackgroundColor3 = C.accent
logoGlow.BackgroundTransparency = 0.7
logoGlow.BorderSizePixel = 0
logoGlow.ZIndex = 1
logoGlow.Active = false
logoGlow.Parent = logoWrap
corner(logoGlow, 14)
task.spawn(function()
    while logoGlow.Parent do
        tw(logoGlow, 1.25, { BackgroundTransparency = 0.45, Size = UDim2.new(1, 16, 1, 16), Position = UDim2.new(0, -8, 0, -8) }, Enum.EasingStyle.Sine)
        task.wait(1.25); if not logoGlow.Parent then break end
        tw(logoGlow, 1.25, { BackgroundTransparency = 0.75, Size = UDim2.new(1, 10, 1, 10), Position = UDim2.new(0, -5, 0, -5) }, Enum.EasingStyle.Sine)
        task.wait(1.25)
    end
end)

local logoBg = Instance.new("Frame")
logoBg.Size = UDim2.new(1, 0, 1, 0)
logoBg.BackgroundColor3 = C.accent
logoBg.BorderSizePixel = 0
logoBg.Active = false
logoBg.ZIndex = 2
logoBg.Parent = logoWrap
corner(logoBg, 11)

local logoImg = Instance.new("ImageLabel")
logoImg.Size = UDim2.new(1, 0, 1, 0)
logoImg.BackgroundTransparency = 1
logoImg.Image = LOGO_ID
logoImg.ScaleType = Enum.ScaleType.Fit
logoImg.ZIndex = 3
logoImg.Active = false
logoImg.Parent = logoWrap
corner(logoImg, 11)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -140, 0, 18)
title.Position = UDim2.new(0, 64, 0, 12)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = C.text
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "Str1ker · Owner"
title.Active = false
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -140, 0, 12)
subtitle.Position = UDim2.new(0, 64, 0, 32)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 9
subtitle.TextColor3 = C.textDim
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Text = "PAINEL ADMINISTRATIVO"
subtitle.Active = false
subtitle.Parent = header

-- Badge PROTECTED
local badge = Instance.new("Frame")
badge.Size = UDim2.new(0, 90, 0, 22)
badge.Position = UDim2.new(1, -130, 0, 20)
badge.BackgroundColor3 = C.green
badge.BackgroundTransparency = 0.92
badge.BorderSizePixel = 0
badge.Active = false
badge.Parent = header
corner(badge, 11)
stroke(badge, C.green, 1, 0.7)

local badgeDot = Instance.new("Frame")
badgeDot.Size = UDim2.new(0, 6, 0, 6)
badgeDot.Position = UDim2.new(0, 10, 0.5, -3)
badgeDot.BackgroundColor3 = C.green
badgeDot.BorderSizePixel = 0
badgeDot.Active = false
badgeDot.Parent = badge
corner(badgeDot, 99)
task.spawn(function()
    while badgeDot.Parent do
        tw(badgeDot, 0.9, { BackgroundTransparency = 0.4 }, Enum.EasingStyle.Sine)
        task.wait(0.9); if not badgeDot.Parent then break end
        tw(badgeDot, 0.9, { BackgroundTransparency = 0 }, Enum.EasingStyle.Sine)
        task.wait(0.9)
    end
end)

local badgeText = Instance.new("TextLabel")
badgeText.Size = UDim2.new(1, -22, 1, 0)
badgeText.Position = UDim2.new(0, 20, 0, 0)
badgeText.BackgroundTransparency = 1
badgeText.Font = Enum.Font.GothamBold
badgeText.TextSize = 9
badgeText.TextColor3 = C.green
badgeText.TextXAlignment = Enum.TextXAlignment.Left
badgeText.Text = "PROTECTED"
badgeText.Active = false
badgeText.Parent = badge

-- Close
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -34, 0, 17)
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
closeBtn.MouseEnter:Connect(function()
    tw(closeBtn, 0.2, { BackgroundTransparency = 0.75 })
end)
closeBtn.MouseLeave:Connect(function()
    tw(closeBtn, 0.2, { BackgroundTransparency = 0.9 })
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- TABS
-- ═══════════════════════════════════════════════════════════════════════════
local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.new(1, 0, 0, 42)
tabsFrame.BackgroundColor3 = C.header
tabsFrame.BorderSizePixel = 0
tabsFrame.Parent = panel

local tabGen = Instance.new("TextButton")
tabGen.Size = UDim2.new(0.5, 0, 1, 0)
tabGen.BackgroundTransparency = 1
tabGen.BorderSizePixel = 0
tabGen.Font = Enum.Font.GothamBold
tabGen.TextSize = 12
tabGen.TextColor3 = C.accent
tabGen.Text = "Gerar Keys"
tabGen.AutoButtonColor = false
tabGen.Parent = tabsFrame

local tabList = Instance.new("TextButton")
tabList.Size = UDim2.new(0.5, 0, 1, 0)
tabList.Position = UDim2.new(0.5, 0, 0, 0)
tabList.BackgroundTransparency = 1
tabList.BorderSizePixel = 0
tabList.Font = Enum.Font.GothamBold
tabList.TextSize = 12
tabList.TextColor3 = C.textDim
tabList.Text = "Listar Keys"
tabList.AutoButtonColor = false
tabList.Parent = tabsFrame

local tabLine = Instance.new("Frame")
tabLine.Size = UDim2.new(0.5, 0, 0, 2)
tabLine.Position = UDim2.new(0, 0, 1, -2)
tabLine.BackgroundColor3 = C.accent
tabLine.BorderSizePixel = 0
tabLine.Active = false
tabLine.Parent = tabsFrame
corner(tabLine, 1)

local lineGlow = Instance.new("Frame")
lineGlow.Size = UDim2.new(1, 0, 0, 6)
lineGlow.Position = UDim2.new(0, 0, 0, -2)
lineGlow.BackgroundColor3 = C.accent
lineGlow.BackgroundTransparency = 0.7
lineGlow.BorderSizePixel = 0
lineGlow.Active = false
lineGlow.Parent = tabLine
corner(lineGlow, 3)

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 0, 0)
contentFrame.BackgroundTransparency = 1
contentFrame.AutomaticSize = Enum.AutomaticSize.Y
contentFrame.Parent = panel

-- ═══════════════════════════════════════════════════════════════════════════
-- PÁGINA GERAR
-- ═══════════════════════════════════════════════════════════════════════════
local genPage = Instance.new("Frame")
genPage.Size = UDim2.new(1, 0, 0, 0)
genPage.BackgroundTransparency = 1
genPage.AutomaticSize = Enum.AutomaticSize.Y
genPage.Parent = contentFrame
pad(genPage, 16, 16, 16, 16)
mkList(genPage, 12)

local durLabel = Instance.new("TextLabel")
durLabel.Size = UDim2.new(1, 0, 0, 14)
durLabel.BackgroundTransparency = 1
durLabel.Font = Enum.Font.GothamBold
durLabel.TextSize = 10
durLabel.TextColor3 = C.textDim
durLabel.TextXAlignment = Enum.TextXAlignment.Left
durLabel.Text = "DURAÇÃO"
durLabel.LayoutOrder = 1
durLabel.Active = false
durLabel.Parent = genPage

-- Presets
local presetState = { selected = 3 }
local presets = {
    { label = "1h",  sub = "hora",     hours = 1 },
    { label = "12h", sub = "meio dia", hours = 12 },
    { label = "1d",  sub = "dia",      hours = 24 },
    { label = "3d",  sub = "3 dias",   hours = 24 * 3 },
    { label = "7d",  sub = "semana",   hours = 24 * 7 },
    { label = "30d", sub = "mês",      hours = 24 * 30 },
}
local presetRefs = {}

local function makePresetRow(order)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 62)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order
    row.Parent = genPage
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = row
    return row
end

local function makePresetButton(parent, order, idx, def)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.33, -6, 1, 0)
    btn.BackgroundColor3 = C.surface
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.LayoutOrder = order
    btn.ZIndex = 5
    btn.Parent = parent
    corner(btn, 9)
    local s = stroke(btn, C.border, 1)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 12)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 15
    label.TextColor3 = C.text
    label.Text = def.label
    label.Active = false
    label.ZIndex = 6
    label.Parent = btn

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, 0, 0, 12)
    sub.Position = UDim2.new(0, 0, 0, 34)
    sub.BackgroundTransparency = 1
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 9
    sub.TextColor3 = C.textDim
    sub.Text = def.sub
    sub.Active = false
    sub.ZIndex = 6
    sub.Parent = btn

    presetRefs[idx] = { btn = btn, stroke = s, label = label, sub = sub, def = def }
    return btn
end

local row1 = makePresetRow(2)
makePresetButton(row1, 1, 1, presets[1])
makePresetButton(row1, 2, 2, presets[2])
makePresetButton(row1, 3, 3, presets[3])

local row2 = makePresetRow(3)
makePresetButton(row2, 1, 4, presets[4])
makePresetButton(row2, 2, 5, presets[5])
makePresetButton(row2, 3, 6, presets[6])

-- Custom
local customBtn = Instance.new("TextButton")
customBtn.Size = UDim2.new(1, 0, 0, 46)
customBtn.BackgroundColor3 = C.surface
customBtn.BorderSizePixel = 0
customBtn.Text = ""
customBtn.AutoButtonColor = false
customBtn.LayoutOrder = 4
customBtn.ZIndex = 5
customBtn.Parent = genPage
corner(customBtn, 9)
local customStroke = stroke(customBtn, C.border, 1)

local customLabel = Instance.new("TextLabel")
customLabel.Size = UDim2.new(1, 0, 0, 18)
customLabel.Position = UDim2.new(0, 0, 0, 8)
customLabel.BackgroundTransparency = 1
customLabel.Font = Enum.Font.GothamBold
customLabel.TextSize = 13
customLabel.TextColor3 = C.text
customLabel.Text = "Custom"
customLabel.Active = false
customLabel.ZIndex = 6
customLabel.Parent = customBtn

local customSub = Instance.new("TextLabel")
customSub.Size = UDim2.new(1, 0, 0, 12)
customSub.Position = UDim2.new(0, 0, 0, 26)
customSub.BackgroundTransparency = 1
customSub.Font = Enum.Font.Gotham
customSub.TextSize = 9
customSub.TextColor3 = C.textDim
customSub.Text = "definir manualmente"
customSub.Active = false
customSub.ZIndex = 6
customSub.Parent = customBtn

presetRefs[99] = { btn = customBtn, stroke = customStroke, label = customLabel, sub = customSub,
                   def = { label = "Custom", sub = "definir manualmente" } }

-- Custom box
local customBox = Instance.new("Frame")
customBox.Size = UDim2.new(1, 0, 0, 0)
customBox.BackgroundTransparency = 1
customBox.ClipsDescendants = true
customBox.LayoutOrder = 5
customBox.Parent = genPage

local customBoxInner = Instance.new("Frame")
customBoxInner.Size = UDim2.new(1, 0, 0, 44)
customBoxInner.BackgroundTransparency = 1
customBoxInner.Parent = customBox

local customQty = Instance.new("TextBox")
customQty.Size = UDim2.new(0.32, -4, 1, 0)
customQty.Position = UDim2.new(0, 0, 0, 0)
customQty.BackgroundColor3 = C.surface
customQty.BorderSizePixel = 0
customQty.Text = "5"
customQty.PlaceholderText = "Qtd"
customQty.TextColor3 = C.text
customQty.Font = Enum.Font.GothamBold
customQty.TextSize = 13
customQty.ClearTextOnFocus = false
customQty.Parent = customBoxInner
corner(customQty, 7)
stroke(customQty, C.border, 1)

local customUnit = Instance.new("TextButton")
customUnit.Size = UDim2.new(0.68, -4, 1, 0)
customUnit.Position = UDim2.new(0.32, 0, 0, 0)
customUnit.BackgroundColor3 = C.surface
customUnit.BorderSizePixel = 0
customUnit.Font = Enum.Font.GothamBold
customUnit.TextSize = 12
customUnit.TextColor3 = C.text
customUnit.Text = "Dias ▾"
customUnit.AutoButtonColor = false
customUnit.Parent = customBoxInner
corner(customUnit, 7)
stroke(customUnit, C.border, 1)

local customUnits = {
    { label = "Horas",   h = 1 },
    { label = "Dias",    h = 24 },
    { label = "Semanas", h = 24 * 7 },
    { label = "Meses",   h = 24 * 30 },
}
local customUnitIdx = 2
customUnit.MouseButton1Click:Connect(function()
    customUnitIdx = customUnitIdx % #customUnits + 1
    customUnit.Text = customUnits[customUnitIdx].label .. " ▾"
end)

local function selectPreset(idx)
    presetState.selected = idx
    for i, ref in pairs(presetRefs) do
        if i == idx then
            tw(ref.btn, 0.25, { BackgroundColor3 = C.accent }, Enum.EasingStyle.Back)
            ref.stroke.Color = C.accentL
            ref.label.TextColor3 = Color3.new(1, 1, 1)
            ref.sub.TextColor3 = Color3.fromRGB(200, 220, 255)
        else
            tw(ref.btn, 0.2, { BackgroundColor3 = C.surface })
            ref.stroke.Color = C.border
            ref.label.TextColor3 = C.text
            ref.sub.TextColor3 = C.textDim
        end
    end
    local targetH = (idx == 99) and 52 or 0
    tw(customBox, 0.3, { Size = UDim2.new(1, 0, 0, targetH) }, Enum.EasingStyle.Quart)
end

for i = 1, #presets do
    local idx = i
    presetRefs[i].btn.MouseButton1Click:Connect(function() selectPreset(idx) end)
end
customBtn.MouseButton1Click:Connect(function() selectPreset(99) end)

-- Quantidade
local qtyLabel = Instance.new("TextLabel")
qtyLabel.Size = UDim2.new(1, 0, 0, 14)
qtyLabel.BackgroundTransparency = 1
qtyLabel.Font = Enum.Font.GothamBold
qtyLabel.TextSize = 10
qtyLabel.TextColor3 = C.textDim
qtyLabel.TextXAlignment = Enum.TextXAlignment.Left
qtyLabel.Text = "QUANTIDADE"
qtyLabel.LayoutOrder = 6
qtyLabel.Active = false
qtyLabel.Parent = genPage

local qtyFrame = Instance.new("Frame")
qtyFrame.Size = UDim2.new(1, 0, 0, 42)
qtyFrame.BackgroundTransparency = 1
qtyFrame.LayoutOrder = 7
qtyFrame.Parent = genPage

local countBox = Instance.new("TextBox")
countBox.Size = UDim2.new(1, 0, 1, 0)
countBox.BackgroundColor3 = C.surface
countBox.BorderSizePixel = 0
countBox.Text = "1"
countBox.PlaceholderText = "Nº de keys"
countBox.TextColor3 = C.text
countBox.Font = Enum.Font.GothamBold
countBox.TextSize = 13
countBox.ClearTextOnFocus = false
countBox.Parent = qtyFrame
corner(countBox, 7)
stroke(countBox, C.border, 1)

-- Botão gerar
local genBtn = Instance.new("TextButton")
genBtn.Size = UDim2.new(1, 0, 0, 44)
genBtn.BackgroundColor3 = C.accentD
genBtn.BorderSizePixel = 0
genBtn.Font = Enum.Font.GothamBold
genBtn.TextSize = 13
genBtn.TextColor3 = C.text
genBtn.Text = "GERAR KEYS"
genBtn.AutoButtonColor = false
genBtn.ClipsDescendants = true
genBtn.LayoutOrder = 8
genBtn.ZIndex = 5
genBtn.Parent = genPage
corner(genBtn, 9)
stroke(genBtn, C.accent, 1)

local genGrad = Instance.new("UIGradient")
genGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.accentD),
    ColorSequenceKeypoint.new(1, C.accent),
})
genGrad.Rotation = 135
genGrad.Parent = genBtn

local shine = Instance.new("Frame")
shine.Size = UDim2.new(0, 80, 1, 0)
shine.Position = UDim2.new(0, -80, 0, 0)
shine.BackgroundColor3 = Color3.new(1, 1, 1)
shine.BackgroundTransparency = 0.88
shine.BorderSizePixel = 0
shine.Active = false
shine.ZIndex = 6
shine.Parent = genBtn

local shineGrad = Instance.new("UIGradient")
shineGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.5, 0.2),
    NumberSequenceKeypoint.new(1, 1),
})
shineGrad.Parent = shine

local function sweepShine()
    shine.Position = UDim2.new(0, -80, 0, 0)
    tw(shine, 0.65, { Position = UDim2.new(1, 0, 0, 0) }, Enum.EasingStyle.Quad)
end

genBtn.MouseEnter:Connect(function()
    tw(genBtn, 0.2, { Size = UDim2.new(1, 0, 0, 46) }, Enum.EasingStyle.Back)
    sweepShine()
end)
genBtn.MouseLeave:Connect(function()
    tw(genBtn, 0.2, { Size = UDim2.new(1, 0, 0, 44) }, Enum.EasingStyle.Quad)
end)

-- Resultado
local genResult = Instance.new("ScrollingFrame")
genResult.Size = UDim2.new(1, 0, 0, 0)
genResult.BackgroundColor3 = C.header
genResult.BorderSizePixel = 0
genResult.AutomaticCanvasSize = Enum.AutomaticSize.Y
genResult.CanvasSize = UDim2.new(0, 0, 0, 0)
genResult.ScrollBarThickness = 3
genResult.ScrollBarImageColor3 = C.accent
genResult.AutomaticSize = Enum.AutomaticSize.Y
genResult.LayoutOrder = 9
genResult.MinSize = UDim2.new(0, 0, 0, 60)
genResult.Parent = genPage
corner(genResult, 9)
stroke(genResult, C.border, 1)
pad(genResult, 8, 8, 8, 8)
mkList(genResult, 7)

local genStatus = Instance.new("Frame")
genStatus.Size = UDim2.new(1, 0, 0, 18)
genStatus.BackgroundTransparency = 1
genStatus.LayoutOrder = 10
genStatus.Parent = genPage

local genDot = Instance.new("Frame")
genDot.Size = UDim2.new(0, 6, 0, 6)
genDot.Position = UDim2.new(0, 0, 0.5, -3)
genDot.BackgroundColor3 = C.textDim
genDot.BorderSizePixel = 0
genDot.Active = false
genDot.Parent = genStatus
corner(genDot, 99)

local genStatusLbl = Instance.new("TextLabel")
genStatusLbl.Size = UDim2.new(1, -14, 1, 0)
genStatusLbl.Position = UDim2.new(0, 14, 0, 0)
genStatusLbl.BackgroundTransparency = 1
genStatusLbl.Font = Enum.Font.Gotham
genStatusLbl.TextSize = 11
genStatusLbl.TextColor3 = C.textDim
genStatusLbl.TextXAlignment = Enum.TextXAlignment.Left
genStatusLbl.Text = ""
genStatusLbl.Active = false
genStatusLbl.Parent = genStatus

-- ═══════════════════════════════════════════════════════════════════════════
-- PÁGINA LISTAR
-- ═══════════════════════════════════════════════════════════════════════════
local listPage = Instance.new("Frame")
listPage.Size = UDim2.new(1, 0, 0, 0)
listPage.BackgroundTransparency = 1
listPage.AutomaticSize = Enum.AutomaticSize.Y
listPage.Visible = false
listPage.Parent = contentFrame
pad(listPage, 16, 16, 16, 16)
mkList(listPage, 12)

local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(1, 0, 0, 38)
refreshBtn.BackgroundColor3 = C.surface
refreshBtn.BorderSizePixel = 0
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = 12
refreshBtn.TextColor3 = C.accent
refreshBtn.Text = "RECARREGAR LISTA"
refreshBtn.AutoButtonColor = false
refreshBtn.Parent = listPage
corner(refreshBtn, 8)
stroke(refreshBtn, C.border, 1)

refreshBtn.MouseEnter:Connect(function() tw(refreshBtn, 0.15, { BackgroundColor3 = C.surface2 }) end)
refreshBtn.MouseLeave:Connect(function() tw(refreshBtn, 0.15, { BackgroundColor3 = C.surface }) end)

local listResult = Instance.new("ScrollingFrame")
listResult.Size = UDim2.new(1, 0, 0, 280)
listResult.BackgroundColor3 = C.header
listResult.BorderSizePixel = 0
listResult.CanvasSize = UDim2.new(0, 0, 0, 0)
listResult.AutomaticCanvasSize = Enum.AutomaticSize.Y
listResult.ScrollBarThickness = 3
listResult.ScrollBarImageColor3 = C.accent
listResult.Parent = listPage
corner(listResult, 9)
stroke(listResult, C.border, 1)
pad(listResult, 8, 8, 8, 8)
mkList(listResult, 7)

local listStatus = Instance.new("Frame")
listStatus.Size = UDim2.new(1, 0, 0, 18)
listStatus.BackgroundTransparency = 1
listStatus.Parent = listPage

local listDot = Instance.new("Frame")
listDot.Size = UDim2.new(0, 6, 0, 6)
listDot.Position = UDim2.new(0, 0, 0.5, -3)
listDot.BackgroundColor3 = C.textDim
listDot.BorderSizePixel = 0
listDot.Active = false
listDot.Parent = listStatus
corner(listDot, 99)

local listStatusLbl = Instance.new("TextLabel")
listStatusLbl.Size = UDim2.new(1, -14, 1, 0)
listStatusLbl.Position = UDim2.new(0, 14, 0, 0)
listStatusLbl.BackgroundTransparency = 1
listStatusLbl.Font = Enum.Font.Gotham
listStatusLbl.TextSize = 11
listStatusLbl.TextColor3 = C.textDim
listStatusLbl.TextXAlignment = Enum.TextXAlignment.Left
listStatusLbl.Text = ""
listStatusLbl.Active = false
listStatusLbl.Parent = listStatus

-- ═══════════════════════════════════════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════════════════════════════════════
local function setStatus(lbl, dot, text, col)
    tw(lbl, 0.25, { TextColor3 = col or C.textDim })
    lbl.Text = text
    if dot then dot.BackgroundColor3 = col or C.textDim end
end

local function clearChildren(parent)
    for _, c in ipairs(parent:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
end

local rowIndex = 0
local function addKeyRow(parent, key, meta)
    rowIndex = rowIndex + 1

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 52)
    row.BackgroundColor3 = C.surface
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.LayoutOrder = rowIndex
    row.Parent = parent
    corner(row, 7)
    stroke(row, C.border, 1)

    local stripe = Instance.new("Frame")
    stripe.Size = UDim2.new(0, 2, 1, 0)
    stripe.BackgroundColor3 = C.accent
    stripe.BorderSizePixel = 0
    stripe.BackgroundTransparency = 1
    stripe.Active = false
    stripe.Parent = row
    corner(stripe, 1)

    local keyLbl = Instance.new("TextLabel")
    keyLbl.Size = UDim2.new(1, -80, 0, 18)
    keyLbl.Position = UDim2.new(0, 12, 0, 8)
    keyLbl.BackgroundTransparency = 1
    keyLbl.Font = Enum.Font.Code
    keyLbl.TextSize = 12
    keyLbl.TextColor3 = C.cyan
    keyLbl.TextXAlignment = Enum.TextXAlignment.Left
    keyLbl.TextTruncate = Enum.TextTruncate.AtEnd
    keyLbl.Text = key
    keyLbl.TextTransparency = 1
    keyLbl.Active = false
    keyLbl.Parent = row

    local metaLbl = Instance.new("TextLabel")
    metaLbl.Size = UDim2.new(1, -80, 0, 14)
    metaLbl.Position = UDim2.new(0, 12, 0, 28)
    metaLbl.BackgroundTransparency = 1
    metaLbl.Font = Enum.Font.Gotham
    metaLbl.TextSize = 10
    metaLbl.TextColor3 = C.textDim
    metaLbl.TextXAlignment = Enum.TextXAlignment.Left
    metaLbl.Text = meta or ""
    metaLbl.TextTransparency = 1
    metaLbl.Active = false
    metaLbl.Parent = row

    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, 62, 0, 26)
    copyBtn.Position = UDim2.new(1, -70, 0.5, -13)
    copyBtn.BackgroundColor3 = C.surface2
    copyBtn.BorderSizePixel = 0
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = 10
    copyBtn.TextColor3 = C.accent
    copyBtn.Text = "COPIAR"
    copyBtn.TextTransparency = 1
    copyBtn.AutoButtonColor = false
    copyBtn.ZIndex = 3
    copyBtn.Parent = row
    corner(copyBtn, 6)
    local cStroke = stroke(copyBtn, C.accentD, 1)

    copyBtn.MouseEnter:Connect(function()
        tw(copyBtn, 0.15, { BackgroundColor3 = C.accent, TextColor3 = C.text })
        cStroke.Color = C.accent
    end)
    copyBtn.MouseLeave:Connect(function()
        tw(copyBtn, 0.15, { BackgroundColor3 = C.surface2, TextColor3 = C.accent })
        cStroke.Color = C.accentD
    end)
    copyBtn.MouseButton1Click:Connect(function()
        setclipboard(key)
        copyBtn.Text = "OK"
        copyBtn.TextColor3 = C.green
        cStroke.Color = C.green
        task.delay(1.2, function()
            copyBtn.Text = "COPIAR"
            copyBtn.TextColor3 = C.accent
            cStroke.Color = C.accentD
        end)
    end)

    row.Position = UDim2.new(0, 0, 0, 8)
    task.delay((rowIndex - 1) * 0.05, function()
        tw(row, 0.35, { BackgroundTransparency = 0, Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Back)
        tw(keyLbl, 0.3, { TextTransparency = 0 })
        tw(metaLbl, 0.3, { TextTransparency = 0 })
        tw(copyBtn, 0.3, { TextTransparency = 0 })
        tw(stripe, 0.3, { BackgroundTransparency = 0 })
    end)

    return row
end

-- ═══════════════════════════════════════════════════════════════════════════
-- TABS SWITCH
-- ═══════════════════════════════════════════════════════════════════════════
local currentTab = "gen"
local function switchTab(tab)
    if currentTab == tab then return end
    currentTab = tab
    if tab == "gen" then
        genPage.Visible = true; listPage.Visible = false
        tw(tabLine, 0.25, { Position = UDim2.new(0, 0, 1, -2) }, Enum.EasingStyle.Quart)
        tw(tabGen, 0.2, { TextColor3 = C.accent })
        tw(tabList, 0.2, { TextColor3 = C.textDim })
    else
        genPage.Visible = false; listPage.Visible = true
        tw(tabLine, 0.25, { Position = UDim2.new(0.5, 0, 1, -2) }, Enum.EasingStyle.Quart)
        tw(tabGen, 0.2, { TextColor3 = C.textDim })
        tw(tabList, 0.2, { TextColor3 = C.accent })
    end
end
tabGen.MouseButton1Click:Connect(function() switchTab("gen") end)
tabList.MouseButton1Click:Connect(function() switchTab("list") end)

-- ═══════════════════════════════════════════════════════════════════════════
-- ENTRY / DRAG
-- ═══════════════════════════════════════════════════════════════════════════
local function openPanel()
    if panel.Visible then return end
    panel.Visible = true
    scale.Scale = 0.88
    panel.BackgroundTransparency = 1
    tw(scale, 0.4, { Scale = 1 }, Enum.EasingStyle.Back)
    tw(panel, 0.3, { BackgroundTransparency = 0 })
end
local function closePanel()
    if not panel.Visible then return end
    tw(scale, 0.2, { Scale = 0.9 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    task.delay(0.2, function() panel.Visible = false; scale.Scale = 1 end)
end

openBtn.MouseButton1Click:Connect(function()
    if panel.Visible then closePanel() else openPanel() end
end)
closeBtn.MouseButton1Click:Connect(closePanel)

local dragging, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = panel.Position
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
        panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                    startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- AÇÃO GERAR
-- ═══════════════════════════════════════════════════════════════════════════
local generating = false
genBtn.MouseButton1Click:Connect(function()
    if generating then return end
    sweepShine()
    generating = true

    local hours, label
    local selected = presetState.selected
    if selected == 99 then
        local amount = tonumber(customQty.Text) or 0
        local unitDef = customUnits[customUnitIdx]
        hours = math.floor(amount * unitDef.h)
        label = ("%d %s · %dh"):format(amount, unitDef.label:lower(), hours)
    else
        local def = presets[selected]
        hours = def.hours
        label = def.label .. " · " .. hours .. "h"
    end

    local count = math.clamp(tonumber(countBox.Text) or 1, 1, 50)
    if hours <= 0 then
        setStatus(genStatusLbl, genDot, "Duração inválida.", C.red)
        generating = false
        return
    end

    setStatus(genStatusLbl, genDot, "Gerando " .. count .. " key(s)…", C.yellow)
    genBtn.Text = "GERANDO…"

    task.spawn(function()
        local data, err = api("/admin/create", "POST", { hours = hours, count = count })
        if err then
            setStatus(genStatusLbl, genDot, "Erro: " .. err, C.red)
            genBtn.Text = "GERAR KEYS"; generating = false; return
        end
        local keys = data and data.keys
        if not keys or #keys == 0 then
            setStatus(genStatusLbl, genDot, "Backend não retornou keys.", C.red)
            genBtn.Text = "GERAR KEYS"; generating = false; return
        end
        rowIndex = 0
        clearChildren(genResult)
        for _, k in ipairs(keys) do
            addKeyRow(genResult, k, label)
        end
        setclipboard(table.concat(keys, "\n"))
        setStatus(genStatusLbl, genDot, ("Geradas %d key(s) · %s — copiadas"):format(#keys, label), C.green)
        genBtn.Text = "GERAR KEYS"
        generating = false
    end)
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- AÇÃO LISTAR
-- ═══════════════════════════════════════════════════════════════════════════
local listing = false
refreshBtn.MouseButton1Click:Connect(function()
    if listing then return end
    listing = true
    setStatus(listStatusLbl, listDot, "Carregando…", C.yellow)
    refreshBtn.Text = "CARREGANDO…"

    task.spawn(function()
        local data, err = api("/admin/keys", "GET")
        if err then
            setStatus(listStatusLbl, listDot, "Erro: " .. err, C.red)
            refreshBtn.Text = "RECARREGAR LISTA"; listing = false; return
        end

        rowIndex = 0
        clearChildren(listResult)
        local keys = data.keys or {}

        if #keys == 0 then
            local empty = Instance.new("TextLabel")
            empty.Size = UDim2.new(1, 0, 0, 40)
            empty.BackgroundTransparency = 1
            empty.Font = Enum.Font.Gotham
            empty.TextSize = 11
            empty.TextColor3 = C.textDim
            empty.Text = "Nenhuma key registrada."
            empty.Active = false
            empty.Parent = listResult
        else
            for _, k in ipairs(keys) do
                local meta
                if k.expired then
                    meta = "Expirada"
                elseif k.used then
                    meta = ("Usada por %s"):format(k.usedByUsername or k.usedBy or "?")
                else
                    local rest = math.max(0, math.floor((k.expiresAt - os.time() * 1000) / 3600000))
                    meta = ("%s · Ativa · %dh restantes"):format(
                        k.admin and "Admin" or (k.tier or "free"), rest
                    )
                end
                addKeyRow(listResult, k.key, meta)
            end
        end
        setStatus(listStatusLbl, listDot, ("%d key(s) listadas."):format(#keys), C.textDim)
        refreshBtn.Text = "RECARREGAR LISTA"
        listing = false
    end)
end)

-- Keybind
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if panel.Visible then closePanel() else openPanel() end
    end
end)

setStatus(genStatusLbl, genDot, "Pronto.", C.green)