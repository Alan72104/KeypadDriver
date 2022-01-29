#include-once
#include "DiscordGameSDK.au3"

Func __Discord_NetworkManager_Init()
    $__Discord_apMethodPtrs[$__DISCORD_NETWORKMANAGER] = DllCallAddress("ptr:cdecl", _
                                                                        DllStructGetData($__Discord_atMethodInterfaces[$__DISCORD_CORE], "GetNetworkManager"), _
                                                                        "ptr", $__Discord_apMethodPtrs[$__DISCORD_CORE])[0]
    $__Discord_atMethodInterfaces[$__DISCORD_NETWORKMANAGER] = DllStructCreate($__DISCORD_tagNETWORKMANAGERMETHODS, $__Discord_apMethodPtrs[$__DISCORD_NETWORKMANAGER])
    __Discord_NetworkManager_InitEvents()
EndFunc

Func __Discord_NetworkManager_InitEvents()
EndFunc

Func __Discord_NetworkManager_Dispose()
EndFunc