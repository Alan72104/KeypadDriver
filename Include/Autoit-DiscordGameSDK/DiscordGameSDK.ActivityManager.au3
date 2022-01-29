#include-once
#include "DiscordGameSDK.au3"

; $fnHandler: void OnActivityJoinHandler(string secret)
; return
; true good
; false bad
Func _Discord_ActivityManager_OnActivityJoin($fnHandler)
    If VarGetType($fnHandler) <> "UserFunction" Then
        Return False
    EndIf
    $__Discord_ActivityManager_afnCallbackHandlers[0] = $fnHandler
    Return True
EndFunc

; $fnHandler: void OnActivitySpectateHandler(string secret)
; return
; true good
; false bad
Func _Discord_ActivityManager_OnActivitySpectate($fnHandler)
    If VarGetType($fnHandler) <> "UserFunction" Then
        Return False
    EndIf
    $__Discord_ActivityManager_afnCallbackHandlers[1] = $fnHandler
    Return True
EndFunc

; $fnHandler: void OnActivityJoinRequestHandler(User {int64 id, string username, string discriminator, string avatar, bool bot})
; return
; true good
; false bad
Func _Discord_ActivityManager_OnActivityJoinRequest($fnHandler)
    If VarGetType($fnHandler) <> "UserFunction" Then
        Return False
    EndIf
    $__Discord_ActivityManager_afnCallbackHandlers[2] = $fnHandler
    Return True
EndFunc

; $fnHandler: void OnActivityInviteHandler(ActivityActionType type, User {int64 id, string username, string discriminator, string avatar, bool bot}, Activity {see type reference})
; return
; true good
; false bad
Func _Discord_ActivityManager_OnActivityInvite($fnHandler)
    If VarGetType($fnHandler) <> "UserFunction" Then
        Return False
    EndIf
    $__Discord_ActivityManager_afnCallbackHandlers[3] = $fnHandler
    Return True
EndFunc

; return
; true good
; false bad @error = discord result
Func _Discord_ActivityManager_RegisterCommand($sCommand)
    Local $aResult = DllCallAddress("int:cdecl", _
                                    DllStructGetData($__Discord_atMethodInterfaces[$__DISCORD_ACTIVITYMANAGER], "RegisterCommand"), _
                                    "ptr", $__Discord_apMethodPtrs[$__DISCORD_ACTIVITYMANAGER], _
                                    "str", $sCommand)
    If $aResult[0] <> $DISCORD_OK Then
        Return SetError($aResult[0], 0, False)
    EndIf
    Return True
EndFunc

; return
; true good
; false bad @error = discord result
Func _Discord_ActivityManager_RegisterSteam($iSteamId)
    Local $aResult = DllCallAddress("int:cdecl", _
                                    DllStructGetData($__Discord_atMethodInterfaces[$__DISCORD_ACTIVITYMANAGER], "RegisterSteam"), _
                                    "ptr", $__Discord_apMethodPtrs[$__DISCORD_ACTIVITYMANAGER], _
                                    "int", $iSteamId)
    If $aResult[0] <> $DISCORD_OK Then
        Return SetError($aResult[0], 0, False)
    EndIf
    Return True
EndFunc

