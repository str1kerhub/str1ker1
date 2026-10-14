--!nocheck
-- ==========================================================================
-- STR1KER OWNER PANEL v2
-- Só renderiza para LocalPlayer.Name == OWNER_NAME
-- ==========================================================================

local OWNER_NAME   = "ws_pix"
local BACKEND_URL  = "https://str1ker-backend.up.railway.app"
local ADMIN_SECRET = "COLOQUE_SUA_ADMIN_SECRET_AQUI"
local LOGO_ID      = "rbxassetid://73606056465798"

local Players          = game:GetService("Players")
local HttpService      = game:GetService("HttpService")
local UIS              = game:GetService("UserInputService")
local LocalPlayer      = Players.LocalPlayer

if LocalPlayer.Name ~= OWNER_NAME then return end

local httpReq = (syn and syn.request) or (http and http.request)
             or http_request or request
if not httpReq then warn("[Owner] executor sem request()") return end

-- ------------------------- API -------------------------
local function api(path, method, body)
    local ok, res = pcall(function()
        return httpReq({
            Url = BACKEND_URL .. path,
            Method = method or "GET",
            Headers = {
                ["Content-Type"]   = "application/json",
                ["x-admin-secret"] = ADMIN_SECRET,
            },
            Body = body and HttpService:JSONEncode(body) or nil,
        })
    end)
    if not ok or not res then return nil, "network" end
    local dec; pcall(function() dec = HttpService:JSONDecode(res.Body) end)
    if res.StatusCode ~= 200 then
        return nil, (dec and dec.error) or ("HTTP " .. tostring(res.StatusCode))
    end
    return dec, nil
end

-- ------------------------- UI -------------------------
local parentGui = (gethui and gethui()) or game:GetService("CoreGui")
local gui = Instance.new("ScreenGui")
gui.Name = "Str1kerOwnerPanel"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999
gui.Parent = parentGui

local function corner(obj, r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r) c.Parent=obj end
local function stroke(obj, col, th, tr) local s=Instance.new("UIStroke") s.Color=col s.Thickness=th or 1 s.Transparency=tr or 0 s.Parent=obj end

-- Botão flutuante (com logo)
local openBtn = Instance.new("ImageButton")
openBtn.Size = UDim2.new(0, 38, 0, 38)
openBtn.Position = UDim2.new(0, 86, 0, 5)
openBtn.BackgroundColor3 = Color3.fromRGB(11, 12, 18)
openBtn.BorderSizePixel = 0
openBtn.Image = LOGO_ID
openBtn.ScaleType = Enum.ScaleType.Fit
openBtn.AutoButtonColor = false
openBtn.Parent = gui
corner(openBtn, 8)
stroke(openBtn, Color3.fromRGB(139, 92, 246), 1.5, 0.3)

-- Painel
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 420, 0, 0)
panel.Position = UDim2.new(0, 8, 0, 50)
panel.BackgroundColor3 = Color3.fromRGB(11, 12, 18)
panel.BorderSizePixel = 0
panel.Visible = false
panel.AutomaticSize = Enum.AutomaticSize.Y
panel.Parent = gui
corner(panel, 10)
stroke(panel, Color3.fromRGB(139, 92, 246), 1, 0.6)

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 12); pad.PaddingBottom = UDim.new(0, 12)
pad.PaddingLeft = UDim.new(0, 14); pad.PaddingRight = UDim.new(0, 14)
pad.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = panel

-- Header com logo + título
local headerRow = Instance.new("Frame")
headerRow.BackgroundTransparency = 1
headerRow.Size = UDim2.new(1, 0, 0, 36)
headerRow.Parent = panel

local headerLogo = Instance.new("ImageLabel")
headerLogo.Size = UDim2.new(0, 36, 0, 36)
headerLogo.Position = UDim2.new(0, 0, 0, 0)
headerLogo.BackgroundTransparency = 1
headerLogo.Image = LOGO_ID
headerLogo.ScaleType = Enum.ScaleType.Fit
headerLogo.Parent = headerRow

local headerText = Instance.new("TextLabel")
headerText.BackgroundTransparency = 1
headerText.Size = UDim2.new(1, -44, 0, 20)
headerText.Position = UDim2.new(0, 44, 0, 0)
headerText.Font = Enum.Font.GothamBold
headerText.TextSize = 15
headerText.TextColor3 = Color3.fromRGB(139, 92, 246)
headerText.TextXAlignment = Enum.TextXAlignment.Left
headerText.Text = "Str1ker · Owner Panel"
headerText.Parent = headerRow

