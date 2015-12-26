--Create global variables for height and width of screen
height = director.displayHeight
width = director.displayWidth
  
--Run game and menu simultaneously
dofile("game.lua")
dofile("menu.lua")

--Switch to Menu
director:setCurrentScene(nil)
director:moveToScene(menuScene)

-- Switch to specific scene
function switchToScene(scene_name)
  if (scene_name == "game") then
    director:moveToScene(gameScene)
  elseif (scene_name == "menu") then
    director:moveToScene(menuScene)
  end
end

--Check to see if highscore is saved. If not, makes a highscore file
local gameData = {}
 
local pathS = system:getFilePath("storage", "")
-- Load the saved JSON string back
local file = io.open(pathS .. "data.txt", "r")
if file == nil then
  local gameData = {bestScore=0}
  local encoded = json.encode(gameData)
  local file = io.open(pathS .. "data.txt", "w")
  file:write(encoded)
  file:close()
  dbg.print('Failed to open file for reading - new one added')
else
  dbg.print('file found no worries')
  file:close()
end

director:startRendering()