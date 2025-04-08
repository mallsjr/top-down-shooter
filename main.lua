---@diagnostic disable: deprecated
function love.load()
  math.randomseed(os.time())

  sprites = {}
  sprites.background = love.graphics.newImage("sprites/background.png")
  sprites.bullet = love.graphics.newImage("sprites/bullet.png")
  sprites.player = love.graphics.newImage("sprites/player.png")
  sprites.zombie = love.graphics.newImage("sprites/zombie.png")

  player = {}
  player.x = love.graphics.getWidth() / 2
  player.y = love.graphics.getHeight() / 2
  player.speed = 180 -- multiplying the speed wanted by 60 to account for dt (3*60)

  myFont = love.graphics.newFont(30)

  zombies = {}
  bullets = {}

  gameState = 1 -- gameState 1 is main menu and 2 is gameplay
  score = 0
  maxTime = 2 -- maximum time before spawning in zombie
  timer = maxTime -- count down till spawn of zombie
end

function love.update(dt)
  if gameState == 2 then
    if love.keyboard.isDown("d") and player.x < love.graphics.getWidth() then
      player.x = player.x + player.speed * dt
    end
    if love.keyboard.isDown("a") and player.x > 0 then
      player.x = player.x - player.speed * dt
    end
    if love.keyboard.isDown("w") and player.y > 0 then
      player.y = player.y - player.speed * dt
    end
    if love.keyboard.isDown("s") and player.y < love.graphics.getHeight() then
      player.y = player.y + player.speed * dt
    end
  end

  -- zombie movement
  -- move the zombie towards the player
  for _, z in ipairs(zombies) do
    z.x = z.x + (math.cos(zombiePlayerAngle(z)) * z.speed * dt)
    z.y = z.y + (math.sin(zombiePlayerAngle(z)) * z.speed * dt)
    if distanceBetween(z.x, z.y, player.x, player.y) < 30 then
      -- ending the game by removing all zombies (Game Over)
      for i, _ in ipairs(zombies) do
        zombies[i] = nil
        gameState = 1 -- ending the round
        player.x = love.graphics.getWidth() / 2
        player.y = love.graphics.getHeight() / 2
      end
    end
  end

  -- shooting bullets in direction of mouse
  for _, b in ipairs(bullets) do
    b.x = b.x + (math.cos(b.direction) * b.speed * dt)
    b.y = b.y + (math.sin(b.direction) * b.speed * dt)
  end

  -- removing bullets
  -- need to loop in reverse order because iterating while removing items breaks things
  for i = #bullets, 1, -1 do
    local b = bullets[i]
    if b.x < 0 or b.y < 0 or b.x > love.graphics.getWidth() or b.y > love.graphics.getHeight() then
      -- this removes items from list and reorders them
      -- again when doing in loop reverse the order (last to first iteration)
      table.remove(bullets, i)
    end
  end

  -- testing for collision between zombies and bullets
  for _, z in ipairs(zombies) do
    for _, b in ipairs(bullets) do
      if distanceBetween(z.x, z.y, b.x, b.y) < 20 then
        -- there is a collision between zombie and bullet
        z.dead = true
        b.dead = true
        score = score + 1
      end
    end
  end

  -- removing dead zombie (had collision with bullet
  for i = #zombies, 1, -1 do
    local z = zombies[i]
    if z.dead == true then
      table.remove(zombies, i)
    end
  end

  -- removing dead bullet
  for i = #bullets, 1, -1 do
    local b = bullets[i]
    if b.dead == true then
      table.remove(bullets, i)
    end
  end

  if gameState == 2 then
    -- counting down to spawn zombie
    -- once timer hits 0 spawn a zombie
    -- also update the max time to be 95% of what it was
    -- and set that as the new maxtime, while setting timer to that new time.
    timer = timer - dt
    if timer <= 0 then
      spawnZombie()
      maxTime = 0.95 * maxTime
      timer = maxTime
    end
  end
end

function love.draw()
  love.graphics.draw(sprites.background, 0, 0)

  if gameState == 1 then
    love.graphics.setFont(myFont)
    love.graphics.printf("Click anywhere to begin!", 0, 50, love.graphics.getWidth(), "center")
  end

  love.graphics.printf("Score: " .. score, 0, love.graphics.getHeight() - 100, love.graphics.getWidth(), "center")

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

  for _, z in ipairs(zombies) do
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

  for _, b in ipairs(bullets) do
    love.graphics.draw(
      sprites.bullet,
      b.x,
      b.y,
      nil,
      0.5,
      nil,
      sprites.bullet:getWidth() / 2,
      sprites.bullet:getHeight() / 2
    )
  end
end

-- Converting degrees into radians is degrees * pi/180
-- angle between 2 points: atan2(y1-y2, x1-x2)

-- used to point the playey towards the mouse
function playerMouseAngle()
  return math.atan2(player.y - love.mouse.getY(), player.x - love.mouse.getX()) + math.pi
end

-- used to point the zombies at the player
function zombiePlayerAngle(enemy)
  return math.atan2(player.y - enemy.y, player.x - enemy.x)
end

function spawnZombie()
  local zombie = {}

  -- zombie.x = math.random(0, love.graphics.getWidth())
  -- zombie.y = math.random(0, love.graphics.getHeight())
  zombie.x = 0
  zombie.y = 0
  zombie.speed = 100
  zombie.dead = false

  local side = math.random(1, 4)
  if side == 1 then
    zombie.x = -30
    zombie.y = math.random(0, love.graphics.getHeight())
  elseif side == 2 then
    zombie.x = love.graphics.getWidth() + 30
    zombie.y = math.random(0, love.graphics.getHeight())
  elseif side == 3 then
    zombie.x = math.random(0, love.graphics.getWidth())
    zombie.y = -30
  else
    zombie.x = math.random(0, love.graphics.getWidth())
    zombie.y = love.graphics.getHeight() + 30
  end

  table.insert(zombies, zombie)
end

function love.keypressed(key)
  if key == "space" then
    spawnZombie()
  end
end

function love.mousepressed(_, _, button) -- _'s are x and y
  if button == 1 and gameState == 2 then
    spawnBullet()
  elseif button == 1 and gameState == 1 then
    gameState = 2
    maxTime = 2
    timer = maxTime
    score = 0
  end
end

function spawnBullet()
  local bullet = {}
  bullet.x = player.x
  bullet.y = player.y
  bullet.speed = 500
  bullet.direction = playerMouseAngle()
  bullet.dead = false

  table.insert(bullets, bullet)
end

function distanceBetween(x1, y1, x2, y2)
  return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end
