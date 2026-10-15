--!nocheck
-- ==========================================================================
-- STR1KER MENU v15 — Aim Smart + Spectate UI controls
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

local HUB_NAME  = "Str1ker Hub"
local DEV_NAME  = "Nyx"
local VERSION   = "V1.0"
local LOGO_ID   = "rbxassetid://135682258411683"
local BACKEND   = "https://str1ker-backend.up.railway.app"
local LOOTLABS  = "https://links.lootlabs.gg/s?w1RValf6"
local OWNER     = "ws_pix"

local C = {
    bg0    = Color3.fromRGB(2, 4, 10),
    bg1    = Color3.fromRGB(5, 10, 21),
    bg2    = Color3.fromRGB(8, 16, 31),
    surface= Color3.fromRGB(15, 30, 51),
    surface2=Color3.fromRGB(20, 40, 68),
    accent = Color3.fromRGB(59, 130, 246),
    accentB= Color3.fromRGB(96, 165, 250),
    accentC= Color3.fromRGB(34, 211, 238),
    text   = Color3.fromRGB(232, 238, 252),
    text2  = Color3.fromRGB(154, 172, 206),
    text3  = Color3.fromRGB(90, 109, 143),
    text4  = Color3.fromRGB(53, 68, 100),
    border = Color3.fromRGB(25, 45, 76),
    border2= Color3.fromRGB(38, 68, 112),
    green  = Color3.fromRGB(16, 185, 129),
    red    = Color3.fromRGB(239, 68, 68),
    white  = Color3.fromRGB(255, 255, 255),
}

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
local function mkList(p, sp)
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, sp or 6)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = p; return l
end
local function tw(o, t, props, style)
    local t2 = TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    t2:Play(); return t2
end
local function getStroke(o) return o:FindFirstChildOfClass("UIStroke") end
local function grad(o, c1, c2, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c1, c2)
    g.Rotation = rot or 0
    g.Parent = o
    return g
end

local gui = Instance.new("ScreenGui")
gui.Name = "Str1kerMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 100
gui.Parent = CoreGui

local overlay = Instance.new("Frame")
overlay.Name = "OverlayLayer"
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundTransparency = 1
overlay.ZIndex = 200
overlay.Parent = gui

-- KEY SCREEN
local keyScreen = Instance.new("Frame")
keyScreen.Size = UDim2.new(1, 0, 1, 0)
keyScreen.BackgroundColor3 = C.bg0
keyScreen.BorderSizePixel = 0
keyScreen.ZIndex = 100
keyScreen.Parent = gui

local kCard = Instance.new("Frame")
kCard.AnchorPoint = Vector2.new(0.5, 0.5)
kCard.Size = UDim2.new(0, 400, 0, 310)
kCard.Position = UDim2.new(0.5, 0, 0.5, 0)
kCard.BackgroundColor3 = C.bg2
kCard.BorderSizePixel = 0
kCard.ZIndex = 101
kCard.Parent = keyScreen
corner(kCard, 16)
stroke(kCard, C.border2, 1)

local kHead = Instance.new("Frame")
kHead.Size = UDim2.new(1, 0, 0, 60)
kHead.BackgroundTransparency = 1
kHead.ZIndex = 102
kHead.Parent = kCard

local kLogo = Instance.new("Frame")
kLogo.Size = UDim2.new(0, 44, 0, 44)
kLogo.Position = UDim2.new(0, 22, 0.5, -22)
kLogo.BackgroundColor3 = C.accent
kLogo.BorderSizePixel = 0
kLogo.ZIndex = 103
kLogo.Parent = kHead
corner(kLogo, 11)
grad(kLogo, C.accent, C.accentC, 45)

local kLogoImg = Instance.new("ImageLabel")
kLogoImg.Size = UDim2.new(1, 0, 1, 0)
kLogoImg.BackgroundTransparency = 1
kLogoImg.Image = LOGO_ID
kLogoImg.ScaleType = Enum.ScaleType.Fit
kLogoImg.ZIndex = 104
kLogoImg.Parent = kLogo
corner(kLogoImg, 11)

local kTitle = Instance.new("TextLabel")
kTitle.Size = UDim2.new(1, -100, 0, 20)
kTitle.Position = UDim2.new(0, 78, 0, 12)
kTitle.BackgroundTransparency = 1
kTitle.Font = Enum.Font.GothamBold
kTitle.TextSize = 15
kTitle.TextColor3 = C.text
kTitle.TextXAlignment = Enum.TextXAlignment.Left
kTitle.Text = HUB_NAME:upper()
kTitle.ZIndex = 102
kTitle.Parent = kHead

local kSub = Instance.new("TextLabel")
kSub.Size = UDim2.new(1, -100, 0, 14)
kSub.Position = UDim2.new(0, 78, 0, 32)
kSub.BackgroundTransparency = 1
kSub.Font = Enum.Font.Gotham
kSub.TextSize = 10
kSub.TextColor3 = C.text3
kSub.TextXAlignment = Enum.TextXAlignment.Left
kSub.Text = "By " .. DEV_NAME .. " · " .. VERSION
kSub.ZIndex = 102
kSub.Parent = kHead

local kDesc = Instance.new("TextLabel")
kDesc.Size = UDim2.new(1, -44, 0, 40)
kDesc.Position = UDim2.new(0, 22, 0, 70)
kDesc.BackgroundTransparency = 1
kDesc.Font = Enum.Font.Gotham
kDesc.TextSize = 11
kDesc.TextColor3 = C.text3
kDesc.TextWrapped = true
kDesc.TextXAlignment = Enum.TextXAlignment.Left
kDesc.TextYAlignment = Enum.TextYAlignment.Top
kDesc.Text = "Paste your key or get a new one by completing a task on LootLabs."
kDesc.ZIndex = 102
kDesc.Parent = kCard

local kField = Instance.new("Frame")
kField.Size = UDim2.new(1, -44, 0, 44)
kField.Position = UDim2.new(0, 22, 0, 116)
kField.BackgroundColor3 = C.surface
kField.BorderSizePixel = 0
kField.ZIndex = 102
kField.Parent = kCard
corner(kField, 9)
stroke(kField, C.border2, 1)

