import "CoreLibs/graphics"
import "mathHelper"

local player = {
	y = 120,
	x = 0,
	w = 10,
	h = 50,
	v = 5,
	combo = 1
}
local ball = {
	x = 200,
	y = 120,
	dx = 0,
	dy = 0,
	v = 5,
	r = 5
}
local screen = {
	w = playdate.display.getWidth(),
	h = playdate.display.getHeight()
}

local badParticles = {}
local goodParticles = {}

local enemy = {
	x = 200,
	y = 120,
	s = 5, --speed
	d = 1, --distance
	a = math.rad(30),
	r = 15
}

local damageSound = playdate.sound.sampleplayer.new("sounds/damage.wav")
local pointSound = playdate.sound.sampleplayer.new("sounds/point.wav")
local wallSound = playdate.sound.sampleplayer.new("sounds/wallhit.wav")

math.randomseed(playdate.getSecondsSinceEpoch())

function PlayerMovement()
	local y = 0
	
	if playdate.buttonIsPressed(playdate.kButtonUp) and  (player.y > 0 ) then
		y = y - player.v
		
	elseif playdate.buttonIsPressed(playdate.kButtonDown) and (not (player.y + player.h > screen.h )) then
		y = y + player.v
	end
	
	player.y = player.y + y
end

function DrawPlayer()
	playdate.graphics.drawRect(0,player.y,player.w,player.h)
end

function DrawBall()
	playdate.graphics.drawCircleAtPoint(ball.x,ball.y,ball.r);
end

function BallMovement()
	ball.x = ball.x + ball.dx
	ball.y = ball.y + ball.dy
end

function BallCollision()
	if ball.x >= screen.w then
		ball.dx = -ball.v
		wallSound:play(1)

	elseif ball.x <= 0 then
		player.combo = 1
		ball.v = 5

		damageSound:play(1)
		table.insert(badParticles,GetParticle(ball.x,ball.y))

		enemy.x = math.random(100,300)
		enemy.y = math.random(30,200)

		ball.dx = ball.v

	elseif ball.y <= 0 then
		ball.dy = ball.v
		wallSound:play(1)

	elseif ball.y >= screen.h then
		ball.dy = -ball.v
		wallSound:play(1)
	end

	if ball.x <= player.x + player.w and 
		ball.y >= player.y and ball.y <= player.y + player.h
	 then
		player.combo = player.combo + 1
		ball.v = ball.v + (player.combo * 0.3)
		ball.dx = ball.v

		pointSound:play(1)

		for i = 1, 20, 1 do
			table.insert(goodParticles,GetGoodParticle(ball.x,ball.y))
		end

		print(ball.v)
	end

	if DistanceFromPoints({x = enemy.x, y = enemy.y},{x = ball.x,y = ball.y}) <= (enemy.r + ball.r) then
		ball.dx = ball.v

		wallSound:play(1)
		
	end
end

function EnemyMovement()
	local v = AngleToNormalizedVector(enemy.a)
	enemy.x = enemy.x + v.x * enemy.d
	enemy.y = enemy.y + v.y * enemy.d
	enemy.a = enemy.a + math.rad(10)
end
function DrawEnemy()
	playdate.graphics.fillCircleAtPoint(enemy.x,enemy.y,enemy.r)
end

function DrawParticlesBad()
	for _, particle in pairs(badParticles) do
		if particle.ttl > 0 then
			
			playdate.graphics.fillCircleAtPoint(particle.x,particle.y,particle.r)

			particle.ttl = particle.ttl - 1
			particle.r = particle.r + 1
		end
		
	end
	for _, particle in pairs(badParticles) do
		if particle.ttl < 0 then
			table.remove(badParticles,_)
		end
		
	end
end

function DrawParticlesGood()
	for _, particle in pairs(goodParticles) do
		if particle.ttl > 0 then
			
			playdate.graphics.drawLine(particle.center.x,particle.center.y,particle.x,particle.y)

			playdate.graphics.drawPixel(particle.x,particle.y)

			local v = AngleToNormalizedVector(particle.a)

			particle.center = {
				x = particle.x + v.x * -5,
				
				y = particle.y + v.y * -5
			}

			particle.x = particle.x + v.x * particle.s
			particle.y = particle.y + v.y * particle.s

			particle.ttl = particle.ttl - 1
			
		end
		
	end
	for _, particle in pairs(goodParticles) do
		if particle.ttl < 0 then
			table.remove(goodParticles,_)
		end
		
	end
end

function GetParticle(x,y)
	return {
		x = x,
		y = y,
		ttl = 30,
		r = 10
	}
end

function GetGoodParticle(x,y)
	return {
		x = x,
		y = y,
		ttl = 20,
		d = 1,
		a = math.rad(math.random(0,360)),
		s = math.random(5,10),
		center = {
			x = x,
			y = y
		}
	}
end

function NewGame()
	ball.dx = ball.v
	ball.dy = ball.v
end

NewGame()

function playdate.update()
	playdate.graphics.clear()

	PlayerMovement()
	DrawPlayer()

	EnemyMovement()
	DrawEnemy()

	DrawBall()
	BallMovement()
	BallCollision()

	DrawParticlesBad()
	DrawParticlesGood()

	playdate.graphics.drawText("Combo: "..player.combo,200,0)

end

