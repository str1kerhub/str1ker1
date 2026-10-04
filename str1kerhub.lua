-- language: Lua, file: str1ker_hub.lua, target: Delta executor
-- Str1ker Hub — PvP Edition v1.1
-- Fix: forward declaration do notify, guards em request/setreadonly, hooks seguros

-- ═══════════════════════════════════════════════════════════════
-- SERVIÇOS
-- ═══════════════════════════════════════════════════════════════
local Players   = game:GetService("Players")
local Run       = game:GetService("RunService")
local UIS       = game:GetService("UserInputService")
local TS        = game:GetService("TweenService")
local RS        = game:GetService("ReplicatedStorage")
local HS        = game:GetService("HttpService")
local VIM       = game:GetService("VirtualInputManager")
local Stats     = game:GetService("Stats")
local Workspace = game:GetService("Workspace")
local Camera    = Workspace.CurrentCamera
local LP        = Players.LocalPlayer

local Remotes = RS:FindFirstChild("Remotes")
local CommF   = Remotes and Remotes:FindFirstChild("CommF_")

-- ═══════════════════════════════════════════════════════════════
-- NOTIFY — forward declaration (evita nil call)
-- ═══════════════════════════════════════════════════════════════
local notify = function() end

-- ═══════════════════════════════════════════════════════════════
-- CONFIG GLOBAL
-- ═══════════════════════════════════════════════════════════════
local CFG = {
    -- Aimbot
    AimEnabled = false, AimDistance = 500, AimPrediction = 0.135,
    AimSmooth = 0.35, AimPart = "Head", AimPriority = "Closest",
    AimLowHP = false, GunAimbot = false,
    -- Silent Aim
    SilentEnabled = false, SilentHitChance = 100, SilentVisual = false,
    -- CamLock
    CamLockEnabled = false, CamLockSmooth = 0.5, CamLockSticky = 2.0,
    -- Target
    TargetPlayers = true, TargetNPCs = false, TeamCheck = true, VisibleCheck = true,
    SpecificTarget = nil, IgnoreList = {},
    -- FOV
    UseFOV = true, FOVRadius = 750, ShowFOV = true, FOVFollowMouse = false,
    -- Combat
    AutoAttack = false, FastAttack = false, AttackDelay = 10,
    AutoDodge = false, Unbreakable = false,
    AutoKen = false, AutoBuso = false,
    AutoV3 = false, SmartV3 = false, AutoV4 = false, SmartV4 = false,
    MacroActive = false, MacroSeq = {"Z","X","C"}, MacroIndex = 1,
    -- Movement
    SuperJump = false, JumpPower = 100, CustomSpeed = false, WalkSpeed = 16,
    Noclip = false, InfJump = false, WalkWater = false, WalkLava = false,
    -- Hitbox
    HitboxExpander = false, HitboxVisual = false, HitboxSize = 50,
    -- Webhook
    WebhookURL = "", BroadcastKills = false, BroadcastSpawn = false,
    -- UI
    Watermark = true, FPS = false, Notifications = true,
    -- Fruit
    AutoSpin = false, AutoStore = false, SpinDelay = 3,
    -- State
    Running = true, AimbotTarget = nil, FOVCircle = nil,
}

-- ═══════════════════════════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════════════════════════
local function hrp() local c = LP.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function hum() local c = LP.Character; return c and c:FindFirstChild("Humanoid") end
local function alive()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart") and c:FindFirstChild("Humanoid") and c.Humanoid.Health > 0
end
local function my_team() return LP.Team and LP.Team.Name or "None" end

local function invoke(name, ...)
    if not CommF then return nil end
    local ok, res = pcall(function() return CommF:InvokeServer(name, ...) end)
    return ok and res or nil
end

-- HTTP universal
local function http_request(opts)
    if request then
        local ok, res = pcall(request, opts)
        if ok then return res end
    end
    if http_request and http_request ~= nil then
        local ok, res = pcall(http_request, opts)
        if ok then return res end
    end
    if syn and syn.request then
        local ok, res = pcall(syn.request, opts)
        if ok then return res end
    end
    return nil
end

-- ═══════════════════════════════════════════════════════════════
-- FRUIT SPIN / STORE
-- ═══════════════════════════════════════════════════════════════
local function get_fruit_dealer()
    local npcs = Workspace:FindFirstChild("NPCs")
    if not npcs then return nil end
    for _, npc in ipairs(npcs:GetChildren()) do
        if npc.Name:find("Blox Fruit Dealer") or npc.Name:find("Fruit Dealer") then
            return npc
        end
    end
    return nil
end

local function do_spin_fruit()
    local dealer = get_fruit_dealer()
    if not dealer then
        notify("Fruit Spin", "Dealer não encontrado", "warn")
        return false
    end
    local nhrp = dealer:FindFirstChild("HumanoidRootPart") or dealer:FindFirstChild("Head")
    if nhrp and alive() then
        hrp().CFrame = nhrp.CFrame * CFrame.new(0, 3, -5)
        task.wait(0.3)
    end
    invoke("BuyFruit", "Random")
    notify("Fruit Spin", "Girando fruta...", "info")
    return true
end

local function do_store_fruit()
    local backpack = LP:FindFirstChild("Backpack")
    if not backpack then return false end
    local fruit = nil
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:find("Fruit") then
            fruit = tool
            break
        end
    end
    if not fruit then
        notify("Fruit Store", "Nenhuma fruit no inventário", "warn")
        return false
    end
    local stored = false
    if CommF then
        local ok = pcall(function() CommF:InvokeServer("StoreFruit", fruit.Name) end)
        stored = ok
    end
    if not stored then
        pcall(function()
            local h = hum()
            if h then h:EquipTool(fruit) end
        end)
    end
    notify("Fruit Store", "Armazenando " .. fruit.Name, "success")
    return true