local kIcon = Instance.new("ImageLabel")
kIcon.Size = UDim2.new(0, 14, 0, 14)
kIcon.Position = UDim2.new(0, 14, 0.5, -7)
kIcon.BackgroundTransparency = 1
kIcon.Image = "rbxassetid://6031094667"
kIcon.ImageColor3 = C.text3
kIcon.ScaleType = Enum.ScaleType.Fit
kIcon.ZIndex = 103
kIcon.Parent = kField

local kInput = Instance.new("TextBox")
kInput.Size = UDim2.new(1, -50, 1, 0)
kInput.Position = UDim2.new(0, 38, 0, 0)
kInput.BackgroundTransparency = 1
kInput.Font = Enum.Font.Gotham
kInput.TextSize = 12
kInput.TextColor3 = C.text
kInput.PlaceholderText = "STR1KER-XXXX-XXXX-XXXX"
kInput.PlaceholderColor3 = C.text4
kInput.Text = ""
kInput.ClearTextOnFocus = false
kInput.TextXAlignment = Enum.TextXAlignment.Left
kInput.ZIndex = 103
kInput.Parent = kField

local kUnlock = Instance.new("TextButton")
kUnlock.Size = UDim2.new(1, -44, 0, 44)
kUnlock.Position = UDim2.new(0, 22, 0, 170)
kUnlock.BackgroundColor3 = C.accent
kUnlock.BorderSizePixel = 0
kUnlock.Font = Enum.Font.GothamBold
kUnlock.TextSize = 12
kUnlock.TextColor3 = C.white
kUnlock.Text = "UNLOCK HUB"
kUnlock.AutoButtonColor = false
kUnlock.ZIndex = 102
kUnlock.Parent = kCard
corner(kUnlock, 9)
grad(kUnlock, C.accent, C.accentC, 30)

local kLoot = Instance.new("TextButton")
kLoot.Size = UDim2.new(1, -44, 0, 44)
kLoot.Position = UDim2.new(0, 22, 0, 220)
kLoot.BackgroundColor3 = C.surface
kLoot.BorderSizePixel = 0
kLoot.Font = Enum.Font.GothamBold
kLoot.TextSize = 12
kLoot.TextColor3 = C.text
kLoot.Text = "GET KEY ON LOOTLABS"
kLoot.AutoButtonColor = false
kLoot.ZIndex = 102
kLoot.Parent = kCard
corner(kLoot, 9)
stroke(kLoot, C.border2, 1)

local kFoot = Instance.new("TextLabel")
kFoot.Size = UDim2.new(1, -44, 0, 14)
kFoot.Position = UDim2.new(0, 22, 1, -24)
kFoot.BackgroundTransparency = 1
kFoot.Font = Enum.Font.Gotham
kFoot.TextSize = 10
kFoot.TextColor3 = C.text4
kFoot.TextXAlignment = Enum.TextXAlignment.Left
kFoot.Text = "PUID: " .. tostring(LP.UserId)
kFoot.ZIndex = 102
kFoot.Parent = kCard

-- WINDOW
local win = Instance.new("Frame")
win.AnchorPoint = Vector2.new(0.5, 0.5)
win.Size = UDim2.new(0, 900, 0, 560)
win.Position = UDim2.new(0.5, 0, 0.5, 0)
win.BackgroundColor3 = C.bg1
win.BorderSizePixel = 0
win.ClipsDescendants = true
win.Visible = false
win.ZIndex = 10
win.Parent = gui
corner(win, 16)
stroke(win, C.border2, 1)

local uiscale = Instance.new("UIScale")
uiscale.Scale = 0.7
uiscale.Parent = win

local topLine = Instance.new("Frame")
topLine.Size = UDim2.new(1, -60, 0, 1)
topLine.Position = UDim2.new(0, 30, 0, 0)
topLine.BackgroundColor3 = C.accent
topLine.BorderSizePixel = 0
topLine.ZIndex = 12
topLine.Parent = win
grad(topLine, C.accent, C.accentC, 0)

local topbar = Instance.new("Frame")
topbar.Size = UDim2.new(1, 0, 0, 54)
topbar.BackgroundColor3 = C.bg2
topbar.BorderSizePixel = 0
topbar.ZIndex = 11
topbar.Parent = win

local tbLine = Instance.new("Frame")
tbLine.Size = UDim2.new(1, 0, 0, 1)
tbLine.Position = UDim2.new(0, 0, 1, -1)
tbLine.BackgroundColor3 = C.border
tbLine.BorderSizePixel = 0
tbLine.ZIndex = 12
tbLine.Parent = topbar

local tbBrand = Instance.new("Frame")
tbBrand.Size = UDim2.new(0, 42, 0, 42)
tbBrand.Position = UDim2.new(0, 12, 0.5, -21)
tbBrand.BackgroundTransparency = 1
tbBrand.ZIndex = 12
tbBrand.Parent = topbar

local tbLogo = Instance.new("ImageLabel")
tbLogo.Size = UDim2.new(1, 0, 1, 0)
tbLogo.BackgroundTransparency = 1
tbLogo.Image = LOGO_ID
tbLogo.ScaleType = Enum.ScaleType.Fit
tbLogo.ZIndex = 13
tbLogo.Parent = tbBrand

local tbCenter = Instance.new("Frame")
tbCenter.AnchorPoint = Vector2.new(0.5, 0.5)
tbCenter.Size = UDim2.new(0, 500, 1, 0)
tbCenter.Position = UDim2.new(0.5, 0, 0.5, 0)
tbCenter.BackgroundTransparency = 1
tbCenter.ZIndex = 12
tbCenter.Parent = topbar

local tbTitle = Instance.new("TextLabel")
tbTitle.Size = UDim2.new(1, 0, 1, 0)
tbTitle.BackgroundTransparency = 1
tbTitle.Font = Enum.Font.GothamBold
tbTitle.TextSize = 15
tbTitle.TextColor3 = C.accentB
tbTitle.Text = HUB_NAME .. " By " .. DEV_NAME .. " [Beta]"
tbTitle.ZIndex = 13
tbTitle.Parent = tbCenter
grad(tbTitle, C.accentB, C.accentC, 20)

