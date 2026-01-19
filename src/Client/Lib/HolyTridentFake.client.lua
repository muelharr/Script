--[[
    Pure logic fake skin + anim (NO GUI)
    API:
        enable()  -> build model & play anim
        disable() -> destroy
        setSpeedMul(mul) -> ubah kecepatan track
]]
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local Config = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

local tool, fake, castTrack, idleTrack
local enabled = false
local speedMul = 1

-- build model
local function buildModel()
    local m = Instance.new("Model")
    m.Name = "FakeHolyTrident"
    local handle = Instance.new("Part")
    handle.Size, handle.CanCollide, handle.Anchored = Vector3.new(.2,2.8,.2), false, false
    handle.Color = Color3.fromRGB(255,210,73); handle.Material = Enum.Material.Neon
    handle.Name = "Handle"; handle.Parent = m
    local mesh = Instance.new("SpecialMesh", handle)
    mesh.MeshType, mesh.MeshId, mesh.TextureId = Enum.MeshType.FileMesh, Config.MESH_ID, Config.TEX_ID
    mesh.Scale = Vector3.new(1.2,1.2,1.2)
    local pe = Instance.new("ParticleEmitter", handle)
    pe.Size = NumberSequence.new(.3); pe.Lifetime = NumberSequence.new(.5)
    pe.Rate = 30; pe.Texture = "rbxassetid://" .. Config.GLOW_PART_ID
    m.PrimaryPart = handle; return m
end
-- weld
local function weld(c,p)
    local w = Instance.new("Weld"); w.Part0, w.Part1 = p, c
    w.C0 = c.CFrame:inverse() * p.CFrame; w.Parent = c; return w
end
-- anim load
local function loadAnim()
    local cast = Instance.new("Animation"); cast.AnimationId = Config.CAST_ANIM
    castTrack = animator:LoadAnimation(cast); castTrack.Priority = Enum.AnimationPriority.Action
    local idle = Instance.new("Animation"); idle.AnimationId = Config.IDLE_ANIM
    idleTrack = animator:LoadAnimation(idle); idleTrack.Priority = Enum.AnimationPriority.Idle; idleTrack.Looped = true
end
-- sound
local function playSfx(id, parent)
    local s = Instance.new("Sound"); s.SoundId = id; s.Parent = parent; s:Play()
    game:GetService("Debris"):AddItem(s, s.TimeLength + 1)
end
-- equip detector
local function onEquip(t)
    if t.Name:lower():find("rod") then tool = t; enabled = true; enable() end
end
local function onUnequip(t) if t == tool then enabled = false; disable(); tool = nil end end
player.Character.ChildAdded:Connect(function(c) if c:IsA("Tool") then onEquip(c) end end)
player.Character.ChildRemoved:Connect(function(c) if c:IsA("Tool") then onUnequip(c) end end)
-- initial check
for _,t in ipairs(char:GetChildren()) do if t:IsA("Tool") then onEquip(t) end end

-------------------------------------------------
-- PUBLIC API
-------------------------------------------------
function enable()
    if fake then return end
    fake = buildModel()
    local rh = char:FindFirstChild("RightHand")
    if rh then weld(fake.Handle, rh).C0 = CFrame.new(0,-1.2,0)*CFrame.Angles(math.rad(-20),0,0) end
    fake.Parent = char
    if not castTrack then loadAnim() end
    idleTrack:Play()
end
function disable()
    if fake then fake:Destroy(); fake = nil end
    if idleTrack then idleTrack:Stop() end
    if castTrack then castTrack:Stop() end
end
function setSpeedMul(mul)
    speedMul = mul
    if castTrack then castTrack:AdjustSpeed(mul) end
    if idleTrack then idleTrack:AdjustSpeed(mul) end
end
-------------------------------------------------
-- fake cast override
local isCasting = false
local function fakeCast(a, s, _)
    if not enabled or isCasting or s~=Enum.UserInputState.Begin then return end
    isCasting = true
    idleTrack:Stop()
    castTrack:Play(); playSfx(Config.CAST_SOUND, fake.Handle)
    task.wait(castTrack.Length / speedMul)
    castTrack:Stop(); idleTrack:Play(); isCasting = false
end
ContextActionService:BindAction("HolyTridentCast", fakeCast, false, Enum.UserInputType.MouseButton1)

return {enable = enable, disable = disable, setSpeedMul = setSpeedMul}