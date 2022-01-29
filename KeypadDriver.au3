#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/pe /sf /sv /rm
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
; ================================================================================
;
; KeypadDriver.au3
; Runs the main loop
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
Global $activity[18]
Global $main_richPresenceUpdateTimer
Global $main_discordHasFinishSetup = False

SetGuiOpeningKey("{F4}")
Opt("GUICloseOnESC", 0)
Opt("TrayAutoPause", 0)
Opt("TrayMenuMode", 1)
Opt("TrayOnEventMode", 1)
TraySetIcon($iconPath)
TraySetToolTip("Keypad Driver")
OnAutoItExitRegister("OnExit")

Func Main()
    _CommSetDllPath(@ScriptDir & "\Include\commg.dll")
    If FileExists($main_configPath) Then
        ConfigLoad($main_configPath)
    Else  ; Default bindings
        BindKey(1, "ESC")
        BindKey(2, "`")
        BindKey(3, "c")
        BindKey(4, "", "!{UP}")
        BindKey(5, "", "^a")
        BindKey(6, "f")
        BindKey(7, "", "!{TAB}")
        BindKey(8, "", "!{DOWN}")
        BindKey(9, "r")
        BindKey(10, "t")
        BindKey(11, "", "{LEFT}")
        BindKey(12, "", "{RIGHT}")
    EndIf
    Sleep(200)
    OpenGui()
    Connect()
    If Not _DotNet_Load(@ScriptDir & "\Include\Dlls\SystemAudioWrapper.dll") Then
        Throw("Main", "Loading SystemAudioWrapper.dll failed! error: " & @error, "Terminating!")
        Terminate()
    EndIf
    If Not _Discord_Init(935375293437337630, @ScriptDir & "\Include\Autoit-DiscordGameSDK\") Then
        Throw("Main", "Failed to init DiscordGameSDK!", @error, @extended)
        Terminate()
    EndIf
    
    $main_trayBtnToggleBassSync = TrayCreateItem("Toggle bass sync")
    TrayItemSetOnEvent($main_trayBtnToggleBassSync, "ToggleBassSync")
    $main_trayBtnExit = TrayCreateItem("Close")
    TrayItemSetOnEvent($main_trayBtnExit, "Terminate")
    TraySetOnEvent($TRAY_EVENT_PRIMARYDOUBLE, "OpenGui")
    TraySetClick(8)

    ; Less thing to run
    ; _Discord_SetLogHook($DISCORD_LOGLEVEL_DEBUG, LogHookHandler)
    _Discord_UserManager_OnCurrentUserUpdate(OnCurrentUserUpdateHandler)
    Local $now = _Date_Time_GetSystemTime()
    Local $unixUtc = _DateDiff('s', "1970/01/01 00:00:00", _Date_Time_SystemTimeToDateTimeStr($now, 1))
    $activity[3] = "Smashing keys"
    $activity[4] = "0 keys pressed"
    $activity[5] = $unixUtc
    $activity[7] = "iconwithpadding"
    $activity[8] = "All done from an Autoit script!"
    $activity[9] = "speed_silver"
    $activity[10] = "Bruh"
    ; It will not update RP and crash on exiting somehow if we didn't let it finish connecting
    Do
        _Discord_RunCallbacks()
    Until $main_discordHasFinishSetup
    
    ; Local $t = 0
    ; Local $tt = 0
    While 1
        $main_loopStartTime = TimerInit()
        If (TimerDiff($main_timer) >= ($main_msPerScan - ($main_loopPeriod > $main_msPerScan ? $main_msPerScan : $main_loopPeriod))) Then
            EnsureConnection()

            If IsKeyDataReceived() Then
                PollKeys()
                $main_slowPollingTimer = TimerInit()
                ; c("Button: $ pressed, state: $", 1, $_pressedBtnNum, $_pressedBtnState)
                If Not IsGuiOpened() Then
                    SendKey(GetKeyDataNum(), GetKeyDataState())
                    If GetKeyDataState() = 1 Then
                        $main_pressCount += 1
                    EndIf
                EndIf
            ElseIf Not IsGuiOpened() And TimerDiff($main_slowPollingTimer) >= 60000 Then
                If Not $main_audioSyncEnable Then Sleep(100)
            EndIf

            If $main_audioSyncEnable And TimerDiff($main_audioSyncTimer) >= 1000 / 30 And $connectionStatus = $CONNECTED Then
                $main_audioSyncTimer = TimerInit()
	            Local $currentAudioLevel = $main_oBassLevel.GetBassLevel() * 50
                SendMsgToKeypad($MSG_SETRGBBRIGHTNESS, Int(MIn($currentAudioLevel, $main_bassLevelCap) * ((255 * 1.5 / 4) / $main_bassLevelCap)))
            EndIf
            
            If IsGuiOpened() Then
                UpdateGui()
            EndIf
            
            If TimerDiff($main_richPresenceUpdateTimer) >= 8 * 1000 Then
                $main_richPresenceUpdateTimer = TimerInit()
                UpdateRP()
                _Discord_RunCallbacks()
            EndIf
                        
            ; Debug loop time and loop frequency output
            ; If TimerDiff($tt) >= 1000 Then
            ;     $tt = TimerInit()
            ;     c($t)
            ;     c($main_loopPeriod)
            ;     $t = 0
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
    $activity[4] = $main_pressCount & " keys pressed"
    _Discord_ActivityManager_UpdateActivity($activity, UpdateActivityHandler)
EndFunc

Func UpdateActivityHandler($result)
EndFunc

Func OnCurrentUserUpdateHandler()
    $main_discordHasFinishSetup = True
EndFunc

Func LogHookHandler($level, $msg)
    c("Log: level $, $", 1, $level, $msg)
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
            Throw("Main", "Initializing SystemAudioBassLevel failed! error: " & @error, _
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

Func Min($iNum1, $iNum2)
	Return ($iNum1 > $iNum2) ? $iNum2 : $iNum1
EndFunc

Func Terminate()
    Exit
EndFunc

Func OnExit()
    CloseGui()
    DisableAudioSync()
EndFunc