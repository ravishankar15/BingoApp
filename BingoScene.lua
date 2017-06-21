local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called
-- -----------------------------------------------------------------------------------------------------------------

-- Local forward references should go here
-- -------------------------------------------------------------------------------
local count=0
local ARRAY = {}
for i=0,4 do
  ARRAY[i] = {}
  for j=0,4 do
    ARRAY[i][j] = "-"
  end
end

local DARRAY = {}
for i=0,4 do
  DARRAY[i] = {}
  for j=0,4 do
    DARRAY[i][j] = "-"
  end
end

function doReset()
  count=0
  --sendmove = false
  for i=0,4 do
    ARRAY[i] = {}
    for j=0,4 do
      ARRAY[i][j] = "-"
    end
  end
  for i=0,4 do
    DARRAY[i] = {}
    for j=0,4 do
      DARRAY[i][j] = "-"
    end
  end
end

function addTextToGrid(value,s,t)
    score = display.newText(value, s,t, native.systemFontBold ,24)
    numbergroup:insert(score)
end

function calculateCentreValue(x,y,x1,y1)
  s = (x+x1)/2
  t = (y+y1)/2
  return s,t
end

function postGameWon(val)
  getTextObject(tostring(val))
  gamestate = false
  gametext.text = "WON"
  restarttext.alpha = 1
  numbertext:removeSelf()
  appWarpClient.sendMove(val .. "/" .. "Won")
end

function checkRowOrColumnFull(i,j,val)
  for s=0,4 do
    if( ROWID[i] == 0 and DARRAY[i][s] ~= "-") then
      rowflag = "R"
    else
      rowflag = "X"
      break
    end
  end
  if(rowflag == "R") then
    bingocount = bingocount + 1
    if(bingocount<5) then
      bingogroup[bingocount]:setFillColor(1, 0, 0.5)
    elseif(bingocount == 5) then
      bingogroup[bingocount]:setFillColor(1, 0, 0.5)
      postGameWon(val)
    end
  end
  for s=0,4 do
    if( COLUMNID[j] == 0 and DARRAY[s][j] ~= "-") then
      columnflag = "C"
    else
      columnflag = "X"
      break
    end
  end
  if(columnflag == "C") then
    bingocount = bingocount + 1
    if(bingocount<5) then
      bingogroup[bingocount]:setFillColor(1, 0, 0.5)
    elseif(bingocount == 5) then
      bingogroup[bingocount]:setFillColor(1, 0, 0.5)
      postGameWon(val)
    end
  end
end

function getIndex(touchX, touchY)
  if(touchX>START_X and touchX<START_X+GRID_WIDTH and touchY>START_Y and touchY<START_Y+GRID_WIDTH) then
    for i=0,4 do
      for j=0,4 do
        if ( touchX>(START_X+(j*GAP)) and touchX<(START_X+(j*GAP)+GAP) and touchY>(START_Y+(i*GAP)) and touchY<(START_Y+(i*GAP)+GAP) ) then
          if(sendmove == true and DARRAY[i][j] ~= "+") then
            DARRAY[i][j] = "+"
            checkRowOrColumnFull(i,j, ARRAY[i][j])
            appWarpClient.sendMove(ARRAY[i][j] .. "/" .. "")
          else
            return i,j
          end
        end
      end
    end
  end
end

function calculateCentre(touchX, touchY)
  if(touchX>START_X and touchX<START_X+GRID_WIDTH and touchY>START_Y and touchY<START_Y+GRID_WIDTH) then
    for i=0,4 do
      for j=0,4 do
        if ( touchX>(START_X+(j*GAP)) and touchX<(START_X+(j*GAP)+GAP) and touchY>(START_Y+(i*GAP)) and touchY<(START_Y+(i*GAP)+GAP) ) then
          s,t = calculateCentreValue(START_X+(j*GAP),START_Y+(i*GAP),START_X+(j*GAP)+GAP,START_Y+(i*GAP)+GAP)
          return s,t
        end
      end
    end
  end
end


function onTouch(event)
  if(event.phase == "began") then
    if(isReady == false) then
      gx,gy = getIndex(event.x,event.y)
      cgx,cgy = calculateCentre(event.x,event.y)
      if(count<=25 and ARRAY[gx][gy] == "-") then
        count = count+1
        ARRAY[gx][gy] = count
        addTextToGrid(ARRAY[gx][gy],cgx,cgy)
      else
        print( "Number already there" )
      end
    elseif(isReady == true and isUserTurn == true and gamestate == true) then
      sendmove = true
      getIndex(event.x,event.y)
    end
  end
