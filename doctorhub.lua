-- DoctorHub V18.9: FINAL STABLE [Enhanced Design + World Time + No Deletions]
local player = game.Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")
local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local teleService = game:GetService("TeleportService")
local players = game:GetService("Players")
local tweenService = game:GetService("TweenService")
local lighting = game:GetService("Lighting")
local mouse = player:GetMouse()

-- Конфигурация (Объединенная)
local config = {
    speedActive = false,
    jumpPowerActive = false,
    infJump = false,
    espActive = false,
    namesActive = false,
    invisibilityActive = false,
    followingPlayer = nil,
    isSmoothing = false,
    selectedObject = nil, 
    selectingMode = false,
    shiftLockActive = false,
    morphObject = nil,
    selectingMorph = false,
    fullBright = false,
    noClip = false,
    antiAfk = true
}

local defaultLight = { Ambient = lighting.Ambient, Brightness = lighting.Brightness, OutdoorAmbient = lighting.OutdoorAmbient }
local theme = {
    background = Color3.fromRGB(15, 15, 15),
    sideBar = Color3.fromRGB(22, 22, 22),
    accent = Color3.fromRGB(0, 160, 255),
    button = Color3.fromRGB(35, 35, 40),
    text = Color3.fromRGB(255, 255, 255),
    secondaryText = Color3.fromRGB(160, 160, 160)
}

-- Очистка старых копий
if pGui:FindFirstChild("DoctorHub_V18") then pGui.DoctorHub_V18:Destroy() end

local sg = Instance.new("ScreenGui")
sg.Name = "DoctorHub_V18"
sg.ResetOnSpawn = false 
sg.Parent = pGui

-- Кнопка MENU
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 110, 0, 40)
toggle.Position = UDim2.new(0, 20, 0.45, 0)
toggle.BackgroundColor3 = theme.background
toggle.Text = "DOCTOR HUB"
toggle.TextColor3 = theme.accent
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 13
toggle.Parent = sg
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 10)
local toggleStroke = Instance.new("UIStroke", toggle)
toggleStroke.Color = theme.accent
toggleStroke.Thickness = 2

-- ГЛАВНОЕ ОКНО
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 580, 0, 450)
main.Position = UDim2.new(0.5, -290, 0.5, -225)
main.BackgroundColor3 = theme.background
main.Visible = true
main.Parent = sg
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 15)
local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = Color3.fromRGB(45, 45, 45)
mainStroke.Thickness = 1.5

-- Draggable Logic
local dragging, dragInput, dragStart, startPos
main.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = main.Position end end)
main.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
uis.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
runService.RenderStepped:Connect(function() if dragging and dragInput then local delta = dragInput.Position - dragStart; main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)

-- Боковая панель
local sideBar = Instance.new("Frame")
sideBar.Size = UDim2.new(0, 170, 1, 0)
sideBar.BackgroundColor3 = theme.sideBar
sideBar.Parent = main
Instance.new("UICorner", sideBar).CornerRadius = UDim.new(0, 15)

local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(1, 0, 0, 80)
logo.Text = "DOCTOR HUB"
logo.TextColor3 = theme.accent
logo.Font = Enum.Font.GothamBold
logo.TextSize = 22
logo.BackgroundTransparency = 1
logo.Parent = sideBar

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 1, -100)
tabContainer.Position = UDim2.new(0, 0, 0, 80)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = sideBar
local layout = Instance.new("UIListLayout", tabContainer)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Padding = UDim.new(0, 6)

local pages = Instance.new("Frame")
pages.Size = UDim2.new(1, -200, 1, -30)
pages.Position = UDim2.new(0, 185, 0, 15)
pages.BackgroundTransparency = 1
pages.Parent = main

local pgList = {}
local function createPage(name)
    local p = Instance.new("ScrollingFrame")
    p.Name = name .. "Page"
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.Visible = false
    p.ScrollBarThickness = 3
    p.ScrollBarImageColor3 = theme.accent
    p.Parent = pages
    local l = Instance.new("UIListLayout", p)
    l.Padding = UDim.new(0, 12)
    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        p.CanvasSize = UDim2.new(0, 0, 0, l.AbsoluteContentSize.Y + 10)
    end)
    pgList[name] = p
    return p
