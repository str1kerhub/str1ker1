-- Assumindo que você tem uma variável "headerFrame" ou "topBar" onde o título fica
local LOGO_ID = "rbxassetid://73606056465798"

local logoRow = Instance.new("Frame")
logoRow.Name = "LogoRow"
logoRow.BackgroundTransparency = 1
logoRow.Size = UDim2.new(0, 160, 1, 0)  -- ajusta conforme seu header
logoRow.Position = UDim2.new(0, 12, 0, 0)
logoRow.Parent = headerFrame  -- <-- troca pelo nome real do seu header

local logo = Instance.new("ImageLabel")
logo.Size = UDim2.new(0, 28, 0, 28)
logo.Position = UDim2.new(0, 0, 0.5, -14)
logo.BackgroundTransparency = 1
logo.Image = LOGO_ID
logo.ScaleType = Enum.ScaleType.Fit
logo.Parent = logoRow

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -36, 1, 0)
title.Position = UDim2.new(0, 36, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(139, 92, 246)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "STR1KER"
title.Parent = logoRow
