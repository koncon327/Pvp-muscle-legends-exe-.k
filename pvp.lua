local P, R, UIS, TS, L = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("TweenService"), game:GetService("Lighting")
local lp, cam = P.LocalPlayer, workspace.CurrentCamera
if lp.PlayerGui:FindFirstChild("HeeUI") then lp.PlayerGui.HeeUI:Destroy() end
local SPAWN_CF = CFrame.new(5105.21, 110.05, 6341.85)
local VOID_Y_LOW, VOID_Y_HIGH = -500, 5000
local THEME = {bg = Color3.fromRGB(20, 20, 25), bgTrans = 0.15, card = Color3.fromRGB(35, 35, 45), cardTrans = 0.2, text = Color3.fromRGB(255, 255, 255), textDim = Color3.fromRGB(170, 170, 180), accent = Color3.fromRGB(138, 43, 226), success = Color3.fromRGB(0, 255, 127), danger = Color3.fromRGB(255, 69, 0)}
local flags = {god=false, spec=false, antvoid=true}
local yaw, pitch, dist, lastVoidWarp = 0, 15, 12, 0
local PvP = {enabled=false, selectedPlayer=nil, punchInterval=0.15, lastPunch=0, state="idle"}
local function formatNumber(n)
    if n>=1e18 then return string.format("%.1fQi",n/1e18)
    elseif n>=1e15 then return string.format("%.1fQa",n/1e15)
    elseif n>=1e12 then return string.format("%.1fT",n/1e12)
    elseif n>=1e9 then return string.format("%.1fB",n/1e9)
    elseif n>=1e6 then return string.format("%.1fM",n/1e6)
    elseif n>=1e3 then return string.format("%.1fK",n/1e3)
    else return tostring(math.floor(n)) end
