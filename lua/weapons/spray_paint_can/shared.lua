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

end

if CLIENT then
	LocalPlayer().PaintColor = Color(255,255,255)
	LocalPlayer().PaintSpots = {}
	LocalPlayer().CurrLayer = 1
	local lastDrawLayer = LocalPlayer().CurrLayer
	local lastpos = Vector(0,0,0)
	local lastPos_2 = Vector(0,0,0)

	hook.Add( "OnPlayerChat", "tb_spray_paint_cmds", function( ply, text, _, _ )
		if ply != LocalPlayer() then return false end
		local prefix = "/-"
		local cmd = string.Explode(" ", text)
		if cmd[1] == prefix then

			if not cmd[2] then
				LocalPlayer():ChatPrint("Please Enter a command")
			elseif cmd[2] == "color" then
				local R = tonumber(cmd[3])
				local G = tonumber(cmd[4])
				local B = tonumber(cmd[5])

				LocalPlayer().PaintColor = Color(R,G,B)
			elseif cmd[2] == "layer" then
				local layer = tonumber(cmd[3])
				LocalPlayer().CurrLayer = layer
			end
			return true
		end
		return false
	end )

	hook.Add("PreDrawOpaqueRenderables","tb_spray_paint",function(isDrawingDepth, _, _)
		if LocalPlayer():GetActiveWeapon():GetClass() != "spray_paint_can" then return end
		isDrawingDepth = true
		local pos = LocalPlayer():GetEyeTrace().HitPos
		
		render.SetColorMaterial()
		render.DrawSphere( pos, 5, 50, 50, LocalPlayer().PaintColor )

		if LocalPlayer():KeyDown(IN_ATTACK) then
			
			if pos:Distance(lastpos) >= 6 then
				table.insert(LocalPlayer().PaintSpots,{pos, LocalPlayer().PaintColor, LocalPlayer().CurrLayer})
				lastpos = pos
			end
		end

		if LocalPlayer():KeyDown(IN_RELOAD) then -- might get replaced
			--PrintTable(LocalPlayer().PaintSpots)
			LocalPlayer().PaintSpots = {}
		end

		for k, v in pairs(LocalPlayer().PaintSpots) do
			if v[3] != nil then
				if lastDrawLayer < v[3] and lastPos_2:Distance(v[1]) >= 6 then
					print(lastDrawLayer)
					render.DrawSphere( v[1], 5, 6, 6, v[2] )
				end
				lastDrawLayer = v[3]
				lastPos_2 = v[1]
			end
		end
	end)
end