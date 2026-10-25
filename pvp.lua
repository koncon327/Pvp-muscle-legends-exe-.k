local P, R, UIS, TS, L = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("TweenService"), game:GetService("Lighting")
local lp, cam = P.LocalPlayer, workspace.CurrentCamera

if lp.PlayerGui:FindFirstChild("HeeUI") then lp.PlayerGui.HeeUI:Destroy() end

local SPAWN_CF = CFrame.new(5105.21, 110.05, 6341.85)
local VOID_Y_LOW = -500
local VOID_Y_HIGH = 5000

local THEME = {
    bg = Color3.fromRGB(20, 20, 25), bgTrans = 0.15,
    card = Color3.fromRGB(35, 35, 45), cardTrans = 0.2,
    text = Color3.fromRGB(255, 255, 255), textDim = Color3.fromRGB(170, 170, 180),
    accent = Color3.fromRGB(138, 43, 226), success = Color3.fromRGB(0, 255, 127), danger = Color3.fromRGB(255, 69, 0)
}

local flags = {god=false, spec=false, antvoid=true}
local yaw, pitch, dist = 0, 15, 12
local lastVoidWarp = 0

local PvP = {
    enabled = false,
    selectedPlayer = nil, 
    punchInterval = 0.15,
    lastPunch = 0,
    state = "idle" 
}

local function formatNumber(n)
    if n >= 1e18 then return string.format("%.1fQi", n / 1e18)
    elseif n >= 1e15 then return string.format("%.1fQa", n / 1e15)
    elseif n >= 1e12 then return string.format("%.1fT", n / 1e12)
    elseif n >= 1e9 then return string.format("%.1fB", n / 1e9)
    elseif n >= 1e6 then return string.format("%.1fM", n / 1e6)
    elseif n >= 1e3 then return string.format("%.1fK", n / 1e3)
    else return tostring(math.floor(n)) end
end

local sg = Instance.new("ScreenGui")
sg.Name = "HeeUI"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.Parent = lp.PlayerGui

local toggleBtn = Instance.new("TextButton", sg)
toggleBtn.Size = UDim2.new(0, 45, 0, 45)
toggleBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
toggleBtn.BackgroundColor3 = THEME.bg
toggleBtn.BackgroundTransparency = THEME.bgTrans
toggleBtn.Text = "HEE"
toggleBtn.TextColor3 = THEME.text
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.GothamBlack
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", toggleBtn).Color = THEME.accent

local f = Instance.new("Frame", sg)
f.Size = UDim2.new(0, 200, 0, 360)
f.Position = UDim2.new(0.5, -100, 0.5, -180)
f.BackgroundColor3 = THEME.bg
f.BackgroundTransparency = THEME.bgTrans
f.Visible = false
f.Active = true
Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
local fStroke = Instance.new("UIStroke", f)
fStroke.Color = THEME.accent
fStroke.Thickness = 1.5
fStroke.Transparency = 0.5

local header = Instance.new("Frame", f)
header.Size = UDim2.new(1, 0, 0, 35)
header.BackgroundTransparency = 1

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -30, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.Text = "HEE.EXE PVP"
title.TextColor3 = THEME.text
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

local cls = Instance.new("TextButton", header)
cls.Size = UDim2.new(0, 25, 0, 25)
cls.Position = UDim2.new(1, -32, 0, 5)
cls.Text = "×"
cls.TextColor3 = THEME.danger
cls.BackgroundTransparency = 1
cls.Font = Enum.Font.GothamBold
cls.TextSize = 18

local content = Instance.new("ScrollingFrame", f)
content.Size = UDim2.new(1, -16, 1, -45)
content.Position = UDim2.new(0, 8, 0, 40)
content.BackgroundTransparency = 1
content.ScrollBarThickness = 2
content.ScrollBarImageColor3 = THEME.accent
content.CanvasSize = UDim2.new(0, 0, 0, 450)

