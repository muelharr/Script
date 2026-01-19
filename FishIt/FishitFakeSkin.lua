-- FishItFakeSkin.lua  (single-file, public release)
-- Visual-only Holy Trident skin + cast anim for Fish It! & any fishing rod
-- Author: muelharr
local repoVer = "v1.0.1"

---------------------------------------------------------------- CONFIG
local CONFIG = {
    CAST_ANIM   = "rbxassetid://17876233325",
    IDLE_ANIM   = "rbxassetid://17876234456",
    MESH_ID     = "rbxassetid://12223378918",
    TEX_ID      = "rbxassetid://12223379005",
    GLOW_PART_ID= "rbxassetid://301049944",
    CAST_SOUND  = "rbxassetid://9063097111",
    HOTKEY      = Enum.KeyCode.F6,
}
---------------------------------------------------------------- SERVICES
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local pGui   = player:WaitForChild("PlayerGui")
---------------------------------------------------------------- GUI BUILD
local screen = Instance.new("ScreenGui")
screen.Name = "HolyTridentFakeGui"
screen.Parent = pGui
screen.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(220,140)
frame.Position = UDim2.fromScale(0.02,0.3)
frame.BackgroundColor3 = Color3.fromRGB(25,27,32)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = screen
Instance.new("UICorner", frame)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,24); title.BackgroundTransparency = 1
title.Text = "Holy Trident Fake"; title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1,1,1); title.TextScaled = true; title.Parent = frame

local tog = Instance.new("TextButton")
tog.Size = UDim2.new(0,90,0,32); tog.Position = UDim2.new(0.5,-45,0,35)
tog.BackgroundColor3 = Color3.fromRGB(0,170,255); tog.Text = "OFF"
tog.Font = Enum.Font.GothamSemibold; tog.TextColor3 = Color3.new(1,1,1)
tog.TextScaled = true; Instance.new("UICorner",tog); tog.Parent = frame

local speedLab = Instance.new("TextLabel")
speedLab.Size = UDim2.new(0,50,0,20); speedLab.Position = UDim2.new(0,10,0,80)
speedLab.BackgroundTransparency = 1; speedLab.Text = "Speed"
speedLab.Font = Enum.Font.Gotham; speedLab.TextScaled = true
speedLab.TextColor3 = Color3.new(1,1,1); speedLab.Parent = frame

local slider = Instance.new("Slider")
slider.Size = UDim2.new(0,120,0,16); slider.Position = UDim2.new(0.5,-10,0,80)
slider.MinValue = 0.2; slider.MaxValue = 2; slider.Value = 1; slider.Step = 0.1
slider.Parent = frame; Instance.new("UICorner",slider.SliderBar)

---------------------------------------------------------------- DRAG
local dragInput,dragStart,startPos,dragging
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false
            end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    if dragging and dragInput == input then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset + delta.X,
                                    startPos.Y.Scale,startPos.Y.Offset + delta.Y)
    end
end)

---------------------------------------------------------------- UTIL
local function playSound(id, parent)
    local s = Instance.new("Sound"); s.SoundId = id; s.Parent = parent
    s:Play(); game:GetService("Debris"):AddItem(s, s.TimeLength + 1)
end
local function weld(c,p)
    local w = Instance.new("Weld"); w.Part0,w.Part1 = p,c
    w.C0 = c.CFrame:inverse() * p.CFrame; w.Parent = c; return w
end

---------------------------------------------------------------- MODEL BUILD
local function buildTrident()
    local m = Instance.new("Model"); m.Name = "FakeHolyTrident"
    local h = Instance.new("Part"); h.Size = Vector3.new(.2,2.8,.2)
    h.CanCollide,h.Anchored = false,false; h.Color = Color3.fromRGB(255,210,73)
    h.Material = Enum.Material.Neon; h.Name = "Handle"; h.Parent = m
    local mesh = Instance.new("SpecialMesh",h)
    mesh.MeshType,mesh.MeshId,mesh.TextureId = Enum.MeshType.FileMesh,CONFIG.MESH_ID,CONFIG.TEX_ID
    mesh.Scale = Vector3.new(1.2,1.2,1.2)
    local pe = Instance.new("ParticleEmitter",h)
    pe.Size = NumberSequence.new(.3); pe.Lifetime = NumberSequence.new(.5)
    pe.Rate = 30; pe.Texture = "rbxassetid://" .. CONFIG.GLOW_PART_ID
    m.PrimaryPart = h; return m
end

