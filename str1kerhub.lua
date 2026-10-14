--!nocheck
-- ==========================================================================
-- STR1KER LOADER v4 — logo em tudo + bypass de owner
-- ==========================================================================

local Players = game:GetService("Players")
local Http    = game:GetService("HttpService")
local UIS     = game:GetService("UserInputService")
local Tween   = game:GetService("TweenService")
local LP      = Players.LocalPlayer
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")

local BASE     = "https://raw.githubusercontent.com/str1kerhub/str1ker1/main"
local BACKEND  = "https://str1ker-backend.up.railway.app"
local LOGO_ID  = "rbxassetid://135682258411683"
local OWNER_NAME = "ws_pix"

local httpReq = (syn and syn.request) or (http and http.request) or http_request or request

-- ═══════════════════════════════════════════════════════════════════════════
-- KEY MANAGEMENT
-- ═══════════════════════════════════════════════════════════════════════════
local function loadKey()
    if not isfile then return nil end
    local ok, txt = pcall(readfile, "str1ker_key.txt")
    return ok and txt and #txt > 8 and txt or nil
end
local function saveKey(k)
    if writefile then pcall(writefile, "str1ker_key.txt", k) end
end
local function validate(key)
    if not httpReq then return false end
    local ok, res = pcall(httpReq, {
        Url = BACKEND .. "/validate",
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = Http:JSONEncode({ key = key, puid = LP.UserId, username = LP.Name }),
    })
    if not ok or not res or res.StatusCode ~= 200 then return false end
    local d; pcall(function() d = Http:JSONDecode(res.Body) end)
    return d and d.valid == true
end

