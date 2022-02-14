#include "DiscordGameSDK.au3"
_Discord_Init(939233557233139742)
Global $act = _Discord_ActivityManager_MakeActivitySimple("State", "Details", 0, 0, "axo", "easy", "ryzen", "pz")
_Discord_ActivityManager_UpdateActivity($act, UpdateActivityHandler)
While 1
    _Discord_RunCallbacks()
    Sleep(100)
WEnd
Func UpdateActivityHandler($res)
EndFunc