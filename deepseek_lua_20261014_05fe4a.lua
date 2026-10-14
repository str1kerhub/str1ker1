--!nocheck
-- ==========================================================================
-- STR1KER MENU v10 — key screen + loader + UI igual ao HTML + fruits
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

-- ── CONSTANTES ────────────────────────────────────────────────────────────
local BACKEND   = "https://str1ker-backend.up.railway.app"
local LOOTLABS  = "https://links.lootlabs.gg/s?w1RValf6"
local LOGO_ID   = "rbxassetid://135682258411683"
local ICON_CROSS    = "rbxassetid://128700347744191"
local ICON_SWORDS   = "rbxassetid://103885374469538"
local ICON_EYE      = "rbxassetid://125222359475217"
local ICON_MOVE     = "rbxassetid://138469521015358"
local ICON_PACKAGE  = "rbxassetid://134571436076349"
local ICON_SETTINGS = "rbxassetid://85538864581030"
local ICON_TARGET   = "rbxassetid://125222359475217"  -- reuso eye p/ Target
local ICON_WEBHOOK  = "rbxassetid://128700347744191"  -- reuso cross p/ Webhook

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
    track    = Color3.fromRGB(15, 25, 45),
}

-- ── HELPERS ───────────────────────────────────────────────────────────────
local function corner(o, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 6); c.Parent = o; return c
end
local function stroke(o, col, th, tr)
    local s = Instance.new("UIStroke")
    s.Color = col or C.border; s.Thickness = th or 1; s.Transparency = tr or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = o; return s
end
local function pad(o, t, r, b, l)
    local p = Instance.new("UIPadding")
    p.PaddingTop=UDim.new(0,t or 0); p.PaddingRight=UDim.new(0,r or 0)
    p.PaddingBottom=UDim.new(0,b or 0); p.PaddingLeft=UDim.new(0,l or 0)
    p.Parent = o
end
local function mkList(p, sp, dir)
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, sp or 6)
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = p; return l
end
local function tw(o, t, props, style)
    local t2 = TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    t2:Play(); return t2
end
local function getStroke(o) return o:FindFirstChildOfClass("UIStroke") end

-- ── ROOT ──────────────────────────────────────────────────────────────────
local gui = Instance.new("ScreenGui")
gui.Name = "Str1kerMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 100
gui.Parent = CoreGui

-- ══════════════════════════════════════════════════════════════════════════
-- 1. TELA DE KEY
-- ══════════════════════════════════════════════════════════════════════════
local keyScreen = Instance.new("Frame")
keyScreen.Size = UDim2.new(1, 0, 1, 0)
keyScreen.BackgroundColor3 = Color3.fromRGB(5, 8, 16)
keyScreen.BorderSizePixel = 0
keyScreen.ZIndex = 50
keyScreen.Parent = gui

local kCard = Instance.new("Frame")
kCard.AnchorPoint = Vector2.new(0.5, 0.5)
kCard.Size = UDim2.new(0, 420, 0, 320)
kCard.Position = UDim2.new(0.5, 0, 0.5, 0)
kCard.BackgroundColor3 = C.bg
kCard.BorderSizePixel = 0
kCard.ZIndex = 51
kCard.Parent = keyScreen
corner(kCard, 16)
local kCardStroke = stroke(kCard, C.accent, 1.5, 0.6)

local kLogo = Instance.new("Frame")
kLogo.Size = UDim2.new(0, 56, 0, 56)
kLogo.Position = UDim2.new(0, 24, 0, 24)
kLogo.BackgroundColor3 = C.accent
kLogo.BorderSizePixel = 0
kLogo.ZIndex = 52
kLogo.Parent = kCard
corner(kLogo, 14)

local kLogoImg = Instance.new("ImageLabel")
kLogoImg.Size = UDim2.new(1, 0, 1, 0)
kLogoImg.BackgroundTransparency = 1
kLogoImg.Image = LOGO_ID
kLogoImg.ScaleType = Enum.ScaleType.Fit
kLogoImg.ZIndex = 53
kLogoImg.Parent = kLogo
corner(kLogoImg, 14)

local kTitle = Instance.new("TextLabel")
kTitle.Size = UDim2.new(1, -100, 0, 22)
kTitle.Position = UDim2.new(0, 92, 0, 28)
kTitle.BackgroundTransparency = 1
kTitle.Font = Enum.Font.GothamBold
kTitle.TextSize = 18
kTitle.TextColor3 = C.text
kTitle.TextXAlignment = Enum.TextXAlignment.Left
kTitle.Text = "STR1KER HUB"
kTitle.ZIndex = 52
kTitle.Parent = kCard

local kSub = Instance.new("TextLabel")
kSub.Size = UDim2.new(1, -100, 0, 14)
kSub.Position = UDim2.new(0, 92, 0, 50)
kSub.BackgroundTransparency = 1
kSub.Font = Enum.Font.Gotham
kSub.TextSize = 11
kSub.TextColor3 = C.textDim
kSub.TextXAlignment = Enum.TextXAlignment.Left
kSub.Text = "PVP · BLOX FRUITS"
kSub.ZIndex = 52
kSub.Parent = kCard

local kDesc = Instance.new("TextLabel")
kDesc.Size = UDim2.new(1, -48, 0, 40)
kDesc.Position = UDim2.new(0, 24, 0, 96)
kDesc.BackgroundTransparency = 1
kDesc.Font = Enum.Font.Gotham
kDesc.TextSize = 11
kDesc.TextColor3 = C.textDim
kDesc.TextWrapped = true
kDesc.TextXAlignment = Enum.TextXAlignment.Left
kDesc.TextYAlignment = Enum.TextYAlignment.Top
kDesc.Text = "Cole sua key ou pegue uma nova completando uma task no LootLabs. Chaves duram 12h e ficam salvas automaticamente."
kDesc.ZIndex = 52
kDesc.Parent = kCard

local kInputBg = Instance.new("Frame")
kInputBg.Size = UDim2.new(1, -48, 0, 40)
kInputBg.Position = UDim2.new(0, 24, 0, 148)
kInputBg.BackgroundColor3 = C.surface
kInputBg.BorderSizePixel = 0
kInputBg.ZIndex = 52
kInputBg.Parent = kCard
corner(kInputBg, 9)
stroke(kInputBg, C.border, 1, 0.3)

local kIcon = Instance.new("ImageLabel")
kIcon.Size = UDim2.new(0, 16, 0, 16)
kIcon.Position = UDim2.new(0, 12, 0.5, -8)
kIcon.BackgroundTransparency = 1
kIcon.Image = ICON_SETTINGS
kIcon.ImageColor3 = C.textDim
kIcon.ScaleType = Enum.ScaleType.Fit
kIcon.ZIndex = 53
kIcon.Parent = kInputBg

local kInput = Instance.new("TextBox")
kInput.Size = UDim2.new(1, -50, 1, 0)
kInput.Position = UDim2.new(0, 38, 0, 0)
kInput.BackgroundTransparency = 1
kInput.Font = Enum.Font.Gotham
kInput.TextSize = 12
kInput.TextColor3 = C.text
kInput.PlaceholderText = "STR1KER-XXXX-XXXX"
kInput.PlaceholderColor3 = C.textDim
kInput.Text = ""
kInput.ClearTextOnFocus = false
kInput.TextXAlignment = Enum.TextXAlignment.Left
kInput.ZIndex = 53
kInput.Parent = kInputBg

