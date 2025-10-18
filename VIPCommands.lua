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
    local ChatEvents = ReplicatedStorageService:FindFirstChild("DefaultChatSystemChatEvents")
    if ChatEvents and ChatEvents:FindFirstChild("SayMessageRequest") then
        ChatEvents.SayMessageRequest:FireServer(cmdString, "All")
        return
    end

    local Channels = TextChatServiceService:FindFirstChild("TextChannels")
    local TargetChannel = Channels and (Channels:FindFirstChild("RBXGeneral") or Channels:FindFirstChild("General"))
    if TargetChannel and TargetChannel.SendAsync then
        TargetChannel:SendAsync(cmdString)
    end
end

LocalPlayer.Chatted:Connect(function(Message)
    if Message:sub(1, 1) == "/" and (
        Message:match("^/vip") or
        Message:match("^/kick") or Message:match("^/vban") or Message:match("^/unban") or
        Message == "/unbanall" or Message == "/bans"
    ) then
        RunVipCmd(Message)
    end
end)

function VipCommandsModule.Freecam()
    if LocalPlayer and LocalPlayer.Name then
        RunVipCmd("/vipfreecam " .. LocalPlayer.Name)
    end
end

function VipCommandsModule.StopFreecam()
    if LocalPlayer and LocalPlayer.Name then
        RunVipCmd("/vipstopfreecam " .. LocalPlayer.Name)
    end
end

function VipCommandsModule.NextMode()
    RunVipCmd("/vipnextmode")
end

function VipCommandsModule.Help()
    RunVipCmd("/vipcommands")
end

function VipCommandsModule.Kick(PlayerName)
    RunVipCmd("/kick " .. (PlayerName or ""))
end

function VipCommandsModule.VBan(PlayerName)
    RunVipCmd("/vban " .. (PlayerName or ""))
end

function VipCommandsModule.Unban(PlayerName)
    RunVipCmd("/unban " .. (PlayerName or ""))
end

function VipCommandsModule.UnbanAll()
    RunVipCmd("/unbanall")
end

function VipCommandsModule.Bans()
    RunVipCmd("/bans")
end

_G.VIPCommands = VipCommandsModule