local scaleBox = Instance.new("Frame")
scaleBox.Size = UDim2.new(0, 130, 0, 26)
scaleBox.Position = UDim2.new(1, -145, 0.5, -13)
scaleBox.BackgroundColor3 = C.bg1
scaleBox.BorderSizePixel = 0
scaleBox.ZIndex = 12
scaleBox.Parent = topbar
corner(scaleBox, 999)
stroke(scaleBox, C.border, 1)

local scaleLbl = Instance.new("TextLabel")
scaleLbl.Size = UDim2.new(0, 34, 1, 0)
scaleLbl.Position = UDim2.new(0, 10, 0, 0)
scaleLbl.BackgroundTransparency = 1
scaleLbl.Font = Enum.Font.GothamBold
scaleLbl.TextSize = 9
scaleLbl.TextColor3 = C.text4
scaleLbl.TextXAlignment = Enum.TextXAlignment.Left
scaleLbl.Text = "SCALE"
scaleLbl.ZIndex = 13
scaleLbl.Parent = scaleBox

local scaleBar = Instance.new("Frame")
scaleBar.Size = UDim2.new(0, 50, 0, 4)
scaleBar.Position = UDim2.new(0, 48, 0.5, -2)
scaleBar.BackgroundColor3 = C.bg0
scaleBar.BorderSizePixel = 0
scaleBar.ZIndex = 13
scaleBar.Parent = scaleBox
corner(scaleBar, 999)

local scaleFill = Instance.new("Frame")
scaleFill.Size = UDim2.new(0.4, 0, 1, 0)
scaleFill.BackgroundColor3 = C.accent
scaleFill.BorderSizePixel = 0
scaleFill.ZIndex = 14
scaleFill.Parent = scaleBar
corner(scaleFill, 999)
grad(scaleFill, C.accent, C.accentC, 0)

local scaleKnob = Instance.new("Frame")
scaleKnob.Size = UDim2.new(0, 10, 0, 10)
scaleKnob.AnchorPoint = Vector2.new(0.5, 0.5)
scaleKnob.Position = UDim2.new(0.4, 0, 0.5, 0)
scaleKnob.BackgroundColor3 = C.white
scaleKnob.BorderSizePixel = 0
scaleKnob.ZIndex = 15
scaleKnob.Parent = scaleBar
corner(scaleKnob, 999)

local scalePct = Instance.new("TextLabel")
scalePct.Size = UDim2.new(0, 28, 1, 0)
scalePct.Position = UDim2.new(1, -32, 0, 0)
scalePct.BackgroundTransparency = 1
scalePct.Font = Enum.Font.GothamBold
scalePct.TextSize = 9
scalePct.TextColor3 = C.accentB
scalePct.TextXAlignment = Enum.TextXAlignment.Right
scalePct.Text = "70%"
scalePct.ZIndex = 13
scalePct.Parent = scaleBox

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0.5, -15)
closeBtn.BackgroundColor3 = C.surface
closeBtn.BorderSizePixel = 0
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.TextColor3 = C.red
closeBtn.Text = "×"
closeBtn.AutoButtonColor = false
closeBtn.ZIndex = 12
closeBtn.Parent = topbar
corner(closeBtn, 8)

local body = Instance.new("Frame")
body.Size = UDim2.new(1, 0, 1, -54)
body.Position = UDim2.new(0, 0, 0, 54)
body.BackgroundTransparency = 1
body.ZIndex = 11
body.Parent = win

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 220, 1, 0)
sidebar.BackgroundColor3 = C.bg0
sidebar.BackgroundTransparency = 0.4
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 12
sidebar.Parent = body
pad(sidebar, 14, 10, 14, 10)

local searchBox = Instance.new("Frame")
searchBox.Size = UDim2.new(1, 0, 0, 34)
searchBox.BackgroundColor3 = C.surface
searchBox.BorderSizePixel = 0
searchBox.ZIndex = 13
searchBox.Parent = sidebar
corner(searchBox, 8)
stroke(searchBox, C.border, 1)

local searchIcon = Instance.new("Frame")
searchIcon.Size = UDim2.new(0, 14, 0, 14)
searchIcon.Position = UDim2.new(0, 12, 0.5, -7)
searchIcon.BackgroundTransparency = 1
searchIcon.ZIndex = 14
searchIcon.Parent = searchBox

local siDot = Instance.new("Frame")
siDot.Size = UDim2.new(0, 9, 0, 9)
siDot.BackgroundColor3 = C.text3
siDot.BorderSizePixel = 0
siDot.ZIndex = 14
siDot.Parent = searchIcon
corner(siDot, 999)
stroke(siDot, C.text3, 1.5)

local siHandle = Instance.new("Frame")
siHandle.Size = UDim2.new(0, 6, 0, 1.5)
siHandle.Position = UDim2.new(0, 8, 0, 10)
siHandle.Rotation = 45
siHandle.BackgroundColor3 = C.text3
siHandle.BorderSizePixel = 0
siHandle.ZIndex = 14
siHandle.Parent = searchIcon

local searchInput = Instance.new("TextBox")
searchInput.Size = UDim2.new(1, -34, 1, 0)
searchInput.Position = UDim2.new(0, 30, 0, 0)
searchInput.BackgroundTransparency = 1
searchInput.Font = Enum.Font.Gotham
searchInput.TextSize = 11
searchInput.TextColor3 = C.text
searchInput.PlaceholderText = "Search..."
searchInput.PlaceholderColor3 = C.text4
searchInput.Text = ""
searchInput.ClearTextOnFocus = false
searchInput.TextXAlignment = Enum.TextXAlignment.Left
searchInput.ZIndex = 14
searchInput.Parent = searchBox

local navContainer = Instance.new("ScrollingFrame")
navContainer.Size = UDim2.new(1, 0, 1, -42)
navContainer.Position = UDim2.new(0, 0, 0, 42)
navContainer.BackgroundTransparency = 1
navContainer.BorderSizePixel = 0
navContainer.ScrollBarThickness = 0
navContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
navContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
navContainer.ZIndex = 13
navContainer.Parent = sidebar
mkList(navContainer, 3)

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -220, 1, 0)
content.Position = UDim2.new(0, 220, 0, 0)
content.BackgroundColor3 = C.bg1
content.BackgroundTransparency = 0.3
content.BorderSizePixel = 0
content.ZIndex = 12
content.Parent = body

