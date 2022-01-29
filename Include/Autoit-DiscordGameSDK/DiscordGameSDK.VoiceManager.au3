#include-once
#include "DiscordGameSDK.au3"

Func __Discord_VoiceManager_Init()
    $__Discord_apMethodPtrs[$__DISCORD_VOICEMANAGER] = DllCallAddress("ptr:cdecl", _
                                                                      DllStructGetData($__Discord_atMethodInterfaces[$__DISCORD_CORE], "GetVoiceManager"), _
                                                                      "ptr", $__Discord_apMethodPtrs[$__DISCORD_CORE])[0]
    $__Discord_atMethodInterfaces[$__DISCORD_VOICEMANAGER] = DllStructCreate($__DISCORD_tagVOICEMANAGERMETHODS, $__Discord_apMethodPtrs[$__DISCORD_VOICEMANAGER])
    __Discord_VoiceManager_InitEvents()
EndFunc

Func __Discord_VoiceManager_InitEvents()
EndFunc

Func __Discord_VoiceManager_Dispose()
EndFunc