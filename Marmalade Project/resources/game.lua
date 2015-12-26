--Create game scene
gameScene = director:createScene()

--Create variables
local button_width
local button_height

local buttons
local sounds
local sequence
local playcursor
local gamemode
local level
local lose
local even
local buttonscalex
local buttonscaley

local background
local text
local score_text
local background2
local quitButton
local replayButton
local lose_text

local tick
local timer
local show = true

--Initialize random generator
math.randomseed( os.time() )

--Click Sensor
function touchListener(self, event)
    -- .touched is a custom value we are using to tracks which finger if any is currently held down for the node
    if self.touched and event.id ~= self.touched then
        return --ignore other fingers once pressed
    end
     
    if not event.target then
        -- listener being called for system, not node
        --After user clicks button, reset to normal size and color
        if self.touched and event.id == self.touched and event.phase == "ended"  and gamemode == 1 then
            -- finger released whether over top of node or not
            self.touched = nil
            self.xScale = buttonscalex
            self.yScale = buttonscaley
            self.color.r = 180
            self.color.g = 180
            self.color.b = 180
            -- If user clicks wrong button, they lose
            if self.sound ~= buttons[sequence[playcursor]].sound then
              lose = true
            end
            if lose == false then
              playcursor = playcursor + 1
            end
        end
        return
    end
     
    -- listener called for node, not system
    if event.phase == "ended" then
        self.touched = nil
    --When user clicks button
    elseif event.phase == "began" and gamemode == 1 and lose == false then
        self.touched = event.id -- track which finger was held down on the node
        -- If user clicks wrong button, play buzzer
        if self.sound ~= buttons[sequence[playcursor]].sound then
          audio:playSound("sounds/wrong.pcm")
          lose = true
        -- Play button's sound when it is clicked
        else
          audio:playSound(sounds[self.sound])
        end
        -- Shrink and light up button when it is clicked
        self.xScale = 0.9 * buttonscalex
        self.yScale = 0.9 * buttonscaley
        self.color.r = 255
        self.color.g = 255
        self.color.b = 255
    end
end

--Reset when user advances levels
function reset()
  gamemode = 0
  playcursor = 1
end

--Add another button randomly to the sequence
function addToSequence()
  local rand = math.random(0, 3)
  table.insert(sequence, rand)
  playcursor = 1
  gamemode = 0
end

--Play the next button in the sequence
function playNext()
  local j = sequence[playcursor]
  if even == 0 then
    audio:playSound(sounds[buttons[j].sound])
    buttons[j].xScale = 0.9 * buttonscalex
    buttons[j].yScale = 0.9 * buttonscaley
    buttons[j].color.r = 255
    buttons[j].color.g = 255
    buttons[j].color.b = 255
    even = even + 1
  elseif even == 1 then
    buttons[j].xScale = buttonscalex
    buttons[j].yScale = buttonscaley
    buttons[j].color.r = 180
    buttons[j].color.g = 180
    buttons[j].color.b = 180
    even = even + 1
  end
end

--Play sound and change buttons to indicate that user played correct sequence
function playCorrect()
  if even == 0 then
    audio:playSound("sounds/correct.pcm")
    for t = 0, 3 do
      buttons[t].xScale = 0.9 * buttonscalex
      buttons[t].yScale = 0.9 * buttonscaley
      buttons[t].color.r = 255
      buttons[t].color.g = 255
      buttons[t].color.b = 255
    end
    even = even + 1
  elseif even == 1 then
    for t = 0, 3 do
      buttons[t].xScale = buttonscalex
      buttons[t].yScale = buttonscaley
      buttons[t].color.r = 180
      buttons[t].color.g = 180
      buttons[t].color.b = 180
    end
    even = even + 1
  end
end

-- Play silence to initialize playSound function
audio:playSound("sounds/blank.pcm")

--When quit button is clicked
function Quit(event)
  if event.phase == "ended" then
    system:quit()
  end
end

--When replay is clicked
function Replay(event)
  if event.phase == "ended" then
    Clear()
    sequence = {}
    playcursor = 1
    gamemode = 0
    level = 1
    lose = false
    even = 0
    show = true
  end
end

--Show or hide elements on screen when user loses or replays
function Clear()
  if show == true then
    background2.alpha = 1
    quitButton.alpha = 1
    replayButton.alpha = 1
    lose_text.alpha = 1
    score_text.zOrder = 10
    score_text.y = height/5
    score_text.color = color.orange
    quitButton:addEventListener("touch", Quit)
    replayButton:addEventListener("touch", Replay)
    local data ={}
    local pathS = system:getFilePath("storage", "")
    local file = io.open(pathS .. "data.txt", "r")
    local a = file:read("*a")
    data = json.decode(a)
    
    local highscore = data.bestScore
    file:close()
    
    if level - 1 > highscore then
      dbg.print('new high score!')
      highscore = level - 1
      data.bestScore = highscore
    end
    
    local newData = json.encode(data)
    local file = io.open(pathS .. "data.txt", "w")
    file:write(newData)
    file:close()
    
    highscore_text.text = "Highscore: " .. highscore
    highscore_text.alpha = 1
  else
    background2.alpha = 0
    quitButton.alpha = 0
    replayButton.alpha = 0
    lose_text.alpha = 0
    highscore_text.alpha = 0
    score_text.y = height/25
    score_text.color = color.white
    quitButton:removeEventListener("touch", Quit)
    replayButton:removeEventListener("touch", Replay)
  end
