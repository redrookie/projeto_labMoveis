-----------------------------------------------------------------------------------------
--
-- view1.lua
--
-----------------------------------------------------------------------------------------

-- module imports
local composer = require('composer')
local widget = require('widget')
local audio = require('audio')
local easing = require('easing')
local transition = require('transition')

-- constants definitions
local _W, _H = display.contentWidth, 720
local _centerX, _centerY = display.contentCenterX, display.contentCenterY

local colors = {
    WHITE = {1, 1, 1},
    BLACK = {0, 0, 0},
    LT_GRAY = {.8, .8, .8},
    DK_GRAY = {.5, .5, .5}
}

-- load audio files
local spinSfx = audio.loadSound('assets/peao-do-bau-sfx.mp3')

-- instantiate scene/view
local scene = composer.newScene()

-- prepare scene/view
function scene:create(event)
    local sceneGroup = self.view

    -- create background as a white rectangle filling the screen
    local background = display.newRect( _centerX, _centerY, _W, _H )
    background:setFillColor(unpack(colors.WHITE))

    -- load and position image
    local img = display.newImage('img.png')
    img.x = _centerX
    img.y = _centerY - 50
    img.width = 200
    img.height = 200

    -- image callback function (to drag and drop)
    function img:touch(event)
        if event.phase == "began" then

            display.getCurrentStage():setFocus( event.target )
            self.markX = self.x    -- store x location of object
            self.markY = self.y    -- store y location of object
            self.isMoving = true

        elseif event.phase == "moved" then

            if self.isMoving then

                local x = (event.x - event.xStart) + self.markX
                local y = (event.y - event.yStart) + self.markY

                self.x, self.y = x, y

            end


        elseif event.phase == "ended"  or event.phase == "cancelled" then

            display.getCurrentStage():setFocus()
            self.isMoving = false

        end

        return true

    end
    img:addEventListener("touch", img)

    -- auxiliar function to reposition image
    local function resetAnimation()
        transition.to(img, { time = 1, rotation = 0 })
    end
    -- rotate image function
    local function spinImg(evt)
        if (evt.phase == "ended") then
            local duration = 10.057
            local spins = 20
            transition.to(img, {
                    time = duration * 1000,
                    rotation = spins * 360,
                    transition = easing.inCubic,
                    onStart = audio.play(spinSfx),
                    onComplete = resetAnimation,
                })
        end
    end
    -- animate button
    local bt_animate = widget.newButton({
            id = 'bt_animate',
            x = _centerX,
            y = _H/2,
            label = "Animate",
            labelColor = {default=colors.BLACK},
            shape = "roundedRect",
            fillColor = {default=colors.LT_GRAY, over=colors.LT_GRAY},
            onEvent = spinImg,
        })

--    -- select image function
--    local function selectImg(evt)
--        --        function onComplete(event)
--        --            if (event.completed) then
--        --                local img2 = display.newImage(event.url)
--        --                img2.x = _centerX
--        --                img2.y = _centerY - 50
--        --                img2.width = 200
--        --                img2.height = 200
--        --                sceneGroup:insert(img2)
--        --            end
--        --        end
--        --        media.selectPhoto ( { listener=onComplete, media.SavedPhotosAlbum } )
--
--        local function onPhotoComplete( event )
--            if ( event.completed ) then
--                local photo = event.target
--                local s = display.contentHeight / photo.height
--                photo:scale( s,s )
--            end
--        end
--
--        media.selectPhoto({listener = onPhotoComplete, mediaSource = media.PhotoLibrary})
--    end
--    -- select img
--    local bt_changeImg = widget.newButton({
--            id = 'bt_changeImg',
--            x = _centerX,
--            y = _H/2 + 75,
--            label = "Choose image",
--            labelColor = {default=colors.BLACK},
--            shape = "roundedRect",
--            fillColor = {default=colors.LT_GRAY, over=colors.LT_GRAY},
--            onEvent = selectImg,
--        })

    local latitude = widget.newButton({
            id = 'txt_Lat',
            x = _centerX-75,
            y = _H/2 + 75,
            label = "Latitude",
            labelColor = {default=colors.BLACK},
            shape = "roundedRect",
            fillColor = {default=colors.WHITE, over=colors.WHITE},
        })
    local longitude = widget.newButton({
            id = 'txt_Long',
            x = _centerX+75,
            y = _H/2 + 75,
            label = "Longitude",
            labelColor = {default=colors.BLACK},
            shape = "roundedRect",
            fillColor = {default=colors.WHITE, over=colors.WHITE},
        })

    local locationHandler = function( event )
        -- Check for error (user may have turned off location services)
        if ( event.errorCode ) then
            native.showAlert( "GPS Location Error", event.errorMessage, {"OK"} )
            print( "Location error: " .. tostring( event.errorMessage ) )
        else
            local latitudeText = string.format( '%.4f', event.latitude )
            latitude:setLabel("Latitude:\n"..latitudeText)

            local longitudeText = string.format( '%.4f', event.longitude )
            longitude:setLabel("Longitude:\n"..longitudeText)
        end
    end

    -- Activate location listener
    Runtime:addEventListener( "location", locationHandler )

    -- inserting all elements to scene/view
    sceneGroup:insert(background)
    sceneGroup:insert(latitude)
    sceneGroup:insert(longitude)
    sceneGroup:insert(img)
    sceneGroup:insert(bt_animate)
--    sceneGroup:insert(bt_changeImg)
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        -- Called when the scene is still off screen and is about to move on screen
    elseif phase == "did" then

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