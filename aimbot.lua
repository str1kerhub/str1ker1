--!nocheck
-- ==========================================================================
-- STR1KER AIMBOT v2
-- Silent Aim + Camera Lock + Predição + Smoothing
-- ==========================================================================

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local Workspace   = game:GetService("Workspace")
local UIS         = game:GetService("UserInputService")
local Stats       = game:GetService("Stats")
local Camera      = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- ------------------------- Configuração -------------------------
local AIM_CFG = {
    enabled          = true,
    mode             = "Silent",     -- "Silent" | "Camera" | "Both"
    keybind          = Enum.KeyCode.E,
    aim_part         = "Head",       -- "Head" | "HumanoidRootPart" | "Torso"
    fov              = 120,
    max_distance     = 600,
    smoothing        = 0.35,         -- 0 = instantâneo, 1 = lento
    prediction       = true,
    prediction_scale = 1.0,
    team_check       = true,
    visibility_check = true,
    wall_check       = false,
    auto_shoot       = false,
    hit_part_draw    = true,
}

getgenv().AIM_CFG = AIM_CFG

-- ------------------------- Predição -------------------------
local function getServerPing()
    local ok, v = pcall(function()
        return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    return (ok and v or 60) / 1000
end

local function predictPosition(part, ping)
    if not AIM_CFG.prediction then
        return part.Position
    end
    local velocity = part.AssemblyLinearVelocity
    if velocity.Magnitude < 0.1 then
        return part.Position
    end
    local t = (ping + 0.05) * AIM_CFG.prediction_scale
    return part.Position + velocity * t
end

-- ------------------------- Alvo -------------------------
local currentTarget = nil
local lockTime = 0
local LOCK_DURATION = 0.25

local function isValidTarget(player)
    if player == LocalPlayer then return false end
    local char = player.Character
    if not char then return false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    if AIM_CFG.team_check and player.Team and LocalPlayer.Team then
        if player.Team == LocalPlayer.Team then return false end
    end
    return true
end

local function getAimPart(char)
    if AIM_CFG.aim_part == "Head" then
        return char:FindFirstChild("Head")
    elseif AIM_CFG.aim_part == "Torso" then
        return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    else
        return char:FindFirstChild("HumanoidRootPart")
    end
end

-- Escolhe o melhor alvo por prioridade (distância + FOV)
local function pickTarget()
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    local best, bestScore = nil, math.huge
    local mousePos = UIS:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if not isValidTarget(player) then continue end

        local char = player.Character
        local part = getAimPart(char)
        if not part then continue end

        local dist = (part.Position - myHRP.Position).Magnitude
        if dist > AIM_CFG.max_distance then continue end

        -- FOV check
        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end

        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if screenDist > AIM_CFG.fov then continue end

        -- Visibility
        if AIM_CFG.visibility_check then
            local ray = Ray.new(Camera.CFrame.Position, part.Position - Camera.CFrame.Position)
            local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {myChar, char})
            if hit and not hit:IsDescendantOf(char) then
                continue
            end
        end

        -- Score: quanto menor, melhor
        local score = screenDist + dist * 0.1
        if score < bestScore then
            best, bestScore = player, score
        end
    end

    return best
end

-- ------------------------- Hook de Silent Aim -------------------------
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()

    if AIM_CFG.enabled and (AIM_CFG.mode == "Silent" or AIM_CFG.mode == "Both") then
        if method == "FireServer" and self.Name == "RemoteEvent" then
            if currentTarget and currentTarget.Character then
                local part = getAimPart(currentTarget.Character)
                if part then
                    local ping = getServerPing()
                    local predicted = predictPosition(part, ping)
                    local args = {...}

                    -- Substitui Vector3/CFrame pelo alvo predito
                    for i = 1, #args do
                        if typeof(args[i]) == "Vector3" then
                            args[i] = predicted
                        elseif typeof(args[i]) == "CFrame" then
                            args[i] = CFrame.new(predicted)
                        end
                    end

                    return oldNamecall(self, unpack(args))
                end
            end
        end
    end

    return oldNamecall(self, ...)
end)

setreadonly(mt, true)

-- ------------------------- Camera Lock + Smoothing -------------------------
RunService.RenderStepped:Connect(function()
    if not AIM_CFG.enabled then return end

    -- Target lock: mantém o alvo por um curto período
    local target = currentTarget
    if target and target.Character then
        local part = getAimPart(target.Character)
        if not part or tick() - lockTime > LOCK_DURATION then
            target = nil
        end
    end

    if not target then
        target = pickTarget()
        if target then
            currentTarget = target
            lockTime = tick()
        else
            currentTarget = nil
        end
    end

    -- Camera lock
    if (AIM_CFG.mode == "Camera" or AIM_CFG.mode == "Both") and currentTarget then
        local part = getAimPart(currentTarget.Character)
        if part then
            local ping = getServerPing()
            local predicted = predictPosition(part, ping)
            local targetCF = CFrame.lookAt(Camera.CFrame.Position, predicted)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 - AIM_CFG.smoothing)
        end
    end

    -- Auto shoot
    if AIM_CFG.auto_shoot and currentTarget then
        local part = getAimPart(currentTarget.Character)
        if part then
            local ping = getServerPing()
            local predicted = predictPosition(part, ping)
            getgenv().aim_pos = CFrame.new(predicted)
        end
    end
end)

-- ------------------------- Keybind -------------------------
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == AIM_CFG.keybind then
        AIM_CFG.enabled = not AIM_CFG.enabled
    end
end)

-- ------------------------- FOV Circle (visual) -------------------------
local fovCircle = createDrawing and createDrawing("Circle") or nil
if fovCircle then
    fovCircle.Thickness = 1
    fovCircle.Color = Color3.fromRGB(255, 255, 255)
    fovCircle.Transparency = 0.5
    fovCircle.NumSides = 64
    fovCircle.Radius = AIM_CFG.fov
    fovCircle.Filled = false
end

RunService.RenderStepped:Connect(function()
    if not fovCircle then return end
    if AIM_CFG.enabled then
        local mousePos = UIS:GetMouseLocation()
        fovCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
        fovCircle.Radius = AIM_CFG.fov
        fovCircle.Visible = true
    else
        fovCircle.Visible = false
    end
end)
