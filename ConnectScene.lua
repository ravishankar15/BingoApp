

-----------------------------------------------------------------------------------------
            --ConnectScene.lua
-----------------------------------------------------------------------------------------

local composer = require "composer"
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called
-- -----------------------------------------------------------------------------------------------------------------

-- Local forward references should go here

-- -------------------------------------------------------------------------------

halfW = display.contentWidth*0.5
halfH = display.contentHeight*0.5


local textOptions =
{
    --parent = textGroup,
    text = "",
    x = 150,
    y = 100,
    font = native.systemFontBold,
    fontSize = 24
}



local function onPlayTouch(event)
  if(event.phase == "began") then
    print( "Touch" )
    statusText = display.newText( "Connecting..", 150, 100, native.systemFontBold, 24 )
    statusText.x = 100
    statusText.y = 50
    reloadtext.alpha = 1
  	statusText:setTextColor( 115 )
    event.target:removeSelf()
    USER_NAME = tostring(os.clock())
    print( USER_NAME )
    appWarpClient.connectWithUserName(USER_NAME) -- join with a random name
  end
end

local function onReload(event)
  if(event.phase == "began") then
    print( "Reload" )
    event.target:removeSelf()
    appWarpClient.unsubscribeRoom(ROOM_ID)
    appWarpClient.leaveRoom(ROOM_ID)
    appWarpClient.deleteRoom(ROOM_ID)
    appWarpClient.disconnect()
  end
end

-- "scene:create()"
function scene:create( event )

	-- Initialize the scene here
	-- Example: add display objects to "sceneGroup", add touch listeners, etc.
    local sceneGroup = self.view
    local bg = display.newImage("images/bgred.png",halfW,halfH)
    local play = display.newImage("images/play.png", halfW,halfH)
    sceneGroup:insert(bg)
    sceneGroup:insert(play)

end

function scene.onConnectDone(resultCode)
  print( "onConnectDone" )
  if(resultCode == WarpResponseResultCode.SUCCESS) then
    statusText.text = "Joining room.."
    appWarpClient.joinRoomInRange (1, 1, false)
  else
    print("Failure")
    statusText.text = "onConnectDone: Failed"..resultCode;
  end

end

function scene.onDisconnectDone(resultCode)
  print( "onDisconnectDone" )
  if(resultCode == WarpResponseResultCode.SUCCESS) then
    composer.gotoScene( "ConnectScene", "slideLeft", 800)
  else
    statusText.text = "onDisconnectDone: Failed"..resultCode;
  end
end

function scene.onJoinRoomDone(resultCode, roomId)
  print( "onJoinRoomDone" )
  if(resultCode == WarpResponseResultCode.SUCCESS) then
    appWarpClient.subscribeRoom(roomId)
  elseif(resultCode == WarpResponseResultCode.RESOURCE_NOT_FOUND) then
    -- no room found with one user creating new room
    local roomPropertiesTable = {}
    roomPropertiesTable["result"] = ""
    ROOM_ADMIN = USER_NAME
    appWarpClient.createTurnRoom ("BingoRoom", ROOM_ADMIN, 2, roomPropertiesTable, 10)
  else
    statusText.text = "onJoinRoomDone: failed"..resultCode
  end
end

function scene.onCreateRoomDone(resultCode, roomId, roomName)
  print( "onCreateRoomDone" )
  if(resultCode == WarpResponseResultCode.SUCCESS) then
    isNewRoomCreated = true;
    appWarpClient.joinRoom(roomId)
  else
    statusText.text = "onCreateRoomDone failed"..resultCode
  end
end

function scene.onSubscribeRoomDone(resultCode, roomId)
  print( "onSubscribeRoomDone" )
  if(resultCode == WarpResponseResultCode.SUCCESS) then
    ROOM_ID = roomId;
    if(isNewRoomCreated) then
      isNewRoomCreated = false
      waitForOtherUser()
    else
      startGame()
    end
  else
    statusText.text = "subscribeRoom failed"
  end
end

function scene.onUserJoinedRoom(userName, roomId)
  print( "onUserJoinedRoom" )
  if(roomId == ROOM_ID and userName ~= USER_NAME) then
    --connectButton:setLabel("Connect")
    startGame()
    --composer.gotoScene( "BingoScene", "slideLeft", 800)
  end
end

function startGame ()
  reloadtext.alpha = 0
  composer.gotoScene( "BingoScene", "slideDown", 800)
end

function waitForOtherUser ()
  statusText.text = "Waiting for user"
  reloadtext.alpha = 1
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
        print( "1: enterScene event" )
        statusText = display.newText( textOptions )
        reloadtext = display.newText( "RELOAD", halfW, halfH, native.systemFontBold, 24 )
        reloadtext:setFillColor(0,0,0)
        reloadtext.alpha = 0
        statusText:setTextColor( 115 )
        local bg = display.newImage("images/bgred.png",halfW,halfH)
        local play = display.newImage("images/play.png", halfW,halfH)

        sceneGroup:insert(statusText)
        sceneGroup:insert(bg)
        sceneGroup:insert(play)
        play:addEventListener("touch",onPlayTouch)
        reloadtext:addEventListener("touch",onReload)
      --countertext = display.newText("",200, 50, native.systemFontBold, 24)
        --timer.performWithDelay( 1000, listener)
      appWarpClient.addRequestListener("onConnectDone", scene.onConnectDone)
      appWarpClient.addRequestListener("onDisconnectDone", scene.onDisconnectDone)
      appWarpClient.addRequestListener("onJoinRoomDone", scene.onJoinRoomDone)
      appWarpClient.addRequestListener("onCreateRoomDone", scene.onCreateRoomDone)
      appWarpClient.addRequestListener("onSubscribeRoomDone", scene.onSubscribeRoomDone)
      appWarpClient.addNotificationListener("onUserJoinedRoom", scene.onUserJoinedRoom)
      print( "show scene" )

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
        statusText:removeSelf()
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


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene
