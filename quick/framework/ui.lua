--[[

Copyright (c) 2011-2014 chukong-inc.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]

--[[--

创建和管理用户界面

]]
local ui = {}

ui.DEFAULT_TTF_FONT      = "Arial"
ui.DEFAULT_TTF_FONT_SIZE = 24

ui.TEXT_ALIGN_LEFT    = cc.TEXT_ALIGNMENT_LEFT
ui.TEXT_ALIGN_CENTER  = cc.TEXT_ALIGNMENT_CENTER
ui.TEXT_ALIGN_RIGHT   = cc.TEXT_ALIGNMENT_RIGHT
ui.TEXT_VALIGN_TOP    = cc.VERTICAL_TEXT_ALIGNMENT_TOP
ui.TEXT_VALIGN_CENTER = cc.VERTICAL_TEXT_ALIGNMENT_CENTER
ui.TEXT_VALIGN_BOTTOM = cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM

--[[--

创建一个文字输入框，并返回 EditBox 对象。

可用参数：

-   image: 输入框的图像，可以是图像名或者是 Sprite9Scale 显示对象。用 display.newScale9Sprite() 创建 Sprite9Scale 显示对象。
-   imagePressed: 输入状态时输入框显示的图像（可选）
-   imageDisabled: 禁止状态时输入框显示的图像（可选）
-   listener: 回调函数
-   size: 输入框的尺寸，用 cc.size(宽度, 高度) 创建
-   x, y: 坐标（可选）

~~~ lua

local function onEdit(event, editbox)
    if event == "began" then
        -- 开始输入
    elseif event == "changed" then
        -- 输入框内容发生变化
    elseif event == "ended" then
        -- 输入结束
    elseif event == "return" then
        -- 从输入框返回
    end
end

local editbox = ui.newEditBox({
    image = "EditBox.png",
    listener = onEdit,
    size = cc.size(200, 40)
})

~~~

注意: 使用setInputFlag(0) 可设为密码输入框。

注意：构造输入框时，请使用setPlaceHolder来设定初始文本显示。setText为出现输入法后的默认文本。

注意：事件触发机制，player模拟器上与真机不同，请使用真机实测(不同ios版本貌似也略有不同)。

注意：changed事件中，需要条件性使用setText（如trim或转化大小写等），否则在某些ios版本中会造成死循环。

~~~ lua

--错误，会造成死循环

editbox:setText(string.trim(editbox:getText()))

~~~

~~~ lua

--正确，不会造成死循环
local _text = editbox:getText()
local _trimed = string.trim(_text)
if _trimed ~= _text then
    editbox:setText(_trimed)
end

~~~

@param table params 参数表格对象

@return EditBox 文字输入框

]]
function ui.newEditBox(params)
    local imageNormal = params.image
    local imagePressed = params.imagePressed
    local imageDisabled = params.imageDisabled

    if type(imageNormal) == "string" then
        imageNormal = display.newScale9Sprite(imageNormal)
    end
    if type(imagePressed) == "string" then
        imagePressed = display.newScale9Sprite(imagePressed)
    end
    if type(imageDisabled) == "string" then
        imageDisabled = display.newScale9Sprite(imageDisabled)
    end

    local editbox = cc.EditBox:create(params.size, imageNormal, imagePressed, imageDisabled)

    if editbox then
        if params.listener then
            editbox:registerScriptEditBoxHandler(params.listener)
        end
        if params.x and params.y then
            editbox:setPosition(params.x, params.y)
        end
    end

    return editbox
end

--[[--

用位图字体创建文本显示对象，并返回 LabelBMFont 对象。

BMFont 通常用于显示英文内容，因为英文字母加数字和常用符号也不多，生成的 BMFont 文件较小。如果是中文，应该用 TTFLabel。

可用参数：

-    text: 要显示的文本
-    font: 字体文件名
-    align: 文字的水平对齐方式（可选）
-    x, y: 坐标（可选）

~~~ lua

local label = ui.newBMFontLabel({
    text = "Hello",
    font = "UIFont.fnt",
})

~~~

@param table params 参数表格对象

@return LabelBMFont LabelBMFont对象

]]
function ui.newBMFontLabel(params)
    assert(type(params) == "table",
           "[framework.ui] newBMFontLabel() invalid params")

    local text      = tostring(params.text)
    local font      = params.font
    local textAlign = params.align or ui.TEXT_ALIGN_CENTER
    local x, y      = params.x, params.y
    assert(font ~= nil, "ui.newBMFontLabel() - not set font")

    local label = cc.LabelBMFont:create(text, font, cc.LABEL_AUTOMATIC_WIDTH, textAlign)
    if not label then return end

    if type(x) == "number" and type(y) == "number" then
        label:setPosition(x, y)
    end

    if textAlign == ui.TEXT_ALIGN_LEFT then
        label:align(display.LEFT_CENTER)
    elseif textAlign == ui.TEXT_ALIGN_RIGHT then
        label:align(display.RIGHT_CENTER)
    else
        label:align(display.CENTER)
    end

    return label
end

--[[--

使用 TTF 字体创建文字显示对象，并返回 LabelTTF 对象。

可用参数：

-    text: 要显示的文本
-    font: 字体名，如果是非系统自带的 TTF 字体，那么指定为字体文件名
-    size: 文字尺寸，因为是 TTF 字体，所以可以任意指定尺寸
-    color: 文字颜色（可选），用 cc.c3b() 指定，默认为白色
-    align: 文字的水平对齐方式（可选）
-    valign: 文字的垂直对齐方式（可选），仅在指定了 dimensions 参数时有效
-    dimensions: 文字显示对象的尺寸（可选），使用 cc.size() 指定
-    x, y: 坐标（可选）

align 和 valign 参数可用的值：

-    ui.TEXT_ALIGN_LEFT 左对齐
-    ui.TEXT_ALIGN_CENTER 水平居中对齐
-    ui.TEXT_ALIGN_RIGHT 右对齐
-    ui.TEXT_VALIGN_TOP 垂直顶部对齐
-    ui.TEXT_VALIGN_CENTER 垂直居中对齐
-    ui.TEXT_VALIGN_BOTTOM 垂直底部对齐

~~~ lua

-- 创建一个居中对齐的文字显示对象
local label = ui.newTTFLabel({
    text = "Hello, World",
    font = "Marker Felt",
    size = 64,
    align = ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
})

-- 左对齐，并且多行文字顶部对齐
local label = ui.newTTFLabel({
    text = "Hello, World\n您好，世界",
    font = "Arial",
    size = 64,
    color = cc.c3b(255, 0, 0), -- 使用纯红色
    align = ui.TEXT_ALIGN_LEFT,
    valign = ui.TEXT_VALIGN_TOP,
    dimensions = cc.size(400, 200)
})

~~~

@param table params 参数表格对象

@return LabelTTF LabelTTF对象

]]
function ui.newTTFLabel(params)
    assert(type(params) == "table",
           "[framework.ui] newTTFLabel() invalid params")

    local text       = tostring(params.text)
    local font       = params.font or ui.DEFAULT_TTF_FONT
    local size       = params.size or ui.DEFAULT_TTF_FONT_SIZE
    local color      = params.color or display.COLOR_WHITE
    local textAlign  = params.align or ui.TEXT_ALIGN_LEFT
    local textValign = params.valign or ui.TEXT_VALIGN_CENTER
    local x, y       = params.x, params.y
    local dimensions = params.dimensions

    assert(type(size) == "number",
           "[framework.ui] newTTFLabel() invalid params.size")

    local label
    if dimensions then
        label = cc.LabelTTF:create(text, font, size, dimensions, textAlign, textValign)
    else
        label = cc.LabelTTF:create(text, font, size)
    end

    if label then
        label:setColor(color)

        function label:realign(x, y)
            if textAlign == ui.TEXT_ALIGN_LEFT then
                label:setPosition(math.round(x + label:getContentSize().width / 2), y)
            elseif textAlign == ui.TEXT_ALIGN_RIGHT then
                label:setPosition(x - math.round(label:getContentSize().width / 2), y)
            else
                label:setPosition(x, y)
            end
        end

        if x and y then label:realign(x, y) end
    end

    return label
end

--[[--

创建带阴影的 TTF 文字显示对象，并返回 LabelTTF 对象。

相比 ui.newTTFLabel() 增加一个参数：

-   shadowColor: 阴影颜色（可选），用 cc.c3b() 指定，默认为黑色

@param table params 参数表格对象

@return LabelTTF LabelTTF对象

]]
function ui.newTTFLabelWithShadow(params)
    assert(type(params) == "table",
           "[framework.ui] newTTFLabelWithShadow() invalid params")

    local color       = params.color or display.COLOR_WHITE
    local shadowColor = params.shadowColor or display.COLOR_BLACK
    local x, y        = params.x, params.y

    local g = display.newNode()
    params.size = params.size
    params.color = shadowColor
    params.x, params.y = 0, 0
    g.shadow1 = ui.newTTFLabel(params)
    local offset = 1 / (display.widthInPixels / display.width)
    g.shadow1:realign(offset, -offset)
    g:addChild(g.shadow1)

    params.color = color
    g.label = ui.newTTFLabel(params)
    g.label:realign(0, 0)
    g:addChild(g.label)

    function g:setString(text)
        g.shadow1:setString(text)
        g.label:setString(text)
    end

    function g:realign(x, y)
        g:setPosition(x, y)
    end

    function g:getContentSize()
        return g.label:getContentSize()
    end

    function g:setColor(...)
        g.label:setColor(...)
    end

    function g:setShadowColor(...)
        g.shadow1:setColor(...)
    end

    function g:setOpacity(opacity)
        g.label:setOpacity(opacity)
        g.shadow1:setOpacity(opacity)
    end

    if x and y then
        g:setPosition(x, y)
    end

    return g
end

--[[--

创建带描边效果的 TTF 文字显示对象，并返回 LabelTTF 对象。

相比 ui.newTTFLabel() 增加一个参数：

    outlineColor: 描边颜色（可选），用 cc.c3b() 指定，默认为黑色

@param table params 参数表格对象

@return LabelTTF LabelTTF对象

]]
function ui.newTTFLabelWithOutline(params)
    assert(type(params) == "table",
           "[framework.ui] newTTFLabelWithShadow() invalid params")

    local color        = params.color or display.COLOR_WHITE
    local outlineColor = params.outlineColor or display.COLOR_BLACK
    local x, y         = params.x, params.y

    local g = display.newNode()
    params.size  = params.size
    params.color = outlineColor
    params.x, params.y = 0, 0
    g.shadow1 = ui.newTTFLabel(params)
    g.shadow1:realign(1, 0)
    g:addChild(g.shadow1)
    g.shadow2 = ui.newTTFLabel(params)
    g.shadow2:realign(-1, 0)
    g:addChild(g.shadow2)
    g.shadow3 = ui.newTTFLabel(params)
    g.shadow3:realign(0, -1)
    g:addChild(g.shadow3)
    g.shadow4 = ui.newTTFLabel(params)
    g.shadow4:realign(0, 1)
    g:addChild(g.shadow4)

    params.color = color
    g.label = ui.newTTFLabel(params)
    g.label:realign(0, 0)
    g:addChild(g.label)

    function g:setString(text)
        g.shadow1:setString(text)
        g.shadow2:setString(text)
        g.shadow3:setString(text)
        g.shadow4:setString(text)
        g.label:setString(text)
    end

    function g:getContentSize()
        return g.label:getContentSize()
    end

    function g:setColor(...)
        g.label:setColor(...)
    end

    function g:setOutlineColor(...)
        g.shadow1:setColor(...)
        g.shadow2:setColor(...)
        g.shadow3:setColor(...)
        g.shadow4:setColor(...)
    end

    function g:setOpacity(opacity)
        g.label:setOpacity(opacity)
        g.shadow1:setOpacity(opacity)
        g.shadow2:setOpacity(opacity)
        g.shadow3:setOpacity(opacity)
        g.shadow4:setOpacity(opacity)
    end

    if x and y then
        g:setPosition(x, y)
    end

    return g
end

return ui
