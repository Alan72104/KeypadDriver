#RequireAdmin
#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "Include\LibDebug.au3"
#include "Include\DotNetDLLWrapper.au3"

Global Const $WIDTH = 1920 / 2
Global Const $HEIGHT = 500
Global $g_bPaused = False
Global $hGui
Global Const $title = iv("GUI Template (running ""$"")", StringTrimRight(@ScriptName, 4))
GlobaL $hGraphics
Global Const $bgColorARGB = 0xFF000000
Global $frameBuffer
Global $hFrameBuffer
Global $hTimerFrame
Global $smoothedFrameTime
Global Const $frameTimeSmoothingRatio = 0.3
Global $brushWhite
Global $volBrushes[256]
Global $cTimer
Global $rtn
Global $o
Global $brushRed
Global $lvl, $cap = 8
HotKeySet("{F6}", "TogglePause")
HotKeySet("{F7}", "Terminate")

Func Update()
	$rtn = $o.GetFFTArray()
	$lvl = $o.GetBassLevel() * 50
EndFunc

Func Draw()
	If Not UBound($rtn) Then Return
	_GDIPlus_GraphicsClear($hFrameBuffer, $bgColorARGB)
	$count = UBound($rtn) / 2
	For $i = 0 To $count / 2 - 1
		$rtn[$i] *= 25
		_GDIPlus_GraphicsFillRect($hFrameBuffer, $WIDTH / ($count / 2) * $i, $HEIGHT / 1 - $rtn[$i], $WIDTH / ($count / 2), $rtn[$i], $volBrushes[Int(Min($rtn[$i] / 25, $cap) / $cap * 255)])
	Next
	For $i = 0 To $lvl / 2 - 1
		_GDIPlus_GraphicsFillEllipse($hFrameBuffer, $WIDTH / 2 - 40 / 2, 30 - 40 / 2, 40, 40, $brushRed)
	Next
	_GDIPlus_GraphicsDrawStringEx($hFrameBuffer, String(Round($lvl, 3)), _
								  _GDIPlus_FontCreate(_GDIPlus_FontFamilyCreate("Arial"), 30, 0), _
								  _GDIPlus_RectFCreate($WIDTH / 2 + 30, 5, 200, 200), _
								  _GDIPlus_StringFormatCreate(), $brushWhite)
EndFunc

Func FrameBufferTransfer()
	_GDIPlus_GraphicsDrawImage($hGraphics, $frameBuffer, 0, 0)
EndFunc

Func Min($iNum1, $iNum2)
	Return ($iNum1 > $iNum2) ? $iNum2 : $iNum1
EndFunc

Func Max($iNum1, $iNum2)
	Return ($iNum1 > $iNum2) ? $iNum1 : $iNum2
EndFunc

Func Main()
	_DebugOn()
	_GDIPlus_Startup()
	; $hGui = GUICreate($title, $WIDTH, $HEIGHT)
	$hGui = GUICreate($title, $WIDTH, $HEIGHT, Default, Default, Default, $WS_EX_TOPMOST)
    GUISetBkColor($bgColorARGB - 0xFF000000, $hGui)
	$hGraphics = _GDIPlus_GraphicsCreateFromHWND($hGui) 
	$frameBuffer = _GDIPlus_BitmapCreateFromGraphics($WIDTH, $HEIGHT, $hGraphics)
	$hFrameBuffer = _GDIPlus_ImageGetGraphicsContext($frameBuffer)
	$brushWhite = _GDIPlus_BrushCreateSolid(0xFFFFFFFF)
	Local $ar = 0x00
	Local $ag = 0xFF
	Local $ab = 0x00
	Local $br = 0xFF
	Local $bg = 0x3F
	Local $bb = 0x00
	Local $cr = 0xFF
	Local $cg = 0x00
	Local $cb = 0x00
	For $i = 0 To 255
		$volBrushes[$i] = _GDIPlus_BrushCreateSolid(0xFF000000 + (($i < 255 / 2) ? _
								LinearInterpolation($i, 255/2, $ar, $br)*256*256 + LinearInterpolation($i, 255/2, $ag, $bg)*256 + LinearInterpolation($i, 255/2, $ab, $bb) : _
								LinearInterpolation($i - 255/2, 255/2, $br, $cr)*256*256 + LinearInterpolation($i - 255/2, 255/2, $bg, $cg)*256 + LinearInterpolation($i - 255/2, 255/2, $bb, $cb)))
	Next
	$brushRed = _GDIPlus_BrushCreateSolid(0x03FF0000)
	GUISetState(@SW_SHOW)
	
    If Not _DotNet_Load(@ScriptDir & "\Include\dlls\SystemAudioWrapper.dll") Then
        MsgBox($MB_ICONWARNING + $MB_TOPMOST, "KeypadDriver", "Exception catched ""Main()""" & @CRLF & @CRLF & _
                                                              "Loading SystemAudioWrapper.dll failed! error: " & @error & @CRLF & @CRLF & _
                                                              "Terminating!")
        Terminate()
    EndIf
    $o = ObjCreate("SystemAudioWrapper.SystemAudioBassLevel")
    If @error Then
        MsgBox($MB_ICONWARNING + $MB_TOPMOST, "KeypadDriver", "Exception catched ""Main()""" & @CRLF & @CRLF & _
                                                              "Initializing SystemAudioBassLevel failed! error: " & @error & @CRLF & @CRLF & _
                                                              "Terminating!")
        Terminate()
    EndIf
    $o.Start(4096, 2, 4)
	
	While 1
		$hTimerFrame = TimerInit()
		Update()
		Draw()
		FrameBufferTransfer()
		$nTimerFrame = TimerDiff($hTimerFrame)
		$smoothedFrameTime = ($smoothedFrameTime * (1 - $frameTimeSmoothingRatio)) + $nTimerFrame * $frameTimeSmoothingRatio
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				Terminate()
		EndSwitch
	WEnd
EndFunc

Main()

Func LinearInterpolation($i, $j, $a, $b)
	$i /= $j
	Return Int($a * (1 - $i) + $b * $i)
EndFunc

Func GdiPlusClose()
	_GDIPlus_BitmapDispose($frameBuffer)
    _GDIPlus_GraphicsDispose($hGraphics)
	_GDIPlus_BrushDispose($brushWhite)
	_GDIPlus_BrushDispose($brushRed)
	For $ele In $volBrushes
		_GDIPlus_BrushDispose($ele)
	Next
    _GDIPlus_Shutdown()
EndFunc

Func Terminate()
	GdiPlusClose()
    GUIDelete($hGui)
    Exit 0
EndFunc

Func TogglePause()
    $g_bPaused = Not $g_bPaused
    While $g_bPaused
        Sleep(500)
        ToolTip('Script is "Paused"', @DesktopWidth / 2, @DesktopHeight / 2, Default, Default, $TIP_CENTER)
    WEnd
	ToolTip("")
EndFunc