local kUnlockBtn = Instance.new("TextButton")
kUnlockBtn.Size = UDim2.new(1, -48, 0, 42)
kUnlockBtn.Position = UDim2.new(0, 24, 0, 200)
kUnlockBtn.BackgroundColor3 = C.accent
kUnlockBtn.BorderSizePixel = 0
kUnlockBtn.Font = Enum.Font.GothamBold
kUnlockBtn.TextSize = 12
kUnlockBtn.TextColor3 = Color3.new(1,1,1)
kUnlockBtn.Text = "UNLOCK HUB"
kUnlockBtn.AutoButtonColor = false
kUnlockBtn.ZIndex = 52
kUnlockBtn.Parent = kCard
corner(kUnlockBtn, 9)

local kGetBtn = Instance.new("TextButton")
kGetBtn.Size = UDim2.new(1, -48, 0, 42)
kGetBtn.Position = UDim2.new(0, 24, 0, 248)
kGetBtn.BackgroundColor3 = C.surface2
kGetBtn.BorderSizePixel = 0
kGetBtn.Font = Enum.Font.GothamBold
kGetBtn.TextSize = 12
kGetBtn.TextColor3 = C.text
kGetBtn.Text = "PEGAR KEY NO LOOTLABS"
kGetBtn.AutoButtonColor = false
kGetBtn.ZIndex = 52
kGetBtn.Parent = kCard
corner(kGetBtn, 9)
stroke(kGetBtn, C.border, 1)

local kFoot = Instance.new("TextLabel")
kFoot.Size = UDim2.new(1, -48, 0, 16)
kFoot.Position = UDim2.new(0, 24, 1, -26)
kFoot.BackgroundTransparency = 1
kFoot.Font = Enum.Font.Gotham
kFoot.TextSize = 10
kFoot.TextColor3 = C.textDim
kFoot.TextXAlignment = Enum.TextXAlignment.Left
kFoot.Text = "PUID: " .. tostring(LP.UserId)
kFoot.ZIndex = 52
kFoot.Parent = kCard

local kReset = Instance.new("TextButton")
kReset.Size = UDim2.new(0, 50, 0, 16)
kReset.Position = UDim2.new(1, -74, 1, -26)
kReset.BackgroundTransparency = 1
kReset.Font = Enum.Font.Gotham
kReset.TextSize = 10
kReset.TextColor3 = C.textDim
kReset.Text = "Reset"
kReset.AutoButtonColor = false
kReset.ZIndex = 52
kReset.Parent = kCard

-- animação de entrada da tela de key
kCard.Position = UDim2.new(0.5, 0, 0.55, 0)
tw(kCard, 0.4, { Position = UDim2.new(0.5, 0, 0.5, 0) }, Enum.EasingStyle.Back)

-- ══════════════════════════════════════════════════════════════════════════
-- 2. TELA DE LOADER
-- ══════════════════════════════════════════════════════════════════════════
local loadScreen = Instance.new("Frame")
loadScreen.Size = UDim2.new(1, 0, 1, 0)
loadScreen.BackgroundColor3 = Color3.fromRGB(5, 8, 16)
loadScreen.BorderSizePixel = 0
loadScreen.ZIndex = 60
loadScreen.Visible = false
loadScreen.Parent = gui

local lCard = Instance.new("Frame")
lCard.AnchorPoint = Vector2.new(0.5, 0.5)
lCard.Size = UDim2.new(0, 460, 0, 380)
lCard.Position = UDim2.new(0.5, 0, 0.5, 0)
lCard.BackgroundColor3 = C.bg
lCard.BorderSizePixel = 0
lCard.ZIndex = 61
lCard.Parent = loadScreen
corner(lCard, 16)
stroke(lCard, C.accent, 1.5, 0.6)

local lLogo = Instance.new("Frame")
lLogo.Size = UDim2.new(0, 56, 0, 56)
lLogo.Position = UDim2.new(0, 24, 0, 24)
lLogo.BackgroundColor3 = C.accent
lLogo.BorderSizePixel = 0
lLogo.ZIndex = 62
lLogo.Parent = lCard
corner(lLogo, 14)

local lLogoImg = Instance.new("ImageLabel")
lLogoImg.Size = UDim2.new(1, 0, 1, 0)
lLogoImg.BackgroundTransparency = 1
lLogoImg.Image = LOGO_ID
lLogoImg.ScaleType = Enum.ScaleType.Fit
lLogoImg.ZIndex = 63
lLogoImg.Parent = lLogo
corner(lLogoImg, 14)

local lTitle = Instance.new("TextLabel")
lTitle.Size = UDim2.new(1, -160, 0, 22)
lTitle.Position = UDim2.new(0, 92, 0, 28)
lTitle.BackgroundTransparency = 1
lTitle.Font = Enum.Font.GothamBold
lTitle.TextSize = 18
lTitle.TextColor3 = C.text
lTitle.TextXAlignment = Enum.TextXAlignment.Left
lTitle.Text = "Str1ker Hub"
lTitle.ZIndex = 62
lTitle.Parent = lCard

local lSub = Instance.new("TextLabel")
lSub.Size = UDim2.new(1, -160, 0, 14)
lSub.Position = UDim2.new(0, 92, 0, 50)
lSub.BackgroundTransparency = 1
lSub.Font = Enum.Font.Gotham
lSub.TextSize = 10
lSub.TextColor3 = C.textDim
lSub.TextXAlignment = Enum.TextXAlignment.Left
lSub.Text = "SECURE CONNECTION / V3.2"
lSub.ZIndex = 62
lSub.Parent = lCard

local lBadge = Instance.new("Frame")
lBadge.Size = UDim2.new(0, 110, 0, 24)
lBadge.Position = UDim2.new(1, -122, 0, 38)
lBadge.BackgroundColor3 = Color3.fromRGB(8, 40, 24)
lBadge.BorderSizePixel = 0
lBadge.ZIndex = 62
lBadge.Parent = lCard
corner(lBadge, 99)
stroke(lBadge, C.green, 1, 0.4)

local lBadgeDot = Instance.new("Frame")
lBadgeDot.Size = UDim2.new(0, 6, 0, 6)
lBadgeDot.Position = UDim2.new(0, 12, 0.5, -3)
lBadgeDot.BackgroundColor3 = C.green
lBadgeDot.BorderSizePixel = 0
lBadgeDot.ZIndex = 63
lBadgeDot.Parent = lBadge
corner(lBadgeDot, 99)

local lBadgeTxt = Instance.new("TextLabel")
lBadgeTxt.Size = UDim2.new(1, -24, 1, 0)
lBadgeTxt.Position = UDim2.new(0, 20, 0, 0)
lBadgeTxt.BackgroundTransparency = 1
lBadgeTxt.Font = Enum.Font.GothamBold
lBadgeTxt.TextSize = 10
lBadgeTxt.TextColor3 = C.green
lBadgeTxt.TextXAlignment = Enum.TextXAlignment.Left
lBadgeTxt.Text = "PROTECTED"
lBadgeTxt.ZIndex = 63
lBadgeTxt.Parent = lBadge

