------------------------- BSD License  -----------------------
-- Copyright (c) 2013, Creative Tools AB
-- All rights reserved.

-- Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

--  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
--  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
-- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
-- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
-- LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--------------------------------------------------------------


rollout fGBarbShapeRollout "Barb Length"(
	CurveControl c   ""  numCurves:1 x_range:[0,1] y_range:[ 0,1] scrollValues:[-15,-45]  zoomValues:[310,140] uiFlags:#(#constrainY, #drawBG, #upperToolbar, #xvalue,#drawgrid)
	on fGBarbShapeRollout open do (
		insertPoint c.curves[1] 2 (ccPoint [0.6,0.6] [0.0,0.0] [0.0,0.0] bezier:false corner:true)
		c.curves[1].points[1].value = [0,0.8]
		c.curves[1].points[3].value = [1,0.0]
	)
)
rollout fGBarbShapeVariationRollout "Barb Length Variation"(
	CurveControl c   ""  numCurves:1 x_range:[0,1] y_range:[ 0,1] scrollValues:[-15,-45]  zoomValues:[310,140] uiFlags:#(#constrainY, #drawBG, #upperToolbar, #xvalue,#drawgrid)
	on fGBarbShapeVariationRollout open do (
		c.curves[1].points[1].value = [0,0.2]
		c.curves[1].points[2].value = [0,0.1]
	)
)
rollout fGBarbAngleRollout "Barb Angle"(
	CurveControl c   ""   numCurves:1 x_range:[0,1] y_range:[-1,1] scrollValues:[-15,0]   zoomValues:[310,80]  uiFlags:#(#constrainY, #drawBG, #upperToolbar, #xvalue,#drawgrid)
	on fGBarbAngleRollout open do (
		c.curves[1].points[1].value = [0,0.4]
		c.curves[1].points[2].value = [0,0.4]
	)
)
rollout fGBarbBendRollout "Barb Bend"(
	CurveControl c   ""   numCurves:1 x_range:[0,1] y_range:[ 0,1] scrollValues:[-15,-45]  zoomValues:[310,140] uiFlags:#(#constrainY, #drawBG, #upperToolbar, #xvalue,#drawgrid)
)
rollout fGBarbNoiseRollout "Barb Noise"(
	CurveControl c   ""   numCurves:1 x_range:[0,1] y_range:[ 0,1] scrollValues:[-15,-45]  zoomValues:[310,140] uiFlags:#(#constrainY, #drawBG, #upperToolbar, #xvalue,#drawgrid)
	on fGBarbNoiseRollout open do (
		c.curves[1].points[1].value = [0,0.2]
		c.curves[1].points[2].value = [0,0.1]
	)
)
rollout fGBarbFrizzRollout "Barb Frizz"(
	CurveControl c   ""   numCurves:1 x_range:[0,1] y_range:[ 0,1] scrollValues:[-15,-45]  zoomValues:[310,140] uiFlags:#(#constrainY, #drawBG, #upperToolbar, #xvalue,#drawgrid)
	on fGBarbFrizzRollout open do (
		c.curves[1].points[1].value = [0,0.4]
		c.curves[1].points[2].value = [0,0.1]
	)
)

