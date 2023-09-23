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
	SWEP.Slot				= 0
	SWEP.SlotPos			= 10

    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = true
end

SWEP.Spawnable              = true
SWEP.AdminSpawnable         = false

SWEP.HoldType = "revolver"
SWEP.ViewModelFOV = 57.688442211055
SWEP.ViewModelFlip = false
SWEP.UseHands = false
SWEP.ViewModel = "models/weapons/v_grenade.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.ViewModelBoneMods = {
	["ValveBiped.Grenade_body"] = { scale = Vector(3, 3, 3), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, -0.186, 4.258), angle = Angle(0, 27.777, 0) }
}


SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = false
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

function SWEP:PrimaryAttack()

end

function SWEP:SecondaryAttack()
	concommand.Run(self:GetOwner(),"PaintManager")
end
