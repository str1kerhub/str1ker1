--!nocheck
-- ==========================================================================
-- STR1KER LOADER v3.2
-- Key UI + Logo + Owner bypass + Auto-update + Anti-dump
-- ==========================================================================

local Players   = game:GetService("Players")
local Http      = game:GetService("HttpService")
local UIS       = game:GetService("UserInputService")
local LP        = Players.LocalPlayer
local CoreGui   = (gethui and gethui()) or game:GetService("CoreGui")

local BASE     = "https://raw.githubusercontent.com/str1kerhub/str1ker1/main"
local BACKEND  = "https://str1ker-backend.up.railway.app"
local LOGO_ID  = "rbxassetid://73606056465798"

-- ⚠️ TROCA PELO SEU NOME DO ROBLOX EXATO
local OWNER_NAME = "ws_pix"

local httpReq = (syn and syn.request) or (http and http.request) or http_request or request

-- ==========================================================================
-- KEY MANAGEMENT
-- ==========================================================================

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

-- ==========================================================================
-- KEY UI (com logo)
-- ==========================================================================

local function promptKey()
    local gui = Instance.new("ScreenGui")
    gui.Name = "Str1kerKey"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 999
    gui.Parent = CoreGui

    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(6, 6, 10)
    overlay.BackgroundTransparency = 0.15
    overlay.BorderSizePixel = 0
    overlay.Parent = gui

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 400, 0, 320)
    bg.Position = UDim2.new(0.5, -200, 0.5, -160)
    bg.BackgroundColor3 = Color3.fromRGB(11, 12, 18)
    bg.BorderSizePixel = 0
    bg.Parent = gui
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 12); c.Parent = bg
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(139, 92, 246)
    s.Thickness = 1.2
    s.Transparency = 0.4
    s.Parent = bg

    local logo = Instance.new("ImageLabel")
    logo.Size = UDim2.new(0, 140, 0, 140)
    logo.Position = UDim2.new(0.5, -70, 0, 14)
    logo.BackgroundTransparency = 1
    logo.Image = LOGO_ID
    logo.ScaleType = Enum.ScaleType.Fit
    logo.Parent = bg

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -24, 0, 20)
    title.Position = UDim2.new(0, 12, 0, 162)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 15
    title.TextColor3 = Color3.fromRGB(139, 92, 246)
    title.Text = "VERIFICAÇÃO"
    title.Parent = bg

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -24, 0, 14)
    sub.Position = UDim2.new(0, 12, 0, 184)
    sub.BackgroundTransparency = 1
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 11
    sub.TextColor3 = Color3.fromRGB(130, 138, 160)
    sub.Text = "Cole sua key para continuar"
    sub.Parent = bg

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -24, 0, 34)
    box.Position = UDim2.new(0, 12, 0, 206)
    box.BackgroundColor3 = Color3.fromRGB(20, 21, 30)
    box.BorderSizePixel = 0
    box.Font = Enum.Font.Code
    box.TextSize = 13
    box.TextColor3 = Color3.fromRGB(232, 234, 240)
    box.PlaceholderText = "STR1KER-XXXX-XXXX-XXXX-XXXX"
    box.Text = ""
    box.ClearTextOnFocus = false
    box.Parent = bg
    local c2 = Instance.new("UICorner"); c2.CornerRadius = UDim.new(0, 6); c2.Parent = box

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -24, 0, 36)
    btn.Position = UDim2.new(0, 12, 0, 250)
    btn.BackgroundColor3 = Color3.fromRGB(38, 30, 80)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.TextColor3 = Color3.fromRGB(139, 92, 246)
    btn.Text = "VERIFICAR"
    btn.Parent = bg
    local c3 = Instance.new("UICorner"); c3.CornerRadius = UDim.new(0, 6); c3.Parent = btn

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -24, 0, 14)
    status.Position = UDim2.new(0, 12, 1, -20)
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.Gotham
    status.TextSize = 10
    status.TextColor3 = Color3.fromRGB(130, 138, 160)
    status.Text = ""
    status.Parent = bg

    local dragging, dragStart, startPos
    bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = bg.Position
        end
    end)
    bg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            bg.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local resolved = false
    local value

    btn.MouseButton1Click:Connect(function()
        local k = box.Text:gsub("%s", "")
        if #k < 8 then
            status.Text = "Key inválida"
            status.TextColor3 = Color3.fromRGB(255, 90, 90)
            return
        end
        status.Text = "Verificando…"
        status.TextColor3 = Color3.fromRGB(255, 200, 0)
        task.spawn(function()
            if validate(k) then
                saveKey(k)
                value = k
                resolved = true
                status.Text = "OK"
                status.TextColor3 = Color3.fromRGB(0, 220, 120)
                task.wait(0.6)
                gui:Destroy()
            else
                status.Text = "Key inválida ou expirada"
                status.TextColor3 = Color3.fromRGB(255, 90, 90)
            end
        end)
    end)

    repeat task.wait() until resolved
    return value
end

-- ==========================================================================
-- FLUXO DE VERIFICAÇÃO (com bypass de owner)
-- ==========================================================================

local IS_OWNER = (LP.Name == OWNER_NAME)
local key

if IS_OWNER then
    -- Owner passa direto, sem key, sem UI, sem validação
    print("[Str1ker] Modo owner ativo — pulando verificação de key.")
    key = "OWNER_BYPASS"
else
    key = loadKey()
    if not key or not validate(key) then
        key = promptKey()
        if not key then return end
    end

    -- Revalidação em background (a cada 5 min)
    task.spawn(function()
        while task.wait(300) do
            if not validate(key) then
                warn("[Str1ker] key expirou")
                for _, g in ipairs(CoreGui:GetChildren()) do
                    if g.Name == "Str1kerOwnerPanel" or g.Name == "Str1kerMenu" then
                        g:Destroy()
                    end
                end
                break
            end
        end
    end)
end

-- ==========================================================================
-- CARREGA PVP
-- ==========================================================================

local ok, err = pcall(function()
    loadstring(game:HttpGet(BASE .. "/str1ker_pvp.lua?v=" .. os.time()))()
end)
if not ok then
    warn("[Str1ker] erro ao carregar PvP: " .. tostring(err))
    return
end

-- ==========================================================================
-- OWNER PANEL
-- ==========================================================================

task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet(BASE .. "/owner_panel.lua?v=" .. os.time()))()
    end)
end)

-- ==========================================================================
-- CARREGA MENU
-- ==========================================================================

task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet(BASE .. "/str1ker_menu.lua?v=" .. os.time()))()
    end)
end)

-- ==========================================================================
-- ANTI-DUMP
-- ==========================================================================

getgenv().Str1kerKey = nil
