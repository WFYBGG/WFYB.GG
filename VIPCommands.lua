--[[
INSTRUCTIONS:
1) Use any UNC executor (even crappy ones like Solara & Xeno work)
2) Type in chat the normal VIP server commands:

Command List:
/vipcommands 
/vipfreecam 
/vipstopfreecam 
/vipnextmode
/kick 
/vban 
/unban
/unbanall
/bans

Want to use this in YOUR OWN script?
1) Add as a module & call the global variable "_G.VIPCommands"

WFYB Exploits | Youtube.com/@WFYBExploits | Made in Mumbai, India
]]

local PlayersService = game:GetService("Players")
local ReplicatedStorageService = game:GetService("ReplicatedStorage")
local TextChatServiceService = game:GetService("TextChatService")
local LocalPlayer = PlayersService.LocalPlayer

local VipCommandsModule = {}

local function RunVipCmd(cmdString)
    pcall(function()
        local Channels = TextChatServiceService:FindFirstChild("TextChannels")
        local TargetChannel = Channels and (Channels:FindFirstChild("RBXGeneral") or Channels:FindFirstChild("General"))
        if TargetChannel and TargetChannel.SendAsync then
            TargetChannel:SendAsync(cmdString)
            return
        end
        local ChatEvents = ReplicatedStorageService:FindFirstChild("DefaultChatSystemChatEvents")
        if ChatEvents and ChatEvents:FindFirstChild("SayMessageRequest") then
            ChatEvents.SayMessageRequest:FireServer(cmdString, "All")
            return
        end
    end)
end

function VipCommandsModule.Freecam()
    pcall(function()
        if LocalPlayer and LocalPlayer.Name then
            RunVipCmd("/vipfreecam " .. LocalPlayer.Name)
        end
    end)
end

function VipCommandsModule.StopFreecam()
    pcall(function()
        if LocalPlayer and LocalPlayer.Name then
            RunVipCmd("/vipstopfreecam " .. LocalPlayer.Name)
        end
    end)
end

function VipCommandsModule.NextMode()
    RunVipCmd("/vipnextmode")
end

function VipCommandsModule.Help()
    RunVipCmd("/vipcommands")
end

function VipCommandsModule.Kick(playerName)
    RunVipCmd("/kick " .. (playerName or ""))
end

function VipCommandsModule.VBan(playerName)
    RunVipCmd("/vban " .. (playerName or ""))
end

function VipCommandsModule.Unban(playerName)
    RunVipCmd("/unban " .. (playerName or ""))
end

function VipCommandsModule.UnbanAll()
    RunVipCmd("/unbanall")
end

function VipCommandsModule.Bans()
    RunVipCmd("/bans")
end

-- [USE THE GLOBAL VARIABLE BELOW IF YOU WANT A CUSTOM UI TO CALL THIS MODULE]
_G.VIPCommands = VipCommandsModule
