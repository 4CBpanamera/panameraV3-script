-- ============================================
-- ЗВУК ПРИ ЗАХВАТЕ ИГРОКА (FIXED)
-- ============================================
local GRAB_SOUND_ID = "140207837688369"
local GRAB_VOLUME = 1
local GRAB_SPEED = 1

local function PlayGrabSound()
    local player = game.Players.LocalPlayer
    if not player then return end
    
    -- Создаем звук
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. tostring(GRAB_SOUND_ID)
    sound.Volume = GRAB_VOLUME
    sound.PlaybackSpeed = GRAB_SPEED
    
    -- Находим родителя
    local parent = player:FindFirstChild("Backpack") 
    if not parent then
        parent = player:FindFirstChild("Character")
    end
    if not parent then
        parent = workspace
    end
    
    sound.Parent = parent
    sound:Play()
    
    -- Авто-удаление
    task.spawn(function()
        task.wait(3)
        if sound and sound.Parent then
            sound:Destroy()
        end
    end)
end

-- ============================================
-- ПЕРЕОПРЕДЕЛЯЕМ mouse1click (если не существует)
-- ============================================
if not mouse1click then
    local function mouse1click()
        local player = game.Players.LocalPlayer
        local mouse = player and player:GetMouse()
        if mouse then
            mouse.Button1Down:Fire()
        end
    end
    _G.mouse1click = mouse1click
end

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local workspaceService = game:GetService("Workspace")
local debrisService = game:GetService("Debris")
local localPlayer = Players.LocalPlayer

-- ============================================
-- ЗАГРУЗЧИК INVENTORY PLUS V2
-- ============================================
local inventoryLoaded = false

local function loadInventory()
    if inventoryLoaded then return end
    local success, err = pcall(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/4CBpanamera/panameralockV2/main/panameralockV2.lua'))()
    end)
    if success then
        inventoryLoaded = true
        print("✅ InventoryPlus V2 loaded!")
    else
        warn("❌ Failed to load Inventory: " .. tostring(err))
    end
end

task.spawn(function()
    task.wait(2)
    loadInventory()
end)

-- ============================================
-- УДАЛЕНИЕ ОКЕАНА
-- ============================================
local oceanFolder = workspace:FindFirstChild("Map")
    and workspace.Map:FindFirstChild("AlwaysHereTweenedObjects")
    and workspace.Map.AlwaysHereTweenedObjects:FindFirstChild("Ocean")

local function destroyOceans(parent)
    for _, child in pairs(parent:GetChildren()) do
        if child.Name == "Ocean" then
            child:Destroy()
        elseif #child:GetChildren() > 0 then
            destroyOceans(child)
        end
    end
end

if oceanFolder then
    destroyOceans(oceanFolder)
end

-- ============================================
-- ПЕРЕКРАШИВАНИЕ ПАЛЛЕТ В ЧЕРНЫЙ
-- ============================================
local function applyNearBlackEffect(model)
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Color = Color3.fromRGB(15, 15, 15)
            part.Material = Enum.Material.Plastic
            part.Reflectance = 0
        end
    end
end

local ePressed = false
local ePressTime = 0

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.E then
        ePressed = true
        ePressTime = tick()
        task.wait(1)
        if ePressed then
            ePressed = false
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if ePressed and (tick() - ePressTime) < 1 then
            _G.mySpawn = true
            _G.mySpawnTime = tick()
            ePressed = false
            task.wait(0.5)
            _G.mySpawn = false
        end
    end
end)

workspace.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("Model") and descendant.Name == "PalletLightBrown" then
        task.wait(0.1)
        if _G.mySpawn and (tick() - _G.mySpawnTime) < 0.6 then
            applyNearBlackEffect(descendant)
        end
    end
end)

-- ============================================
-- ПЕРЕМЕННЫЕ
-- ============================================
local fovEnabled = false
local tpEnabled = false
local espEnabled = false
local thirdPersonEnabled = false
local antiGrabEnabled = false
local autoResetEnabled = false
local timeEnabled = false
local antiLagEnabled = false
local jerkOffActive = false

local normalFOV = 120
local boostedFOV = 120
local guiVisible = true
local currentPage = 1

local antiGrabConn = nil
local savedCFrame = nil
local antiKickResetConnection = nil
local thirdPersonConnection = nil
local jerkOffTrack = nil
local jerkOffLoop = nil

local autoGrabEnabled = false
local hasGrabbed = false
local grabbedPlayer = nil
local isWaitingForReset = false
local autoGrabConnection = nil

local espFolder = Instance.new("Folder")
espFolder.Name = "PANAMERA_ESP"
espFolder.Parent = game.CoreGui
local espElements = {}

-- ============================================
-- АНЧОРИК
-- ============================================
AnchoredObjects = AnchoredObjects or {}
SB_LineTransparencyValue = SB_LineTransparencyValue or Instance.new("NumberValue")
SB_SurfaceTransparencyValue = SB_SurfaceTransparencyValue or Instance.new("NumberValue")
SB_AnchoredColor3 = SB_AnchoredColor3 or Instance.new("Color3Value")
SB_AnchoredColor3Surface = SB_AnchoredColor3Surface or Instance.new("Color3Value")

SB_AnchoredColor3.Value = Color3.fromRGB(22, 2, 138)
SB_AnchoredColor3Surface.Value = Color3.fromRGB(38, 85, 172)
SB_LineTransparencyValue.Value = 0
SB_SurfaceTransparencyValue.Value = 0.56

local catSound = Instance.new("Sound")
catSound.SoundId = "rbxassetid://9126228625"
catSound.PlaybackSpeed = 1.25

local attachmentInstance = Instance.new("Attachment")
local particleEmitter = Instance.new("ParticleEmitter", attachmentInstance)
particleEmitter.LightInfluence = 1
particleEmitter.Lifetime = NumberRange.new(2, 3)
particleEmitter.Texture = "rbxassetid://15668608167"
particleEmitter.Transparency = NumberSequence.new(0, 1)
particleEmitter.Speed = NumberRange.new(6, 6)
particleEmitter.Size = NumberSequence.new(0, 1)
particleEmitter.SpreadAngle = Vector2.new(360, 360)
particleEmitter.Rate = 20
particleEmitter.Enabled = false
particleEmitter.Name = "particle"

local function playAnchorEffect(parentPart)
    local clonedAttachment = attachmentInstance:Clone()
    clonedAttachment.Parent = parentPart
    clonedAttachment.particle:Emit(25)
    local sound = catSound:Clone()
    sound.Parent = clonedAttachment
    sound:Play()
    debrisService:AddItem(clonedAttachment)
end

function ChangeSBstate(selectionBox, selectionBoxState)
    if typeof(selectionBox) == "Instance" and selectionBox:IsA("SelectionBox") then
        if selectionBoxState == "Anchored" then
            selectionBox.Color3 = SB_AnchoredColor3.Value
            selectionBox.SurfaceColor3 = SB_AnchoredColor3Surface.Value
        else
            selectionBox.Color3 = Color3.fromRGB(139, 0, 0)
            selectionBox.SurfaceColor3 = Color3.fromRGB(193, 0, 0)
        end
    end
end

function unAnchorObject(anchoredObject)
    if typeof(anchoredObject) == "Instance" and anchoredObject.Parent and 
       (anchoredObject.Parent:IsA("Model") or anchoredObject.Parent:IsA("Folder")) then
        local anchoredObjectParent = anchoredObject.Parent
        if anchoredObjectParent ~= workspaceService then
            anchoredObject = anchoredObjectParent
        end
        if AnchoredObjects[anchoredObject] then
            local anchoredObjectData = AnchoredObjects[anchoredObject]
            anchoredObjectData.BodyPosition.Parent = anchoredObject
            anchoredObjectData.BodyGyro.Parent = anchoredObject
            anchoredObjectData.PartAnchored = nil
            anchoredObjectData.SB.Visible = false
            for _, connection in pairs(anchoredObjectData.Connections or {}) do
                connection:Disconnect()
            end
            anchoredObject:SetAttribute("IsAnchored", nil)
            anchoredObject:SetAttribute("AnchorOwnership", nil)
            AnchoredObjects[anchoredObject] = nil
        end
    end
end

