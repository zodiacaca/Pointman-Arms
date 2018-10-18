
EFFECT.Mat = Material( "effects/spark" ) 
/*---------------------------------------------------------
   EFFECT:Init(data)
---------------------------------------------------------*/
function EFFECT:Init(data)

	self.StartPos 	= data:GetStart()	
	self.EndPos 	= data:GetOrigin()
	self.Dir 		= self.EndPos - self.StartPos
	self.Entity:SetRenderBoundsWS(self.StartPos, self.EndPos)

	// Die when it reaches its target
	self.DieTime 	= CurTime() + 0.2

end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think()

	if (CurTime() > self.DieTime) then return false end

	return true

end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()

	local a = (self.DieTime - CurTime())/0.2
	a = math.Clamp(a, 0, 1)

	local color = Color(255, 0, 0, 255 * a)
	render.SetMaterial(self.Mat)
 	render.DrawBeam(self.StartPos, self.EndPos, 8 * a, 0, 1, color)

end