local chead = Instance.new("Frame")
chead.Size = UDim2.new(1, 0, 0, 48)
chead.BackgroundColor3 = C.bg2
chead.BorderSizePixel = 0
chead.ZIndex = 13
chead.Parent = content

local cheadLine = Instance.new("Frame")
cheadLine.Size = UDim2.new(1, 0, 0, 1)
cheadLine.Position = UDim2.new(0, 0, 1, -1)
cheadLine.BackgroundColor3 = C.border
cheadLine.BorderSizePixel = 0
cheadLine.ZIndex = 14
cheadLine.Parent = chead

local cheadTitle = Instance.new("TextLabel")
cheadTitle.Size = UDim2.new(1, -60, 1, 0)
cheadTitle.Position = UDim2.new(0, 20, 0, 0)
cheadTitle.BackgroundTransparency = 1
cheadTitle.Font = Enum.Font.GothamBold
cheadTitle.TextSize = 13
cheadTitle.TextColor3 = C.text
cheadTitle.TextXAlignment = Enum.TextXAlignment.Left
cheadTitle.Text = "Aimbot Tab"
cheadTitle.ZIndex = 14
cheadTitle.Parent = chead

local cardsScroll = Instance.new("ScrollingFrame")
cardsScroll.Size = UDim2.new(1, 0, 1, -48)
cardsScroll.Position = UDim2.new(0, 0, 0, 48)
cardsScroll.BackgroundTransparency = 1
cardsScroll.BorderSizePixel = 0
cardsScroll.ScrollBarThickness = 3
cardsScroll.ScrollBarImageColor3 = C.accent
cardsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
cardsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
cardsScroll.ZIndex = 13
cardsScroll.Parent = content
pad(cardsScroll, 12, 16, 12, 16)
mkList(cardsScroll, 6)

-- DROPDOWN OVERLAY
local activeDropdown = nil
local function closeActiveDropdown()
    if activeDropdown then activeDropdown:Destroy(); activeDropdown = nil end
end

local function openDropdown(anchorBtn, options, currentValue, onSelect)
    closeActiveDropdown()
    local pos = anchorBtn.AbsolutePosition
    local size = anchorBtn.AbsoluteSize
    local listHeight = #options * 30 + 10
    local list = Instance.new("Frame")
    list.Size = UDim2.new(0, math.max(size.X, 150), 0, listHeight)
    list.Position = UDim2.new(0, pos.X, 0, pos.Y + size.Y + 4)
    list.BackgroundColor3 = C.bg2
    list.BorderSizePixel = 0
    list.ZIndex = 201
    list.Parent = overlay
    corner(list, 8)
    stroke(list, C.border2, 1)
    pad(list, 5, 5, 5, 5)

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 2)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = list

    for _, opt in ipairs(options) do
        local item = Instance.new("TextButton")
        item.Size = UDim2.new(1, 0, 0, 26)
        item.BackgroundColor3 = (opt == currentValue) and C.surface2 or C.bg2
        item.BorderSizePixel = 0
        item.Font = Enum.Font.Gotham
        item.TextSize = 11
        item.TextColor3 = (opt == currentValue) and C.accentB or C.text2
        item.Text = tostring(opt)
        item.TextXAlignment = Enum.TextXAlignment.Left
        item.AutoButtonColor = false
        item.ZIndex = 202
        item.Parent = list
        corner(item, 5)
        pad(item, 0, 0, 0, 10)
        item.MouseEnter:Connect(function()
            if opt ~= currentValue then item.BackgroundColor3 = C.surface end
        end)
        item.MouseLeave:Connect(function()
            if opt ~= currentValue then item.BackgroundColor3 = C.bg2 end
        end)
        item.MouseButton1Click:Connect(function()
            onSelect(opt)
            closeActiveDropdown()
        end)
    end
    activeDropdown = list
end

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if activeDropdown then
            local mp = input.Position
            local p = activeDropdown.AbsolutePosition
            local s = activeDropdown.AbsoluteSize
            local inside = mp.X >= p.X and mp.X <= p.X + s.X and mp.Y >= p.Y and mp.Y <= p.Y + s.Y
            if not inside then closeActiveDropdown() end
        end
    end
end)

-- CARD BUILDERS
local function mkSection(parent, title)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextColor3 = C.accentB
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.Text = title
    lbl.ZIndex = 14
    lbl.Parent = parent
    return lbl
end

local function mkCard(parent, title, desc)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, desc and 52 or 42)
    row.BackgroundColor3 = C.surface
    row.BorderSizePixel = 0
    row.ZIndex = 14
    row.Parent = parent
    corner(row, 8)
    stroke(row, C.border, 1)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -100, 0, 16)
    t.Position = UDim2.new(0, 14, 0, desc and 9 or 13)
    t.BackgroundTransparency = 1
    t.Font = Enum.Font.GothamBold
    t.TextSize = 12
    t.TextColor3 = C.text
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Text = title
    t.ZIndex = 15
    t.Parent = row

    if desc then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1, -100, 0, 13)
        d.Position = UDim2.new(0, 14, 0, 28)
        d.BackgroundTransparency = 1
        d.Font = Enum.Font.Gotham
        d.TextSize = 10
        d.TextColor3 = C.text3
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Text = desc
        d.ZIndex = 15
        d.Parent = row
    end
    return row
end

local function mkToggle(parent, label, desc, initial, callback)
    local row = mkCard(parent, label, desc)
    local on = initial == true
    local box = Instance.new("TextButton")
    box.Size = UDim2.new(0, 24, 0, 24)
    box.Position = UDim2.new(1, -38, 0.5, -12)
    box.BackgroundColor3 = on and C.accent or C.bg0
    box.BorderSizePixel = 0
    box.Text = on and "✓" or ""
    box.Font = Enum.Font.GothamBold
    box.TextSize = 14
    box.TextColor3 = C.white
    box.AutoButtonColor = false
    box.ZIndex = 16
    box.Parent = row
    corner(box, 5)
    local boxStroke = stroke(box, on and C.accentB or C.border2, 1.5)
    if on then grad(box, C.accent, C.accentC, 45) end
    box.MouseButton1Click:Connect(function()
        on = not on
        if on then
            box.BackgroundColor3 = C.accent
            box.Text = "✓"
            boxStroke.Color = C.accentB
            local g = box:FindFirstChildOfClass("UIGradient")
            if not g then grad(box, C.accent, C.accentC, 45) end
        else
            box.BackgroundColor3 = C.bg0
            box.Text = ""
            boxStroke.Color = C.border2
            local g = box:FindFirstChildOfClass("UIGradient")
            if g then g:Destroy() end
        end
        if callback then callback(on) end
    end)
