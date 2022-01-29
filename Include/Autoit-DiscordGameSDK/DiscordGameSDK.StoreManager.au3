#include-once
#include "DiscordGameSDK.au3"

Func __Discord_StoreManager_Init()
    $__Discord_apMethodPtrs[$__DISCORD_STOREMANAGER] = DllCallAddress("ptr:cdecl", _
                                                                      DllStructGetData($__Discord_atMethodInterfaces[$__DISCORD_CORE], "GetStoreManager"), _
                                                                      "ptr", $__Discord_apMethodPtrs[$__DISCORD_CORE])[0]
    $__Discord_atMethodInterfaces[$__DISCORD_STOREMANAGER] = DllStructCreate($__DISCORD_tagSTOREMANAGERMETHODS, $__Discord_apMethodPtrs[$__DISCORD_STOREMANAGER])
    __Discord_StoreManager_InitEvents()
EndFunc

Func __Discord_StoreManager_InitEvents()
EndFunc

Func __Discord_StoreManager_Dispose()
EndFunc