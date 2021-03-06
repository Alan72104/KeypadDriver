#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/pe /sf /sv /rm
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#pragma compile(inputboxres, true)
; ================================================================================
;
; KeypadDriver.au3
; Starts all the shit together
;
; ================================================================================

#RequireAdmin
#include-once
#include <Date.au3>
#include <FileConstants.au3>
#include <TrayConstants.au3>
#include "Include\LibDebug.au3"
#include "Include\CommMG.au3"
#include "Include\DotNetDLLWrapper.au3"
#include "Include\Autoit-DiscordGameSDK\DiscordGameSDK.au3"
#include "KeypadDriver.Vars.au3"
#include "KeypadDriver.Gui.au3"
#include "KeypadDriver.Serial.au3"
#include "KeypadDriver.Keys.au3"

Global $main_configPath = @ScriptDir & "\keypadconfig.ini"
Global Const $main_scansPerSec = 1000
Global Const $main_msPerScan = 1000 / $main_scansPerSec
Global $main_loopPeriod, $main_loopStartTime, $main_timer
Global $main_slowPollingTimer
Global $main_audioSyncEnable = False
Global $main_oBassLevel = Null
Global $main_audioSyncTimer
Global Const $main_bassLevelCap = 580
Global $main_trayBtnExit, $main_trayBtnToggleBassSync
Global $main_pressCount = 0
Global $main_timeframeKeyCount = 0
Global $main_historyQueue = Queue(1000, 1.7976931348623157e+308)
Global $main_maxKPS = 0
Global $main_activity[18]
Global $main_richPresenceUpdateTimer
Global $main_discordHasFinishSetup = False
Global $main_comErrorHandler = ObjEvent("AutoIt.Error", "ComErrorHandler")
SetGuiOpeningKey("{F4}")
Opt("GUICloseOnESC", 0)
Opt("TrayAutoPause", 0)
Opt("TrayMenuMode", 1)
Opt("TrayOnEventMode", 1)
TraySetIcon($iconPath)
TraySetToolTip("Keypad Driver")