local function createToggle(text, yPos, callback, defaultOn)
    local card = Instance.new("Frame", content)
    card.Size = UDim2.new(1, 0, 0, 32)
    card.Position = UDim2.new(0, 0, 0, yPos)
    card.BackgroundColor3 = THEME.card
    card.BackgroundTransparency = THEME.cardTrans
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", card).Color = THEME.accent
    
    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.Text = text
    lbl.TextColor3 = THEME.text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 11
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local switchBtn = Instance.new("TextButton", card)
    switchBtn.Size = UDim2.new(0, 30, 0, 16)
    switchBtn.Position = UDim2.new(1, -40, 0.5, -8)
    switchBtn.BackgroundColor3 = THEME.bg
    switchBtn.Text = ""
    switchBtn.AutoButtonColor = false
    Instance.new("UICorner", switchBtn).CornerRadius = UDim.new(1, 0)
    
    local swStroke = Instance.new("UIStroke", switchBtn)
    swStroke.Color = THEME.textDim
    
    local circle = Instance.new("Frame", switchBtn)
    circle.Size = UDim2.new(0, 12, 0, 12)
    circle.Position = UDim2.new(0, 2, 0.5, -6)
    circle.BackgroundColor3 = THEME.textDim
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    local isOn = defaultOn or false
    local canClick = true

    if isOn then
        switchBtn.BackgroundColor3 = THEME.success
        swStroke.Color = THEME.success
        circle.BackgroundColor3 = THEME.text
        circle.Position = UDim2.new(1, -14, 0.5, -6)
    end

    switchBtn.InputBegan:Connect(function(input)
        if canClick and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            canClick = false; isOn = not isOn
            
            if isOn then
                switchBtn.BackgroundColor3 = THEME.success
                swStroke.Color = THEME.success
                circle.BackgroundColor3 = THEME.text
                TS:Create(circle, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1, -14, 0.5, -6)}):Play()
            else
                switchBtn.BackgroundColor3 = THEME.bg
                swStroke.Color = THEME.textDim
                circle.BackgroundColor3 = THEME.textDim
                TS:Create(circle, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 2, 0.5, -6)}):Play()
            end
            callback(isOn, lbl)
        end
    end)
    
    switchBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then canClick = true end
    end)
end

local function createDropdown(yPos)
    local frame = Instance.new("Frame", content)
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundColor3 = THEME.card
    frame.BackgroundTransparency = THEME.cardTrans
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", frame).Color = THEME.accent

    local display = Instance.new("TextLabel", frame)
    display.Size = UDim2.new(1, -10, 1, 0)
    display.Position = UDim2.new(0, 5, 0, 0)
    display.Text = "🎯 เลือกเป้าหมาย..."
    display.TextColor3 = THEME.textDim
    display.Font = Enum.Font.GothamMedium
    display.TextSize = 11
    display.BackgroundTransparency = 1
    display.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""

    local listFrame = Instance.new("ScrollingFrame", content)
    listFrame.Size = UDim2.new(1, 0, 0, 150)
    listFrame.Position = UDim2.new(0, 0, 0, yPos + 32)
    listFrame.BackgroundColor3 = THEME.bg
    listFrame.BackgroundTransparency = 0.1
    listFrame.Visible = false
    listFrame.ZIndex = 10
    listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", listFrame).Color = THEME.accent

    local layout = Instance.new("UIListLayout", listFrame)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local function refreshList()
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        if PvP.selectedPlayer then
            display.Text = "🎯 ล็อก: " .. PvP.selectedPlayer.DisplayName
            display.TextColor3 = THEME.success
        else
            display.Text = "🎯 เลือกเป้าหมาย..."
            display.TextColor3 = THEME.textDim
        end

        for _, plr in ipairs(P:GetPlayers()) do
            if plr ~= lp then
                local opt = Instance.new("TextButton", listFrame)
                opt.Size = UDim2.new(1, 0, 0, 28)
                opt.BackgroundColor3 = THEME.card
                opt.BackgroundTransparency = 0.5
                opt.Text = plr.DisplayName
                opt.TextColor3 = THEME.text
                opt.Font = Enum.Font.Gotham
                opt.TextSize = 11
                opt.ZIndex = 11
                opt.MouseButton1Click:Connect(function()
                    PvP.selectedPlayer = plr
                    PvP.state = "idle"
                    display.Text = "🎯 ล็อก: " .. plr.DisplayName
                    display.TextColor3 = THEME.success
                    listFrame.Visible = false
                end)
            end
        end
        listFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    end

    btn.MouseButton1Click:Connect(function()
        listFrame.Visible = not listFrame.Visible
        if listFrame.Visible then refreshList() end
    end)
    P.PlayerAdded:Connect(refreshList)
    P.PlayerRemoving:Connect(function(p)
        if PvP.selectedPlayer == p then
            PvP.selectedPlayer = nil
            display.Text = "🎯 เลือกเป้าหมาย..."
            display.TextColor3 = THEME.textDim
        end
        refreshList()
    end)
    refreshList()