function setanchorObject(part)
    if typeof(part) == "Instance" and part.Parent and 
       (part.Parent:IsA("Model") or part.Parent:IsA("Folder")) then
        local parentModel = part.Parent
        if parentModel:IsA("Folder") or parentModel == workspaceService then
            parentModel = part
        end
        if parentModel:GetAttribute("IsAnchored") then
            unAnchorObject(part)
            return
        end
        local anchorPositionBody = parentModel:FindFirstChild("AnchorPositionBody") or 
                                   (part:FindFirstChild("AnchorPositionBody") or Instance.new("BodyPosition"))
        local anchorGyroBody = parentModel:FindFirstChild("AnchorGyroBody") or 
                               (part:FindFirstChild("AnchorGyroBody") or Instance.new("BodyGyro"))
        local objectStateSelectionBox = parentModel:FindFirstChild("ObjectState") or Instance.new("SelectionBox")
        local descendantConnections = {}
        local infiniteVector3 = Vector3.new(math.huge, math.huge, math.huge)
        local zeroVector = Vector3.new(0, 0, 0)
        local partPosition = part.Position
        
        anchorPositionBody.Name = "AnchorPositionBody"
        anchorPositionBody.Position = part.Position
        anchorPositionBody.Parent = part
        anchorPositionBody.P = 40000
        anchorPositionBody.D = 950
        
        anchorGyroBody.Name = "AnchorGyroBody"
        anchorGyroBody.Parent = part
        anchorGyroBody.CFrame = part.CFrame
        anchorGyroBody.D = 950
        anchorGyroBody.P = 40000
        
        objectStateSelectionBox.Name = "ObjectState"
        objectStateSelectionBox.LineThickness = 0.025
        objectStateSelectionBox.SurfaceTransparency = SB_SurfaceTransparencyValue.Value
        objectStateSelectionBox.Transparency = SB_LineTransparencyValue.Value
        objectStateSelectionBox.Visible = true
        objectStateSelectionBox.Parent = parentModel
        objectStateSelectionBox.Adornee = parentModel
        
        local function updateJointMaxForce()
            if parentModel:GetAttribute("IsAnchored") then
                anchorGyroBody.MaxTorque = infiniteVector3
                anchorPositionBody.MaxForce = infiniteVector3
                ChangeSBstate(objectStateSelectionBox, "Anchored")
            else
                anchorGyroBody.MaxTorque = zeroVector
                anchorPositionBody.MaxForce = zeroVector
            end
        end
        
        descendantConnections[1] = parentModel.DescendantAdded:Connect(function(descendant)
            if descendant.Name == "PartOwner" and descendant.Value == localPlayer.Name then
                updateJointMaxForce()
            end
        end)
        
        descendantConnections[#descendantConnections + 1] = SB_LineTransparencyValue.Changed:Connect(function(transparencyValue)
            objectStateSelectionBox.Transparency = transparencyValue
        end)
        descendantConnections[#descendantConnections + 1] = SB_SurfaceTransparencyValue.Changed:Connect(function(surfaceTransparencyValue)
            objectStateSelectionBox.SurfaceTransparency = surfaceTransparencyValue
        end)
        
        task.spawn(function()
            while anchorPositionBody.Parent do
                if parentModel:GetAttribute("IsAnchored") then
                    anchorGyroBody.MaxTorque = infiniteVector3
                    anchorPositionBody.MaxForce = infiniteVector3
                else
                    anchorGyroBody.MaxTorque = zeroVector
                    anchorPositionBody.MaxForce = zeroVector
                end
                anchorPositionBody.Position = partPosition + Vector3.new(0, 0.001, 0)
                task.wait()
                anchorPositionBody.Position = partPosition
            end
        end)
        
        AnchoredObjects[parentModel] = {
            BodyPosition = anchorPositionBody,
            BodyGyro = anchorGyroBody,
            PartAnchored = part,
            SB = objectStateSelectionBox,
            Connections = descendantConnections,
            Model = parentModel
        }
        
        playAnchorEffect(part)
        parentModel:SetAttribute("IsAnchored", true)
        updateJointMaxForce()
        print("Anchored!")
    end
end

function GetPlayerCharacter()
    if localPlayer.Character and 
       localPlayer.Character:FindFirstChild("HumanoidRootPart") and 
       localPlayer.Character:FindFirstChildOfClass("Humanoid") then
        return localPlayer.Character
    end
end

function anchorfunc()
    local grabPartsFolder = workspaceService:FindFirstChild("GrabParts")
    
    local function isGrabbablePart(part)
        if part and not (part:IsDescendantOf(workspaceService.Map) or part.Anchored) then
            return true
        end
    end
    
    if grabPartsFolder then
        local grabbedPart = grabPartsFolder:FindFirstChild("GrabPart")
        if grabbedPart then
            local weldConstraint = grabbedPart:FindFirstChild("WeldConstraint")
            if weldConstraint then
                local part1 = weldConstraint.Part1
                if isGrabbablePart(part1) then
                    setanchorObject(part1)
                end
            end
        end
    elseif GetPlayerCharacter() then
        local controllingCreature = _G.ControllingCreature or localPlayer.Character
        if controllingCreature then
            local cameraPartName = _G.ControllingCreature and "Head" or "CamPart"
            local camPart = controllingCreature:FindFirstChild(cameraPartName)
            if camPart then
                local ray = Ray.new(camPart.Position, localPlayer.Character.CamPart.CFrame.lookVector * 5000)
                local hitPart, _ = workspaceService:FindPartOnRayWithIgnoreList(ray, {controllingCreature})
                if hitPart and hitPart.Parent and hitPart.Parent:IsA("Model") and 
                   isGrabbablePart(hitPart) then
                    setanchorObject(hitPart)
                end
            end
        end
    end
end

ContextActionService:BindAction("AnchorH", function(actionName, inputState)
    if actionName == "AnchorH" and inputState == Enum.UserInputState.Begin then
        anchorfunc()
    end
end, false, Enum.KeyCode.H)

-- ============================================
-- ВСЕ ВИЗУАЛЫ (СТАНДАРТНЫЙ FF)
-- ============================================
local Visuals = {}

Visuals.DefaultLighting = {
    Brightness=Lighting.Brightness, ClockTime=Lighting.ClockTime,
    GlobalShadows=Lighting.GlobalShadows, OutdoorAmbient=Lighting.OutdoorAmbient,
    Ambient=Lighting.Ambient, FogStart=Lighting.FogStart, FogEnd=Lighting.FogEnd,
    FogColor=Lighting.FogColor, ExposureCompensation=Lighting.ExposureCompensation,
}
Visuals.DefaultSkySettings = {}
local defaultSky = Lighting:FindFirstChildOfClass("Sky")
if defaultSky then
    Visuals.DefaultSkySettings = {
        SkyboxBk=defaultSky.SkyboxBk, SkyboxDn=defaultSky.SkyboxDn,
        SkyboxFt=defaultSky.SkyboxFt, SkyboxLf=defaultSky.SkyboxLf,
        SkyboxRt=defaultSky.SkyboxRt, SkyboxUp=defaultSky.SkyboxUp,
    }
end

Visuals.HatEnabled=false; Visuals.HatTransparency=0.3
Visuals.HatColor=Color3.fromRGB(0,255,255); Visuals.HatParts={}
Visuals.TrailEnabled=false; Visuals.TrailGradient=false; Visuals.TrailLifetime=0.5
Visuals.TrailTransparencyStart=0
Visuals.TrailColorStatic=Color3.fromRGB(0,255,255)
Visuals.TrailGradient1=Color3.fromRGB(0,86,255); Visuals.TrailGradient2=Color3.fromRGB(255,0,0)
Visuals.TrailParts={}
Visuals.SkinTrailEnabled=false; Visuals.SkinTrailColor=Color3.fromRGB(255,0,0); Visuals.SkinTrailLife=0.5
Visuals.ForceFieldEnabled=false; Visuals.ForceFieldColor=Color3.fromRGB(128,128,128)
Visuals.ForceFieldTransparency=0
Visuals.OriginalColors={}
Visuals.WorldTimeEnabled=false; Visuals.WorldTimeValue=12; Visuals.FullBrightEnabled=false
Visuals.NebulaEnabled=false; Visuals.NebulaThemeColor=Color3.fromRGB(173,216,230)
Visuals.CurrentSkybox="HD"; Visuals.CustomSkyEnabled=false
Visuals.ScreenEnabled=false; Visuals.ScreenIntensity=0; Visuals.ScreenConnection=nil
Visuals.AnimeImageEnabled=false; Visuals.AnimeImageGui=nil
Visuals.FireAuraEnabled=false
Visuals.FireAuraObjects={}

Visuals.SkyboxAssets = {
    ["Black Storm"]={Bk="rbxassetid://15502511288",Dn="rbxassetid://15502508460",Ft="rbxassetid://15502510289",Lf="rbxassetid://15502507918",Rt="rbxassetid://15502509398",Up="rbxassetid://15502511911"},
    HD={Bk="http://www.roblox.com/asset/?id=16553658937",Dn="http://www.roblox.com/asset/?id=16553660713",Ft="http://www.roblox.com/asset/?id=16553662144",Lf="http://www.roblox.com/asset/?id=16553664042",Rt="http://www.roblox.com/asset/?id=16553665766",Up="http://www.roblox.com/asset/?id=16553667750"},
    Snow={Bk="http://www.roblox.com/asset/?id=155657655",Dn="http://www.roblox.com/asset/?id=155674246",Ft="http://www.roblox.com/asset/?id=155657609",Lf="http://www.roblox.com/asset/?id=155657671",Rt="http://www.roblox.com/asset/?id=155657619",Up="http://www.roblox.com/asset/?id=155674931"},
    ["Blue Space"]={Bk="rbxassetid://15536110634",Dn="rbxassetid://15536112543",Ft="rbxassetid://15536116141",Lf="rbxassetid://15536114370",Rt="rbxassetid://15536118762",Up="rbxassetid://15536117282"},
    Realistic={Bk="rbxassetid://653719502",Dn="rbxassetid://653718790",Ft="rbxassetid://653719067",Lf="rbxassetid://653719190",Rt="rbxassetid://653718931",Up="rbxassetid://653719321"},
    Stormy={Bk="http://www.roblox.com/asset/?id=18703245834",Dn="http://www.roblox.com/asset/?id=18703243349",Ft="http://www.roblox.com/asset/?id=18703240532",Lf="http://www.roblox.com/asset/?id=18703237556",Rt="http://www.roblox.com/asset/?id=18703235430",Up="http://www.roblox.com/asset/?id=18703232671"},
    Pink={Bk="rbxassetid://12216109205",Dn="rbxassetid://12216109875",Ft="rbxassetid://12216109489",Lf="rbxassetid://12216110170",Rt="rbxassetid://12216110471",Up="rbxassetid://12216108877"},
    Sunset={Bk="rbxassetid://600830446",Dn="rbxassetid://600831635",Ft="rbxassetid://600832720",Lf="rbxassetid://600886090",Rt="rbxassetid://600833862",Up="rbxassetid://600835177"},
    Arctic={Bk="http://www.roblox.com/asset/?id=225469390",Dn="http://www.roblox.com/asset/?id=225469395",Ft="http://www.roblox.com/asset/?id=225469403",Lf="http://www.roblox.com/asset/?id=225469450",Rt="http://www.roblox.com/asset/?id=225469471",Up="http://www.roblox.com/asset/?id=225469481"},
    Space={Bk="http://www.roblox.com/asset/?id=166509999",Dn="http://www.roblox.com/asset/?id=166510057",Ft="http://www.roblox.com/asset/?id=166510116",Lf="http://www.roblox.com/asset/?id=166510092",Rt="http://www.roblox.com/asset/?id=166510131",Up="http://www.roblox.com/asset/?id=166510114"},
    ["Roblox Default"]={Bk="rbxasset://textures/sky/sky512_bk.tex",Dn="rbxasset://textures/sky/sky512_dn.tex",Ft="rbxasset://textures/sky/sky512_ft.tex",Lf="rbxasset://textures/sky/sky512_lf.tex",Rt="rbxasset://textures/sky/sky512_rt.tex",Up="rbxasset://textures/sky/sky512_up.tex"},
}

