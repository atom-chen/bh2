ccui = ccui or {}

ccui.TouchEventType.state_change_to_normal = 4
ccui.TouchEventType.state_change_to_pressed = 5
ccui.TouchEventType.state_change_to_disabled = 6

ccui.ListViewEventType.onSelectedItem_start = ccui.ListViewEventType.ONSELECTEDITEM_START
ccui.ListViewEventType.onSelectedItem_end = ccui.ListViewEventType.ONSELECTEDITEM_END

local p = uber.PACKAGE_NAME .. ".ccui"

cclog("required ccui module")
if not cc then
    cclog("ccui module must be before required cocos2dx.lua!")
end

UI_WIDGET		= "Widget"
UI_BUTTON		= "Button"
UI_CHECKBOX		= "CheckBox"
UI_IMAGEVIEW	= "ImageView"
UI_LABEL 		= "Text"
UI_LABELATLAS	= "TextAtlas"
UI_LABELBMFONT  = "TextBMFont"
UI_LOADINGBAR	= "LoadingBar"
UI_PANEL 		= "Layout"
UI_SCROLLVIEW	= "ScrollView"
UI_SLIDER		= "Slider"
UI_TEXTFIELD	= "TextField"
UI_DRAGPANEL	= "DragPanel"
UI_LISTVIEW		= "ListView"
UI_PAGEVIEW		= "PageView"
UI_SCALE9SPRITE = "Scale9Sprite"

SET_POS = function(widget,x,y)
    if type(x) == "number" and type(y) == "number" then
        widget:setPosition(cc.p(x,y))
    end
end

ccui.DEFAULT_TTF_FONT        = "宋体"
ccui.DEFAULT_TTF_FONT_SIZE   = function() return pix(20) end
ccui.DEFAULT_INPUT_HOLDER    = "在这里输入"
ccui.DEFAULT_TEXTAREA_SIZE   = function() return uber.size(40,40) end
ccui.DEFAULT_CAPINSETS       = cc.rect(0, 0, 0, 0)
ccui.DEFAULT_LAYOUT_SIZE     = function() return uber.size(280,150) end
ccui.COLOR_WHITE             = cc.c3b(255,255,255)

ccui.DEFAULT_BUTTON_NORMAL = "Default/Button_Normal.png"
ccui.DEFAULT_BUTTON_PRESSED = "Default/Button_Press.png"
ccui.DEFAULT_BUTTON_DISABLED = "Default/Button_Disable.png"

ccui.DEFAULT_LABELATLAS = "Default/"

ccui.DEFAULT_IMAGE = "Default/Sprite.png"

ccui.DEFAULT_LABELBMFONT = "Default/defaultBMFont.png"
ccui.DEFAULT_LABELBMFONT_TEXT = "abc"

ccui.DEFAULT_CHECKBOX_NORMAL    = "Default/CheckBox_Normal.png"
ccui.DEFAULT_CHECKBOX_PRESSED   = "Default/CheckBox_Press.png"
ccui.DEFAULT_CHECKBOX_ACTIVE    = "Default/CheckBoxNode_Normal.png"
ccui.DEFAULT_CHECKBOX_N_DISABLE = "Default/CheckBox_Disable.png"
ccui.DEFAULT_CHECKBOX_A_DISABLE = "Default/CheckBoxNode_Disable.png"

ccui.DEFAULT_SLIDER_BAR         = "Default/Slider_Back.png"
ccui.DEFAULT_SLIDER_PROGRESS    = "Default/Slider_PressBar.png"
ccui.DEFAULT_SLIDER_BALL_N      = "Default/SliderNode_Normal.png"
ccui.DEFAULT_SLIDER_BALL_P      = "Default/SliderNode_Press.png"
ccui.DEFAULT_SLIDER_BALL_D      = "Default/SliderNode_Disable.png"

ccui.DEFAULT_LOADINGBAR         = "Default/LoadingBarFile.png"

require(p..".WidgetEx")
require(p..".CheckBoxEx")
require(p..".TextFieldEx")
require(p..".SliderEx")
require(p..".LayerEx")
require(p..".LayoutEx")
require(p..".ScrollViewEx")
require(p..".PageViewEx")
require(p..".ListViewEx")