end

createToggle("💀 God Mode", 10, function(s) flags.god = s end, true)
createToggle("🎥 Spectate", 47, function(s) 
    flags.spec = s 
    if not s then cam.CameraType = Enum.CameraType.Custom end 
end)
createToggle("🛡️ Anti-Void", 84, function(s) flags.antvoid = s end, true)
createToggle("⚔️ PVP MASTER", 121, function(s)
    PvP.enabled = s
    if s then
        workspace.Gravity = 0
        PvP.state = "idle"
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if hrp then 
            hrp.Anchored = false
            hrp.CFrame = SPAWN_CF 
        end
    else
        workspace.Gravity = 196.2
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if hrp then 
            hrp.Anchored = false
            hrp.CFrame = SPAWN_CF 
        end
    end
end)

createDropdown(158) 

local hpFrame = Instance.new("Frame", content)
hpFrame.Size = UDim2.new(1, 0, 0, 45)
hpFrame.Position = UDim2.new(0, 0, 0, 198)
hpFrame.BackgroundColor3 = THEME.card
hpFrame.BackgroundTransparency = THEME.cardTrans
Instance.new("UICorner", hpFrame).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", hpFrame).Color = THEME.accent

local hpText = Instance.new("TextLabel", hpFrame)
hpText.Size = UDim2.new(1, -10, 0, 20)
hpText.Position = UDim2.new(0, 5, 0, 2)
hpText.Text = "เป้าหมาย: ไม่ได้เลือก"
hpText.TextColor3 = THEME.text
hpText.Font = Enum.Font.GothamMedium
hpText.TextSize = 11
hpText.BackgroundTransparency = 1
hpText.TextXAlignment = Enum.TextXAlignment.Left

local hpBarBg = Instance.new("Frame", hpFrame)
hpBarBg.Size = UDim2.new(1, -10, 0, 14)
hpBarBg.Position = UDim2.new(0, 5, 0, 24)
hpBarBg.BackgroundColor3 = Color3.fromRGB(50, 20, 20)
hpBarBg.BorderSizePixel = 0
Instance.new("UICorner", hpBarBg).CornerRadius = UDim.new(0, 4)

local hpBarFill = Instance.new("Frame", hpBarBg)
hpBarFill.Size = UDim2.new(1, 0, 1, 0)
hpBarFill.BackgroundColor3 = THEME.success
hpBarFill.BorderSizePixel = 0
Instance.new("UICorner", hpBarFill).CornerRadius = UDim.new(0, 4)

local dragging, dragInput, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = f.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        f.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local draggingCam, lastMCam = false, nil
UIS.InputBegan:Connect(function(i) 
    if flags.spec and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then 
        draggingCam = true; lastMCam = i.Position 
    end 
end)
UIS.InputChanged:Connect(function(i) 
    if flags.spec and draggingCam and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then 
        local d = i.Position - lastMCam 
        yaw = yaw - (d.X * 0.4) 
        pitch = math.clamp(pitch + (d.Y * 0.4), -80, 80) 
        lastMCam = i.Position 
    elseif flags.spec and i.UserInputType == Enum.UserInputType.MouseWheel then
        dist = math.clamp(dist - (i.Position.Z * 2), 5, 50)
    end
end)
UIS.InputEnded:Connect(function(i) 
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
        draggingCam = false 
    end 
end)
UIS.TouchPinch:Connect(function(touchPositions, scale, velocity, state)
    if flags.spec then
        dist = math.clamp(dist / scale, 5, 50)
    end
end)

local function isAlive(plr)
    return plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") 
       and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0
end

local function isSpawnProtected(plr)
    if not plr or not plr.Character then return true end
    if plr.Character:FindFirstChildOfClass("ForceField") or plr.Character:FindFirstChild("spawnProtectionHighlight") then return true end
    local untilT = plr.Character:GetAttribute("SpawnProtectedUntil")
    if typeof(untilT) == "number" and workspace:GetServerTimeNow() < untilT then return true end
    return false