; $fnHandler: UpdateActivityCallbackHandler(Result result)
; return
; true good
; false bad
Func _Discord_ActivityManager_UpdateActivity($aActivity, $fnHandler)
    If VarGetType($fnHandler) <> "UserFunction" Then
        Return False
    EndIf
    If UBound($aActivity) <> 18 Then
        Return False
    EndIf
    If $__Discord_ActivityManager_hUpdateActivityCallback = 0 Then
        $__Discord_ActivityManager_hUpdateActivityCallback = DllCallbackRegister("__Discord_ActivityManager_UpdateActivityCallbackHandler", "none:cdecl", "ptr;int")
    EndIf
    $__Discord_ActivityManager_fnUpdateActivityCallbackHandler = $fnHandler
    Local $tActivity = DllStructCreate($__DISCORD_tagACTIVITY)
    ; ActivityType is strictly for the purpose of handling events that you receive from Discord; though the SDK/our API will not reject a payload with an ActivityType sent, it will be discarded and will not change anything in the client.
    ; DllStructSetData($tActivity, "Type", $aActivity[0])
    DllStructSetData($tActivity, "ApplicationId", $aActivity[1])
    DllStructSetData($tActivity, "Name", $aActivity[2])
    DllStructSetData($tActivity, "State", $aActivity[3])
    DllStructSetData($tActivity, "Details", $aActivity[4])
    DllStructSetData($tActivity, "Timestamps_Start", $aActivity[5])
    DllStructSetData($tActivity, "Timerstamps_End", $aActivity[6])
    DllStructSetData($tActivity, "Assets_LargeImage", $aActivity[7])
    DllStructSetData($tActivity, "Assets_LargeText", $aActivity[8])
    DllStructSetData($tActivity, "Assets_SmallImage", $aActivity[9])
    DllStructSetData($tActivity, "Assets_SmallText", $aActivity[10])
    DllStructSetData($tActivity, "Party_Id", $aActivity[11])
    DllStructSetData($tActivity, "Party_Size_CurrentSize", $aActivity[12])
    DllStructSetData($tActivity, "Party_Size_MaxSize", $aActivity[13])
    DllStructSetData($tActivity, "Secrets_Match", $aActivity[14])
    DllStructSetData($tActivity, "Secrets_Join", $aActivity[15])
    DllStructSetData($tActivity, "Secrets_Spectate", $aActivity[16])
    DllStructSetData($tActivity, "Instance", $aActivity[17])
    Local $aResult = DllCallAddress("none:cdecl", _
                                    DllStructGetData($__Discord_atMethodInterfaces[$__DISCORD_ACTIVITYMANAGER], "UpdateActivity"), _
                                    "ptr", $__Discord_apMethodPtrs[$__DISCORD_ACTIVITYMANAGER], _
                                    "ptr", DllStructGetPtr($tActivity), _
                                    "ptr", Null, _
                                    "ptr", DllCallbackGetPtr($__Discord_ActivityManager_hUpdateActivityCallback))
    Return True
EndFunc

; $fnHandler: ClearActivityCallbackHandler(Result result)
; return
; true good
; false bad
Func _Discord_ActivityManager_ClearActivity($aActivity, $fnHandler)
    If VarGetType($fnHandler) <> "UserFunction" Then
        Return False
    EndIf
    If $__Discord_ActivityManager_hClearActivityCallback = 0 Then
        $__Discord_ActivityManager_hClearActivityCallback = DllCallbackRegister("__Discord_ActivityManager_ClearActivityCallbackHandler", "none:cdecl", "ptr;int")
    EndIf
    $__Discord_ActivityManager_fnClearActivityCallbackHandler = $fnHandler
    Local $aResult = DllCallAddress("none:cdecl", _
                                    DllStructGetData($__Discord_atMethodInterfaces[$__DISCORD_ACTIVITYMANAGER], "ClearActivity"), _
                                    "ptr", $__Discord_apMethodPtrs[$__DISCORD_ACTIVITYMANAGER], _
                                    "ptr", Null, _
                                    "ptr", DllCallbackGetPtr($__Discord_ActivityManager_hClearActivityCallback))
    Return True
EndFunc

; $fnHandler: SendRequestReplyCallbackHandler(Result result)
; return
; true good
; false bad
Func _Discord_ActivityManager_SendRequestReply($iUserId, $iReply, $fnHandler)
    If VarGetType($fnHandler) <> "UserFunction" Then
        Return False
    EndIf
    If $__Discord_ActivityManager_hSendRequestReplyCallback = 0 Then
        $__Discord_ActivityManager_hSendRequestReplyCallback = DllCallbackRegister("__Discord_ActivityManager_SendRequestReplyCallbackHandler", "none:cdecl", "ptr;int")
    EndIf
    $__Discord_ActivityManager_fnSendRequestReplyCallbackHandler = $fnHandler
    Local $aResult = DllCallAddress("none:cdecl", _
                                    DllStructGetData($__Discord_atMethodInterfaces[$__DISCORD_ACTIVITYMANAGER], "SendRequestReply"), _
                                    "ptr", $__Discord_apMethodPtrs[$__DISCORD_ACTIVITYMANAGER], _
                                    "int64", $iUserId, _
                                    "int", $iReply, _
                                    "ptr", Null, _
                                    "ptr", DllCallbackGetPtr($__Discord_ActivityManager_hSendRequestReplyCallback))
    Return True
EndFunc

