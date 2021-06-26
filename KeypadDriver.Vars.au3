; ================================================================================
;
; KeypadDriver.Vars.au3
; This file declares the variables required to define the keypad specs and all other status
;
; ================================================================================

#include-once

; Size of the keypad
Global Const $WIDTH = 4, $HEIGHT = 3
; Available rgb states on the keypad
Global $rgbStates = ["Rainbow", _
                     "StaticRainbow", _
                     "Splash", _
                     "StaticLight", _
                     "Breathing", _
                     "FractionalDrawingTest2d", _
                     "SpinningRainbow", _
                     "Ripple", _
                     "AntiRipple", _
                     "Stars", _
                     "Raindrop", _
                     "Snake", _
                     "ShootingParticles", _
                     "WhacAMole", _
                     "TicTacToe", _
                     "BullsNCows"]

; Global variables for the connection status
Global Enum $NOTCONNECTED, $CONNECTIONFAILED, $PORTDETECTIONFAILED, $CONNECTED
Global $connectionStatus = $NOTCONNECTED

; Global variables for possible keystroke states
Global Enum $KEYSTROKEUP, $KEYSTROKEDOWN
Global $keyStrokeAmount = 2