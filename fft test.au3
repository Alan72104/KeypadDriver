#RequireAdmin
#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "Include\LibDebug.au3"
#include "Include\DotNetDLLWrapper.au3"

Global Const $WIDTH = 1920 * 1.25
Global Const $HEIGHT = 300
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
Global $cTimer
Global $rtn
Global $o
Global $brushRed
Global $lvl
HotKeySet("{F6}", "TogglePause")
HotKeySet("{F7}", "Terminate")

Func Update()
	$rtn = $o.GetFFTArray()
	$lvl = $o.GetBassLevel() * 50
EndFunc

Func Draw()
	_GDIPlus_GraphicsClear($hFrameBuffer, $bgColorARGB)
	$tt = TimerInit()
	$count = UBound($rtn)
	For $i = 0 To $count - 1
		$rtn[$i] *= 25
		_GDIPlus_GraphicsFillRect($hFrameBuffer, $WIDTH / $count * $i, $HEIGHT / 1 - $rtn[$i], $WIDTH / $count, $rtn[$i], $brushWhite)
	Next
	For $i = 0 To $lvl - 1
		_GDIPlus_GraphicsFillEllipse($hFrameBuffer, $WIDTH / 2 - 30 / 2, 25 - 30 / 2, 30, 30, $brushRed)
	Next
	_GDIPlus_GraphicsDrawStringEx($hFrameBuffer, String(Round($lvl, 3)), _
								  _GDIPlus_FontCreate(_GDIPlus_FontFamilyCreate("Arial"), 30, 0), _
								  _GDIPlus_RectFCreate($WIDTH / 2 + 25, 5, 200, 200), _
								  _GDIPlus_StringFormatCreate(), $brushWhite)
EndFunc

Func FrameBufferTransfer()
	_GDIPlus_GraphicsDrawImage($hGraphics, $frameBuffer, 0, 0)
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
	$brushRed = _GDIPlus_BrushCreateSolid(0x03FF0000)
	GUISetState(@SW_SHOW)
	
    If Not _DotNet_Load(@ScriptDir & "\SystemAudioWrapper\bin\Release\SystemAudioWrapper.dll") Then
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

Func GdiPlusClose()
	_GDIPlus_BitmapDispose($frameBuffer)
    _GDIPlus_GraphicsDispose($hGraphics)
	_GDIPlus_BrushDispose($brushWhite)
	_GDIPlus_BrushDispose($brushRed)
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
        ToolTip('Script is "Paused"', @desktopWIDTH / 2, @desktopHEIGHT / 2, Default, Default, $TIP_CENTER)
    WEnd
	ToolTip("")
EndFunc