end
local sg = Instance.new("ScreenGui")
sg.Name, sg.ResetOnSpawn, sg.IgnoreGuiInset, sg.Parent = "HeeUI", false, true, lp.PlayerGui
local toggleBtn = Instance.new("TextButton", sg)
toggleBtn.Size, toggleBtn.Position, toggleBtn.BackgroundColor3, toggleBtn.BackgroundTransparency = UDim2.new(0,45,0,45), UDim2.new(0.05,0,0.15,0), THEME.bg, THEME.bgTrans
toggleBtn.Text, toggleBtn.TextColor3, toggleBtn.TextSize, toggleBtn.Font = "HEE", THEME.text, 14, Enum.Font.GothamBlack
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", toggleBtn).Color = THEME.accent
local f = Instance.new("Frame", sg)
f.Size, f.Position, f.BackgroundColor3, f.BackgroundTransparency, f.Visible, f.Active = UDim2.new(0,200,0,360), UDim2.new(0.5,-100,0.5,-180), THEME.bg, THEME.bgTrans, false, true
Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
local fStroke = Instance.new("UIStroke", f)
fStroke.Color, fStroke.Thickness, fStroke.Transparency = THEME.accent, 1.5, 0.5
local header = Instance.new("Frame", f)
header.Size, header.BackgroundTransparency = UDim2.new(1,0,0,35), 1
local title = Instance.new("TextLabel", header)
title.Size, title.Position, title.Text, title.TextColor3, title.TextSize, title.Font = UDim2.new(1,-30,1,0), UDim2.new(0,12,0,0), "HEE.EXE PVP", THEME.text, 14, Enum.Font.GothamBold
title.BackgroundTransparency, title.TextXAlignment = 1, Enum.TextXAlignment.Left
local cls = Instance.new("TextButton", header)
cls.Size, cls.Position, cls.Text, cls.TextColor3, cls.BackgroundTransparency, cls.Font, cls.TextSize = UDim2.new(0,25,0,25), UDim2.new(1,-32,0,5), "×", THEME.danger, 1, Enum.Font.GothamBold, 18
local content = Instance.new("ScrollingFrame", f)
content.Size, content.Position, content.BackgroundTransparency = UDim2.new(1,-16,1,-45), UDim2.new(0,8,0,40), 1
content.ScrollBarThickness, content.ScrollBarImageColor3, content.CanvasSize = 2, THEME.accent, UDim2.new(0,0,0,450)
local function createToggle(text, yPos, callback, defaultOn)
    local card = Instance.new("Frame", content)
    card.Size, card.Position, card.BackgroundColor3, card.BackgroundTransparency = UDim2.new(1,0,0,32), UDim2.new(0,0,0,yPos), THEME.card, THEME.cardTrans
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", card).Color = THEME.accent
    local lbl = Instance.new("TextLabel", card)
    lbl.Size, lbl.Position, lbl.Text, lbl.TextColor3, lbl.Font, lbl.TextSize = UDim2.new(1,-50,1,0), UDim2.new(0,10,0,0), text, THEME.text, Enum.Font.GothamMedium, 11
    lbl.BackgroundTransparency, lbl.TextXAlignment = 1, Enum.TextXAlignment.Left
    local switchBtn = Instance.new("TextButton", card)
    switchBtn.Size, switchBtn.Position, switchBtn.BackgroundColor3, switchBtn.Text, switchBtn.AutoButtonColor = UDim2.new(0,30,0,16), UDim2.new(1,-40,0.5,-8), THEME.bg, "", false
    Instance.new("UICorner", switchBtn).CornerRadius = UDim.new(1, 0)
    local swStroke = Instance.new("UIStroke", switchBtn)
    swStroke.Color = THEME.textDim
    local circle = Instance.new("Frame", switchBtn)
    circle.Size, circle.Position, circle.BackgroundColor3 = UDim2.new(0,12,0,12), UDim2.new(0,2,0.5,-6), THEME.textDim
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    local isOn, canClick = defaultOn or false, true
    if isOn then
        switchBtn.BackgroundColor3, swStroke.Color, circle.BackgroundColor3, circle.Position = THEME.success, THEME.success, THEME.text, UDim2.new(1,-14,0.5,-6)
    end
    switchBtn.InputBegan:Connect(function(input)
        if canClick and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then
            canClick = false; isOn = not isOn
            if isOn then
                switchBtn.BackgroundColor3, swStroke.Color, circle.BackgroundColor3 = THEME.success, THEME.success, THEME.text
                TS:Create(circle,TweenInfo.new(0.15),{Position=UDim2.new(1,-14,0.5,-6)}):Play()
            else
                switchBtn.BackgroundColor3, swStroke.Color, circle.BackgroundColor3 = THEME.bg, THEME.textDim, THEME.textDim
                TS:Create(circle,TweenInfo.new(0.15),{Position=UDim2.new(0,2,0.5,-6)}):Play()
            end
            callback(isOn)
        end
    end)
    switchBtn.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then canClick = true end
    end)