end

function checkGridFull()
  for i=0,4 do
    for j=0,4 do
      if(ARRAY[i][j]=="-") then
        return false
      end
    end
  end
  return true
end

function readyTouch(event)
  if(event.phase == "began") then
    if(checkGridFull()) then
      isReady = true
      readytext.alpha = 0
      cleartext.alpha = 0
      if( ROOM_ADMIN == USER_NAME ) then
        appWarpClient.startGame()
        return
      end
    else
      print("fill grid")
    end
  end
end

function onRestart(event)
  if(event.phase == "began") then
    restarttext:removeSelf()
    bingogroup:removeSelf()
    numbergroup:removeSelf()
    gametext:removeSelf()
    exittext:removeSelf()
    grid:removeSelf()

    appWarpClient.unsubscribeRoom(ROOM_ID)
    appWarpClient.leaveRoom(ROOM_ID)
    appWarpClient.deleteRoom(ROOM_ID)
    appWarpClient.disconnect()
  end
end



function clearGrid(event)
  if(event.phase == "began") then
    if(isReady == false) then
      count = 0
      for i=0,4 do
        ARRAY[i] = {}
        for j=0,4 do
          ARRAY[i][j] = "-"
          display.remove( numbergroup )
          numbergroup = display.newGroup()
        end
      end
    end
  end
end


function exitScene(event)
  if(event.phase == "began") then
    --composer.gotoScene( "network", "slideLeft", 800)
    native.requestExit()
  end
end

-- To find the index of the value recived from the Opponent
function getIndexOfNumber(value)
  for i=0,4 do
    for j=0,4 do
      if(value == tostring( ARRAY[i][j] )) then
        return i,j
      end
    end
  end
end

-- The numbers in the Grid are text object
-- This function is to change the color of the Text object whose value is pressed
function getTextObject(value)
  for i=1,25 do
    if(value == tostring( numbergroup[i].text )) then
      numbergroup[i]:setFillColor( 1, 0, 0.5 )
      break
    end
  end
end

-- "scene:create()"
function scene:create( event )

    local sceneGroup = self.view
    -- Initialize the scene here
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.
    bg = display.newImage("images/bgred.png", halfW, halfH)
    --grid = display.newImage("images/grid.png", halfW, halfH)

    sceneGroup:insert(bg)
    --sceneGroup:insert(grid)
end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen)
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen
        -- Insert code here to make the scene come alive
        -- Example: start timers, begin animation, play audio, etc.
        if(ROOM_ADMIN == USER_NAME) then
          print( "your turn" )
        else
          print("Opponent turn")
        end


        GRID_WIDTH = 256
        OBJECT_WIDTH = 64
        GAP = 256/5
        isReady = false
        sendmove = false
        START_X = display.contentWidth/2-GRID_WIDTH/2
        START_Y = display.contentHeight/2-GRID_WIDTH/2
        numbergroup = display.newGroup()
        ROWID = {}
        COLUMNID = {}
        for i=0,4 do
          ROWID[i] = 0
          COLUMNID[i] = 0
        end
        doReset()
        -- Initialize the scene here
        -- Example: add display objects to "sceneGroup", add touch listeners, etc.
        bg = display.newImage("images/bgred.png", halfW, halfH)
        grid = display.newImage("images/grid.png", halfW, halfH)

        --username = display.newText(USER_NAME,55,20,native.systemFontBold ,24)

        btext = display.newText("B",55,55,native.systemFontBold ,50)
        itext = display.newText("I",55+GAP,55,native.systemFontBold ,50)
        ntext = display.newText("N",105+GAP,55,native.systemFontBold ,50)
        gtext = display.newText("G",155+GAP,55,native.systemFontBold ,50)
        otext = display.newText("O",205+GAP,55,native.systemFontBold ,50)

        bingocount = 0

        bingogroup = display.newGroup()
        bingogroup:insert(btext)
        bingogroup:insert(itext)
        bingogroup:insert(ntext)
        bingogroup:insert(gtext)
        bingogroup:insert(otext)

        exittext = display.newText("Exit", halfW-100, halfH+200,native.systemFontBold ,25)
        readytext = display.newText("Ready", halfW+100, halfH+200,native.systemFontBold ,25)
        cleartext = display.newText("Clear", halfW, halfH+200,native.systemFontBold ,25)
        gametext = display.newText("Welcome", halfW, halfH+160,native.systemFontBold ,20)
        numbertext = display.newText("", halfW+100, halfH+160,native.systemFontBold ,25)
        restarttext = display.newText("Restart", halfW+100, halfH+200,native.systemFontBold ,25)
        restarttext.alpha = 0
        print( "User" .. USER_NAME )
        --transition.fadeOut( gametext, { time=1000 } )
        --demoflag = 0

        sceneGroup:insert(bg)
        sceneGroup:insert(grid)

        grid:addEventListener("touch",onTouch)
        readytext:addEventListener("touch",readyTouch)
        cleartext:addEventListener("touch",clearGrid)
        exittext:addEventListener("touch",exitScene)
        restarttext:addEventListener("touch",onRestart)


        appWarpClient.addRequestListener("onConnectDone", scene.onConnectDone)
        appWarpClient.addRequestListener("onDisconnectDone", scene.onDisconnectDone)
        appWarpClient.addNotificationListener("onUserLeftRoom", scene.onUserLeftRoom)
        appWarpClient.addNotificationListener("onGameStarted", scene.onGameStarted)
        appWarpClient.addNotificationListener("onGameStopped", scene.onGameStopped)
        appWarpClient.addNotificationListener("onMoveCompleted", scene.onMoveCompleted)
    end