-- HAT
function Visuals.removeHat(c) local h=Visuals.HatParts[c]; if h then h:Destroy(); Visuals.HatParts[c]=nil end end
function Visuals.addHat(c) task.wait(0.1); local head=c and c:FindFirstChild("Head"); if not head then return end; Visuals.removeHat(c); local hat=Instance.new("Part"); hat.Name="Hat"; hat.Transparency=Visuals.HatTransparency; hat.Color=Visuals.HatColor; hat.Material=Enum.Material.Neon; hat.CanCollide=false; hat.CanTouch=false; hat.CanQuery=false; hat.Massless=true; local m=Instance.new("SpecialMesh"); m.MeshId="rbxassetid://1033714"; m.Scale=Vector3.new(2.4,1.6,2.4); m.Parent=hat; local w=Instance.new("WeldConstraint"); w.Part0=head; w.Part1=hat; w.Parent=hat; hat.CFrame=head.CFrame*CFrame.new(0,1.1,0); hat.Parent=c; Visuals.HatParts[c]=hat end
function Visuals.updateHats() 
    for c,h in pairs(Visuals.HatParts) do 
        if h and h.Parent and c==player.Character then 
            h.Transparency=Visuals.HatTransparency
            h.Color = Color3.fromHSV((tick()%5)/5,1,1)
        end 
    end 
end

-- TRAIL
function Visuals.removeTrail(c) if Visuals.TrailParts[c] then Visuals.TrailParts[c]:Destroy(); Visuals.TrailParts[c]=nil end; local t=c and c:FindFirstChild("HumanoidRootPart"); if t then local a0=t:FindFirstChild("TrailAttach0"); local a1=t:FindFirstChild("TrailAttach1"); if a0 then a0:Destroy() end; if a1 then a1:Destroy() end end end
function Visuals.addTrail(c) local t=c and c:FindFirstChild("HumanoidRootPart"); if not t then return end; Visuals.removeTrail(c); local a0=Instance.new("Attachment"); a0.Name="TrailAttach0"; a0.Position=Vector3.new(0,2,0); a0.Parent=t; local a1=Instance.new("Attachment"); a1.Name="TrailAttach1"; a1.Position=Vector3.new(0,-2,0); a1.Parent=t; local tr=Instance.new("Trail"); tr.Attachment0=a0; tr.Attachment1=a1; tr.Lifetime=Visuals.TrailLifetime; tr.LightEmission=0.2; tr.Enabled=true; tr.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,Visuals.TrailTransparencyStart),NumberSequenceKeypoint.new(1,1)}); tr.Color=ColorSequence.new(Color3.fromHSV(0,1,1)); tr.Parent=c; Visuals.TrailParts[c]=tr end
function Visuals.updateTrails() 
    for c,tr in pairs(Visuals.TrailParts) do 
        if tr and tr.Parent and c==player.Character then 
            tr.Lifetime=Visuals.TrailLifetime
            tr.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,Visuals.TrailTransparencyStart),NumberSequenceKeypoint.new(1,1)})
            local hue = (tick()%5)/5
            tr.Color=ColorSequence.new(Color3.fromHSV(hue,1,1))
        end 
    end 
end

function Visuals.toggleSkinTrail(en) local c=player.Character; if not c then return end; local hrp=c:FindFirstChild("HumanoidRootPart"); if not hrp then return end; for _,p in ipairs(c:GetChildren()) do if p:IsA("BasePart") and p~=hrp then if en then if not p:FindFirstChild("SkinTrail") then local tr=Instance.new("Trail"); tr.Name="SkinTrail"; tr.Texture="rbxassetid://1390780157"; tr.Color=ColorSequence.new(Visuals.SkinTrailColor); tr.Lifetime=Visuals.SkinTrailLife; tr.Parent=p; local p1=Instance.new("Attachment"); p1.Name="SkinPointer1"; p1.Parent=p; local p2=Instance.new("Attachment"); p2.Name="SkinPointer2"; p2.Parent=hrp; tr.Attachment0=p1; tr.Attachment1=p2 end else local tr=p:FindFirstChild("SkinTrail"); local p1=p:FindFirstChild("SkinPointer1"); if tr then tr:Destroy() end; if p1 then p1:Destroy() end end end end; if not en then local p2=hrp:FindFirstChild("SkinPointer2"); if p2 then p2:Destroy() end end end

function Visuals.updateSkinTrail()
    local c = player.Character
    if not c then return end
    for _, d in ipairs(c:GetDescendants()) do
        if d:IsA("Trail") and d.Name == "SkinTrail" then
            d.Color = ColorSequence.new(Visuals.SkinTrailColor)
            d.Lifetime = Visuals.SkinTrailLife
        end
    end
end

-- FORCEFIELD
function Visuals.saveOriginalColors(c) Visuals.OriginalColors[c]={} for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.Name~="Hat" then Visuals.OriginalColors[c][p]={Color=p.Color,Material=p.Material} end end end
function Visuals.applyForceField(c) Visuals.saveOriginalColors(c); for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.Name~="Hat" then p.Color=Visuals.ForceFieldColor; p.Material=Enum.Material.ForceField end end end
function Visuals.removeForceField(c) local orig=Visuals.OriginalColors[c]; if not orig then return end; for p,d in pairs(orig) do if p and p.Parent and p:IsA("BasePart") then p.Color=d.Color; p.Material=d.Material end end; Visuals.OriginalColors[c]=nil end
function Visuals.updateForceField() if not(player.Character and Visuals.ForceFieldEnabled) then return end; for _,p in ipairs(player.Character:GetDescendants()) do if p:IsA("BasePart") and p.Name~="Hat" and p.Material==Enum.Material.ForceField then p.Color=Visuals.ForceFieldColor end end end

function Visuals.applySkybox(n) local s=Visuals.SkyboxAssets[n]; if not s then return end; local sky=Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky",Lighting); sky.Name="Sky"; sky.SkyboxBk=s.Bk; sky.SkyboxDn=s.Dn; sky.SkyboxFt=s.Ft; sky.SkyboxLf=s.Lf; sky.SkyboxRt=s.Rt; sky.SkyboxUp=s.Up end
function Visuals.restoreDefaultSky() local sky=Lighting:FindFirstChildOfClass("Sky"); if sky and Visuals.DefaultSkySettings.SkyboxBk then sky.SkyboxBk=Visuals.DefaultSkySettings.SkyboxBk; sky.SkyboxDn=Visuals.DefaultSkySettings.SkyboxDn; sky.SkyboxFt=Visuals.DefaultSkySettings.SkyboxFt; sky.SkyboxLf=Visuals.DefaultSkySettings.SkyboxLf; sky.SkyboxRt=Visuals.DefaultSkySettings.SkyboxRt; sky.SkyboxUp=Visuals.DefaultSkySettings.SkyboxUp elseif sky then sky:Destroy() end end
function Visuals.setNebulaEnabled(en) Visuals.NebulaEnabled=en; if en then local bl=Lighting:FindFirstChild("NebulaBloom") or Instance.new("BloomEffect"); bl.Name="NebulaBloom"; bl.Intensity=0.7; bl.Size=24; bl.Threshold=1; bl.Parent=Lighting; local cc=Lighting:FindFirstChild("NebulaColorCorrection") or Instance.new("ColorCorrectionEffect"); cc.Name="NebulaColorCorrection"; cc.Saturation=0.5; cc.Contrast=0.2; cc.TintColor=Visuals.NebulaThemeColor; cc.Parent=Lighting; local atm=Lighting:FindFirstChild("NebulaAtmosphere") or Instance.new("Atmosphere"); atm.Name="NebulaAtmosphere"; atm.Density=0.4; atm.Offset=0.25; atm.Glare=1; atm.Haze=2; atm.Color=Visuals.NebulaThemeColor; atm.Decay=Color3.fromRGB(173,216,230); atm.Parent=Lighting; Lighting.Ambient=Visuals.NebulaThemeColor; Lighting.OutdoorAmbient=Visuals.NebulaThemeColor; Lighting.FogStart=100; Lighting.FogEnd=500; Lighting.FogColor=Visuals.NebulaThemeColor else for _,nm in ipairs({"NebulaBloom","NebulaColorCorrection","NebulaAtmosphere"}) do local o=Lighting:FindFirstChild(nm); if o then o:Destroy() end end; Lighting.Ambient=Visuals.DefaultLighting.Ambient; Lighting.OutdoorAmbient=Visuals.DefaultLighting.OutdoorAmbient; Lighting.FogStart=Visuals.DefaultLighting.FogStart; Lighting.FogEnd=Visuals.DefaultLighting.FogEnd; Lighting.FogColor=Visuals.DefaultLighting.FogColor end end
function Visuals.setFullBrightEnabled(en) Visuals.FullBrightEnabled=en; if not en then Lighting.Brightness=Visuals.DefaultLighting.Brightness; Lighting.GlobalShadows=Visuals.DefaultLighting.GlobalShadows; Lighting.OutdoorAmbient=Visuals.DefaultLighting.OutdoorAmbient; Lighting.ExposureCompensation=Visuals.DefaultLighting.ExposureCompensation end end
function Visuals.setScreenEnabled(en) Visuals.ScreenEnabled=en; if en then if Visuals.ScreenConnection then Visuals.ScreenConnection:Disconnect() end; Visuals.ScreenConnection=RunService.RenderStepped:Connect(function() local cam=workspace.CurrentCamera; if cam then cam.CFrame=cam.CFrame*CFrame.new(0,0,0,1,0,0,0,0.65+Visuals.ScreenIntensity,0,0,0,1) end end) elseif Visuals.ScreenConnection then Visuals.ScreenConnection:Disconnect(); Visuals.ScreenConnection=nil end end
function Visuals.toggleAnimeImage(en) Visuals.AnimeImageEnabled=en; if en then if Visuals.AnimeImageGui then Visuals.AnimeImageGui:Destroy() end; local g=Instance.new("ScreenGui"); g.Name="AnimeImageGui"; g.ResetOnSpawn=false; g.Parent=player:WaitForChild("PlayerGui"); local img=Instance.new("ImageLabel"); img.Name="AnimeImage"; img.Image="http://www.roblox.com/asset/?id=117783035423570"; img.Size=UDim2.new(0,350,0,400); img.Position=UDim2.new(1,-25,0,10); img.AnchorPoint=Vector2.new(1,0); img.BackgroundTransparency=1; img.Parent=g; Visuals.AnimeImageGui=g elseif Visuals.AnimeImageGui then Visuals.AnimeImageGui:Destroy(); Visuals.AnimeImageGui=nil end end