; $fnHandler: SendInviteCallbackHandler(Result result)
; return
; true good
; false bad
Func _Discord_ActivityManager_SendInvite($iUserId, $iType, $sContent, $fnHandler)
    If VarGetType($fnHandler) <> "UserFunction" Then
        Return False
    EndIf
    If $__Discord_ActivityManager_hSendInviteCallback = 0 Then
        $__Discord_ActivityManager_hSendInviteCallback = DllCallbackRegister("__Discord_ActivityManager_SendInviteCallbackHandler", "none:cdecl", "ptr;int")
    EndIf
    $__Discord_ActivityManager_fnSendInviteCallbackHandler = $fnHandler
    Local $aResult = DllCallAddress("none:cdecl", _
                                    DllStructGetData($__Discord_atMethodInterfaces[$__DISCORD_ACTIVITYMANAGER], "SendInvite"), _
                                    "ptr", $__Discord_apMethodPtrs[$__DISCORD_ACTIVITYMANAGER], _
                                    "int64", $iUserId, _
                                    "int", $iType, _
                                    "str", $sContent, _
                                    "ptr", Null, _
                                    "ptr", DllCallbackGetPtr($__Discord_ActivityManager_hSendInviteCallback))
    Return True
EndFunc

; $fnHandler: AcceptInviteCallbackHandler(Result result)
; return
; true good
; false bad
Func _Discord_ActivityManager_AcceptInvite($iUserId, $fnHandler)
    If VarGetType($fnHandler) <> "UserFunction" Then
        Return False
    EndIf
    If $__Discord_ActivityManager_hAcceptInviteCallback = 0 Then
        $__Discord_ActivityManager_hAcceptInviteCallback = DllCallbackRegister("__Discord_ActivityManager_AcceptInviteCallbackHandler", "none:cdecl", "ptr;int")
    EndIf
    $__Discord_ActivityManager_fnAcceptInviteCallbackHandler = $fnHandler
    Local $aResult = DllCallAddress("none:cdecl", _
                                    DllStructGetData($__Discord_atMethodInterfaces[$__DISCORD_ACTIVITYMANAGER], "AcceptInvite"), _
                                    "ptr", $__Discord_apMethodPtrs[$__DISCORD_ACTIVITYMANAGER], _
                                    "int64", $iUserId, _
                                    "ptr", Null, _
                                    "ptr", DllCallbackGetPtr($__Discord_ActivityManager_hAcceptInviteCallback))
    Return True
EndFunc

Func __Discord_ActivityManager_Init()
    $__Discord_apMethodPtrs[$__DISCORD_ACTIVITYMANAGER] = DllCallAddress("ptr:cdecl", _
                                                                         DllStructGetData($__Discord_atMethodInterfaces[$__DISCORD_CORE], "GetActivityManager"), _
                                                                         "ptr", $__Discord_apMethodPtrs[$__DISCORD_CORE])[0]
    $__Discord_atMethodInterfaces[$__DISCORD_ACTIVITYMANAGER] = DllStructCreate($__DISCORD_tagACTIVITYMANAGERMETHODS, $__Discord_apMethodPtrs[$__DISCORD_ACTIVITYMANAGER])
    __Discord_ActivityManager_InitEvents()
EndFunc

Func __Discord_ActivityManager_InitEvents()
    $__Discord_ActivityManager_afnCallbackHandlers[0] = 0
    $__Discord_ActivityManager_ahCallbacks[0] = DllCallbackRegister("__DISCORD_ACTIVITYMANAGER_OnActivityJoinHandler", "none:cdecl", "ptr;str")
    DllStructSetData($__Discord_atEventInterfaces[$__DISCORD_ACTIVITYMANAGER], "OnActivityJoin", DllCallbackGetPtr($__Discord_ActivityManager_ahCallbacks[0]))
    $__Discord_ActivityManager_afnCallbackHandlers[1] = 0
    $__Discord_ActivityManager_ahCallbacks[1] = DllCallbackRegister("__DISCORD_ACTIVITYMANAGER_OnActivitySpectateHandler", "none:cdecl", "ptr;str")
    DllStructSetData($__Discord_atEventInterfaces[$__DISCORD_ACTIVITYMANAGER], "OnActivitySpectate", DllCallbackGetPtr($__Discord_ActivityManager_ahCallbacks[1]))
    $__Discord_ActivityManager_afnCallbackHandlers[2] = 0
    $__Discord_ActivityManager_ahCallbacks[2] = DllCallbackRegister("__DISCORD_ACTIVITYMANAGER_OnActivityJoinRequestHandler", "none:cdecl", "ptr;ptr")
    DllStructSetData($__Discord_atEventInterfaces[$__DISCORD_ACTIVITYMANAGER], "OnActivitySpectate", DllCallbackGetPtr($__Discord_ActivityManager_ahCallbacks[2]))
    $__Discord_ActivityManager_afnCallbackHandlers[3] = 0
    $__Discord_ActivityManager_ahCallbacks[3] = DllCallbackRegister("__DISCORD_ACTIVITYMANAGER_OnActivityInviteHandler", "none:cdecl", "ptr;int;ptr;ptr")
    DllStructSetData($__Discord_atEventInterfaces[$__DISCORD_ACTIVITYMANAGER], "OnActivitySpectate", DllCallbackGetPtr($__Discord_ActivityManager_ahCallbacks[3]))
