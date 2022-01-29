#include-once
#include "DiscordGameSDK.au3"

; return
; string
Func _Discord_ApplicationManager_GetCurrentLocale()
    Local $aResult = DllCallAddress("none:cdecl", _
                                    DllStructGetData($__Discord_atMethodInterfaces[$__DISCORD_APPLICATIONMANAGER], "GetCurrentLocale"), _
                                    "ptr", $__Discord_apMethodPtrs[$__DISCORD_APPLICATIONMANAGER], _
                                    "str", "")
    Local $sStr = $aResult[2]
    Return $sStr
EndFunc

; return
; string
Func _Discord_ApplicationManager_GetCurrentBranch()
    Local $aResult = DllCallAddress("none:cdecl", _
                                    DllStructGetData($__Discord_atMethodInterfaces[$__DISCORD_APPLICATIONMANAGER], "GetCurrentBranch"), _
                                    "ptr", $__Discord_apMethodPtrs[$__DISCORD_APPLICATIONMANAGER], _
                                    "str", "")
    Local $sStr = $aResult[2]
    Return $sStr
EndFunc

; $fnHandler: void ValidateOrExitCallbackHandler(Result result)
; return
; true good
; false bad
Func _Discord_ApplicationManager_ValidateOrExit($fnHandler)
    If VarGetType($fnHandler) <> "UserFunction" Then
        Return False
    EndIf
    If $__Discord_ApplicationManager_hValidateOrExitCallback = 0 Then
        $__Discord_ApplicationManager_hValidateOrExitCallback = DllCallbackRegister("__Discord_ApplicationManager_ValidateOrExitCallbackHandler", "none", "ptr;int")
    EndIf
    $__Discord_ApplicationManager_fnValidateOrExitCallbackHandler = $fnHandler
    Local $aResult = DllCallAddress("none:cdecl", _
                                    DllStructGetData($__Discord_atMethodInterfaces[$__DISCORD_APPLICATIONMANAGER], "ValidateOrExit"), _
                                    "ptr", $__Discord_apMethodPtrs[$__DISCORD_APPLICATIONMANAGER], _
                                    "ptr", Null, _
                                    "ptr", DllCallbackGetPtr($__Discord_ApplicationManager_hValidateOrExitCallback))
    Return True
EndFunc

; $fnHandler: void GetOAuth2TokenHandler(Result result, {string accessToken, string scopes, Int64 expires})
; return
; true good
; false bad
Func _Discord_ApplicationManager_GetOAuth2Token($fnHandler)
    If VarGetType($fnHandler) <> "UserFunction" Then
        Return False
    EndIf
    If $__Discord_ApplicationManager_hGetOAuth2TokenCallback = 0 Then
        $__Discord_ApplicationManager_hGetOAuth2TokenCallback = DllCallbackRegister("__Discord_ApplicationManager_GetOAuth2TokenHandler", "none", "ptr;int;ptr")
    EndIf
    $__Discord_ApplicationManager_fnGetOAuth2TokenCallbackHandler = $fnHandler
    Local $aResult = DllCallAddress("none:cdecl", _
                                    DllStructGetData($__Discord_atMethodInterfaces[$__DISCORD_APPLICATIONMANAGER], "GetOAuth2Token"), _
                                    "ptr", $__Discord_apMethodPtrs[$__DISCORD_APPLICATIONMANAGER], _
                                    "ptr", Null, _
                                    "ptr", DllCallbackGetPtr($__Discord_ApplicationManager_hGetOAuth2TokenCallback))
    Return True
EndFunc

; $fnHandler: void GetTicketCallback(Result result, string data)
; return
; true good
; false bad
Func _Discord_ApplicationManager_GetTicket($fnHandler)
    If VarGetType($fnHandler) <> "UserFunction" Then
        Return False
    EndIf
    If $__Discord_ApplicationManager_hGetTicketCallback = 0 Then
        $__Discord_ApplicationManager_hGetTicketCallback = DllCallbackRegister("__Discord_ApplicationManager_GetTicketCallbackHandler", "none", "ptr;int;ptr")
    EndIf
    $__Discord_ApplicationManager_fnGetTicketCallbackHandler = $fnHandler
    Local $aResult = DllCallAddress("none:cdecl", _
                                    DllStructGetData($__Discord_atMethodInterfaces[$__DISCORD_APPLICATIONMANAGER], "GetTicket"), _
                                    "ptr", $__Discord_apMethodPtrs[$__DISCORD_APPLICATIONMANAGER], _
                                    "ptr", Null, _
                                    "ptr", DllCallbackGetPtr($__Discord_ApplicationManager_hGetTicketCallback))
    Return True
