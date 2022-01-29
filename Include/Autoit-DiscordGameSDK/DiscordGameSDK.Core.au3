#include-once
#include "DiscordGameSDK.au3"

; return
; true good
; false bad
; error
; -1 id isn't int64
; -2 invalid flag
; -3 init'd
; -4 failed to open dll
; -5 failed to call dll, @ext dllcall error
; -6 discord error, @ext discord result
Func _Discord_Init($iDiscordId, $sDllFolderPath = @ScriptDir, $iFlags = $DISCORD_CREATEFLAGS_NOREQUIREDISCORD)
    If VarGetType($iDiscordId) <> "Int64" Then
        Return SetError(-1, 0, False)
    EndIf
    If VarGetType($iFlags) <> "Int32" Or $iFlags < $DISCORD_CREATEFLAGS_DEFAULT Or $iFlags > $DISCORD_CREATEFLAGS_NOREQUIREDISCORD Then
        Return SetError(-2, 0, False)
    EndIf
    If $__Discord_hDll Then
        Return SetError(-3, 0, False)
    EndIf

    Local $tParams = DllStructCreate($__DISCORD_tagFFICREATEPARAMS)
    DllStructSetData($tParams, "ClientId", $iDiscordId)
    DllStructSetData($tParams, "Flags", $iFlags)
    ; Reference to core instance obj that will be sent back on static callback to dispatch to instance objects, OOP isn't used there
    DllStructSetData($tParams, "Events", Null)
    $__Discord_atEventInterfaces[$__DISCORD_CORE] = DllStructCreate($__DISCORD_tagCOREEVENTS)
    DllStructSetData($tParams, "EventData", DllStructGetPtr($__Discord_atEventInterfaces[$__DISCORD_CORE]))
    $__Discord_atEventInterfaces[$__DISCORD_APPLICATIONMANAGER] = DllStructCreate($__DISCORD_tagCOREEVENTS)
    DllStructSetData($tParams, "ApplicationEvents", DllStructGetPtr($__Discord_atEventInterfaces[$__DISCORD_APPLICATIONMANAGER]))
    DllStructSetData($tParams, "ApplicationVersion", 1)
    $__Discord_atEventInterfaces[$__DISCORD_USERMANAGER] = DllStructCreate($__DISCORD_tagUSERMANAGEREVENTS)
    DllStructSetData($tParams, "UserEvents", DllStructGetPtr($__Discord_atEventInterfaces[$__DISCORD_USERMANAGER]))
    DllStructSetData($tParams, "UserVersion", 1)
    $__Discord_atEventInterfaces[$__DISCORD_IMAGEMANAGER] = DllStructCreate($__DISCORD_tagIMAGEMANAGEREVENTS)
    DllStructSetData($tParams, "ImageEvents", DllStructGetPtr($__Discord_atEventInterfaces[$__DISCORD_IMAGEMANAGER]))
    DllStructSetData($tParams, "ImageVersion", 1)
    $__Discord_atEventInterfaces[$__DISCORD_ACTIVITYMANAGER] = DllStructCreate($__DISCORD_tagACTIVITYMANAGEREVENTS)
    DllStructSetData($tParams, "ActivityEvents", DllStructGetPtr($__Discord_atEventInterfaces[$__DISCORD_ACTIVITYMANAGER]))
    DllStructSetData($tParams, "ActivityVersion", 1)
    $__Discord_atEventInterfaces[$__DISCORD_RELATIONSHIPMANAGER] = DllStructCreate($__DISCORD_tagRELATIONSHIPMANAGEREVENTS)
    DllStructSetData($tParams, "RelationshipEvents", DllStructGetPtr($__Discord_atEventInterfaces[$__DISCORD_RELATIONSHIPMANAGER]))
    DllStructSetData($tParams, "RelationshipVersion", 1)
    $__Discord_atEventInterfaces[$__DISCORD_LOBBYMANAGER] = DllStructCreate($__DISCORD_tagLOBBYMANAGEREVENTS)
    DllStructSetData($tParams, "LobbyEvents", DllStructGetPtr($__Discord_atEventInterfaces[$__DISCORD_LOBBYMANAGER]))
    DllStructSetData($tParams, "LobbyVersion", 1)
    $__Discord_atEventInterfaces[$__DISCORD_NETWORKMANAGER] = DllStructCreate($__DISCORD_tagNETWORKMANAGEREVENTS)
    DllStructSetData($tParams, "NetworkEvents", DllStructGetPtr($__Discord_atEventInterfaces[$__DISCORD_NETWORKMANAGER]))
    DllStructSetData($tParams, "NetworkVersion", 1)
    $__Discord_atEventInterfaces[$__DISCORD_OVERLAYMANAGER] = DllStructCreate($__DISCORD_tagOVERLAYMANAGEREVENTS)
    DllStructSetData($tParams, "OverlayEvents", DllStructGetPtr($__Discord_atEventInterfaces[$__DISCORD_OVERLAYMANAGER]))
    DllStructSetData($tParams, "OverlayVersion", 1)
    $__Discord_atEventInterfaces[$__DISCORD_STORAGEMANAGER] = DllStructCreate($__DISCORD_tagSTORAGEMANAGEREVENTS)
    DllStructSetData($tParams, "StorageEvents", DllStructGetPtr($__Discord_atEventInterfaces[$__DISCORD_STORAGEMANAGER]))
    DllStructSetData($tParams, "StorageVersion", 1)
    $__Discord_atEventInterfaces[$__DISCORD_STOREMANAGER] = DllStructCreate($__DISCORD_tagSTOREMANAGEREVENTS)
    DllStructSetData($tParams, "StoreEvents", DllStructGetPtr($__Discord_atEventInterfaces[$__DISCORD_STOREMANAGER]))
    DllStructSetData($tParams, "StoreVersion", 1)
    $__Discord_atEventInterfaces[$__DISCORD_VOICEMANAGER] = DllStructCreate($__DISCORD_tagVOICEMANAGEREVENTS)
    DllStructSetData($tParams, "VoiceEvents", DllStructGetPtr($__Discord_atEventInterfaces[$__DISCORD_VOICEMANAGER]))
    DllStructSetData($tParams, "VoiceVersion", 1)
    $__Discord_atEventInterfaces[$__DISCORD_ACHIEVEMENTMANAGER] = DllStructCreate($__DISCORD_tagACHIEVEMENTMANAGEREVENTS)
    DllStructSetData($tParams, "AchievementEvents", DllStructGetPtr($__Discord_atEventInterfaces[$__DISCORD_ACHIEVEMENTMANAGER]))
    DllStructSetData($tParams, "AchievementVersion", 1)

    Local $hDll = -1
    If StringRight($sDllFolderPath, 1) = "\" Or StringRight($sDllFolderPath, 1) = "/" Then
    Else
        $sDllFolderPath &= "\"
    EndIf
    If @AutoItX64 Then
        $hDll = DllOpen($sDllFolderPath & "discord_game_sdk64.dll")
    Else
        $hDll = DllOpen($sDllFolderPath & "discord_game_sdk32.dll")
    EndIf
    If $hDll = -1 Then
        Return SetError(-4, 0, False)
    EndIf
    $__Discord_hDll = $hDll

    __Discord_InitEvents()

    ; Result DiscordCreate(UInt32 version, ref FFICreateParams createParams, out IntPtr manager);
    Local $aResult = DllCall($__Discord_hDll, "int:cdecl", "DiscordCreate", "uint", 2, "ptr", DllStructGetPtr($tParams), "ptr*", Null)
    $__Discord_apMethodPtrs[$__DISCORD_CORE] = $aResult[3]

    If @error Then
        Return SetError(-5, @error, False)
    EndIf

    If $aResult[0] <> $DISCORD_OK Then
        __Discord_Dispose()
        Return SetError(-6, $aResult[0], False)
    EndIf

    ; Retrieve the method ptr table for this core instance
    $__Discord_atMethodInterfaces[$__DISCORD_CORE] = DllStructCreate($__DISCORD_tagCOREMETHODS, $__Discord_apMethodPtrs[$__DISCORD_CORE])

    __Discord_AchievementManager_Init()
    __Discord_ActivityManager_Init()
    __Discord_ApplicationManager_Init()
    __Discord_ImageManager_Init()
    __Discord_LobbyManager_Init()
    __Discord_NetworkManager_Init()
    __Discord_OverlayManager_Init()
    __Discord_RelationshipManager_Init()
    __Discord_StorageManager_Init()
    __Discord_StoreManager_Init()
    __Discord_UserManager_Init()
    __Discord_VoiceManager_Init()

    OnAutoItExitRegister("__Discord_Dispose")
    Return True
