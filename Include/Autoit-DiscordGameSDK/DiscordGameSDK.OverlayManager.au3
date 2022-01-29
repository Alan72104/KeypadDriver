#include-once
#include "DiscordGameSDK.au3"

Func __Discord_OverlayManager_Init()
    $__Discord_apMethodPtrs[$__DISCORD_OVERLAYMANAGER] = DllCallAddress("ptr:cdecl", _
                                                                        DllStructGetData($__Discord_atMethodInterfaces[$__DISCORD_CORE], "GetOverlayManager"), _
                                                                        "ptr", $__Discord_apMethodPtrs[$__DISCORD_CORE])[0]
    $__Discord_atMethodInterfaces[$__DISCORD_OVERLAYMANAGER] = DllStructCreate($__DISCORD_tagOVERLAYMANAGERMETHODS, $__Discord_apMethodPtrs[$__DISCORD_OVERLAYMANAGER])
    __Discord_OverlayManager_InitEvents()
EndFunc

Func __Discord_OverlayManager_InitEvents()
EndFunc

Func __Discord_OverlayManager_Dispose()
EndFunc