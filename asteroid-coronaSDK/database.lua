-- database.lua

local M = {}

M.filename = "game_data.db" -- Nome do arquivo do banco de dados

-- Defina a estrutura da tabela de recordes
M.recordsTable = [[
    CREATE TABLE IF NOT EXISTS records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        playerName TEXT NOT NULL,
        score INTEGER NOT NULL
    );
]]

-- Função para inserir o recorde de um jogador no banco de dados
local function insertRecord(playerName, score)
    local dbPath = system.pathForFile(M.filename, system.DocumentsDirectory)
    local db = sqlite3.open(dbPath)

    local insertQuery = [[
        INSERT INTO records (playerName, score)
        VALUES (']] .. playerName .. [[', ]] .. score .. [[);
    ]]

    db:exec(insertQuery)

    db:close()
end

-- Função para buscar todos os recordes no banco de dados
local function getAllRecords()
    local dbPath = system.pathForFile(M.filename, system.DocumentsDirectory)
    local db = sqlite3.open(dbPath)

    local query = [[SELECT * FROM records ORDER BY score DESC;]]
    local records = {}

    for row in db:nrows(query) do
        table.insert(records, {
            playerName = row.playerName,
            score = row.score
        })
    end

    db:close()

    return records
end

M.insertRecord = insertRecord -- Adicione a função no módulo M
M.getAllRecords = getAllRecords -- Adicione a função no módulo M

return M