
verCode = 
{
  none  = 0,
  last  = 1,  -- 最新
  revised = 2,  -- 修正版
  sub   = 3,  -- 次版本
  main  = 4,  -- 主版本
  deprecated = 5, -- 废弃]
  ver   = 12354, -- 版本号
  text    = "1.0.0",
}

if config.editor == false then
  CCS_VER = 2.1
else
  CCS_VER = 1.6
end

-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 1

-- display FPS stats on screen
DEBUG_FPS = true

-- dump memory info every 10 seconds
DEBUG_MEM = false

-- load deprecated API
LOAD_DEPRECATED_API = false

-- load shortcodes API
LOAD_SHORTCODES_API = true

-- screen orientation
CONFIG_SCREEN_ORIENTATION = "landscape"

-- design resolution
CONFIG_SCREEN_WIDTH  = 960
CONFIG_SCREEN_HEIGHT = 640

-- auto scale mode
--CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"
local frameSize = cc.Director:getInstance():getOpenGLView():getFrameSize()
if frameSize.width / frameSize.height > config.designWidth/config.designHeight then
    CONFIG_SCREEN_AUTOSCALE = "FIXED_HEIGHT"
else
    CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"
end
