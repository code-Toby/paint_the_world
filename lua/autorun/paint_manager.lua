
if SERVER then
    util.AddNetworkString("PaintManager_OPENMENU")

    hook.Add( "Initialize", "Initialize_Paint_Commands", function()
        concommand.Add( "PaintManager", function( ply )
            if ply == nil then return end
            net.Start("PaintManager_OPENMENU")
            net.Send(ply)
        end)
    end)
end

if CLIENT then

    local paint_color = CreateClientConVar("paint_manager_color", "255 255 255", false, false, "sets the color for the paint swep example: paint_manager_color <r> <g> <b>")
    local paint_size = CreateClientConVar("paint_manager_size", "1.5", false, false, "sets the radius of the paint swep example: paint_manager_size <number>")
    local paint_layer = CreateClientConVar("paint_manager_layer", "1", false, false, "sets the current working layer of the paint swep example: paint_manager_layer <number>")

    function DrawMenu()
        local MainScrW = 270
        local MainScrH = 500

        local Clr_str = string.Explode(" ",paint_color:GetString())

        local R = tonumber(Clr_str[1])
        local G = tonumber(Clr_str[2])
        local B = tonumber(Clr_str[3])

        local Clr = Color(R,G,B)

        local DFrame = vgui.Create("DFrame") -- The name of the panel we don't have to parent it.
        DFrame:SetPos((ScrW() / 2) + MainScrW + 320, (ScrH() / 2) - MainScrH) 
        DFrame:SetSize(MainScrW, MainScrH)
        DFrame:SetTitle("Paint Swep")
        DFrame:MakePopup()

        local DermaColorCombo = vgui.Create( "DColorCombo", DFrame )
        DermaColorCombo:SetPos( 5, 30 )
        DermaColorCombo:SetColor( Clr )
        function DermaColorCombo:OnValueChanged( col )
            
            paint_color:SetString( col['r'].." "..col['g'].." "..col['b'])
        end
        

        local DermaNumSlider_size = vgui.Create( "DNumSlider", DFrame )
        DermaNumSlider_size:SetPos( 10, 300 )				
        DermaNumSlider_size:SetSize( MainScrW, 70 )			
        DermaNumSlider_size:SetText( "Paint Size" )	
        DermaNumSlider_size:SetMin( 0.1 )				 	
        DermaNumSlider_size:SetMax( 100 )				
        DermaNumSlider_size:SetDecimals( 1 )				
        DermaNumSlider_size:SetValue( paint_size:GetFloat() )
        DermaNumSlider_size:SetConVar( "paint_manager_size" )
        
        local DermaNumSlider_layer = vgui.Create( "DNumSlider", DFrame )
        DermaNumSlider_layer:SetPos( 10, 370 )				
        DermaNumSlider_layer:SetSize( MainScrW, 70 )			
        DermaNumSlider_layer:SetText( "Paint Layer" )	
        DermaNumSlider_layer:SetMin( 1 )				 	
        DermaNumSlider_layer:SetMax( 5 )				
        DermaNumSlider_layer:SetDecimals( 0 )
        DermaNumSlider_layer:SetValue( paint_layer:GetInt() )				
        DermaNumSlider_layer:SetConVar( "paint_manager_layer" )

        local FinishButton = vgui.Create( "DButton", DFrame )
        FinishButton:SetPos(MainScrW/2.6,450)
        FinishButton:SetText("Finish")
        FinishButton.DoClick = function()
            DFrame:Close()
        end
    end

    //--HUD STUFF START--\\
    //--HUD STUFF END--\\

    //--MENU STUFF START--\\
    net.Receive("PaintManager_OPENMENU", function(_, _)
        DrawMenu()
    end)
    //--MENU STUFF END--\\
end