EndFunc

; Handler for: void ActivityJoinHandler(IntPtr ptr, string secret)
Func __Discord_ActivityManager_OnActivityJoinHandler($pPtr, $sSecret)
    #forceref $pPtr
    If $__Discord_ActivityManager_afnCallbackHandlers[0] <> 0 Then
        $__Discord_ActivityManager_afnCallbackHandlers[0]($sSecret)
    EndIf
EndFunc

; Handler for: void ActivitySpectateHandler(IntPtr ptr, string secret)
Func __DISCORD_ACTIVITYMANAGER_OnActivitySpectateHandler($pPtr, $sSecret)
    #forceref $pPtr
    If $__Discord_ActivityManager_afnCallbackHandlers[1] <> 0 Then
        $__Discord_ActivityManager_afnCallbackHandlers[1]($sSecret)
    EndIf
EndFunc

; Handler for: void ActivityJoinRequestHandler(IntPtr ptr, ref User user)
Func __DISCORD_ACTIVITYMANAGER_OnActivityJoinRequestHandler($pPtr, $pUser)
    #forceref $pPtr
    If $__Discord_ActivityManager_afnCallbackHandlers[2] <> 0 Then
        Local $tUser = DllStructCreate($__DISCORD_tagUSER, $pUser)
        Local $aUser = [DllStructGetData($tUser, "Id"), _
                        DllStructGetData($tUser, "Username"), _
                        DllStructGetData($tUser, "Discriminator"), _
                        DllStructGetData($tUser, "Avatar"), _
                        DllStructGetData($tUser, "Bot")]
        $__Discord_ActivityManager_afnCallbackHandlers[2]($aUser)
    EndIf
EndFunc

; Handler for: void ActivityInviteHandler(IntPtr ptr, ActivityActionType type, ref User user, ref Activity activity)
Func __DISCORD_ACTIVITYMANAGER_OnActivityInviteHandler($pPtr, $iType, $pUser, $pActivity)
    #forceref $pPtr
    If $__Discord_ActivityManager_afnCallbackHandlers[3] <> 0 Then
        Local $tUser = DllStructCreate($__DISCORD_tagUSER, $pUser)
        Local $aUser = [DllStructGetData($tUser, "Id"), _
                        DllStructGetData($tUser, "Username"), _
                        DllStructGetData($tUser, "Discriminator"), _
                        DllStructGetData($tUser, "Avatar"), _
                        DllStructGetData($tUser, "Bot")]
        Local $tActivity = DllStructCreate($__DISCORD_tagACTIVITY, $pActivity)
        Local $aActivity = [DllStructGetData($tActivity, "Type"), _
                            DllStructGetData($tActivity, "ApplicationId"), _
                            DllStructGetData($tActivity, "Name"), _
                            DllStructGetData($tActivity, "State"), _
                            DllStructGetData($tActivity, "Details"), _
                            DllStructGetData($tActivity, "Timestamps_Start"), _
                            DllStructGetData($tActivity, "Timerstamps_End"), _
                            DllStructGetData($tActivity, "Assets_LargeImage"), _
                            DllStructGetData($tActivity, "Assets_LargeText"), _
                            DllStructGetData($tActivity, "Assets_SmallImage"), _
                            DllStructGetData($tActivity, "Assets_SmallText"), _
                            DllStructGetData($tActivity, "Party_Id"), _
                            DllStructGetData($tActivity, "Party_Size_CurrentSize"), _
                            DllStructGetData($tActivity, "Party_Size_MaxSize"), _
                            DllStructGetData($tActivity, "Secrets_Match"), _
                            DllStructGetData($tActivity, "Secrets_Join"), _
                            DllStructGetData($tActivity, "Secrets_Spectate"), _
                            DllStructGetData($tActivity, "Instance")]
        $__Discord_ActivityManager_afnCallbackHandlers[3]($iType, $aUser, $aActivity)
    EndIf
