-- DoctorHub V17.4: Full Edition [Morph Fixed + ShiftLock + Deleter]
-- ПРИМЕЧАНИЕ: Согласно твоей инструкции, старые функции сохранены, добавлены только уточнения.

local player = game.Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")
local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local teleService = game:GetService("TeleportService")
local players = game:GetService("Players")
local tweenService = game:GetService("TweenService")
local mouse = player:GetMouse()

-- Конфигурация
local config = {
    speedActive = false,
    infJump = false,
    espActive = false,
    namesActive = false,
    invisibilityActive = false,
    realInvisActive = false, -- Новая переменная для настоящей невидимости
    followingPlayer = nil,
    isSmoothing = false,
    selectedObject = nil, 
    selectingMode = false,
    shiftLockActive = false,
    morphObject = nil,
    selectingMorph = false
}

-- Очистка старых копий
if pGui:FindFirstChild("DoctorHub_V17") then pGui.DoctorHub_V17:Destroy() end

local sg = Instance.new("ScreenGui")
sg.Name = "DoctorHub_V17"
sg.ResetOnSpawn = false 
sg.Parent = pGui

-- Кнопка MENU
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 90, 0, 40)
toggle.Position = UDim2.new(0, 10, 0.45, 0)
toggle.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
toggle.Text = "MENU"
toggle.TextColor3 = Color3.fromRGB(0, 180, 255)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 18
toggle.Parent = sg
Instance.new("UICorner", toggle)

-- ГЛАВНОЕ ОКНО
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 520, 0, 420)
main.Position = UDim2.new(0.5, -260, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.Visible = true
main.Parent = sg
Instance.new("UICorner", main)

-- Боковая панель
local sideBar = Instance.new("Frame")
sideBar.Size = UDim2.new(0, 140, 1, 0)
sideBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
sideBar.Parent = main
Instance.new("UICorner", sideBar)

-- ЛОГОТИП
local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(1, 0, 0, 60)
logo.Text = "DoctorHub"
logo.TextColor3 = Color3.fromRGB(0, 180, 255)
logo.Font = Enum.Font.GothamBold
logo.TextSize = 22
logo.BackgroundTransparency = 1
logo.Parent = sideBar

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 1, -70)
tabContainer.Position = UDim2.new(0, 0, 0, 65)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = sideBar
Instance.new("UIListLayout", tabContainer).HorizontalAlignment = Enum.HorizontalAlignment.Center

local pages = Instance.new("Frame")
pages.Size = UDim2.new(1, -160, 1, -20)
pages.Position = UDim2.new(0, 150, 0, 10)
pages.BackgroundTransparency = 1
pages.Parent = main

local function createPage(name)
    local p = Instance.new("ScrollingFrame")
    p.Name = name .. "Page"
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.Visible = false
    p.ScrollBarThickness = 2
    p.Parent = pages
    local l = Instance.new("UIListLayout", p)
    l.Padding = UDim.new(0, 10)
    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        p.CanvasSize = UDim2.new(0, 0, 0, l.AbsoluteContentSize.Y + 20)
    end)
    return p
end

local playerPage = createPage("Player")
local visualsPage = createPage("Visuals")
local teleportPage = createPage("Teleport")
local playersPage = createPage("Players")
local deleterPage = createPage("Deleter")
local morphPage = createPage("Morph")

local function showPage(pName)
    playerPage.Visible = (pName == "Player")
    visualsPage.Visible = (pName == "Visuals")
    teleportPage.Visible = (pName == "Teleport")
    playersPage.Visible = (pName == "Players")
    deleterPage.Visible = (pName == "Deleter")
    morphPage.Visible = (pName == "Morph")
end

local function createTabBtn(name)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 120, 0, 40)
    b.BackgroundTransparency = 1
    b.Text = name
    b.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 16
    b.Parent = tabContainer
    b.MouseButton1Click:Connect(function() showPage(name) end)
end

createTabBtn("Player"); createTabBtn("Visuals"); createTabBtn("Teleport"); createTabBtn("Players"); createTabBtn("Deleter"); createTabBtn("Morph")