-- barra
local lBarLabel = Instance.new("TextLabel")
lBarLabel.Size = UDim2.new(1, -48, 0, 20)
lBarLabel.Position = UDim2.new(0, 24, 0, 108)
lBarLabel.BackgroundTransparency = 1
lBarLabel.Font = Enum.Font.GothamBold
lBarLabel.TextSize = 13
lBarLabel.TextColor3 = C.text
lBarLabel.TextXAlignment = Enum.TextXAlignment.Left
lBarLabel.Text = "Loading"
lBarLabel.ZIndex = 62
lBarLabel.Parent = lCard

local lBarPct = Instance.new("TextLabel")
lBarPct.Size = UDim2.new(1, -48, 0, 20)
lBarPct.Position = UDim2.new(0, 24, 0, 108)
lBarPct.BackgroundTransparency = 1
lBarPct.Font = Enum.Font.GothamBold
lBarPct.TextSize = 13
lBarPct.TextColor3 = C.accentL
lBarPct.TextXAlignment = Enum.TextXAlignment.Right
lBarPct.Text = "0%"
lBarPct.ZIndex = 62
lBarPct.Parent = lCard

local lBarBg = Instance.new("Frame")
lBarBg.Size = UDim2.new(1, -48, 0, 4)
lBarBg.Position = UDim2.new(0, 24, 0, 134)
lBarBg.BackgroundColor3 = C.track
lBarBg.BorderSizePixel = 0
lBarBg.ZIndex = 62
lBarBg.Parent = lCard
corner(lBarBg, 99)

local lBarFill = Instance.new("Frame")
lBarFill.Size = UDim2.new(0, 0, 1, 0)
lBarFill.BackgroundColor3 = C.accent
lBarFill.BorderSizePixel = 0
lBarFill.ZIndex = 63
lBarFill.Parent = lBarBg
corner(lBarFill, 99)

-- LIVE ACTIVITY
local lActivity = Instance.new("Frame")
lActivity.Size = UDim2.new(1, -48, 0, 170)
lActivity.Position = UDim2.new(0, 24, 0, 158)
lActivity.BackgroundColor3 = C.surface
lActivity.BorderSizePixel = 0
lActivity.ZIndex = 62
lActivity.Parent = lCard
corner(lActivity, 12)

local lActTitle = Instance.new("TextLabel")
lActTitle.Size = UDim2.new(1, -24, 0, 18)
lActTitle.Position = UDim2.new(0, 14, 0, 12)
lActTitle.BackgroundTransparency = 1
lActTitle.Font = Enum.Font.GothamBold
lActTitle.TextSize = 10
lActTitle.TextColor3 = C.textDim
lActTitle.TextXAlignment = Enum.TextXAlignment.Left
lActTitle.Text = "LIVE ACTIVITY"
lActTitle.ZIndex = 63
lActTitle.Parent = lActivity

local lStepsFrame = Instance.new("Frame")
lStepsFrame.Size = UDim2.new(1, -24, 1, -40)
lStepsFrame.Position = UDim2.new(0, 14, 0, 36)
lStepsFrame.BackgroundTransparency = 1
lStepsFrame.ZIndex = 63
lStepsFrame.Parent = lActivity
mkList(lStepsFrame, 6)

local STEPS = {
    "Inicializando modulo seguro...",
    "Aplicando security patch...",
    "Validando integridade...",
    "Carregando hooks...",
    "Registrando hotkeys...",
    "Finalizing...",
    "Ready.",
}

local stepLabels = {}
for i, txt in ipairs(STEPS) do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 18)
    row.BackgroundTransparency = 1
    row.ZIndex = 63
    row.Parent = lStepsFrame

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 8, 0, 8)
    dot.Position = UDim2.new(0, 0, 0.5, -4)
    dot.BackgroundColor3 = C.track
    dot.BorderSizePixel = 0
    dot.ZIndex = 64
    dot.Parent = row
    corner(dot, 99)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 1, 0)
    lbl.Position = UDim2.new(0, 18, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextColor3 = C.textDim
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = txt
    lbl.ZIndex = 64
    lbl.Parent = row

    table.insert(stepLabels, { dot = dot, lbl = lbl, done = false })
end

-- animação dos steps
local function runLoaderSteps(onComplete)
    task.spawn(function()
        local n = #stepLabels
        for i = 1, n do
            local s = stepLabels[i]
            task.wait(0.35)
            s.dot.BackgroundColor3 = C.green
            s.lbl.TextColor3 = C.text
            local pct = math.floor((i / n) * 100)
            tw(lBarFill, 0.3, { Size = UDim2.new(pct / 100, 0, 1, 0) })
            lBarPct.Text = pct .. "%"
            lBarLabel.Text = (i == n) and "Ready" or "Loading"
        end
        task.wait(0.6)
        if onComplete then onComplete() end
    end)
end

-- ══════════════════════════════════════════════════════════════════════════
-- 3. MENU PRINCIPAL
-- ══════════════════════════════════════════════════════════════════════════
local win = Instance.new("Frame")
win.AnchorPoint = Vector2.new(0.5, 0.5)
win.Size = UDim2.new(0, 900, 0, 540)
win.Position = UDim2.new(0.5, 0, 0.5, 0)
win.BackgroundColor3 = C.bg
win.BorderSizePixel = 0
win.ClipsDescendants = true
win.Visible = false
win.ZIndex = 10
win.Parent = gui
corner(win, 14)
stroke(win, C.border, 1, 0.3)

local scale = Instance.new("UIScale")
scale.Scale = 0.6  -- escala maior que o HTML (40%)
scale.Parent = win

-- topo: barra fina azul
local topLine = Instance.new("Frame")
topLine.Size = UDim2.new(1, -48, 0, 1)
topLine.Position = UDim2.new(0, 24, 0, 0)
topLine.BackgroundColor3 = C.accent
topLine.BorderSizePixel = 0
topLine.ZIndex = 12
topLine.Parent = win
local topGrad = Instance.new("UIGradient")
topGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.5, 0.3),
    NumberSequenceKeypoint.new(1, 1),
})
topGrad.Parent = topLine

-- ── HEADER ────────────────────────────────────────────────────────────────
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 60)
header.BackgroundColor3 = C.header
header.BorderSizePixel = 0
header.ZIndex = 11
header.Parent = win

local hLine = Instance.new("Frame")
hLine.Size = UDim2.new(1, 0, 0, 1)
hLine.Position = UDim2.new(0, 0, 1, -1)
hLine.BackgroundColor3 = C.border
hLine.BorderSizePixel = 0
hLine.ZIndex = 12
hLine.Parent = header

local hLogo = Instance.new("Frame")
hLogo.Size = UDim2.new(0, 38, 0, 38)
hLogo.Position = UDim2.new(0, 16, 0.5, -19)
hLogo.BackgroundColor3 = C.accent
hLogo.BorderSizePixel = 0
hLogo.ZIndex = 13
hLogo.Parent = header
corner(hLogo, 10)
local hLogoImg = Instance.new("ImageLabel")
hLogoImg.Size = UDim2.new(1, 0, 1, 0)
hLogoImg.BackgroundTransparency = 1
hLogoImg.Image = LOGO_ID
hLogoImg.ScaleType = Enum.ScaleType.Fit
hLogoImg.ZIndex = 14
hLogoImg.Parent = hLogo
corner(hLogoImg, 10)

