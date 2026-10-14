--!nocheck
-- ==========================================================================
-- STR1KER ESP v2
-- Box + HealthBar + Name + Distance + Tracer + Skeleton
-- Baseado no padrão do menu de referência
-- ==========================================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local Workspace        = game:GetService("Workspace")
local Camera           = Workspace.CurrentCamera
local LocalPlayer      = Players.LocalPlayer

-- ------------------------- Configuração -------------------------
local ESP_CFG = {
    enabled          = true,
    box              = true,
    health_bar       = true,
    name             = true,
    distance         = true,
    level            = true,
    tracer           = true,
    skeleton         = true,
    team_check       = true,
    max_distance     = 1500,

    -- Cores
    enemy_color      = Color3.fromRGB(255, 60, 60),
    team_color       = Color3.fromRGB(60, 255, 120),
    box_thickness    = 1.5,
    health_green     = Color3.fromRGB(0, 230, 100),
    health_yellow    = Color3.fromRGB(255, 200, 0),
    health_red       = Color3.fromRGB(255, 50, 50),
    name_color       = Color3.fromRGB(255, 255, 255),
    distance_color   = Color3.fromRGB(180, 190, 210),
    tracer_color     = Color3.fromRGB(255, 255, 255),
    skeleton_color   = Color3.fromRGB(255, 255, 255),
}

getgenv().ESP_CFG = ESP_CFG

-- ------------------------- Drawing API -------------------------
local DrawNew = (Drawing and Drawing.new) or (syn and syn.drawing and syn.drawing.new) or (Krnl and Krnl.Drawing and Krnl.Drawing.new)
if not DrawNew then warn("[ESP] Drawing API não encontrada") return end

local V2 = Vector2.new
local V3 = Vector3.new

-- Cache de ESP por jogador
local espCache = {}

-- ------------------------- Helpers -------------------------
local function worldToViewport(pos)
    local screen, onScreen = Camera:WorldToViewportPoint(pos)
    return screen, onScreen, screen.Z
end

local function createDrawing(class)
    local ok, d = pcall(DrawNew, class)
    if not ok then return nil end
    d.Visible = false
    d.Transparency = 1
    return d
end

-- ------------------------- Criação de ESP -------------------------
local function createESP(player)
    if player == LocalPlayer then return end

    local esp = {
        box       = createDrawing("Square"),
        box_out   = createDrawing("Square"),
        hp_bg     = createDrawing("Square"),
        hp_fill   = createDrawing("Square"),
        name      = createDrawing("Text"),
        distance  = createDrawing("Text"),
        level     = createDrawing("Text"),
        tracer    = createDrawing("Line"),
        -- Skeleton
        sk_head   = createDrawing("Line"),
        sk_torso  = createDrawing("Line"),
        sk_arm_l  = createDrawing("Line"),
        sk_arm_r  = createDrawing("Line"),
        sk_leg_l  = createDrawing("Line"),
        sk_leg_r  = createDrawing("Line"),
    }

    -- Configuração base
    if esp.box then
        esp.box.Filled = false
        esp.box.Thickness = ESP_CFG.box_thickness
        esp.box_out.Filled = false
        esp.box_out.Thickness = ESP_CFG.box_thickness + 1
    end

    if esp.hp_bg then
        esp.hp_bg.Filled = true
        esp.hp_bg.Color = Color3.fromRGB(0, 0, 0)
        esp.hp_bg.Transparency = 0.5
        esp.hp_fill.Filled = true
        esp.hp_fill.Color = ESP_CFG.health_green
    end

    if esp.name then
        esp.name.Size = 14
        esp.name.Center = true
        esp.name.Outline = true
        esp.name.OutlineColor = Color3.fromRGB(0, 0, 0)
        esp.name.Font = 2 -- GothamBold
        esp.name.Color = ESP_CFG.name_color
    end

    if esp.distance then
        esp.distance.Size = 12
        esp.distance.Center = true
        esp.distance.Outline = true
        esp.distance.OutlineColor = Color3.fromRGB(0, 0, 0)
        esp.distance.Font = 2
        esp.distance.Color = ESP_CFG.distance_color
    end

    if esp.level then
        esp.level.Size = 11
        esp.level.Center = true
        esp.level.Outline = true
        esp.level.OutlineColor = Color3.fromRGB(0, 0, 0)
        esp.level.Font = 2
        esp.level.Color = Color3.fromRGB(200, 200, 255)
    end

    if esp.tracer then
        esp.tracer.Thickness = 1
        esp.tracer.Color = ESP_CFG.tracer_color
    end

    -- Skeleton lines
    for _, line in pairs({esp.sk_head, esp.sk_torso, esp.sk_arm_l, esp.sk_arm_r, esp.sk_leg_l, esp.sk_leg_r}) do
        if line then
            line.Thickness = 1.2
            line.Color = ESP_CFG.skeleton_color
        end
    end

    espCache[player] = esp
