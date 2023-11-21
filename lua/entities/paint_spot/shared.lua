include("autorun/paint_manager.lua")

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Paint Spot"
ENT.Author = "{Toby}"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
    self:NetworkVar("Vector", 0, "Scale")
    self:NetworkVar("Vector", 1, "Color")
    self:NetworkVar("Vector", 2, "Position")
end