local sub = Instance.new("TextLabel")
sub.BackgroundTransparency = 1
sub.Size = UDim2.new(1, -44, 0, 14)
sub.Position = UDim2.new(0, 44, 0, 20)
sub.Font = Enum.Font.Gotham
sub.TextSize = 11
sub.TextColor3 = Color3.fromRGB(100, 108, 130)
sub.TextXAlignment = Enum.TextXAlignment.Left
sub.Text = "Gera keys no backend. Só você vê isso."
sub.Parent = headerRow

-- Linha de duração
local durRow = Instance.new("Frame")
durRow.BackgroundTransparency = 1
durRow.Size = UDim2.new(1, 0, 0, 32)
durRow.Parent = panel

local function mkBox(parent, w, pos, ph, default)
    local b = Instance.new("TextBox")
    b.Size = UDim2.new(w, -6, 1, 0)
    b.Position = UDim2.new(pos, 0, 0, 0)
    b.BackgroundColor3 = Color3.fromRGB(20, 21, 30)
    b.BorderSizePixel = 0
    b.Text = default
    b.PlaceholderText = ph
    b.TextColor3 = Color3.fromRGB(232, 234, 240)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.ClearTextOnFocus = false
    b.Parent = parent
    corner(b, 6)
    return b
end

local durBox   = mkBox(durRow, 0.30, 0, "Qtd", "7")
local countBox = mkBox(durRow, 0.25, 0.75, "Nº", "1")

local unitBtn = Instance.new("TextButton")
unitBtn.Size = UDim2.new(0.45, -6, 1, 0)
unitBtn.Position = UDim2.new(0.30, 0, 0, 0)
unitBtn.BackgroundColor3 = Color3.fromRGB(24, 26, 38)
unitBtn.BorderSizePixel = 0
unitBtn.Text = "Dias ▾"
unitBtn.TextColor3 = Color3.fromRGB(200, 205, 220)
unitBtn.Font = Enum.Font.GothamBold
unitBtn.TextSize = 13
unitBtn.Parent = durRow
corner(unitBtn, 6)

local unitOptions = {
    { label = "Horas",   hours = 1 },
    { label = "Dias",    hours = 24 },
    { label = "Semanas", hours = 24 * 7 },
    { label = "Meses",   hours = 24 * 30 },
}
local unitIdx = 2

unitBtn.MouseButton1Click:Connect(function()
    unitIdx = unitIdx % #unitOptions + 1
    unitBtn.Text = unitOptions[unitIdx].label .. " ▾"
end)

-- Botão gerar
local genBtn = Instance.new("TextButton")
genBtn.Size = UDim2.new(1, 0, 0, 34)
genBtn.BackgroundColor3 = Color3.fromRGB(38, 30, 80)
genBtn.BorderSizePixel = 0
genBtn.Text = "GERAR KEYS"
genBtn.TextColor3 = Color3.fromRGB(139, 92, 246)
genBtn.Font = Enum.Font.GothamBold
genBtn.TextSize = 13
genBtn.Parent = panel
corner(genBtn, 6)
stroke(genBtn, Color3.fromRGB(139, 92, 246), 1, 0.5)

-- Área de resultado
local resultArea = Instance.new("ScrollingFrame")
resultArea.Size = UDim2.new(1, 0, 0, 180)
resultArea.BackgroundTransparency = 1
resultArea.BorderSizePixel = 0
resultArea.ScrollBarThickness = 3
resultArea.ScrollBarImageColor3 = Color3.fromRGB(139, 92, 246)
resultArea.CanvasSize = UDim2.new(0, 0, 0, 0)
resultArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
resultArea.Parent = panel

local rList = Instance.new("UIListLayout")
rList.Padding = UDim.new(0, 4)
rList.SortOrder = Enum.SortOrder.LayoutOrder
rList.Parent = resultArea

-- Status
local status = Instance.new("TextLabel")
status.BackgroundTransparency = 1
status.Size = UDim2.new(1, 0, 0, 16)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextColor3 = Color3.fromRGB(110, 118, 145)
status.TextXAlignment = Enum.TextXAlignment.Left
status.Text = "Pronto."
status.Parent = panel

