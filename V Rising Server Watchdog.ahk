;*******************************************************************************************
;****************** THE CONTENTS OF THIS FILE WERE CREATED BY KORNSTALX ********************
;****************************** v0.59 Last Update: 06/23/22 ********************************
;*******************************************************************************************

#SingleInstance, Force											;Prevent duplicate copies of script
#InstallKeybdHook												;Necessary for AFK/Logout detection
SetKeyDelay, 0, 1												;Changing this will break everything
;SendMode, Input
SetDefaultMouseSpeed, 0 
SetScrollLockState, OFF											;Used for weapon-swap override visual indicator
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

;*******************************************************************************************
;********************************   --- User Config --->   *********************************
;*******************************************************************************************

LaunchMin := 1530												;Earliest random time login (4-digit 24h format)
LaunchMax := 1600												;Latest random time login (4-digit 24h format)
SiegeStart := 1600												;Your server's siege time (4-digit 24h format)
SiegeHours := 6													;Your server's siege length (1-digit hours)

;*******************************************************************************************
;**********************************   --- Startup --->   ***********************************
;*******************************************************************************************

SiegeEnd := SiegeStart + (SiegeHours * 100)
If SiegeEnd > 2400
  SiegeEnd := SiegeEnd - 2400
Random, RandLaunch, LaunchMin, LaunchMax
If RandLaunch > 2400
  RandLaunch := RandLaunch - 2400
;RandLaunch := Format("{:04}", RandLaunch)									
SetTimer, VRing, 5000
SetTimer, CombatCheck
Return

Capslock::Home													;CapsLock sends "Home" key for Push-to-Talk

;*******************************************************************************************
;***************************  --- Keybindings (Game Only) --->   ***************************
;*******************************************************************************************

#IfWinActive, VRising ahk_class UnityWndClass ahk_exe VRising.exe
LWin::															;LWin toggles the weapon-swap override on/off
  nMasterOverride := !nMasterOverride
  If nMasterOverride
  {
    SetScrollLockState, ON
    SoundPlay, %A_WinDir%\Media\Speech Off.wav	
  }
  Else
  {
    SetScrollLockState, OFF
    SoundPlay, %A_WinDir%\Media\Speech On.wav	
  }
  Return
^LWin::															;Ctrl+LWin holds Left Click for door bashing
  Send, {LButton DOWN}
  Return  
$WheelUp::														;Do not modify (see Subroutines below)
  Send, {Blind}{WheelDown} 
  If !nBusy
  {
    nBusy = 1
    SetTimer, WheelUpRoutine, -1
  }
  Return
$WheelDown::													;Do not modify (see Subroutines below)
;  Send, {Blind}{WheelUp}		
  If !nBusy
  {
    nBusy = 1
    SetTimer, WheelDownRoutine, -1
  }
  Return
$+WheelUp::														;Do not modify (see Subroutines below)
  Send, {Blind}{WheelDown}
  If !nBusy
  {
    nBusy = 1
    SetTimer, WheelUpRoutineShift, -1
  }	
  Return
$+WheelDown::													;Do not modify (see Subroutines below)
;  Send, {Blind}{WheelUp} 
  If !nBusy
  {
    nBusy = 1
    SetTimer, WheelDownRoutineShift, -1
  }
  Return
$Tab::															;Map is no longer a toggle; hold it down
  Send, {Tab}
  HotKey, $WheelUp, OFF
  HotKey, $WheelDown, OFF
  KeyWait, Tab
  Send, {Tab}
  HotKey, $WheelUp, ON
  HotKey, $WheelDown, ON
  Return
XButton1::														;Thumb "Back" function
  If nCombat && !nMasterOverride								
    Send, {NumPad1}
  Send, {F3 DOWN}
  KeyWait, XButton1
  Send, {F3 UP}
  Return
XButton2::														;Thumb "Forward" function
  If nCombat && !nMasterOverride								
    Send, {NumPad1}
  Send, {F4 DOWN}
  KeyWait, XButton2
  Send, {F4 UP}
  Return
