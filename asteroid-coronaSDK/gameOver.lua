-- gameOver.lua

local composer = require("composer")
local scene = composer.newScene()

-- Função para redirecionar o jogador para a tela de início
local function goToHome()
    composer.gotoScene("inicio") -- Substitua "inicio" pelo nome da cena de início do jogo
end

-- Função para redirecionar o jogador para a tela de recordes
local function goToRecords()
    composer.gotoScene("records") -- Substitua "records" pelo nome da cena que mostra os recordes do jogo
end

function scene:create(event)
    local sceneGroup = self.view

    -- Obtenha o nome do jogador e pontuação final da cena anterior
    local playerName = event.params.playerName
    local finalScore = event.params.finalScore

    -- Exiba o nome do jogador e a pontuação final na tela de game over
    local playerNameText = display.newText(sceneGroup, "Jogador: " .. playerName, display.contentCenterX, 200, native.systemFont, 36)
    local finalScoreText = display.newText(sceneGroup, "Pontuação Final: " .. finalScore, display.contentCenterX, 250, native.systemFont, 36)

    -- Crie o botão "Voltar ao Início"
    local homeButton = display.newText(sceneGroup, "Voltar ao Início", display.contentCenterX, 350, native.systemFont, 36)
    homeButton:setFillColor(1, 0.2, 0.2)

    -- Crie o botão "Ver Recordes"
    local recordsButton = display.newText(sceneGroup, "Ver Recordes", display.contentCenterX, 400, native.systemFont, 36)
    recordsButton:setFillColor(0.2, 0.2, 1)

    -- Defina os listeners dos botões para redirecionar o jogador ao serem clicados
    homeButton:addEventListener("tap", goToHome)
    recordsButton:addEventListener("tap", goToRecords)
end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Código a ser executado antes da transição para a cena
    elseif (phase == "did") then
        -- Código a ser executado após a transição para a cena
    end
end

function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Código a ser executado antes da transição para outra cena
    elseif (phase == "did") then
        -- Código a ser executado após a transição para outra cena
    end
end

function scene:destroy(event)
    local sceneGroup = self.view

    -- Código a ser executado antes da remoção da cena
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
