#include-once
#include "DiscordGameSDK.au3"

Func __Discord_RelationshipManager_Init()
    $__Discord_apMethodPtrs[$__DISCORD_RELATIONSHIPMANAGER] = DllCallAddress("ptr:cdecl", _
                                                                             DllStructGetData($__Discord_atMethodInterfaces[$__DISCORD_CORE], "GetRelationshipManager"), _
                                                                             "ptr", $__Discord_apMethodPtrs[$__DISCORD_CORE])[0]
    $__Discord_atMethodInterfaces[$__DISCORD_RELATIONSHIPMANAGER] = DllStructCreate($__DISCORD_tagRELATIONSHIPMANAGERMETHODS, $__Discord_apMethodPtrs[$__DISCORD_RELATIONSHIPMANAGER])
    __Discord_RelationshipManager_InitEvents()
EndFunc

Func __Discord_RelationshipManager_InitEvents()
EndFunc

Func __Discord_RelationshipManager_Dispose()
EndFunc