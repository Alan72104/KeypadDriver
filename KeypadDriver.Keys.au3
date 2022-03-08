; ================================================================================
;
; KeypadDriver.Keys.au3
; Manages key mapping
;
; ================================================================================

; Todo: Better name for this module

#include-once
#include "Include\LibDebug.au3"
#include "KeypadDriver.Vars.au3"
#include "KeypadDriver.Gui.au3"

; [[keyStrokeUp, keyStrokeDown], ...]
Global $keys_keyMap[$WIDTH * $HEIGHT][$keyStrokeAmount]
Global $keys_currentProfile = "Main"
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

Func SendKey($num, $state)
    ; Only send the key stroke when the gui isn't opened
    If $num <= $WIDTH * $HEIGHT And Not IsGuiOpened() And $keys_keyMap[$num - 1][$state] <> "" Then
        Send($keys_keyMap[$num - 1][$state])
    EndIf
EndFunc

Func KeyHasBinding($num, $state)
    Return GetKeybindingForKey($num, $state) <> "" ? True : False
Endfunc

Func GetKeybindingForKey($num, $state)
    If $num <= $WIDTH * $HEIGHT Then
        Return $keys_keyMap[$num - 1][$state]
    EndIf
EndFunc

; Removes both up and down strokes from a key
Func BindRemove($num)
    $keys_keyMap[$num - 1][$KEYSTROKEUP] = ""
    $keys_keyMap[$num - 1][$KEYSTROKEDOWN] = ""
EndFunc

; Takes 2 arguments and binds a character to both keystrokes of a key,
; or takes 3 arguments and binds special keystrokes to a key
Func BindKey($num, $key, $extra = 0x0)
    If $num > $WIDTH * $HEIGHT Then Return
    Switch @NumParams
        Case 2
            $keys_keyMap[$num - 1][$KEYSTROKEUP] = "{" & $key & " up}"
            $keys_keyMap[$num - 1][$KEYSTROKEDOWN] = "{" & $key & " down}"
        Case 3
            $keys_keyMap[$num - 1][$KEYSTROKEUP] = $key
            $keys_keyMap[$num - 1][$KEYSTROKEDOWN] = $extra
    EndSwitch
EndFunc

Func KeysGetProfile()
    Return $keys_currentProfile
EndFunc

; Sets the current profile, assuming that profile exists in the config
Func KeysSetProfile($path, $profile)
    $keys_currentProfile = $profile
    KeysLoadConfig($path)
EndFunc

; Loads config from a specific profile
Func KeysLoadConfig($path, $profile = $keys_currentProfile)
    For $i = 1 To $WIDTH * $HEIGHT
        BindKey($i, IniRead($path, iv("Profile_$_ButtonBindings", $profile), "Button" & $i & "Up", ""), _
                    IniRead($path, iv("Profile_$_ButtonBindings", $profile), "Button" & $i & "Down", ""))
    Next
EndFunc

; Saves current keymap to a specific profile
Func KeysSaveConfig($path, $profile = $keys_currentProfile)
    For $i = 1 To $WIDTH * $HEIGHT
        IniWrite($path, iv("Profile_$_ButtonBindings", $profile), "Button" & $i & "Up", GetKeybindingForKey($i, $KEYSTROKEUP))
        IniWrite($path, iv("Profile_$_ButtonBindings", $profile), "Button" & $i & "Down", GetKeybindingForKey($i, $KEYSTROKEDOWN))
    Next
EndFunc