end

local function showPage(pName)
    for name, page in pairs(pgList) do
        page.Visible = (name == pName)
    end
end

local function createTabBtn(name)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 150, 0, 38)
    b.BackgroundColor3 = theme.button
    b.BackgroundTransparency = 1
    b.Text = "  " .. name:upper()
    b.TextColor3 = theme.secondaryText
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Parent = tabContainer
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(function() showPage(name) end)
end

for _, n in pairs({"Player", "Visuals", "Teleport", "Players", "World", "Deleter", "Morph"}) do 
    createPage(n)
    createTabBtn(n)
end

local function createBtn(name, parent, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 45)
    btn.BackgroundColor3 = color or theme.button
    btn.Text = name; btn.TextColor3 = theme.text; btn.Font = Enum.Font.GothamBold; btn.TextSize = 13; btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    local s = Instance.new("UIStroke", btn); s.Color = Color3.fromRGB(60,60,65); s.Thickness = 1
    if callback then btn.MouseButton1Click:Connect(callback) end
    return btn
end

local function createInput(placeholder, parent)
    local i = Instance.new("TextBox")
    i.Size = UDim2.new(1, -10, 0, 42); i.BackgroundColor3 = theme.button; i.Text = ""; i.PlaceholderText = placeholder; i.TextColor3 = theme.accent; i.Parent = parent
    Instance.new("UICorner", i).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", i).Color = Color3.fromRGB(55,55,60)
    return i
end

-- --- PLAYER PAGE ---
local sInput = createInput("Enter WalkSpeed (Default: 16)", pgList.Player)
local speedBtn = createBtn("Toggle WalkSpeed: OFF", pgList.Player, nil, function() config.speedActive = not config.speedActive end)
local jInput = createInput("Enter JumpPower (Default: 50)", pgList.Player)
local jumpBtn = createBtn("Toggle JumpPower: OFF", pgList.Player, nil, function() config.jumpPowerActive = not config.jumpPowerActive end)
createBtn("Infinite Jump: OFF", pgList.Player, nil, function() config.infJump = not config.infJump end)
createBtn("No-Clip: OFF", pgList.Player, nil, function() config.noClip = not config.noClip end)
createBtn("Shift Lock: OFF", pgList.Player, nil, function() config.shiftLockActive = not config.shiftLockActive end)

local invisBtn = createBtn("Invisibility: OFF (Only for you)", pgList.Player, nil, function()
    config.invisibilityActive = not config.invisibilityActive
    local char = player.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                if part.Name ~= "HumanoidRootPart" then part.Transparency = config.invisibilityActive and 1 or 0 end
            end
        end
    end
end)

-- --- VISUALS ---
createBtn("Player ESP Box: OFF", pgList.Visuals, nil, function() config.espActive = not config.espActive end)
createBtn("ESP Names & Distance: OFF", pgList.Visuals, nil, function() config.namesActive = not config.namesActive end)