end

local function getPunchTool()
    if not lp.Character then return nil end
    local inChar = lp.Character:FindFirstChild("Punch")
    if inChar then return inChar end
    local bp = lp:FindFirstChild("Backpack")
    return bp and bp:FindFirstChild("Punch")
end

local function setGhostMode(enabled)
    if not lp.Character then return end
    for _, part in pairs(lp.Character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.CanCollide = not enabled
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if PvP.selectedPlayer then
            local target = PvP.selectedPlayer
            hpText.Text = "เป้าหมาย: " .. target.DisplayName
            
            local hum = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local health = math.floor(hum.Health)
                local maxHealth = math.floor(hum.MaxHealth)
                local percent = math.clamp(health / maxHealth, 0, 1)
                
                TS:Create(hpBarFill, TweenInfo.new(0.1), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
                if percent > 0.5 then
                    hpBarFill.BackgroundColor3 = THEME.success
                elseif percent > 0.2 then
                    hpBarFill.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
                else
                    hpBarFill.BackgroundColor3 = THEME.danger
                end
                
                hpText.Text = target.DisplayName .. " : " .. formatNumber(health) .. " / " .. formatNumber(maxHealth)
                hpText.TextColor3 = THEME.text
            else
                TS:Create(hpBarFill, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 1, 0)}):Play()
                hpBarFill.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                hpText.Text = target.DisplayName .. " : DEAD / WAITING"
                hpText.TextColor3 = THEME.textDim
            end
        else
            hpText.Text = "เป้าหมาย: ไม่ได้เลือก"
            hpText.TextColor3 = THEME.textDim
            TS:Create(hpBarFill, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 1, 0)}):Play()
            hpBarFill.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if PvP.enabled and PvP.selectedPlayer then
            local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            local myHum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
            if not hrp or not myHum then continue end

            local target = PvP.selectedPlayer
            
            if not isAlive(target) or isSpawnProtected(target) then
                if PvP.state ~= "waiting" then
                    PvP.state = "waiting"
                    hrp.Anchored = false
                    setGhostMode(false)
                    hrp.CFrame = SPAWN_CF
                    hrp.AssemblyLinearVelocity = Vector3.zero
                end
            else
                if PvP.state ~= "attacking" then
                    PvP.state = "attacking"
                end

                local tRoot = target.Character.HumanoidRootPart
                setGhostMode(true)
                
                if flags.antvoid and (tRoot.Position.Y < VOID_Y_LOW or tRoot.Position.Y > VOID_Y_HIGH) then
                    if tick() - lastVoidWarp > 0.5 then
                        lastVoidWarp = tick()
                        hrp.Anchored = false
                        
                        if tRoot.Position.Y < VOID_Y_LOW then
                            hrp.CFrame = CFrame.new(tRoot.Position + Vector3.new(0, -5, 0))
                        else
                            hrp.CFrame = CFrame.new(tRoot.Position + Vector3.new(0, 3, 2.5))
                        end
                        
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                        
                        task.delay(0.2, function()
                            if hrp and hrp.Parent then hrp.Anchored = true end
                        end)
                    end
                else
                    hrp.Anchored = false
                    hrp.CFrame = CFrame.lookAt((tRoot.CFrame * CFrame.new(0, 2, 2.5)).Position, tRoot.Position)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                end

                if tick() - PvP.lastPunch >= PvP.punchInterval then
                    local punch = getPunchTool()
                    if punch and punch.Parent ~= lp.Character then pcall(function() myHum:EquipTool(punch) end) end
                    
                    local hand = lp.Character:FindFirstChild("LeftHand") or lp.Character:FindFirstChild("RightHand")
                    if hand then
                        pcall(function()
                            if type(firetouchinterest) == "function" then
                                firetouchinterest(tRoot, hand, 0)
                                firetouchinterest(tRoot, hand, 1)
                            end
                            local muscleEvent = lp:FindFirstChild("muscleEvent")
                            if muscleEvent then muscleEvent:FireServer("punch", hand.Name == "LeftHand" and "leftHand" or "rightHand") end
                            if punch then punch:Activate() end
                        end)
                    end
                    PvP.lastPunch = 