-- ------------------------- Helpers -------------------------
local function pushStatus(text, color)
    status.Text = text
    status.TextColor3 = color or Color3.fromRGB(110, 118, 145)
end

local function addKeyRow(keyText, durationLabel)
    local row = Instance.new("Frame")
    row.BackgroundColor3 = Color3.fromRGB(16, 18, 26)
    row.BorderSizePixel = 0
    row.Size = UDim2.new(1, 0, 0, 46)
    row.Parent = resultArea
    corner(row, 6)

    local keyLbl = Instance.new("TextLabel")
    keyLbl.BackgroundTransparency = 1
    keyLbl.Size = UDim2.new(1, -12, 0, 20)
    keyLbl.Position = UDim2.new(0, 8, 0, 4)
    keyLbl.Font = Enum.Font.Code
    keyLbl.TextSize = 13
    keyLbl.TextColor3 = Color3.fromRGB(0, 212, 255)
    keyLbl.TextXAlignment = Enum.TextXAlignment.Left
    keyLbl.Text = keyText
    keyLbl.Parent = row

    local durLbl = Instance.new("TextLabel")
    durLbl.BackgroundTransparency = 1
    durLbl.Size = UDim2.new(0.6, 0, 0, 14)
    durLbl.Position = UDim2.new(0, 8, 0, 24)
    durLbl.Font = Enum.Font.Gotham
    durLbl.TextSize = 10
    durLbl.TextColor3 = Color3.fromRGB(110, 118, 145)
    durLbl.TextXAlignment = Enum.TextXAlignment.Left
    durLbl.Text = durationLabel
    durLbl.Parent = row

    local copy = Instance.new("TextButton")
    copy.Size = UDim2.new(0, 62, 0, 24)
    copy.Position = UDim2.new(1, -70, 0, 11)
    copy.BackgroundColor3 = Color3.fromRGB(14, 30, 46)
    copy.BorderSizePixel = 0
    copy.Text = "Copiar"
    copy.TextColor3 = Color3.fromRGB(0, 212, 255)
    copy.Font = Enum.Font.GothamBold
    copy.TextSize = 11
    copy.Parent = row
    corner(copy, 4)
    copy.MouseButton1Click:Connect(function()
        setclipboard(keyText)
        copy.Text = "OK!"
        task.delay(1.2, function() copy.Text = "Copiar" end)
    end)
end

-- ------------------------- Drag do painel -------------------------
local dragging, dragStart, startPos
headerRow.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = panel.Position
    end
end)
headerRow.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ------------------------- Ações -------------------------
openBtn.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
end)

genBtn.MouseButton1Click:Connect(function()
    local amount  = tonumber(durBox.Text) or 0
    local count   = math.clamp(tonumber(countBox.Text) or 1, 1, 50)
    local unitDef = unitOptions[unitIdx]
    local hours   = math.floor(amount * unitDef.hours)
    if hours <= 0 then
        pushStatus("Duração inválida.", Color3.fromRGB(255, 90, 90))
        return
    end

    pushStatus("Gerando " .. count .. " key(s)…", Color3.fromRGB(255, 200, 60))

    local data, err = api("/admin/create", "POST", {
        hours = hours,
        count = count,
    })

    if err then
        pushStatus("Erro: " .. tostring(err), Color3.fromRGB(255, 90, 90))
        return
    end

    local keys = (data and (data.keys or data.data and data.data.keys)) or (data and data.key and { data.key })
    if not keys or #keys == 0 then
        pushStatus("Backend respondeu sem keys.", Color3.fromRGB(255, 90, 90))
        return
    end

    for _, child in ipairs(resultArea:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local labelDur = ("%d %s (%dh)"):format(amount, unitDef.label:lower(), hours)
    for i, k in ipairs(keys) do
        addKeyRow(k, labelDur)
    end
    pushStatus(("Geradas %d key(s) · %s"):format(#keys, labelDur), Color3.fromRGB(0, 204, 102))
    setclipboard(table.concat(keys, "\n"))
end)

-- Keybind opcional (RightShift)
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        panel.Visible = not panel.Visible
    end
end)

pushStatus("Pronto. Painel do dono carregado.", Color3.fromRGB(0, 204, 102))
