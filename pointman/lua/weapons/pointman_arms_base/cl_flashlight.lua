

function SWEP:CreateLight()

	if !self.Lighted and self.LightState then

		local pos = self.Owner:GetViewModel():GetAttachment(1).Pos
		local ang = self.Owner:GetViewModel():GetAttachment(1).Ang

		ptmFlashlight = {}
		-- main
		ptmFlashlight.Main = ProjectedTexture()
		ptmFlashlight.Main:SetPos( pos + ang:Forward() * self.LightOffset.x + ang:Right() * self.LightOffset.y + ang:Up() * self.LightOffset.z )
		ptmFlashlight.Main:SetAngles( ang )
		ptmFlashlight.Main:SetBrightness( self.LightBrightness )
		ptmFlashlight.Main:SetFarZ( self.LightFarZ )
		ptmFlashlight.Main:SetFOV( self.LightFOV )
		if self.Weapon:GetNWFloat("Suppressor") == 1 then
			ptmFlashlight.Main:SetTexture( self.LightTextureSuppressed )
		else
			ptmFlashlight.Main:SetTexture( self.LightTexture )
		end
		ptmFlashlight.Main:Update()

		-- env
		ptmFlashlight.Env = ProjectedTexture()
		ptmFlashlight.Env:SetPos( pos + ang:Forward() * (self.LightOffset.x - 16) + ang:Right() * self.LightOffset.y + ang:Up() * self.LightOffset.z )
		ptmFlashlight.Env:SetAngles( ang )
		ptmFlashlight.Env:SetBrightness( 0.05 )
		ptmFlashlight.Env:SetFarZ( 1024 )
		ptmFlashlight.Env:SetFOV( 4096 )
		ptmFlashlight.Env:SetEnableShadows( false )
		ptmFlashlight.Env:SetTexture( "effects/pointman_flashlight_env" )
		ptmFlashlight.Env:Update()

		self.Lighted = true

	else

		if ptmFlashlight != nil then

			for k, v in pairs(ptmFlashlight) do

				if IsValid(v) then

					v:Remove()

				end

			end
			ptmFlashlight = nil

		end

		self.Lighted = false

	end

end

