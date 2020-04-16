-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- show default status bar (iOS)
display.setStatusBar(display.DefaultStatusBar)

-- module imports
local widget = require('widget')
local composer = require('composer')

-- functions to open scene/view
local function onFirstView(event)
	composer.gotoScene("view1")
end
local function onSecondView( event )
	composer.gotoScene("view2")
end

-- create tabBar (bottom menu)
local tabBar = widget.newTabBar{
	top = display.contentHeight - 10,
    buttons = {
        { label="First view", onPress=onFirstView, selected=true },
        { label="Second view", onPress=onSecondView },
    }
}

-- start on first scene/view
onFirstView()
