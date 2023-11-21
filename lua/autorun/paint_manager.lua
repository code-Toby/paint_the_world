if SERVER then
    util.AddNetworkString("PaintManager_OPENMENU")

    hook.Add("Initialize", "Initialize_Paint_Commands", function()
        concommand.Add("PaintManager", function(ply)
            if IsValid(ply) then
                net.Start("PaintManager_OPENMENU")
                net.Send(ply)
            end
        end)
    end)
end

if CLIENT then
    local paint_color = CreateClientConVar("paint_manager_color", "255 255 255", false, false, "Sets the color for the paint swep. Example: paint_manager_color <r> <g> <b>")
    local paint_size = CreateClientConVar("paint_manager_size", "1.5", false, false, "Sets the radius of the paint swep. Example: paint_manager_size <number>")
    local paint_layer = CreateClientConVar("paint_manager_layer", "1", false, false, "Sets the current working layer of the paint swep. Example: paint_manager_layer <number>")
    local paint_manager_remove_type = CreateClientConVar("paint_manager_remove_type", "0", false, false, "Sets the paint removal type. 0: Clean ALL, 1: Manual Clear, 2: Manual Clear By Color")
    local paint_remove_by_layer = CreateClientConVar("paint_manager_remove_by_layer", "0", false, false, "Enable or disable removing by layer")

    local DermaLabelRemoveByLayer
    local DermaCheckBoxRemoveByLayer
	
	local DermaNumSliderRemoveType
    local hexLabel, hexEntry
    local rgbLabel, rgbEntry

    local function AdjustConVarLimits()
        local maxSize = 100
        local currentSize = paint_size:GetFloat()
        if currentSize > maxSize then
            paint_size:SetFloat(maxSize)
        elseif currentSize < 0.1 then
            paint_size:SetFloat(0.1)
        end

        local maxLayer = 5
        local currentLayer = paint_layer:GetFloat()
        if currentLayer > maxLayer then
            paint_layer:SetFloat(maxLayer)
        elseif currentLayer < 1 then
            paint_layer:SetFloat(1)
        end

        local maxRemoveType = 2
        local currentRemoveType = paint_manager_remove_type:GetFloat()
        if currentRemoveType > maxRemoveType then
            paint_manager_remove_type:SetFloat(maxRemoveType)
        elseif currentRemoveType < 0 then
            paint_manager_remove_type:SetFloat(0)
        end

        local removeType = paint_manager_remove_type:GetInt()
        if IsValid(DermaLabelRemoveByLayer) then
            DermaLabelRemoveByLayer:SetVisible(removeType == 1 or removeType == 2)
			if removeType == 0 then
				DermaNumSliderRemoveType:SetText("Remove Type: Clear ALL")
			elseif removeType == 1 then
				DermaNumSliderRemoveType:SetText("Remove Type: Manual Clear")
			elseif removeType == 2 then
				DermaNumSliderRemoveType:SetText("Remove Type: Manual Clear by Color")
			end
			
        end
        if IsValid(DermaCheckBoxRemoveByLayer) then
            DermaCheckBoxRemoveByLayer:SetVisible(removeType == 1 or removeType == 2)
        end
    end

    hook.Add("Think", "AdjustConVarLimits", AdjustConVarLimits)

    local function DrawMenu()
        local MainScrW, MainScrH = 470, 600
		local RemoveType = GetConVar("paint_manager_remove_type"):GetInt()

        local Clr_str = string.Explode(" ", paint_color:GetString())
        local R, G, B = tonumber(Clr_str[1]), tonumber(Clr_str[2]), tonumber(Clr_str[3])
        local Clr = Color(R, G, B)

        local DFrame = vgui.Create("DFrame")
        DFrame:SetPos((ScrW() / 2) + MainScrW + 0, (ScrH() / 2) - MainScrH + 150)
        DFrame:SetSize(MainScrW, MainScrH)
        DFrame:SetTitle("Paint Swep")
        DFrame:MakePopup()

        local DermaColorCombo = vgui.Create("DColorCombo", DFrame)
        DermaColorCombo:SetPos(5, 30)
        DermaColorCombo:SetColor(Clr)
        function DermaColorCombo:OnValueChanged(col)
            local r, g, b = col['r'], col['g'], col['b']
            paint_color:SetString(r .. " " .. g .. " " .. b)

            hexLabel:SetText(string.format("Hex: #%02X%02X%02X", r, g, b))
            hexEntry:SetText(string.format("%02X%02X%02X", r, g, b))

            rgbLabel:SetText(string.format("(R, G, B): (%d, %d, %d)", r, g, b))
            rgbEntry:SetText(string.format("(%d, %d, %d)", r, g, b))
        end

		hexLabel = vgui.Create("DLabel", DFrame)
		hexLabel:SetPos(280, 60)
		hexLabel:SetText(string.format("Hex: #%02X%02X%02X", R, G, B))
		hexLabel:SizeToContents()
		hexLabel:SetAutoStretchVertical(true)

        hexEntry = vgui.Create("DTextEntry", DFrame)
        hexEntry:SetPos(280, 80)
        hexEntry:SetSize(100, 20)
        hexEntry:SetText(string.format("%02X%02X%02X", R, G, B))
		hexEntry.OnEnter = function(self)
			local hexString = self:GetText()
			local validHex = string.match(hexString, "^#?([0-9a-fA-F]+)$")

			if validHex and #validHex == 6 then
				local r, g, b = tonumber("0x" .. validHex:sub(1, 2)), tonumber("0x" .. validHex:sub(3, 4)), tonumber("0x" .. validHex:sub(5, 6))

				if r and g and b and r >= 0 and r <= 255 and g >= 0 and g <= 255 and b >= 0 and b <= 255 then
					DermaColorCombo:SetColor(Color(r, g, b))

					hexLabel:SetText(string.format("Hex: #%02X%02X%02X", r, g, b))
					hexEntry:SetText(string.format("%02X%02X%02X", r, g, b))

					rgbLabel:SetText(string.format("(R, G, B): (%d, %d, %d)", r, g, b))
					rgbEntry:SetText(string.format("(%d, %d, %d)", r, g, b))
				else
					self:SetText(string.format("%02X%02X%02X", R, G, B))
				end
			else
				self:SetText(string.format("%02X%02X%02X", R, G, B))
			end

			local newHexString = hexEntry:GetText()
			hexLabel:SetText(string.format("Hex: #%s", newHexString))
			hexLabel:SizeToContents()
	end

		rgbLabel = vgui.Create("DLabel", DFrame)
		rgbLabel:SetPos(280, 110)
		rgbLabel:SetText(string.format("(R, G, B): (%d, %d, %d)", R, G, B))
		rgbLabel:SizeToContents()
		rgbLabel:SetAutoStretchVertical(true)

        rgbEntry = vgui.Create("DTextEntry", DFrame)
        rgbEntry:SetPos(280, 130)
        rgbEntry:SetSize(100, 20)
        rgbEntry:SetText(string.format("(%d, %d, %d)", R, G, B))
		rgbEntry.OnEnter = function(self)
			local rgbString = self:GetText()
			local r, g, b = rgbString:match("(%d+), (%d+), (%d+)")

			if r and g and b then
				r, g, b = tonumber(r), tonumber(g), tonumber(b)

				if r and g and b and r >= 0 and r <= 255 and g >= 0 and g <= 255 and b >= 0 and b <= 255 then
					DermaColorCombo:SetColor(Color(r, g, b))

					hexLabel:SetText(string.format("Hex: #%02X%02X%02X", r, g, b))
					hexEntry:SetText(string.format("%02X%02X%02X", r, g, b))

					rgbLabel:SetText(string.format("(R, G, B): (%d, %d, %d)", r, g, b))
					rgbEntry:SetText(string.format("(%d, %d, %d)", r, g, b))
				else
					self:SetText(string.format("(%d, %d, %d)", R, G, B))
				end
			else
				self:SetText(string.format("(%d, %d, %d)", R, G, B))
			end
		end

        local function CreateSlider(DFrame, yPos, labelText, conVar, min, max, defaultValue)
            local DermaNumSlider = vgui.Create("DNumSlider", DFrame)
            DermaNumSlider:SetPos(10, yPos)
            DermaNumSlider:SetSize(MainScrW, 70)
            DermaNumSlider:SetText(labelText)
            DermaNumSlider:SetMin(min)
            DermaNumSlider:SetMax(max)
            DermaNumSlider:SetDecimals(1)
            DermaNumSlider:SetValue(GetConVar(conVar):GetFloat())
            DermaNumSlider:SetConVar(conVar)
        end

        DermaNumSliderRemoveType = vgui.Create("DNumSlider", DFrame)
        DermaNumSliderRemoveType:SetPos(10, 440)
        DermaNumSliderRemoveType:SetSize(MainScrW, 70)
        DermaNumSliderRemoveType:SetText("Remove Type")
        DermaNumSliderRemoveType:SetMin(0)
        DermaNumSliderRemoveType:SetMax(2)
        DermaNumSliderRemoveType:SetDecimals(0)
        DermaNumSliderRemoveType:SetValue(paint_manager_remove_type:GetFloat())
        DermaNumSliderRemoveType:SetConVar("paint_manager_remove_type")

        DermaLabelRemoveByLayer = vgui.Create("DLabel", DFrame)
        DermaLabelRemoveByLayer:SetPos(10, 520)
		DermaLabelRemoveByLayer:SetText("Remove by Layer:")
        DermaLabelRemoveByLayer:SizeToContents()

        DermaCheckBoxRemoveByLayer = vgui.Create("DCheckBoxLabel", DFrame)
        DermaCheckBoxRemoveByLayer:SetPos(105, 520)
        DermaCheckBoxRemoveByLayer:SetText("")
        DermaCheckBoxRemoveByLayer:SetValue(paint_remove_by_layer:GetInt())
        DermaCheckBoxRemoveByLayer:SizeToContents()
        DermaCheckBoxRemoveByLayer.OnChange = function(self)
            paint_remove_by_layer:SetInt(self:GetChecked() and 1 or 0)
        end

        CreateSlider(DFrame, 300, "Paint Size", "paint_manager_size", 0.1, 100, 1.5)
        CreateSlider(DFrame, 370, "Paint Layer", "paint_manager_layer", 1, 5, 1)

		local FinishButton = vgui.Create("DButton", DFrame)
		FinishButton:SetText("Finish")
		FinishButton:SetPos((MainScrW - FinishButton:GetWide()) / 2, 550)
		FinishButton.DoClick = function()
			DFrame:Close()
		end

        local removeType = paint_manager_remove_type:GetInt()
        DermaLabelRemoveByLayer:SetVisible(removeType == 1 or removeType == 2)
        DermaCheckBoxRemoveByLayer:SetVisible(removeType == 1 or removeType == 2)
    end

    net.Receive("PaintManager_OPENMENU", function(_, _)
        DrawMenu()
    end)
end