-- FIRE AURA
function Visuals.enableFireAura(c)
    Visuals.disableFireAura()
    if not c then return end
    local parts = {"HumanoidRootPart","Head","Left Arm","Right Arm","Left Leg","Right Leg"}
    for _, name in ipairs(parts) do
        local p = c:FindFirstChild(name)
        if p then
            local fire = Instance.new("Fire")
            fire.Size = 4
            fire.Heat = 6
            fire.Color = Color3.fromRGB(255, 80, 0)
            fire.SecondaryColor = Color3.fromRGB(255, 200, 0)
            fire.Parent = p
            table.insert(Visuals.FireAuraObjects, fire)
        end
    end
end

function Visuals.disableFireAura()
    for _, o in ipairs(Visuals.FireAuraObjects) do
        if o and o.Parent then o:Destroy() end
    end
    Visuals.FireAuraObjects = {}
end

function vReapply(c) 
    task.wait(1) 
    if Visuals.HatEnabled then Visuals.addHat(c) end
    if Visuals.TrailEnabled then Visuals.addTrail(c) end
    if Visuals.ForceFieldEnabled then Visuals.applyForceField(c) end
    if Visuals.SkinTrailEnabled then Visuals.toggleSkinTrail(true) end
    if Visuals.AnimeImageEnabled then Visuals.toggleAnimeImage(true) end
    if Visuals.FireAuraEnabled then Visuals.enableFireAura(c) end
end

player.CharacterAdded:Connect(vReapply)
if player.Character then task.defer(function() vReapply(player.Character) end) end

RunService.Heartbeat:Connect(function()
    if Visuals.HatEnabled then Visuals.updateHats() end
    if Visuals.TrailEnabled then Visuals.updateTrails() end
    if Visuals.ForceFieldEnabled then Visuals.updateForceField() end
    if Visuals.WorldTimeEnabled then Lighting.ClockTime=Visuals.WorldTimeValue end
    if Visuals.FullBrightEnabled then Lighting.Brightness=3; Lighting.GlobalShadows=false; Lighting.OutdoorAmbient=Color3.new(1,1,1); Lighting.ExposureCompensation=0.3 end
end)

-- ============================================
-- ГУИ
-- ============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PANAMERA_GUI"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BackgroundTransparency = 0.85
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.Size = UDim2.new(0, 300, 0, 470)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true

local bg = Instance.new("ImageLabel")
bg.Parent = mainFrame
bg.BackgroundTransparency = 1
bg.Size = UDim2.new(1, 0, 1, 0)
bg.Image = "rbxassetid://17297011003"
bg.ScaleType = Enum.ScaleType.Crop
bg.ZIndex = 0

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 1.5
stroke.Transparency = 0.3
stroke.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Parent = mainFrame
title.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
title.BackgroundTransparency = 0.3
title.Size = UDim2.new(1, 0, 0, 30)
title.Font = Enum.Font.GothamBold
title.Text = "PANAMERA"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.ZIndex = 1

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = title

-- ============================================
-- ТАБЫ
-- ============================================
local tabsFrame = Instance.new("Frame")
tabsFrame.Parent = mainFrame
tabsFrame.BackgroundTransparency = 1
tabsFrame.Position = UDim2.new(0, 0, 0, 30)
tabsFrame.Size = UDim2.new(1, 0, 0, 30)
tabsFrame.ZIndex = 1

local function createTabBtn(name, pos, color)
    local btn = Instance.new("TextButton")
    btn.Parent = tabsFrame
    btn.BackgroundColor3 = color or Color3.fromRGB(80, 0, 0)
    btn.BackgroundTransparency = 0.2
    btn.Position = pos
    btn.Size = UDim2.new(0.33, -5, 0, 25)
    btn.Font = Enum.Font.GothamBold
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.ZIndex = 2
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    return btn
end

local tab1 = createTabBtn("MAIN", UDim2.new(0, 5, 0, 5), Color3.fromRGB(150, 0, 0))
local tab2 = createTabBtn("DEFENSE", UDim2.new(0.33, 2.5, 0, 5))
local tab3 = createTabBtn("VISUALS", UDim2.new(0.67, 2.5, 0, 5))

-- ============================================
-- СТРАНИЦЫ
-- ============================================
local page1 = Instance.new("Frame")
page1.Parent = mainFrame
page1.BackgroundTransparency = 1
page1.Position = UDim2.new(0, 0, 0, 65)
page1.Size = UDim2.new(1, 0, 1, -65)
page1.Visible = true
page1.ZIndex = 1

local page2 = Instance.new("Frame")
page2.Parent = mainFrame
page2.BackgroundTransparency = 1
page2.Position = UDim2.new(0, 0, 0, 65)
page2.Size = UDim2.new(1, 0, 1, -65)
page2.Visible = false
page2.ZIndex = 1

local page3 = Instance.new("Frame")
page3.Parent = mainFrame
page3.BackgroundTransparency = 1
page3.Position = UDim2.new(0, 0, 0, 65)
page3.Size = UDim2.new(1, 0, 1, -65)
page3.Visible = false
page3.ZIndex = 1

local function switchTab(num)
    currentPage = num
    page1.Visible = num == 1
    page2.Visible = num == 2
    page3.Visible = num == 3
    tab1.BackgroundColor3 = num == 1 and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(80, 0, 0)
    tab2.BackgroundColor3 = num == 2 and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(80, 0, 0)
    tab3.BackgroundColor3 = num == 3 and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(80, 0, 0)
end

tab1.MouseButton1Click:Connect(function() switchTab(1) end)
tab2.MouseButton1Click:Connect(function() switchTab(2) end)
tab3.MouseButton1Click:Connect(function() switchTab(3) end)

-- ============================================
-- СОЗДАНИЕ ЭЛЕМЕНТОВ МЕНЮ
-- ============================================
local function createItem(parent, name, y)
    local ind = Instance.new("Frame")
    ind.Parent = parent
    ind.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    ind.Position = UDim2.new(0, 15, 0, y)
    ind.Size = UDim2.new(0, 16, 0, 16)
    ind.ZIndex = 2
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = ind
    
    local status = Instance.new("TextLabel")
    status.Parent = parent
    status.BackgroundTransparency = 1
    status.Position = UDim2.new(0, 40, 0, y)
    status.Size = UDim2.new(0, 120, 0, 18)
    status.Font = Enum.Font.Gotham
    status.Text = name .. ": OFF"
    status.TextColor3 = Color3.fromRGB(255, 0, 0)
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.TextSize = 11
    status.ZIndex = 2
    
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    btn.BackgroundTransparency = 0.1
    btn.Position = UDim2.new(0, 165, 0, y - 4)
    btn.Size = UDim2.new(0, 105, 0, 24)
    btn.Font = Enum.Font.Gotham
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 0, 0)
    btn.TextSize = 11
    btn.ZIndex = 2
    local c2 = Instance.new("UICorner")
    c2.CornerRadius = UDim.new(0, 5)
    c2.Parent = btn
    
    return ind, status, btn
end

-- ============================================
-- MAIN TAB
-- ============================================
local fovInd, fovStatus, fovBtn = createItem(page1, "FOV", 5)
local tpInd, tpStatus, tpBtn = createItem(page1, "TP", 35)
local espInd, espStatus, espBtn = createItem(page1, "ESP", 65)
local ragdollInd, ragdollStatus, ragdollBtn = createItem(page1, "Ragdoll", 95)
local thirdInd, thirdStatus, thirdBtn = createItem(page1, "3rd Person", 125)
local timeInd, timeStatus, timeBtn = createItem(page1, "Time", 155)

-- ВРЕМЯ
local timeFrame = Instance.new("Frame")
timeFrame.Parent = page1
timeFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
timeFrame.BackgroundTransparency = 0.5
timeFrame.Position = UDim2.new(0, 10, 0, 180)
timeFrame.Size = UDim2.new(0, 265, 0, 110)
timeFrame.Visible = false
timeFrame.ClipsDescendants = true
timeFrame.ZIndex = 2
local tc = Instance.new("UICorner")
tc.CornerRadius = UDim.new(0, 8)
tc.Parent = timeFrame

local timeDisplay = Instance.new("TextLabel")
timeDisplay.Parent = timeFrame
timeDisplay.BackgroundTransparency = 1
timeDisplay.Position = UDim2.new(0, 10, 0, 2)
timeDisplay.Size = UDim2.new(1, -20, 0, 24)
timeDisplay.Font = Enum.Font.GothamBold
timeDisplay.Text = "14:30"
timeDisplay.TextColor3 = Color3.fromRGB(255, 0, 0)
timeDisplay.TextSize = 18
timeDisplay.ZIndex = 3

local currentHour = 14
local currentMinute = 30

local function setTime(h, m)
    Lighting.TimeOfDay = string.format("%02d:%02d:00", h, m)
    if Lighting:FindFirstChild("ClockTime") then
        Lighting.ClockTime = (h * 3600 + m * 60) / 3600
    end
    if h >= 6 and h < 18 then
        Lighting.Brightness = 2
        Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
    else
        Lighting.Brightness = 0.5
        Lighting.OutdoorAmbient = Color3.fromRGB(30, 30, 60)
    end
end

-- ЧАС
local hourLabel = Instance.new("TextLabel")
hourLabel.Parent = timeFrame
hourLabel.BackgroundTransparency = 1
hourLabel.Position = UDim2.new(0, 10, 0, 30)
hourLabel.Size = UDim2.new(0, 40, 0, 14)
hourLabel.Font = Enum.Font.GothamBold
hourLabel.Text = "ЧАС"
hourLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
hourLabel.TextSize = 10
hourLabel.ZIndex = 3