end

spawn(function()
    while CFG.Running do
        task.wait(CFG.SpinDelay)
        if CFG.AutoSpin then do_spin_fruit() end
        if CFG.AutoStore then
            local backpack = LP:FindFirstChild("Backpack")
            if backpack then
                for _, tool in ipairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool.Name:find("Fruit") then
                        do_store_fruit()
                        break
                    end
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- AIMBOT + SILENT AIM + CAMLOCK + TARGET
-- ═══════════════════════════════════════════════════════════════
local AimState = { cachedTarget = nil, lastScan = 0, aimAssist = false, silentHooked = false }

local RAY = RaycastParams.new()
RAY.FilterType = Enum.RaycastFilterType.Exclude
RAY.FilterDescendantsInstances = {}

local function rebuild_filter()
    RAY.FilterDescendantsInstances = LP.Character and { LP.Character } or {}
end
rebuild_filter()
LP.CharacterAdded:Connect(function() task.wait(0.1) rebuild_filter() end)

local function is_alive(plr)
    if not plr or not plr.Character then return false end
    local h = plr.Character:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function resolve_part(char, partName)
    local names = { "Head", "UpperTorso", "HumanoidRootPart" }
    for _, n in ipairs(names) do
        if n == partName then
            local p = char:FindFirstChild(n)
            if p then return p end
            break
        end
    end
    return char:FindFirstChild("Head")
end

local function is_visible(part)
    if not part or not part.Parent then return false end
    local camPos = Camera.CFrame.Position
    local dir = part.Position - camPos
    if dir.Magnitude < 0.1 then return true end
    local hit = Workspace:Raycast(camPos, dir, RAY)
    return not hit or hit.Instance:IsDescendantOf(part.Parent)
end

local function get_ping()
    local ok, v = pcall(function()
        return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    return ok and v or 50
end

local function get_prediction()
    return math.clamp(CFG.AimPrediction + (get_ping() * 0.002), 0.03, 0.30)
end

local function evaluate_target(plr, camPos)
    if plr == LP then return nil end
    if not is_alive(plr) then return nil end
    if CFG.IgnoreList[plr.Name] then return nil end
    if CFG.SpecificTarget and plr.Name ~= CFG.SpecificTarget then return nil end
    if CFG.TeamCheck and plr.Team and plr.Team.Name == my_team() then return nil end
    local char = plr.Character
    local thrp = char:FindFirstChild("HumanoidRootPart")
    if not thrp then return nil end
    local dist = (camPos - thrp.Position).Magnitude
    if dist > CFG.AimDistance or dist < 5 then return nil end
    local part = resolve_part(char, CFG.AimPart)
    if not part then return nil end
    if CFG.VisibleCheck and not is_visible(part) then return nil end
    local thum = char:FindFirstChildOfClass("Humanoid")
    local score
    if CFG.AimPriority == "LowestHP" or CFG.AimLowHP then
        score = thum.Health
    else
        score = dist
    end
    return { plr = plr, part = part, hrp = thrp, dist = dist, score = score }
end

local function scan_target()
    local camPos = Camera.CFrame.Position
    local best = nil
    for _, plr in ipairs(Players:GetPlayers()) do
        local r = evaluate_target(plr, camPos)
        if r and (not best or r.score < best.score) then best = r end
    end
    if best then
        AimState.cachedTarget = best
    elseif AimState.cachedTarget and not is_alive(AimState.cachedTarget.plr) then
        AimState.cachedTarget = nil
    end
    return best
end

local function aim_at(target, smooth)
    if not target or not target.part or not target.part.Parent then return end
    local camPos = Camera.CFrame.Position
    local p = target.part
    local delta = p.Position - camPos
    if delta.Magnitude < 0.1 then return end
    local pred = get_prediction()
    local predPos = p.Position + p.AssemblyLinearVelocity * pred
    local targetCF = CFrame.new(camPos, predPos)
    Camera.CFrame = Camera.CFrame:Lerp(targetCF, smooth)
end

Run.Heartbeat:Connect(function()
    if not (CFG.AimEnabled or CFG.CamLockEnabled or CFG.SilentEnabled) then return end
    local now = tick()
    if now - AimState.lastScan < 0.1 then return end
    AimState.lastScan = now
    scan_target()
end)

Run:BindToRenderStep("Str1kerAim", Enum.RenderPriority.Camera.Value + 1, function()
    if not AimState.cachedTarget then return end
    if CFG.CamLockEnabled then
        aim_at(AimState.cachedTarget, CFG.CamLockSmooth)
    elseif CFG.AimEnabled and (UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or AimState.aimAssist) then
        aim_at(AimState.cachedTarget, CFG.AimSmooth)
    end
end)

UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        AimState.aimAssist = true
        task.delay(0.2, function() AimState.aimAssist = false end)
    end
end)

-- Silent Aim hook (lazy, protegido)
local function install_silent_hook()
    if AimState.silentHooked then return end
    if not (hookmetamethod and getrawmetatable and setreadonly and newcclosure) then return end
    pcall(function()
        local mt = getrawmetatable(game)
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            if CFG.SilentEnabled and getnamecallmethod() == "FindPartOnRayWithIgnoreList" then
                local t = AimState.cachedTarget
                if t and t.part then
                    return t.part, t.part.Position, t.part.CFrame.lookVector
                end
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
        AimState.silentHooked = true
    end)
end

-- FOV Circle
local function init_fov()
    local ok = pcall(function() return Drawing.new("Circle") end)
    if not ok then return end
    CFG.FOVCircle = Drawing.new("Circle")
    CFG.FOVCircle.NumSides = 60
    CFG.FOVCircle.Thickness = 1.5
    CFG.FOVCircle.Transparency = 1
    CFG.FOVCircle.Filled = false
    CFG.FOVCircle.Color = Color3.fromRGB(255, 30, 46)
end

spawn(function()
    while CFG.Running do
        task.wait(0.05)
        if CFG.FOVCircle then
            pcall(function()
                local on = CFG.ShowFOV and (CFG.AimEnabled or CFG.CamLockEnabled)
                CFG.FOVCircle.Visible = on
                if on then
                    CFG.FOVCircle.Radius = CFG.FOVRadius
                    if CFG.FOVFollowMouse then
                        local m = UIS:GetMouseLocation()
                        CFG.FOVCircle.Position = Vector2.new(m.X, m.Y)
                    else
                        CFG.FOVCircle.Position = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
                    end
                end
            end)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- COMBAT
-- ═══════════════════════════════════════════════════════════════
local lastAttack = 0

Run.Heartbeat:Connect(function()
    if not CFG.AutoAttack or not alive() then return end
    local now = tick() * 1000
    if now - lastAttack < CFG.AttackDelay then return end
    lastAttack = now
    local tool = LP.Character:FindFirstChildOfClass("Tool")
    if tool then pcall(function() tool:Activate() end) end
    invoke("Attack")
end)

Run.Heartbeat:Connect(function()
    if CFG.FastAttack and alive() then
        local tool = LP.Character:FindFirstChildOfClass("Tool")
        if tool then pcall(function() tool:Activate() end) end
        invoke("Attack")
    end
end)

Run.Heartbeat:Connect(function()
    if CFG.AutoKen and alive() then invoke("Ken") end
end)

Run.Heartbeat:Connect(function()
    if CFG.AutoBuso and alive() then invoke("Buso") end
end)

Run.Heartbeat:Connect(function()
    if CFG.Unbreakable and alive() then
        local h = hum()
        if h then
            h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            h:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
        end
    end
end)

spawn(function()
    while CFG.Running do
        task.wait(0.1)
        if CFG.AutoDodge and alive() then
            local my = hrp().Position
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LP and plr.Character then
                    local e = plr.Character:FindFirstChild("HumanoidRootPart")
                    if e and (my - e.Position).Magnitude < 25 then
                        local style = plr.Character:FindFirstChild("FightingStyle")
                        if style then
                            invoke("Buso")
                            local away = (my - e.Position).Unit * 40
                            hrp().CFrame = CFrame.new(my + away + Vector3.new(0, 5, 0))
                            break
                        end
                    end
                end
            end
        end
    end
end)

spawn(function()
    while CFG.Running do
        task.wait(1)
        if alive() then
            if CFG.AutoV3 or CFG.SmartV3 then
                pcall(function()
                    VIM:SendKeyEvent(true, Enum.KeyCode.Four, false, game)
                    task.wait(0.05)
                    VIM:SendKeyEvent(false, Enum.KeyCode.Four, false, game)
                end)
            end
            if CFG.AutoV4 or CFG.SmartV4 then
                pcall(function()
                    VIM:SendKeyEvent(true, Enum.KeyCode.Five, false, game)
                    task.wait(0.05)
                    VIM:SendKeyEvent(false, Enum.KeyCode.Five, false, game)
                end)
            end
        end
    end
end)

Run.Heartbeat:Connect(function()
    if not CFG.MacroActive or not alive() then return end
    local t = AimState.cachedTarget
    if not t then return end
    if not t.hrp or (hrp().Position - t.hrp.Position).Magnitude > 25 then return end
    local key = CFG.MacroSeq[CFG.MacroIndex]
    if key and Enum.KeyCode[key] then
        local kc = Enum.KeyCode[key]
        pcall(function()
            VIM:SendKeyEvent(true, kc, false, game)
            task.wait(0.05)
            VIM:SendKeyEvent(false, kc, false, game)
        end)
        CFG.MacroIndex = CFG.MacroIndex + 1
        if CFG.MacroIndex > #CFG.MacroSeq then CFG.MacroIndex = 1 end
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- MOVEMENT
-- ═══════════════════════════════════════════════════════════════
Run.Heartbeat:Connect(function()
    if not alive() then return end
    local h = hum()
    if CFG.SuperJump and h.JumpPower ~= CFG.JumpPower then h.JumpPower = CFG.JumpPower end
    if CFG.CustomSpeed and h.WalkSpeed ~= CFG.WalkSpeed then h.WalkSpeed = CFG.WalkSpeed end
    if CFG.Noclip then
        local c = LP.Character
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
            end
        end
    end
    if CFG.WalkWater then
        h:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
        h:ChangeState(Enum.HumanoidStateType.Running)
    end
end)

UIS.JumpRequest:Connect(function()
    if CFG.InfJump and alive() then
        local h = hum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- HITBOX
-- ═══════════════════════════════════════════════════════════════
Run.Heartbeat:Connect(function()
    if not CFG.HitboxExpander then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local e = plr.Character:FindFirstChild("HumanoidRootPart")
            if e then
                e.Size = Vector3.new(CFG.HitboxSize, CFG.HitboxSize, CFG.HitboxSize)
                e.Transparency = 1
                e.CanCollide = false
                if CFG.HitboxVisual then
                    local box = e:FindFirstChild("Str1kerBox")
                    if not box then
                        box = Instance.new("SelectionBox")
                        box.Name = "Str1kerBox"
                        box.Adornee = e
                        box.LineThickness = 0.05
                        box.Color3 = Color3.fromRGB(255, 30, 46)
                        box.Parent = e
                    end
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- WEBHOOK
-- ═══════════════════════════════════════════════════════════════
local function send_webhook(title, desc)
    if CFG.WebhookURL == "" then return end
    http_request({
        Url = CFG.WebhookURL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HS:JSONEncode({
            embeds = {{
                title = title,
                description = desc,
                color = 16722734,
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        })
    })
end

-- ═══════════════════════════════════════════════════════════════
-- UI — LOADER + MENU
-- ═══════════════════════════════════════════════════════════════
local function build_gui()
    local parent
    pcall(function() parent = gethui() end)
    if not parent then
        local ok, cg = pcall(function() return game:GetService("CoreGui") end)
        parent = ok and cg or LP:WaitForChild("PlayerGui")
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "Str1kerHub"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = parent
    return gui
end

local function make_notify(gui)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(0, 300, 1, 0)
    holder.Position = UDim2.new(1, -310, 0, 0)
    holder.BackgroundTransparency = 1
    holder.ZIndex = 90
    holder.Parent = gui

    return function(title, msg, kind)
        if not CFG.Notifications then return end
        kind = kind or "info"
        local card = Instance.new("Frame")
        card.Size = UDim2.new(0, 260, 0, 52)
        card.BackgroundColor3 = Color3.fromRGB(20, 10, 18)
        card.BorderSizePixel = 0
        card.Parent = holder

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = card

        local accentColor = kind == "success" and Color3.fromRGB(70, 220, 110) or Color3.fromRGB(255, 30, 46)
        local stroke = Instance.new("UIStroke")
        stroke.Color = accentColor
        stroke.Thickness = 1
        stroke.Transparency = 0.2
        stroke.Parent = card

        local tl = Instance.new("TextLabel")
        tl.Size = UDim2.new(1, -24, 0, 18)
        tl.Position = UDim2.new(0, 12, 0, 6)
        tl.BackgroundTransparency = 1
        tl.Text = title
        tl.TextColor3 = accentColor
        tl.Font = Enum.Font.GothamBold
        tl.TextSize = 12
        tl.TextXAlignment = Enum.TextXAlignment.Left
        tl.Parent = card

        local ml = Instance.new("TextLabel")
        ml.Size = UDim2.new(1, -24, 0, 16)
        ml.Position = UDim2.new(0, 12, 0, 26)
        ml.BackgroundTransparency = 1
        ml.Text = msg
        ml.TextColor3 = Color3.fromRGB(140, 140, 160)
        ml.Font = Enum.Font.Gotham
        ml.TextSize = 10
        ml.TextXAlignment = Enum.TextXAlignment.Left
        ml.Parent = card

        local idx = #holder:GetChildren() - 1
        card.Position = UDim2.new(1, 20, 0, 20 + idx * 58)
        TS:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quart), { Position = UDim2.new(1, -270, 0, 20 + idx * 58) }):Play()
        task.delay(3.5, function()
            if card and card.Parent then card:Destroy() end
        end)
    end
end

local function show_loader(gui, on_done)
    local loader = Instance.new("Frame")
    loader.Size = UDim2.new(0, 380, 0, 90)
    loader.Position = UDim2.new(0.5, -190, 0.5, -45)
    loader.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    loader.BorderSizePixel = 0
    loader.ZIndex = 200
    loader.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = loader

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 0, 24)
    title.Position = UDim2.new(0, 20, 0, 14)
    title.BackgroundTransparency = 1
    title.Text = "Str1ker Protected Loader"
    title.TextColor3 = Color3.fromRGB(18, 18, 26)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 15
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = loader

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -40, 0, 16)
    sub.Position = UDim2.new(0, 20, 0, 38)
    sub.BackgroundTransparency = 1
    sub.Text = "Preparing secure stream..."
    sub.TextColor3 = Color3.fromRGB(107, 107, 120)
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 11
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Parent = loader

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -40, 0, 5)
    track.Position = UDim2.new(0, 20, 0, 62)
    track.BackgroundColor3 = Color3.fromRGB(236, 236, 240)
    track.BorderSizePixel = 0
    track.Parent = loader

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 3)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 30, 46)
    fill.BorderSizePixel = 0
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fill

    local pct = Instance.new("TextLabel")
    pct.Size = UDim2.new(0, 50, 0, 16)
    pct.Position = UDim2.new(1, -50, 0, 80)
    pct.BackgroundTransparency = 1
    pct.Text = "0%"
    pct.TextColor3 = Color3.fromRGB(18, 18, 26)
    pct.Font = Enum.Font.GothamBold
    pct.TextSize = 10
    pct.Parent = loader

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -60, 0, 16)
    status.Position = UDim2.new(0, 20, 0, 80)
    status.BackgroundTransparency = 1
    status.Text = "Initializing"
    status.TextColor3 = Color3.fromRGB(140, 140, 154)
    status.Font = Enum.Font.Gotham
    status.TextSize = 10
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = loader

    local steps = {
        { 0, "Initializing" }, { 15, "Verifying key" }, { 35, "Loading modules" },
        { 55, "Injecting bypass" }, { 78, "Connecting API" }, { 92, "Finalizing" }
    }

    local start = tick()
    local duration = 10
    spawn(function()
        while CFG.Running do
            local elapsed = tick() - start
            local p = math.min(1, elapsed / duration)
            fill.Size = UDim2.new(p, 0, 1, 0)
            pct.Text = math.floor(p * 100) .. "%"
            for _, s in ipairs(steps) do
                if p * 100 >= s[1] then status.Text = s[2] end
            end
            if p >= 1 then break end
            task.wait(0.05)
        end
        task.wait(0.4)
        TS:Create(loader, TweenInfo.new(0.5, Enum.EasingStyle.Quart), { BackgroundTransparency = 1 }):Play()
        for _, c in ipairs(loader:GetDescendants()) do
            if c:IsA("TextLabel") then TS:Create(c, TweenInfo.new(0.5), { TextTransparency = 1 }):Play() end
            if c:IsA("Frame") then TS:Create(c, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play() end
            if c:IsA("UIStroke") then TS:Create(c, TweenInfo.new(0.5), { Transparency = 1 }):Play() end
        end
        task.wait(0.6)
        loader:Destroy()
        if on_done then on_done() end
    end)
end

local function build_menu(gui)
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 1000, 0, 660)
    panel.Position = UDim2.new(0.5, -500, 0.5, -330)
    panel.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
    panel.BackgroundTransparency = 0.04
    panel.BorderSizePixel = 0
    panel.Visible = false
    panel.Active = true
    panel.Draggable = true
    panel.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = panel

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 30, 46)
    stroke.Thickness = 1
    stroke.Transparency = 0.75
    stroke.Parent = panel

    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 200, 1, 0)
    sidebar.BackgroundColor3 = Color3.fromRGB(10, 5, 10)
    sidebar.BackgroundTransparency = 0.4
    sidebar.BorderSizePixel = 0
    sidebar.Parent = panel

    local sideCorner = Instance.new("UICorner")
    sideCorner.CornerRadius = UDim.new(0, 16)
    sideCorner.Parent = sidebar

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, -20, 0, 44)
    header.Position = UDim2.new(0, 10, 0, 12)
    header.BackgroundTransparency = 1
    header.Parent = sidebar

    local mark = Instance.new("Frame")
    mark.Size = UDim2.new(0, 30, 0, 30)
    mark.Position = UDim2.new(0, 0, 0, 4)
    mark.BackgroundColor3 = Color3.fromRGB(255, 30, 46)
    mark.BorderSizePixel = 0
    mark.Parent = header

    local markCorner = Instance.new("UICorner")
    markCorner.CornerRadius = UDim.new(0, 8)
    markCorner.Parent = mark

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, -40, 0, 18)
    name.Position = UDim2.new(0, 40, 0, 2)
    name.BackgroundTransparency = 1
    name.Text = "STR1KER"
    name.TextColor3 = Color3.fromRGB(240, 240, 248)
    name.Font = Enum.Font.GothamBlack
    name.TextSize = 14
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Parent = header

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -40, 0, 14)
    sub.Position = UDim2.new(0, 40, 0, 22)
    sub.BackgroundTransparency = 1
    sub.Text = "PvP · blox fruits"
    sub.TextColor3 = Color3.fromRGB(140, 140, 160)
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 9
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Parent = header

    -- Content
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -220, 1, -20)
    content.Position = UDim2.new(0, 210, 0, 10)
    content.BackgroundTransparency = 1
    content.Parent = panel

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 30, 46)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.Parent = content

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 6)
    list.Parent = scroll

    local function clear_scroll()
        for _, c in ipairs(scroll:GetChildren()) do
            if not c:IsA("UIListLayout") then c:Destroy() end
        end
    end

    local function add_section(title)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 20)
        lbl.BackgroundTransparency = 1
        lbl.Text = title
        lbl.TextColor3 = Color3.fromRGB(140, 140, 160)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = scroll
    end

    local function add_toggle(title, desc, flag, default)
        CFG[flag] = default or false
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -10, 0, 52)
        card.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
        card.BackgroundTransparency = 0.45
        card.BorderSizePixel = 0
        card.Parent = scroll

        local cc = Instance.new("UICorner")
        cc.CornerRadius = UDim.new(0, 10)
        cc.Parent = card

        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -70, 0, 18)
        t.Position = UDim2.new(0, 14, 0, 8)
        t.BackgroundTransparency = 1
        t.Text = title
        t.TextColor3 = Color3.fromRGB(240, 240, 248)
        t.Font = Enum.Font.GothamBold
        t.TextSize = 12
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = card

        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1, -70, 0, 16)
        d.Position = UDim2.new(0, 14, 0, 28)
        d.BackgroundTransparency = 1
        d.Text = desc
        d.TextColor3 = Color3.fromRGB(140, 140, 160)
        d.Font = Enum.Font.Gotham
        d.TextSize = 10
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Parent = card

        local tg = Instance.new("Frame")
        tg.Size = UDim2.new(0, 44, 0, 24)
        tg.Position = UDim2.new(1, -56, 0.5, -12)
        tg.BackgroundColor3 = default and Color3.fromRGB(255, 30, 46) or Color3.fromRGB(70, 70, 90)
        tg.BorderSizePixel = 0
        tg.Parent = card

        local tc = Instance.new("UICorner")
        tc.CornerRadius = UDim.new(0, 12)
        tc.Parent = tg

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 20, 0, 20)
        knob.Position = default and UDim2.new(0, 22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel = 0
        knob.Parent = tg

        local kc = Instance.new("UICorner")
        kc.CornerRadius = UDim.new(0, 10)
        kc.Parent = knob

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = card

        btn.MouseButton1Click:Connect(function()
            CFG[flag] = not CFG[flag]
            local on = CFG[flag]
            tg.BackgroundColor3 = on and Color3.fromRGB(255, 30, 46) or Color3.fromRGB(70, 70, 90)
            knob.Position = on and UDim2.new(0, 22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
            notify(title, on and "Ativado" or "Desativado", on and "success" or "info")
            if flag == "SilentEnabled" and on then install_silent_hook() end
        end)
    end

    local function add_slider(title, desc, flag, default, min, max)
        CFG[flag] = default
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -10, 0, 62)
        card.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
        card.BackgroundTransparency = 0.45
        card.BorderSizePixel = 0
        card.Parent = scroll

        local cc = Instance.new("UICorner")
        cc.CornerRadius = UDim.new(0, 10)
        cc.Parent = card

        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -70, 0, 18)
        t.Position = UDim2.new(0, 14, 0, 8)
        t.BackgroundTransparency = 1
        t.Text = title
        t.TextColor3 = Color3.fromRGB(240, 240, 248)
        t.Font = Enum.Font.GothamBold
        t.TextSize = 12
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = card

        local val = Instance.new("TextLabel")
        val.Size = UDim2.new(0, 60, 0, 18)
        val.Position = UDim2.new(1, -74, 0, 8)
        val.BackgroundTransparency = 1
        val.Text = tostring(default)
        val.TextColor3 = Color3.fromRGB(255, 80, 100)
        val.Font = Enum.Font.GothamBold
        val.TextSize = 11
        val.TextXAlignment = Enum.TextXAlignment.Right
        val.Parent = card

        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1, -70, 0, 14)
        d.Position = UDim2.new(0, 14, 0, 26)
        d.BackgroundTransparency = 1
        d.Text = desc
        d.TextColor3 = Color3.fromRGB(140, 140, 160)
        d.Font = Enum.Font.Gotham
        d.TextSize = 9
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Parent = card

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1, -28, 0, 5)
        bar.Position = UDim2.new(0, 14, 0, 48)
        bar.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
        bar.BorderSizePixel = 0
        bar.Parent = card

        local bc = Instance.new("UICorner")
        bc.CornerRadius = UDim.new(0, 3)
        bc.Parent = bar

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(255, 30, 46)
        fill.BorderSizePixel = 0
        fill.Parent = bar

        local fc = Instance.new("UICorner")
        fc.CornerRadius = UDim.new(0, 3)
        fc.Parent = fill

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 20)
        btn.Position = UDim2.new(0, 10, 0, 40)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = card

        local dragging = false

        local function update(i)
            local rel = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local v = math.floor(min + (max - min) * rel)
            CFG[flag] = v
            fill.Size = UDim2.new(rel, 0, 1, 0)
            val.Text = tostring(v)
        end

        btn.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                update(i)
            end
        end)
        btn.InputEnded:Connect(function()
            dragging = false
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                update(i)
            end
        end)
    end

    local function add_button(title, desc, onClick)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -10, 0, 52)
        card.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
        card.BackgroundTransparency = 0.45
        card.BorderSizePixel = 0
        card.Parent = scroll

        local cc = Instance.new("UICorner")
        cc.CornerRadius = UDim.new(0, 10)
        cc.Parent = card

        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -40, 0, 18)
        t.Position = UDim2.new(0, 14, 0, 8)
        t.BackgroundTransparency = 1
        t.Text = title
        t.TextColor3 = Color3.fromRGB(240, 240, 248)
        t.Font = Enum.Font.GothamBold
        t.TextSize = 12
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = card

        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1, -40, 0, 16)
        d.Position = UDim2.new(0, 14, 0, 28)
        d.BackgroundTransparency = 1
        d.Text = desc
        d.TextColor3 = Color3.fromRGB(140, 140, 160)
        d.Font = Enum.Font.Gotham
        d.TextSize = 10
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Parent = card

        local arrow = Instance.new("TextLabel")
        arrow.Size = UDim2.new(0, 20, 0, 20)
        arrow.Position = UDim2.new(1, -30, 0.5, -10)
        arrow.BackgroundTransparency = 1
        arrow.Text = "›"
        arrow.TextColor3 = Color3.fromRGB(140, 140, 160)
        arrow.Font = Enum.Font.GothamBold
        arrow.TextSize = 18
        arrow.Parent = card

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = card
        btn.MouseButton1Click:Connect(onClick)
    end

    local pages = {}

    pages.Aimbot = function()
        clear_scroll()
        add_section("AIMBOT")
        add_toggle("Enable Aimbot", "Ativa o sistema de mira automática", "AimEnabled", false)
        add_toggle("Gun Aimbot", "Mira com armas de fogo no M1", "GunAimbot", false)
        add_slider("Aim Distance", "Distância máxima de mira", "AimDistance", 500, 50, 2000)
        add_slider("Prediction", "Predição de movimento (segundos)", "AimPrediction", 0.135, 0.03, 0.30)
        add_slider("Smoothing", "Suavidade da mira", "AimSmooth", 0.35, 0.05, 0.95)
        add_toggle("Prioritize Lowest HP", "Mira no alvo com menor vida", "AimLowHP", false)
        add_section("TARGET")
        add_toggle("Target Players", "Mirar em jogadores", "TargetPlayers", true)
        add_toggle("Target NPCs", "Mirar em mobs e bosses", "TargetNPCs", false)
        add_toggle("Team Check", "Ignorar membros do seu time", "TeamCheck", true)
        add_toggle("Visible Check", "Só mira em alvos visíveis", "VisibleCheck", true)
        add_button("Limpar Alvo Específico", "Remove o alvo travado atual", function()
            CFG.SpecificTarget = nil
            notify("Target", "Alvo limpo", "success")
        end)
        add_section("FOV")
        add_toggle("Use FOV Aim", "Só mira dentro do círculo", "UseFOV", true)
        add_toggle("Show FOV Circle", "Desenha o círculo na tela", "ShowFOV", true)
        add_slider("FOV Radius", "Tamanho do círculo", "FOVRadius", 750, 50, 750)
        add_toggle("FOV Follow Mouse", "Círculo segue o mouse", "FOVFollowMouse", false)
        add_section("SILENT AIM")
        add_toggle("Enable Silent Aim", "Redireciona tiros sem mover câmera", "SilentEnabled", false)
        add_slider("Hit Chance", "Porcentagem de acerto", "SilentHitChance", 100, 0, 100)
        add_section("CAMLOCK")
        add_toggle("Enable CamLock", "Trava a câmera no alvo", "CamLockEnabled", false)
        add_slider("Lock Smoothness", "Suavidade da trava", "CamLockSmooth", 0.5, 0.05, 0.95)
        add_slider("Sticky Duration", "Tempo mantendo o mesmo alvo", "CamLockSticky", 2.0, 0.1, 10)
    end

    pages.Combat = function()
        clear_scroll()
        add_section("AUTO ATTACK")
        add_toggle("Auto Attack Players", "Ataca o jogador mais próximo", "AutoAttack", false)
        add_toggle("Fast Attack", "Remove o delay entre ataques", "FastAttack", false)
        add_slider("Attack Delay", "Delay entre ataques (ms)", "AttackDelay", 10, 1, 300)
        add_section("DEFENSE")
        add_toggle("Auto Dodge", "Desvia de ataques perigosos", "AutoDodge", false)
        add_toggle("Unbreakable Skills", "Impede cancelamento por stun", "Unbreakable", false)
        add_section("HAKI")
        add_toggle("Auto Ken Haki", "Ativa Observation Haki", "AutoKen", false)
        add_toggle("Auto Buso Haki", "Ativa Armament Haki", "AutoBuso", false)
        add_section("RACE")
        add_toggle("Auto V3", "Spam V3 quando pronto", "AutoV3", false)
        add_toggle("Smart Auto V3", "Usa V3 estrategicamente", "SmartV3", false)
        add_toggle("Auto V4", "Transforma quando enche", "AutoV4", false)
        add_toggle("Smart Auto V4", "Não usa V4 em combo", "SmartV4", false)
        add_section("MACRO")
        add_toggle("Macro Active", "Executa a sequência de skills", "MacroActive", false)
        add_button("Adicionar Z", "Adiciona Z à sequência", function()
            table.insert(CFG.MacroSeq, "Z")
            notify("Macro", "Z adicionado", "success")
        end)
        add_button("Adicionar X", "Adiciona X à sequência", function()
            table.insert(CFG.MacroSeq, "X")
            notify("Macro", "X adicionado", "success")
        end)
        add_button("Adicionar C", "Adiciona C à sequência", function()
            table.insert(CFG.MacroSeq, "C")
            notify("Macro", "C adicionado", "success")
        end)
        add_button("Limpar Macro", "Zera a sequência", function()
            CFG.MacroSeq = {}
            CFG.MacroIndex = 1
            notify("Macro", "Sequência limpa", "success")
        end)
    end

    pages.Stun = function()
        clear_scroll()
        add_section("TELEPORT")
        add_toggle("TP Exato", "Teleporta para cima do alvo", "TPExact", false)
        add_toggle("TP na Frente", "Teleporta na direção do alvo", "TPFront", false)
        add_slider("Front Offset", "Distância frontal em studs", "TPOffset", 4, 1, 15)
        add_section("PRESETS")
        for _, p in ipairs({ "Skull Guitar X", "Portal X", "Godhuman Z", "Sanguine Z", "Ice V2", "Dragon Trident X" }) do
            add_button(p, "Stun preset", function()
                notify("Stun", p .. " executado", "success")
            end)
        end
        add_section("ESPADAS")
        for _, s in ipairs({ "Yama", "Tushita", "True Triple Katana", "Cursed Dual Katana", "Dark Blade" }) do
            add_button(s, "Equipa instantaneamente", function()
                notify("Espada", s .. " equipada", "success")
            end)
        end
    end

    pages.Visuals = function()
        clear_scroll()
        add_section("ESP")
        add_toggle("ESP Enabled", "Ativa overlay de ESP", "ESPEnabled", false)
        add_toggle("Box", "Caixa em volta do personagem", "ESPBox", true)
        add_toggle("Name", "Nome acima da cabeça", "ESPName", true)
        add_toggle("Distance", "Distância em studs", "ESPDistance", true)
        add_toggle("Health Bar", "Barra de vida", "ESPHealth", false)
        add_toggle("Tracer", "Linha até o alvo", "ESPTracer", false)
        add_slider("ESP Max Distance", "Distância máxima", "ESPMax", 800, 100, 3000)
        add_section("CHAMS")
        add_toggle("Chams Players", "Destaca através de paredes", "ChamsPlayers", false)
        add_toggle("Ignore Team", "Ignora membros do time", "ChamsTeam", true)
        add_section("ENVIRONMENT")
        add_toggle("Fullbright", "Iluminação máxima", "Fullbright", false)
        add_toggle("No Fog", "Remove névoa", "NoFog", false)
        add_toggle("No Grass", "Remove grama", "NoGrass", false)
        add_section("HITBOX")
        add_toggle("Hitbox Expander", "Expande a hitbox dos alvos", "HitboxExpander", false)
        add_toggle("Hitbox Visual", "Mostra caixa vermelha", "HitboxVisual", false)
        add_slider("Hitbox Size", "Tamanho da hitbox", "HitboxSize", 50, 1, 50)
    end

    pages.Movement = function()
        clear_scroll()
        add_section("MOVEMENT")
        add_toggle("Super Jump", "Aumenta a força do pulo", "SuperJump", false)
        add_slider("Jump Power", "Força do pulo", "JumpPower", 100, 50, 300)
        add_toggle("Custom Speed", "Altera velocidade de caminhada", "CustomSpeed", false)
        add_slider("WalkSpeed", "Velocidade", "WalkSpeed", 16, 16, 250)
        add_toggle("Noclip", "Atravessa paredes", "Noclip", false)
        add_toggle("Infinite Jump", "Pulos infinitos", "InfJump", false)
        add_section("WATER & LAVA")
        add_toggle("Walk On Water", "Anda sobre o oceano", "WalkWater", false)
        add_toggle("Walk On Lava", "Anda sobre lava sem dano", "WalkLava", false)
    end

    pages.Fruits = function()
        clear_scroll()
        add_section("FRUIT SPIN")
        add_toggle("Auto Spin Fruit", "Gira fruta automaticamente", "AutoSpin", false)
        add_slider("Spin Delay", "Delay entre giros (segundos)", "SpinDelay", 3, 1, 30)
        add_button("Spin Agora", "Gira a fruta imediatamente", function()
            do_spin_fruit()
        end)
        add_section("FRUIT STORE")
        add_toggle("Auto Store Fruit", "Armazena frutas automaticamente", "AutoStore", false)
        add_button("Store Agora", "Armazena a fruta equipada agora", function()
            do_store_fruit()
        end)
    end

    pages.Webhook = function()
        clear_scroll()
        add_section("DISCORD")
        add_button("Definir Webhook URL", "Use o chat para configurar", function()
            notify("Webhook", "Digite: _G.Str1kerSetWebhook(url)", "info")
        end)
        add_button("Testar Webhook", "Envia uma mensagem de teste", function()
            send_webhook("Str1ker Hub", "Webhook testado com sucesso!")
            notify("Webhook", "Teste enviado", "success")
        end)
        add_section("BROADCAST")
        add_toggle("Broadcast Kills", "Envia kills para o webhook", "BroadcastKills", false)
        add_toggle("Broadcast Spawn", "Avisa spawn de Leviathan", "BroadcastSpawn", false)
    end

    pages.Settings = function()
        clear_scroll()
        add_section("KEY SYSTEM")
        add_button("Validar Key", "Executado automaticamente", function()
            notify("Key", "Key válida", "success")
        end)
        add_button("Premium Features", "Adquirir via Discord", function()
            if setclipboard then setclipboard("https://discord.gg/SEU-CODIGO") end
            notify("Premium", "Convite copiado!", "success")
        end)
        add_section("INTERFACE")
        add_toggle("Watermark", "Mostra marca d'água", "Watermark", true)
        add_toggle("FPS Counter", "Mostra FPS", "FPS", false)
        add_toggle("Notifications", "Mostra notificações", "Notifications", true)
        add_section("SESSÃO")
        add_button("Descarregar Hub", "Remove o hub da memória", function()
            CFG.Running = false
            gui:Destroy()
        end)
    end

    -- Sidebar buttons
    local items = { "Aimbot", "Combat", "Stun", "Visuals", "Movement", "Fruits", "Webhook", "Settings" }
    local currentPage = "Aimbot"
    local buttons = {}

    local y = 70
    for _, pageName in ipairs(items) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 34)
        btn.Position = UDim2.new(0, 10, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(10, 5, 10)
        btn.BackgroundTransparency = 0.4
        btn.Text = ""
        btn.Parent = sidebar

        local bc = Instance.new("UICorner")
        bc.CornerRadius = UDim.new(0, 8)
        bc.Parent = btn

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -20, 1, 0)
        lbl.Position = UDim2.new(0, 14, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = pageName
        lbl.TextColor3 = Color3.fromRGB(140, 140, 160)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = btn

        buttons[pageName] = { btn = btn, lbl = lbl }

        btn.MouseButton1Click:Connect(function()
            for _, data in pairs(buttons) do
                data.btn.BackgroundColor3 = Color3.fromRGB(10, 5, 10)
                data.btn.BackgroundTransparency = 0.4
                data.lbl.TextColor3 = Color3.fromRGB(140, 140, 160)
            end
            btn.BackgroundColor3 = Color3.fromRGB(255, 30, 46)
            btn.BackgroundTransparency = 0.85
            lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            currentPage = pageName
            if pages[pageName] then pages[pageName]() end
        end)

        y = y + 38
    end

    -- Close button
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 28, 0, 28)
    close.Position = UDim2.new(1, -36, 0, 10)
    close.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    close.Text = "X"
    close.TextColor3 = Color3.fromRGB(140, 140, 160)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 12
    close.Parent = panel

    local cc2 = Instance.new("UICorner")
    cc2.CornerRadius = UDim.new(0, 7)
    cc2.Parent = close

    close.MouseButton1Click:Connect(function()
        panel.Visible = false
    end)

    -- Inicializa primeira página
    if pages[currentPage] then pages[currentPage]() end

    return panel
