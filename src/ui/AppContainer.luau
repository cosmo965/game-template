--[[
--Created Date: Saturday April 25th 2026 12:05:37 pm CEST
--Author: Cosmovyz
-------
--Last Modified: Friday April 25th 2026 12:00:00 pm CEST
--Modified By: Claude
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local React = require(Packages.React)
local ReactReflex = require(Packages.ReactReflex)
local RootProducer = require(ReplicatedStorage.Client.Features.Reflex.Controller)

local Components = script.Parent.Generic.Components

local ContextStack = require(Components.ContextStack)
local ErrorBoundary = require(Components.ErrorBoundary)
local ScreenInsetsDisabledContainer = require(Components.ScreenInsetsDisabledContainer)

local e = React.createElement

local function AppContainer(props: {
    onLoaded: () -> ()
})
    return e(React.Fragment, nil, {
        AppContainer = e("ScreenGui", {
            ref = props.onLoaded,
            ResetOnSpawn = false,
            IgnoreGuiInset = true,
            -- ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        }, {
            ContextStack = e(ContextStack, {
                -- Context providers go here
                -- Does not receive any other properties besides children
                providers = {
                    -- Wrapped reflex
                    function()
                        return ReactReflex.ReflexProvider({
                            producer = RootProducer.Store
                        })
                    end,
                },
            }, {
                -- Screens go here
                ErrorBoundary = e(ErrorBoundary, nil, {
                    Menus = e(require(script.Parent.Components.Menus)),
                    HUD = e(require(script.Parent.Components.HUD)),
                    Billboards = e(require(script.Parent.Components.Billboards)),
                }),
            })
        }),

        ScreenInsetsDisabledContainer = e("ScreenGui", {
            ResetOnSpawn = false,
            IgnoreGuiInset = true,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            ScreenInsets = Enum.ScreenInsets.None,
        }, {
            ContextStack = e(ContextStack, {
                providers = {
                    -- Wrapped
                    function()
                        return ReactReflex.ReflexProvider({
                            producer = RootProducer.Store
                        })
                    end,
                },
            }, {
                -- Screens go here
                ErrorBoundary = e(ErrorBoundary, nil, {
                    ScreenInsetsDisabledContainer = e(require(ScreenInsetsDisabledContainer)),
                }),
            })
        })
    })
end

return AppContainer
