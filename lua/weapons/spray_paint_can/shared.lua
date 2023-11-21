AddCSLuaFile()
include("swepModelerCode.lua")

if SERVER then
    SWEP.Weight             = 5
	SWEP.AutoSwitchTo       = false
	SWEP.AutoSwitchFrom     = false
end

if CLIENT then
    SWEP.PrintName			= "Spray paint"			
	SWEP.Author				= "{Toby}"
	SWEP.Instructions		= "Left click - Paint			Right click - Open Color Menu		Reload - clear your paint"
	SWEP.Slot				= 0
	SWEP.SlotPos			= 10

    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = false
end

SWEP.Spawnable              = true
SWEP.AdminSpawnable         = false

SWEP.HoldType = "revolver"
SWEP.ViewModelFOV = 57.688442211055
SWEP.ViewModelFlip = false
SWEP.UseHands = false
SWEP.ViewModel = "models/weapons/v_grenade.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false
SWEP.ViewModelBoneMods = {
	["ValveBiped.Grenade_body"] = { scale = Vector(3, 3, 3), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, -0.186, 4.258), angle = Angle(0, 27.777, 0) }
}


SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Ammo           = "none"
 
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo         = "none"

SWEP.WElements = {
	["spray_can"] = { type = "Model", model = "models/paint_the_world/Spray_paint_can.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.596, 1.557, 0), angle = Angle(0, 0, 180), size = Vector(0.625, 0.625, 0.625), color = Color(255, 255, 255, 255), surpresslightning = false, material = "PAINT_THE_WORLD/spray_can", skin = 0, bodygroup = {} }
}
SWEP.VElements = {
	["spray_can"] = { type = "Model", model = "models/paint_the_world/Spray_paint_can.mdl", bone = "ValveBiped.Grenade_body", rel = "", pos = Vector(-3.636, 0, 0), angle = Angle(0, 24.545, 180), size = Vector(0.95, 0.95, 0.95), color = Color(255, 255, 255, 255), surpresslightning = false, material = "PAINT_THE_WORLD/spray_can", skin = 0, bodygroup = {} }
}

SWEP.PaintSpots = {}
SWEP.LastPos = Vector(0,0,0)
SWEP.ONHOLDSTER = function(self)
	if self.CrossHair != nil then
		self.CrossHair:SetScale(Vector(0,0,0))
	end
end

function PAINT(swep)
    local EntSize = GetConVar("paint_manager_size"):GetFloat()
    local EntColor = GetConVar("paint_manager_color"):GetString()

    local ClrDecode = string.Explode(" ", EntColor)
    local R, G, B = tonumber(ClrDecode[1]), tonumber(ClrDecode[2]), tonumber(ClrDecode[3])

    local owner = swep:GetOwner()
    local eyeTrace = owner:GetEyeTrace()

    local EntLayer = GetConVar("paint_manager_layer"):GetFloat()

    local mainPos = eyeTrace.HitPos + eyeTrace.HitNormal * EntLayer * 1.2

    if mainPos:Distance(swep.LastPos) >= EntSize / 2.5 then
        local currPaint = ents.Create("paint_spot")
        currPaint:SetOwner(owner)
        currPaint:SetPos(eyeTrace.HitPos + eyeTrace.HitNormal * EntLayer / 2.8)
        currPaint:SetAngles(eyeTrace.HitNormal:Angle() + Angle(90, 0, 0))
        currPaint:Spawn()

        currPaint:SetScale(Vector(EntSize, EntSize, 0))
        currPaint:SetColor(Color(R, G, B))
        currPaint.Layer = EntLayer

        currPaint.Creator = owner

        table.insert(swep.PaintSpots, currPaint)
    end

    swep.LastPos = mainPos
end

function SWEP:ERASE()
    local EntSize = GetConVar("paint_manager_size"):GetFloat()
    local EntLayer = GetConVar("paint_manager_layer"):GetFloat()
    local RemoveType = GetConVar("paint_manager_remove_type"):GetInt()
    local RemoveByLayer = GetConVar("paint_manager_remove_by_layer"):GetBool()

    local MainPos = self:GetOwner():GetEyeTrace().HitPos + self:GetOwner():GetEyeTrace().HitNormal * EntLayer * 5.1

    local trace = self:GetOwner():GetEyeTrace()
    
    for _, ent in pairs(ents.FindInSphere(trace.HitPos, EntSize / 2 + 5.1)) do
        if IsValid(ent) and ent:GetClass() == "paint_spot" and ent.Creator == self:GetOwner() then
            local distanceToSpot = ent:GetPos():Distance(trace.HitPos)
            if distanceToSpot <= EntSize / 0.2 and ent.Creator == self:GetOwner() then
                if not RemoveByLayer or (RemoveByLayer and ent.Layer == EntLayer) then
                    if RemoveType == 1 then
                        ent:Remove()
                    elseif RemoveType == 2 then
                        local spotColor = ent:GetColor()
                        local EntColor = GetConVar("paint_manager_color"):GetString()
                        local ClrDecode = string.Explode(" ", EntColor)
                        local R = tonumber(ClrDecode[1])
                        local G = tonumber(ClrDecode[2])
                        local B = tonumber(ClrDecode[3])

                        local isMatchingColor = spotColor.r == R and spotColor.g == G and spotColor.b == B

                        if isMatchingColor then
                            ent:Remove()
                        end
                    end
                end
            end
        end
    end

    self.LastPos = MainPos
end

function SWEP:PrimaryAttack()
	PAINT(self)
end

function SWEP:SecondaryAttack()
	concommand.Run(self:GetOwner(),"PaintManager")
end

function SWEP:Reload()
    local RemoveType = GetConVar("paint_manager_remove_type"):GetInt()

    if RemoveType == 0 then
        for _, paintSpot in pairs(self.PaintSpots) do
            if IsValid(paintSpot) and paintSpot.Creator == self:GetOwner() then
                paintSpot:Remove()
            end
        end

        self.PaintSpots = self:FilterValidPaintSpots(self.PaintSpots)
    elseif RemoveType == 1 or RemoveType == 2 then
        self:ERASE()
    end
end

function SWEP:FilterValidPaintSpots(paintSpots)
    local filteredPaintSpots = {}

    for _, paintSpot in pairs(paintSpots) do
        if IsValid(paintSpot) then
            table.insert(filteredPaintSpots, paintSpot)
        end
    end

    return filteredPaintSpots
end

function SWEP:Think()
    if CLIENT then
        local EntSize = GetConVar("paint_manager_size"):GetFloat()
        local EntColor = GetConVar("paint_manager_color"):GetString()
        local EntLayer = GetConVar("paint_manager_layer"):GetFloat()
        local RemoveType = GetConVar("paint_manager_remove_type"):GetInt()
        
        local ClrDecode = string.Explode(" ", EntColor)
        local R = tonumber(ClrDecode[1])
        local G = tonumber(ClrDecode[2])
        local B = tonumber(ClrDecode[3])

        if not self:GetOwner():KeyDown(IN_RELOAD) or RemoveType == 0 then
            if self.CrossHair == nil then
                self.CrossHair = ents.CreateClientside("paint_spot")
                self.CrossHair:SetModel("models/hunter/tubes/tube1x1x1.mdl")
                self.CrossHair:Spawn()
            else
                local shapeType = "circle"

                if self.ShapeType ~= shapeType then
                    self.CrossHair:Remove()

                    self.CrossHair = ents.CreateClientside("paint_spot")
                    self.CrossHair:SetModel(shapeType == "circle" and "models/hunter/tubes/tube1x1x1.mdl" or "models/props_c17/canister01a.mdl")
                    self.CrossHair:Spawn()

                    self.ShapeType = shapeType
                end

                self.CrossHair:SetScale(Vector(EntSize, EntSize, 0))
                self.CrossHair:SetColor(Color(R, G, B))
                self.CrossHair:SetAngles(self:GetOwner():GetEyeTrace().HitNormal:Angle() + Angle(90, 0, 0))
                self.CrossHair:SetPos(self:GetOwner():GetEyeTrace().HitPos + self:GetOwner():GetEyeTrace().HitNormal * EntLayer / 2.5)
            end
        elseif RemoveType == 1 or RemoveType == 2 and self:GetOwner():KeyDown(IN_RELOAD)then
            if self.CrossHair ~= nil then
                self.CrossHair:Remove()
                self.CrossHair = nil
            end
        end
    end
end

function SWEP:OnRemove()
	for k, v in pairs(self.PaintSpots) do
		if not IsValid(v) then return end
		print(v)
		v:Remove()

		if k == #self.PaintSpots then
			self.PaintSpots = {}
		end
	end

	if self.CrossHair != nil then
		self.CrossHair:Remove()
	end
end