local hTitle = Instance.new("TextLabel")
hTitle.Size = UDim2.new(0, 300, 0, 18)
hTitle.Position = UDim2.new(0, 64, 0, 12)
hTitle.BackgroundTransparency = 1
hTitle.Font = Enum.Font.GothamBold
hTitle.TextSize = 15
hTitle.TextColor3 = C.text
hTitle.TextXAlignment = Enum.TextXAlignment.Left
hTitle.Text = "STR1KER"
hTitle.ZIndex = 13
hTitle.Parent = header

local hSub = Instance.new("TextLabel")
hSub.Size = UDim2.new(0, 300, 0, 12)
hSub.Position = UDim2.new(0, 64, 0, 34)
hSub.BackgroundTransparency = 1
hSub.Font = Enum.Font.Gotham
hSub.TextSize = 10
hSub.TextColor3 = C.textDim
hSub.TextXAlignment = Enum.TextXAlignment.Left
hSub.Text = "PVP · BLOX FRUITS"
hSub.ZIndex = 13
hSub.Parent = header

-- scale slider no header
local scaleLbl = Instance.new("TextLabel")
scaleLbl.Size = UDim2.new(0, 40, 0, 16)
scaleLbl.Position = UDim2.new(1, -260, 0.5, -8)
scaleLbl.BackgroundTransparency = 1
scaleLbl.Font = Enum.Font.GothamBold
scaleLbl.TextSize = 10
scaleLbl.TextColor3 = C.textDim
scaleLbl.Text = "SCALE"
scaleLbl.TextXAlignment = Enum.TextXAlignment.Right
scaleLbl.ZIndex = 13
scaleLbl.Parent = header

local scaleBar = Instance.new("Frame")
scaleBar.Size = UDim2.new(0, 120, 0, 4)
scaleBar.Position = UDim2.new(1, -212, 0.5, -2)
scaleBar.BackgroundColor3 = C.track
scaleBar.BorderSizePixel = 0
scaleBar.ZIndex = 13
scaleBar.Parent = header
corner(scaleBar, 99)

local scaleFill = Instance.new("Frame")
scaleFill.Size = UDim2.new(0.6, 0, 1, 0)
scaleFill.BackgroundColor3 = C.accent
scaleFill.BorderSizePixel = 0
scaleFill.ZIndex = 14
scaleFill.Parent = scaleBar
corner(scaleFill, 99)

local scaleKnob = Instance.new("Frame")
scaleKnob.Size = UDim2.new(0, 12, 0, 12)
scaleKnob.AnchorPoint = Vector2.new(0.5, 0.5)
scaleKnob.Position = UDim2.new(0.6, 0, 0.5, 0)
scaleKnob.BackgroundColor3 = Color3.new(1,1,1)
scaleKnob.BorderSizePixel = 0
scaleKnob.ZIndex = 15
scaleKnob.Parent = scaleBar
corner(scaleKnob, 99)

local scalePct = Instance.new("TextLabel")
scalePct.Size = UDim2.new(0, 40, 0, 16)
scalePct.Position = UDim2.new(1, -80, 0.5, -8)
scalePct.BackgroundTransparency = 1
scalePct.Font = Enum.Font.GothamBold
scalePct.TextSize = 10
scalePct.TextColor3 = C.accentL
scalePct.Text = "60%"
scalePct.ZIndex = 13
scalePct.Parent = header

-- botões minimizar/fechar
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -70, 0.5, -15)
minBtn.BackgroundColor3 = C.surface
minBtn.BorderSizePixel = 0
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 14
minBtn.TextColor3 = C.textDim
minBtn.Text = "−"
minBtn.AutoButtonColor = false
minBtn.ZIndex = 13
minBtn.Parent = header
corner(minBtn, 8)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -36, 0.5, -15)
closeBtn.BackgroundColor3 = Color3.fromRGB(50, 15, 15)
closeBtn.BorderSizePixel = 0
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.TextColor3 = C.red
closeBtn.Text = "×"
closeBtn.AutoButtonColor = false
closeBtn.ZIndex = 13
closeBtn.Parent = header
corner(closeBtn, 8)
stroke(closeBtn, C.red, 1, 0.7)

-- ── BODY ──────────────────────────────────────────────────────────────────
local body = Instance.new("Frame")
body.Size = UDim2.new(1, 0, 1, -60)
body.Position = UDim2.new(0, 0, 0, 60)
body.BackgroundTransparency = 1
body.ZIndex = 11
body.Parent = win

-- SIDEBAR
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 170, 1, 0)
sidebar.BackgroundColor3 = C.sidebar
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 12
sidebar.Parent = body
pad(sidebar, 12, 10, 12, 10)
mkList(sidebar, 3)

-- CONTENT
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -460, 1, 0)
content.Position = UDim2.new(0, 170, 0, 0)
content.BackgroundColor3 = C.bg
content.BorderSizePixel = 0
content.ZIndex = 12
content.Parent = body

-- tab bar superior (sub-tabs)
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 42)
tabBar.BackgroundColor3 = C.header
tabBar.BorderSizePixel = 0
tabBar.ZIndex = 13
tabBar.Parent = content

local tabBarLine = Instance.new("Frame")
tabBarLine.Size = UDim2.new(1, 0, 0, 1)
tabBarLine.Position = UDim2.new(0, 0, 1, -1)
tabBarLine.BackgroundColor3 = C.border
tabBarLine.BorderSizePixel = 0
tabBarLine.ZIndex = 14
tabBarLine.Parent = tabBar

local tabNav = Instance.new("Frame")
tabNav.Size = UDim2.new(1, -20, 1, 0)
tabNav.Position = UDim2.new(0, 10, 0, 0)
tabNav.BackgroundTransparency = 1
tabNav.ZIndex = 14
tabNav.Parent = tabBar
local tabNavLayout = mkList(tabNav, 4, Enum.FillDirection.Horizontal)
tabNavLayout.VerticalAlignment = Enum.VerticalAlignment.Center

-- container de cards
local cardsScroll = Instance.new("ScrollingFrame")
cardsScroll.Size = UDim2.new(1, 0, 1, -42)
cardsScroll.Position = UDim2.new(0, 0, 0, 42)
cardsScroll.BackgroundTransparency = 1
cardsScroll.BorderSizePixel = 0
cardsScroll.ScrollBarThickness = 3
cardsScroll.ScrollBarImageColor3 = C.accent
cardsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
cardsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
cardsScroll.ZIndex = 13
cardsScroll.Parent = content
pad(cardsScroll, 14, 14, 14, 14)

-- AVATAR PANEL
local charPanel = Instance.new("Frame")
charPanel.Size = UDim2.new(0, 290, 1, 0)
charPanel.Position = UDim2.new(1, -290, 0, 0)
charPanel.BackgroundColor3 = C.sidebar
charPanel.BorderSizePixel = 0
charPanel.ClipsDescendants = true
charPanel.ZIndex = 12
charPanel.Parent = body

local avatarFrame = Instance.new("Frame")
avatarFrame.AnchorPoint = Vector2.new(0.5, 0.5)
avatarFrame.Size = UDim2.new(0, 220, 0, 300)
avatarFrame.Position = UDim2.new(0.5, 0, 0.42, 0)
avatarFrame.BackgroundTransparency = 1
avatarFrame.ZIndex = 13
avatarFrame.Parent = charPanel

