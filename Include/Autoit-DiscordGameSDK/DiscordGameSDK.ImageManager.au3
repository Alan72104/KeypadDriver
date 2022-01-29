#include-once
#include "DiscordGameSDK.au3"

Func __Discord_ImageManager_Init()
    $__Discord_apMethodPtrs[$__DISCORD_IMAGEMANAGER] = DllCallAddress("ptr:cdecl", _
                                                                      DllStructGetData($__Discord_atMethodInterfaces[$__DISCORD_CORE], "GetImageManager"), _
                                                                      "ptr", $__Discord_apMethodPtrs[$__DISCORD_CORE])[0]
    $__Discord_atMethodInterfaces[$__DISCORD_IMAGEMANAGER] = DllStructCreate($__DISCORD_tagIMAGEMANAGERMETHODS, $__Discord_apMethodPtrs[$__DISCORD_IMAGEMANAGER])
    __Discord_ImageManager_InitEvents()
EndFunc

Func __Discord_ImageManager_InitEvents()
EndFunc

Func __Discord_ImageManager_Dispose()
EndFunc