local function createBtn(name, parent, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -5, 0, 40)
    btn.BackgroundColor3 = color or Color3.fromRGB(30, 30, 30)
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = parent
    Instance.new("UICorner", btn)
    if callback then btn.MouseButton1Click:Connect(callback) end
    return btn
end

-- --- PLAYER ---
local sInput = Instance.new("TextBox")
sInput.Size = UDim2.new(1, -5, 0, 40); sInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25); sInput.Text = "100"; sInput.TextColor3 = Color3.new(1, 1, 1); sInput.Parent = playerPage; Instance.new("UICorner", sInput)
local speedBtn = createBtn("Speed: OFF", playerPage, nil, function() config.speedActive = not config.speedActive end)
local jumpBtn = createBtn("Inf Jump: OFF", playerPage, nil, function() config.infJump = not config.infJump end)
local shiftLockBtn = createBtn("Shift Lock: OFF", playerPage, nil, function() config.shiftLockActive = not config.shiftLockActive end)

-- Кнопка локальной невидимости (изменено название)
local invisBtn = createBtn("Invisibility: OFF (Local)", playerPage, nil, function()
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

-- ДОБАВЛЕНО: Кнопка настоящей невидимости (для других)
local realInvisBtn = createBtn("Real Invis: OFF (Server)", playerPage, Color3.fromRGB(100, 0, 150), function()
    config.realInvisActive = not config.realInvisActive
    if config.realInvisActive then
        -- Логика Fling/God Invis (Сервер перестает видеть твоего персонажа правильно)
        if player.Character and player.Character:FindFirstChild("LowerTorso") then
            player.Character.LowerTorso:BreakJoints()
            player.Character.LowerTorso.Transparency = 1
            player.Character.LowerTorso.CanCollide = false
        end
    else
        -- Для возврата нужно нажать Rejoin или сброситься
        teleService:Teleport(game.PlaceId, player)
    end
end)

-- --- DELETER ---
local selectedLabel = Instance.new("TextLabel")
-- ИЗМЕНЕНО: Добавлено пояснение
selectedLabel.Size = UDim2.new(1, -5, 0, 50); selectedLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25); selectedLabel.Text = "Selected: None (Local Only)"; selectedLabel.TextColor3 = Color3.new(1, 1, 1); selectedLabel.Font = Enum.Font.GothamBold; selectedLabel.Parent = deleterPage; Instance.new("UICorner", selectedLabel)

createBtn("SELECT OBJECT (CLICK)", deleterPage, Color3.fromRGB(0, 120, 200), function()
    config.selectingMode = true
end)

-- ИЗМЕНЕНО: Добавлено (Только для тебя)
createBtn("DELETE SELECTED (ONLY FOR YOU)", deleterPage, Color3.fromRGB(200, 0, 0), function()
    if config.selectedObject then config.selectedObject:Destroy(); config.selectedObject = nil; selectedLabel.Text = "Selected: Deleted (Local)" end
end)

-- --- MORPH LOGIC ---
local morphLabel = Instance.new("TextLabel")
-- ИЗМЕНЕНО: Добавлено пояснение
morphLabel.Size = UDim2.new(1, -5, 0, 50); morphLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25); morphLabel.Text = "To Morph: None (Local Only)"; morphLabel.TextColor3 = Color3.new(1, 1, 1); morphLabel.Font = Enum.Font.GothamBold; morphLabel.Parent = morphPage; Instance.new("UICorner", morphLabel)

local selectMorphBtn = createBtn("SELECT PART", morphPage, Color3.fromRGB(0, 120, 200), function()
    config.selectingMorph = true
end)

-- ИЗМЕНЕНО: Добавлено (Только для тебя)
createBtn("MORPH (ONLY FOR YOU)", morphPage, Color3.fromRGB(0, 180, 100), function()
    if config.morphObject and player.Character then
        local char = player.Character
        for _, v in pairs(char:GetChildren()) do if v.Name == "MorphPart" then v:Destroy() end end
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then v.Transparency = 1 
            elseif v:IsA("Accessory") and v:FindFirstChild("Handle") then v.Handle.Transparency = 1 end
        end
        local clone = config.morphObject:Clone()
        clone.Name = "MorphPart"; clone.Anchored = false; clone.CanCollide = false; clone.Parent = char
        local weld = Instance.new("Weld")
        weld.Part0 = char.HumanoidRootPart; weld.Part1 = clone; weld.C0 = CFrame.new(0, 0, 0); weld.Parent = clone
        morphLabel.Text = "Morphed! (Local)"
    end
end)

