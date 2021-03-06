; ================================================================================
;
; KeypadDriver.Gui.au3
; Gui related
;
; ================================================================================

#include-once
#include <Array.au3>
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <StringConstants.au3>
#include <WindowsConstants.au3>
#include "Include\CommMG.au3"
#include "KeypadDriver.au3"
#include "KeypadDriver.Vars.au3"
#include "KeypadDriver.Serial.au3"
#include "KeypadDriver.Keys.au3"

Global $gui_isGuiOpened = False
Global $gui_hGui
Global $gui_msg

Global $gui_idButtonBtns[$WIDTH * $HEIGHT]

Global Enum $gui_BIND, $gui_REMOVE
Global $gui_bindingAction = $gui_BIND
Global $gui_isBindingKeys = False
Global $gui_currentlyBinding = 0
Global $gui_idGroupBinding, $gui_idLabelCurrentlyBinding, $gui_idLabelBindingArrow, $gui_idLabelBindingStr, $gui_idInputKeyUp, $gui_idInputKeyDown, $gui_idButtonConfirm, $gui_idButtonCancel

Global $gui_idRadioBind, $gui_idRadioRemove

Global Enum $gui_MONITORRGB, $gui_MONITORKEYPRESS
Global $gui_monitoringType = $gui_MONITORRGB
Global $gui_idRadioMonitorRgb, $gui_idRadioMonitorKeypress

Global $gui_idButtonEnableModifiedKeys, $gui_idButtonDisableModifiedKeys

Global $gui_idComboRgbState, $gui_idButtonRgbUpdate, $gui_idButtonRgbIncreaseBrightness, $gui_idButtonRgbDecreaseBrightness, $gui_idButtonEffectIncreaseSpeed, $gui_idButtonEffectDecreaseSpeed
Global $gui_idCheckBoxBassSync

Global $gui_idLabelConnection

Global $gui_idButtonClose, $gui_idComboProfile, $gui_idButtonNewProfile

Global Enum $gui_UPDATERGBSTATE, $gui_GETRGBDATA, $gui_INCREASERGBBRIGHTNESS, $gui_DECREASERGBBRIGHTNESS, $gui_INCREASEEFFECTSPEED, $gui_DECREASEEFFECTSPEED

Global $gui_syncingButtonIndex = 0
Global $gui_syncingRgbIndex = 0
Global $gui_rgbBuffer[$WIDTH * $HEIGHT][3]

Opt("GUIOnEventMode", 1)

