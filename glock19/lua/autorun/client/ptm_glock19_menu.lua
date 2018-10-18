

local function golck19_options(panel)

	panel:AddControl( "CheckBox", { Label = "Auto change FOV?", Command = "Glock19AutoChangeFOV" } )
	panel:ControlHelp("NOTE: Auto change back will not work if you get killed or weapon has been removed or leave game")

end

hook.Add("PopulateToolMenu", "Glock19AddOptions", function()

	spawnmenu.AddToolMenuOption("Options", "Pointman Arms", "golck19_options", "Glock 19", "", "", golck19_options)
	
end)