end

function scene.onConnectDone(resultCode)
  if(resultCode ~= WarpResponseResultCode.SUCCESS) then
    --statusText.text = "Connection Error.."
    --composer.loadScene( "main", "slideLeft", 800  )
  end
end

function scene.onGameStarted(sender, roomId, nextTurn)
  gamestate = true
  if(nextTurn == USER_NAME) then
    isUserTurn = true
    gametext.text = "Your Turn"
  else
    isUserTurn = false
    gametext.text = "Opponent Turn"
  end
end

function scene.onMoveCompleted(sender, roomId, nextTurn, moveData)
  if(gamestate) then
    if(nextTurn == USER_NAME) then
      gametext.text = "Your Turn"
      isUserTurn = true
    else
      gametext.text = "Opponent Turn"
      isUserTurn = false
    end
  end

  if(sender ~= USER_NAME) then
    if(string.len(moveData)>0) then
      valueparsed = string.sub(moveData, 0, string.find(moveData, "/")-1)
      state = string.sub(moveData, string.find(moveData, "/")+1, string.len(moveData))
      if(state ~= "Won") then
        -- To perform the operation on the mobile whose turn it was
        -- And to check if the user whose turn it was has won the game
        li,lj = getIndexOfNumber(valueparsed)
        DARRAY[li][lj] = "+"
        getTextObject(valueparsed)
        checkRowOrColumnFull(li,lj)
        numbertext.text = valueparsed
      elseif(state == "Won") then
        -- If the Opponent won the game
        getTextObject(valueparsed)
        gamestate = false
        gametext.text = "LOOSE"
        restarttext.alpha  = 1
        numbertext:removeSelf()
      end
    end
  elseif(gamestate == true and string.len(moveData)>0) then
    valuesent = string.sub(moveData, 0, string.find(moveData, "/")-1)
    getTextObject(valuesent)
  end
end


function scene.onGameStopped(sender, roomId)
   gamestate = false
  print( "Game stopped" )
end

function scene.onUserLeftRoom(userName, roomId)
--  if (isGameRunning and userName ~= USER_NAME) then
    --handleFinishGame("WIN", "OPPONENT_LEFT")
    print( "user left" )
  --end
end

function scene.onDisconnectDone(resultCode)
  print( "onDisconnectDone" )
  if(resultCode == WarpResponseResultCode.SUCCESS) then
    print( "success disconnect" )
    composer.gotoScene( "ConnectScene", "slideLeft", 800)
  else
    statusText.text = "onDisconnectDone: Failed"..resultCode;
  end
end



-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen)
        -- Insert code here to "pause" the scene
        -- Example: stop timers, stop animation, stop audio, etc.
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen
    end
end

-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view
    -- Insert code here to clean up the scene
    -- Example: remove display objects, save state, etc.
end


---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