; Called whenever a control is clicked
Func OnMsg()
    $gui_msg = @GUI_CtrlId
    Switch $gui_msg
        ; The gui "x" button
        Case $GUI_EVENT_CLOSE
            CloseGui()
        
        ; The "Close the driver" button
        Case $gui_idButtonClose
            CloseGui()
            Terminate()
        
        ; The profile selector
        Case $gui_idComboProfile
            Local $profile = GUICtrlRead($gui_idComboProfile)
            ShowBindingGroup(False)
            KeysSetProfile(GetConfigPath(), $profile)
            UpdateBtnLabels()

        ; The new profile button
        Case $gui_idButtonNewProfile
            Local $name = InputBox("Create a new keymap profile", "Enter the name of your new profile")
            If $name <> "" Then
                ShowBindingGroup(False)
                GUICtrlSetData($gui_idComboProfile, $name, $name)
                KeysSaveConfig(GetConfigPath(), $name)
                KeysSetProfile(GetConfigPath(), $name)
            EndIf
        
        ; The binding action selectors
        Case $gui_idRadioBind
            $gui_bindingAction = $gui_BIND
        Case $gui_idRadioRemove
            $gui_bindingAction = $gui_REMOVE
            If $gui_isBindingKeys Then
                $gui_isBindingKeys = False
                ShowBindingGroup(0)
            EndIf
        
        ; The monitoring type selectors
        Case $gui_idRadioMonitorRgb
            $gui_monitoringType = $gui_MONITORRGB
        Case $gui_idRadioMonitorKeypress
            $gui_monitoringType = $gui_MONITORKEYPRESS
            For $j = 0 To $HEIGHT - 1
                For $i = 0 To $WIDTH - 1
                    UpdateBtnLabelRgb($j * $WIDTH + $i + 1, 255, 255, 255)
                Next
            Next

        ; The modified keys control buttons
        Case $gui_idButtonEnableModifiedKeys
            SendMsgToKeypad($MSG_ENABLEMODIFIEDKEYS, 0)
        Case $gui_idButtonDisableModifiedKeys
            SendMsgToKeypad($MSG_DISABLEMODIFIEDKEYS, 0)
        
        ; The rgb "Update" button
        Case $gui_idButtonRgbUpdate
            SendMsgToKeypad($MSG_UPDATERGBSTATE, ArrayFind($rgbStates, GUICtrlRead($gui_idComboRgbState)))
        
        ; The rgb brightness control buttons
        Case $gui_idButtonRgbIncreaseBrightness
            SendMsgToKeypad($MSG_INCREASERGBBRIGHTNESS, 0)
        Case $gui_idButtonRgbDecreaseBrightness
            SendMsgToKeypad($MSG_DECREASERGBBRIGHTNESS, 0)

        ; The effect speed control buttons
        Case $gui_idButtonEffectIncreaseSpeed
            SendMsgToKeypad($MSG_INCREASEEFFECTSPEED, 0)
        Case $gui_idButtonEffectDecreaseSpeed
            SendMsgToKeypad($MSG_DECREASEEFFECTSPEED, 0)

        ; The bass sync enable checkbox
        Case $gui_idCheckBoxBassSync
            If GUICtrlRead($gui_idCheckBoxBassSync) = $GUI_CHECKED Then
                EnableAudioSync()
            Else
                DisableAudioSync()
            EndIf
        
        ; The binding "Confirm" button, updates the key to new bindings
        Case $gui_idButtonConfirm
            BindKey($gui_currentlyBinding, GUICtrlRead($gui_idInputKeyUp), GUICtrlRead($gui_idInputKeyDown))
            UpdateBtnLabels()
            $gui_isBindingKeys = False
            ShowBindingGroup(False)
            KeysSaveConfig(GetConfigPath())
        
        ; The binding "Cancel" button, closes the "Binding" group
        Case $gui_idButtonCancel
            $gui_isBindingKeys = False
            ShowBindingGroup(False)
            KeysSaveConfig(GetConfigPath())
        
        Case Else
            ; Handle the key buttons in for loop to get the button number
            For $j = 0 To $HEIGHT - 1
                For $i = 0 To $WIDTH - 1
                    If $gui_msg = $gui_idButtonBtns[$j * $WIDTH + $i] Then
                        Switch $gui_bindingAction
                            ; Open the "Binding" group for the specific key
                            Case $gui_BIND
                                $gui_isBindingKeys = True
                                $gui_currentlyBinding = $j * $WIDTH + $i + 1
                                GUICtrlSetData($gui_idLabelCurrentlyBinding, "Binding key " & $gui_currentlyBinding)
                                GUICtrlSetData($gui_idInputKeyUp, GetKeybindingForKey($j * $WIDTH + $i + 1, $KEYSTROKEUP))
                                GUICtrlSetData($gui_idInputKeyDown, GetKeybindingForKey($j * $WIDTH + $i + 1, $KEYSTROKEDOWN))
                                ShowBindingGroup(True)
                            
                            ; Remove the bindings for the specific key
                            Case $gui_REMOVE
                                BindRemove($j * $WIDTH + $i + 1)
                                UpdateBtnLabels()
                        EndSwitch
                        Return
                    EndIf
                Next
            Next
    EndSwitch
EndFunc

Func UpdateGui($onlyLabel = False)
    Local Static $lastConnectionStatus = -1

    ; Only update the label if needed to prevent flickering
    If $lastConnectionStatus <> $connectionStatus Or $onlyLabel Then
        $lastConnectionStatus = $connectionStatus
        Switch $connectionStatus
            Case $NOTCONNECTED
                GUICtrlSetData($gui_idLabelConnection, "Not connected, detecting the port...")
            Case $CONNECTIONFAILED
                GUICtrlSetData($gui_idLabelConnection, "Cannot connect to " & GetComPort() & ", retrying...")
            Case $PORTDETECTIONFAILED
                GUICtrlSetData($gui_idLabelConnection, "COM port auto detection failed, please make sure you have the keypad plugged in!")
            Case $CONNECTED
                GUICtrlSetData($gui_idLabelConnection, "Connected to " & GetComPort())
        EndSwitch
    EndIf
    if $onlyLabel Then Return

    ; Update gui key status
    If $connectionStatus = $CONNECTED Then
        Switch $gui_monitoringType
            Case $gui_MONITORKEYPRESS
                If IsKeyDataReceived() Then
                    UpdateBtnLabelRgb(GetKeyDataNum(), 255, GetKeyDataState() ? 0 : 255, GetKeyDataState() ? 0 : 255)
                EndIf
            Case $gui_MONITORRGB
                SyncGuiRgb()
        EndSwitch
    EndIf
EndFunc

; Retrieves the rgb info from the keypad and syncs them to the gui
Func SyncGuiRgb()
    Local Static $syncTimer = 0

    If $connectionStatus <> $CONNECTED Then Return
    If TimerDiff($syncTimer) > 1000 / 30 Then
        $syncTimer = TimerInit()
        
        ; Clear the serial input buffer in case there are still some scrapped bytes
        _CommClearInputBuffer()
        SendMsgToKeypad($MSG_GETRGBDATA, 0)
        $gui_syncingButtonIndex = 0
        $gui_syncingRgbIndex = 0
        
        ; Constantly poll the bytes from serial until all the rgb infos have been received
        ; One button consists of a RGB value, a RGB value consists of 3 bytes which are R, G and B
        While 1
            Do
                PollData()

                ; Watch out for timeouts that could potentially lock the script
                If TimerDiff($syncTimer) > 100 Then
                    ByteProcessed()
                    ; Don't forget to clear buffer
                    _CommClearInputBuffer()
                    Return
                EndIf
            Until IsByteReceived()
            $gui_rgbBuffer[$gui_syncingButtonIndex][$gui_syncingRgbIndex] = GetByte()
            ByteProcessed()
            $gui_syncingRgbIndex += 1
            
            ; If 3 bytes have been received, switch to the next button
            If $gui_syncingRgbIndex = 3 Then
                $gui_syncingRgbIndex = 0
                $gui_syncingButtonIndex += 1
            EndIf
            
            ; If all the buttons' rgb have been received, update the key buttons' colors and return
            If $gui_syncingButtonIndex = $WIDTH * $HEIGHT Then
                ; TODO: Prevent window flashing
                For $j = 0 To $HEIGHT - 1
                    For $i = 0 To $WIDTH - 1
                        UpdateBtnLabelRgb($j * $WIDTH + $i + 1, $gui_rgbBuffer[$j * $WIDTH + $i][0], $gui_rgbBuffer[$j * $WIDTH + $i][1], $gui_rgbBuffer[$j * $WIDTH + $i][2])
                    Next
                Next
                Return
            EndIf
        WEnd
    EndIf
EndFunc

; Updates the key buttons' text to their "keyStrokeDown"s
Func UpdateBtnLabels()
    For $j = 0 To $HEIGHT - 1
        For $i = 0 To $WIDTH - 1
            GUICtrlSetData($gui_idButtonBtns[$j * $WIDTH + $i], ($j * $WIDTH + $i + 1) & @CRLF & _
                                                                KeyHasBinding($j * $WIDTH + $i + 1, $KEYSTROKEDOWN) ? GetKeybindingForKey($j * $WIDTH + $i + 1, $KEYSTROKEDOWN) : "None")
        Next
    Next
EndFunc

; Updates the background colors of the key buttons
Func UpdateBtnLabelRgb($num, $r, $g, $b)
    If $num <= $WIDTH * $HEIGHT Then
        GUICtrlSetBkColor($gui_idButtonBtns[$num - 1], $r * 256 * 256 + $g * 256 + $b)
    EndIf
EndFunc

; Shows or hides the "Binding" group and the inside controls
Func ShowBindingGroup($state)
    $state = $state ? $GUI_SHOW : $GUI_HIDE
    GUICtrlSetState($gui_idGroupBinding, $state)
    GUICtrlSetState($gui_idLabelCurrentlyBinding, $state)
    GUICtrlSetState($gui_idLabelBindingArrow, $state)
    GUICtrlSetState($gui_idInputKeyUp, $state)
    GUICtrlSetState($gui_idInputKeyDown, $state)
    GUICtrlSetState($gui_idButtonConfirm, $state)
    GUICtrlSetState($gui_idButtonCancel, $state)
EndFunc

Func SetGuiOpeningKey($key)
    HotKeySet($key, "OpenGui")
EndFunc

; Creates the gui 
Func OpenGui()
    ; If gui is already opened, activate the window instead
    If $gui_isGuiOpened Then Return WinActivate("THE Keypad Control Panel")
    
    $gui_isGuiOpened = True
    $gui_hGui = GUICreate("THE Keypad Control Panel", 750, 500, Default, Default, Default, $WS_EX_TOPMOST)
    GUISetOnEvent($GUI_EVENT_CLOSE, "CloseGui")

    ; vvvvvvvvvvvvvvvvvvvvvvvvv Group buttons vvvvvvvvvvvvvvvvvvvvvvvvv
    GUICtrlCreateGroup("Buttons", 50, 30, _
                                  15 + 60 + 85 * 3 + 15, _
                                  15 + 60 + 85 * 2 + 15)
        For $j = 0 To $HEIGHT - 1
            For $i = 0 To $WIDTH - 1
                $gui_idButtonBtns[$j * $WIDTH + $i] = GUICtrlCreateButton(($j * $WIDTH + $i + 1) & @CRLF & _
                                                                       KeyHasBinding($j * $WIDTH + $i + 1, $KEYSTROKEDOWN) ? GetKeybindingForKey($j * $WIDTH + $i + 1, $KEYSTROKEDOWN) : "None", _
                                                                       50 + 15 + $i * 85, _
                                                                       30 + 15 + $j * 85, _
                                                                       60, 60, $BS_MULTILINE)
                GUICtrlSetOnEvent($gui_idButtonBtns[$j * $WIDTH + $i], "OnMsg")
            Next
        Next
    GUICtrlCreateGroup("", -99, -99, 1, 1)
    ; ^^^^^^^^^^^^^^^^^^^^^^^^^ Group buttons ^^^^^^^^^^^^^^^^^^^^^^^^^
    
    ; vvvvvvvvvvvvvvvvvvvvvvvvv Group rgb controls vvvvvvvvvvvvvvvvvvvvvvvvv
    GUICtrlCreateGroup("RGB Controls", 50, (30 + 15 + 60 + 85 * 2 + 15) + 15, _
                                           15 + 150 + 15 + 55 + (5 + 15) * 2 + 15 + 100 + 15, _
                                           15 + 25 + 8 + 25 + 15)
        $gui_idComboRgbState = GUICtrlCreateCombo($rgbStates[0], 50 + 15, _
                                                                 (30 + 15 + 60 + 85 * 2 + 15) + 15 + 15, _
                                                                 150, 30)
            GUICtrlSetOnEvent($gui_idComboRgbState, "OnMsg")
            GUICtrlSetData($gui_idComboRgbState, _ArrayToString($rgbStates, "|", 1))
        
        $gui_idButtonRgbUpdate = GUICtrlCreateButton("Update", 50 + 15, _
                                                               (30 + 15 + 60 + 85 * 2 + 15) + 15 + 15 + 25 + 8, _
                                                               150, 25)
            GUICtrlSetOnEvent($gui_idButtonRgbUpdate, "OnMsg")
        
        GUICtrlCreateLabel("Brightness:", 50 + 15 + 150 + 15, _
                                          (30 + 15 + 60 + 85 * 2 + 15) + 15 + 15 + 3, _
                                          55, 15)
        
        $gui_idButtonRgbIncreaseBrightness = GUICtrlCreateButton("+", 50 + 15 + 150 + 15 + 55 + 5, _
                                                                      (30 + 15 + 60 + 85 * 2 + 15) + 15 + 15, _
                                                                      15, 25)
            GUICtrlSetOnEvent($gui_idButtonRgbIncreaseBrightness, "OnMsg")
        
        $gui_idButtonRgbDecreaseBrightness = GUICtrlCreateButton("-", 50 + 15 + 150 + 15 + 55 + 5 + 15 + 10, _
                                                                      (30 + 15 + 60 + 85 * 2 + 15) + 15 + 15, _
                                                                      15, 25)
            GUICtrlSetOnEvent($gui_idButtonRgbDecreaseBrightness, "OnMsg")
        
        GUICtrlCreateLabel("Speed:", 50 + 15 + 150 + 15, _
                                          (30 + 15 + 60 + 85 * 2 + 15) + 15 + 15 + 25 + 8 + 3, _
                                          55, 15)
        $gui_idButtonEffectIncreaseSpeed = GUICtrlCreateButton("+", 50 + 15 + 150 + 15 + 55 + 5, _
                                                                    (30 + 15 + 60 + 85 * 2 + 15) + 15 + 15 + 25 + 8, _
                                                                    15, 25)
            GUICtrlSetOnEvent($gui_idButtonEffectIncreaseSpeed, "OnMsg")
        
        $gui_idButtonEffectDecreaseSpeed = GUICtrlCreateButton("-", 50 + 15 + 150 + 15 + 55 + 5 + 15 + 10, _
                                                                    (30 + 15 + 60 + 85 * 2 + 15) + 15 + 15 + 25 + 8, _
                                                                    15, 25)
            GUICtrlSetOnEvent($gui_idButtonEffectDecreaseSpeed, "OnMsg")
        
        $gui_idCheckBoxBassSync = GUICtrlCreateCheckbox("Enable bass sync", 50 + 15 + 150 + 15 + 55 + 5 + 15 + 10 + 15 + 15, _
                                                                            (30 + 15 + 60 + 85 * 2 + 15) + 15 + 15 + 20, _
                                                                            100, 15)
            GUICtrlSetOnEvent($gui_idCheckBoxBassSync, "OnMsg")
            GUICtrlSetState($gui_idCheckBoxBassSync, IsBassSyncEnabled() ? $GUI_CHECKED : $GUI_UNCHECKED)
    GUICtrlCreateGroup("", -99, -99, 1, 1)
    ; ^^^^^^^^^^^^^^^^^^^^^^^^^ Group rgb controls ^^^^^^^^^^^^^^^^^^^^^^^^^

    ; vvvvvvvvvvvvvvvvvvvvvvvvv Group binding vvvvvvvvvvvvvvvvvvvvvvvvv
    $gui_idGroupBinding = GUICtrlCreateGroup("Binding", (50 + 15 + 60 + 85 * 3 + 15) + 15, 30, _
                                                        15 + 100 + 15, _
                                                        15 + 15 + 20 + 8 + 20 + 25 + 25 + 8 + 25 + 15)
        $gui_idLabelCurrentlyBinding = GUICtrlCreateLabel("Binding key 1", (50 + 15 + 60 + 85 * 3 + 15) + 15 + 15, _
                                                                           30 + 15, _
                                                                           100, 15)
            GUICtrlSetOnEvent($gui_idLabelCurrentlyBinding, "OnMsg")
        
        $gui_idLabelBindingArrow = GUICtrlCreateLabel("=>", (50 + 15 + 60 + 85 * 3 + 15) + 15 + 15, _
                                                            30 + 15 + 30, _
                                                            15, 15)
            GUICtrlSetOnEvent($gui_idLabelBindingArrow, "OnMsg")
        
        $gui_idInputKeyUp = GUICtrlCreateInput("{UP up}", (50 + 15 + 60 + 85 * 3 + 15) + 15 + 15 + 10 + 15, _
                                                          30 + 15 + 15, _
                                                          75, 20)
            GUICtrlSetOnEvent($gui_idInputKeyUp, "OnMsg")
        
        $gui_idInputKeyDown = GUICtrlCreateInput("{UP down}", (50 + 15 + 60 + 85 * 3 + 15) + 15 + 15 + 10 + 15, _
                                                              30 + 15 + 15 + 20 + 8, _
                                                              75, 20)
            GUICtrlSetOnEvent($gui_idInputKeyDown, "OnMsg")
        
        $gui_idButtonConfirm = GUICtrlCreateButton("Confirm", (50 + 15 + 60 + 85 * 3 + 15) + 15 + 15, _
                                                              30 + 15 + 15 + 20 + 8 + 20 + 25, _
                                                              100, 25)
            GUICtrlSetOnEvent($gui_idButtonConfirm, "OnMsg")
        
        $gui_idButtonCancel = GUICtrlCreateButton("Cancel", (50 + 15 + 60 + 85 * 3 + 15) + 15 + 15, _
                                                            30 + 15 + 15 + 20 + 8 + 20 + 25 + 25 + 8, _
                                                            100, 25)
            GUICtrlSetOnEvent($gui_idButtonCancel, "OnMsg")
    GUICtrlCreateGroup("", -99, -99, 1, 1)
    ShowBindingGroup(False)
    ; ^^^^^^^^^^^^^^^^^^^^^^^^^ Group binding ^^^^^^^^^^^^^^^^^^^^^^^^^

    ; vvvvvvvvvvvvvvvvvvvvvvvvv Group actions vvvvvvvvvvvvvvvvvvvvvvvvv
    GUICtrlCreateGroup("Actions", 750 - 50 - 15 - 100 - 15, _
                                  0 + 30, _
                                  15 + 100 + 15, _
                                  15 + 15 + 25 * 1 + 15)
        $gui_idRadioBind = GUICtrlCreateRadio("Bind to new keys", 750 - 50 - 15 - 100, 30 + 15, 100, 15)
            GUICtrlSetOnEvent($gui_idRadioBind, "OnMsg")
            GUICtrlSetState($gui_idRadioBind, $GUI_CHECKED)
        
        $gui_idRadioRemove = GUICtrlCreateRadio("Remove binding", 750 - 50 - 15 - 100, 30 + 15 + 15 + 10, 100, 15)
            GUICtrlSetOnEvent($gui_idRadioRemove, "OnMsg")
    GUICtrlCreateGroup("", -99, -99, 1, 1)
    ; ^^^^^^^^^^^^^^^^^^^^^^^^^ Group actions ^^^^^^^^^^^^^^^^^^^^^^^^^

    ; vvvvvvvvvvvvvvvvvvvvvvvvv Group monitoring vvvvvvvvvvvvvvvvvvvvvvvvv
    GUICtrlCreateGroup("Monitoring", 750 - 50 - 15 - 100 - 15, _
                                  (30 + 15 + 15 + 25 * 1 + 15) + 15, _
                                  15 + 100 + 15, _
                                  15 + 15 + 25 * 1 + 15)
        $gui_idRadioMonitorRgb = GUICtrlCreateRadio("RGB effect", 750 - 50 - 15 - 100, _
                                                                  (30 + 15 + 15 + 25 * 1 + 15) + 15 + 15, _
                                                                  100, 15)
            GUICtrlSetOnEvent($gui_idRadioMonitorRgb, "OnMsg")
            GUICtrlSetState($gui_idRadioMonitorRgb, $GUI_CHECKED)
        
        $gui_idRadioMonitorKeypress = GUICtrlCreateRadio("Key press", 750 - 50 - 15 - 100, _
                                                                      (30 + 15 + 15 + 25 * 1 + 15) + 15 + 15 + 15 + 10, _
                                                                      100, 15)
            GUICtrlSetOnEvent($gui_idRadioMonitorKeypress, "OnMsg")
    GUICtrlCreateGroup("", -99, -99, 1, 1)
    ; ^^^^^^^^^^^^^^^^^^^^^^^^^ Group monitoring ^^^^^^^^^^^^^^^^^^^^^^^^^

    $gui_idButtonEnableModifiedKeys = GUICtrlCreateButton("Enable modified keys", 750 - 50 - 15 - 100 - 15, _
                                                          ((30 + 15 + 15 + 25 * 1 + 15) + 15 + 15 + 15 + 25 * 1 + 15) + 15, _
                                                          130, 25)
        GUICtrlSetOnEvent($gui_idButtonEnableModifiedKeys, "OnMsg")

    $gui_idButtonDisableModifiedKeys = GUICtrlCreateButton("Disable modified keys", 750 - 50 - 15 - 100 - 15, _
                                                           ((30 + 15 + 15 + 25 * 1 + 15) + 15 + 15 + 15 + 25 * 1 + 15) + 15 + 25 + 5, _
                                                           130, 25)
        GUICtrlSetOnEvent($gui_idButtonDisableModifiedKeys, "OnMsg")

    $gui_idComboProfile = GUICtrlCreateCombo("", 750 - 25 - 150 + 25, _
                                                     500 - 25 - 25 - 25 - 5 - 25 - 5, _
                                                     100, 25)
        GUICtrlSetOnEvent($gui_idComboProfile, "OnMsg")
    
    $gui_idButtonNewProfile = GUICtrlCreateButton("New profile", 750 - 25 - 150 + 25, _
                                                                 500 - 25 - 25 - 25 - 5, _
                                                                 100, 25)
        GUICtrlSetOnEvent($gui_idButtonNewProfile, "OnMsg")

    $gui_idButtonClose = GUICtrlCreateButton("Close the driver", 750 - 25 - 150, _
                                                                 500 - 25 - 25, _
                                                                 150, 25)
        GUICtrlSetOnEvent($gui_idButtonClose, "Terminate")
        GUICtrlSetColor($gui_idButtonClose, 0xFF0000)
    
    $gui_idLabelConnection = GUICtrlCreateLabel("", 50, 500 - 25 - 15, 500, 15)
        UpdateGui(True)  ; Update the connection label

    ; Reset the states
    $gui_isBindingKeys = False
    $gui_bindingAction = $gui_BIND
    $gui_monitoringType = $gui_MONITORRGB

    ; Get avaliable profiles from the config
    Local $profiles[1] = ["Main"]
    Local $profilesString = ""
    Local $sections = IniReadSectionNames(GetConfigPath())
    For $i = 1 To $sections[0]
        Local $separated = StringSplit($sections[$i], "_", $STR_NOCOUNT)
        If $separated[0] = "Profile" Then
            ; Small check for profiles with more than 1 sections
            For $j = 0 To UBound($profiles) - 1
                If $separated[1] = $profiles[$j] Then ContinueLoop
            Next
            ReDim $profiles[UBound($profiles) + 1]
            $profiles[UBound($profiles) - 1] = $separated[1]
            $profilesString &= $separated[1] & "|"
        EndIf
    Next
    GUICtrlSetData($gui_idComboProfile, "")
    GUICtrlSetData($gui_idComboProfile, $profilesString, KeysGetProfile())
    
    GUISetIcon($iconPath)
    ; Show the gui
    GUISetState(@SW_SHOW)
    
    $gui_timerGuiBtnRgbSync = TimerInit()
EndFunc

Func CloseGui()
    GUIDelete($gui_hGui)
    $gui_isGuiOpened = False
EndFunc

Func IsGuiOpened()
    Return $gui_isGuiOpened
EndFunc

Func EnableGuiTopmost()
    WinSetOnTop($gui_hGui, "", 1)
EndFunc

Func DisableGuiTopmost()
    WinSetOnTop($gui_hGui, "", 0)
EndFunc

Func ArrayFind(ByRef $a, $v)
    For $i = 0 To UBound($a) - 1
        If $a[$i] = $v Then
            Return $i
        EndIf
    Next
    Return -1
EndFunc