local hourSlider = Instance.new("Frame")
hourSlider.Parent = timeFrame
hourSlider.Position = UDim2.new(0, 50, 0, 33)
hourSlider.Size = UDim2.new(0, 195, 0, 5)
hourSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
hourSlider.ZIndex = 3
local hc = Instance.new("UICorner")
hc.CornerRadius = UDim.new(0, 2.5)
hc.Parent = hourSlider

local hourFill = Instance.new("Frame")
hourFill.Parent = hourSlider
hourFill.Size = UDim2.new(0.58, 0, 1, 0)
hourFill.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
hourFill.ZIndex = 4
local hfc = Instance.new("UICorner")
hfc.CornerRadius = UDim.new(0, 2.5)
hfc.Parent = hourFill

local hourBtn = Instance.new("TextButton")
hourBtn.Parent = hourFill
hourBtn.Size = UDim2.new(0, 12, 0, 12)
hourBtn.Position = UDim2.new(1, -6, 0, -3.5)
hourBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
hourBtn.Text = ""
hourBtn.BorderSizePixel = 0
hourBtn.ZIndex = 5
local hbc = Instance.new("UICorner")
hbc.CornerRadius = UDim.new(0, 6)
hbc.Parent = hourBtn

-- МИНУТА
local minuteLabel = Instance.new("TextLabel")
minuteLabel.Parent = timeFrame
minuteLabel.BackgroundTransparency = 1
minuteLabel.Position = UDim2.new(0, 10, 0, 55)
minuteLabel.Size = UDim2.new(0, 40, 0, 14)
minuteLabel.Font = Enum.Font.GothamBold
minuteLabel.Text = "МИН"
minuteLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
minuteLabel.TextSize = 10
minuteLabel.ZIndex = 3

local minuteSlider = Instance.new("Frame")
minuteSlider.Parent = timeFrame
minuteSlider.Position = UDim2.new(0, 50, 0, 58)
minuteSlider.Size = UDim2.new(0, 195, 0, 5)
minuteSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
minuteSlider.ZIndex = 3
local mc = Instance.new("UICorner")
mc.CornerRadius = UDim.new(0, 2.5)
mc.Parent = minuteSlider

local minuteFill = Instance.new("Frame")
minuteFill.Parent = minuteSlider
minuteFill.Size = UDim2.new(0.5, 0, 1, 0)
minuteFill.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
minuteFill.ZIndex = 4
local mfc = Instance.new("UICorner")
mfc.CornerRadius = UDim.new(0, 2.5)
mfc.Parent = minuteFill

local minuteBtn = Instance.new("TextButton")
minuteBtn.Parent = minuteFill
minuteBtn.Size = UDim2.new(0, 12, 0, 12)
minuteBtn.Position = UDim2.new(1, -6, 0, -3.5)
minuteBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
minuteBtn.Text = ""
minuteBtn.BorderSizePixel = 0
minuteBtn.ZIndex = 5
local mbc = Instance.new("UICorner")
mbc.CornerRadius = UDim.new(0, 6)
mbc.Parent = minuteBtn

local applyBtn = Instance.new("TextButton")
applyBtn.Parent = timeFrame
applyBtn.Position = UDim2.new(0, 50, 0, 78)
applyBtn.Size = UDim2.new(0, 195, 0, 22)
applyBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
applyBtn.BackgroundTransparency = 0.2
applyBtn.Text = "ПРИМЕНИТЬ"
applyBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
applyBtn.Font = Enum.Font.GothamBold
applyBtn.TextSize = 12
applyBtn.BorderSizePixel = 0
applyBtn.ZIndex = 3
local ac = Instance.new("UICorner")
ac.CornerRadius = UDim.new(0, 5)
ac.Parent = applyBtn

local function setupSlider(fill, btn, max, onChange)
    local dragging = false
    btn.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = input.Position.X
            local sPos = fill.Parent.AbsolutePosition.X
            local sW = fill.Parent.AbsoluteSize.X
            if sW > 0 then
                local pct = math.clamp((pos - sPos) / sW, 0, 1)
                local val = math.floor(pct * max)
                if max == 24 then val = math.clamp(val, 0, 23) end
                if max == 60 then val = math.clamp(val, 0, 59) end
                onChange(val)
            end
        end
    end)
end

setupSlider(hourFill, hourBtn, 24, function(v)
    currentHour = v
    timeDisplay.Text = string.format("%02d:%02d", currentHour, currentMinute)
    hourFill.Size = UDim2.new(v / 24, 0, 1, 0)
end)

setupSlider(minuteFill, minuteBtn, 60, function(v)
    currentMinute = v
    timeDisplay.Text = string.format("%02d:%02d", currentHour, currentMinute)
    minuteFill.Size = UDim2.new(v / 60, 0, 1, 0)
end)

applyBtn.MouseButton1Click:Connect(function()
    setTime(currentHour, currentMinute)
    applyBtn.BackgroundColor3 = Color3.fromRGB(70, 200, 70)
    task.wait(0.2)
    applyBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
end)

local function toggleTime()
    timeEnabled = not timeEnabled
    timeFrame.Visible = timeEnabled
    if timeEnabled then
        timeInd.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        timeStatus.Text = "Time: ON"
        timeBtn.Text = "Hide"
    else
        timeInd.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        timeStatus.Text = "Time: OFF"
        timeBtn.Text = "Time"
    end
end

timeBtn.MouseButton1Click:Connect(toggleTime)

-- ============================================
-- SCREEN STRETCH
-- ============================================
local stretchIntensity = 100
local stretchConnection = nil

local stretchTitle = Instance.new("TextLabel")
stretchTitle.Parent = page1
stretchTitle.BackgroundTransparency = 1
stretchTitle.Position = UDim2.new(0, 10, 0, 295)
stretchTitle.Size = UDim2.new(0, 200, 0, 20)
stretchTitle.Font = Enum.Font.GothamBold
stretchTitle.Text = "Screen Stretch"
stretchTitle.TextColor3 = Color3.fromRGB(255, 0, 0)
stretchTitle.TextXAlignment = Enum.TextXAlignment.Left
stretchTitle.TextSize = 14
stretchTitle.ZIndex = 2

local stretchValueLabel = Instance.new("TextLabel")
stretchValueLabel.Parent = page1
stretchValueLabel.BackgroundTransparency = 1
stretchValueLabel.Position = UDim2.new(1, -60, 0, 295)
stretchValueLabel.Size = UDim2.new(0, 50, 0, 20)
stretchValueLabel.Font = Enum.Font.GothamBold
stretchValueLabel.Text = "100%"
stretchValueLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
stretchValueLabel.TextXAlignment = Enum.TextXAlignment.Right
stretchValueLabel.TextSize = 14
stretchValueLabel.ZIndex = 2

local stretchSlider = Instance.new("Frame")
stretchSlider.Parent = page1
stretchSlider.Position = UDim2.new(0, 10, 0, 319)
stretchSlider.Size = UDim2.new(0, 275, 0, 5)
stretchSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
stretchSlider.ZIndex = 2

local stretchSliderCorner = Instance.new("UICorner")
stretchSliderCorner.CornerRadius = UDim.new(0, 2.5)
stretchSliderCorner.Parent = stretchSlider

local stretchFill = Instance.new("Frame")
stretchFill.Parent = stretchSlider
stretchFill.Size = UDim2.new(1, 0, 1, 0)
stretchFill.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
stretchFill.ZIndex = 3

local stretchFillCorner = Instance.new("UICorner")
stretchFillCorner.CornerRadius = UDim.new(0, 2.5)
stretchFillCorner.Parent = stretchFill

local stretchSliderButton = Instance.new("TextButton")
stretchSliderButton.Parent = stretchFill
stretchSliderButton.Size = UDim2.new(0, 14, 0, 14)
stretchSliderButton.Position = UDim2.new(1, -7, 0, -4.5)
stretchSliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
stretchSliderButton.Text = ""
stretchSliderButton.BorderSizePixel = 0
stretchSliderButton.ZIndex = 4

local stretchSliderButtonCorner = Instance.new("UICorner")
stretchSliderButtonCorner.CornerRadius = UDim.new(0, 7)
stretchSliderButtonCorner.Parent = stretchSliderButton

local function updateStretchUI()
    stretchValueLabel.Text = math.floor(stretchIntensity) .. "%"
    local percent = (stretchIntensity - 5) / 95
    stretchFill.Size = UDim2.new(percent, 0, 1, 0)
end

local function applyStretch(value)
    local newValue = math.floor(value)
    if newValue < 5 then newValue = 5 end
    if newValue > 100 then newValue = 100 end
    stretchIntensity = newValue
    updateStretchUI()
    
    if stretchConnection then
        stretchConnection:Disconnect()
        stretchConnection = nil
    end
    
    local stretch = 0.5 + (stretchIntensity / 100) * 0.5
    stretchConnection = RunService.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        if cam then
            cam.CFrame = cam.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, stretch, 0, 0, 0, 1)
        end
    end)
end

local stretchDragging = false

stretchSliderButton.MouseButton1Down:Connect(function()
    stretchDragging = true
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        stretchDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if stretchDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = input.Position.X
        local sliderPos = stretchSlider.AbsolutePosition.X
        local sliderWidth = stretchSlider.AbsoluteSize.X
        if sliderWidth > 0 then
            local percent = math.clamp((mousePos - sliderPos) / sliderWidth, 0, 1)
            local value = 5 + percent * 95
            applyStretch(value)
        end
    end
end)

stretchSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = input.Position.X
        local sliderPos = stretchSlider.AbsolutePosition.X
        local sliderWidth = stretchSlider.AbsoluteSize.X
        if sliderWidth > 0 then
            local percent = math.clamp((mousePos - sliderPos) / sliderWidth, 0, 1)
            local value = 5 + percent * 95
            applyStretch(value)
        end
    end
end)

local function onCharacterAdded()
    task.wait(0.5)
    applyStretch(stretchIntensity)
end

player.CharacterAdded:Connect(onCharacterAdded)

applyStretch(100)

