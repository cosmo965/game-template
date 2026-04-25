--[[
--Created Date: Saturday October 4th 2025 4:49:27 pm CEST
--Author: Cosmovyz
-------
--Last Modified: Thursday April 23rd 2026 3:23:06 pm CEST
--Modified By: Cosmovyz
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local ReactReflex = require(Packages.ReactReflex)

local React = require(ReplicatedStorage.Packages.React)
local ReactSpring = require(ReplicatedStorage.Packages.ReactSpring)
local e = React.createElement

local usePx = require(script.Parent.Parent.Parent.Hooks.usePx)
local useRefToState = require(script.Parent.Parent.Parent.Hooks.useRefToState)

return function()
    local guiFocus = ReactReflex.useSelector(function(state)
        return state.UI.Generic.GUIFocus
    end)
    local prevGuiFocus = useRefToState(guiFocus)
    local ui = React.useRef()
    local container = React.useRef()
    local px = usePx()

    local uiVisibility, setUiVisibility = React.useState(false)
    local styles, api = ReactSpring.useSpring(function()
        return {
            strokeTransparency = 0,
            containerFrameTransparency = 1,
            containerPosition = UDim2.fromScale(0, 0),
            containerSize = UDim2.fromOffset(px(50), px(50))
        }
    end)

    React.useEffect(function()
        local connections = {}
        
        if ui.current and container.current then
            if guiFocus then
                api.start({
                    strokeTransparency = 0,
                    containerFrameTransparency = .6,

                    config = {
                        duration = 0.4
                    }
                })

                local function updatePosition()
                    local size = guiFocus.AbsoluteSize
                    local uiOffset = ui.current.AbsolutePosition
                    local position = guiFocus.AbsolutePosition + size / 2 - uiOffset
                    
                    local Tsize =  UDim2.fromOffset(size.X + px(20), size.Y + px(20))
                    local Tposition = UDim2.fromOffset(position.X, position.Y)
                    
                    api.start({
                        containerPosition = Tposition,
                        containerSize = Tsize,

                        config = {
                            easingStyle = ReactSpring.easings.linear,
                            duration = 0.1
                        }
                    })
                end

                table.insert(connections, ui.current:GetPropertyChangedSignal("AbsolutePosition"):Connect(updatePosition))
                table.insert(connections, guiFocus:GetPropertyChangedSignal("AbsoluteSize"):Connect(updatePosition))
                table.insert(connections, guiFocus:GetPropertyChangedSignal("AbsolutePosition"):Connect(updatePosition))
                updatePosition()

                setUiVisibility(true)
            else
                if prevGuiFocus.current == nil then
                    return
                end
                
                api.start({
                    strokeTransparency = 1,
                    containerFrameTransparency = 1,

                    config = {
                        duration = 0.2
                    }
                }):andThen(function()
                    if prevGuiFocus.current == nil then
                        return
                    end
                    setUiVisibility(false)
                end)
                
                return
            end
        end

        return function()
            for _, v in pairs(connections) do
                v:Disconnect()
            end
        end
    end, { guiFocus, ui, container })

    return e("Frame", {
        ref = ui,
        Size = UDim2.fromScale(1, 1),
        AnchorPoint = Vector2.one / 2,
        Position = UDim2.fromScale(0.5, 0.5),
        BackgroundTransparency = 1,
        Visible = uiVisibility,
        ZIndex = 100,
    }, {
        Container = e("Frame", {
            ref = container,
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position = styles.containerPosition,
            Size = styles.containerSize,
            Visible = guiFocus ~= nil,
        }, {
            Frame = e("Frame", {
                AnchorPoint = Vector2.new(0.5, 1),
                BackgroundColor3 = Color3.new(),
                BackgroundTransparency = styles.containerFrameTransparency,
                BorderColor3 = Color3.new(),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.5, 0),
                Size = UDim2.fromOffset(px(10000), px(10000)),
                ZIndex = 100,
            }),

            Frame2 = e("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Color3.new(),
                BackgroundTransparency = styles.containerFrameTransparency,
                BorderColor3 = Color3.new(),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.new(0, px(10000), 1, 0),
                ZIndex = 100,
            }),

            Frame3 = e("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Color3.new(),
                BackgroundTransparency = styles.containerFrameTransparency,
                BorderColor3 = Color3.new(),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(1, 0.5),
                Size = UDim2.new(0, px(10000), 1, 0),
                ZIndex = 100,
            }),

            Frame4 = e("Frame", {
                AnchorPoint = Vector2.new(0.5, 0),
                BackgroundColor3 = Color3.new(),
                BackgroundTransparency = styles.containerFrameTransparency,
                BorderColor3 = Color3.new(),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.5, 1),
                Size = UDim2.fromOffset(px(10000), px(10000)),
                ZIndex = 100,
            }),

            UIStroke = e("UIStroke", {
                Color = Color3.new(1, 1, 1),
                Thickness = 2,
                Transparency = styles.strokeTransparency,
            }),
        })
    })
end