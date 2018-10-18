
local function pointman_options(panel)

	panel:AddControl( "Label", { Text = "Server Settings:" } )
	
	panel:CheckBox( "Drop clip while reloading?", "PointmanDropClip" ):SetTooltip( [[ I'm feeling rich : ) ]] )
	
	panel:AddControl( "CheckBox", { Label = "Show rifles on your back?", Command = "PointmanRifleOnBack" } )
	panel:ControlHelp("This requires your player model has the matching attachment.")
	
	panel:AddControl( "CheckBox", { Label = "NPCs use flashlights?", Command = "PointmanNPCFlashlights" } )
	
	panel:AddControl( "CheckBox", { Label = "No friendly hurt? (NPC)", Command = "PointmanNoFriendlyDamage" } )
	
	panel:NumSlider( "Damage Multiplier", "PointmanDamageMultiplier", 0, 10, 1 )
	
	panel:AddControl( "Label", { Text = "Client Settings:" } )
	
	local label_arms = vgui.Create("DLabel")
		label_arms:SetText("Arms:")
		label_arms:SizeToContents()
		label_arms:SetDark(true)		-- dark text color
	panel:AddItem(label_arms)
	local arms = {
		[1] = {"Male Oakley Glove", 0},
		[2] = {"Female Oakley Glove", 1}
		}
	local ComboBox_arms = vgui.Create("DComboBox")
		ComboBox_arms:SetText("Arms")
	for k, v in ipairs(arms) do
		ComboBox_arms:AddChoice(v[1], v[2])
	end
	for k, v in pairs(arms) do
		if (GetConVarNumber("PointmanVMArms") == v[2]) then
			ComboBox_arms:ChooseOption(v[1])			-- initial it to your current choice
		end
	end
	ComboBox_arms.OnSelect = function(panel, index, value, data)
		RunConsoleCommand("PointmanVMArms", data)
	end
	panel:AddItem(ComboBox_arms)
	panel:ControlHelp("Restart to take effect.")
	
	local label_hands = vgui.Create("DLabel")
		label_hands:SetText("Glove Color:")
		label_hands:SizeToContents()
		label_hands:SetDark(true)
	panel:AddItem(label_hands)
	local hands = {
		[1] = {"Tan", 0},
		[2] = {"Green", 1},
		[3] = {"White", 2},
		[4] = {"Black", 3}
		}
	local ComboBox_hands = vgui.Create("DComboBox")
		ComboBox_hands:SetText("Glove Color")
	for k, v in ipairs(hands) do
		ComboBox_hands:AddChoice(v[1], v[2])
	end
	for k, v in pairs(hands) do
		if (GetConVarNumber("PointmanVMHands") == v[2]) then
			ComboBox_hands:ChooseOption(v[1])
		end
	end
	ComboBox_hands.OnSelect = function(panel, index, value, data)
		RunConsoleCommand("PointmanVMHands", data)
		local ply = LocalPlayer()
		if not IsValid(ply) then return end
		local wep = ply:GetActiveWeapon()
		if not IsValid(wep) then return end
		
		local vm = ply:GetViewModel()
		if not IsValid(vm) then return end
		local mats = vm:GetMaterials()
		local index = nil
		for k, v in pairs(mats) do
			if string.find( v, "glove", 1, false ) then
				index = k
			end
		end

		if index then
			if data == 0 then
				vm:SetSubMaterial( index - 1, nil )
			elseif data == 1 then
				vm:SetSubMaterial( index - 1, "models/weapons/ptm/hands/glove_green" )
			elseif data == 2 then
				vm:SetSubMaterial( index - 1, "models/weapons/ptm/hands/glove_white" )
			else
				vm:SetSubMaterial( index - 1, "models/weapons/ptm/hands/glove_black" )
			end
		end
		
	end
	panel:AddItem(ComboBox_hands)
	
	panel:AddControl( "Slider", { label = "View bob Multiplier", Command = "PointmanViewBobMultiplier", Type = "Float", Min = "0", Max = "2" } )
	
	panel:AddControl( "Slider", { label = "Lean Angle Multiplier", Command = "PointmanLeanAngleMultiplier", Type = "Float", Min = "0", Max = "2" } )
	
	panel:AddControl( "Label", { Text = "" } )
	panel:AddControl( "Label", { Text = "Compatibility:" } )
	local rmv_btn = vgui.Create( "DButton" )
	rmv_btn:SetText( "Remove CalcView hooks" )
	rmv_btn.DoClick = Pointman_RemoveHooks
	panel:AddPanel(rmv_btn)
	local add_btn = vgui.Create( "DButton" )
	add_btn:SetText( "Add back CalcView hooks" )
	add_btn.DoClick = Pointman_AddHooks
	panel:AddPanel( add_btn )
	
end

hook.Add("PopulateToolMenu", "PointmanAddOptions", function()

	spawnmenu.AddToolMenuOption("Options", "Pointman Arms", "pointman_options", "[Settings]", "", "", pointman_options)
	
end)


local CalcViewTable = {}
local CalcVMViewTable = {}

local function Pointman_RemoveHooks()

	for k, v in pairs(hook.GetTable()["CalcView"]) do
		if k != "Pointman CalcView" then
			local mod = { name = k, fn = v }
			table.insert( CalcViewTable, mod )
		end
	end
	for k, v in pairs(hook.GetTable()["CalcViewModelView"]) do
		local mod = { name = k, fn = v }
		table.insert( CalcVMViewTable, mod )
	end
	
	for k, v in pairs(CalcViewTable) do
		hook.Remove( "CalcView", v.name )
	end
	for k, v in pairs(CalcVMViewTable) do
		hook.Remove( "CalcViewModelView", v.name )
	end
	print(table.ToString(CalcViewTable).." have been removed temporarily.")
	print(table.ToString(CalcVMViewTable).." have been removed temporarily.")
	
end

local function Pointman_AddHooks()
	
	for k, v in pairs(CalcViewTable) do
		hook.Add( "CalcView", v.name, v.fn )
	end
	CalcViewTable = {}
	for k, v in pairs(CalcVMViewTable) do
		hook.Add( "CalcViewModelView", v.name, v.fn )
	end
	CalcVMViewTable = {}
	
end
