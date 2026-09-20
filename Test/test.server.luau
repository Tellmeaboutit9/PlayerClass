--!nolint LocalUnused
--!nolint ImportUnused

--/ SERVICES \--

--/ MODULES \--
local PlayerClass = require("../src")

--/ VARIABLES \--
local Template = {
    Coins = 0,
    Inventory = {}
}

--/ CONNECTIONS \--
PlayerClass.PlayerAdded:Connect(function(Player)
    local Class = PlayerClass.new(Player)
    Class:addUserId(Player.UserId)
    
    Class.sessionEnd:Connect(function()
        Player:Kick(`Session ended. Please rejoin`)
    end)

    Class:startProfile(Template)
end)

PlayerClass.PlayerRemoving:Connect(function(Player)
    local Class = PlayerClass.getClass(Player)

    Class:End()
end)
