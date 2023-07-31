-- login.lua

local composer = require( "composer" )
local scene = composer.newScene()

local widget = require( "widget" )

local function handleLoginButtonEvent( event )
    if ( "ended" == event.phase ) then
        -- Implementar a lógica de login aqui
        composer.gotoScene( "game", { effect="fade", time=500 } )
    end
end

function scene:create( event )
    local sceneGroup = self.view

    local loginButton = widget.newButton(
        {
            label = "Login",
            onEvent = handleLoginButtonEvent,
            emboss = false,
            shape = "roundedRect",
            width = 200,
            height = 40,
            cornerRadius = 10,
            fillColor = { default={0.2,0.6,1,1}, over={0.3,0.7,1,1} },
            labelColor = { default={1,1,1,1}, over={1,1,1,1} },
        }
    )
    loginButton.x = display.contentCenterX
    loginButton.y = display.contentCenterY

    sceneGroup:insert( loginButton )
end

scene:addEventListener( "create", scene )

return scene