end

-- ------------------------- Remoção -------------------------
local function removeESP(player)
    local esp = espCache[player]
    if not esp then return end
    for _, d in pairs(esp) do
        if d and d.Remove then
            pcall(function() d:Remove() end)
        end
    end
    espCache[player] = nil
end

-- ------------------------- Skeleton Helper -------------------------
local function getSkeletonPoints(char)
    local head = char:FindFirstChild("Head")
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local lArm = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm")
    local rArm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
    local lLeg = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg")
    local rLeg = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg")

    if not head or not torso or not hrp then return nil end

    return {
        head  = head.Position,
        torso = torso.Position,
        hrp   = hrp.Position,
        lArm  = lArm and lArm.Position or nil,
        rArm  = rArm and rArm.Position or nil,
        lLeg  = lLeg and lLeg.Position or nil,
        rLeg  = rLeg and rLeg.Position or nil,
    }
end

-- ------------------------- Update por Frame -------------------------
RunService.RenderStepped:Connect(function()
    if not ESP_CFG.enabled then
        for _, esp in pairs(espCache) do
            for _, d in pairs(esp) do
                if d then d.Visible = false end
            end
        end
        return
    end

    for player, esp in pairs(espCache) do
        local char = player.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if not char or not humanoid or not hrp or humanoid.Health <= 0 then
            for _, d in pairs(esp) do
                if d then d.Visible = false end
            end
            continue
        end

        local myChar = LocalPlayer.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then continue end

        local dist = (hrp.Position - myHRP.Position).Magnitude
        if dist > ESP_CFG.max_distance then
            for _, d in pairs(esp) do
                if d then d.Visible = false end
            end
            continue
        end

        -- Team check
        local isEnemy = true
        if ESP_CFG.team_check and player.Team and LocalPlayer.Team then
            isEnemy = (player.Team ~= LocalPlayer.Team)
        end

        local baseColor = isEnemy and ESP_CFG.enemy_color or ESP_CFG.team_color

        -- Head e Feet positions
        local headPos = hrp.Position + V3(0, 3, 0)
        local feetPos = hrp.Position - V3(0, 2.5, 0)

        local headScreen, headOn, headZ = worldToViewport(headPos)
        local feetScreen, feetOn, feetZ = worldToViewport(feetPos)

        if not headOn or not feetOn or headZ <= 0 then
            for _, d in pairs(esp) do
                if d then d.Visible = false end
            end
            continue
        end

        -- Box dimensions
        local h = math.abs(headScreen.Y - feetScreen.Y)
        local w = h * 0.6
        local x = headScreen.X - w / 2
        local y = headScreen.Y

        -- Box
        if esp.box then
            esp.box.Size = V2(w, h)
            esp.box.Position = V2(x, y)
            esp.box.Color = baseColor
            esp.box.Visible = ESP_CFG.box

            esp.box_out.Size = V2(w + 2, h + 2)
            esp.box_out.Position = V2(x - 1, y - 1)
            esp.box_out.Color = Color3.fromRGB(0, 0, 0)
            esp.box_out.Visible = ESP_CFG.box
        end

        -- Health bar
        if esp.hp_bg then
            local hpRatio = humanoid.Health / humanoid.MaxHealth
            local hpHeight = h
            local hpWidth = 3

            esp.hp_bg.Size = V2(hpWidth, hpHeight)
            esp.hp_bg.Position = V2(x - 8, y)
            esp.hp_bg.Visible = ESP_CFG.health_bar

            local hpColor = ESP_CFG.health_green
            if hpRatio < 0.3 then hpColor = ESP_CFG.health_red
            elseif hpRatio < 0.6 then hpColor = ESP_CFG.health_yellow end

            esp.hp_fill.Size = V2(hpWidth, hpHeight * hpRatio)
            esp.hp_fill.Position = V2(x - 8, y + hpHeight * (1 - hpRatio))
            esp.hp_fill.Color = hpColor
            esp.hp_fill.Visible = ESP_CFG.health_bar
        end

        -- Name
        if esp.name then
            esp.name.Text = player.Name
            esp.name.Position = V2(headScreen.X, y - 32)
            esp.name.Color = baseColor
            esp.name.Visible = ESP_CFG.name
        end

        -- Distance
        if esp.distance then
            esp.distance.Text = string.format("%dm", math.floor(dist))
            esp.distance.Position = V2(headScreen.X, y - 18)
            esp.distance.Visible = ESP_CFG.distance
        end

        -- Level
        if esp.level then
            local lvl = "?"
            local data = player:FindFirstChild("Data")
            if data and data:FindFirstChild("Level") then
                lvl = tostring(data.Level.Value)
            end
            esp.level.Text = "Lv " .. lvl
            esp.level.Position = V2(headScreen.X, y + h + 4)
            esp.level.Visible = ESP_CFG.level
        end

        -- Tracer
        if esp.tracer then
            esp.tracer.From = V2(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            esp.tracer.To = V2(feetScreen.X, feetScreen.Y)
            esp.tracer.Color = baseColor
            esp.tracer.Visible = ESP_CFG.tracer
        end

        -- Skeleton
        if ESP_CFG.skeleton then
            local pts = getSkeletonPoints(char)
            if pts then
                local hS, hOn = worldToViewport(pts.head)
                local tS, tOn = worldToViewport(pts.torso)
                local lArmS, laOn = worldToViewport(pts.lArm or pts.torso)
                local rArmS, raOn = worldToViewport(pts.rArm or pts.torso)
                local lLegS, llOn = worldToViewport(pts.lLeg or pts.hrp)
                local rLegS, rlOn = worldToViewport(pts.rLeg or pts.hrp)

                if hOn and tOn then
                    esp.sk_head.From = V2(hS.X, hS.Y)
                    esp.sk_head.To = V2(tS.X, tS.Y)
                    esp.sk_head.Visible = true

                    if laOn then
                        esp.sk_arm_l.From = V2(tS.X, tS.Y)
                        esp.sk_arm_l.To = V2(lArmS.X, lArmS.Y)
                        esp.sk_arm_l.Visible = true
                    end
                    if raOn then
                        esp.sk_arm_r.From = V2(tS.X, tS.Y)
                        esp.sk_arm_r.To = V2(rArmS.X, rArmS.Y)
                        esp.sk_arm_r.Visible = true
                    end
                    if llOn then
                        esp.sk_leg_l.From = V2(tS.X, tS.Y)
                        esp.sk_leg_l.To = V2(lLegS.X, lLegS.Y)
                        esp.sk_leg_l.Visible = true
                    end
                    if rlOn then
                        esp.sk_leg_r.From = V2(tS.X, tS.Y)
                        esp.sk_leg_r.To = V2(rLegS.X, rLegS.Y)
                        esp.sk_leg_r.Visible = true
                    end
                end
            else
                esp.sk_head.Visible = false
                esp.sk_torso.Visible = false
                esp.sk_arm_l.Visible = false
                esp.sk_arm_r.Visible = false
                esp.sk_leg_l.Visible = false
                esp.sk_leg_r.Visible = false
            end
        else
            esp.sk_head.Visible = false
            esp.sk_torso.Visible = false
            esp.sk_arm_l.Visible = false
            esp.sk_arm_r.Visible = false
            esp.sk_leg_l.Visible = false
            esp.sk_leg_r.Visible = false
        end
    end
end)

-- ------------------------- Lifecycle -------------------------
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then createESP(p) end
end

Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then createESP(p) end
end)

Players.PlayerRemoving:Connect(function(p)
    removeESP(p)
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    for _, esp in pairs(espCache) do
        for _, d in pairs(esp) do
            if d then d.Visible = false end
        end
    end
end)