local hintLabel1 = Instance.new("TextLabel")
hintLabel1.Parent = page1
hintLabel1.BackgroundTransparency = 1
hintLabel1.Position = UDim2.new(0, 10, 0, 335)
hintLabel1.Size = UDim2.new(0, 280, 0, 75)
hintLabel1.Font = Enum.Font.GothamBold
hintLabel1.Text = "[R] FOV  •  [Z] TP  •  [C] Ragdoll\n[V] 3rd Person  •  [L] Hide GUI\n[Tab] Switch Page  •  [O] Zoom"
hintLabel1.TextColor3 = Color3.fromRGB(255, 0, 0)
hintLabel1.TextSize = 12
hintLabel1.TextWrapped = true
hintLabel1.ZIndex = 2

-- ============================================
-- DEFENSE TAB (Page 2)
-- ============================================
local antiGrabInd, antiGrabStatus, antiGrabBtn = createItem(page2, "Anti Grab", 5)
local autoResetInd, autoResetStatus, autoResetBtn = createItem(page2, "Auto Reset", 35)
local jerkOffInd, jerkOffStatus, jerkOffBtn = createItem(page2, "Jerk Off", 65)
local antiLagInd, antiLagStatus, antiLagBtn = createItem(page2, "Anti Lag", 95)

local hintLabel2 = Instance.new("TextLabel")
hintLabel2.Parent = page2
hintLabel2.BackgroundTransparency = 1
hintLabel2.Position = UDim2.new(0, 10, 0, 125)
hintLabel2.Size = UDim2.new(0, 280, 0, 130)
hintLabel2.Font = Enum.Font.GothamBold
hintLabel2.Text = "Anti Grab - prevents players from\ngrabbing you\n\nAuto Reset - auto respawn when\nkicked for flying\n\nJerk Off - anim\n\nAnti Lag - disables line creation"
hintLabel2.TextColor3 = Color3.fromRGB(255, 0, 0)
hintLabel2.TextSize = 12
hintLabel2.TextWrapped = true
hintLabel2.ZIndex = 2

-- ============================================
-- VISUALS TAB (Page 3)
-- ============================================
local function createVisItem(name, y)
    local ind = Instance.new("Frame")
    ind.Parent = page3
    ind.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    ind.Position = UDim2.new(0, 15, 0, y)
    ind.Size = UDim2.new(0, 16, 0, 16)
    ind.ZIndex = 2
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = ind
    
    local status = Instance.new("TextLabel")
    status.Parent = page3
    status.BackgroundTransparency = 1
    status.Position = UDim2.new(0, 40, 0, y)
    status.Size = UDim2.new(0, 120, 0, 18)
    status.Font = Enum.Font.Gotham
    status.Text = name .. ": OFF"
    status.TextColor3 = Color3.fromRGB(255, 0, 0)
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.TextSize = 11
    status.ZIndex = 2
    
    local btn = Instance.new("TextButton")
    btn.Parent = page3
    btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    btn.BackgroundTransparency = 0.1
    btn.Position = UDim2.new(0, 165, 0, y - 4)
    btn.Size = UDim2.new(0, 105, 0, 24)
    btn.Font = Enum.Font.Gotham
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 0, 0)
    btn.TextSize = 11
    btn.ZIndex = 2
    local c2 = Instance.new("UICorner")
    c2.CornerRadius = UDim.new(0, 5)
    c2.Parent = btn
    
    return ind, status, btn
end

local hatInd, hatStatus, hatBtn = createVisItem("Hat", 5)
local trailInd, trailStatus, trailBtn = createVisItem("Trail", 35)
local skinTrailInd, skinTrailStatus, skinTrailBtn = createVisItem("Skin Trail", 65)
local ffInd, ffStatus, ffBtn = createVisItem("ForceField", 95)
local nebulaInd, nebulaStatus, nebulaBtn = createVisItem("Nebula", 125)
local fullBrightInd, fullBrightStatus, fullBrightBtn = createVisItem("Full Bright", 155)
local animeInd, animeStatus, animeBtn = createVisItem("Anime Image", 185)
local screenInd, screenStatus, screenBtn = createVisItem("Screen FX", 215)
local fireAuraInd, fireAuraStatus, fireAuraBtn = createVisItem("Fire Aura", 245)

-- SKYBOX DROPDOWN
local skyboxLabel = Instance.new("TextLabel")
skyboxLabel.Parent = page3
skyboxLabel.BackgroundTransparency = 1
skyboxLabel.Position = UDim2.new(0, 10, 0, 275)
skyboxLabel.Size = UDim2.new(0, 100, 0, 18)
skyboxLabel.Font = Enum.Font.GothamBold
skyboxLabel.Text = "Skybox:"
skyboxLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
skyboxLabel.TextSize = 12
skyboxLabel.TextXAlignment = Enum.TextXAlignment.Left
skyboxLabel.ZIndex = 2

local skyboxBtn = Instance.new("TextButton")
skyboxBtn.Parent = page3
skyboxBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
skyboxBtn.BackgroundTransparency = 0.2
skyboxBtn.Position = UDim2.new(0, 100, 0, 271)
skyboxBtn.Size = UDim2.new(0, 170, 0, 24)
skyboxBtn.Font = Enum.Font.Gotham
skyboxBtn.Text = "HD"
skyboxBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
skyboxBtn.TextSize = 11
skyboxBtn.ZIndex = 2
local sbCorner = Instance.new("UICorner")
sbCorner.CornerRadius = UDim.new(0, 5)
sbCorner.Parent = skyboxBtn

local skyboxNames = {"Black Storm", "HD", "Snow", "Blue Space", "Realistic", "Stormy", "Pink", "Sunset", "Arctic", "Space", "Roblox Default"}
local skyboxIndex = 1

skyboxBtn.MouseButton1Click:Connect(function()
    skyboxIndex = skyboxIndex + 1
    if skyboxIndex > #skyboxNames then skyboxIndex = 1 end
    local name = skyboxNames[skyboxIndex]
    skyboxBtn.Text = name
    Visuals.CurrentSkybox = name
    Visuals.applySkybox(name)
end)

-- FORCEFIELD TRANSPARENCY SLIDER
local ffTransLabel = Instance.new("TextLabel")
ffTransLabel.Parent = page3
ffTransLabel.BackgroundTransparency = 1
ffTransLabel.Position = UDim2.new(0, 10, 0, 300)
ffTransLabel.Size = UDim2.new(0, 120, 0, 16)
ffTransLabel.Font = Enum.Font.Gotham
ffTransLabel.Text = "FF Transparency"
ffTransLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
ffTransLabel.TextSize = 10
ffTransLabel.TextXAlignment = Enum.TextXAlignment.Left
ffTransLabel.ZIndex = 2

local ffTransSlider = Instance.new("Frame")
ffTransSlider.Parent = page3
ffTransSlider.Position = UDim2.new(0, 10, 0, 318)
ffTransSlider.Size = UDim2.new(0, 260, 0, 4)
ffTransSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
ffTransSlider.ZIndex = 2
local ftsc = Instance.new("UICorner")
ftsc.CornerRadius = UDim.new(0, 2)
ftsc.Parent = ffTransSlider

local ffTransFill = Instance.new("Frame")
ffTransFill.Parent = ffTransSlider
ffTransFill.Size = UDim2.new(0, 0, 1, 0)
ffTransFill.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
ffTransFill.ZIndex = 3
local ftfc = Instance.new("UICorner")
ftfc.CornerRadius = UDim.new(0, 2)
ftfc.Parent = ffTransFill

local ffTransBtn = Instance.new("TextButton")
ffTransBtn.Parent = ffTransFill
ffTransBtn.Size = UDim2.new(0, 10, 0, 10)
ffTransBtn.Position = UDim2.new(1, -5, 0, -3)
ffTransBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ffTransBtn.Text = ""
ffTransBtn.BorderSizePixel = 0
ffTransBtn.ZIndex = 4
local ftbc = Instance.new("UICorner")
ftbc.CornerRadius = UDim.new(0, 5)
ftbc.Parent = ffTransBtn

local ffTransValue = Instance.new("TextLabel")
ffTransValue.Parent = page3
ffTransValue.BackgroundTransparency = 1
ffTransValue.Position = UDim2.new(0, 275, 0, 300)
ffTransValue.Size = UDim2.new(0, 30, 0, 16)
ffTransValue.Font = Enum.Font.Gotham
ffTransValue.Text = "0%"
ffTransValue.TextColor3 = Color3.fromRGB(255, 100, 100)
ffTransValue.TextSize = 10
ffTransValue.TextXAlignment = Enum.TextXAlignment.Right
ffTransValue.ZIndex = 2

local ffTransDragging = false

ffTransBtn.MouseButton1Down:Connect(function() ffTransDragging = true end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then ffTransDragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if ffTransDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local pos = input.Position.X
        local sPos = ffTransSlider.AbsolutePosition.X
        local sW = ffTransSlider.AbsoluteSize.X
        if sW > 0 then
            local pct = math.clamp((pos - sPos) / sW, 0, 1)
            local val = math.floor(pct * 100)
            ffTransFill.Size = UDim2.new(pct, 0, 1, 0)
            ffTransValue.Text = val .. "%"
            Visuals.ForceFieldTransparency = val / 100
            if Visuals.ForceFieldEnabled and player.Character then
                Visuals.applyForceField(player.Character)
            end
        end
    end
end)

ffTransSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local pos = input.Position.X
        local sPos = ffTransSlider.AbsolutePosition.X
        local sW = ffTransSlider.AbsoluteSize.X
        if sW > 0 then
            local pct = math.clamp((pos - sPos) / sW, 0, 1)
            local val = math.floor(pct * 100)
            ffTransFill.Size = UDim2.new(pct, 0, 1, 0)
            ffTransValue.Text = val .. "%"
            Visuals.ForceFieldTransparency = val / 100
            if Visuals.ForceFieldEnabled and player.Character then
                Visuals.applyForceField(player.Character)
            end
        end
    end
end)

-- ============================================
-- TOGGLES VISUALS
-- ============================================
hatBtn.MouseButton1Click:Connect(function()
    Visuals.HatEnabled = not Visuals.HatEnabled
    if Visuals.HatEnabled then
        hatInd.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        hatStatus.Text = "Hat: ON"
        hatBtn.Text = "Disable"
        if player.Character then Visuals.addHat(player.Character) end
    else
        hatInd.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        hatStatus.Text = "Hat: OFF"
        hatBtn.Text = "Hat"
        if player.Character then Visuals.removeHat(player.Character) end
    end
end)