end

--Set up game scene
function gameScene:setUp(event)
  button_width = .3125 * width
  button_height = .260417 * height
  buttonscalex = button_width / 100
  buttonscaley = button_height / 125
  buttons = {}
  sounds = {}
  sequence = {}
  playcursor = 1
  gamemode = 0
  level = 1
  lose = false
  even = 0
  background = director:createSprite(0, 0, "gfx/background2.jpg")
  buttons[0] = director:createSprite({x = (width - button_width)/6 , y = 3 * (height - button_height)/4, source = "gfx/r.png", color={180, 180, 180}})
  buttons[0].sound = "a"
  buttons[0].touch = touchListener
  buttons[1] = director:createSprite({x = 5 * (width - button_width)/6, y = 3 * (height - button_height)/4, source = "gfx/t.png", color={180, 180, 180}})
  buttons[1].sound = "b"
  buttons[1].touch = touchListener
  buttons[2] = director:createSprite({x = (width - button_width)/6, y = (height - button_height)/4, source = "gfx/c.png", color={180, 180, 180}})
  buttons[2].sound = "c"
  buttons[2].touch = touchListener
  buttons[3] = director:createSprite({x = 5 * (width - button_width)/6, y = (height - button_height)/4, source = "gfx/l.png", color={180, 180, 180}})
  buttons[3].sound = "d"
  buttons[3].touch = touchListener
  for p = 0, 3 do
    buttons[p].xScale = buttonscalex
    buttons[p].yScale = buttonscaley
  end
  text = director:createLabel({x = 0, y = height - 30, text = "RoboTech Says...", hAlignment = "centre"})
  score_text = director:createLabel({x = 0, y = height/25, text = "Score: "..level-1, hAlignment = "centre"})
  background2 = director:createSprite(0, 0, "gfx/background3.jpg")
  quitButton = director:createSprite(width/8, height/2 - 0.15625*width, "gfx/quit.png")
  quitButton.xScale = (0.3125 * width)/240
  quitButton.yScale = (0.3125 * width)/240
  replayButton = director:createSprite(0.5625*width, height/2 - 0.15625*width, "gfx/replay.png")
  replayButton.xScale = (0.3125 * width)/240
  replayButton.yScale = (0.3125 * width)/240
  lose_text = director:createLabel({x = 0, y = height - 60, text = "Sorry, you lost! Try again!", hAlignment = "centre"})
  lose_text.color = color.orange
  highscore_text = director:createLabel({x = 0, y = .15625 * height, text = "", hAlignment = "centre"})
  highscore_text.color = color.orange
  background2.alpha = 0
  quitButton.alpha = 0
  replayButton.alpha = 0
  lose_text.alpha = 0
  highscore_text.alpha = 0
  for b = 0, 3 do 
    local letter = buttons[b].sound
    sounds[letter] = "sounds/"..letter..".pcm"
    audio:loadSound(sounds[letter])
    buttons[b]:addEventListener("touch", buttons[b])
    system:addEventListener("touch", buttons[b])
  end
  --Make game function, runs every half second
  tick = function(timer)
    if lose == false then
      score_text.text = "Score: "..level-1
      if gamemode == 0 then
        local i = #sequence
        while i < level + 2 do
          addToSequence()
          i = #sequence
        end
        if playcursor <= i then
          playNext()
          if even == 2 then
            playcursor = playcursor + 1
            even = 0
          end
        elseif playcursor == (i + 1) then
          for i = 0, 3 do
            buttons[i].xScale = buttonscalex
            buttons[i].yScale = buttonscaley
            buttons[i].color.r = 180
            buttons[i].color.g = 180
            buttons[i].color.b = 180
          end
          gamemode = 1
          playcursor = 1
        end
      else
        if playcursor == level + 3 then
          playCorrect()
          if even == 2 then
            playcursor = playcursor + 1
            even = 0
          end
        elseif playcursor == level + 4 then
          level = level + 1
          reset()
        end
      end
    else
      if show == true then
        Clear()
        show = false
      end
    end
  end
  timer = system:addTimer(tick, 0.5, 0, 2)
  dbg.print("Game set up")
end
 
--Tear down game scene
function gameScene:tearDown(event)
  background = background:removeFromParent()
  for e = 0, 3 do
    buttons[e]:removeEventListener("touch", buttons[e])
    system:removeEventListener("touch", buttons[e])
    buttons[e] = buttons[e]:removeFromParent()
  end
  dbg.print("Game torn down")
end
 
gameScene:addEventListener({"setUp", "tearDown"}, gameScene)