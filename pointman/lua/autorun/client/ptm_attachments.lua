

surface.CreateFont( "ptm_DavilleCondensedSlanted", {
	font = "Daville Condensed Slanted",
	extended = false,
	size = 18,
	weight = 1000,
	blursize = 0,
	scanlines = 2,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
} )

surface.CreateFont( "ptm_DavilleCondensedSlanted_small", {
	font = "Daville Condensed Slanted",
	extended = false,
	size = 16,
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )


pointman_menu = nil
pointman_frame = {}

function pointman_custom_panel()

	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	local wep = ply:GetActiveWeapon()
	if not IsValid(wep) then return end
	if wep.Base == nil then return end
	if wep.Base != "pointman_arms_base" then return end
	local vm = ply:GetViewModel()
	if not IsValid(vm) then return end

	local pos, ang = vm:GetAttachment(1).Pos, vm:GetAttachment(1).Ang
	local x, y
	if pos:ToScreen().visible then
		x, y = pos:ToScreen().x, pos:ToScreen().y
	else
		x, y = ScrW()/2 + 100, ScrH()/2 + 100
	end
	
	pointman_menu = vgui.Create( "DFrame" )
	pointman_menu:SetPos( x + wep.MenuOffset.x, y + wep.MenuOffset.y )
	pointman_menu:SetSize( 1000, 1000 )
	pointman_menu:SetTitle( "" )
	pointman_menu:SetVisible( true )
	pointman_menu:SetDraggable( false )
	pointman_menu:SetSizable( false )
	pointman_menu:SetIsMenu( true )
	pointman_menu:ShowCloseButton( false )
	pointman_menu:MakePopup()
	
	pointman_frame = { ["Label"] = {}, ["Button"] = {}, ["Underline"] = {} }

	for num, att in pairs(wep.Attachments) do

		local number = tonumber(num)

		pointman_frame["Label"][number] = vgui.Create( "DLabel", pointman_menu )
		pointman_frame["Label"][number]:SetText( att["Name"]..":" )
		pointman_frame["Label"][number]:SetFont( "ptm_DavilleCondensedSlanted" )
		pointman_frame["Label"][number]:SetColor( Color( 255, 255, 255 ) )
		pointman_frame["Label"][number]:SetPos( 0, number * 40 )
		pointman_frame["Label"][number]:SetSize( 100, 28 )
		pointman_frame["Label"][number].Paint = function()
		end
		pointman_frame["Button"][number] = {}
		for tag, mode in pairs(att["Mode"]) do

			pointman_frame["Button"][number][mode + 1] = vgui.Create( "DButton", pointman_menu )
			pointman_frame["Button"][number][mode + 1]:SetText( tag )
			pointman_frame["Button"][number][mode + 1]:SetFont( "ptm_DavilleCondensedSlanted_small" )
			pointman_frame["Button"][number][mode + 1]:SetTextColor( Color( 0, 255, 255 ) )
			pointman_frame["Button"][number][mode + 1]:SetPos( (mode + 1) * 100, number * 40 )
			pointman_frame["Button"][number][mode + 1]:SetSize( 80, 28 )
			pointman_frame["Button"][number][mode + 1].DoClick = function()
				if !wep:GetNWBool( "DoingSequence" ) then
					if att["Children"] != nil then
						for i = 1, table.Count(wep.Attachments[att["Children"]]["Mode"]) do
							if mode == 1 then
								pointman_frame["Button"][att["Children"]][i].Paint = function()
									surface.SetDrawColor( 0, 160, 230, 200 )
									surface.DrawRect( 0, 0, pointman_frame["Button"][att["Children"]][i]:GetWide(), pointman_frame["Button"][att["Children"]][i]:GetTall() )
								end
							else
								pointman_frame["Button"][att["Children"]][i].Paint = function()
									surface.SetDrawColor( 0, 160, 230, 50 )
									surface.DrawRect( 0, 0, pointman_frame["Button"][att["Children"]][i]:GetWide(), pointman_frame["Button"][att["Children"]][i]:GetTall() )
								end
							end
						end
					end
					if att["Bodygroup"] != nil then
						vm:SetBodygroup( att["Bodygroup"], mode )
					end
					if wep:GetNWFloat( att["Name"] ) != mode then
						if att["Sound"] != nil then
							wep:EmitSound( att["Sound"] )
						end
					end
					net.Start( "pointman_custom"..ply:EntIndex() )
						net.WriteString( att["Name"] )
						net.WriteFloat( mode )
					net.SendToServer()
					pointman_frame["Underline"][number]:SetPos( (mode + 1) * 100, number * 40 + 27 )
				end
			end
			pointman_frame["Button"][number][mode + 1].Paint = function()
				if att["Parent"] != nil and wep:GetNWFloat( att["Parent"] ) < 1 then
					surface.SetDrawColor( 0, 150, 255, 50 )
				else
					surface.SetDrawColor( 0, 150, 255, 200 )
				end
				surface.DrawRect( 0, 0, pointman_frame["Button"][number][mode + 1]:GetWide(), pointman_frame["Button"][number][mode + 1]:GetTall() )
			end

			if wep:GetNWFloat( att["Name"] ) == mode then
				pointman_frame["Underline"][number] = vgui.Create( "DLabel", pointman_menu )
				pointman_frame["Underline"][number]:SetText( "" )
				pointman_frame["Underline"][number]:SetPos( (mode + 1) * 100, number * 40 + 27 )
				pointman_frame["Underline"][number]:SetSize( 80, 3 )
				pointman_frame["Underline"][number].Paint = function()
					surface.SetDrawColor( 0, 255, 0, 200 )
					surface.DrawRect( 0, 0, pointman_frame["Underline"][number]:GetWide(), pointman_frame["Underline"][number]:GetTall() )
				end
			end

		end

	end

	-- mask
	local count = table.Count(wep.Attachments)
	pointman_frame["Label"][count + 1] = vgui.Create( "DLabel", pointman_menu )
	pointman_frame["Label"][count + 1]:SetText( "Gasmask:" )
	pointman_frame["Label"][count + 1]:SetFont( "ptm_DavilleCondensedSlanted" )
	pointman_frame["Label"][count + 1]:SetColor( Color( 255, 255, 255 ) )
	pointman_frame["Label"][count + 1]:SetPos( 0, (count + 1)  * 40 )
	pointman_frame["Label"][count + 1]:SetSize( 100, 28 )
	pointman_frame["Label"][count + 1].Paint = function()
	end
	pointman_frame["Button"][count + 1] = vgui.Create( "DButton", pointman_menu )
	pointman_frame["Button"][count + 1]:SetText( "On" )
	pointman_frame["Button"][count + 1]:SetFont( "ptm_DavilleCondensedSlanted_small" )
	pointman_frame["Button"][count + 1]:SetTextColor( Color( 0, 255, 255 ) )
	pointman_frame["Button"][count + 1]:SetPos( 100, (count + 1) * 40 )
	pointman_frame["Button"][count + 1]:SetSize( 80, 28 )
	pointman_frame["Button"][count + 1].DoClick = function()
		wep:SetNWBool("Gasmask", !wep:GetNWBool("Gasmask"))
		ply:EmitSound("weapons/pointman/common/cloth3.wav", 100, math.Rand(100,105) * GetConVarNumber("host_timescale"), 1, CHAN_WEAPON)
	end
	pointman_frame["Underline"][count + 1] = vgui.Create( "DLabel", pointman_menu )
	pointman_frame["Underline"][count + 1]:SetText( "" )
	pointman_frame["Underline"][count + 1]:SetPos( 100, (count + 1) * 40 + 27 )
	pointman_frame["Underline"][count + 1]:SetSize( 80, 3 )
	pointman_frame["Underline"][count + 1].Paint = function()
	end
	pointman_frame["Button"][count + 1].Paint = function()
		if wep:GetNWBool("Gasmask") then
			pointman_frame["Underline"][count + 1].Paint = function()
				surface.SetDrawColor( 0, 255, 0, 200 )
				surface.DrawRect( 0, 0, pointman_frame["Underline"][count + 1]:GetWide(), pointman_frame["Underline"][count + 1]:GetTall() )
			end
			surface.SetDrawColor( 0, 150, 255, 200 )
		else
			pointman_frame["Underline"][count + 1].Paint = function()
			surface.SetDrawColor( 0, 255, 0, 0 )
			surface.DrawRect( 0, 0, pointman_frame["Underline"][count + 1]:GetWide(), pointman_frame["Underline"][count + 1]:GetTall() )
			end
			surface.SetDrawColor( 0, 150, 255, 50 )
		end
		surface.DrawRect( 0, 0, pointman_frame["Button"][count + 1]:GetWide(), pointman_frame["Button"][count + 1]:GetTall() )
	end

end


local function open_pointman_panel()

	if pointman_menu == nil then
		pointman_custom_panel()
		if pointman_menu != nil then
			pointman_menu.Paint = function()
				surface.SetDrawColor( 0, 0, 0, 0 )
				surface.DrawRect( 0, 0, pointman_menu:GetWide(), pointman_menu:GetTall() )
			end
		end
	end

end
concommand.Add( "+pointman", open_pointman_panel )

local function close_pointman_panel()

	if pointman_menu != nil then
		pointman_menu:Close()
		pointman_menu = nil
		pointman_frame = { ["Label"] = {}, ["Button"] = {}, ["Underline"] = {} }
	end

end
concommand.Add( "-pointman", close_pointman_panel )

hook.Add( "KeyPress", "Pointman KeyPress", function( ply, key )

	if key == IN_ZOOM then			-- override ZOOM key
		ply:ConCommand( "+pointman" )
	end

end )

hook.Add( "KeyRelease", "Pointman KeyRelease", function( ply, key )

	if key == IN_ZOOM then
		ply:ConCommand( "-pointman" )
	end

end )

function Pointman_RenderScreenspaceEffects()

	if pointman_menu != nil then
		DrawToyTown( 1, ScrH() )		-- blur out background
	end

end
hook.Add("RenderScreenspaceEffects", "Pointman RenderScreenspaceEffects", Pointman_RenderScreenspaceEffects)

