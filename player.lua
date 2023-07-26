PLAYERSTARTX = 360
PLAYERSTARTY = 100
PLAYER = WORLD:newRectangleCollider(PLAYERSTARTX,PLAYERSTARTY,40,100,{collision_class = "PLAYER"})
--rotates or not
PLAYER:setFixedRotation(true)
PLAYER.speed = 240
PLAYER.animation = ANIMATIONS.idle
PLAYER.isMoving = false
PLAYER.direction = 1
PLAYER.grounded = true


function playerUpdate(dt)
    if PLAYER.body then
        local colliders = WORLD:queryRectangleArea(PLAYER:getX() - 20,PLAYER:getY() + 50,40,2,{'PLATFORM'})
        if #colliders > 0 then
            PLAYER.grounded =true
        else
            PLAYER.grounded=false
        end
        PLAYER.isMoving = false
        local px,py = PLAYER:getPosition()
        if love.keyboard.isDown('right') or love.keyboard.isDown('d') then
            PLAYER:setX(px + PLAYER.speed * dt)
            PLAYER.isMoving=true
            PLAYER.direction = 1
        end
        if love.keyboard.isDown('left') or love.keyboard.isDown('a') then
            PLAYER:setX(px - PLAYER.speed * dt)
            PLAYER.isMoving=true
            PLAYER.direction = -1
        end
    end
    if PLAYER:enter('DANGER') then
        PLAYER:setPosition(PLAYERSTARTX,PLAYERSTARTY)
    end
    if PLAYER.grounded then
        if PLAYER.isMoving then
            PLAYER.animation= ANIMATIONS.run
        else
            PLAYER.animation = ANIMATIONS.idle
        end
    else
        PLAYER.animation = ANIMATIONS.jump
    end
    PLAYER.animation:update(dt) 
end

function drawPlayer()
    local px,py = PLAYER:getPosition()
    PLAYER.animation:draw(SPRITES.playerSheet,px,py,nil,0.20 * PLAYER.direction,0.20,130,272)
end