EndFunc

; $fnHandler: void LogHookCallbackHandler(LogLevel level, string message)
; return
; true good
; false bad
Func _Discord_SetLogHook($iLogLevel, $fnHandler)
    If VarGetType($iLogLevel) <> "Int32" Or $iLogLevel < $DISCORD_LOGLEVEL_ERROR Or $iLogLevel > $DISCORD_LOGLEVEL_DEBUG Then
        c(3333)
        Return False
    EndIf
    If $__Discord_hLogHookCallback = 0 Then
        $__Discord_hLogHookCallback = DllCallbackRegister("__Discord_LogHookCallbackHandler", "none:cdecl", "ptr;int;str")
    EndIf
    $__Discord_fnLogHookCallbackHandler = $fnHandler
    DllCallAddress("none:cdecl", _
                   DllStructGetData($__Discord_atMethodInterfaces[$__DISCORD_CORE], "SetLogHook"), _
                   "ptr", $__Discord_apMethodPtrs[$__DISCORD_CORE], _
                   "int", $iLogLevel, _
                   "ptr", Null, _
                   "ptr", DllCallbackGetPtr($__Discord_hLogHookCallback))
    Return True
EndFunc

; return
; string
Func _Discord_GetErrorString($iError)
    Switch $iError
        Case 0
            Return "Ok"
        Case 1
            Return "ServiceUnavailable"
        Case 2
            Return "InvalidVersion"
        Case 3
            Return "LockFailed"
        Case 4
            Return "InternalError"
        Case 5
            Return "InvalidPayload"
        Case 6
            Return "InvalidCommand"
        Case 7
            Return "InvalidPermissions"
        Case 8
            Return "NotFetched"
        Case 9
            Return "NotFound"
        Case 10
            Return "Conflict"
        Case 11
            Return "InvalidSecret"
        Case 12
            Return "InvalidJoinSecret"
        Case 13
            Return "NoEligibleActivity"
        Case 14
            Return "InvalidInvite"
        Case 15
            Return "NotAuthenticated"
        Case 16
            Return "InvalidAccessToken"
        Case 17
            Return "ApplicationMismatch"
        Case 18
            Return "InvalidDataUrl"
        Case 19
            Return "InvalidBase64"
        Case 20
            Return "NotFiltered"
        Case 21
            Return "LobbyFull"
        Case 22
            Return "InvalidLobbySecret"
        Case 23
            Return "InvalidFilename"
        Case 24
            Return "InvalidFileSize"
        Case 25
            Return "InvalidEntitlement"
        Case 26
            Return "NotInstalled"
        Case 27
            Return "NotRunning"
        Case 28
            Return "InsufficientBuffer"
        Case 29
            Return "PurchaseCanceled"
        Case 30
            Return "InvalidGuild"
        Case 31
            Return "InvalidEvent"
        Case 32
            Return "InvalidChannel"
        Case 33
            Return "InvalidOrigin"
        Case 34
            Return "RateLimited"
        Case 35
            Return "OAuth2Error"
        Case 36
            Return "SelectChannelTimeout"
        Case 37
            Return "GetGuildTimeout"
        Case 38
            Return "SelectVoiceForceRequired"
        Case 39
            Return "CaptureShortcutAlreadyListening"
        Case 40
            Return "UnauthorizedForAchievement"
        Case 41
            Return "InvalidGiftCode"
        Case 42
            Return "PurchaseError"
        Case 43
            Return "TransactionAborted"
        Case Else
            Return "Invalid error code"
    EndSwitch