EndFunc

; Handler for: void UpdateActivityCallback(IntPtr ptr, Result result)
Func __Discord_ActivityManager_UpdateActivityCallbackHandler($pPtr, $iResult)
    #forceref $pPtr
    If $__Discord_ActivityManager_fnUpdateActivityCallbackHandler <> 0 Then
        $__Discord_ActivityManager_fnUpdateActivityCallbackHandler($iResult)
    EndIf
EndFunc

; Handler for: void ClearActivityCallback(IntPtr ptr, Result result)
Func __Discord_ActivityManager_ClearActivityCallbackHandler($pPtr, $iResult)
    #forceref $pPtr
    If $__Discord_ActivityManager_fnClearActivityCallbackHandler <> 0 Then
        $__Discord_ActivityManager_fnClearActivityCallbackHandler($iResult)
    EndIf
EndFunc

; Handler for: void SendRequestReplyCallback(IntPtr ptr, Result result)
Func __Discord_ActivityManager_SendRequestReplyCallbackHandler($pPtr, $iResult)
    #forceref $pPtr
    If $__Discord_ActivityManager_fnSendRequestReplyCallbackHandler <> 0 Then
        $__Discord_ActivityManager_fnSendRequestReplyCallbackHandler($iResult)
    EndIf
EndFunc

; Handler for: void SendInviteCallback(IntPtr ptr, Result result)
Func __Discord_ActivityManager_SendInviteCallbackHandler($pPtr, $iResult)
    #forceref $pPtr
    If $__Discord_ActivityManager_fnSendInviteCallbackHandler <> 0 Then
        $__Discord_ActivityManager_fnSendInviteCallbackHandler($iResult)
    EndIf
EndFunc

; Handler for: void AcceptInviteCallback(IntPtr ptr, Result result)
Func __Discord_ActivityManager_AcceptInviteCallbackHandler($pPtr, $iResult)
    #forceref $pPtr
    If $__Discord_ActivityManager_fnAcceptInviteCallbackHandler <> 0 Then
        $__Discord_ActivityManager_fnAcceptInviteCallbackHandler($iResult)
    EndIf
EndFunc

Func __Discord_ActivityManager_Dispose()
    For $i = 0 To UBound($__Discord_ActivityManager_ahCallbacks) - 1
        If $__Discord_ActivityManager_ahCallbacks[$i] Then
            DllCallbackFree($__Discord_ActivityManager_ahCallbacks[$i])
            $__Discord_ActivityManager_ahCallbacks[$i] = 0
        EndIf
    Next
    If $__Discord_ActivityManager_hUpdateActivityCallback Then
        DllCallbackFree($__Discord_ActivityManager_hUpdateActivityCallback)
        $__Discord_ActivityManager_hUpdateActivityCallback = 0
    EndIf
    If $__Discord_ActivityManager_hClearActivityCallback Then
        DllCallbackFree($__Discord_ActivityManager_hClearActivityCallback)
        $__Discord_ActivityManager_hClearActivityCallback = 0
    EndIf
    If $__Discord_ActivityManager_hSendRequestReplyCallback Then
        DllCallbackFree($__Discord_ActivityManager_hSendRequestReplyCallback)
        $__Discord_ActivityManager_hSendRequestReplyCallback = 0
    EndIf
    If $__Discord_ActivityManager_hSendInviteCallback Then
        DllCallbackFree($__Discord_ActivityManager_hSendInviteCallback)
        $__Discord_ActivityManager_hSendInviteCallback = 0
    EndIf
    If $__Discord_ActivityManager_hAcceptInviteCallback Then
        DllCallbackFree($__Discord_ActivityManager_hAcceptInviteCallback)
        $__Discord_ActivityManager_hAcceptInviteCallback = 0
    EndIf
EndFunc