trailBtn.MouseButton1Click:Connect(function()
    Visuals.TrailEnabled = not Visuals.TrailEnabled
    if Visuals.TrailEnabled then
        trailInd.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        trailStatus.Text = "Trail: ON"
        trailBtn.Text = "Disable"
        if player.Character then Visuals.addTrail(player.Character) end
    else
        trailInd.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        trailStatus.Text = "Trail: OFF"
        trailBtn.Text = "Trail"
        if player.Character then Visuals.removeTrail(player.Character) end
    end
end)

skinTrailBtn.MouseButton1Click:Connect(function()
    Visuals.SkinTrailEnabled = not Visuals.SkinTrailEnabled
    if Visuals.SkinTrailEnabled then
        skinTrailInd.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        skinTrailStatus.Text = "Skin Trail: ON"
        skinTrailBtn.Text = "Disable"
        Visuals.toggleSkinTrail(true)
    else
        skinTrailInd.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        skinTrailStatus.Text = "Skin Trail: OFF"
        skinTrailBtn.Text = "Skin Trail"
        Visuals.toggleSkinTrail(false)
    end
end)

ffBtn.MouseButton1Click:Connect(function()
    Visuals.ForceFieldEnabled = not Visuals.ForceFieldEnabled
    if Visuals.ForceFieldEnabled then
        ffInd.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        ffStatus.Text = "FF: ON"
        ffBtn.Text = "Disable"
        if player.Character then Visuals.applyForceField(player.Character) end
        ffTransFill.Size = UDim2.new(Visuals.ForceFieldTransparency, 0, 1, 0)
        ffTransValue.Text = math.floor(Visuals.ForceFieldTransparency * 100) .. "%"
    else
        ffInd.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        ffStatus.Text = "FF: OFF"
        ffBtn.Text = "ForceField"
        if player.Character then Visuals.removeForceField(player.Character) end
    end
end)

nebulaBtn.MouseButton1Click:Connect(function()
    Visuals.NebulaEnabled = not Visuals.NebulaEnabled
    if Visuals.NebulaEnabled then
        nebulaInd.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        nebulaStatus.Text = "Nebula: ON"
        nebulaBtn.Text = "Disable"
        Visuals.setNebulaEnabled(true)
    else
        nebulaInd.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        nebulaStatus.Text = "Nebula: OFF"
        nebulaBtn.Text = "Nebula"
        Visuals.setNebulaEnabled(false)
    end
end)

fullBrightBtn.MouseButton1Click:Connect(function()
    Visuals.FullBrightEnabled = not Visuals.FullBrightEnabled
    if Visuals.FullBrightEnabled then
        fullBrightInd.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        fullBrightStatus.Text = "Full Bright: ON"
        fullBrightBtn.Text = "Disable"
        Visuals.setFullBrightEnabled(true)
    else
        fullBrightInd.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        fullBrightStatus.Text = "Full Bright: OFF"
        fullBrightBtn.Text = "Full Bright"
        Visuals.setFullBrightEnabled(false)
    end
end)

animeBtn.MouseButton1Click:Connect(function()
    Visuals.AnimeImageEnabled = not Visuals.AnimeImageEnabled
    if Visuals.AnimeImageEnabled then
        animeInd.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        animeStatus.Text = "Anime: ON"
        animeBtn.Text = "Disable"
        Visuals.toggleAnimeImage(true)
    else
        animeInd.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        animeStatus.Text = "Anime: OFF"
        animeBtn.Text = "Anime Image"
        Visuals.toggleAnimeImage(false)
    end
end)

screenBtn.MouseButton1Click:Connect(function()
    Visuals.ScreenEnabled = not Visuals.ScreenEnabled
    if Visuals.ScreenEnabled then
        screenInd.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        screenStatus.Text = "Screen FX: ON"
        screenBtn.Text = "Disable"
        Visuals.setScreenEnabled(true)
    else
        screenInd.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        screenStatus.Text = "Screen FX: OFF"
        screenBtn.Text = "Screen FX"
        Visuals.setScreenEnabled(false)
    end
end)

fireAuraBtn.MouseButton1Click:Connect(function()
    Visuals.FireAuraEnabled = not Visuals.FireAuraEnabled
    if Visuals.FireAuraEnabled then
        fireAuraInd.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        fireAuraStatus.Text = "Fire Aura: ON"
        fireAuraBtn.Text = "Disable"
        if player.Character then Visuals.enableFireAura(player.Character) end
    else
        fireAuraInd.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        fireAuraStatus.Text = "Fire Aura: OFF"
        fireAuraBtn.Text = "Fire Aura"
        Visuals.disableFireAura()
    end
end)

-- ============================================
-- ФУНКЦИИ
-- ============================================
local function toggleFOV()
    fovEnabled = not fovEnabled
    camera.FieldOfView = fovEnabled and boostedFOV or normalFOV
    if fovEnabled then
        fovInd.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        fovStatus.Text = "FOV: ON ("..boostedFOV..")"
        fovBtn.Text = "Disable"
    else
        fovInd.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        fovStatus.Text = "FOV: OFF"
        fovBtn.Text = "FOV"
    end
end

