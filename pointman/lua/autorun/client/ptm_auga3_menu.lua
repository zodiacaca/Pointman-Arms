
local function auga3_options(panel)

	panel:AddControl( "Label", { Text = "Server Settings:" } )

	panel:AddControl( "CheckBox", { Label = "One hit kill for knife?", Command = "AUGA3KnifeOneHit" } )
	
	panel:AddControl( "Label", { Text = "Client Settings:" } )
	
	panel:AddControl( "CheckBox", { Label = "Draw knife automatically?", Command = "AUGA3AutoMelee" } )

end

