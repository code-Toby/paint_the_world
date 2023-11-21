include("shared.lua")

function ENT:Initialize()
    
end

function ENT:Draw(flags)
    self:SetMaterial("models/debug/debugwhite")
    self:SetModel("models/hunter/misc/sphere025x025.mdl")

    local matrix = Matrix()
    matrix:Scale(self:GetScale())
    self:EnableMatrix("RenderMultiply", matrix)

    render.SuppressEngineLighting(true)
    self:DrawModel()
    render.SuppressEngineLighting(false)
end
