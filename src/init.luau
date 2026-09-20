--!nolint LocalUnused
--!nolint ImportUnused

--/ SERVICES \--
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

--/ MODULES \--
local Signal = require("@self/Signal")
local Types = require("@self/Type")
local Trove = require("../Packages/trove")

--/ VARIABLES \--
local Datastore = DataStoreService:GetDataStore("Test")

--/ SIGNALS \--
local playerAdded = Signal.new()
local playerRemoving = Signal.new()

--/ MODULE \--
local PlayerClass = {}
PlayerClass.Index = {} :: {[Player]: unknown}
PlayerClass.__index = PlayerClass

--/ FUNCTIONS \--
function PlayerClass.new<t>(Player: Player, Template : t): Types.Main<t>?
    if typeof(Player) ~= "Player" then
        return nil
    end

    local self = setmetatable({}, PlayerClass)

    self._Player = Player
    self.Data = {}
    self.Template = Template
    self._Trove = Trove.new()
    self.UserIds = {}

    self.Character = Player.Character or Player.CharacterAdded:Wait()

    self.Died = Signal.new()
    self.sessionEnd = Signal.new()
    self._Trove:Connect(Player.CharacterAdded, function(newCharacter)
        assert(typeof(newCharacter) ~= "Model", "Invalid character type")

        self.Character = newCharacter
    end)
    
    return self
end

function PlayerClass:Reconcile<t>()
    for i, v in pairs(self.Template) do
        if not table.find(self.Data, i) then
            table.insert(self.Data, v)
        elseif not self.Data[i] then
            self.Data[i] = v
        end
    end
end

function PlayerClass:startProfile<t>()
    local Success, result = pcall(function()
        return Datastore:GetAsync(self.Player.UserId)
    end)

    if not Success then
        self.sessionEnd:Fire()
        return
    end

    if Success then
        self.Data = result
    end
end

function PlayerClass:onDeath(fn : () -> ())
    self._Trove:Connect(self.Character:WaitForChild("Humanoid").Died, fn)
end

function PlayerClass:overrideData(newData : any)
    self.Data = newData
end

function PlayerClass:addUserId(UserId: number)
    if not UserId then
        return
    end

    assert(typeof(UserId) ~= "number", "UserId has to be a number.")

    table.insert(self.UserIds, UserId)
end

function PlayerClass:End()
    local success, error = pcall(function()
        Datastore:SetAsync(self.Player.UserId, self.Data, self.UserIds)
    end)

    if not success then
        print(`[{script.Name}]: Failed to save {self.Player.Name}'s Data. Attempting again`)
    end

    local Attempts = 0

    repeat task.wait(2)
        success, error = pcall(function()
            Datastore:SetAsync(self.Player.UserId, self.Data, self.UserIds)
        end)

        Attempts = Attempts + 1
    until success ~= false or Attempts >= 15
    
    self:Clean()
end

function PlayerClass:Clean()
    self._Trove:Clean()

    return nil
end

function PlayerClass.getClass<t>(Player: Player): Types.Main<t>
    return PlayerClass.Index[Player]
end

Players.PlayerAdded:Connect(function(Player)
    playerAdded:Fire(Player)
end)

Players.PlayerRemoving:Connect(function(Player)
    playerRemoving:Fire(Player)
end)


PlayerClass.PlayerAdded = playerAdded
PlayerClass.PlayerRemoving = playerRemoving

--/ END \--
return PlayerClass
--\ END /--