createBtn("UNMORPH / RESET", morphPage, Color3.fromRGB(150, 0, 0), function()
    if player.Character then
        for _, v in pairs(player.Character:GetChildren()) do
            if v.Name == "MorphPart" then v:Destroy() end
            if v:IsA("BasePart") then v.Transparency = 0 
            elseif v:IsA("Accessory") and v:FindFirstChild("Handle") then v.Handle.Transparency = 0 end
        end
        morphLabel.Text = "Reset Done"
    end
end)

-- --- ОБЩАЯ ОБРАБОТКА МЫШИ ---
mouse.Button1Down:Connect(function()
    if config.selectingMode and mouse.Target then
        config.selectedObject = mouse.Target
        selectedLabel.Text = "Selected: " .. mouse.Target.Name
        config.selectingMode = false
    elseif config.selectingMorph and mouse.Target then
        config.morphObject = mouse.Target
        morphLabel.Text = "To Morph: " .. mouse.Target.Name
        config.selectingMorph = false
    end
end)

-- --- VISUALS ---
local espBtn = createBtn("ESP Box: OFF", visualsPage, nil, function() config.espActive = not config.espActive end)
local namesBtn = createBtn("ESP Names: OFF", visualsPage, nil, function() config.namesActive = not config.namesActive end)

-- --- TELEPORT ---
local gpsLabel = Instance.new("TextLabel")
gpsLabel.Size = UDim2.new(1, -5, 0, 50); gpsLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20); gpsLabel.TextColor3 = Color3.fromRGB(0, 255, 150); gpsLabel.Parent = teleportPage; Instance.new("UICorner", gpsLabel)
local tpInput = Instance.new("TextBox")
tpInput.Size = UDim2.new(1, -5, 0, 40); tpInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25); tpInput.PlaceholderText = "Coords X, Y, Z"; tpInput.TextColor3 = Color3.new(1, 1, 1); tpInput.Parent = teleportPage; Instance.new("UICorner", tpInput)

createBtn("Copy GPS", teleportPage, Color3.fromRGB(50, 50, 50), function()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then tpInput.Text = string.format("%.1f, %.1f, %.1f", root.Position.X, root.Position.Y, root.Position.Z) end
end)

createBtn("INSTANT TELEPORT", teleportPage, Color3.fromRGB(0, 120, 200), function()
    local text = tpInput.Text:gsub(",", " "); local c = {}
    for v in text:gmatch("%S+") do table.insert(c, tonumber(v)) end
    if #c >= 3 then player.Character.HumanoidRootPart.CFrame = CFrame.new(c[1], c[2], c[3]) end
end)