widget_table = 
{
    [UI_WIDGET]      = { name = "Widget",      create = function() return ccui.Widget:create() end,      extend = function(uiwidget) return CCSWidgetExtend.extend(uiwidget) end},
    [UI_BUTTON]      = { name = "Button",      create = function() return ccui.Button:create() end,      extend = function(uiwidget) return CCSWidgetExtend.extend(uiwidget) end},
    [UI_CHECKBOX]    = { name = "CheckBox",    create = function() return ccui.CheckBox:create() end,    extend = function(uiwidget) return CCSCheckBoxExtend.extend(uiwidget) end},
    [UI_IMAGEVIEW]   = { name = "ImageView",   create = function() return ccui.ImageView:create() end,   extend = function(uiwidget) return CCSWidgetExtend.extend(uiwidget) end},
    [UI_LABEL]       = { name = "Text",        create = function() return ccui.Text:create() end,       extend = function(uiwidget) return CCSWidgetExtend.extend(uiwidget) end},
    [UI_LABELATLAS]  = { name = "TextAtlas",   create = function() return ccui.TextAtlas:create() end,  extend = function(uiwidget) return CCSWidgetExtend.extend(uiwidget) end},
    [UI_LABELBMFONT] = { name = "TextBMFont",  create = function() return ccui.TextBMFont:create() end, extend = function(uiwidget) return CCSWidgetExtend.extend(uiwidget) end},
    [UI_LOADINGBAR]  = { name = "LoadingBar",  create = function() return ccui.LoadingBar:create() end,  extend = function(uiwidget) return CCSWidgetExtend.extend(uiwidget) end},
    [UI_PANEL]       = { name = "Layout",      create = function() return ccui.Layout:create() end,      extend = function(uiwidget) return CCSLayoutExtend.extend(uiwidget) end},
    [UI_SCROLLVIEW]  = { name = "ScrollView",  create = function() return ccui.ScrollView:create() end,  extend = function(uiwidget) return CCSScrollViewExtend.extend(uiwidget) end},
    [UI_SLIDER]      = { name = "Slider",      create = function() return ccui.Slider:create() end,      extend = function(uiwidget) return CCSSliderExtend.extend(uiwidget) end},
    [UI_TEXTFIELD]   = { name = "TextField",   create = function() return ccui.TextField:create() end,   extend = function(uiwidget) return CCSTextFieldExtend.extend(uiwidget) end},
    [UI_DRAGPANEL]   = { name = "DragPanel",   create = function() return ccui.DragPanel:create() end,   extend = function(uiwidget) return CCSScrollViewExtend.extend(uiwidget) end},
    [UI_LISTVIEW]    = { name = "ListView",    create = function() return ccui.ListView:create() end,    extend = function(uiwidget) return CCSListViewExtend.extend(uiwidget) end},
--  [UI_LISTVIEWEX]  = { name = "ListViewEx",  create = function() return ccui.ListViewEx:create() end,  extend = function(uiwidget) return CCSListViewExExtend.extend(uiwidget) end},
    [UI_PAGEVIEW]    = { name = "PageView",    create = function() return ccui.PageView:create() end,    extend = function(uiwidget) return CCSPageViewExtend.extend(uiwidget) end},
    [UI_SCALE9SPRITE]= {name = "PageView",    create = function() return ccui.Scale9Sprite:create() end, extend = function(uiwidget) return CCSWidgetExtend.extend(uiwidget) end},
 }

function ccui.layer()
	local layer = cc.Layer:create()
	return layer
end

function ccui.widget(params)
    assert(type(params) == "table", "[ccui.widget] invalid params")
    local widget = widget_table[UI_WIDGET].create()
    if widget:init(params) == false then
        assert(false,"[ccui.widget] failed to initialize!")
        return nil
    end
    return widget
end

function ccui.button(params)
    --assert(type(params) == "table","[ccui.button] invalid params")
    params = params or {}
    local normal    = params.normal or ccui.DEFAULT_BUTTON_NORMAL
    local pressed   = params.pressed or ccui.DEFAULT_BUTTON_PRESSED
    local disabled  = params.disabled or ccui.DEFAULT_BUTTON_DISABLED
    local scale9    = params.scale9 or false
    local capInsets = params.capInsets or ccui.DEFAULT_CAPINSETS
    local text      = params.text

	local button = widget_table[UI_BUTTON].create()
    
    if button:init(params) == false then
        assert(false,"[ccui.button] failed to initialize!")
        return nil
    end

    button:loadTextures(normal,pressed,disabled)

    if params.size then
        button:setSize(params.size)
    end
    
    if scale9 == true then
        button:setScale9Enabled(scale9)
        button:setCapInsets(capInsets)
    end

    if text and type(text) == "string" then
        button:setTitleText(text)
    end

    return button
