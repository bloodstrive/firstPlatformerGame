ENEMIES = {}

function spawnEnemy(x,y)
    local enemy = WORLD:newRectangleCollider(x,y,70,90,{collision_class= "DANGER"})
    enemy.direction = 1
    enemy.speed = 200
    enemy.animation = ANIMATIONS.enemy
    table.insert(ENEMIES,enemy)
end

function updateEnemies(dt)
    for i,e in ipairs(ENEMIES) do
        e.animation:update(dt)
        local ex,ey = e:getPosition()

        local colliders = WORLD:queryRectangleArea(ex + (40 * e.direction), ey + 40, 10,10,{"PLATFORM"})
        if #colliders ==0 then
            e.direction = e.direction * -1
        end
        e:setX(ex + e.speed * dt * e.direction )
    end
end


function drawEnemies()
    for i,e in ipairs(ENEMIES) do
        local ex,ey = e:getPosition()
        e.animation:draw(SPRITES.enemySheet,ex,ey,nil,e.direction,1,50,65)
    end
end