end
local function createDropdown(yPos)
    local frame = Instance.new("Frame", content)
    frame.Size, frame.Position, frame.BackgroundColor3, frame.BackgroundTransparency = UDim2.new(1,0,0,30), UDim2.new(0,0,0,yPos), THEME.card, THEME.cardTrans
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", frame).Color = THEME.accent
    local display = Instance.new("TextLabel", frame)
    display.Size, display.Position, display.Text, display.TextColor3, display.Font, display.TextSize = UDim2.new(1,-10,1,0), UDim2.new(0,5,0,0), "🎯 เลือกเป้าหมาย...", THEME.textDim, Enum.Font.GothamMedium, 11
    display.BackgroundTransparency, display.TextXAlignment = 1, Enum.TextXAlignment.Left
    local btn = Instance.new("TextButton", frame)
    btn.Size, btn.BackgroundTransparency, btn.Text = UDim2.new(1,0,1,0), 1, ""
    local listFrame = Instance.new("ScrollingFrame", content)
    listFrame.Size, listFrame.Position, listFrame.BackgroundColor3, listFrame.BackgroundTransparency = UDim2.new(1,0,0,150), UDim2.new(0,0,0,yPos+32), THEME.bg, 0.1
    listFrame.Visible, listFrame.ZIndex, listFrame.CanvasSize = false, 10, UDim2.new(0,0,0,0)
    Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", listFrame).Color = THEME.accent
    local layout = Instance.new("UIListLayout", listFrame)
    local function refreshList()
        for _,child in ipairs(listFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
        display.Text = PvP.selectedPlayer and "🎯 ล็อก: "..PvP.selectedPlayer.DisplayName or "🎯 เลือกเป้าหมาย..."
        display.TextColor3 = PvP.selectedPlayer and THEME.success or THEME.textDim
        for _,plr in ipairs(P:GetPlayers()) do
            if plr ~= lp then
                local opt = Instance.new("TextButton", listFrame)
                opt.Size, opt.BackgroundColor3, opt.BackgroundTransparency, opt.Text, opt.TextColor3 = UDim2.new(1,0,0,28), THEME.card, 0.5, plr.DisplayName, THEME.text
                opt.Font, opt.TextSize, opt.ZIndex = Enum.Font.Gotham, 11, 11
                opt.MouseButton1Click:Connect(function()
                    PvP.selectedPlayer, PvP.state, display.Text, display.TextColor3 = plr, "idle", "🎯 ล็อก: "..plr.DisplayName, THEME.success
                    listFrame.Visible = false
                end)
            end
        end
        listFrame.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y)
    end
    btn.MouseButton1Click:Connect(function() listFrame.Visible = not listFrame.Visible; if listFrame.Visible then refreshList() end end)
    P.PlayerAdded:Connect(refreshList)
    P.PlayerRemoving:Connect(function(p)
        if PvP.selectedPlayer == p then PvP.selectedPlayer, display.Text, display.TextColor3 = nil, "🎯 เลือกเป้าหมาย...", THEME.textDim end
        refreshList()
    end)
    refreshList()
end
createToggle("💀 God Mode", 10, function(s) flags.god = s end, true)
createToggle("🎥 Spectate", 47, function(s) flags.spec = s; if not s then cam.CameraType = Enum.CameraType.Custom end end)
createToggle("🛡️ Anti-Void", 84, function(s) flags.antvoid = s end, true)
createToggle("⚔️ PVP MASTER", 121, function(s)
    PvP.enabled, PvP.state = s, "idle"
    workspace.Gravity = s and 0 or 196.2
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Anchored = false; hrp.CFrame = SPAWN_CF end
end)
createDropdown(158)
local hpFrame = Instance.new("Frame", content)
hpFrame.Size, hpFrame.Position, hpFrame.BackgroundColor3, hpFrame.BackgroundTransparency = UDim2.new(1,0,0,45), UDim2.new(0,0,0,198), THEME.card, THEME.cardTrans
Instance.new("UICorner", hpFrame).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", hpFrame).Color = THEME.accent
local hpText = Instance.new("TextLabel", hpFrame)
hpText.Size, hpText.Position, hpText.Text, hpText.TextColor3, hpText.Font, hpText.TextSize = UDim2.new(1,-10,0,20), UDim2.new(0,5,0,2), "เป้าหมาย: ไม่ได้เลือก", THEME.text, Enum.Font.GothamMedium, 11
hpText.BackgroundTransparency, hpText.TextXAlignment = 1, Enum.TextXAlignment.Left
local hpBarBg = Instance.new("Frame", hpFrame)
hpBarBg.Size, hpBarBg.Position, hpBarBg.BackgroundColor3, hpBarBg.BorderSizePixel = UDim2.new(1,-10,0,14), UDim2.new(0,5,0,24), Color3.fromRGB(50,20,20), 0
Instance.new("UICorner", hpBarBg).CornerRadius = UDim.new(0, 4)
local hpBarFill = Instance.new("Frame", hpBarBg)
hpBarFill.Size, hpBarFill.BackgroundColor3, hpBarFill.BorderSizePixel = UDim2.new(1,0,1,0), THEME.success, 0
Instance.new("UICorner", hpBarFill).CornerRadius = UDim.new(0, 4)
local dragging, dragInput, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging, dragStart, startPos = true, input.Position, f.Position
        input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then dragging = false end end)
    end