end

function ccui.label(params)
    --assert(type(params) == "table","[ccui.label] invalid params")
    params = params or {}
    local text      = tostring(params.text)
    local font      = params.font or ccui.DEFAULT_TTF_FONT
    local fontSize  = params.fontSize or ccui.DEFAULT_TTF_FONT_SIZE()

    local label = widget_table[UI_LABEL].create()
    
    if label:init(params) == false then
        assert(false,"[ccui.label] failed to initialize!")
        return nil
    end
    label:setFontName(font)
    label:setFontSize(fontSize)
    if params.color ~= nil then
        label:setColor(params.color)
    end
    label:setString(text)

    return label
end

function ccui.TextArea(params)
    --assert(type(params) == "table", "[ccui.TextArea] invalid params")
    params = params or {}
    local areaSize      = params.size or ccui.DEFAULT_TEXTAREA_SIZE()
    assert(tolua.type(areaSize) == "table", "[ccui.TextArea] invalid params.size")
    local h_alignment   = params.H_alignment
    local v_alignment   = params.A_alignment
    local textArea      = ccui.label(params)

    textArea:setTextAreaSize(areaSize)
    if h_alignment then
        textArea:setTextHorizontalAlignment(h_alignment)
    end
    if v_alignment then
        textArea:setTextVerticalAlignment(v_alignment)
    end

    return textArea
end

function ccui.labelAtlas(params)
    --assert(type(params) == "table","[ccui.labelAtlas] invalid params")
    params = params or {}
    local text      = params.text or "0"
    local start     = params.start or "0"
    local image     = params.image or ccui.DEFAULT_LABELATLAS
    assert(image and type(image) == "string", "[ccui.labelAtlas] invalid params.image")
    local width     = params.w or 1
    local height    = params.h or 1

    local labelAtlas = widget_table[UI_LABELATLAS].extend(widget_table[UI_LABELATLAS].create())
    
    if labelAtlas:init(params) == false then
        assert(false,"[ccui.labelAtlas] failed to initialize!")
        return nil
    end

    if image then
        labelAtlas:setProperty(text,image,width,height,start)
    end

    return labelAtlas
end

function ccui.image(params)
    --assert(type(params) == "table","[ccui.image] invalid params")
    params = params or {}
    local image = params.image or ccui.DEFAULT_IMAGE
    assert(image and type(image) == "string", "[ccui.image] invalid params.image")
    cclog("0000000000")
    print("image name:"..image)
    local imageView = widget_table[UI_IMAGEVIEW].create()

    cclog("1111111111")
    if imageView:init(params) == false then
        assert(false,"[ccui.image] failed to initialize!")
        return nil
    end

    params.loadType = params.loadType or ccui.TextureResType.localType
    if image then
        imageView:loadTexture(image,params.loadType)
    end

    return imageView
end

function ccui.scale9Sprite(params)
    assert(type(params) == "table","[ccui.scale9Sprite] invalid params")
    local image = params.image
    local rect = params.rect or ccui.DEFAULT_CAPINSETS
    assert(image and type(image) == "string", "[ccui.scale9Sprite] invalid params.image")
    local scale9Sprite = widget_table[UI_SCALE9SPRITE].create()
    --[[
    if scale9Sprite:init(params) == false then
        assert(false,"[ccui.image] failed to initialize!")
        return nil
    end]]

    scale9Sprite:initWithFile(image,rect)

    return scale9Sprite
end

function ccui.labelBMFont(params)
    --assert(type(params) == "table","[ccui.labelBMFont] invalid params")
    params = params or {}
    local font      = params.font or ccui.DEFAULT_LABELBMFONT
    assert(font and type(font) == "string","[ccui.labelBMFont] invalid params.font")
    local text      = params.text or ccui.DEFAULT_LABELBMFONT_TEXT

    local labelBMF = widget_table[UI_LABELBMFONT].create()

    if labelBMF:init(params) == false then
        assert(false,"[ccui.labelBMF] failed to initialize!")
        return nil
    end
    
    labelBMF:setFntFile(font)
    labelBMF:setString(text)

    return labelBMF
end

