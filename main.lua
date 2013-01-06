function love.load()
  invaderImage = love.graphics.newImage("res/invader.png")
  heartImage = love.graphics.newImage("res/heart.png")
  paddleImage = love.graphics.newImage("res/paddle.png")

  cannotShootSound = love.audio.newSource("res/beep.ogg", "static")
  backgroundMusic = love.audio.newSource("res/music.wav")

  spaceInvadersFontBig = love.graphics.setNewFont("res/font.ttf", 50)
  spaceInvadersFontHuge = love.graphics.setNewFont("res/font.ttf", 80)
  spaceInvadersFontSmall = love.graphics.newFont("res/font.ttf", 30)

  setColorFunction = love.graphics.setColor

  firstTime = true

  startGame()
end

function startGame()
  love.audio.play(backgroundMusic)
  invaders = {}
  invaders.goingLeft = false

  for i = 0, 8 do
    for u = 0, 3 do
      local newInvader = { x = 15 + i * 70, y = 25 + u * 70, selected = false, alive = true }
      table.insert(invaders, newInvader)
    end
  end

  invaders[1].selected = true
  selectedInvader = 1
  canShoot = true

  canGoRight = true
  canGoLeft = true
  canGoUp = true
  canGoDown = true

  invaderBullet = { moving = false, x = nil, y = nil, speed = 2, width = nil, height = nil }

  paddle = { moving = true, x = 800 / 2 - 48 / 2, y = 605, width = 48, height = 12, lives = 5, goAfter = nil }
  paddleBullet = { moving = false, x = nil, y = nil, speed = 5, width = 2, height = 7, invadersKilled = 0 }

  gameLost = nil
  gameOver = false
  state = "title"
  menuSelection = "Play"

  spawnTitleInvaderCounter = 0
  titleInvaders = {}
end

