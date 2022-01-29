#include-once
#include "DiscordGameSDK.au3"

Func __Discord_StorageManager_Init()
    $__Discord_apMethodPtrs[$__DISCORD_STORAGEMANAGER] = DllCallAddress("ptr:cdecl", _
                                                                        DllStructGetData($__Discord_atMethodInterfaces[$__DISCORD_CORE], "GetStorageManager"), _
                                                                        "ptr", $__Discord_apMethodPtrs[$__DISCORD_CORE])[0]
    $__Discord_atMethodInterfaces[$__DISCORD_STORAGEMANAGER] = DllStructCreate($__DISCORD_tagSTORAGEMANAGERMETHODS, $__Discord_apMethodPtrs[$__DISCORD_STORAGEMANAGER])
    __Discord_StorageManager_InitEvents()
EndFunc

Func __Discord_StorageManager_InitEvents()
EndFunc

Func __Discord_StorageManager_Dispose()
EndFunc