function ccui.checkBox(params)
    --assert(type(params) == "table","[ccui.checkBox] invalid params")
    params = params or {}
    local normal            = params.normal or ccui.DEFAULT_CHECKBOX_NORMAL
    local pressed           = params.pressed or ccui.DEFAULT_CHECKBOX_PRESSED
    local active            = params.active or ccui.DEFAULT_CHECKBOX_ACTIVE
    local normal_disable    = params.n_disable or ccui.DEFAULT_CHECKBOX_N_DISABLE
    local active_disable    = params.a_disable or ccui.DEFAULT_CHECKBOX_A_DISABLE
    local checkboxListener  = params.checkboxListener
    assert(normal and type(normal) == "string","[ccui.checkBox] invalid params.normal")
    
    local checkBox = widget_table[UI_CHECKBOX].create()

    if checkBox:init(params) == false then
        assert(false,"[ccui.checkBox] failed to initialize!")
        return nil
    end

    checkBox:loadTextures(normal,pressed,active,normal_disable,active_disable)
    
    if checkboxListener then
        checkBox:addCheckBoxEvent(checkboxListener)
    end

    return checkBox
end

function ccui.slider(params)
    --assert(type(params) == "table","[ccui.slider] invalid params")
    params = params or {}
    local bar_image        = params.bar or ccui.DEFAULT_SLIDER_BAR
    local progress         = params.progress or  ccui.DEFAULT_SLIDER_PROGRESS
    local ball_normal      = params.ball_n or  ccui.DEFAULT_SLIDER_BALL_N
    local ball_pressed     = params.ball_p or  ccui.DEFAULT_SLIDER_BALL_P
    local ball_disable     = params.ball_d or  ccui.DEFAULT_SLIDER_BALL_D
    local capInsets        = params.capInsets or ccui.DEFAULT_CAPINSETS
    assert(tolua.type(capInsets) == "table", "[ccui.slider] invalid params.capInsets")
    local size             = params.size
    local eventHandle      = params.eventHandle

    local slider = widget_table[UI_SLIDER].create()

    if slider:init(params) == false then
        assert(false,"[ccui.slider] failed to initialize!")
        return nil
    end

    slider:loadBarTexture(bar_image)
    slider:loadSlidBallTextures(ball_normal,ball_pressed,ball_disable)
    slider:loadProgressBarTexture(progress)

    --开启9宫格模式
    if size then
        slider:setScale9Enabled(true)
        slider:setCapInsets(capInsets)
        slider:setSize(size)
    end

    if eventHandle then
        slider:addSliderEvent(eventHandle)
    end

    return slider
end

function ccui.loadingbar(params)
    --assert(type(params) == "table","[ccui.loadingbar] invalid params")
    params = params or {}
    local image     = params.image or ccui.DEFAULT_LOADINGBAR
    local percent   = params.percent or 100 
    local direction = params.dir

    local loadingbar = widget_table[UI_LOADINGBAR].create()

    if loadingbar:init(params) == false then
        assert(false,"[ccui.loadingbar] failed to initialize!")
        return nil
    end

    loadingbar:loadTexture(image)
    loadingbar:setPercent(percent)

    if direction then
        loadingbar:setDirection(direction)
    end

    return loadingbar
end

function ccui.textField(params)
    --assert(type(params) == "table","[ccui.textField] invalid params")
    params = params or {}
    local font              = params.font or ccui.DEFAULT_TTF_FONT
    local fontSize          = params.fontSize or ccui.DEFAULT_TTF_FONT_SIZE()
    local placeHolder       = params.holder or ccui.DEFAULT_INPUT_HOLDER
    local maxLength         = params.max
    local password          = params.password or false
    local passwordText      = params.passwordText or "*"
    local textFieldListener = params.textFieldListener

    local textField = widget_table[UI_TEXTFIELD].create()

    if textField:init(params) == false then
        assert(false,"[ccui.textField] failed to initialize!")
        return nil
    end

    textField:setFontName(font)
    textField:setFontSize(fontSize)
    textField:setPlaceHolder(placeHolder)

    if maxLength then
        if type(maxLength) == "number" then
            textField:setMaxLengthEnabled(true)
            textField:setMaxLength(maxLength)
        else
            assert(false,"[ccui.textField] invalid params.maxLength")
        end
    end

    if password == true then
        textField:setPasswordEnabled(true)
        textField:setPasswordStyleText(passwordText)
    end

    if textFieldListener then
        textField:addTextFieldEvent(textFieldListener)
    end

    return textField
end

--
-- layout group
--

