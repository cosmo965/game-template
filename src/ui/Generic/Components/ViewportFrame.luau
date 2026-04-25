--[[
--Created Date: Monday March 24th 2025 6:48:39 pm CEST
--Author: Cosmovyz
-------
--Last Modified: Saturday April 18th 2026 10:29:27 pm CEST
--Modified By: Cosmovyz
--]]

local ContextActionService = game:GetService("ContextActionService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Sift = require(ReplicatedStorage.Packages.Sift)
local Promise = require(ReplicatedStorage.Packages.Promise)
local ReactSpring = require(ReplicatedStorage.Packages.ReactSpring)
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

local VIEWPORTS_FOLDER = workspace:WaitForChild("World"):WaitForChild("ViewportModels")

local function ViewportFrame(props: {
	modelScale: number?,
    cameraDistance: number?,
    isSpinning: boolean?,
    native: {}?,
    animation: Animation?,
    cframeOffset: CFrame?,
	model: Model,
})
    local viewportFrame = React.useRef()
    local worldModel = React.useRef()
    local camera = React.useRef()

    local isModelLoading, setIsModelLoading = React.useState(true)
    local model, setModel = React.useState()
    local modelExtentsSize, setModelExtentsSize = React.useState(Vector3.zero)
    
    -- TODO: lazy load
    
    React.useEffect(function()
        if not viewportFrame.current or not camera.current or not props.model then
            warn("No viewport or camera or model")
            return
        end

		if model then
			model:Destroy()
			setModel(nil)
		end
		
        setIsModelLoading(true)
		local function loadModel()
            return Promise.try(function()
                local _model = props.model:Clone()
                _model.Parent = VIEWPORTS_FOLDER

                -- set primary part to nil because it changes orientation axises too much sumn like that idk
                _model.PrimaryPart = nil
                
                local extentsSize = _model:GetExtentsSize()
                local wantedScale = props.modelScale or 1
                local scale = wantedScale --wantedScale / math.max(size.X, size.Y, size.Z)
                
                -- _model:ScaleTo(scale)
                _model.Parent = worldModel.current
                _model:PivotTo( CFrame.new(Vector3.zero) * (props.cframeOffset or CFrame.new()))

                setModel(_model)
                setModelExtentsSize(extentsSize)

                if props.animation then
                    local controller = _model:FindFirstChildOfClass("Humanoid") or _model:FindFirstChildOfClass("AnimationController")
                    
                    if controller and controller.Animator then
                        controller.Animator:LoadAnimation(props.animation):Play()
                    end
                end

                return _model
            end):catch(function(error)
                warn(error)
                return
            end):finally(function()
                setIsModelLoading(false)
            end)
            
        end
        
        local modelPromise = loadModel()

        return function()
            modelPromise:andThen(function(_model)
                if _model then
                    _model:Destroy()
                end
            end, warn, "Delete model failure")
        end

    end, { props.model })

    -- spin feature
    React.useEffect(function()
        if props.isSpinning then
            local conn
            conn = RunService.PreRender:Connect(function()
                if not camera.current or not viewportFrame.current then return end
                
                local t = os.clock()
        
                local x = math.sin(t) * props.cameraDistance or 10
                local z = math.cos(t) * props.cameraDistance or 10
                
                camera.current.CFrame = CFrame.lookAt(Vector3.new(x, 1, z), Vector3.zero)
            end)

            return function()
                conn:Disconnect()
            end
        end
        
    end, { camera.current, viewportFrame.current, props.isSpinning })

    React.useEffect(function()
        viewportFrame.current.CurrentCamera = camera.current
    end, { camera.current, viewportFrame.current })
    
    return e("ViewportFrame",
        Sift.Dictionary.merge({
            ref = viewportFrame,
            
            Position = UDim2.fromScale(0.5,0.5),
            AnchorPoint = Vector2.one / 2,
            Visible = model ~= nil,
		}, props.native or {}),
        {
            Camera = e("Camera", {
                ref = camera,
                CFrame = CFrame.new(Vector3.zAxis * -math.clamp(math.max(modelExtentsSize.X, modelExtentsSize.Y, modelExtentsSize.Z) * 1.1, 0, 30), Vector3.zero) -- (props.cameraDistance or 7.5)
            }),
            
            WorldModel = e("WorldModel", {
                ref = worldModel,
            })
        },
        props.children
    )
end

return ViewportFrame