createBtn("SMOOTH TP", teleportPage, Color3.fromRGB(0, 160, 80), function()
    local text = tpInput.Text:gsub(",", " "); local c = {}
    for v in text:gmatch("%S+") do table.insert(c, tonumber(v)) end
    if #c >= 3 and player.Character and not config.isSmoothing then
        config.isSmoothing = true
        local root = player.Character.HumanoidRootPart
        local targetCFrame = CFrame.new(c[1], c[2], c[3])
        local tween = tweenService:Create(root, TweenInfo.new((targetCFrame.Position - root.Position).Magnitude / 150, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
        tween:Play()
        tween.Completed:Connect(function() config.isSmoothing = false end)
    end
end)

createBtn("REJOIN", teleportPage, Color3.fromRGB(150, 0, 0), function() teleService:Teleport(game.PlaceId, player) end)

-- --- PLAYERS ---
local function updatePlayerList()
    for _, child in pairs(playersPage:GetChildren()) do if not child:IsA("UIListLayout") then child:Destroy() end end
    for _, p in pairs(players:GetPlayers()) do
        if p ~= player then
            local pFrame = Instance.new("Frame")
            pFrame.Size = UDim2.new(1, -10, 0, 42); pFrame.BackgroundTransparency = 1; pFrame.Parent = playersPage
            local mainBtn = createBtn(p.Name, pFrame, Color3.fromRGB(35, 35, 35))
            mainBtn.Size = UDim2.new(1, 0, 0, 40)
            local options = Instance.new("Frame")
            options.Name = "Options"; options.Size = UDim2.new(1, 0, 0, 40); options.Position = UDim2.new(0, 0, 0, 42); options.BackgroundTransparency = 1; options.Visible = false; options.Parent = pFrame
            mainBtn.MouseButton1Click:Connect(function()
                options.Visible = not options.Visible
                pFrame.Size = options.Visible and UDim2.new(1, -10, 0, 85) or UDim2.new(1, -10, 0, 42)
            end)
            createBtn("TP", options, Color3.fromRGB(0, 100, 180), function()
                if p.Character then player.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3) end
            end).Size = UDim2.new(0.48, 0, 1, 0)
            local fBtn = createBtn("Follow", options, Color3.fromRGB(180, 80, 0))
            fBtn.Size = UDim2.new(0.48, 0, 1, 0); fBtn.Position = UDim2.new(0.52, 0, 0, 0)
            fBtn.MouseButton1Click:Connect(function()
                if config.followingPlayer == p then config.followingPlayer = nil else config.followingPlayer = p end
            end)
        end
    end
end
players.PlayerAdded:Connect(updatePlayerList); players.PlayerRemoving:Connect(updatePlayerList); updatePlayerList()

-- --- ESP LOGIC ---
local function updateESP()
    for _, p in pairs(players:GetPlayers()) do
        if p ~= player and p.Character then
            local h = p.Character:FindFirstChild("EspBox")
            if config.espActive then
                if not h then h = Instance.new("Highlight", p.Character); h.Name = "EspBox"; h.FillColor = Color3.fromRGB(0, 180, 255) end
            elseif h then h:Destroy() end
            local t = p.Character:FindFirstChild("NameTag")
            if config.namesActive then
                if not t then
                    t = Instance.new("BillboardGui", p.Character); t.Name = "NameTag"; t.Size = UDim2.new(0, 100, 0, 40); t.AlwaysOnTop = true; t.ExtentsOffset = Vector3.new(0, 3, 0)
                    local l = Instance.new("TextLabel", t); l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1; l.Text = p.Name; l.TextColor3 = Color3.new(1,1,1); l.TextSize = 14
                end
            elseif t then t:Destroy() end
        end
    end
end

-- --- ЦИКЛ ОБНОВЛЕНИЯ ---
runService.RenderStepped:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        if config.shiftLockActive then
            char.Humanoid.CameraOffset = Vector3.new(1.7, 0, 0)
            uis.MouseBehavior = Enum.MouseBehavior.LockCenter
            local _, y = workspace.CurrentCamera.CFrame:ToEulerAnglesYXZ()
            root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, y, 0)
        else
            char.Humanoid.CameraOffset = Vector3.new(0, 0, 0)
            if not config.selectingMode and not config.selectingMorph then uis.MouseBehavior = Enum.MouseBehavior.Default end
        end
        if config.speedActive and not config.isSmoothing then char.Humanoid.WalkSpeed = tonumber(sInput.Text) or 16 end
        gpsLabel.Text = string.format("X: %.0f | Y: %.0f | Z: %.0f", root.Position.X, root.Position.Y, root.Position.Z)
        updateESP()
        
        speedBtn.Text = "Speed: " .. (config.speedActive and "[ON]" or "[OFF]")
        jumpBtn.Text = "Inf Jump: " .. (config.infJump and "[ON]" or "[OFF]")
        shiftLockBtn.Text = "Shift Lock: " .. (config.shiftLockActive and "[ON]" or "[OFF]")
        invisBtn.Text = "Invis (Local): " .. (config.invisibilityActive and "[ON]" or "[OFF]")
        realInvisBtn.Text = "Real Invis (Server): " .. (config.realInvisActive and "[ON]" or "[OFF]")
    end
end)

uis.JumpRequest:Connect(function()
    if config.infJump and player.Character then player.Character.Humanoid:ChangeState(3) end
end)

toggle.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)
showPage("Player")
