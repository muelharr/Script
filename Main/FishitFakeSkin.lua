-- FishItFakeSkin.lua  (v1.0.2)  - ready to loadstring
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

-- anti double
local old = pGui:FindFirstChild("HolyTridentFakeGui")
if old then old:Destroy() end

local CONFIG = {
    CAST_ANIM   = "rbxassetid://17876233325",
    IDLE_ANIM   = "rbxassetid://17876234456",
    MESH_ID     = "rbxassetid://12223378918",
    TEX_ID      = "rbxassetid://12223379005",
    GLOW_PART_ID= "rbxassetid://301049944",
    CAST_SOUND  = "rbxassetid://9063097111",
    HOTKEY      = Enum.KeyCode.F6,
}

-- GUI
local screen = Instance.new("ScreenGui")
screen.Name = "HolyTridentFakeGui"; screen.Parent = pGui; screen.ResetOnSpawn = false
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(220,140); frame.Position = UDim2.fromScale(.02,.3)
frame.BackgroundColor3 = Color3.fromRGB(25,27,32); frame.BorderSizePixel = 0; frame.Parent = screen
Instance.new("UICorner",frame)
local tog = Instance.new("TextButton")
tog.Size = UDim2.new(0,90,0,32); tog.Position = UDim2.new(.5,-45,.3,0)
tog.BackgroundColor3 = Color3.fromRGB(0,170,255); tog.Text = "OFF"
tog.Font = Enum.Font.GothamSemibold; tog.TextColor3 = Color3.new(1,1,1); tog.TextScaled = true
Instance.new("UICorner",tog); tog.Parent = frame

-- util
local function playSound(id, par)
    local s = Instance.new("Sound",par); s.SoundId = id; s:Play(); game:GetService("Debris"):AddItem(s,3)
end
local function weld(c,p)
    local w = Instance.new("Weld"); w.Part0,p.Part1 = p,c; w.C0 = c.CFrame:inverse()*p.CFrame; w.Parent=c; return w
end
local function build()
    local m = Instance.new("Model"); m.Name="FakeHolyTrident"
    local h = Instance.new("Part"); h.Size=Vector3.new(.2,2.8,.2); h.CanCollide=false; h.Anchored=false
    h.Color = Color3.fromRGB(255,210,73); h.Material = Enum.Material.Neon; h.Name="Handle"; h.Parent=m
    Instance.new("SpecialMesh",h).MeshId = CONFIG.MESH_ID; h.Mesh.TextureId = CONFIG.TEX_ID; h.Mesh.Scale = Vector3.new(1.2,1.2,1.2)
    Instance.new("ParticleEmitter",h).Texture="rbxassetid://" .. CONFIG.GLOW_PART_ID
    m.PrimaryPart = h; return m
end

-- anim
local castTrack,idleTrack,speedMul = nil,nil,1
local function loadAnims(hum)
    if castTrack then return end
    castTrack = hum:LoadAnimation((function() local a=Instance.new("Animation"); a.AnimationId=CONFIG.CAST_ANIM; return a end)())
    idleTrack = hum:LoadAnimation((function() local a=Instance.new("Animation"); a.AnimationId=CONFIG.IDLE_ANIM; return a end)())
    castTrack.Priority = Enum.AnimationPriority.Action; idleTrack.Priority = Enum.AnimationPriority.Idle; idleTrack.Looped = true
end
local function setSpeed(m) speedMul = m; if castTrack then castTrack.AdjustSpeed(castTrack,m) end; if idleTrack then idleTrack.AdjustSpeed(idleTrack,m) end end

-- equip
local tool,fakeModel,enabled = nil,nil,false
local function onEquip(t)
    if not t.Name:lower():find("rod") then return end
    tool = t; enabled = true; local char = player.Character or player.CharacterAdded:Wait()
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
player.Character.ChildAdded:Connect(function(c) if c:IsA("Tool") then onEquip(c) end end)
player.Character.ChildRemoved:Connect(function(c) if c:IsA("Tool") then onUnequip() end end)
if player.Character then for _,t in ipairs(player.Character:GetChildren()) do if t:IsA("Tool") then onEquip(t) end end end
player.CharacterAdded:Connect(function(char) char.ChildAdded:Connect(function(c) if c:IsA("Tool") then onEquip(c) end end) end)

-- cast hook
local isCasting = false
local function doAnim()
    if not enabled or isCasting or not fakeModel then return end
    isCasting = true
    idleTrack:Stop()
    castTrack:Play(); playSound(CONFIG.CAST_SOUND, fakeModel.Handle)
    task.wait(castTrack.Length / speedMul)
    castTrack:Stop(); idleTrack:Play(); isCasting = false
end
-- aman hook Activated
local function hook()
    while task.wait(1) do
        local char = player.Character or player.CharacterAdded:Wait()
        local t = char:FindFirstChildOfClass("Tool")
        if t and t.Name:lower():find("rod") and not t:FindFirstChild("HookTag") then
            local tag = Instance.new("BoolValue"); tag.Name = "HookTag"; tag.Parent = t
            t.Activated:Connect(function() doAnim() end)
        end
    end
end
task.spawn(hook)

-- GUI toggle
local active = false
tog.MouseButton1Click:Connect(function()
    active = not active; tog.Text = active and "ON" or "OFF"
    tog.BackgroundColor3 = active and Color3.fromRGB(0,255,123) or Color3.fromRGB(0,170,255)
    if active then onEquip(tool) else onUnequip() end
end)

-- hotkey F6
game:GetService("UserInputService").InputBegan:Connect(function(inp, g)
    if g then return end
    if inp.KeyCode == CONFIG.HOTKEY then tog.Text = (not active) and "ON" or "OFF"; tog.BackgroundColor3 = (not active) and Color3.fromRGB(0,255,123) or Color3.fromRGB(0,170,255); active = not active; if active then onEquip(tool) else onUnequip() end end
end)

print("[FishItFakeSkin] Loaded! Press F6 to toggle GUI.")