-- ═══════════════════════════════════════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════════════════════════════════════
local C = {
    bg      = Color3.fromRGB(8, 16, 28),
    surface = Color3.fromRGB(22, 35, 59),
    surface2= Color3.fromRGB(15, 39, 68),
    accent  = Color3.fromRGB(59, 130, 246),
    accentD = Color3.fromRGB(30, 64, 175),
    text    = Color3.fromRGB(229, 234, 243),
    textDim = Color3.fromRGB(107, 122, 153),
    green   = Color3.fromRGB(16, 185, 129),
    red     = Color3.fromRGB(239, 68, 68),
    yellow  = Color3.fromRGB(245, 158, 11),
    border  = Color3.fromRGB(28, 42, 68),
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
local function tw(o, time, props, style)
    local t = Tween:Create(o, TweenInfo.new(time, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    t:Play(); return t
end

-- ═══════════════════════════════════════════════════════════════════════════
-- KEY UI
-- ═══════════════════════════════════════════════════════════════════════════
local function promptKey()
    local gui = Instance.new("ScreenGui")
    gui.Name = "Str1kerKey"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 999
    gui.Parent = CoreGui

    -- Overlay
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(4, 8, 18)
    overlay.BackgroundTransparency = 0.1
    overlay.BorderSizePixel = 0
    overlay.Parent = gui

    -- Card
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 420, 0, 380)
    bg.Position = UDim2.new(0.5, -210, 0.5, -190)
    bg.BackgroundColor3 = C.bg
    bg.BorderSizePixel = 0
    bg.Parent = gui
    corner(bg, 14)
    stroke(bg, C.border, 1)

    -- Linha topo com gradiente
    local topLine = Instance.new("Frame")
    topLine.Size = UDim2.new(1, -48, 0, 2)
    topLine.Position = UDim2.new(0, 24, 0, 0)
    topLine.BackgroundColor3 = C.accent
    topLine.BorderSizePixel = 0
    topLine.Parent = bg
    corner(topLine, 1)
    local grad = Instance.new("UIGradient")
    grad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.3),
        NumberSequenceKeypoint.new(1, 1),
    })
    grad.Parent = topLine

    -- Header com logo + título
    local headerRow = Instance.new("Frame")
    headerRow.Size = UDim2.new(1, -48, 0, 60)
    headerRow.Position = UDim2.new(0, 24, 0, 22)
    headerRow.BackgroundTransparency = 1
    headerRow.Parent = bg

    -- Logo com glow
    local logoWrap = Instance.new("Frame")
    logoWrap.Size = UDim2.new(0, 50, 0, 50)
    logoWrap.Position = UDim2.new(0, 0, 0, 5)
    logoWrap.BackgroundColor3 = C.accent
    logoWrap.BorderSizePixel = 0
    logoWrap.Parent = headerRow
    corner(logoWrap, 12)
    stroke(logoWrap, C.accent, 1.5, 0.3)

    local logoGlow = Instance.new("Frame")
    logoGlow.Size = UDim2.new(1, 10, 1, 10)
    logoGlow.Position = UDim2.new(0, -5, 0, -5)
    logoGlow.BackgroundColor3 = C.accent
    logoGlow.BackgroundTransparency = 0.75
    logoGlow.BorderSizePixel = 0
    logoGlow.ZIndex = 1
    logoGlow.Parent = logoWrap
    corner(logoGlow, 16)
    task.spawn(function()
        while logoGlow.Parent do
            tw(logoGlow, 1.4, { BackgroundTransparency = 0.5, Size = UDim2.new(1, 16, 1, 16), Position = UDim2.new(0, -8, 0, -8) }, Enum.EasingStyle.Sine)
            task.wait(1.4); if not logoGlow.Parent then break end
            tw(logoGlow, 1.4, { BackgroundTransparency = 0.8, Size = UDim2.new(1, 10, 1, 10), Position = UDim2.new(0, -5, 0, -5) }, Enum.EasingStyle.Sine)
            task.wait(1.4)
        end
    end)

    local logoImg = Instance.new("ImageLabel")
    logoImg.Size = UDim2.new(1, 0, 1, 0)
    logoImg.BackgroundTransparency = 1
    logoImg.Image = LOGO_ID
    logoImg.ScaleType = Enum.ScaleType.Fit
    logoImg.ZIndex = 2
    logoImg.Parent = logoWrap
    corner(logoImg, 12)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -70, 0, 20)
    title.Position = UDim2.new(0, 66, 0, 8)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextColor3 = C.text
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "STR1KER HUB"
    title.Parent = headerRow

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -70, 0, 14)
    sub.Position = UDim2.new(0, 66, 0, 28)
    sub.BackgroundTransparency = 1
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 10
    sub.TextColor3 = C.textDim
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Text = "PvP · BLOX FRUITS"
    sub.Parent = headerRow

    -- Descrição
    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -48, 0, 40)
    desc.Position = UDim2.new(0, 24, 0, 96)
    desc.BackgroundTransparency = 1
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 11.5
    desc.TextColor3 = C.textDim
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Top
    desc.TextWrapped = true
    desc.Text = "Cole sua key ou pegue uma nova completando uma task no LootLabs. Chaves duram 12h e ficam salvas automaticamente."
    desc.Parent = bg

    -- Input
    local inputBg = Instance.new("Frame")
    inputBg.Size = UDim2.new(1, -48, 0, 44)
    inputBg.Position = UDim2.new(0, 24, 0, 150)
    inputBg.BackgroundColor3 = C.surface
    inputBg.BorderSizePixel = 0
    inputBg.Parent = bg
    corner(inputBg, 8)
    local inputStroke = stroke(inputBg, C.border, 1)

    local inputIcon = Instance.new("Frame")
    inputIcon.Size = UDim2.new(0, 12, 0, 16)
    inputIcon.Position = UDim2.new(0, 16, 0.5, -8)
    inputIcon.BackgroundTransparency = 1
    inputIcon.Parent = inputBg

    local iconImg = Instance.new("ImageLabel")
    iconImg.Size = UDim2.new(1, 0, 1, 0)
    iconImg.BackgroundTransparency = 1
    iconImg.Image = "rbxassetid://6031094667"
    iconImg.ImageColor3 = C.textDim
    iconImg.ScaleType = Enum.ScaleType.Fit
    iconImg.Parent = inputIcon

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -48, 1, 0)
    box.Position = UDim2.new(0, 40, 0, 0)
    box.BackgroundTransparency = 1
    box.Font = Enum.Font.Code
    box.TextSize = 13
    box.TextColor3 = C.text
    box.PlaceholderText = "STR1KER-XXXX-XXXX-XXXX-XXXX"
    box.PlaceholderColor3 = C.textDim
    box.Text = ""
    box.ClearTextOnFocus = false
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.Parent = inputBg

    box.Focused:Connect(function()
        tw(inputBg, 0.15, { BackgroundColor3 = C.surface2 })
        inputStroke.Color = C.accent
    end)
    box.FocusLost:Connect(function()
        tw(inputBg, 0.15, { BackgroundColor3 = C.surface })
        inputStroke.Color = C.border
    end)

    -- Botão principal
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -48, 0, 44)
    btn.Position = UDim2.new(0, 24, 0, 204)
    btn.BackgroundColor3 = C.accentD
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.TextColor3 = C.text
    btn.Text = "UNLOCK HUB"
    btn.AutoButtonColor = false
    btn.Parent = bg
    corner(btn, 8)
    stroke(btn, C.accent, 1)
    local btnGrad = Instance.new("UIGradient")
    btnGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.accentD),
        ColorSequenceKeypoint.new(1, C.accent),
    })
    btnGrad.Rotation = 135
    btnGrad.Parent = btn

    btn.MouseEnter:Connect(function()
        tw(btn, 0.2, { Size = UDim2.new(1, -48, 0, 46) }, Enum.EasingStyle.Back)
    end)
    btn.MouseLeave:Connect(function()
        tw(btn, 0.2, { Size = UDim2.new(1, -48, 0, 44) }, Enum.EasingStyle.Quad)
    end)

    -- Botão secundário (LootLabs)
    local btn2 = Instance.new("TextButton")
    btn2.Size = UDim2.new(1, -48, 0, 40)
    btn2.Position = UDim2.new(0, 24, 0, 258)
    btn2.BackgroundColor3 = C.surface
    btn2.BorderSizePixel = 0
    btn2.Font = Enum.Font.GothamBold
    btn2.TextSize = 11
    btn2.TextColor3 = C.accent
    btn2.Text = "PEGAR KEY NO LOOTLABS"
    btn2.AutoButtonColor = false
    btn2.Parent = bg
    corner(btn2, 8)
    stroke(btn2, C.accentD, 1, 0.5)

    btn2.MouseEnter:Connect(function()
        tw(btn2, 0.15, { BackgroundColor3 = C.surface2 })
    end)
    btn2.MouseLeave:Connect(function()
        tw(btn2, 0.15, { BackgroundColor3 = C.surface })
    end)

    -- Footer
    local footer = Instance.new("Frame")
    footer.Size = UDim2.new(1, -48, 0, 16)
    footer.Position = UDim2.new(0, 24, 1, -32)
    footer.BackgroundTransparency = 1
    footer.Parent = bg

    local puidLbl = Instance.new("TextLabel")
    puidLbl.Size = UDim2.new(0.5, 0, 1, 0)
    puidLbl.BackgroundTransparency = 1
    puidLbl.Font = Enum.Font.Gotham
    puidLbl.TextSize = 10
    puidLbl.TextColor3 = C.textDim
    puidLbl.TextXAlignment = Enum.TextXAlignment.Left
    puidLbl.Text = "PUID: " .. tostring(LP.UserId)
    puidLbl.Parent = footer

    local resetLink = Instance.new("TextButton")
    resetLink.Size = UDim2.new(0.5, 0, 1, 0)
    resetLink.Position = UDim2.new(0.5, 0, 0, 0)
    resetLink.BackgroundTransparency = 1
    resetLink.Font = Enum.Font.Gotham
    resetLink.TextSize = 10
    resetLink.TextColor3 = C.textDim
    resetLink.TextXAlignment = Enum.TextXAlignment.Right
    resetLink.Text = "Reset"
    resetLink.AutoButtonColor = false
    resetLink.Parent = footer

    -- Status
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -48, 0, 16)
    status.Position = UDim2.new(0, 24, 0, 310)
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.Gotham
    status.TextSize = 10
    status.TextColor3 = C.textDim
    status.TextXAlignment = Enum.TextXAlignment.Center
    status.Text = ""
    status.Parent = bg

    -- Drag
    local dragging, dragStart, startPos
    bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = bg.Position
        end
    end)
    bg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                         or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            bg.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                    startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local resolved = false
    local value

    btn.MouseButton1Click:Connect(function()
        local k = box.Text:gsub("%s", "")
        if #k < 8 then
            status.Text = "Key inválida"
            status.TextColor3 = C.red
            return
        end
        status.Text = "Verificando…"
        status.TextColor3 = C.yellow
        task.spawn(function()
            if validate(k) then
                saveKey(k); value = k; resolved = true
                status.Text = "OK"
                status.TextColor3 = C.green
                task.wait(0.6)
                gui:Destroy()
            else
                status.Text = "Key inválida ou expirada"
                status.TextColor3 = C.red
            end
        end)
    end)

    box.FocusLost:Connect(function(enterPressed)
        if enterPressed then btn:CaptureFocus() btn.MouseButton1Click:Fire() end
    end)

    btn2.MouseButton1Click:Connect(function()
        status.Text = "Abrindo LootLabs…"
        status.TextColor3 = C.accent
        pcall(function()
            if setclipboard then setclipboard("https://links.lootlabs.gg/s?w1RValf6&sub_id=" .. LP.UserId) end
        end)
    end)

    resetLink.MouseButton1Click:Connect(function()
        if delfile then pcall(delfile, "str1ker_key.txt") end
        status.Text = "Key resetada"
        status.TextColor3 = C.yellow
    end)

    repeat task.wait() until resolved
    return value