EndFunc

; return
; true good
; false bad
; error
; discord result
Func _Discord_RunCallbacks()
    Local $aResult = DllCallAddress("int:cdecl", _
                                    DllStructGetData($__Discord_atMethodInterfaces[$__DISCORD_CORE], "RunCallbacks"), _
                                    "ptr", $__Discord_apMethodPtrs[$__DISCORD_CORE])
    If $aResult[0] <> $DISCORD_OK Then
        Return SetError($aResult[0], 0, False)
    EndIf
    Return True
EndFunc

Func __Discord_InitEvents()
EndFunc

; Handler for: void SetLogHookCallback(IntPtr ptr, LogLevel level, [MarshalAs(UnmanagedType.LPStr)]string message)
Func __Discord_LogHookCallbackHandler($pPtr, $iLevel, $sMessage)
    #forceref $pPtr
    If $__Discord_fnLogHookCallbackHandler <> 0 Then
        $__Discord_fnLogHookCallbackHandler($iLevel, $sMessage)
    EndIf
EndFunc

Func __Discord_Dispose()
    OnAutoItExitUnRegister("__Discord_Dispose")
    __Discord_AchievementManager_Dispose()
    __Discord_ActivityManager_Dispose()
    __Discord_ApplicationManager_Dispose()
    __Discord_ImageManager_Dispose()
    __Discord_LobbyManager_Dispose()
    __Discord_NetworkManager_Dispose()
    __Discord_OverlayManager_Dispose()
    __Discord_RelationshipManager_Dispose()
    __Discord_StorageManager_Dispose()
    __Discord_StoreManager_Dispose()
    __Discord_UserManager_Dispose()
    __Discord_VoiceManager_Dispose()
    If $__Discord_apMethodPtrs[$__DISCORD_CORE] Then
        DllCallAddress("none:cdecl", _
                       DllStructGetData($__Discord_atMethodInterfaces[$__DISCORD_CORE], "Destroy"), _
                       "ptr", $__Discord_apMethodPtrs[$__DISCORD_CORE])
        $__Discord_apMethodPtrs[$__DISCORD_CORE] = 0
    EndIf
    If $__Discord_hLogHookCallback Then
        DllCallbackFree($__Discord_hLogHookCallback)
        $__Discord_hLogHookCallback = 0
    EndIf
    If $__Discord_hDll Then
        DllClose($__Discord_hDll)
        $__Discord_hDll = 0
    EndIf
EndFunc