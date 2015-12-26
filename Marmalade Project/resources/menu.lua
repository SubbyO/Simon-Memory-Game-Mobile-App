-- Create menu scene 
menuScene = director:createScene() 

-- Create background and sprites: 
local background
local title
local playButton

--Switch to game when play button is pressed
function newGame(event)
  if event.phase == "ended" then
    -- Switch to game scene
    switchToScene("game")
  end
end

--Initialize background and sprites
function menuScene:setUp(event)
  dbg.print("Menu set up")
  background = director:createSprite(director.displayCenterX, director.displayCenterY, "gfx/background.jpg")
  background.xAnchor = 0.5
  background.yAnchor = 0.5
  title = director:createSprite((width - 280) / 2, height - 130, "gfx/title.png")
  playButton = director:createSprite(director.displayCenterX, director.displayCenterY, "gfx/play.png")
  playButton.xAnchor = 0.5
  playButton.yAnchor = 0.5
  playButton.xScale = 0.5
  playButton.yScale = 0.5
  playButton:addEventListener("touch", newGame)
end

--Remove background and sprites
function menuScene:tearDown(event)
  dbg.print("Menu torn down")
  playButton:removeEventListener("touch", newGame)
  background = background:removeFromParent()
  title = title:removeFromParent()
  playButton = playButton:removeFromParent()
end
 
menuScene:addEventListener({"setUp", "tearDown"}, menuScene)