~Space::														;Hold Space in map/menus to Wheel scroll/zoom
  If nCombat && !nMasterOverride
    Send, {NumPad1}
  Else 
  {  
    HotKey, $WheelUp, OFF
    HotKey, $WheelDown, OFF	
    KeyWait, Space
    HotKey, $WheelUp, ON
    HotKey, $WheelDown, ON	  
  }	
  Return  
MButton::x														;Wheel Click picks up or activates items
+MButton::F5  													;Shift + Wheel Click activates Ultimate
LButton::														;Left Click always uses Hotbar #1 for attacks
  While GetKeyState("LButton", "P")
  {
    If (nCombat && !nMasterOverride)
	  Send, {NumPad1}
    Send, {LButton DOWN}	
  }
  KeyWait, LButton
  Send, {LButton UP}  
  Return
  
;*******************************************************************************************
;********************************  --- Subroutines --->   **********************************
;*******************************************************************************************
  
WheelUpRoutine:													;Wheel Up function
  If !nMasterOverride
  {
    Send, {NumPad2}
    Sleep 300
  }	
  Send, {F1}
  nBusy = 0
  Return
WheelDownRoutine:												;Wheel Down function
  If !nMasterOverride
  {
    Send, {NumPad2}
    Sleep 300
  }	
  Send, {F2}
  nBusy = 0
  Return
WheelUpRoutineShift:											;Shift + Wheel Up function
  If !nMasterOverride
  {
    Send, {NumPad3}
    Sleep 300
    Send, {F1}
	Send, {NumPad1}
  }	
  Else
    Send, {F1}
  nBusy = 0  
  Return
WheelDownRoutineShift:											;Shift + Wheel Down function
  If !nMasterOverride
  {
    Send, {NumPad3}
    Sleep 300
    Send, {F2}
	Send, {NumPad1}
  }	
  Else
    Send, {F2} 
  nBusy = 0
  Return
  
;*******************************************************************************************
;****************************   --- Watchdog and Timers --->   *****************************
;*******************************************************************************************  

CombatCheck:													;Determines when you are in combat
  IfWinActive, VRising ahk_class UnityWndClass ahk_exe VRising.exe
  {
    ImageSearch, X, Y, 1524, 1210, 2024, 1274, *100 combat.jpg	; <-Raw coords for 1440p only!
    If !ErrorLevel												 
    {															
;      If !nCombat												;Uncomment to enable combat chimes	
;        SoundPlay, %A_WinDir%\Media\Speech Off.wav			  	;Uncomment to enable combat chimes
      nCombat = 1												
    }															
    Else														
    {															
;      If nCombat												;Uncomment to enable combat chimes
;	    SoundPlay, %A_WinDir%\Media\Speech On.wav				;Uncomment to enable combat chimes
      nCombat = 0												
    }															
  }																
  Return  
VRing:															;Watchdog for Siege Window auto-login
  FormatTime, CurrTime,, HHmm
  HWND := WinExist("ahk_exe VRising.exe")
  If (CurrTime >= RandLaunch) && (CurrTime <= SiegeEnd) && !HWND						  
  {
;	SoundSet, Mute												;Comment out to disable volume mute
    Run, "steam://rungameid/1604030"
	WinWait, ahk_exe VRising.exe
;    WinActivate, ahk_exe VRising.exe
;    WinWaitActive, ahk_exe VRising.exe
;    BlockInput, ON
    MouseMove, 0, 0
    ControlClick, x00 y00, ahk_exe VRising.exe,,,, D
;    Send, {LButton DOWN}
    Sleep 15000
    ControlClick, x00 y00, ahk_exe VRising.exe,,,, U	
;    Send, {LButton UP}
    MouseMove, 400, 600											;Always uses the TOP server in history
    ControlClick, x400 y600, ahk_exe VRising.exe	
;    Click
    Sleep 5000
    MouseMove, 1000, 250
    ControlClick, x1000 y250, ahk_exe VRising.exe
;    Click
    Sleep 5000 
    MouseMove, 2250, 1350
    ControlClick, x2250 y1350, ahk_exe VRising.exe
;    Click
    Sleep 10000
    ControlClick, x00 y00, ahk_exe VRising.exe
;    Click
    Sleep 10000
	ControlSend, {Space}, ahk_exe VRising.exe
;    Send, {Space} 
;    BlockInput, OFF	
   }
   Return   