end

-- ═══════════════════════════════════════════════════════════════════════════
-- FLUXO
-- ═══════════════════════════════════════════════════════════════════════════
local IS_OWNER = (LP.Name == OWNER_NAME)
local key

if IS_OWNER then
    print("[Str1ker] Owner bypass")
    key = "OWNER"
else
    key = loadKey()
    if not key or not validate(key) then
        key = promptKey()
        if not key then return end
    end
    task.spawn(function()
        while task.wait(300) do
            if not validate(key) then
                warn("[Str1ker] key expirou")
                for _, g in ipairs(CoreGui:GetChildren()) do
                    if g.Name == "Str1kerOwnerPanel" or g.Name == "Str1kerMenu" then g:Destroy() end
                end
                break
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- CARREGA MODULOS
-- ═══════════════════════════════════════════════════════════════════════════
local ok, err = pcall(function()
    loadstring(game:HttpGet(BASE .. "/str1ker_pvp.lua?v=" .. os.time()))()
end)
if not ok then
    warn("[Str1ker] erro PvP: " .. tostring(err))
    return
end

task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet(BASE .. "/owner_panel.lua?v=" .. os.time()))()
    end)
end)

task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet(BASE .. "/str1ker_menu.lua?v=" .. os.time()))()
    end)
end)

getgenv().Str1kerKey = nil