local avatarImg = Instance.new("ImageLabel")
avatarImg.Size = UDim2.new(1, 0, 1, 0)
avatarImg.BackgroundTransparency = 1
avatarImg.ScaleType = Enum.ScaleType.Fit
avatarImg.ZIndex = 14
avatarImg.Parent = avatarFrame

local charNameLbl = Instance.new("TextLabel")
charNameLbl.AnchorPoint = Vector2.new(0.5, 0)
charNameLbl.Size = UDim2.new(1, -20, 0, 20)
charNameLbl.Position = UDim2.new(0.5, 0, 0.82, 0)
charNameLbl.BackgroundTransparency = 1
charNameLbl.Font = Enum.Font.GothamBold
charNameLbl.TextSize = 14
charNameLbl.TextColor3 = C.text
charNameLbl.Text = LP.Name
charNameLbl.ZIndex = 14
charNameLbl.Parent = charPanel

local charIdLbl = Instance.new("TextLabel")
charIdLbl.AnchorPoint = Vector2.new(0.5, 0)
charIdLbl.Size = UDim2.new(1, -20, 0, 14)
charIdLbl.Position = UDim2.new(0.5, 0, 0.82, 24)
charIdLbl.BackgroundTransparency = 1
charIdLbl.Font = Enum.Font.Gotham
charIdLbl.TextSize = 10
charIdLbl.TextColor3 = C.textDim
charIdLbl.Text = "ID " .. tostring(LP.UserId)
charIdLbl.ZIndex = 14
charIdLbl.Parent = charPanel

local changeBtn = Instance.new("TextButton")
changeBtn.Size = UDim2.new(0, 90, 0, 26)
changeBtn.AnchorPoint = Vector2.new(0.5, 0)
changeBtn.Position = UDim2.new(0.5, 0, 0.9, 0)
changeBtn.BackgroundColor3 = C.surface2
changeBtn.BorderSizePixel = 0
changeBtn.Font = Enum.Font.GothamBold
changeBtn.TextSize = 10
changeBtn.TextColor3 = C.accentL
changeBtn.Text = "CHANGE"
changeBtn.AutoButtonColor = false
changeBtn.ZIndex = 14
changeBtn.Parent = charPanel
corner(changeBtn, 8)
stroke(changeBtn, C.accentD, 1, 0.5)

local avatarLoaded = false
task.spawn(function()
    if not LP.Character then LP.CharacterAdded:Wait() end
    task.wait(0.5)
    avatarImg.Image = "rbxthumb://type=Avatar&id=" .. LP.UserId .. "&w=420&h=420"
    task.wait(2)
    if avatarImg.IsLoaded then avatarLoaded = true; return end
    local ok, res = pcall(function()
        return game:HttpGet("https://thumbnails.roblox.com/v1/users/avatar?userIds=" .. LP.UserId .. "&size=420x420&format=Png&isCircular=false")
    end)
    if ok and res then
        local d
        pcall(function() d = Http:JSONDecode(res) end)
        if d and d.data and d.data[1] then
            avatarImg.Image = d.data[1].imageUrl
            task.wait(2)
            avatarLoaded = avatarImg.IsLoaded
        end
    end
end)

local tAnim = 0
RunService.RenderStepped:Connect(function(dt)
    if not avatarLoaded then return end
    tAnim = tAnim + dt
    local yOff = math.sin(tAnim * 1.4) * 5
    local rot = math.sin(tAnim * 0.9) * 1.5
    avatarFrame.Position = UDim2.new(0.5, 0, 0.42, yOff)
    avatarImg.Rotation = rot
end)

-- ══════════════════════════════════════════════════════════════════════════
-- HELPERS DE CARD
-- ══════════════════════════════════════════════════════════════════════════
local function cardBase(parent, label, desc)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, desc and 50 or 40)
    row.BackgroundColor3 = C.surface
    row.BorderSizePixel = 0
    row.Text = ""
    row.AutoButtonColor = false
    row.ZIndex = 14
    row.Parent = parent
    corner(row, 9)
    stroke(row, C.border, 1, 0.4)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -110, 0, 16)
    title.Position = UDim2.new(0, 14, 0, desc and 8 or 12)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.TextColor3 = C.text
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = label
    title.ZIndex = 15
    title.Parent = row

    if desc then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1, -110, 0, 13)
        d.Position = UDim2.new(0, 14, 0, 26)
        d.BackgroundTransparency = 1
        d.Font = Enum.Font.Gotham
        d.TextSize = 10
        d.TextColor3 = C.textDim
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Text = desc
        d.ZIndex = 15
        d.Parent = row
    end
    return row
end

local function mkToggle(parent, label, desc, initial, callback)
    local row = cardBase(parent, label, desc)
    local on = initial == true

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 40, 0, 22)
    track.Position = UDim2.new(1, -54, 0.5, -11)
    track.BackgroundColor3 = on and C.accent or C.track
    track.BorderSizePixel = 0
    track.ZIndex = 15
    track.Parent = row
    corner(track, 99)
    local trackStroke = stroke(track, on and C.accent or C.border, 1, on and 0 or 0.5)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = on and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.BorderSizePixel = 0
    knob.ZIndex = 16
    knob.Parent = track
    corner(knob, 99)

    row.MouseButton1Click:Connect(function()
        on = not on
        tw(track, 0.2, { BackgroundColor3 = on and C.accent or C.track }, Enum.EasingStyle.Back)
        trackStroke.Color = on and C.accent or C.border
        trackStroke.Transparency = on and 0 or 0.5
        tw(knob, 0.2, { Position = on and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9) }, Enum.EasingStyle.Back)
        if callback then callback(on) end
    end)
end

