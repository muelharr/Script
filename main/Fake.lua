-- FishItFakeSkin.lua  v1.0.3  (public loader)
-- Visual-only Holy Trident + anim + close button
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

---------- ANTI DOUBLE ----------
for _,v in ipairs(pGui:GetChildren()) do
    if v.Name == "HolyTridentFakeGui" then v:Destroy() end
end
for _,m in ipairs(workspace:GetChildren()) do
    if m.Name == "FakeHolyTrident" and m:IsA("Model") then m:Destroy() end
end

---------- CONFIG ----------
local CONFIG = {
    CAST_ANIM   = "rbxassetid://17876233325",
    IDLE_ANIM   = "rbxassetid://17876234456",
    MESH_ID     = "rbxassetid://12223378918",
    TEX_ID      = "rbxassetid://12223379005",
    GLOW_PART_ID= "rbxassetid://301049944",
    CAST_SOUND  = "rbxassetid://9063097111",
    HOTKEY      = Enum.KeyCode.F6,
}

---------- UTIL ----------
local function weld(c,p)
    local w = Instance.new("Weld"); w.Part0,p.Part1 = p,c
    w.C0 = c.CFrame:inverse() * p.CFrame; w.Parent = c; return w
end
local function playSound(id,par)
    local s = Instance.new("Sound",par); s.SoundId = id; s:Play()
    game:GetService("Debris"):AddItem(s,3)
end

---------- MODEL ----------
local function build()
    local m = Instance.new("Model"); m.Name = "FakeHolyTrident"
    local h = Instance.new("Part"); h.Size = Vector3.new(.2,2.8,.2)
    h.CanCollide = false; h.Anchored = false; h.Color = Color3.fromRGB(255,210,73)
    h.Material = Enum.Material.Neon; h.Name = "Handle"; h.Parent = m
    Instance.new("SpecialMesh",h).MeshType = Enum.MeshType.FileMesh
    h.Mesh.MeshId,h.Mesh.TextureId = CONFIG.MESH_ID,CONFIG.TEX_ID
    h.Mesh.Scale = Vector3.new(1.2,1.2,1.2)
    Instance.new("ParticleEmitter",h).Texture = "rbxassetid://" .. CONFIG.GLOW_PART_ID
    m.PrimaryPart = h; return m
end

---------- ANIM ----------
local castTrack,idleTrack,speedMul = nil,nil,1
local function loadAnims(hum)
    if castTrack then return end
    castTrack = hum:LoadAnimation((function() local a=Instance.new("Animation"); a.AnimationId=CONFIG.CAST_ANIM; return a end)())
    idleTrack = hum:LoadAnimation((function() local a=Instance.new("Animation"); a.AnimationId=CONFIG.IDLE_ANIM; return a end)())
    castTrack.Priority = Enum.AnimationPriority.Action; idleTrack.Priority = Enum.AnimationPriority.Idle; idleTrack.Looped = true
end
local function setSpeed(m)
    speedMul = m
    if castTrack then castTrack:AdjustSpeed(m) end
    if idleTrack then idleTrack:AdjustSpeed(m) end
end

---------- STATE ----------
local tool,fakeModel,enabled = nil,nil,false
local function doEquip(t)
    if not t or not t:IsA("Tool") then return end
    if not string.find(t.Name:lower(), "rod") then return end
    tool = t; enabled = true
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid"); loadAnims(hum)
    if fakeModel then fakeModel:Destroy() end
    fakeModel = build()
    local rh = char:FindFirstChild("RightHand")
    if rh then weld(fakeModel.Handle,rh).C0 = CFrame.new(0,-1.2,0)*CFrame.Angles(math.rad(-20),0,0) end
    fakeModel.Parent = char; idleTrack:Play()
end
local function onUnequip()
    enabled = false; tool = nil
    if idleTrack then idleTrack:Stop() end; if castTrack then castTrack:Stop() end
    if fakeModel then fakeModel:Destroy(); fakeModel = nil end
end

---------- AUTO EQUIP / CHECK ----------
local function checkAndEquip()
    -- 1. cek character
    local char = player.Character or player.CharacterAdded:Wait()
    local t = char:FindFirstChildOfClass("Tool")
    if t then doEquip(t); return end
    -- 2. cek backpack, equip paksa
    local bp = player:FindFirstChildOfClass("Backpack")
    if bp then
        for _,v in ipairs(bp:GetChildren()) do
            if v:IsA("Tool") and string.find(v.Name:lower(), "rod") then
                local hum = char:WaitForChild("Humanoid")
                hum:EquipTool(v)
                break
            end
        end
    end
end
player.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(function(c) if c:IsA("Tool") then doEquip(c) end end)
    task.wait(.5); checkAndEquip()
end)
if player.Character then checkAndEquip() end
player.Backpack.ChildAdded:Connect(function(t) if t:IsA("Tool") then checkAndEquip() end end)

