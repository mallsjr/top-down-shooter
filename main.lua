function love.load()
  sprites = {}
  sprites.background = love.graphics.newImage("sprites/background.png")
  sprites.bullet = love.graphics.newImage("sprites/bullet.png")
  sprites.player = love.graphics.newImage("sprites/player.png")
  sprites.zombie = love.graphics.newImage("sprites/zombie.png")

  player = {}
  player.x = love.graphics.getWidth() / 2
  player.y = love.graphics.getHeight() / 2
  player.speed = 180 -- multiplying the speed wanted by 60 to account for dt (3*60)

  zombies = {}
end

function love.update(dt)
  if love.keyboard.isDown("d") then
    player.x = player.x + player.speed * dt
  end
  if love.keyboard.isDown("a") then
    player.x = player.x - player.speed * dt
  end
  if love.keyboard.isDown("w") then
    player.y = player.y - player.speed * dt
  end
  if love.keyboard.isDown("s") then
    player.y = player.y + player.speed * dt
  end

  -- zombie movement
  -- move the zombie towards the player
  for i, z in ipairs(zombies) do
    z.x = z.x + (math.cos(zombiePlayerAngle(z)) * z.speed * dt)
    z.y = z.y + (math.sin(zombiePlayerAngle(z)) * z.speed * dt)
  end
end

function love.draw()
  love.graphics.draw(sprites.background, 0, 0)
  love.graphics.draw(
    sprites.player,
    player.x,
    player.y,
    playerMouseAngle(), -- rotation in radians
    nil, -- scale x
    nil, -- scale y
    sprites.player:getWidth() / 2, -- ox: location of origin x, default is left
    sprites.player:getHeight() / 2 -- oy: location of origin y, default is top
  )

  for i, z in ipairs(zombies) do
    love.graphics.draw(
      sprites.zombie,
      z.x,
      z.y,
      zombiePlayerAngle(z),
      nil,
      nil,
      sprites.zombie:getWidth() / 2,
      sprites.zombie:getHeight() / 2
    )
  end
end

-- Converting degrees into radians is degrees * pi/180
-- angle between 2 points: atan2(y1-y2, x1-x2)

function playerMouseAngle()
  return math.atan2(player.y - love.mouse.getY(), player.x - love.mouse.getX()) + math.pi
end

function zombiePlayerAngle(enemy)
  return math.atan2(player.y - enemy.y, player.x - enemy.x)
end

function spawnZombie()
  local zombie = {}
  zombie.x = math.random(0, love.graphics.getWidth())
  zombie.y = math.random(0, love.graphics.getHeight())
  zombie.speed = 100

  table.insert(zombies, zombie)
end

function love.keypressed(key)
  if key == "space" then
    spawnZombie()
  end
end