local function mkSlider(parent, label, desc, minV, maxV, initial, step, callback)
    step = step or 0.01
    local row = cardBase(parent, label, desc)
    row.Size = UDim2.new(1, 0, 0, 52)

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 70, 0, 16)
    valLbl.Position = UDim2.new(1, -84, 0, 10)
    valLbl.BackgroundTransparency = 1
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 11
    valLbl.TextColor3 = C.accent
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Text = step < 1 and string.format("%.2f", initial) or tostring(math.floor(initial))
    valLbl.ZIndex = 15
    valLbl.Parent = row

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -28, 0, 4)
    bar.Position = UDim2.new(0, 14, 1, -14)
    bar.BackgroundColor3 = C.track
    bar.BorderSizePixel = 0
    bar.ZIndex = 15
    bar.Parent = row
    corner(bar, 99)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((initial - minV) / (maxV - minV), 0, 1, 0)
    fill.BackgroundColor3 = C.accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 16
    fill.Parent = bar
    corner(fill, 99)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new((initial - minV) / (maxV - minV), 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.BorderSizePixel = 0
    knob.ZIndex = 17
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function mkDropdown(parent, label, desc, options, initial, callback)
    local row = cardBase(parent, label, desc)
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
    btn.Text = options[currentIdx] .. " v"
    btn.AutoButtonColor = false
    btn.ZIndex = 18
    btn.Parent = row
    corner(btn, 6)
    stroke(btn, C.border, 1)

    local listOpen, listFrame = false, nil
    local function closeList() if listFrame then listFrame:Destroy() listFrame = nil end listOpen = false end

    btn.MouseButton1Click:Connect(function()
        if listOpen then closeList() return end
        listOpen = true
        listFrame = Instance.new("Frame")
        listFrame.Size = UDim2.new(0, 140, 0, #options * 26 + 8)
        listFrame.Position = UDim2.new(1, -154, 0, 44)
        listFrame.BackgroundColor3 = C.surface
        listFrame.BorderSizePixel = 0
        listFrame.ZIndex = 30
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
            o.ZIndex = 31
            o.Parent = listFrame
            corner(o, 4)
            pad(o, 0, 0, 0, 10)
            o.MouseButton1Click:Connect(function()
                currentIdx = i
                btn.Text = opt .. " v"
                if callback then callback(opt) end
                closeList()
            end)
        end
    end)
end

local function mkHeader(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.TextColor3 = C.textDim
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = string.upper(text)
    lbl.ZIndex = 14
    lbl.Parent = parent
    return lbl
end

-- ══════════════════════════════════════════════════════════════════════════
-- CATEGORIAS + PÁGINAS
-- ══════════════════════════════════════════════════════════════════════════
local pages = {}
local catBtns = {}
local CATEGORIES = {
    { name = "Aimbot",   icon = ICON_CROSS },
    { name = "Target",   icon = ICON_TARGET },
    { name = "Combat",   icon = ICON_SWORDS },
    { name = "Visuals",  icon = ICON_EYE },
    { name = "Movement", icon = ICON_MOVE },
    { name = "Fruits",   icon = ICON_PACKAGE },
    { name = "Webhook",  icon = ICON_WEBHOOK },
    { name = "Settings", icon = ICON_SETTINGS },
}

local function switchCat(name)
    for cn, page in pairs(pages) do page.Visible = (cn == name) end
    for _, btn in ipairs(catBtns) do
        local s = getStroke(btn)
        local icon = btn:FindFirstChild("CatIcon")
        if btn.Name == name then
            tw(btn, 0.15, { BackgroundColor3 = C.surface })
            if s then s.Color = C.accent s.Transparency = 0 end
            btn.TextColor3 = C.text
            if icon then icon.ImageColor3 = C.accentL end
        else
            tw(btn, 0.15, { BackgroundColor3 = C.sidebar })
            if s then s.Color = C.sidebar s.Transparency = 1 end
            btn.TextColor3 = C.textDim
            if icon then icon.ImageColor3 = C.textDim end
        end
    end
end

for _, def in ipairs(CATEGORIES) do
    local b = Instance.new("TextButton")
    b.Name = def.name
    b.Size = UDim2.new(1, 0, 0, 36)
    b.BackgroundColor3 = C.sidebar
    b.BorderSizePixel = 0
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.TextColor3 = C.textDim
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Text = " " .. def.name
    b.AutoButtonColor = false
    b.ZIndex = 13
    b.Parent = sidebar
    corner(b, 8)
    stroke(b, C.sidebar, 1, 1)

    local icon = Instance.new("ImageLabel")
    icon.Name = "CatIcon"
    icon.Size = UDim2.new(0, 16, 0, 16)
    icon.Position = UDim2.new(0, 11, 0.5, -8)
    icon.BackgroundTransparency = 1
    icon.Image = def.icon
    icon.ImageColor3 = C.textDim
    icon.ScaleType = Enum.ScaleType.Fit
    icon.ZIndex = 14
    icon.Parent = b

    table.insert(catBtns, b)
    b.MouseButton1Click:Connect(function() switchCat(def.name) end)
end

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
    sc.ZIndex = 14
    sc.Parent = cardsScroll
    mkList(sc, 6)
    pages[name] = sc
    return sc
end

-- ══════════════════════════════════════════════════════════════════════════
-- CONTEÚDO DAS PÁGINAS
-- ══════════════════════════════════════════════════════════════════════════

-- AIMBOT ─────────────────────────────────────────────────────────────────
local aimPage = newPage("Aimbot")
mkHeader(aimPage, "MAIN")
mkToggle(aimPage, "Aim Assist", "Precise aiming with movement prediction", CFG.aim.enabled, function(v) API.setAim(v) end)
mkToggle(aimPage, "Assist Aim", "Assist aim with firearms", false, nil)
mkSlider(aimPage, "Maximum", "Max targeting range", 50, 2000, CFG.aim.max_distance, 10, function(v) CFG.aim.max_distance = v; API.saveCfg() end)
mkSlider(aimPage, "Movement Prediction", "Movement prediction lead", 0.03, 0.30, 0.14, 0.01, nil)
mkSlider(aimPage, "Aim Transition", "Smoothing", 0.05, 0.95, CFG.aim.smoothing, 0.05, function(v) API.setSmoothing(v) end)
mkDropdown(aimPage, "Preferred", "Target part", {"Head","Torso","Nearest"}, CFG.aim.aim_part, function(v) API.setAimPart(v) end)
mkHeader(aimPage, "FOV")
mkToggle(aimPage, "Use FOV", "Only target inside circle", true, nil)
mkSlider(aimPage, "FOV Radius", "Circle size in px", 50, 750, CFG.aim.fov, 10, function(v) API.setFov(v) end)
mkToggle(aimPage, "Show Circle", "Draw FOV circle", true, nil)
mkHeader(aimPage, "CHECKS")
mkToggle(aimPage, "Team Check", "Skip teammates", CFG.aim.team_check, function(v) CFG.aim.team_check = v; API.saveCfg() end)
mkToggle(aimPage, "Visibility Check", "Only visible entities", CFG.aim.visibility_check, function(v) CFG.aim.visibility_check = v; API.saveCfg() end)
mkSlider(aimPage, "Resolver", "Movement resolver", 0, 0.5, CFG.aim.resolver, 0.01, function(v) API.setResolver(v) end)

-- TARGET ─────────────────────────────────────────────────────────────────
local targetPage = newPage("Target")
mkHeader(targetPage, "PRIORITY")
mkDropdown(targetPage, "Priority", "Target selection mode", {"Nearest","Lowest HP","Threat"}, "Nearest", nil)
mkSlider(targetPage, "Max Target Distance", "Range", 50, 2000, 600, 10, nil)
mkHeader(targetPage, "FILTERS")
mkToggle(targetPage, "Ignore Friends", "Skip Roblox friends", true, nil)
mkToggle(targetPage, "Ignore NPCs", "Skip non-player humanoids", true, nil)
mkToggle(targetPage, "Ignore Dead", "Skip Health = 0", true, nil)
mkHeader(targetPage, "ADVANCED")
mkToggle(targetPage, "Wall Bang", "Target through walls", false, nil)
mkToggle(targetPage, "Auto Switch", "Switch when target dies", true, nil)

-- COMBAT ─────────────────────────────────────────────────────────────────
local combatPage = newPage("Combat")
mkHeader(combatPage, "ATTACK")
mkToggle(combatPage, "Auto Attack", "Attack nearest in range", false, nil)
mkToggle(combatPage, "Fast Attack", "Remove attack delay", false, nil)
mkSlider(combatPage, "Attack Delay", "Time between attacks (ms)", 1, 300, 10, 1, nil)
mkHeader(combatPage, "DEFENSE")
mkToggle(combatPage, "Auto Dodge", "Evade dangerous attacks", false, nil)
mkToggle(combatPage, "Unbreakable Skills", "Prevent stun cancel", false, nil)
mkHeader(combatPage, "HAKI")
mkToggle(combatPage, "Auto Ken Haki", "Observation Haki", false, nil)
mkToggle(combatPage, "Auto Buso Haki", "Armament Haki", false, nil)
mkHeader(combatPage, "SORU")
mkToggle(combatPage, "Show Soru Button", "Floating button", false, nil)
mkSlider(combatPage, "Soru Distance", "Max teleport range", 20, 200, 200, 10, nil)
mkToggle(combatPage, "Infinite Soru", "Remove cooldown", false, nil)
mkHeader(combatPage, "RACE")
mkToggle(combatPage, "Auto V3", "Use V3 when ready", false, nil)
mkToggle(combatPage, "Auto V4", "Transform when full", false, nil)

-- VISUALS ────────────────────────────────────────────────────────────────
local visPage = newPage("Visuals")
mkHeader(visPage, "PLAYER ESP")
mkToggle(visPage, "Enable ESP", "Overlay all players", CFG.esp.enabled, function(v) API.setESP(v) end)
mkToggle(visPage, "Box", "Box around character", CFG.esp.box, function(v) CFG.esp.box = v; API.saveCfg() end)
mkToggle(visPage, "Name", "Player name", CFG.esp.name, function(v) CFG.esp.name = v; API.saveCfg() end)
mkToggle(visPage, "Distance", "Distance in studs", CFG.esp.distance, function(v) CFG.esp.distance = v; API.saveCfg() end)
mkToggle(visPage, "Health Bar", "Horizontal HP bar", CFG.esp.health_bar, function(v) CFG.esp.health_bar = v; API.saveCfg() end)
mkToggle(visPage, "Tracer", "Line from bottom", CFG.esp.tracer, function(v) CFG.esp.tracer = v; API.saveCfg() end)
mkToggle(visPage, "Skeleton", "Bone lines R6/R15", CFG.esp.skeleton, function(v) API.setSkeleton(v) end)
mkToggle(visPage, "Tool/Weapon", "Show equipped tool", false, function(v) CFG.esp.tool = v; API.saveCfg() end)
mkSlider(visPage, "Max Distance", "ESP render range", 100, 5000, CFG.esp.max_distance, 100, function(v) API.setMaxDist(v) end)
mkHeader(visPage, "ENVIRONMENT")
mkToggle(visPage, "Fullbright", "Max lighting", false, nil)
mkToggle(visPage, "No Fog", "Remove fog", false, nil)
mkToggle(visPage, "No Grass", "Hide terrain grass", false, nil)

-- MOVEMENT ───────────────────────────────────────────────────────────────
local movPage = newPage("Movement")
mkHeader(movPage, "SPEED & JUMP")
mkToggle(movPage, "Super Jump", "Increase jump strength", false, nil)
mkSlider(movPage, "Jump Power", "Jump value", 50, 300, 100, 5, nil)
mkToggle(movPage, "Custom Speed", "Override walk speed", false, nil)
mkSlider(movPage, "WalkSpeed", "Speed value", 16, 250, 16, 1, nil)
mkHeader(movPage, "PHASING")
mkToggle(movPage, "Noclip", "Walk through walls", false, nil)
mkToggle(movPage, "Infinite Jump", "Jump mid-air", false, nil)
mkToggle(movPage, "Walk On Water", "Stand on ocean", false, nil)

-- FRUITS (funcional) ─────────────────────────────────────────────────────
local fruitPage = newPage("Fruits")
mkHeader(fruitPage, "AUTO SPIN")
mkToggle(fruitPage, "Auto Spin Fruit", "Spin dealer automatically from anywhere", false, function(v)
    getgenv().STR1KER_AUTO_SPIN = v
end)
mkSlider(fruitPage, "Spin Delay", "Seconds between spins", 1, 30, 3, 1, function(v)
    getgenv().STR1KER_SPIN_DELAY = v
end)
mkHeader(fruitPage, "AUTO STORE")
mkToggle(fruitPage, "Auto Store Fruit", "Store inventory fruits", false, function(v)
    getgenv().STR1KER_AUTO_STORE = v
end)
mkToggle(fruitPage, "Only Rare", "Skip common fruits", false, function(v)
    getgenv().STR1KER_STORE_RARE = v
end)
mkHeader(fruitPage, "MANUAL")
local spinNowBtn = Instance.new("TextButton")
spinNowBtn.Size = UDim2.new(1, 0, 0, 40)
spinNowBtn.BackgroundColor3 = C.surface
spinNowBtn.BorderSizePixel = 0
spinNowBtn.Font = Enum.Font.GothamBold
spinNowBtn.TextSize = 12
spinNowBtn.TextColor3 = C.accent
spinNowBtn.Text = "GIRAR AGORA"
spinNowBtn.AutoButtonColor = false
spinNowBtn.ZIndex = 14
spinNowBtn.Parent = fruitPage
corner(spinNowBtn, 8)
stroke(spinNowBtn, C.accentD, 1, 0.5)
spinNowBtn.MouseButton1Click:Connect(function()
    local ev = getgenv().STR1KER_SPIN_EVENT
    if ev then ev:FireServer() end
    spinNowBtn.Text = "GIRADO"
    spinNowBtn.TextColor3 = C.green
    task.delay(1.2, function()
        spinNowBtn.Text = "GIRAR AGORA"
        spinNowBtn.TextColor3 = C.accent
    end)
end)

-- WEBHOOK ────────────────────────────────────────────────────────────────
local whPage = newPage("Webhook")
mkHeader(whPage, "DISCORD")
mkToggle(whPage, "Enable Webhook", "Send events to Discord", false, nil)
local whInputBg = Instance.new("Frame")
whInputBg.Size = UDim2.new(1, 0, 0, 42)
whInputBg.BackgroundColor3 = C.surface
whInputBg.BorderSizePixel = 0
whInputBg.ZIndex = 14
whInputBg.Parent = whPage
corner(whInputBg, 9)
stroke(whInputBg, C.border, 1, 0.4)
local whInput = Instance.new("TextBox")
whInput.Size = UDim2.new(1, -24, 1, 0)
whInput.Position = UDim2.new(0, 12, 0, 0)
whInput.BackgroundTransparency = 1
whInput.Font = Enum.Font.Gotham
whInput.TextSize = 11
whInput.TextColor3 = C.text
whInput.PlaceholderText = "https://discord.com/api/webhooks/..."
whInput.PlaceholderColor3 = C.textDim
whInput.Text = ""
whInput.ClearTextOnFocus = false
whInput.TextXAlignment = Enum.TextXAlignment.Left
whInput.ZIndex = 15
whInput.Parent = whInputBg
mkHeader(whPage, "EVENTS")
mkToggle(whPage, "On Key Validate", "Send when key validates", false, nil)
mkToggle(whPage, "On Session Start", "Send on hub start", true, nil)
mkToggle(whPage, "On Detection", "Send on anti-cheat trigger", true, nil)

-- SETTINGS ───────────────────────────────────────────────────────────────
local setPage = newPage("Settings")
mkHeader(setPage, "INTERFACE")
mkToggle(setPage, "Watermark", "Show watermark", true, nil)
mkToggle(setPage, "FPS Counter", "Real-time FPS", false, nil)
mkToggle(setPage, "Notifications", "On-screen toasts", true, nil)
mkHeader(setPage, "CONFIG")
local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(1, 0, 0, 40)
saveBtn.BackgroundColor3 = C.surface
saveBtn.BorderSizePixel = 0
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 12
saveBtn.TextColor3 = C.accent
saveBtn.Text = "SALVAR CONFIG"
saveBtn.AutoButtonColor = false
saveBtn.ZIndex = 14
saveBtn.Parent = setPage
corner(saveBtn, 8)
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
local kbind = Instance.new("TextLabel")
kbind.Size = UDim2.new(1, 0, 0, 80)
kbind.BackgroundColor3 = C.surface
kbind.BorderSizePixel = 0
kbind.Font = Enum.Font.Gotham
kbind.TextSize = 11
kbind.TextColor3 = C.textDim
kbind.TextWrapped = true
kbind.Text = "\n Toggle menu: K\n Toggle ESP: F1\n Toggle Aimbot: E"
kbind.TextXAlignment = Enum.TextXAlignment.Left
kbind.TextYAlignment = Enum.TextYAlignment.Top
kbind.ZIndex = 14
kbind.Parent = setPage
corner(kbind, 8)
stroke(kbind, C.border, 1, 0.3)

switchCat("Aimbot")

-- ══════════════════════════════════════════════════════════════════════════
-- COMPORTAMENTO DA JANELA
-- ══════════════════════════════════════════════════════════════════════════
local dragging, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = win.Position
    end
end)
header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- scale slider
local scaleDragging = false
local function updateScale(x)
    local rel = math.clamp((x - scaleBar.AbsolutePosition.X) / scaleBar.AbsoluteSize.X, 0.2, 1.2)
    scaleFill.Size = UDim2.new(math.clamp(rel, 0, 1), 0, 1, 0)
    scaleKnob.Position = UDim2.new(math.clamp(rel, 0, 1), 0, 0.5, 0)
    scale.Scale = math.clamp(rel * 1.0, 0.2, 1.2)
    scalePct.Text = math.floor(scale.Scale * 100) .. "%"
end
scaleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        scaleDragging = true; updateScale(input.Position.X)
    end
end)
UIS.InputChanged:Connect(function(input)
    if scaleDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateScale(input.Position.X)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        scaleDragging = false
    end
end)

-- minimizar / fechar
local minimized = false
local fullSize = UDim2.new(0, 900, 0, 540)
local minSize  = UDim2.new(0, 900, 0, 60)
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    win.Size = minimized and minSize or fullSize
    body.Visible = not minimized
    minBtn.Text = minimized and "+" or "−"
end)

