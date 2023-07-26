function love.load()
    love.window.setMode(1000,768)

    ANIM8 = require "./library/anim8/anim8"
    WF = require "./library/windfield/windfield"
    STI = require "./library/Simple-Tiled-Implementation/sti"
    CAMERAFILE = require "./library/hump/camera"

    --bring the camera in
    CAM = CAMERAFILE()

    --bring in sprites
    SPRITES = {}
    SPRITES.playerSheet = love.graphics.newImage('sprites/playerSheet.png')
    SPRITES.enemySheet= love.graphics.newImage('sprites/enemySheet.png')
    SPRITES.background = love.graphics.newImage('sprites/background.png')

    local grid = ANIM8.newGrid(614,564,SPRITES.playerSheet:getWidth(),SPRITES.playerSheet:getHeight())
    local enemyGrid = ANIM8.newGrid(100,79,SPRITES.enemySheet:getWidth(),SPRITES.enemySheet:getHeight())

    --animations
    ANIMATIONS={}
    ANIMATIONS.idle = ANIM8.newAnimation(grid('1-15',1),0.05)
    ANIMATIONS.jump= ANIM8.newAnimation(grid('1-7',2),0.05)
    ANIMATIONS.run= ANIM8.newAnimation(grid('1-15',3),0.05)
    ANIMATIONS.enemy = ANIM8.newAnimation(enemyGrid('1-2',1),0.03)

    --the world
    WORLD = WF.newWorld(0,800,false)
    WORLD:setQueryDebugDrawing(true)

    WORLD:addCollisionClass('PLATFORM')
    WORLD:addCollisionClass('PLAYER'--[[,{ignores = {"PLATFORM"}}]])
    WORLD:addCollisionClass('DANGER')

    --music
    SOUNDS = {}
    SOUNDS.jump = love.audio.newSource("audio/jump.wav","static")
    SOUNDS.music= love.audio.newSource("audio/music.mp3","stream")
    SOUNDS.music:setLooping(true)

    SOUNDS.music:play()

    
    --require stuff we brought in
    require('player')
    require('enemy')
    require('show')
    
    DANGERZONE = WORLD:newRectangleCollider(-500,800,5000,50,{collision_class="DANGER"})
    DANGERZONE:setType('static')
    
    PLATFORMS={}
    FLAGX=0
    FLAGY=0

    --save date
    saveData={}
    saveData.CURRENTLEVEL= "level1"
    if love.filesystem.getInfo("data.lua") then
        local data = love.filesystem.load("data.lua")
        data()
    end

    --load saved data
    loadMap(saveData.CURRENTLEVEL)
end

function love.update(dt)
    WORLD:update(dt)
    GAMEMAP:update(dt)
    playerUpdate(dt)
    updateEnemies(dt)
    local px,py = PLAYER:getPosition()
    CAM:lookAt(px,love.graphics.getHeight()/2)

    local colliders = WORLD:queryCircleArea(FLAGX,FLAGY,10,{'PLAYER'})
    if #colliders > 0 then
        if saveData.CURRENTLEVEL == "level1" then
            loadMap("level2")
        elseif saveData.CURRENTLEVEL == "level2" then
            loadMap("level1")
        end
    end
end

function love.draw()
    love.graphics.draw(SPRITES.background,0,0)
    CAM:attach()
        GAMEMAP:drawLayer(GAMEMAP.layers["Tile Layer 1"])
        --WORLD:draw()
        drawPlayer()
        drawEnemies()
    CAM:detach()
end


function love.keypressed(key)
    if key == 'up' or key=='w' then
        if PLAYER.grounded then
            PLAYER:applyLinearImpulse(0,-4000)
            SOUNDS.jump:play()
        end
    end
    if key == 'r' then
        loadMap("level2")
    end
end

function destroyAll()
    local i = #PLATFORMS
    while i > -1 do
        if PLATFORMS[i] ~= nil then
            PLATFORMS[i]:destroy()
        end
        table.remove(PLATFORMS,i)
        i = i -1
    end
    local i = #ENEMIES
    while i > -1 do
        if ENEMIES[i] ~= nil then
            ENEMIES[i]:destroy()
        end
        table.remove(ENEMIES,i)
        i = i -1
    end
end

function love.mousepressed(x,y,button)
    if button == 1 then
        local colliders = WORLD:queryCircleArea(x,y,100,{'PLATFORM','DANGER'})
        for i,c in ipairs(colliders) do
            c:destroy()
        end
    end
end

function loadMap(mapName)
    saveData.CURRENTLEVEL = mapName
    love.filesystem.write("data.lua",table.show(saveData,"saveData"))
    destroyAll()
    GAMEMAP = STI("maps/" .. mapName .. ".lua")
    for i,obj in pairs(GAMEMAP.layers["Start"].objects)do
        PLAYERSTARTX = obj.x
        PLAYERSTARTY = obj.y
    end
    PLAYER:setPosition(PLAYERSTARTX,PLAYERSTARTY)
    for i,obj in pairs(GAMEMAP.layers["Platforms"].objects)do
        spawnPlatform(obj.x,obj.y,obj.width,obj.height)
    end
    for i,obj in pairs(GAMEMAP.layers["Enemies"].objects)do
        spawnEnemy(obj.x,obj.y)
    end
    for i,obj in pairs(GAMEMAP.layers["Flag"].objects)do
        FLAGX=obj.x
        FLAGY=obj.y
    end
end

function spawnPlatform(x,y,width,height)
        local PLATFORM = WORLD:newRectangleCollider(x,y,width,height,{collision_class = "PLATFORM"})
        PLATFORM:setType('static')
        table.insert(PLATFORMS,PLATFORM)
end