---------------------------------------------------------------- ANIM
local castTrack, idleTrack, speedMul = nil,nil,1
local function loadAnims(hum)
    if castTrack then return end
    local castAnim = Instance.new("Animation"); castAnim.AnimationId = CONFIG.CAST_ANIM
    castTrack = hum:LoadAnimation(castAnim); castTrack.Priority = Enum.AnimationPriority.Action
    local idleAnim = Instance.new("Animation"); idleAnim.AnimationId = CONFIG.IDLE_ANIM
    idleTrack = hum:LoadAnimation(idleAnim); idleTrack.Priority = Enum.AnimationPriority.Idle; idleTrack.Looped = true
end
local function setSpeed(m) speedMul = m; if castTrack then castTrack:AdjustSpeed(m) end; if idleTrack then idleTrack:AdjustSpeed(m) end end

---------------------------------------------------------------- STATE
local tool, fakeModel, enabled, isCasting = nil, nil, false, false
local function onEquip(t)
    if not t.Name:lower():find("rod") then return end
    tool = t; enabled = true; local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid"); loadAnims(hum)
    -- BUILD & ATTACH
    if fakeModel then fakeModel:Destroy() end
    fakeModel = buildTrident()
    local rh = char:FindFirstChild("RightHand")
    if rh then
        local w = weld(fakeModel.Handle,rh); w.C0 = CFrame.new(0,-1.2,0)*CFrame.Angles(math.rad(-20),0,0)
    end
    fakeModel.Parent = char; idleTrack:Play()
end
local function onUnequip(t)
    if t ~= tool then return end
    enabled = false; tool = nil
    if idleTrack then idleTrack:Stop() end; if castTrack then castTrack:Stop() end
    if fakeModel then fakeModel:Destroy(); fakeModel = nil end
end
player.Character.ChildAdded:Connect(function(c) if c:IsA("Tool") then onEquip(c) end end)
player.Character.ChildRemoved:Connect(function(c) if c:IsA("Tool") then onUnequip(c) end end)
-- initial check
if player.Character then for _,t in ipairs(player.Character:GetChildren()) do if t:IsA("Tool") then onEquip(t) end end end
player.CharacterAdded:Connect(function(char) char.ChildAdded:Connect(function(c) if c:IsA("Tool") then onEquip(c) end end) end)

---------------------------------------------------------------- FAKE CAST (safe hook)
local function doAnim()
    if not enabled or isCasting or not fakeModel then return end
    isCasting = true
    idleTrack:Stop()
    castTrack:Play(); playSound(CONFIG.CAST_SOUND, fakeModel.Handle)
    task.wait(castTrack.Length / speedMul)
    castTrack:Stop(); idleTrack:Play(); isCasting = false
end
-- Hook tool.Activated (tidak ganggu fungsi asli game)
local function hookToolActivated()
    while task.wait(1) do
        local char = player.Character or player.CharacterAdded:Wait()
        local t = char:FindFirstChildOfClass("Tool")
        if t and t.Name:lower():find("rod") and not t:FindFirstChild("ActivatedHook") then
            local conn; conn = t.Activated:Connect(function() doAnim() end)
            local tag = Instance.new("BoolValue"); tag.Name = "ActivatedHook"; tag.Parent = t
            t:GetPropertyChangedSignal("Parent"):Connect(function() if not t.Parent then conn:Disconnect(); tag:Destroy() end end)
        end
    end
end
task.spawn(hookToolActivated)

---------------------------------------------------------------- GUI INTERACT
tog.MouseButton1Click:Connect(function()
    active = not active; tog.Text = active and "ON" or "OFF"
    tog.BackgroundColor3 = active and Color3.fromRGB(0,255,123) or Color3.fromRGB(0,170,255)
    if active then
        onEquip(tool or player.Character:FindFirstChildOfClass("Tool"))
    else
        onUnequip(tool)
    end
end)
slider.Changed:Connect(function() setSpeed(slider.Value) end)
-- hotkey
UserInputService.InputBegan:Connect(function(inp, g)
    if g then return end
    if inp.KeyCode == CONFIG.HOTKEY then tog.Text = (not active) and "ON" or "OFF"; tog.BackgroundColor3 = (not active) and Color3.fromRGB(0,255,123) or Color3.fromRGB(0,170,255); active = not active; if active then onEquip(tool) else onUnequip(tool) end end
end)

---------------------------------------------------------------- CLEANUP (optional)
local function cleanup()
    if screen then screen:Destroy() end
    onUnequip(tool)
end
player.CharacterRemoving:Connect(cleanup); player.Chatted:Connect(function(m) if m:lower() == "/removefake" then cleanup() end end)

print("[FishItFakeSkin "..repoVer.."] Loaded! Press F6 to toggle GUI.")