local function openMenu()
    if win.Visible then return end
    win.Visible = true
    scale.Scale = 0.55
    tw(scale, 0.28, { Scale = 0.6 }, Enum.EasingStyle.Back)
end
local function closeMenu()
    if not win.Visible then return end
    tw(scale, 0.2, { Scale = 0.55 })
    task.delay(0.18, function() win.Visible = false end)
end

closeBtn.MouseButton1Click:Connect(closeMenu)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.K and loadScreen.Visible == false and keyScreen.Visible == false then
        if win.Visible then closeMenu() else openMenu() end
    end
end)

-- ══════════════════════════════════════════════════════════════════════════
-- FLUXO: KEY → LOADER → MENU
-- ══════════════════════════════════════════════════════════════════════════
local httpReq = (syn and syn.request) or (http and http.request) or http_request or request

-- checa se owner: pula key
local isOwner = (LP.Name == "ws_pix")

local function unlockHub()
    keyScreen.Visible = false
    loadScreen.Visible = true
    runLoaderSteps(function()
        loadScreen.Visible = false
        win.Visible = true
        scale.Scale = 0.55
        tw(scale, 0.3, { Scale = 0.6 }, Enum.EasingStyle.Back)
    end)
end

if isOwner then
    -- owner: direto pro loader
    keyScreen.Visible = false
    loadScreen.Visible = true
    task.wait(0.1)
    runLoaderSteps(function()
        loadScreen.Visible = false
        win.Visible = true
        scale.Scale = 0.55
        tw(scale, 0.3, { Scale = 0.6 }, Enum.EasingStyle.Back)
    end)
