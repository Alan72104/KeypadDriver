#include-once
#include "DiscordGameSDK.au3"

Func __Discord_LobbyManager_Init()
    $__Discord_apMethodPtrs[$__DISCORD_LOBBYMANAGER] = DllCallAddress("ptr:cdecl", _
                                                                      DllStructGetData($__Discord_atMethodInterfaces[$__DISCORD_CORE], "GetLobbyManager"), _
                                                                      "ptr", $__Discord_apMethodPtrs[$__DISCORD_CORE])[0]
    $__Discord_atMethodInterfaces[$__DISCORD_LOBBYMANAGER] = DllStructCreate($__DISCORD_tagLOBBYMANAGERMETHODS, $__Discord_apMethodPtrs[$__DISCORD_LOBBYMANAGER])
    __Discord_LobbyManager_InitEvents()
EndFunc

Func __Discord_LobbyManager_InitEvents()
EndFunc

Func __Discord_LobbyManager_Dispose()
EndFunc