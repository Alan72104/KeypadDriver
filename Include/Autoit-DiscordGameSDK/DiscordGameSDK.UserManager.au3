#include-once
#include "DiscordGameSDK.au3"

; $fnHandler: void OnCurrentUserUpdateHandler()
; return
; true good
; false bad
Func _Discord_UserManager_OnCurrentUserUpdate($fnHandler)
    If VarGetType($fnHandler) <> "UserFunction" Then
        Return False
    EndIf
    $__Discord_UserManager_afnCallbackHandlers[0] = $fnHandler
    Return True
EndFunc

; return
; User {int64 id, string username, string discriminator, string avatar, bool bot} good
; false bad @error = discord result
Func _Discord_UserManager_GetCurrentUser()
    Local $tUser = DllStructCreate($__DISCORD_tagUSER)
    Local $aResult = DllCallAddress("int:cdecl", _
                                    DllStructGetData($__Discord_atMethodInterfaces[$__DISCORD_USERMANAGER], "GetCurrentUser"), _
                                    "ptr", $__Discord_apMethodPtrs[$__DISCORD_USERMANAGER], _
                                    "ptr", DllStructGetPtr($tUser))
    If $aResult[0] <> $DISCORD_OK Then
        Return SetError($aResult[0], 0, False)
    EndIf
    Local $aUser = [DllStructGetData($tUser, "Id"), _
                    DllStructGetData($tUser, "Username"), _
                    DllStructGetData($tUser, "Discriminator"), _
                    DllStructGetData($tUser, "Avatar"), _
                    DllStructGetData($tUser, "Bot")]
    Return $aUser
EndFunc

; $fnHandler: void GetUserHandler(Result result, User {int64 id, string username, string discriminator, string avatar, bool bot})
; return
; true good
; false bad
Func _Discord_UserManager_GetUser($iUserId, $fnHandler)
    If Not IsInt($iUserId) Then
        Return False
    EndIf
    If VarGetType($fnHandler) <> "UserFunction" Then
        Return False
    EndIf
    If $__Discord_UserManager_hGetUserCallback = 0 Then
        $__Discord_UserManager_hGetUserCallback = DllCallbackRegister("__Discord_UserManager_GetUserCallbackHandler", "none:cdecl", "ptr;int;ptr")
    EndIf
    $__Discord_UserManager_fnGetUserCallbackHandler = $fnHandler
    Local $aResult = DllCallAddress("none:cdecl", _
                                    DllStructGetData($__Discord_atMethodInterfaces[$__DISCORD_USERMANAGER], "GetUser"), _
                                    "ptr", $__Discord_apMethodPtrs[$__DISCORD_USERMANAGER], _
                                    "int64", $iUserId, _
                                    "ptr", Null, _
                                    "ptr", DllCallbackGetPtr($__Discord_UserManager_hGetUserCallback))
    Return True
EndFunc

; return
; int premium type
; false bad @error discord result
Func _Discord_UserManager_GetCurrentUserPremiumType()
    Local $aResult = DllCallAddress("int:cdecl", _
                                    DllStructGetData($__Discord_atMethodInterfaces[$__DISCORD_USERMANAGER], "GetCurrentUserPremiumType"), _
                                    "ptr", $__Discord_apMethodPtrs[$__DISCORD_USERMANAGER], _
                                    "int", 0)
    If $aResult[0] <> $DISCORD_OK Then
        Return SetError(-1, @error, False)
    EndIf
    Local $iPremiumType = $aResult[2]
    Return $iPremiumType
EndFunc

; return
; bool flag
; false bad @error discord result
Func _Discord_UserManager_CurrentUserHasFlag()
    Local $aResult = DllCallAddress("int:cdecl", _
                                    DllStructGetData($__Discord_atMethodInterfaces[$__DISCORD_USERMANAGER], "CurrentUserHasFlag"), _
                                    "ptr", $__Discord_apMethodPtrs[$__DISCORD_USERMANAGER], _
                                    "boolean", 0)
    If $aResult[0] <> $DISCORD_OK Then
        Return SetError(-1, @error, False)
    EndIf
    Local $bFlag = $aResult[2]
    Return $bFlag
EndFunc

; Handler for: void GetUserCallback(IntPtr ptr, Result result, ref User user)
Func __Discord_UserManager_GetUserCallbackHandler($pPtr, $iResult, $pUser)
    #forceref $pPtr
    If $__Discord_UserManager_fnGetUserCallbackHandler <> 0 Then
        Local $tUser = DllStructCreate($__DISCORD_tagUSER, $pUser)
        Local $aUser = [DllStructGetData($tUser, "Id"), _
                        DllStructGetData($tUser, "Username"), _
                        DllStructGetData($tUser, "Discriminator"), _
                        DllStructGetData($tUser, "Avatar"), _
                        DllStructGetData($tUser, "Bot")]
        $__Discord_UserManager_fnGetUserCallbackHandler($iResult, $aUser)
    EndIf
EndFunc

Func __Discord_UserManager_Init()
    $__Discord_apMethodPtrs[$__DISCORD_USERMANAGER] = DllCallAddress("ptr:cdecl", _
                                                                     DllStructGetData($__Discord_atMethodInterfaces[$__DISCORD_CORE], "GetUserManager"), _
                                                                     "ptr", $__Discord_apMethodPtrs[$__DISCORD_CORE])[0]
    $__Discord_atMethodInterfaces[$__DISCORD_USERMANAGER] = DllStructCreate($__DISCORD_tagUSERMANAGERMETHODS, $__Discord_apMethodPtrs[$__DISCORD_USERMANAGER])
    __Discord_UserManager_InitEvents()
EndFunc

Func __Discord_UserManager_InitEvents()
    $__Discord_UserManager_afnCallbackHandlers[0] = 0
    $__Discord_UserManager_ahCallbacks[0] = DllCallbackRegister("__Discord_UserManager_OnCurrentUserUpdateHandler", "none:cdecl", "ptr")
    DllStructSetData($__Discord_atEventInterfaces[$__DISCORD_USERMANAGER], "OnCurrentUserUpdate", DllCallbackGetPtr($__Discord_UserManager_ahCallbacks[0]))
EndFunc

; Handler for: void CurrentUserUpdateHandler(IntPtr ptr)
Func __Discord_UserManager_OnCurrentUserUpdateHandler($pPtr)
    #forceref $pPtr
    If $__Discord_UserManager_afnCallbackHandlers[0] <> 0 Then
        $__Discord_UserManager_afnCallbackHandlers[0]()
    EndIf
EndFunc

Func __Discord_UserManager_Dispose()
    For $i = 0 To UBound($__Discord_UserManager_ahCallbacks) - 1
        If $__Discord_UserManager_ahCallbacks[$i] Then
            DllCallbackFree($__Discord_UserManager_ahCallbacks[$i])
            $__Discord_UserManager_ahCallbacks[$i] = 0
        EndIf
    Next
    If $__Discord_UserManager_hGetUserCallback Then
        DllCallbackFree($__Discord_UserManager_hGetUserCallback)
        $__Discord_UserManager_hGetUserCallback = 0
    EndIf
EndFunc