EndFunc

; Handler for: void GetTicketCallback(IntPtr ptr, Result result, [MarshalAs(UnmanagedType.LPStr)]ref string data);
Func __Discord_ApplicationManager_GetTicketCallbackHandler($pPtr, $iResult, $sData)
    #forceref $pPtr
    If $__Discord_ApplicationManager_fnGetTicketCallbackHandler <> 0 Then
        $__Discord_ApplicationManager_fnGetTicketCallbackHandler($iResult, $sData)
    EndIf
EndFunc

; Handler for: void ValidateOrExitCallback(IntPtr ptr, Result result)
Func __Discord_ApplicationManager_ValidateOrExitCallbackHandler($pPtr, $iResult)
    #forceref $pPtr
    If $__Discord_ApplicationManager_fnValidateOrExitCallbackHandler <> 0 Then
        $__Discord_ApplicationManager_fnValidateOrExitCallbackHandler($iResult)
    EndIf
EndFunc

; Handler for: void GetOAuth2TokenCallback(IntPtr ptr, Result result, {string accessToken, string scopes, Int64 expires})
Func __Discord_ApplicationManager_GetOAuth2TokenHandler($pPtr, $iResult, $pOAuth2Token)
    #forceref $pPtr
    If $__Discord_ApplicationManager_fnGetOAuth2TokenCallbackHandler <> 0 Then
        Local $tOAuth2Token = DllStructCreate($__DISCORD_tagOAUTH2TOKEN, $pOAuth2Token)
        Local $aOAuth2Token = [DllStructGetData($tOAuth2Token, "AccessToken"), _
                               DllStructGetData($tOAuth2Token, "Scopes"), _
                               DllStructGetData($tOAuth2Token, "Expires")]
        $__Discord_ApplicationManager_fnGetOAuth2TokenCallbackHandler($iResult, $aOAuth2Token)
    EndIf
EndFunc

Func __Discord_ApplicationManager_Init()
    $__Discord_apMethodPtrs[$__DISCORD_APPLICATIONMANAGER] = DllCallAddress("ptr:cdecl", _
                                                                            DllStructGetData($__Discord_atMethodInterfaces[$__DISCORD_CORE], "GetApplicationManager"), _
                                                                            "ptr", $__Discord_apMethodPtrs[$__DISCORD_CORE])[0]
    $__Discord_atMethodInterfaces[$__DISCORD_APPLICATIONMANAGER] = DllStructCreate($__DISCORD_tagAPPLICATIONMANAGERMETHODS, $__Discord_apMethodPtrs[$__DISCORD_APPLICATIONMANAGER])
    __Discord_ApplicationManager_InitEvents()
EndFunc

Func __Discord_ApplicationManager_InitEvents()
EndFunc

Func __Discord_ApplicationManager_Dispose()
    If $__Discord_ApplicationManager_hValidateOrExitCallback Then
        DllCallbackFree($__Discord_ApplicationManager_hValidateOrExitCallback)
        $__Discord_ApplicationManager_hValidateOrExitCallback = 0
    EndIf
    If $__Discord_ApplicationManager_hGetOAuth2TokenCallback Then
        DllCallbackFree($__Discord_ApplicationManager_hGetOAuth2TokenCallback)
        $__Discord_ApplicationManager_hGetOAuth2TokenCallback = 0
    EndIf
    If $__Discord_ApplicationManager_hGetTicketCallback Then
        DllCallbackFree($__Discord_ApplicationManager_hGetTicketCallback)
        $__Discord_ApplicationManager_hGetTicketCallback = 0
    EndIf
EndFunc