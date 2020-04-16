-----------------------------------------------------------------------------------------
--
-- view2.lua
--
-----------------------------------------------------------------------------------------

-- module imports
local composer = require('composer')
local widget = require('widget')
local media = require('media')
local easing = require('easing')
local transition = require('transition')
local notifications = require('plugin.notifications.v2')

-- constants definitions
local _W, _H = display.contentWidth, 720
local _centerX, _centerY = display.contentCenterX, display.contentCenterY

local colors = {
    WHITE = {1, 1, 1},
    BLACK = {0, 0, 0},
    LT_GRAY = {.8, .8, .8},
    DK_GRAY = {.5, .5, .5}
}

local video

-- instantiate scene/view
local scene = composer.newScene()

-- prepare scene/view
function scene:create(event)
    local sceneGroup = self.view

    -- create background as a white rectangle filling the screen
    local background = display.newRect( _centerX, _centerY, _W, _H )
    background:setFillColor(unpack(colors.WHITE))

    video = native.newVideo( _centerX, 100, 320, 180 )
    
    -- video opening function
    local function openVideo(event)
        local function videoComplete( event )
            if ( event.completed ) then
                video:load( event.url, media.RemoteSource )
                video:play()
            end
        end

        media.selectVideo ( { listener=videoComplete , media.PhotoLibrary } )
    end

    -- video button
    local bt_video = widget.newButton({
            id = 'bt_video',
            x = _centerX,
            y = _H/10 * 4,
            label = "Load video",
            labelColor = {default=colors.BLACK},
            shape = "roundedRect",
            fillColor = {default=colors.LT_GRAY, over=colors.LT_GRAY},
        })
    -- video button callback function
    function bt_video:touch(event)
        if self.hasFocus and event.phase == "ended" then
            openVideo()
        end
        self.hasFocus = not self.hasFocus
    end
    bt_video:addEventListener("touch", bt_video)

    -- camera opening function
    local function openCamera()
        local cameraComplete = function()
            print("camera completed")
        end
        media.capturePhoto({cameraComplete})
    end
    -- camera button
    local bt_camera = widget.newButton({
            id = 'bt_camera',
            x = _centerX,
            y = _H/10 * 5,
            label = "Open camera",
            labelColor = {default=colors.BLACK},
            shape = "roundedRect",
            fillColor = {default=colors.LT_GRAY, over=colors.LT_GRAY},
        })
    -- camera button callback function
    function bt_camera:touch(event)
        if self.hasFocus and event.phase == "ended" then
            openCamera()
        end
        self.hasFocus = not self.hasFocus
    end
    bt_camera:addEventListener("touch", bt_camera)

    -- notify button callback function
    local function sendNotification()
        notifications.scheduleNotification(1, { alert = "Você foi notificado, meu amigo" })
    end
    -- notify button
    local bt_notify = widget.newButton({
            id = 'bt_notify',
            x = _centerX,
            y = _H/10 * 6,
            label = "Notify",
            labelColor = {default=colors.BLACK},
            shape = "roundedRect",
            fillColor = {default=colors.LT_GRAY, over=colors.LT_GRAY},
            onEvent = sendNotification,
        })

    local text = widget.newButton({
            id = 'txt_isShaking',
            x = _centerX,
            y = _H/10 * 3,
            label = "Chacoalha aí",
            labelColor = {default=colors.BLACK},
            shape = "roundedRect",
            fillColor = {default=colors.WHITE, over=colors.WHITE},
        })

    local function shaking(event)
        if event.isShake then
            text:setLabel("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
        else
            text:setLabel("Chacoalha aí")
        end
        return true
    end
    Runtime:addEventListener( "accelerometer", shaking )

    -- panel control variable
    local isPanelOpen = false

    local panelLimit = _W/3
    local panelExtension = 30

    -- panel background
    local panelBG = display.newRect(_W, -45, _W, _H - 205)
    panelBG.anchorY = 0
    panelBG.anchorX = 0

    -- function to change panel color / switch button callback function
    local togglePanelColor = function(evt)
        local panelColor = evt.target.isOn and colors.WHITE or colors.BLACK
        panelBG:setFillColor(unpack(panelColor))
    end

    -- switch button
    local switch_PanelColor = widget.newSwitch({
            id = 'switch_PanelColor',
            x = _W + 60,
            y = 100,
            onPress = togglePanelColor,
        })

    function slide(obj, finalX)
        transition.to(obj, {
                time = 0.7 * 1000,
                x = finalX,
                transition = easing.outCubic,
            })
    end

    local slidingArea = display.newRect(_W - panelExtension, 0, _W, _H - 205)
    slidingArea.anchorY = 0
    slidingArea.anchorX = 0
    slidingArea:setFillColor(unpack(colors.WHITE),0.1)

    -- panel sliding function
    function slidingArea:touch(event)
        if event.phase == "began" then
            display.getCurrentStage():setFocus( event.target )
            self.markX = self.x    -- store x location of object
            self.isMoving = true
            oldEventX = self.markX
        elseif event.phase == "moved" then
            if self.isMoving then
                local x = (event.x - event.xStart) + self.markX
                self.isClosing = event.x > oldEventX
                oldEventX = event.x
                if x >= panelLimit then
                    self.x = x-panelExtension
                    panelBG.x = x
                    switch_PanelColor.x = x+100

                    isPanelOpen = x < _W - panelExtension
                end
            end
        elseif event.phase == "ended"  or event.phase == "cancelled" then
            display.getCurrentStage():setFocus()
            self.isMoving = false
            if isPanelOpen and not self.isClosing then
                slide(self, panelLimit-panelExtension)
                slide(panelBG, panelLimit)
                slide(switch_PanelColor, panelLimit+100)
            elseif self.isClosing then
                slide(self, _W-panelExtension)
                slide(panelBG, _W)
                slide(switch_PanelColor, _W+100)
                isPanelOpen = false
            end
        end
        return true
    end
    slidingArea:addEventListener("touch", slidingArea)

    -- inserting all elements to scene/view
    sceneGroup:insert(background)
    sceneGroup:insert(video)
    sceneGroup:insert(bt_video)
    sceneGroup:insert(bt_camera)
    sceneGroup:insert(bt_notify)
    sceneGroup:insert(text)
    sceneGroup:insert(slidingArea)
    sceneGroup:insert(panelBG)
    sceneGroup:insert(switch_PanelColor)

end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        -- Called when the scene is still off screen and is about to move on screen
    elseif phase == "did" then
        -- Called when the scene is now on screen
        -- 
        -- INSERT code here to make the scene come alive
        -- e.g. start timers, begin animation, play audio, etc.
    end	
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if event.phase == "will" then
        -- Called when the scene is on screen and is about to move off screen
        --
        -- INSERT code here to pause the scene
        -- e.g. stop timers, stop animation, unload sounds, etc.)
    elseif phase == "did" then
        -- Called when the scene is now off screen
    end
end

function scene:destroy( event )
    local sceneGroup = self.view

    display.remove(video)
    video = nil
    -- Called prior to the removal of scene's "view" (sceneGroup)
    -- 
    -- INSERT code here to cleanup the scene
    -- e.g. remove display objects, remove touch listeners, save state, etc.
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