end)
header.InputChanged:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then dragInput = input end end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        f.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y)
    end
end)
local draggingCam, lastMCam = false, nil
UIS.InputBegan:Connect(function(i) if flags.spec and (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) then draggingCam, lastMCam = true, i.Position end end)
UIS.InputChanged:Connect(function(i)
    if flags.spec and draggingCam and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        local d = i.Position - lastMCam
        yaw, pitch, lastMCam = yaw - (d.X*0.4), math.clamp(pitch + (d.Y*0.4), -80, 80), i.Position
    elseif flags.spec and i.UserInputType==Enum.UserInputType.MouseWheel then dist = math.clamp(dist - (i.Position.Z*2), 5, 50) end
end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then draggingCam = false end end)
UIS.TouchPinch:Connect(function(touchPositions, scale, velocity, state) if flags.spec then dist = math.clamp(dist/scale, 5, 50) end end)
local function isAlive(plr) return plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 end
local function isSpawnProtected(plr)
    if not plr or not plr.Character then return true end
    if plr.Character:FindFirstChildOfClass("ForceField") or plr.Character:FindFirstChild("spawnProtectionHighlight") then return true end
    local untilT = plr.Character:GetAttribute("SpawnProtectedUntil")
    return typeof(untilT)=="number" and workspace:GetServerTimeNow() < untilT
end
local function getPunchTool()
    if not lp.Character then return nil end
    return lp.Character:FindFirstChild("Punch") or (lp:FindFirstChild("Backpack") and lp.Backpack:FindFirstChild("Punch"))
