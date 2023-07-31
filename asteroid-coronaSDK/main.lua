-- Copyright (c) 2017 Corona Labs Inc.
-- Code is MIT licensed and can be re-used; see https://www.coronalabs.com/links/code/license
-- Other assets are licensed by their creators:
--    Art assets by Kenney: http://kenney.nl/assets
--    Music and sound effect assets by Eric Matyas: http://www.soundimage.org

local composer = require("composer")
local sqlite3 = require("sqlite3")
local database = require("database") -- Importe o arquivo de configuração do banco de dados

-- Criação do banco de dados no evento "applicationStart"
local function onApplicationStart()
    local dbPath = system.pathForFile(database.filename, system.DocumentsDirectory)
    local db = sqlite3.open(dbPath)

    -- Criação da tabela de recordes
    db:exec(database.recordsTable)

    -- Fechamento do banco de dados
    db:close()
end

-- Inicializa o banco de dados no momento de "applicationStart"
Runtime:addEventListener("system", onApplicationStart)


local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

-- Seed the random number generator
math.randomseed( os.time() )

-- Configure image sheet
local sheetOptions =
{
    frames =
    {
        {   -- 1) asteroid 1
            x = 0,
            y = 0,
            width = 102,
            height = 85
        },
        {   -- 2) asteroid 2
            x = 0,
            y = 85,
            width = 90,
            height = 83
        },
        {   -- 3) asteroid 3
            x = 0,
            y = 168,
            width = 100,
            height = 97
        },
        {   -- 4) ship
            x = 0,
            y = 265,
            width = 98,
            height = 79
        },
        {   -- 5) laser
            x = 98,
            y = 265,
            width = 14,
            height = 40
        },
    },
}
local objectSheet = graphics.newImageSheet( "gameObjects.png", sheetOptions )

-- Initialize variables
local lives = 3
local score = 0
local died = false

local asteroidsTable = {}

local ship
local gameLoopTimer
local livesText
local scoreText

-- Set up display groups
local backGroup = display.newGroup()  -- Display group for the background image
local mainGroup = display.newGroup()  -- Display group for the ship, asteroids, lasers, etc.
local uiGroup = display.newGroup()    -- Display group for UI objects like the score

-- Load the background
local background = display.newImageRect( backGroup, "background.png", 800, 1400 )
background.x = display.contentCenterX
background.y = display.contentCenterY

ship = display.newImageRect( mainGroup, objectSheet, 4, 98, 79 )
ship.x = display.contentCenterX
ship.y = display.contentHeight - 100
physics.addBody( ship, { radius=30, isSensor=true } )
ship.myName = "ship"

-- Display lives and score
livesText = display.newText( uiGroup, "Lives: " .. lives, 200, 80, native.systemFont, 36 )
scoreText = display.newText( uiGroup, "Score: " .. score, 400, 80, native.systemFont, 36 )

-- Hide the status bar
display.setStatusBar( display.HiddenStatusBar )


local function updateText()
	livesText.text = "Lives: " .. lives
	scoreText.text = "Score: " .. score
end


local function createAsteroid()
 
    local newAsteroid = display.newImageRect( mainGroup, objectSheet, 1, 102, 85 )
    table.insert( asteroidsTable, newAsteroid )
    physics.addBody( newAsteroid, "dynamic", { radius=40, bounce=0.8 } )
    newAsteroid.myName = "asteroid"

    local whereFrom = math.random( 3 )

    if ( whereFrom == 1 ) then
        -- From the left
        newAsteroid.x = -60
        newAsteroid.y = math.random( 500 )
        newAsteroid:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) )
    elseif ( whereFrom == 2 ) then
        -- From the top
        newAsteroid.x = math.random( display.contentWidth )
        newAsteroid.y = -60
        newAsteroid:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
    elseif ( whereFrom == 3 ) then
        -- From the right
        newAsteroid.x = display.contentWidth + 60
        newAsteroid.y = math.random( 500 )
        newAsteroid:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
    end
   
    newAsteroid:applyTorque( math.random( -6,6 ) )
end


local function fireLaser()
 
    local newLaser = display.newImageRect( mainGroup, objectSheet, 5, 14, 40 )
    physics.addBody( newLaser, "dynamic", { isSensor=true } )
    newLaser.isBullet = true
    newLaser.myName = "laser"
   
    newLaser.x = ship.x
    newLaser.y = ship.y
    newLaser:toBack()

    transition.to( newLaser, { y=-40, time=500,
        onComplete = function() display.remove( newLaser ) end
    } )
end

ship:addEventListener( "tap", fireLaser )