function love.update(dt)
  if state == "title" then
    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
      menuSelection = "Play"
    elseif love.keyboard.isDown("down") or love.keyboard.isDown("s") then
      menuSelection = "Quit"
    end

    if love.keyboard.isDown(" ") or love.keyboard.isDown("return") then
      if menuSelection == "Play" then
        if not firstTime then
          state = "game"
          love.timer.sleep(1.0)
        else
          state = "tutorial"
          spawnTitleInvaderCounter = 0
          love.timer.sleep(1.0)
        end
      else
        love.event.quit()
      end
    end

    if love.keyboard.isDown("escape") then
      love.event.quit()
    end

    for i = 1, #titleInvaders do
      titleInvaders[i].y = titleInvaders[i].y + 250 * dt
    end

    spawnTitleInvaderCounter = spawnTitleInvaderCounter + dt

    if spawnTitleInvaderCounter > 0.5 and math.random(0, 500) then
      local newTitleInvader = { x = math.random(-50, 800), y = -70 }
      table.insert(titleInvaders, newTitleInvader)
      spawnTitleInvaderCounter = 0
    end
  elseif state == "tutorial" then
    for i = 1, #titleInvaders do
      titleInvaders[i].y = titleInvaders[i].y + 250 * dt
    end

    spawnTitleInvaderCounter = spawnTitleInvaderCounter + dt
    
    if spawnTitleInvaderCounter > 0.5 and math.random(0, 500) then
      local newTitleInvader = { x = math.random(-50, 800), y = -70 }
      table.insert(titleInvaders, newTitleInvader)
      spawnTitleInvaderCounter = 0
    end
    
    if love.keyboard.isDown(" ") or love.keyboard.isDown("return") then
      state = "game"
      firstTime = false
    end
  elseif state == "game" and not gameOver then
    if love.keyboard.isDown("escape") then
      startGame()
      love.timer.sleep(1.0)
    end

    -- Decide where to move
    local hitEdge = false

    for i = 1, #invaders do
      if invaders[i].x > 740 then
        invaders.goingLeft = true
        hitEdge = true
        break
      elseif invaders[i].x < 3 then
        invaders.goingLeft = false
        hitEdge = true
        break
      end
    end

    -- Move asteroids down
    if hitEdge then
      for i = 1, #invaders do
        invaders[i].y = invaders[i].y + 10
      end
    end

    -- Move asteroids to the right or to the left
    for i = 1, #invaders do
      if invaders.goingLeft then
        invaders[i].x = invaders[i].x - 50 * dt
      else
        invaders[i].x = invaders[i].x + 50 * dt
      end
    end

    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
      if canGoRight then
        for i = 1, #invaders do
          if invaders[i].selected and i < 33 then
            invaders[i].selected = false
            invaders[i + 4].selected = true
            selectedInvader = i + 4
            break
          end
        end

        canGoRight = false
      end
    else
      canGoRight = true
    end

    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
      if canGoLeft then
        for i = 1, #invaders do
          if invaders[i].selected and i > 4 then
            invaders[i].selected = false
            invaders[i - 4].selected = true
            selectedInvader = i - 4
            break
          end
        end

        canGoLeft = false
      end
    else
      canGoLeft = true
    end

    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
      if canGoDown then
        for i = 1, #invaders do
          if invaders[i].selected and i ~= 4 and i ~= 8 and i ~= 12 and i ~= 16 and i ~= 20 and i ~= 24 and i ~= 28 and i ~= 32 and i ~= 36 then
            invaders[i].selected = false
            invaders[i + 1].selected = true
            selectedInvader = i + 1
            break
          end
        end

        canGoDown = false
      end
    else
      canGoDown = true
    end

    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
      if canGoUp then
        for i = 1, #invaders do
          if invaders[i].selected and i ~= 1 and i ~= 5 and i ~= 9 and i ~= 13 and i ~= 17 and i ~= 21 and i ~= 25 and i ~= 29 and i ~= 33 then
            invaders[i].selected = false
            invaders[i - 1].selected = true
            selectedInvader = i - 1
            break
          end
        end

        canGoUp = false
      end
    else
      canGoUp = true
    end

    -- Send invader bullet when player hits [SPACE]
    if love.keyboard.isDown(" ") then
      if canShoot then
        if not invaderBullet.moving then
          if invaders[selectedInvader].alive then
            invaderBullet.moving = true

            invaderBullet.x = invaders[selectedInvader].x + 32
            invaderBullet.y = invaders[selectedInvader].y + 65

            invaderBullet.width = 2
            invaderBullet.height = 10

            invaderBullet.speed = 300
          else
            love.audio.play(cannotShootSound)
          end
        end

        canShoot = false
      else
        canShoot = true
      end
    end

    -- Make invader bullet move and delete it when off-screen
    if invaderBullet.moving then
      invaderBullet.y = invaderBullet.y + invaderBullet.speed * dt

      if invaderBullet.y > 640 then
        invaderBullet.moving = false
      end
    end

    -- Handle collision between invader bullet and the paddle
    if invaderBullet.moving then
      if invaderBullet.x > paddle.x and invaderBullet.x + invaderBullet.width < paddle.x + paddle.width and invaderBullet.y > paddle.y and invaderBullet.y + invaderBullet.width < paddle.y + paddle.height then
        paddle.lives = paddle.lives - 1
        invaderBullet.moving = false
      end
    end

    local invadersAlive = 0
    for i = 1, #invaders do
      if invaders[i].alive then
        invadersAlive = invadersAlive + 1
      end
    end

    if invadersAlive <= 30 then
      for i = 1, #invaders do
        if invaders[i].alive then
          paddle.goAfter = invaders[i].x
        end
      end
    end

    if not paddle.goAfter then
      -- Make paddle move...
      if paddle.goingLeft then
        paddle.x = paddle.x + 100 * dt
      else
        paddle.x = paddle.x - 100 * dt
      end

      -- ... randomly ...
      if math.random(0, 10000 * dt) == 0 then
        paddle.goingLeft = not paddle.goingLeft
      end

      -- ... but with some rules.
      if paddle.x < 3 then
        paddle.goingLeft = true
      elseif paddle.x + paddle.width > 797 then
        paddle.goingLeft = false
      end
    else
      if paddle.x > paddle.goAfter then paddle.x = paddle.x - 100 * dt end
      if paddle.x < paddle.goAfter then paddle.x = paddle.x + 100 * dt end
    end

    -- Handle paddle shooting
    if not paddleBullet.moving then
      if math.random(0, 2000 * dt) == 0 then
        paddleBullet.moving = true

        paddleBullet.x = paddle.x + 32
        paddleBullet.y = paddle.y - 2

        paddleBullet.width = 2
        paddleBullet.height = 10

        paddleBullet.speed = 650

        paddleBullet.invadersKilled = 0
      end
    else
      paddleBullet.y = paddleBullet.y - paddleBullet.speed * dt

      if paddleBullet.y < 0 then
        paddleBullet.moving = false
      end
    end

    -- Handle paddle bullet collision
    if paddleBullet.moving then
      for i = 1, #invaders do
        if paddleBullet.x > invaders[i].x and paddleBullet.x + paddleBullet.width < invaders[i].x + 64 and paddleBullet.y > invaders[i].y and paddleBullet.y + paddleBullet.height < invaders[i].y + 64 and invaders[i].alive then
          invaders[i].alive = false
          paddleBullet.invadersKilled = paddleBullet.invadersKilled + 1
          break
        end
      end
    end

    if paddleBullet.invadersKilled > 1 then
      paddleBullet.moving = false
    end

    -- Check if player has won or lost
    if paddle.lives == 0 or invaders[#invaders].y > 550 then
      gameOver = true
      gameLost = false
      love.timer.sleep(1.0)
    elseif invadersAlive == 0 then
      gameOver = true
      gameLost = true
      love.timer.sleep(1.0)
    end
  end

  if gameOver then
    if love.keyboard.isDown(" ") or love.keyboard.isDown("return") then
      gameOver = nil
      startGame()
      love.graphics.setColor = setColorFunction

      love.timer.sleep(1.0)
    end
  end
end

function love.draw()
  if gameOver then
    setColorFunction(255, 255, 255, 255)

    love.graphics.setFont(spaceInvadersFontHuge)
    if gameLost then
      love.graphics.print("You lost", 180, 500)
    else
      love.graphics.print("You win", 200, 500)
      paddle.moving = false
    end

    love.graphics.setColor = function(r, g, b) setColorFunction(r, g, b, 30) end
  end

  if state == "title" then
    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(spaceInvadersFontHuge)
    love.graphics.print("Not", 315, 40)
    love.graphics.print("Space", 252.5, 118)
    love.graphics.print("Invaders", 165, 200)

    love.graphics.setColor(255, 255, 255, 30)
    for i = 1, #titleInvaders do
      love.graphics.draw(invaderImage, titleInvaders[i].x, titleInvaders[i].y)
    end

    love.graphics.setFont(spaceInvadersFontSmall)
    if menuSelection == "Play" then love.graphics.setColor(255, 0, 0) else love.graphics.setColor(255, 255, 255) end
    love.graphics.print("Play", 356, 530)
    if menuSelection == "Quit" then love.graphics.setColor(255, 0, 0) else love.graphics.setColor(255, 255, 255) end
    love.graphics.print("Quit", 356, 580)
  elseif state == "tutorial" then
    love.graphics.setFont(spaceInvadersFontSmall)
    love.graphics.setColor(255, 255, 255, 255)

    love.graphics.print("Your people are invading the Earth.", 10, 10)
    love.graphics.print("Use the arrow keys to select \nan invader and then hit [Space]\nto shoot.", 10, 100)

    love.graphics.print("Now hit [Space] to start playing.", 10, 240)

    love.graphics.setColor(255, 255, 255, 30)
    for i = 1, #titleInvaders do
      love.graphics.draw(invaderImage, titleInvaders[i].x, titleInvaders[i].y)
    end
  elseif state == "game" then
    for i = 1, #invaders do
      if invaders[i].selected and invaders[i].alive then
        love.graphics.setColor(255, 0, 0)
      elseif invaders[i].selected and not invaders[i].alive then
        love.graphics.setColor(255, 0, 255)
      elseif not invaders[i].selected and not invaders[i].alive then
        love.graphics.setColor(161, 165, 167, 30)
      else
        love.graphics.setColor(255, 255, 255)
      end

      love.graphics.draw(invaderImage, invaders[i].x, invaders[i].y)
    end

    if invaderBullet.moving then
      love.graphics.setColor(101, 205, 248)
      love.graphics.rectangle("fill", invaderBullet.x, invaderBullet.y, invaderBullet.width, invaderBullet.height)
    end

    if paddleBullet.moving then
      love.graphics.setColor(52, 248, 31)
      love.graphics.rectangle("fill", paddleBullet.x, paddleBullet.y, paddleBullet.width, paddleBullet.height)
    end

    -- Draw paddle's hearts
    for i = 0, paddle.lives - 1 do
      love.graphics.setColor(255, 255, 255)
      love.graphics.draw(heartImage, 7 + i * 20, 618)
    end

    if paddle.moving then
      love.graphics.setColor(255, 255, 255)
      love.graphics.draw(paddleImage, paddle.x, paddle.y)
    end
  end
end