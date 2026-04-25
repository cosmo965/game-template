--[[
--Created Date: Friday February 28th 2025 9:56:33 pm CEST
--Author: Cosmovyz
-------
--Last Modified: Tuesday October 21st 2025 12:19:23 pm CEST
--Modified By: Cosmovyz
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local ReactReflex = require(Packages.ReactReflex)
local Store = require(ReplicatedStorage.Client.Reflex.Controller).Store

local React = require(ReplicatedStorage.Packages.React)
local ReactSpring = require(ReplicatedStorage.Packages.ReactSpring)
local e = React.createElement

local hud = {}
for _, hudUI in script:GetChildren() do
    hud[hudUI.Name] = require(hudUI)
end

return function(props)
    local hudMemo = React.useMemo(function()
        local hudMemo = {}

        for name, hudUI in pairs(hud) do
            hudMemo[name] = e(hudUI)
        end

        return hudMemo
    end, {})

    return e("Folder", {
        Name = "ScreenInsetsDisabledContainer"
    }, {
        e(React.Fragment, nil, hudMemo)
    })
end