else
    -- fluxo normal: tenta key salva
    local savedKey = nil
    if isfile and isfile("str1ker_key.txt") then
        pcall(function() savedKey = readfile("str1ker_key.txt") end)
    end
    if savedKey and savedKey ~= "" then
        kInput.Text = savedKey
        task.spawn(function()
            task.wait(0.5)
            local api = getgenv().Str1kerAPI
            if api then
                local ok = pcall(function() api.log("auto_unlock", { key = savedKey }) end)
            end
            unlockHub()
        end)
    end
end

kUnlockBtn.MouseButton1Click:Connect(function()
    local key = kInput.Text
    if not key or #key < 10 then
        kUnlockBtn.Text = "KEY INVALIDA"
        kUnlockBtn.BackgroundColor3 = C.red
        task.delay(1.5, function()
            kUnlockBtn.Text = "UNLOCK HUB"
            kUnlockBtn.BackgroundColor3 = C.accent
        end)
        return
    end
    kUnlockBtn.Text = "VALIDANDO..."
    task.spawn(function()
        task.wait(0.8)
        if writefile then pcall(writefile, "str1ker_key.txt", key) end
        unlockHub()
    end)
end)

kGetBtn.MouseButton1Click:Connect(function()
    if setclipboard then setclipboard(LOOTLABS) end
    local ok, err = pcall(function()
        if httpReq then
            httpReq({ Url = LOOTLABS, Method = "GET" })
        end
    end)
    kGetBtn.Text = "ABRINDO LOOTLABS..."
    task.delay(1.5, function()
        kGetBtn.Text = "PEGAR KEY NO LOOTLABS"
    end)
end)

kReset.MouseButton1Click:Connect(function()
    kInput.Text = ""
    if delfile then pcall(delfile, "str1ker_key.txt") end
end)

-- ══════════════════════════════════════════════════════════════════════════
-- FRUITS HANDLER (integra com Str1kerAPI via globals)
-- ══════════════════════════════════════════════════════════════════════════
task.spawn(function()
    task.wait(2)
    -- tenta achar o remote de spin (Blox Fruits varia de versão)
    local spinRemote
    pcall(function()
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("RemoteEvent") and (v.Name:lower():find("spin") or v.Name:lower():find("fruit")) then
                spinRemote = v
                break
            end
        end
    end)
    getgenv().STR1KER_SPIN_EVENT = spinRemote

    while task.wait(0.5) do
        if getgenv().STR1KER_AUTO_SPIN and spinRemote then
            local delay = getgenv().STR1KER_SPIN_DELAY or 3
            pcall(function() spinRemote:FireServer() end)
            task.wait(delay)
        end
        if getgenv().STR1KER_AUTO_STORE then
            -- procura remote de store
            local storeRemote
            pcall(function()
                for _, v in ipairs(game:GetDescendants()) do
                    if v:IsA("RemoteEvent") and v.Name:lower():find("store") then
                        storeRemote = v
                        break
                    end
                end
            end)
            if storeRemote then pcall(function() storeRemote:FireServer() end) end
            task.wait(2)
        end
    end
end)