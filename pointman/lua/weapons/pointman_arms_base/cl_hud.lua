

SWEP.InputValue = {}

--[[---------------------------------------------------------
	HUD
-----------------------------------------------------------]]
function SWEP:HUDShouldDraw(str)

	if str != "CHudHealth" and str != "CHudBattery" and str != "CHudAmmo" then

		return true

	end

end

function SWEP:DoDrawCrosshair(x, y)
	return true
end

function SWEP:DrawHUDBackground()

	self:SendAimInfo()

end

function SWEP:DrawHUD()

	if not IsValid(self.Weapon) then return end
	if not IsValid(self.Owner) then return end

	self:DrawTunnel()

	if !GetConVar("cl_drawhud"):GetBool() then return end
	self:HUD()
	local mul = GetConVarNumber("PointmanDebugMultiply")
	if mul != 0 then
		for k, v in pairs(self.InputValue) do
			if self.InputValue[k] != nil then
				self.InputValue[k] = self.InputValue[k] * mul
				self:Graph(k, mul)
			end
		end
	end

end

local ampMat = Material( "hud/pjt_drn_amplitude" )
local ampInvertMat = Material( "hud/pjt_drn_amplitude_invert" )

local values = { [1] = {}, [2] = {}, [3] = {} }
local graphLength = 300

for k, v in pairs(values) do

	for i = 1, graphLength do

		values[k][i] = 0

	end
	
end

function SWEP:Graph(num, mul)

	local y = ScrH()/2 - 100 + (num - 1) * 200

	local unit = 3

	surface.SetDrawColor(0, 100, 255, 100)
	surface.DrawLine(1, y, graphLength * unit + 1, y)

	values[num][1] = self.InputValue[num]

	surface.SetFont( "HudHintTextLarge" )
	surface.SetTextColor( 250, 200, 0, 255 )
	surface.SetTextPos( graphLength * unit, y )
	surface.DrawText(values[num][1] / mul)

	for v = 1, graphLength do

		local x = v * unit

		if values[num][v] >= 0 then
			surface.SetMaterial( ampInvertMat )
			surface.DrawTexturedRect( x, y - values[num][v] + 1, 3, values[num][v] )
		else
			surface.SetMaterial( ampMat )
			surface.DrawTexturedRect( x, y, 3, -values[num][v] )
		end

	end

	local valuesCopy = table.Copy( values[num] )
	for i = 2, graphLength do

		values[num][i] = valuesCopy[i-1]

	end

end

function SWEP:DrawTunnel()

	-- draw tunnel for open door action
	if CurTime() - self.LastUse < self.InteractDuration + 2 and CurTime() - self.LastUse > self.InteractDuration then
		surface.SetTexture(surface.GetTextureID("hud/ptm_tunnel"))
		surface.SetDrawColor( Color( 255, 255, 255, 255 * (1 - (CurTime() - self.LastUse - self.InteractDuration)/2) ) )
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	elseif CurTime() - self.LastUse <= self.InteractDuration then
		surface.SetTexture(surface.GetTextureID("hud/ptm_tunnel"))
		surface.SetDrawColor( Color( 255, 255, 255, 255 * (CurTime() - self.LastUse)/self.InteractDuration ) )
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	end

end

-- local nextFT = 0
-- local displayFT = 0

SWEP.HUDElements = {
	["Background"] = Vector(32, -38.72, 11.364),
	["Frame"] = Vector(32, -38.8, 14),
	["Health"] = Vector(32, -35.4, 15.82),
	["Speed"] = Vector(32, -38.8, 13.12),
	["Rate"] = Vector(32, -38.8, 12.92),
	["Stamina"] = Vector(32, -34.4, 12.36),
	["Camera"] = Vector(32, 32, 15.6),
	["TextStamina"] = Vector(32, -35.28, 14.52),
	["TextClip"] = Vector(32, -28.5, 16),
	["TextAmmo"] = Vector(32, -26.5, 15.9)
}

function SWEP:GetHUDElementPosition(pos, element, forward, right, up)

	local offset = pos + self.HUDElements[element].x * forward + self.HUDElements[element].y * right + self.HUDElements[element].z * up

	return offset

end

