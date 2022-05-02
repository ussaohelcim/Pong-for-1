---Get a normalized vector pointing to an angle
---@param angle number in radians
function AngleToNormalizedVector(angle)
	return { 
		x = math.cos(angle),
		y = math.sin(angle)
	}
end
---Get the angle from the origin to a point
---@param x number x property of a vector2
---@param y number y property of a vector2
---@return number
function Vec2angle(x,y)
	return math.atan(y,x)
end

function DistanceFromPoints(v1, v2)
	return math.sqrt((v1.x - v2.x)*(v1.x - v2.x) + (v1.y - v2.y)*(v1.y - v2.y))
end