end

local function mkSlider(parent, label, desc, minV, maxV, initial, step, callback)
    step = step or 0.01
    local row = mkCard(parent, label, desc)
    row.Size = UDim2.new(1, 0, 0, 56)
    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 70, 0, 16)
    valLbl.Position = UDim2.new(1, -84, 0, 12)
    valLbl.BackgroundTransparency = 1
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 11
    valLbl.TextColor3 = C.accentB
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Text = step < 1 and string.format("%.2f", initial) or tostring(math.floor(initial))
    valLbl.ZIndex = 15
    valLbl.Parent = row
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -28, 0, 4)
    bar.Position = UDim2.new(0, 14, 1, -16)
    bar.BackgroundColor3 = C.bg0
    bar.BorderSizePixel = 0
    bar.ZIndex = 15
    bar.Parent = row
    corner(bar, 999)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((initial - minV) / (maxV - minV), 0, 1, 0)
    fill.BackgroundColor3 = C.accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 16
    fill.Parent = bar
    corner(fill, 999)
    grad(fill, C.accent, C.accentC, 0)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new((initial - minV) / (maxV - minV), 0, 0.5, 0)
    knob.BackgroundColor3 = C.white
    knob.BorderSizePixel = 0
    knob.ZIndex = 17
    knob.Parent = bar
    corner(knob, 999)
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
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; update(input.Position.X)
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
    local row = mkCard(parent, label, desc)
    local current = initial or options[1]
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 130, 0, 28)
    btn.Position = UDim2.new(1, -146, 0.5, -14)
    btn.BackgroundColor3 = C.surface2
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = C.text
    btn.Text = current .. "  ▾"
    btn.AutoButtonColor = false
    btn.ZIndex = 16
    btn.Parent = row
    corner(btn, 7)
    stroke(btn, C.border2, 1)
    btn.MouseButton1Click:Connect(function()
        if activeDropdown then closeActiveDropdown(); return end
        openDropdown(btn, options, current, function(opt)
            current = opt
            btn.Text = opt .. "  ▾"
            if callback then callback(opt) end
        end)
    end)
end

local function mkAction(parent, label, desc, btnText, callback)
    local row = mkCard(parent, label, desc)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 90, 0, 28)
    btn.Position = UDim2.new(1, -106, 0.5, -14)
    btn.BackgroundColor3 = C.accent
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = C.white
    btn.Text = btnText
    btn.AutoButtonColor = false
    btn.ZIndex = 16
    btn.Parent = row
    corner(btn, 7)
    grad(btn, C.accent, C.accentC, 30)
    btn.MouseButton1Click:Connect(function()
        local o = btn.Text
        btn.Text = "OK"
        task.delay(0.9, function() btn.Text = o end)
        if callback then callback() end
    end)
end

local function mkInfo(parent, text)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 40)
    row.BackgroundColor3 = C.bg2
    row.BorderSizePixel = 0
    row.ZIndex = 14
    row.Parent = parent
    corner(row, 8)
    stroke(row, C.border, 1)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -24, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 10
    lbl.TextColor3 = C.text2
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.ZIndex = 15
    lbl.Parent = row
end

local function mkText(parent, label, desc, placeholder, initial, callback)
    local row = mkCard(parent, label, desc)
    local inp = Instance.new("TextBox")
    inp.Size = UDim2.new(0, 200, 0, 28)
    inp.Position = UDim2.new(1, -216, 0.5, -14)
    inp.BackgroundColor3 = C.bg0
    inp.BorderSizePixel = 0
    inp.Font = Enum.Font.Gotham
    inp.TextSize = 11
    inp.TextColor3 = C.text
    inp.PlaceholderText = placeholder or ""
    inp.PlaceholderColor3 = C.text4
    inp.Text = initial or ""
    inp.ClearTextOnFocus = false
    inp.TextXAlignment = Enum.TextXAlignment.Left
    inp.ZIndex = 16
    inp.Parent = row
    corner(inp, 7)
    stroke(inp, C.border2, 1)
    pad(inp, 0, 0, 0, 10)
    inp.FocusLost:Connect(function()
        if callback then callback(inp.Text) end
    end)
end

-- SECTIONS + PAGES
local pages = {}
local navBtns = {}

local SECTIONS = {
    { name = "Aimbot",   icon = "⌖" },
    { name = "Target",   icon = "◎" },
    { name = "Combat",   icon = "⚔" },
    { name = "Visuals",  icon = "◉" },
    { name = "Movement", icon = "✥" },
    { name = "Fruits",   icon = "❖" },
    { name = "Webhook",  icon = "◈" },
    { name = "Setting",  icon = "⚙" },
}

local function switchPage(name)
    for n, p in pairs(pages) do p.Visible = (n == name) end
    for _, b in ipairs(navBtns) do
        local s = getStroke(b)
        local bar = b:FindFirstChild("ActiveBar")
        if b.Name == name then
            b.BackgroundColor3 = C.surface
            b.BackgroundTransparency = 0
            b.TextColor3 = C.text
            if s then s.Color = C.border2 s.Transparency = 0 end
            if bar then bar.Visible = true end
        else
            b.BackgroundColor3 = C.bg0
            b.BackgroundTransparency = 1
            b.TextColor3 = C.text2
            if s then s.Color = C.border s.Transparency = 1 end
            if bar then bar.Visible = false end
        end
    end
    cheadTitle.Text = name .. " Tab"
end