end
local function setGhostMode(enabled)
    if not lp.Character then return end
    for _,part in pairs(lp.Character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name~="HumanoidRootPart" then part.CanCollide = not enabled end
    end
end
task.spawn(function()
    while true do
        task.wait(0.1)
        if PvP.selectedPlayer then
            local target, hum = PvP.selectedPlayer, PvP.selectedPlayer.Character and PvP.selectedPlayer.Character:FindFirstChildOfClass("Humanoid")
            hpText.Text = "เป้าหมาย: "..target.DisplayName
            if hum and hum.Health > 0 then
                local health, maxHealth = math.floor(hum.Health), math.floor(hum.MaxHealth)
                local percent = math.clamp(health/maxHealth, 0, 1)
                TS:Create(hpBarFill,TweenInfo.new(0.1),{Size=UDim2.new(percent,0,1,0)}):Play()
                hpBarFill.BackgroundColor3 = percent > 0.5 and THEME.success or (percent > 0.2 and Color3.fromRGB(255,200,0) or THEME.danger)
                hpText.Text, hpText.TextColor3 = target.DisplayName.." : "..formatNumber(health).." / "..formatNumber(maxHealth), THEME.text
            else
                TS:Create(hpBarFill,TweenInfo.new(0.1),{Size=UDim2.new(1,0,1,0)}):Play()
                hpBarFill.BackgroundColor3, hpText.Text, hpText.TextColor3 = Color3.fromRGB(80,80,80), target.DisplayName.." : DEAD / WAITING", THEME.textDim
            end
        else
            hpText.Text, hpText.TextColor3 = "เป้าหมาย: ไม่ได้เลือก", THEME.textDim
            TS:Create(hpBarFill,TweenInfo.new(0.1),{Size=UDim2.new(1,0,1,0)}):Play()
            hpBarFill.BackgroundColor3 = Color3.fromRGB(80,80,80)
        end
    end
end)
task.spawn(function()
    while true do
        task.wait(0.1)
        if PvP.enabled and PvP.selectedPlayer then
            local hrp, myHum = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart"), lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
            if not hrp or not myHum then continue end
            local target = PvP.selectedPlayer
            if not isAlive(target) or isSpawnProtected(target) then
                if PvP.state ~= "waiting" then
                    PvP.state, hrp.Anchored = "waiting", false
                    setGhostMode(false)
                    hrp.CFrame, hrp.AssemblyLinearVelocity = SPAWN_CF, Vector3.zero
                end
            else
                if PvP.state ~= "attacking" then PvP.state = "attacking" end
                local tRoot = target.Character.HumanoidRootPart
                setGhostMode(true)
                if flags.antvoid and (tRoot.Position.Y < VOID_Y_LOW or tRoot.Position.Y > VOID_Y_HIGH) then
                    if tick() - lastVoidWarp > 0.5 then
                        lastVoidWarp, hrp.Anchored = tick(), false
                        hrp.CFrame = tRoot.Position.Y < VOID_Y_LOW and CFrame.new(tRoot.Position+Vector3.new(0,-5,0)) or CFrame.new(tRoot.Position+Vector3.new(0,3,2.5))
                        hrp.AssemblyLinearVelocity, hrp.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
                        task.delay(0.2, function() if hrp and hrp.Parent then hrp.Anchored = true end end)
                    end
                else
                    hrp.Anchored = false
                    hrp.CFrame = CFrame.lookAt((tRoot.CFrame*CFrame.new(0,2,2.5)).Position, tRoot.Position)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                end
                if tick() - PvP.lastPunch >= PvP.punchInterval then
                    local punch = getPunchTool()
                    if punch and punch.Parent ~= lp.Character then pcall(function() myHum:EquipTool(punch) end) end
                    local hand = lp.Character:FindFirstChild("LeftHand") or lp.Character:FindFirstChild("RightHand")
                    if hand then
                        pcall(function()
                            if type(firetouchinterest)=="function" then firetouchinterest(tRoot,hand,0); firetouchinterest(tRoot,hand,1) end
                            local me = lp:FindFirstChild("muscleEvent")
                            if me then me:FireServer("punch", hand.Name=="LeftHand" and "leftHand" or "rightHand") end
                            if punch then punch:Activate() end
                        end)
                    end
                    PvP.lastPunch = tick()
                end
            end
        end
    end
end)
R.Heartbeat:Connect(function()
    local ch = lp.Character
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    if flags.god then
        local actualMax = 1e20
        if hum.MaxHealth < 1e19 then hum.MaxHealth = actualMax else actualMax = hum.MaxHealth end
        if hum.Health < actualMax then hum.Health = actualMax end
        hum.PlatformStand = false
        if hrp.Position.Y < VOID_Y_LOW then hrp.Anchored, hrp.CFrame, hrp.AssemblyLinearVelocity = false, SPAWN_CF, Vector3.zero end
    end
    if flags.spec and PvP.selectedPlayer and PvP.selectedPlayer.Character then
        local th = PvP.selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if th then
            cam.CameraType = Enum.CameraType.Scriptable
            local ry, rp = math.rad(yaw), math.rad(pitch)
            local off = Vector3.new(math.sin(ry)*math.cos(rp), math.sin(rp), math.cos(ry)*math.cos(rp)) * dist
            cam.CFrame = CFrame.new(th.Position + off + Vector3.new(0,3,0), th.Position + Vector3.new(0,2,0))
        end
    elseif flags.spec then cam.CameraType = Enum.CameraType.Custom end
end)
toggleBtn.MouseButton1Click:Connect(function() f.Visible = not f.Visible end)
cls.MouseButton1Click:Connect(function()
    cam.CameraType = Enum.CameraType.Custom
    if lp.Character then
        local hrp = lp.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Anchored, hrp.CFrame = false, SPAWN_CF end
    end
    sg:Destroy()
end)
lp.CharacterAdded:Connect(function(char)
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if hrp then hrp.Anchored = false end
    PvP.state = "idle"
end)