local function dragShip( event )
 
    local ship = event.target
    local phase = event.phase

    if ( "began" == phase ) then
        -- Set touch focus on the ship
        display.currentStage:setFocus( ship )
        -- Store initial offset position
        ship.touchOffsetX = event.x - ship.x
    
    elseif ( "moved" == phase ) then
        -- Move the ship to the new touch position
        ship.x = event.x - ship.touchOffsetX

    elseif ( "ended" == phase or "cancelled" == phase ) then
        -- Release touch focus on the ship
        display.currentStage:setFocus( nil )
    end
   
    return true  -- Prevents touch propagation to underlying objects
end

ship:addEventListener( "touch", dragShip )


local function gameLoop()
    
    -- Create new asteroid
    createAsteroid()

    -- Remove asteroids which have drifted off screen
    for i = #asteroidsTable, 1, -1 do
        local thisAsteroid = asteroidsTable[i]
 
        if ( thisAsteroid.x < -100 or
             thisAsteroid.x > display.contentWidth + 100 or
             thisAsteroid.y < -100 or
             thisAsteroid.y > display.contentHeight + 100 )
        then
            display.remove( thisAsteroid )
            table.remove( asteroidsTable, i )
        end
    end
end

gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 )


local function restoreShip()
 
    ship.isBodyActive = false
    ship.x = display.contentCenterX
    ship.y = display.contentHeight - 100
 
    -- Fade in the ship
    transition.to( ship, { alpha=1, time=4000,
        onComplete = function()
            ship.isBodyActive = true
            died = false
        end
    } )
end


local function onCollision( event )
 
    if ( event.phase == "began" ) then
 
        local obj1 = event.object1
        local obj2 = event.object2

        if ( ( obj1.myName == "laser" and obj2.myName == "asteroid" ) or
             ( obj1.myName == "asteroid" and obj2.myName == "laser" ) )
        then
            -- Remove both the laser and asteroid
            display.remove( obj1 )
            display.remove( obj2 )

            for i = #asteroidsTable, 1, -1 do
                if ( asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2 ) then
                    table.remove( asteroidsTable, i )
                    break
                end
            end

            -- Increase score
            score = score + 100
            scoreText.text = "Score: " .. score

        elseif ( ( obj1.myName == "ship" and obj2.myName == "asteroid" ) or
                 ( obj1.myName == "asteroid" and obj2.myName == "ship" ) )
        then
            if ( died == false ) then
                died = true

                -- Update lives
                lives = lives - 1
                livesText.text = "Lives: " .. lives

                if ( lives == 0 ) then
                    display.remove( ship )
                else
                    ship.alpha = 0
                    timer.performWithDelay( 1000, restoreShip )
                end
            end
        end
    end
end


local function playerDied()
    -- Atualize a variável 'died' para evitar que essa função seja chamada novamente
    died = true

    -- Atualize a variável 'lives'
    lives = lives - 1
    livesText.text = "Lives: " .. lives

    -- Verifique se o jogador ainda possui vidas
    if lives == 0 then
        -- Se o jogador não tem mais vidas, remova a nave
        display.remove(ship)
        -- Exiba a tela de game over com os botões "Voltar ao Início" e "Ver Recordes"
        local options = {
            effect = "fade",
            time = 500,
            params = {
                playerName = "Nome do jogador", -- Substitua pelo nome do jogador obtido no jogo
                finalScore = score -- Substitua pela pontuação final obtida no jogo
            }
        }
        composer.gotoScene("gameOver", options)
    else
        -- Se o jogador ainda tem vidas, restaure a nave após um pequeno intervalo
        ship.alpha = 0
        timer.performWithDelay(1000, restoreShip)
    end

    -- A partir daqui, você pode chamar a função que envia os dados do jogador e pontuação para a API
    -- Você pode obter o nome do jogador e a pontuação a partir das variáveis disponíveis no jogo

    -- Exemplo: enviar dados do jogador e pontuação para a API
    local playerName = "Nome do jogador" -- Substitua pelo nome do jogador obtido no jogo
    local playerScore = score -- Substitua pela pontuação obtida no jogo

    -- Chamada para enviar dados do jogador e pontuação para a API
    -- Substitua 'sendPlayerData()' e 'sendPlayerRecord()' pelas funções de envio da API que você criou no jogo Solar2D
    sendPlayerData(playerName, playerScore)
end


Runtime:addEventListener( "collision", onCollision )

-- main.lua

local sqlite3 = require("sqlite3")
local database = require("database") -- Importe o arquivo de configuração do banco de dados

-- Criação do banco de dados
local dbPath = system.pathForFile(database.filename, system.DocumentsDirectory)
local db = sqlite3.open(dbPath)

-- Criação da tabela de recordes
db:exec(database.recordsTable)

-- Fechamento do banco de dados
db:close()