-- --- TELEPORT ---
local gpsLabel = Instance.new("TextLabel"); gpsLabel.Size = UDim2.new(1, -10, 0, 55); gpsLabel.BackgroundColor3 = theme.sideBar; gpsLabel.TextColor3 = Color3.fromRGB(0, 255, 150); gpsLabel.Font = Enum.Font.Code; gpsLabel.Parent = pgList.Teleport; Instance.new("UICorner", gpsLabel)
local tpInput = createInput("X, Y, Z coordinates", pgList.Teleport)
createBtn("Get Current Position (GPS)", pgList.Teleport, theme.button, function()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then tpInput.Text = string.format("%.1f, %.1f, %.1f", root.Position.X, root.Position.Y, root.Position.Z) end
end)
createBtn("INSTANT TELEPORT", pgList.Teleport, Color3.fromRGB(0, 110, 200), function()
    local c = {}
    for v in tpInput.Text:gsub(",", " "):gmatch("%S+") do table.insert(c, tonumber(v)) end
    if #c >= 3 then player.Character.HumanoidRootPart.CFrame = CFrame.new(c[1], c[2], c[3]) end
end)
createBtn("SMOOTH TWEEN TELEPORT", pgList.Teleport, Color3.fromRGB(45, 160, 90), function()
    local c = {}
    for v in tpInput.Text:gsub(",", " "):gmatch("%S+") do table.insert(c, tonumber(v)) end
    if #c >= 3 and player.Character and not config.isSmoothing then
        config.isSmoothing = true; local root = player.Character.HumanoidRootPart; local target = CFrame.new(c[1], c[2], c[3])
        local t = tweenService:Create(root, TweenInfo.new((target.Position - root.Position).Magnitude / 150, Enum.EasingStyle.Linear), {CFrame = target})
        t:Play(); t.Completed:Connect(function() config.isSmoothing = false end)
    end
end)
createBtn("SERVER REJOIN", pgList.Teleport, Color3.fromRGB(170, 60, 60), function() teleService:Teleport(game.PlaceId, player) end)

-- --- WORLD ---
createBtn("Toggle FullBright", pgList.World, nil, function()
    config.fullBright = not config.fullBright
    if config.fullBright then
        lighting.Ambient = Color3.new(1,1,1); lighting.Brightness = 2; lighting.OutdoorAmbient = Color3.new(1,1,1)
    else
        lighting.Ambient = defaultLight.Ambient; lighting.Brightness = defaultLight.Brightness; lighting.OutdoorAmbient = defaultLight.OutdoorAmbient
    end
end)
createBtn("Set Time: DAY (14:00)", pgList.World, Color3.fromRGB(200, 160, 0), function() lighting.TimeOfDay = "14:00:00" end)
createBtn("Set Time: NIGHT (00:00)", pgList.World, Color3.fromRGB(50, 50, 100), function() lighting.TimeOfDay = "00:00:00" end)
local afkBtn = createBtn("Anti-AFK System: ON", pgList.World, Color3.fromRGB(45, 160, 90), function() 
    config.antiAfk = not config.antiAfk 
end)

-- --- DELETER ---
local delInfo = Instance.new("TextLabel", pgList.Deleter); delInfo.Size = UDim2.new(1, -10, 0, 20); delInfo.BackgroundTransparency = 1; delInfo.Text = "(Only for you)"; delInfo.TextColor3 = theme.secondaryText; delInfo.Font = Enum.Font.Gotham; delInfo.TextSize = 12
local selL = Instance.new("TextLabel", pgList.Deleter); selL.Size = UDim2.new(1,-10,0,45); selL.BackgroundColor3 = theme.sideBar; selL.Text = "Selected Object: None"; selL.TextColor3 = theme.accent; Instance.new("UICorner", selL)
createBtn("CLICK TO SELECT OBJECT", pgList.Deleter, Color3.fromRGB(0, 110, 200), function() config.selectingMode = true end)
createBtn("DESTROY SELECTED", pgList.Deleter, Color3.fromRGB(190, 50, 50), function() if config.selectedObject then config.selectedObject:Destroy(); config.selectedObject = nil; selL.Text = "Deleted successfully" end end)