Func Main()
    _CommSetDllPath(@ScriptDir & "\Include\commg.dll")
    If FileExists($main_configPath) Then
        $main_pressCount = Int(IniRead($main_configPath, "Statistics", "KeyPressCount", "0"))
        KeysSetProfile($main_configPath, IniRead($main_configPath, "Main", "Profile", "Main"))
    Else  ; Create default config
        IniWrite($main_configPath, "Main", "Profile", "Main")
        IniWrite($main_configPath, "Statistics", "KeyPressCount", 0)
        KeysSaveConfig($main_configPath)
    EndIf
    If Not _DotNet_Load(@ScriptDir & "\Include\Dlls\SystemAudioWrapper.dll") Then
        Throw("Main", "Loading SystemAudioWrapper.dll failed! error: " & @error, "Terminating!")
        Terminate()
    EndIf
    If Not _Discord_Init(935375293437337630, $DISCORD_CREATEFLAGS_DEFAULT, @ScriptDir & "\Include\Autoit-DiscordGameSDK\") Then
        Throw("Main", "Failed to init DiscordGameSDK!", @error, @extended)
        Terminate()
    EndIf
    
    $main_trayBtnToggleBassSync = TrayCreateItem("Toggle bass sync")
    TrayItemSetOnEvent($main_trayBtnToggleBassSync, "ToggleBassSync")
    $main_trayBtnExit = TrayCreateItem("Close")
    TrayItemSetOnEvent($main_trayBtnExit, "Terminate")
    TraySetOnEvent($TRAY_EVENT_PRIMARYDOUBLE, "OpenGui")
    TraySetClick(8)

    ; _Discord_SetLogHook($DISCORD_LOGLEVEL_DEBUG, LogHookHandler)
    _Discord_UserManager_OnCurrentUserUpdate(OnCurrentUserUpdateHandler)
    Local $now = _Date_Time_GetSystemTime()
    Local $unixUtc = _DateDiff('s', "1970/01/01 00:00:00", _Date_Time_SystemTimeToDateTimeStr($now, 1))
    $main_activity[5] = $unixUtc
    $main_activity[7] = "iconwithpadding"
    $main_activity[8] = "Smashing keys"
    $main_activity[9] = "speed_silver"
    $main_activity[10] = "Autoit on top"
    
    Connect()
    OpenGui()
    
    $main_lastPressTime = TimerInit()
    ; Local $t = 0
    ; Local $tt = 0
    While 1
        $main_loopStartTime = TimerInit()
        If (TimerDiff($main_timer) >= ($main_msPerScan - ($main_loopPeriod > $main_msPerScan ? $main_msPerScan : $main_loopPeriod))) Then
            EnsureConnection()

            PollKeys()
            If IsKeyDataReceived() Then
                $main_slowPollingTimer = TimerInit()
                ; c("Button: $ pressed, state: $", 1, $_pressedBtnNum, $_pressedBtnState)
                If Not IsGuiOpened() Then
                    SendKey(GetKeyDataNum(), GetKeyDataState())
                    If GetKeyDataState() = 1 Then
                        $main_pressCount += 1
                        $main_timeframeKeyCount += 1
                        QueuePush($main_historyQueue, TimerInit())
                    EndIf
                EndIf
            ElseIf Not IsGuiOpened() And TimerDiff($main_slowPollingTimer) >= 60000 Then
                If Not $main_audioSyncEnable Then Sleep(100)
            EndIf
            
            While $main_historyQueue[0] And TimerDiff(QueuePeak($main_historyQueue)) >= 300
                QueuePop($main_historyQueue, 1.7976931348623157e+308)
                $main_maxKPS = Max($main_maxKPS, $main_timeframeKeyCount / 3 * 10)
                $main_timeframeKeyCount -= 1
            WEnd

            If $main_audioSyncEnable And TimerDiff($main_audioSyncTimer) >= 1000 / 30 And $connectionStatus = $CONNECTED Then
                $main_audioSyncTimer = TimerInit()
	            Local $currentAudioLevel = $main_oBassLevel.GetBassLevel() * 50
                SendMsgToKeypad($MSG_SETRGBBRIGHTNESS, Int(Min($currentAudioLevel, $main_bassLevelCap) * ((255 * 1.5 / 4) / $main_bassLevelCap)))
            EndIf
            
            If IsGuiOpened() Then
                UpdateGui()
            EndIf
            
            If TimerDiff($main_richPresenceUpdateTimer) >= 8 * 1000 Then
                $main_richPresenceUpdateTimer = TimerInit()
                _Discord_RunCallbacks()
                UpdateRP()
            EndIf
                        
            ; Debug loop time and loop frequency output
            ; If TimerDiff($tt) >= 1000 Then
                ; $tt = TimerInit()
                ; c($t)
                ; c($main_loopPeriod)
                ; $t = 0
            ; EndIf
            ; $t += 1

            KeyDataProcessed()
            
            $main_timer = TimerInit()
            $main_loopPeriod = $main_loopPeriod * 0.6 + TimerDiff($main_loopStartTime) * 0.4  ; Don't modify the measured loop time immediately as it might float around
        EndIf
    WEnd
EndFunc

Main()

Func UpdateRP()
    Local Static $lastCount = -1
    ; If $lastCount = $main_pressCount Then
        ; Return
    ; EndIf
    ; $lastCount = $main_pressCount
    $main_activity[4] = $main_pressCount & " keys pressed"
    If $connectionStatus = $CONNECTED Then
        If TimerDiff($main_slowPollingTimer) >= 60000 Then
            $main_activity[3] = "idle"
        Else
            $main_activity[3] = "max speed " & Round($main_maxKPS, 2) & " keys/second"
        EndIf
    Else
        $main_activity[3] = "keypad not connected"
    EndIf
    _Discord_ActivityManager_UpdateActivity($main_activity, UpdateActivityHandler)
EndFunc

Func UpdateActivityHandler($result)
    ; If $result <> $DISCORD_OK Then
        ; c("UpdateActivity failed with $", 1, _Discord_GetErrorString(@error))
    ; Else
        ; c("UpdateActivity succeeded")
    ; EndIf
EndFunc

Func OnCurrentUserUpdateHandler()
    $main_discordHasFinishSetup = True
    ; Local $user = _Discord_UserManager_GetCurrentUser()
    ; If $user = False Then
        ; c("GetCurrentUser failed with $", 1, _Discord_GetErrorString(@error))
    ; Else
        ; c("User updated\n  Id: $\n  Username: $\n  Discriminator: $\n  Avatar: $\n  Bot: $", 1, $user[0], $user[1], $user[2], $user[3], $user[4])
    ; EndIf
EndFunc

Func LogHookHandler($level, $msg)
    ; c("Log: level $, $", 1, $level, $msg)
EndFunc

Func ToggleBassSync()
    If $main_audioSyncEnable Then
        DisableAudioSync()
    Else
        EnableAudioSync()
    EndIf
EndFunc

Func EnableAudioSync()
    If Not $main_audioSyncEnable Then
        $main_audioSyncEnable = True
        $main_oBassLevel = ObjCreate("SystemAudioWrapper.SystemAudioBassLevel")
        If @error Then
            Throw("EnableAudioSync", "Initializing SystemAudioBassLevel failed! error: " & @error, _
                                     "Terminating!")
            Terminate()
        EndIf
        $main_oBassLevel.Start(4096, 2, 4)
        $main_audioSyncTimer = TimerInit()
    EndIf
EndFunc

Func DisableAudioSync()
    If $main_audioSyncEnable Then
        $main_audioSyncEnable = False
        $main_oBassLevel = Null  ; Delete the object
        SendMsgToKeypad($MSG_SETRGBBRIGHTNESS, 63)
    EndIf
EndFunc

Func GetConfigPath()
    Return $main_configPath
EndFunc

Func IsBassSyncEnabled()
    Return $main_audioSyncEnable
EndFunc

Func ComErrorHandler($oError)
    Throw("ComErrorHandler", c("COM Error occurred on line $!", 1, $oError.scriptline), _
                             c("    number        : 0x" & Hex($oError.number)), _
                             c("    windescription: " & StringStripWS($oError.windescription, $STR_STRIPLEADING + $STR_STRIPTRAILING)), _
                             c("    description   : " & $oError.description), _
                             c("    source        : " & $oError.source), _
                             c("    helpfile      : " & $oError.helpfile), _
                             c("    helpcontext   : " & $oError.helpcontext), _
                             c("    lastdllerror  : " & $oError.lastdllerror), _
                             c("    scriptline    : " & $oError.scriptline), _
                             c("    retcode       : 0x" & Hex($oError.retcode)))
    Terminate()
EndFunc

Func Terminate()
    CloseGui()
    DisableAudioSync()
    IniWrite($main_configPath, "Statistics", "KeyPressCount", String($main_pressCount))
    IniWrite($main_configPath, "Main", "Profile", KeysGetProfile())
    Exit
EndFunc

; Utils

Func Queue($size, $n = 0)
    Local $queue[$size + 3]
    $queue[0] = 0 ; Count
    $queue[1] = 3 ; Start
    $queue[2] = $size
    For $i = 3 To $size + 3 - 1
        $queue[$i] = $n
    Next
    Return $queue
EndFunc

Func QueuePush(ByRef $q, $e)
    $q[Mod($q[1] + $q[0] - 3, $q[2]) + 3] = $e
    $q[0] += 1
EndFunc

Func QueuePop(ByRef $q, $n = 0)
    ; Local $t = $q[$q[1]]
    $q[$q[1]] = $n
    $q[1] = Mod($q[1] - 2, $q[2]) + 3
    $q[0] -= 1
    ; Return $t
EndFunc

Func QueuePeak(ByRef $q)
    Return $q[$q[1]]
EndFunc

Func Min($iNum1, $iNum2)
	Return ($iNum1 > $iNum2) ? $iNum2 : $iNum1
EndFunc

Func Max($iNum1, $iNum2)
	Return ($iNum1 < $iNum2) ? $iNum2 : $iNum1
EndFunc