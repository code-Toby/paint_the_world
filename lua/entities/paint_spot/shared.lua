include("autorun/paint_manager.lua")

ENT.Type            = "anim"
ENT.Base            = "base_anim"

ENT.PrintName       = "paint spot"
ENT.Author          = "{Toby}"

ENT.Spawnable       = true
ENT.AdminSpawnable  = false

function ENT:SetupDataTables()
	self:NetworkVar( "Vector", 0, "Scale" )
	self:NetworkVar( "Vector", 0, "Color" )
	self:NetworkVar( "Vector", 0, "Position")
end