---------- CAST ANIM ----------
local isCasting = false
local function playCast()
    if not enabled or isCasting or not fakeModel then return end
    isCasting = true
    idleTrack:Stop()
    castTrack:Play(); playSound(CONFIG.CAST_SOUND, fakeModel.Handle)
    task.wait(castTrack.Length / speedMul)
    castTrack:Stop(); idleTrack:Play(); isCasting = false
end
-- safe hook Activated
local function hookActivated()
    while task.wait(1) do
        local char = player.Character or player.CharacterAdded:Wait()
        local t = char:FindFirstChildOfClass("Tool")
        if t and string.find(t.Name:lower(), "rod") and not t:FindFirstChild("HookTag") then
            t.Activated:Connect(function() playCast() end)
            Instance.new("BoolValue",t).Name = "HookTag"
        end
    end
end
task.spawn(hookActivated)

---------- GUI ----------
local screen = Instance.new("ScreenGui")
screen.Name = "HolyTridentFakeGui"; screen.Parent = pGui; screen.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(220,160); frame.Position = UDim2.fromScale(.02,.3)
frame.BackgroundColor3 = Color3.fromRGB(25,27,32); frame.BorderSizePixel = 0; frame.Active = true; frame.Parent = screen
Instance.new("UICorner",frame)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,24); title.BackgroundTransparency = 1; title.Text = "Holy Trident Fake"; title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1,1,1); title.TextScaled = true; title.Parent = frame

local tog = Instance.new("TextButton")
tog.Size = UDim2.new(0,90,0,32); tog.Position = UDim2.new(.5,-45,.25,0)
tog.BackgroundColor3 = Color3.fromRGB(0,170,255); tog.Text = "OFF"
tog.Font = Enum.Font.GothamSemibold; tog.TextColor3 = Color3.new(1,1,1); tog.TextScaled = true
Instance.new("UICorner",tog); tog.Parent = frame

local closeBtn = Instance.new("TextButton") -- TOMBOL CLOSE
closeBtn.Size = UDim2.new(0,20,0,20); closeBtn.Position = UDim2.new(1,-25,0,5)
closeBtn.BackgroundColor3 = Color3.fromRGB(255,70,70); closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextColor3 = Color3.new(1,1,1); closeBtn.TextScaled = true
Instance.new("UICorner",closeBtn); closeBtn.Parent = frame

local speedLab = Instance.new("TextLabel")
speedLab.Size = UDim2.new(0,50,0,20); speedLab.Position = UDim2.new(0,10,0,80)
speedLab.BackgroundTransparency = 1; speedLab.Text = "Speed"; speedLab.Font = Enum.Font.Gotham; speedLab.TextScaled = true
speedLab.TextColor3 = Color3.new(1,1,1); speedLab.Parent = frame

local slider = Instance.new("Slider")
slider.Size = UDim2.new(0,120,0,16); slider.Position = UDim2.new(0.5,-10,0,80)
slider.MinValue = 0.2; slider.MaxValue = 2; slider.Value = 1; slider.Step = 0.1; slider.Parent = frame
Instance.new("UICorner",slider.SliderBar)

---------- DRAG ----------
local dragInput,dragStart,startPos,dragging
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and input.Position.Y < frame.Position.Y.Offset + 24 then
        dragging = true; dragStart = input.Position; startPos = frame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    if dragging and dragInput == input then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset + delta.X, startPos.Y.Scale,startPos.Y.Offset + delta.Y)
    end
end)

---------- GUI INTERACT ----------
local active = false
tog.MouseButton1Click:Connect(function()
    active = not active; tog.Text = active and "ON" or "OFF"
    tog.BackgroundColor3 = active and Color3.fromRGB(0,255,123) or Color3.fromRGB(0,170,255)
    if active then
        checkAndEquip()
    else
        onUnequip()
    end
end)
closeBtn.MouseButton1Click:Connect(function() screen:Destroy(); onUnequip() end) -- TUTUP GUI
slider.Changed:Connect(function() setSpeed(slider.Value) end)

---------- HOTKEY & CLEANUP ----------
UserInputService.InputBegan:Connect(function(inp, g)
    if g then return end
    if inp.KeyCode == CONFIG.HOTKEY then
        active = not active; tog.Text = active and "ON" or "OFF"
        tog.BackgroundColor3 = active and Color3.fromRGB(0,255,123) or Color3.fromRGB(0,170,255)
        if active then checkAndEquip() else onUnequip() end
    end
end)
player.CharacterRemoving:Connect(onUnequip)
-- chat command
player.Chatted:Connect(function(m) if m:lower() == "/removefake" then screen:Destroy(); onUnequip() end end)

print("[FishItFakeSkin] Loaded! Press F6 to toggle GUI. Chat /removefake to close.")