-- --- MORPH ---
local morphTag = Instance.new("TextLabel", pgList.Morph); morphTag.Size = UDim2.new(1, -10, 0, 20); morphTag.BackgroundTransparency = 1; morphTag.Text = "(Only for you)"; morphTag.TextColor3 = theme.secondaryText; morphTag.Font = Enum.Font.Gotham; morphTag.TextSize = 12
local morphL = Instance.new("TextLabel", pgList.Morph); morphL.Size = UDim2.new(1,-10,0,45); morphL.BackgroundColor3 = theme.sideBar; morphL.Text = "Morph Target: None"; morphL.TextColor3 = theme.accent; Instance.new("UICorner", morphL)
createBtn("CLICK TO SELECT PART", pgList.Morph, Color3.fromRGB(0, 110, 200), function() config.selectingMorph = true end)
createBtn("APPLY MORPH", pgList.Morph, Color3.fromRGB(45, 160, 90), function()
    if config.morphObject and player.Character then
        local char = player.Character
        for _, v in pairs(char:GetChildren()) do if v.Name == "MorphPart" then v:Destroy() end end
        for _, v in pairs(char:GetChildren()) do 
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then v.Transparency = 1 
            elseif v:IsA("Accessory") and v:FindFirstChild("Handle") then v.Handle.Transparency = 1 end
        end
        local cl = config.morphObject:Clone(); cl.Name = "MorphPart"; cl.Anchored = false; cl.CanCollide = false; cl.Parent = char
        local w = Instance.new("Weld", cl); w.Part0 = char.HumanoidRootPart; w.Part1 = cl; w.C0 = CFrame.new(0, 0, 0)
    end
end)
createBtn("REMOVE MORPH & RESET", pgList.Morph, Color3.fromRGB(170, 60, 60), function()
    local char = player.Character
    if char then
        for _, v in pairs(char:GetChildren()) do if v.Name == "MorphPart" then v:Destroy() end end
        for _, v in pairs(char:GetChildren()) do 
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then v.Transparency = 0 
            elseif v:IsA("Accessory") and v:FindFirstChild("Handle") then v.Handle.Transparency = 0 end
        end
    end
end)