for _, def in ipairs(SECTIONS) do
    local btn = Instance.new("TextButton")
    btn.Name = def.name
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = C.bg0
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextColor3 = C.text2
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Text = "  " .. def.icon .. "   " .. def.name
    btn.AutoButtonColor = false
    btn.ZIndex = 14
    btn.Parent = navContainer
    corner(btn, 7)
    stroke(btn, C.border, 1, 1)

    local activeBar = Instance.new("Frame")
    activeBar.Name = "ActiveBar"
    activeBar.Size = UDim2.new(0, 3, 0, 18)
    activeBar.Position = UDim2.new(0, 0, 0.5, -9)
    activeBar.BackgroundColor3 = C.accent
    activeBar.BorderSizePixel = 0
    activeBar.Visible = false
    activeBar.ZIndex = 15
    activeBar.Parent = btn
    corner(activeBar, 999)
    grad(activeBar, C.accent, C.accentC, 90)

    table.insert(navBtns, btn)
    btn.MouseButton1Click:Connect(function() switchPage(def.name) end)
end

local function newPage(name)
    local sc = Instance.new("ScrollingFrame")
    sc.Name = name
    sc.Size = UDim2.new(1, 0, 1, 0)
    sc.BackgroundTransparency = 1
    sc.BorderSizePixel = 0
    sc.ScrollBarThickness = 0
    sc.CanvasSize = UDim2.new(0, 0, 0, 0)
    sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sc.Visible = false
    sc.ZIndex = 14
    sc.Parent = cardsScroll
    mkList(sc, 6)
    pages[name] = sc
    return sc
end

-- AIMBOT
local aim = newPage("Aimbot")
mkSection(aim, "MAIN")
mkToggle(aim, "Aim Assist", "Precise aiming with prediction", CFG.aim.enabled, function(v) API.setAim(v) end)
mkSlider(aim, "Maximum Distance", "Max targeting range", 50, 2000, CFG.aim.max_distance, 10, function(v) CFG.aim.max_distance = v; API.saveCfg() end)
mkSlider(aim, "Movement Prediction", "Prediction lead", 0.03, 0.30, 0.14, 0.01, nil)
mkToggle(aim, "Aggressive Prediction", "Minimum 0.3s lead — better vs laggy targets", CFG.aim.aggressive_prediction, function(v) CFG.aim.aggressive_prediction = v; API.saveCfg() end)
mkSlider(aim, "Aim Transition", "Smoothing", 0.05, 0.95, CFG.aim.smoothing, 0.05, function(v) API.setSmoothing(v) end)
mkDropdown(aim, "Preferred Part", "Target hit part", {"Head", "Torso", "Nearest"}, CFG.aim.aim_part, function(v) API.setAimPart(v) end)
mkToggle(aim, "Hook GetTargetPosition", "Second layer aim hook", CFG.aim.hook_get_target, function(v) CFG.aim.hook_get_target = v; API.saveCfg() end)

mkSection(aim, "AIM SMART")
mkToggle(aim, "Aim Smart", "Adaptive prediction via motion pattern", CFG.aim.smart, function(v) API.setAimSmart(v) end)
mkSlider(aim, "Smart Samples", "History buffer size", 4, 20, CFG.aim.smart_samples, 1, function(v) API.setAimSmartSamples(v) end)
mkSlider(aim, "Strafe Lead", "Extra lead on direction change", 0, 0.2, CFG.aim.smart_strafe_lead, 0.01, function(v) API.setAimSmartStrafeLead(v) end)
mkSlider(aim, "Accel Weight", "Quadratic accel influence", 0, 1, CFG.aim.smart_accel_weight, 0.05, function(v) API.setAimSmartAccelWeight(v) end)
mkInfo(aim, "Smart samples: how many frames of movement to track. Strafe lead adds ms when target changes direction twice.")

mkSection(aim, "FOV")
mkToggle(aim, "Use FOV", "Only target inside circle", true, nil)
mkSlider(aim, "FOV Radius", "Circle size in px", 50, 750, CFG.aim.fov, 10, function(v) API.setFov(v) end)
mkToggle(aim, "Show Circle", "Draw FOV circle", true, nil)

mkSection(aim, "CHECKS")
mkToggle(aim, "Team Check", "Skip teammates", CFG.aim.team_check, function(v) CFG.aim.team_check = v; API.saveCfg() end)
mkSlider(aim, "Resolver", "Movement resolver", 0, 0.5, CFG.aim.resolver, 0.01, function(v) API.setResolver(v) end)

mkSection(aim, "AUTO DODGE")
mkToggle(aim, "Enable Auto Dodge", "Dodge incoming attacks", CFG.dodge.enabled, function(v) API.setDodge(v) end)
mkToggle(aim, "Auto Ken", "Activate Ken on incoming hit", CFG.dodge.auto_ken, function(v) CFG.dodge.auto_ken = v; API.saveCfg() end)
mkToggle(aim, "Ken Trick", "Ken ON/OFF, saves charges", CFG.dodge.kentrick.enabled, function(v) API.setKenTrick(v) end)
mkToggle(aim, "Skip Ken On Breaker", "Don't waste Ken on instinct-breaking attacks", CFG.dodge.skip_ken_on_breaker, function(v) CFG.dodge.skip_ken_on_breaker = v; API.saveCfg() end)
mkToggle(aim, "Learning", "Auto-learn attack latency and cues", CFG.dodge.learning, function(v) API.setLearning(v) end)
mkToggle(aim, "Dodge Log", "Log every dodge trigger in F9", CFG.dodge.log_triggers, function(v) API.setDodgeLog(v) end)
mkAction(aim, "Export Learn Table", "Copy learned data to clipboard", "EXPORT", function() API.learnExport() end)
mkAction(aim, "Wipe Learn Data", "Reset all learned data", "WIPE", function() API.learnWipe() end)

-- TARGET
local tgt = newPage("Target")
mkSection(tgt, "PRIORITY")
mkDropdown(tgt, "Priority", "Selection mode", {"Nearest", "Lowest HP", "Threat"}, "Nearest", nil)
mkSlider(tgt, "Max Target Distance", "Range", 50, 2000, 600, 10, nil)
mkSection(tgt, "FILTERS")
mkToggle(tgt, "Ignore Friends", "Skip Roblox friends", true, nil)
mkToggle(tgt, "Ignore NPCs", "Skip non-player humanoids", true, nil)
mkToggle(tgt, "Ignore Dead", "Skip Health = 0", true, nil)
mkSection(tgt, "ADVANCED")
mkToggle(tgt, "Wall Bang", "Target through walls", false, nil)
mkToggle(tgt, "Auto Switch", "Switch when target dies", true, nil)

