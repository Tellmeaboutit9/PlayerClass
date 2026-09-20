type RBXScriptConnection = {
    Disconnect: (self: RBXScriptConnection) -> nil
}
local trove = require(script.Parent.Packages.trove)

export type Signal<t...> = {
    Fire: (self: Signal<t...>, t...) -> ();
    Connect: (self: Signal<t...>, fn: (t...) -> ()) -> RBXScriptConnection;
    DisconnectAll: (self: Signal<t...>) -> ();
    Once: (self: Signal<t...>, fn: (t...) -> ()) -> RBXScriptConnection;
}

export type Main<t> = {
   _Trove: typeof(trove.new());
   Data: t;
   _Player: Player;
   sessionEnd: Signal<>;
   startProfile: (self: Main<t>, Template: t) -> ();
   End: (self: Main<t>) -> nil;
   onDeath: (self: Main<t>, fn : () -> ()) -> ();
   overrideData: (self: Main<t>, newData : any) -> ();
   addUserId :(self: Main<t>, UserId: number) -> ();
}

return nil