-- --- PLAYERS ---
local function updatePlayerList()
    for _, v in pairs(pgList.Players:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
    for _, p in pairs(players:GetPlayers()) do if p ~= player then
        local f = Instance.new("Frame", pgList.Players); f.Size = UDim2.new(1, -10, 0, 42); f.BackgroundTransparency = 1
        local b = createBtn(p.Name, f, theme.button); b.Size = UDim2.new(0.6, 0, 1, 0)
        b.MouseButton1Click:Connect(function() if p.Character then player.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame end end)
        local fl = createBtn("Follow", f, theme.accent); fl.Size = UDim2.new(0.35, 0, 1, 0); fl.Position = UDim2.new(0.65, 0, 0, 0)
        fl.MouseButton1Click:Connect(function() if config.followingPlayer == p then config.followingPlayer = nil; fl.Text = "Follow" else config.followingPlayer = p; fl.Text = "STOP" end end)
    end end
end
players.PlayerAdded:Connect(updatePlayerList); players.PlayerRemoving:Connect(updatePlayerList); updatePlayerList()

-- --- MAIN LOOP ---
runService.RenderStepped:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        local hum = char.Humanoid
        
        -- Speed & Jump
        if config.speedActive then hum.WalkSpeed = tonumber(sInput.Text) or 16 else hum.WalkSpeed = 16 end
        if config.jumpPowerActive then hum.JumpPower = tonumber(jInput.Text) or 50; hum.UseJumpPower = true else hum.UseJumpPower = false end
        
        -- NoClip
        if config.noClip then for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
        
        -- ShiftLock
        if config.shiftLockActive then
            hum.CameraOffset = Vector3.new(1.7, 0, 0); uis.MouseBehavior = Enum.MouseBehavior.LockCenter
            local _, y = workspace.CurrentCamera.CFrame:ToEulerAnglesYXZ(); root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, y, 0)
        else
            hum.CameraOffset = Vector3.new(0, 0, 0)
        end

        -- Follow
        if config.followingPlayer and config.followingPlayer.Character then root.CFrame = config.followingPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 4) end
        
        -- ESP Logic
        for _, p in pairs(players:GetPlayers()) do if p ~= player and p.Character then
            local h = p.Character:FindFirstChild("EspBox")
            if config.espActive then if not h then h = Instance.new("Highlight", p.Character); h.Name = "EspBox"; h.FillColor = theme.accent end else if h then h:Destroy() end end
            
            local t = p.Character:FindFirstChild("NameTag")
            if config.namesActive then
                if not t then
                    t = Instance.new("BillboardGui", p.Character); t.Name = "NameTag"; t.Size = UDim2.new(0, 100, 0, 40); t.AlwaysOnTop = true; t.ExtentsOffset = Vector3.new(0, 3, 0)
                    local l = Instance.new("TextLabel", t); l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1; l.TextColor3 = Color3.new(1,1,1); l.TextSize = 14; l.Font = Enum.Font.GothamBold; l.Parent = t
                end
                local dist = math.floor((root.Position - p.Character.HumanoidRootPart.Position).Magnitude)
                t.TextLabel.Text = p.Name .. " [" .. dist .. "m]"
            elseif t then t:Destroy() end
        end end
        
        -- UI Updates & Styling Toggle
        gpsLabel.Text = string.format(" POS X: %.0f | Y: %.0f | Z: %.0f ", root.Position.X, root.Position.Y, root.Position.Z)
        
        -- Тексты и цвета для кнопок (динамически)
        for _, b in pairs(pgList.Player:GetChildren()) do
            if b:IsA("TextButton") then
                if b.Text:find("WalkSpeed") then b.Text = "WalkSpeed: "..(config.speedActive and "ON" or "OFF"); b.BackgroundColor3 = config.speedActive and theme.accent or theme.button end
                if b.Text:find("JumpPower") then b.Text = "JumpPower: "..(config.jumpPowerActive and "ON" or "OFF"); b.BackgroundColor3 = config.jumpPowerActive and theme.accent or theme.button end
                if b.Text:find("Infinite Jump") then b.Text = "Infinite Jump: "..(config.infJump and "ON" or "OFF"); b.BackgroundColor3 = config.infJump and theme.accent or theme.button end
                if b.Text:find("No-Clip") then b.Text = "No-Clip: "..(config.noClip and "ON" or "OFF"); b.BackgroundColor3 = config.noClip and theme.accent or theme.button end
                if b.Text:find("Shift Lock") then b.Text = "Shift Lock: "..(config.shiftLockActive and "ON" or "OFF"); b.BackgroundColor3 = config.shiftLockActive and theme.accent or theme.button end
                if b.Text:find("Invisibility") then b.Text = "Invisibility: "..(config.invisibilityActive and "ON" or "OFF").." (Only for you)"; b.BackgroundColor3 = config.invisibilityActive and theme.accent or theme.button end
            end
        end

        for _, b in pairs(pgList.Visuals:GetChildren()) do
            if b:IsA("TextButton") then
                if b.Text:find("Box") then b.Text = "Player ESP Box: "..(config.espActive and "ON" or "OFF"); b.BackgroundColor3 = config.espActive and theme.accent or theme.button end
                if b.Text:find("Names") then b.Text = "ESP Names: "..(config.namesActive and "ON" or "OFF"); b.BackgroundColor3 = config.namesActive and theme.accent or theme.button end
            end
        end
        
        -- Fixed Anti-AFK Toggle Display
        afkBtn.Text = "Anti-AFK System: " .. (config.antiAfk and "ON" or "OFF")
        afkBtn.BackgroundColor3 = config.antiAfk and Color3.fromRGB(45, 160, 90) or theme.button
    end
end)

-- Вспомогательные события
mouse.Button1Down:Connect(function()
    if config.selectingMode and mouse.Target then config.selectedObject = mouse.Target; selL.Text = "Selected: "..mouse.Target.Name; config.selectingMode = false end
    if config.selectingMorph and mouse.Target then config.morphObject = mouse.Target; morphL.Text = "To Morph: "..mouse.Target.Name; config.selectingMorph = false end
end)

uis.JumpRequest:Connect(function() if config.infJump and player.Character then player.Character.Humanoid:ChangeState(3) end end)

-- Anti-AFK Logic
player.Idled:Connect(function() if config.antiAfk then game:GetService("VirtualUser"):CaptureController(); game:GetService("VirtualUser"):ClickButton2(Vector2.new()) end end)

toggle.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)
showPage("Player")