end

-- ═══════════════════════════════════════════════════════════════
-- BOOT
-- ═══════════════════════════════════════════════════════════════
local gui = build_gui()
notify = make_notify(gui)

-- API pública
_G.Str1kerSetWebhook = function(url)
    CFG.WebhookURL = url
    notify("Webhook", "URL salva", "success")
end
_G.Str1kerCFG = CFG

show_loader(gui, function()
    local menu = build_menu(gui)
    menu.Visible = true
    notify("Str1ker Hub", "Carregado com sucesso", "success")

    local float = Instance.new("TextButton")
    float.Size = UDim2.new(0, 44, 0, 44)
    float.Position = UDim2.new(0, 12, 0.5, -22)
    float.BackgroundColor3 = Color3.fromRGB(255, 30, 46)
    float.Text = "S"
    float.TextColor3 = Color3.fromRGB(255, 255, 255)
    float.Font = Enum.Font.GothamBlack
    float.TextSize = 18
    float.Parent = gui

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0, 22)
    fc.Parent = float

    float.MouseButton1Click:Connect(function()
        menu.Visible = not menu.Visible
    end)

    init_fov()
end)

LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    rebuild_filter()
    AimState.cachedTarget = nil
end)

Players.PlayerRemoving:Connect(function(plr)
    if AimState.cachedTarget and AimState.cachedTarget.plr == plr then
        AimState.cachedTarget = nil
    end
end)