function ccui.panel(params)
    --assert(type(params) == "table","[ccui.plane] invalid params")
    params = params or {}
    local panel = widget_table[UI_PANEL].create()

    if panel:initlayout(params) == false then
        assert(false, "[ccui.panel] failed to initialize!")
        return nil
    end

    return panel
end

function ccui.listView(params)
    --assert(type(params) == "table","[ccui.listView] invalid params")
    params = params or {}
    local direction = params.direction
    local listViewListener = params.listListener
    local gravity = params.gravity

    local listView = widget_table[UI_LISTVIEW].create()

    if listView:initlayout(params) == false then
        assert(false, "[ccui.listView] failed to initialize!")
        return nil
    end

    if direction then
        listView:setDirection(direction)
    end

    if listViewListener then
        listView:addListVeiwEvent(listViewListener)
    end

    if gravity then
        listView:setGravity(gravity)
    end

    return listView
end

function ccui.dragPanel(params)
    params.direction = ccui.ScrollViewDir.both
    local dragPanel = ccui.scrollView(params)
    return dragPanel
end

function ccui.scrollView(params)
    --assert(type(params) == "table","[ccui.scrollView] invalid params")
    params = params or {}
    local direction = params.direction
    local bounce    = params.bounce
    local inertia   = params.inertia
    local innerSize = params.innerSize
    local scrollViewListener = params.scrollListener

    local scrollView = widget_table[UI_SCROLLVIEW].create()

    if scrollView:initlayout(params) == false then
        assert(false, "[ccui.scrollView] failed to initialize!")
        return nil
    end
    
    if direction then
        scrollView:setDirection(direction)
    end

    if bounce then
        scrollView:setBounceEnabled(bounce)
    end

    if inertia then
        scrollView:setInertiaScrollEnabled(inertia)
    end

    if innerSize then
        scrollView:setInnerContainerSize(innerSize)
    else
        scrollView:setInnerContainerSize(scrollView:getSize())
    end

    if scrollViewListener then
        scrollView:addScrollViewEvent(scrollViewListener)
    end

    return scrollView
end

function ccui.pageView(params)
    --assert(type(params) == "table","[ccui.pageView] invalid params")
    params = params or {}
    local eventHandle = params.eventHandle
    local pageView = widget_table[UI_PAGEVIEW].create()

    if pageView:initlayout(params) == false then
        assert(false, "[ccui.pageView] failed to initialize!")
        return nil
    end

    if eventHandle then
        pageView:addPageViewEvent(eventHandle)
    end

    return pageView
end

function ccui.loadLayer(filename)
    local layer = ccui.layer()
    layer:load(filename)
    return layer
end
--[[
function ccui.loadWidget(filename)
    if INT then
        filename = INT.localeFilePath(filename)
    end
    local widget = ccs.GUIReader:getInstance():widgetFromJsonFile(filename)--cc.CSLoader:createNode(filename)
	return widget
end]]

function ccui.loadWidget(filename)
    if false then
        filename = INT.localeFilePath(filename)
    end

    local widget = nil
    if CCS_VER < 2 then
        if string.find(filename,"%.csb") then
            widget = ccs.GUIReader:getInstance():widgetFromBinaryFile(filename)
        elseif string.find(filename,"%.json") or string.find(filename,"%.ExportJson") then
            widget = ccs.GUIReader:getInstance():widgetFromJsonFile(filename)
        else
            assert(false,"Can't Load File [" .. filename "]! Wrong file format")
        end
    else
        widget = cc.CSLoader:createNode(filename)
        --[[
        local action = cc.CSLoader:createTimeline(filename)
        action:gotoFrameAndPlay(0,false)
        widget:runAction(action)]]
    end

    return widget
end

ccui.particle = function(filename)
    return require("Editor.ui.particle").new(filename)
end

ccui.plistNode = function (filename)
    --isplay.addSpriteFrames(filename)
    cc.SpriteFrameCache:getInstance():addSpriteFrames(filename)
    local dict = cc.FileUtils:getInstance():getValueMapFromFile(filename)
    local framesDict = dict["frames"] --valuemap<spriteFramename,Value>
    return framesDict
end

ccui.spineNode = function(fullpath)
    fullpath = cc.getFullPath(fullpath)
    return require("Editor.ui.spineNode").new(fullpath)
end

ccui.animationNode = function(filename)
    return require("Editor.ui.animationNode").new(filename)
end