rollout featherGeneratorRollout "Creative Tools Feather Generator"
(
	Button uiGenerate          "Generate"
	Spinner uiRandomSeed       "Random Seed"    range:[1, 10000, 8971] type:#integer
	Spinner uiFeatherLength    "Feather Length" range:[0.1, 1000.0, 100.0]
	Spinner uiFeatherWidth     "Feather Width"  range:[0.1, 1000.0, 30.0]
	Spinner uiBarbDetails      "Barb Details" type:#integer range:[1,50,4]
	Spinner uiBarbCount      "Barb Count" type:#integer range:[1,5000,50]
	Spinner uiCalamusLength    "Calamus Length" range:[0.001,100.0,30.0]
	
	function getBarbPoint yPos bendAngle bendBackAngle len side barbNoise= (
		local z = len * sin(bendBackAngle)
		local xyLen = len * cos(bendBackAngle)
		local x  = xyLen * cos(bendAngle)
		local y  = xyLen * sin(bendAngle) + yPos
		if side == 2 then (
			x = -x
		)
		local tmpX = x*0.15
		local tmpY = y*0.15
		x += barbNoise * (noise3 [tmpX, tmpY, side*549.365 + 23.451])
		y += barbNoise * (noise3 [tmpX, tmpY, side*349.647 + 975.167])
		z += barbNoise * (noise3 [tmpX, tmpY, side*874.849 + 135.146])
		return [y,x,z]
	)
	
	function generate = (
		local prevPanel = getCommandPanelTaskMode()
		setCommandPanelTaskMode #create
		seed uiRandomSeed.value
		local featherLength = uiFeatherLength.value
		local featherWidth  = uiFeatherWidth.value
		local rachis = line()
		local barbs  = line()
		delete $Rachis*
		delete $Barbs*
		rachis.name = "Rachis"
		barbs.name  = "Barbs"
		addNewSpline rachis
		local barbIndex   = 0
		local barbSpacing = 1.0/uiBarbCount.value
		select rachis
		selectMore  barbs
		local calamusLenght = uiCalamusLength.value
		local p = -calamusLenght
		while p < 0 do(
			addKnot rachis 1 #smooth #curve [p,0,0]
			p += barbSpacing * featherLength
		)
		for side=1 to 2 do(
			local barbPos     = 0.0
			local barbEnd     = 1.0
			local barbDetail  = uiBarbDetails.value
			local barbStep    = 1.0/barbDetail
			while barbPos < barbEnd do (
				local barbAngle   = (getValue fGBarbAngleRollout.c.curves[1] 0 barbPos) * 90
				local l           = getValue fGBarbShapeRollout.c.curves[1] 0 barbPos
				local l_variation = getValue fGBarbShapeVariationRollout.c.curves[1] 0 barbPos
				l                += l * (random -l_variation l_variation) * 0.5
				local barbRandom  = getValue fGBarbFrizzRollout.c.curves[1] 0 barbPos
				barbRandom       *= 0.2
				local bendAngle   = getValue fGBarbBendRollout.c.curves[1] 0 barbPos
				bendAngle        += random -barbRandom barbRandom
				bendAngle        *= 90
				local bendBack   = 0
				local angleBack   = 0
				local barbNoise   = (getValue fGBarbNoiseRollout.c.curves[1] 0 barbPos) * 6
				if side == 1 then (
					addKnot rachis 1 #smooth #curve [barbPos*featherLength,0,0]
				)
				if l > 0.0 then(
					addNewSpline barbs
					barbIndex += 1
					addKnot barbs barbIndex #smooth #curve [barbPos*featherLength,0,0]
					local barbY = barbPos*featherLength
					for i=1 to barbDetail do (
						local val = i*barbStep
						local bendVal = bendAngle * val
						bendVal += 100 * (random -barbRandom barbRandom)
						bendVal += barbAngle
						local bendBackVal = bendBack * val
						bendBackVal += 100 * (random -barbRandom barbRandom)
						bendBackVal += angleBack
						local len = featherWidth*l*val
						local p = getBarbPoint barbY bendVal bendBackVal len side barbNoise
						addKnot barbs barbIndex #smooth #curve p
					)
				)
				barbPos += barbSpacing
			)
		)
		setCommandPanelTaskMode prevPanel
	)
		
	on uiGenerate pressed do(
		generate()
	)
)

featherFloater = newRolloutFloater "CT Feather Generator" 400 800 
addRollout featherGeneratorRollout featherFloater
addRollout fGBarbShapeRollout featherFloater rolledUp:true
addRollout fGBarbShapeVariationRollout featherFloater rolledUp:true
addRollout fGBarbAngleRollout featherFloater rolledUp:true
addRollout fGBarbBendRollout featherFloater rolledUp:true
addRollout fGBarbNoiseRollout featherFloater rolledUp:true
addRollout fGBarbFrizzRollout featherFloater rolledUp:true
