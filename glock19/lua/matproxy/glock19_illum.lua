
local float = 0

matproxy.Add(
{
	name = "Glock19Illumination",

	init 	= function( self, mat, values )

		self.ResultTo = values.resultvar

	end,

	bind	=	function( self, mat, ent )

		if ( !IsValid( ent ) ) then return end
		
		local envlight = (render.ComputeLighting(ent:GetPos(), Vector(0, 0, 1)) + render.ComputeDynamicLighting(ent:GetPos(), Vector(0, 0, 1))):Length()
		
		if envlight > float then
			float = envlight		-- charged in no time
		else
			float = float - 0.0001 * FrameTime()		-- slowly attenuate
		end
		float = math.Clamp(float, 0, 0.22)
		
		mat:SetFloat( "$detailblendfactor", float )		-- control the illumination brightness

	end
})
