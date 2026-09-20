--!nolint LocalUnused
--!nolint ImportUnused

--/ SERVICES \--
local RunService = game:GetService("RunService")

--/ VARIABLES \--

--/ MODULES \--
local Types = require("./Type")

--/ TYPES \--
type Signal<t...> = Types.Signal<t...>

--/ MODULE \--
local Signal = {}
Signal.__index = Signal

--/ FUNCTIONS \--
function Signal.new<t...>() : Signal<t...>
    local self = setmetatable({
        _Callbacks = {},
        _oneTimeCallbacks = {}
    }, Signal)

    return self
end

function Signal:Fire<t...>(... : t...)
    for _, v in pairs(self._Callbacks) do
        if typeof(v) == "function" then
            v(...)
        else
            continue
        end
    end

    for i, v in pairs(self._oneTimeCallbacks) do
        if typeof(v) == "function" then
            v(...)
            table.remove(self._oneTimeCallbacks, i)
        else
            continue
        end
    end
end

function Signal:Connect<t...>(fn : (t...) -> ())
    table.insert(self._Callbacks, fn)
    
    return {
        Disconnect = function()
            local i = table.find(self._Callbacks, fn)

            if i then
                table.remove(self._Callbacks, i)
            end

            return nil
         end
    }
end

function Signal:Once<t...>(fn : (t...) -> ())
    table.insert(self.oneTimeCallbacks, fn)
    
    return {
        Disconnect = function()
            local i = table.find(self.oneTimeCallbacks, fn)

            if i then
                table.remove(self.oneTimeCallbacks, i)
            end

            return nil
         end
    }
end

function Signal:DisconnectAll()
    self._Callbacks = {}
    self._oneTimeCallbacks = {}
end

--/ END \--
return Signal
--\ END /--