local function getCameraTargetPosition()
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {player.Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(camera.CFrame.Position, camera.CFrame.LookVector * 500, params)
    return result and result.Position or camera.CFrame.Position + camera.CFrame.LookVector * 500
end

local function teleportToCenter()
    if not tpEnabled then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    if root then root.CFrame = CFrame.new(getCameraTargetPosition()) end
end

local function toggleTP()
    tpEnabled = not tpEnabled
    if tpEnabled then
        tpInd.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        tpStatus.Text = "TP: ON"
        tpBtn.Text = "Disable"
    else
        tpInd.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        tpStatus.Text = "TP: OFF"
        tpBtn.Text = "TP"
    end
end

local function createESPForPlayer(plr)
    if espElements[plr] or plr == player then return end
    local function update()
        local char = plr.Character
        if not char then return end
        local head = char:FindFirstChild("Head")
        if not head then return end
        if espElements[plr] then espElements[plr]:Destroy(); espElements[plr] = nil end
        local bill = Instance.new("BillboardGui")
        bill.Name = "ESP_"..plr.Name
        bill.Adornee = head
        bill.Size = UDim2.new(0, 200, 0, 50)
        bill.StudsOffset = Vector3.new(0, 3, 0)
        bill.AlwaysOnTop = true
        bill.Parent = espFolder
        local txt = Instance.new("TextLabel")
        txt.Parent = bill
        txt.BackgroundTransparency = 1
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.Text = plr.DisplayName or plr.Name
        txt.TextColor3 = Color3.fromRGB(255, 255, 255)
        txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        txt.TextStrokeTransparency = 0.3
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 16
        txt.TextScaled = true
        espElements[plr] = bill
    end
    if plr.Character then update() end
    plr.CharacterAdded:Connect(update)
    plr.CharacterRemoving:Connect(function()
        if espElements[plr] then espElements[plr]:Destroy(); espElements[plr] = nil end
    end)
end

local function toggleESP()
    espEnabled = not espEnabled
    if espEnabled then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= player then createESPForPlayer(p) end
        end
        game.Players.PlayerAdded:Connect(function(p) if p ~= player then createESPForPlayer(p) end end)
        game.Players.PlayerRemoving:Connect(function(p)
            if espElements[p] then espElements[p]:Destroy(); espElements[p] = nil end
        end)
        espInd.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        espStatus.Text = "ESP: ON"
        espBtn.Text = "Disable"
    else
        for _, e in pairs(espElements) do e:Destroy() end
        espElements = {}
        espInd.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        espStatus.Text = "ESP: OFF"
        espBtn.Text = "ESP"
    end
end

local function activateRagdoll()
    ragdollInd.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    ragdollStatus.Text = "Ragdoll: Working..."
    local char = player.Character
    local HRP = char and char:FindFirstChild("HumanoidRootPart")
    local Ragdoll = ReplicatedStorage:FindFirstChild("CharacterEvents") and ReplicatedStorage.CharacterEvents:FindFirstChild("RagdollRemote")
    if char and HRP and char:FindFirstChild("Left Leg") and char:FindFirstChild("Right Leg") and char:FindFirstChild("Torso") then
        local ll = char["Left Leg"]
        local rl = char["Right Leg"]
        local torso = char.Torso
        local void = workspace.FallenPartsDestroyHeight
        local pos = torso.CFrame
        workspace.FallenPartsDestroyHeight = -100
        if Ragdoll then Ragdoll:FireServer(HRP, 2) end
        task.wait(0.5)
        rl.CFrame = CFrame.new(0, -10000, 0)
        ll.CFrame = CFrame.new(0, -10000, 0)
        task.wait(0.3)
        torso.CFrame = CFrame.new(0, -9970, 0)
        task.wait(0.5)
        torso.CFrame = pos
        task.wait(0.5)
        workspace.FallenPartsDestroyHeight = void
        task.spawn(function()
            while char and char.Parent do
                if not char:FindFirstChild("Left Leg") and not char:FindFirstChild("Right Leg") then
                    local hum = char:FindFirstChild("Humanoid")
                    if hum then
                        local controls = player.PlayerGui:FindFirstChild("ControlsGui")
                        if controls and controls:FindFirstChild("PCFrame") and controls.PCFrame:FindFirstChild("Stand") then
                            if controls.PCFrame.Stand.Visible == false then
                                hum.HipHeight = 2
                            else
                                hum.HipHeight = 0
                            end
                        end
                    end
                else
                    break
                end
                task.wait()
            end
        end)
        ragdollInd.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        ragdollStatus.Text = "Ragdoll: Done"
        task.wait(2)
        ragdollInd.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        ragdollStatus.Text = "Ragdoll: OFF"
    else
        ragdollInd.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        ragdollStatus.Text = "Ragdoll: Error"
        task.wait(2)
        ragdollStatus.Text = "Ragdoll: OFF"
    end
end

local function toggleThirdPerson()
    thirdPersonEnabled = not thirdPersonEnabled
    if thirdPersonEnabled then
        player.CameraMode = Enum.CameraMode.Classic
        player.CameraMaxZoomDistance = 100
        thirdPersonConnection = RunService.RenderStepped:Connect(function()
            player.CameraMode = Enum.CameraMode.Classic
            player.CameraMaxZoomDistance = 100
        end)
        thirdInd.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        thirdStatus.Text = "3rd Person: ON"
        thirdBtn.Text = "Disable"
    else
        if thirdPersonConnection then thirdPersonConnection:Disconnect(); thirdPersonConnection = nil end
        player.CameraMode = Enum.CameraMode.LockFirstPerson
        player.CameraMaxZoomDistance = 0.5
        thirdInd.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        thirdStatus.Text = "3rd Person: OFF"
        thirdBtn.Text = "3rd Person"
    end
end

local function toggleJerkOff()
    jerkOffActive = not jerkOffActive
    if jerkOffActive then
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://168268306"
        jerkOffTrack = animator:LoadAnimation(anim)
        jerkOffTrack.Priority = Enum.AnimationPriority.Action
        jerkOffTrack:Play()
        if jerkOffLoop then task.cancel(jerkOffLoop) end
        jerkOffLoop = task.spawn(function()
            while jerkOffActive do
                task.wait(0.1)
                if jerkOffTrack and jerkOffTrack.IsPlaying then
                    jerkOffTrack.TimePosition = 0.3
                end
            end
        end)
        jerkOffInd.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        jerkOffStatus.Text = "Jerk Off: ON"
        jerkOffBtn.Text = "Disable"
    else
        if jerkOffLoop then task.cancel(jerkOffLoop); jerkOffLoop = nil end
        if jerkOffTrack then jerkOffTrack:Stop(); jerkOffTrack = nil end
        jerkOffInd.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        jerkOffStatus.Text = "Jerk Off: OFF"
        jerkOffBtn.Text = "Jerk Off"
    end
end

local function toggleAntiGrab()
    antiGrabEnabled = not antiGrabEnabled
    if antiGrabEnabled then
        local isHeld = player:WaitForChild("IsHeld", 5)
        local struggle = ReplicatedStorage:FindFirstChild("CharacterEvents") and ReplicatedStorage.CharacterEvents:FindFirstChild("Struggle")
        if not isHeld or not struggle then
            antiGrabEnabled = false
            antiGrabInd.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            antiGrabStatus.Text = "Anti Grab: Error"
            return
        end
        local function onHeldChanged(held)
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if held then
                if hrp then savedCFrame = hrp.CFrame; hrp.Anchored = true end
                task.spawn(function()
                    while isHeld.Value and antiGrabEnabled do
                        struggle:FireServer(player)
                        task.wait()
                    end
                    if hrp then hrp.Anchored = false; if savedCFrame then hrp.CFrame = savedCFrame end end
                end)
            else
                if hrp then hrp.Anchored = false; if savedCFrame then hrp.CFrame = savedCFrame end end
            end
        end
        if antiGrabConn then antiGrabConn:Disconnect() end
        antiGrabConn = isHeld.Changed:Connect(onHeldChanged)
        if isHeld.Value then onHeldChanged(true) end
        antiGrabInd.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        antiGrabStatus.Text = "Anti Grab: ON"
        antiGrabBtn.Text = "Disable"
    else
        if antiGrabConn then antiGrabConn:Disconnect(); antiGrabConn = nil end
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Anchored = false end
        antiGrabInd.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        antiGrabStatus.Text = "Anti Grab: OFF"
        antiGrabBtn.Text = "Anti Grab"
    end
end

local function toggleAutoReset()
    autoResetEnabled = not autoResetEnabled
    if autoResetEnabled then
        local notify = ReplicatedStorage:FindFirstChild("GameCorrectionEvents") and ReplicatedStorage.GameCorrectionEvents:FindFirstChild("GameCorrectionsNotify")
        if not notify then
            autoResetEnabled = false
            autoResetInd.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            autoResetStatus.Text = "Auto Reset: Error"
            return
        end
        antiKickResetConnection = notify.OnClientEvent:Connect(function(reason)
            if reason == "Flying" then
                local char = player.Character
                local hum = char and char:FindFirstChild("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Dead); hum.Health = 0 end
            end
        end)
        autoResetInd.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        autoResetStatus.Text = "Auto Reset: ON"
        autoResetBtn.Text = "Disable"
    else
        if antiKickResetConnection then antiKickResetConnection:Disconnect(); antiKickResetConnection = nil end
        autoResetInd.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        autoResetStatus.Text = "Auto Reset: OFF"
        autoResetBtn.Text = "Auto Reset"
    end
end

local function toggleAntiLag()
    antiLagEnabled = not antiLagEnabled
    local scripts = player:FindFirstChild("PlayerScripts")
    local target = scripts and scripts:FindFirstChild("CharacterAndBeamMove")
    if antiLagEnabled then
        if target then
            target.Disabled = true
            antiLagInd.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            antiLagStatus.Text = "Anti Lag: ON"
            antiLagBtn.Text = "Disable"
        else
            local rf = game:GetService("ReplicatedFirst")
            local alt = rf and rf:FindFirstChild("CharacterAndBeamMove")
            if alt then
                alt.Disabled = true
                antiLagInd.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                antiLagStatus.Text = "Anti Lag: ON"
                antiLagBtn.Text = "Disable"
            else
                antiLagEnabled = false
                antiLagInd.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                antiLagStatus.Text = "Anti Lag: Error"
                antiLagBtn.Text = "Anti Lag"
            end
        end
    else
        if target then target.Disabled = false end
        local rf = game:GetService("ReplicatedFirst")
        local alt = rf and rf:FindFirstChild("CharacterAndBeamMove")
        if alt then alt.Disabled = false end
        antiLagInd.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        antiLagStatus.Text = "Anti Lag: OFF"
        antiLagBtn.Text = "Anti Lag"
    end
end

-- ============================================
-- АВТОГРАБ (Q - вкл, F - сброс)
-- ============================================
local function getPlayerAtCenter()
    if not player.Character then return nil, nil end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {player.Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local size = camera.ViewportSize
    local center = Vector2.new(size.X / 2, size.Y / 2)
    local ray = camera:ViewportPointToRay(center.X, center.Y)
    local result = workspace:Raycast(ray.Origin, ray.Direction * 29, params)
    if result then
        local hit = result.Instance
        local char = hit:FindFirstAncestorOfClass("Model")
        if char then
            local target = game.Players:GetPlayerFromCharacter(char)
            if target and target ~= player then return target, hit end
        end
    end
    return nil, nil
end

local function performGrab()
    if hasGrabbed or isWaitingForReset then return false end
    local targetPlayer, hitPart = getPlayerAtCenter()
    if targetPlayer and hitPart then
        local char = player.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            if root and (root.Position - hitPart.Position).Magnitude <= 29 then
                local mouse = player:GetMouse()
                mouse1click()
                hasGrabbed = true
                grabbedPlayer = targetPlayer
                isWaitingForReset = true
                return true
            end
        end
    end
    return false
end

local function resetGrab()
    if hasGrabbed or isWaitingForReset then
        hasGrabbed = false
        grabbedPlayer = nil
        isWaitingForReset = false
        return true
    end
    return false
end

local function toggleAutoGrab()
    autoGrabEnabled = not autoGrabEnabled
    if autoGrabEnabled then
        hasGrabbed = false
        grabbedPlayer = nil
        isWaitingForReset = false
        autoGrabConnection = RunService.Heartbeat:Connect(function()
            if not autoGrabEnabled then return end
            if not player.Character or not player.Character:FindFirstChild("Humanoid") or player.Character.Humanoid.Health <= 0 then
                hasGrabbed = false
                grabbedPlayer = nil
                isWaitingForReset = false
                return
            end
            if hasGrabbed or isWaitingForReset then return end
            performGrab()
        end)
    else
        if autoGrabConnection then autoGrabConnection:Disconnect(); autoGrabConnection = nil end
        hasGrabbed = false
        grabbedPlayer = nil
        isWaitingForReset = false
    end
end

local function toggleGUI()
    guiVisible = not guiVisible
    mainFrame.Visible = guiVisible
end

-- ============================================
-- КНОПКИ
-- ============================================
fovBtn.MouseButton1Click:Connect(toggleFOV)
tpBtn.MouseButton1Click:Connect(toggleTP)
espBtn.MouseButton1Click:Connect(toggleESP)
ragdollBtn.MouseButton1Click:Connect(activateRagdoll)
thirdBtn.MouseButton1Click:Connect(toggleThirdPerson)
antiGrabBtn.MouseButton1Click:Connect(toggleAntiGrab)
autoResetBtn.MouseButton1Click:Connect(toggleAutoReset)
antiLagBtn.MouseButton1Click:Connect(toggleAntiLag)
jerkOffBtn.MouseButton1Click:Connect(toggleJerkOff)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.R then toggleFOV()
    elseif input.KeyCode == Enum.KeyCode.Z then teleportToCenter()
    elseif input.KeyCode == Enum.KeyCode.C then activateRagdoll()
    elseif input.KeyCode == Enum.KeyCode.V then toggleThirdPerson()
    elseif input.KeyCode == Enum.KeyCode.L then toggleGUI()
    elseif input.KeyCode == Enum.KeyCode.Tab then switchTab(currentPage == 1 and 2 or currentPage == 2 and 3 or 1)
    elseif input.KeyCode == Enum.KeyCode.G then toggleJerkOff()
    elseif input.KeyCode == Enum.KeyCode.Q then toggleAutoGrab()
    elseif input.KeyCode == Enum.KeyCode.F then resetGrab()
    elseif input.KeyCode == Enum.KeyCode.H then anchorfunc()
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(1)
    if fovEnabled then camera.FieldOfView = boostedFOV end
    if thirdPersonEnabled then
        player.CameraMode = Enum.CameraMode.Classic
        player.CameraMaxZoomDistance = 100
    end
    if antiLagEnabled then
        local scripts = player:FindFirstChild("PlayerScripts")
        local target = scripts and scripts:FindFirstChild("CharacterAndBeamMove")
        if target then target.Disabled = true end
    end
    hasGrabbed = false
    grabbedPlayer = nil
    isWaitingForReset = false
end)



print("loaded successfully!")
