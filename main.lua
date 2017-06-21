--
-- Abstract: Storyboard Chat Sample using AppWarp
--
--
-- Demonstrates use of the AppWarp API (connect, disconnect, joinRoom, subscribeRoom, chat )
--

display.setStatusBar( display.HiddenStatusBar )

local composer = require "composer"
local widget = require "widget"


composer.gotoScene("ConnectScene", "fade", 500)


-- load first scene
--composer.gotoScene( "start", "fade", 400 )

-- Replace these with the values from AppHQ dashboard of your AppWarp app
API_KEY = ""
SECRET_KEY = ""
ROOM_ID = ""
USER_NAME = ""
USER_ID = ""
REMOTE_USER = ""
ROOM_ADMIN = ""

-- create global warp client and initialize it
appWarpClient = require "AppWarp.WarpClient"
appWarpClient.initialize(API_KEY, SECRET_KEY)

--appWarpClient.enableTrace(true)

-- IMPORTANT! loop WarpClient. This is required for receiving responses and notifications
local function gameLoop(event)
  appWarpClient.Loop()
end

Runtime:addEventListener("enterFrame", gameLoop)