-- COMBAT
local cmb = newPage("Combat")
mkSection(cmb, "ATTACK")
mkToggle(cmb, "Auto Attack", "Attack nearest in range", false, nil)
mkToggle(cmb, "Fast Attack", "Remove attack animation delay", false, function(v)
    getgenv().Usefastattack = v
    getgenv().fastattect = v
end)
mkToggle(cmb, "Super Fast Attack", "Accelerated fast attack mode", false, function(v)
    getgenv().SuperFastAttack = v
    if v then
        getgenv().Usefastattack = true
        getgenv().fastattect = true
    end
end)
mkSlider(cmb, "Attack Delay", "Time between attacks (ms)", 1, 300, 10, 1, nil)

mkSection(cmb, "DEFENSE")
mkToggle(cmb, "Auto Dodge", "Evade dangerous attacks", CFG.dodge.enabled, function(v) API.setDodge(v) end)
mkToggle(cmb, "Unbreakable Skills", "Prevent stun cancel", false, nil)

mkSection(cmb, "HAKI")
mkToggle(cmb, "Auto Ken Haki", "Observation Haki — auto activate", false, function(v)
    getgenv().Str1kerAutoKen = v
    CFG.dodge.auto_ken = v
    API.saveCfg()
end)
mkToggle(cmb, "Auto Buso Haki", "Armament Haki — auto activate", false, function(v)
    getgenv().Str1kerAutoBuso = v
end)

mkSection(cmb, "SORU")
mkToggle(cmb, "Show Soru Button", "Floating button", false, nil)
mkSlider(cmb, "Soru Distance", "Max teleport range", 20, 200, 200, 10, nil)
mkToggle(cmb, "Infinite Soru", "Remove cooldown", false, nil)

mkSection(cmb, "RACE")
mkToggle(cmb, "Auto V3", "Use V3 when ready", false, function(v)
    getgenv().Str1kerAutoV3 = v
end)
mkToggle(cmb, "Auto V4", "Transform when full", false, function(v)
    getgenv().Str1kerAutoV4 = v
end)

-- VISUALS
local vis = newPage("Visuals")
mkSection(vis, "PLAYER ESP")
mkToggle(vis, "Enable ESP", "Overlay all players", CFG.esp.enabled, function(v) API.setESP(v) end)
mkToggle(vis, "Box", "Box around character", CFG.esp.box, function(v) CFG.esp.box = v; API.saveCfg() end)
mkToggle(vis, "Name", "Player name", CFG.esp.name, function(v) CFG.esp.name = v; API.saveCfg() end)
mkToggle(vis, "Distance", "Distance in studs", CFG.esp.distance, function(v) CFG.esp.distance = v; API.saveCfg() end)
mkToggle(vis, "Health Bar", "Horizontal HP bar", CFG.esp.health_bar, function(v) CFG.esp.health_bar = v; API.saveCfg() end)
mkToggle(vis, "Tracer", "Line from bottom", CFG.esp.tracer, function(v) CFG.esp.tracer = v; API.saveCfg() end)
mkToggle(vis, "Skeleton", "Bone lines R6/R15", CFG.esp.skeleton, function(v) API.setSkeleton(v) end)
mkToggle(vis, "Text Backdrop", "Dark background behind text", CFG.esp.text_backdrop, function(v) CFG.esp.text_backdrop = v; API.saveCfg() end)
mkSlider(vis, "Max Distance", "ESP render range", 100, 5000, CFG.esp.max_distance, 100, function(v) API.setMaxDist(v) end)

mkSection(vis, "ESP ICONS")
mkToggle(vis, "Enable Icons", "Show icons next to players", CFG.esp.icons, function(v) CFG.esp.icons = v; API.saveCfg() end)
mkToggle(vis, "Weapon Icon", "Show equipped weapon", CFG.esp.icon_weapon, function(v) CFG.esp.icon_weapon = v; API.saveCfg() end)
mkToggle(vis, "Headshot Icon", "Show player headshot", CFG.esp.icon_head, function(v) CFG.esp.icon_head = v; API.saveCfg() end)
mkDropdown(vis, "Icon Position", "Where to place icons", {"Left of Name", "Right of Name", "Above Name", "Below Name"}, CFG.esp.icon_pos, function(v) CFG.esp.icon_pos = v; API.saveCfg() end)
mkSlider(vis, "Icon Size", "Icon pixel size", 16, 64, CFG.esp.icon_size, 2, function(v) CFG.esp.icon_size = v; API.saveCfg() end)
mkSlider(vis, "Icon Spacing", "Space between icons", 2, 20, CFG.esp.icon_spacing, 1, function(v) CFG.esp.icon_spacing = v; API.saveCfg() end)
mkToggle(vis, "Icon Background", "Dark backdrop behind icon", CFG.esp.icon_bg, function(v) CFG.esp.icon_bg = v; API.saveCfg() end)
mkSlider(vis, "Icon Opacity", "Background transparency", 0, 100, CFG.esp.icon_opacity, 5, function(v) CFG.esp.icon_opacity = v; API.saveCfg() end)

mkSection(vis, "SPECTATE")
mkToggle(vis, "Enable Spectate", "Camera follows target", CFG.esp.spectate, function(v) API.setSpectate(v) end)
mkDropdown(vis, "Spectate Mode", "Target selection", {"Nearest", "Aim Target", "Manual"}, CFG.esp.spectate_mode, function(v) API.setSpectateMode(v) end)
mkText(vis, "Manual Target", "Player name (Manual mode only)", "username", CFG.esp.spectate_manual, function(v) API.setSpectateManual(v) end)
mkToggle(vis, "Show Buttons", "Floating SPECTATE + MINI VIEW buttons", CFG.esp.spectate_show_button, function(v) API.setSpectateShowButton(v) end)
mkToggle(vis, "Show Mini Window", "Allow the mini viewport window", CFG.esp.spectate_show_mini, function(v) API.setSpectateShowMini(v) end)
mkSlider(vis, "Mini FOV", "Mini window field of view", 40, 110, CFG.esp.spectate_mini_fov, 5, function(v) API.setSpectateMiniFov(v) end)
mkInfo(vis, "F2 cycle · F3 stop · auto-recovers on death")

mkSection(vis, "ENVIRONMENT")
mkToggle(vis, "Fullbright", "Max lighting", false, nil)
mkToggle(vis, "No Fog", "Remove fog", false, nil)
mkToggle(vis, "No Grass", "Hide terrain grass", false, nil)

-- MOVEMENT
local mov = newPage("Movement")
mkSection(mov, "SPEED & JUMP")
mkToggle(mov, "Super Jump", "Increase jump power", CFG.move.super_jump, function(v) API.setSuperJump(v) end)
mkSlider(mov, "Jump Power", "Jump value", 50, 500, CFG.move.jump_power, 5, function(v) API.setJumpPower(v) end)
mkToggle(mov, "Custom Speed", "Override walk speed", CFG.move.custom_speed, function(v) API.setCustomSpeed(v) end)
mkSlider(mov, "WalkSpeed", "Speed value", 16, 500, CFG.move.walk_speed, 1, function(v) API.setWalkSpeed(v) end)
mkSection(mov, "PHASING")
mkToggle(mov, "Walk On Water", "Anchored platform under player", CFG.move.walk_on_water, function(v) API.setWalkOnWater(v) end)
mkToggle(mov, "Infinite Jump", "Jump mid-air", false, nil)

-- FRUITS
local frt = newPage("Fruits")
mkSection(frt, "FRUITS")
mkToggle(frt, "Random Devil Fruit", "Auto spin random fruit gacha", false, function(v)
    getgenv().Str1kerRandomFruit = v
end)
mkToggle(frt, "Auto Store Fruit", "Store inventory fruits automatically", false, function(v)
    getgenv().Str1kerAutoStore = v
end)
mkInfo(frt, "Random Devil Fruit requires a gacha ticket from the Cousin NPC. Auto Store stores fruits in inventory when the storage is not full.")

-- WEBHOOK
local wh = newPage("Webhook")
mkSection(wh, "DISCORD")
mkToggle(wh, "Enable Webhook", "Send events to Discord", false, nil)
mkText(wh, "Webhook URL", "Discord endpoint", "https://discord.com/api/webhooks/...", "", nil)
mkSection(wh, "EVENTS")
mkToggle(wh, "On Key Validate", "Send when key validates", false, nil)
mkToggle(wh, "On Session Start", "Send on hub start", true, nil)
mkToggle(wh, "On Detection", "Send on anti-cheat", true, nil)

-- SETTING
local set = newPage("Setting")
mkSection(set, "INTERFACE")
mkToggle(set, "Watermark", "Show watermark", true, nil)
mkToggle(set, "FPS Counter", "Real-time FPS", false, nil)
mkToggle(set, "Notifications", "On-screen toasts", true, nil)
mkSection(set, "CONFIG")
mkAction(set, "Save Config", "Persist all settings", "SAVE", function() API.saveCfg() end)
mkInfo(set, "Toggle menu: K · Toggle ESP: F1 · Toggle Aimbot: E · Cycle spectate: F2 · Stop spectate: F3")

switchPage("Aimbot")

-- SCALE
local SCALE_MIN, SCALE_MAX = 0.5, 1.0
local function applyScale(s)
    s = math.clamp(s, SCALE_MIN, SCALE_MAX)
    uiscale.Scale = s
    local rel = (s - SCALE_MIN) / (SCALE_MAX - SCALE_MIN)
    scaleFill.Size = UDim2.new(rel, 0, 1, 0)
    scaleKnob.Position = UDim2.new(rel, 0, 0.5, 0)
    scalePct.Text = math.floor(s * 100) .. "%"
end
applyScale(0.7)

local scaleDragging = false
local function updateScale(x)
    local rel = math.clamp((x - scaleBar.AbsolutePosition.X) / scaleBar.AbsoluteSize.X, 0, 1)
    applyScale(SCALE_MIN + (SCALE_MAX - SCALE_MIN) * rel)
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

-- DRAG
local dragging, dragStart, startPos
topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = win.Position
    end
end)
topbar.InputEnded:Connect(function(input)
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

-- OPEN / CLOSE
local function openMenu()
    if win.Visible then return end
    win.Visible = true
    uiscale.Scale = 0.65
    tw(uiscale, 0.25, { Scale = 0.7 }, Enum.EasingStyle.Back)
end
local function closeMenu()
    if not win.Visible then return end
    closeActiveDropdown()
    tw(uiscale, 0.18, { Scale = 0.65 })
    task.delay(0.16, function() win.Visible = false end)
end

closeBtn.MouseButton1Click:Connect(closeMenu)
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.K and not keyScreen.Visible then
        if win.Visible then closeMenu() else openMenu() end
    end
end)

-- KEY FLOW
local function unlockHub()
    keyScreen.Visible = false
    openMenu()
end

if LP.Name == OWNER then
    keyScreen.Visible = false
    openMenu()
end

kUnlock.MouseButton1Click:Connect(function()
    local key = kInput.Text
    if not key or #key < 10 then
        kUnlock.Text = "INVALID KEY"
        kUnlock.BackgroundColor3 = C.red
        local g = kUnlock:FindFirstChildOfClass("UIGradient")
        if g then g:Destroy() end
        task.delay(1.5, function()
            kUnlock.Text = "UNLOCK HUB"
            kUnlock.BackgroundColor3 = C.accent
            grad(kUnlock, C.accent, C.accentC, 30)
        end)
        return
    end
    if writefile then pcall(writefile, "str1ker_key.txt", key) end
    unlockHub()
end)

kLoot.MouseButton1Click:Connect(function()
    if setclipboard then setclipboard(LOOTLABS) end
    kLoot.Text = "OPENING..."
    task.delay(1.5, function() kLoot.Text = "GET KEY ON LOOTLABS" end)
end)

task.spawn(function()
    task.wait(0.3)
    if LP.Name == OWNER then return end
    local saved = nil
    if isfile and isfile("str1ker_key.txt") then
        pcall(function() saved = readfile("str1ker_key.txt") end)
    end
    if saved and saved ~= "" then
        kInput.Text = saved
        unlockHub()
    end
end)