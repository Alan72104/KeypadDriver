#include-once
#include "DiscordGameSDK.au3"

Func __Discord_AchievementManager_Init()
    $__Discord_apMethodPtrs[$__DISCORD_ACHIEVEMENTMANAGER] = DllCallAddress("ptr:cdecl", _
                                                                            DllStructGetData($__Discord_atMethodInterfaces[$__DISCORD_CORE], "GetAchievementManager"), _
                                                                            "ptr", $__Discord_apMethodPtrs[$__DISCORD_CORE])[0]
    $__Discord_atMethodInterfaces[$__DISCORD_ACHIEVEMENTMANAGER] = DllStructCreate($__DISCORD_tagACHIEVEMENTMANAGERMETHODS, $__Discord_apMethodPtrs[$__DISCORD_ACHIEVEMENTMANAGER])
    __Discord_AchievementManager_InitEvents()
EndFunc

Func __Discord_AchievementManager_InitEvents()
EndFunc

Func __Discord_AchievementManager_Dispose()
EndFunc