function SWEP:HUD()

	if self.Owner:ShouldDrawLocalPlayer() or !self.FixedPos then return end

	local pos = self.FixedPos
	local ang = self.Owner:EyeAngles() + self.CalcViewAng or Angle(0, 0, 0)
	ang = ang + self.Owner:GetViewPunchAngles()
	local forward = ang:Forward()
	local right = ang:Right()
	local up = ang:Up()
	ang:RotateAroundAxis(ang:Up(), 7.4)
	ang:RotateAroundAxis(ang:Right(), 90)
	ang:RotateAroundAxis(ang:Forward(), 0)

	local envlight = (render.ComputeLighting(self.Owner:EyePos(), Vector(0, 0, 1)) + render.ComputeDynamicLighting(self.Owner:EyePos(), Vector(0, 0, 1))):Length()

	cam.Start3D()

		-- background
		cam.Start3D2D(self:GetHUDElementPosition(pos, "Background", forward, right, up), ang, 1)

			surface.SetTexture(surface.GetTextureID("hud/ptm_background"))
			surface.SetDrawColor( Color( 255, 255, 255, 200 + 55 * math.sin(CurTime()) ) )
			local u = -CurTime()/10
			local v = math.sin(CurTime()/10)
			surface.DrawTexturedRectUV(2, -1, 5, 15, u, v, u + 0.3, v + 0.9)

		cam.End3D2D()

		-- frame
		cam.Start3D2D(self:GetHUDElementPosition(pos, "Frame", forward, right, up), ang, 1)

			surface.SetTexture(surface.GetTextureID("hud/ptm_hud"))
			surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
			surface.DrawTexturedRectUV(0, 0, 4, 14, 0.16, 0, 0.5, 1)

		cam.End3D2D()

		-- health
		cam.Start3D2D(self:GetHUDElementPosition(pos, "Health", forward, right, up), ang, 0.8)

			surface.SetTexture(surface.GetTextureID("hud/ptm_hud"))
			surface.SetDrawColor( Color( 255, 255, 255, 200 ) )
			if self.Owner:Health() > 95 then
				surface.DrawTexturedRectUV(0, 1, 2, 4, 0, 0, 0.12, 0.2)
			elseif self.Owner:Health() > 80 then
				surface.DrawTexturedRectUV(0, 1, 2, 5, 0, 0.2, 0.12, 0.5)
			elseif self.Owner:Health() > 20 then
				surface.DrawTexturedRectUV(0, 1, 2, 5, 0, 0.5, 0.12, 0.8)
			else
				surface.DrawTexturedRectUV(0, 2, 2, 4, 0, 0.8, 0.12, 1)
			end

		cam.End3D2D()

		-- speed
		cam.Start3D2D(self:GetHUDElementPosition(pos, "Speed", forward, right, up), ang, 1)

			surface.SetDrawColor( Color( 255, 255, 255, 220 ) )
			if self.Owner:KeyDown(IN_SPEED) and self.Owner:GetAbsVelocity():Length() > 130 then
				surface.DrawTexturedRectUV(0, 7, 2, 4, 0.5, 0.8, 0.6, 1)
			elseif !self.Owner:KeyDown(IN_WALK) then
				surface.DrawTexturedRectUV(0, 6, 2, 4, 0.5, 0.5, 0.6, 0.7)
			else
				surface.DrawTexturedRectUV(0, 7, 2, 4, 0.5, 0.3, 0.6, 0.5)
			end

		cam.End3D2D()

		-- rate
		cam.Start3D2D(self:GetHUDElementPosition(pos, "Rate", forward, right, up), ang, 1)

			surface.SetDrawColor( Color( 255, 255, 255, 50 ) )
			surface.SetTexture(surface.GetTextureID("hud/ptm_text"))
			surface.DrawTexturedRectUV(0, 0, 3, 15, 0.1, 0, 0.32, 1)

			surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
			if self.Primary.Automatic then
				surface.DrawTexturedRectUV(0, 3, 3, 12, 0.12, 0.2, 0.32, 1)
			else
				surface.DrawTexturedRectUV(0, 0, 3, 3, 0.12, 0, 0.32, 0.2)
			end

		cam.End3D2D()

		-- stamina
		cam.Start3D2D(self:GetHUDElementPosition(pos, "Stamina", forward, right, up), ang, 1)

			surface.SetDrawColor( Color( 255, 255, 255, 140 ) )
			surface.SetTexture(surface.GetTextureID("hud/ptm_text"))
			surface.DrawTexturedRectUV(0, 0, 2, 1, 0.62, 0.54, 0.82, 0.64)

		cam.End3D2D()

		local ang2 = self.Owner:EyeAngles()
		ang2 = ang2 + self.Owner:GetViewPunchAngles()
		local forward2 = ang2:Forward()
		local right2 = ang2:Right()
		local up2 = ang2:Up()
		ang2:RotateAroundAxis(ang2:Forward(), -0.6)
		ang2:RotateAroundAxis(ang2:Up(), 180 - 19)
		ang2:RotateAroundAxis(ang2:Right(), 90)

		-- cam
		cam.Start3D2D(self:GetHUDElementPosition(pos, "Camera", forward2, right2, up2), ang2, 0.8)

			surface.SetTexture(surface.GetTextureID("hud/ptm_nosignal"))
			surface.SetDrawColor( Color( 255, 255, 255, 220) )
			surface.DrawTexturedRectUV(0, 0, 2, 6, 0.8, 0, 1, 0.6)

		cam.End3D2D()

		-- texts
		-- stamina
		ang:RotateAroundAxis(ang:Up(), -90)
		ang:RotateAroundAxis(ang:Right(), -2)

		local stm_dsp = math.floor((2750 - self.Stamina)/2750 * 100)
		cam.Start3D2D(self:GetHUDElementPosition(pos, "TextStamina", forward, right, up), ang, 0.06)

			surface.SetFont( "Default" )
			surface.SetTextColor( 250, 200, 0, 155 )
			surface.SetTextPos( 0, 0 )
			surface.DrawText(stm_dsp)

		cam.End3D2D()

		-- clip
		cam.Start3D2D(self:GetHUDElementPosition(pos, "TextClip", forward, right, up), ang, 0.1)

			surface.SetFont( "Default" )
			surface.SetTextColor( 250, 200, 0, 155 )
			surface.SetTextPos( 0, 0 )
			surface.DrawText(self:Clip1())
			-- // display frame time
			-- if CurTime() > nextFT then
				-- displayFT = 1/FrameTime()
				-- nextFT = CurTime() + 0.5
			-- end
			-- surface.DrawText(displayFT)

		cam.End3D2D()

		-- ammo
		cam.Start3D2D(self:GetHUDElementPosition(pos, "TextAmmo", forward, right, up), ang, 0.1)

			surface.SetFont( "Default" )
			surface.SetTextColor( 250, 200, 0, 155 )
			surface.SetTextPos( 0, 0 )
			surface.DrawText(self:Ammo1())

		cam.End3D2D()

	cam.End3D()

end

