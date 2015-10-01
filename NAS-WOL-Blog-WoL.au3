; Nas-Wol Script mit Gui von splix´
;PLINK.exe muss im Verzeichniss C:\Putty\ liegen, unten anpassbar

#Region ### MAC Addr. ###
Global $Mac = "00:00:00:00:00:00" ; MAC des Servers
#EndRegion ### MAC Addr. ###

#Region ### Includes ###
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Constants.au3>
#EndRegion ### Includes ###

#Region ### Funcs ###
Func _MagicPacket($sMac)
    ;Author: Prog@ndy, nicht meine eigene Arbeit!
    If Not IsBinary($sMac) Then $sMac = Binary('0x' & StringRegExpReplace($sMac,'(0x)|[^A-Za-z0-9]', ''))
    Local $binPacket = Binary('0xFFFFFFFFFFFF')
    For $i = 1 To 16
        $binPacket &= $sMac
    Next
    Return $binPacket
EndFunc
#EndRegion ### Funcs ###

#Region ### UDP ###
UDPStartup() ; UDP für WoL
$Broadcast = UDPOpen("255.255.255.255", 9, 1)
#EndRegion ### UDP ###

#Region ### GUI section ###
$Form1_1 = GUICreate("NAS-WOL by splix", 297, 79, 688, 417) ;GUI Titel
$Button1 = GUICtrlCreateButton("Start", 11, 41, 85, 28, $WS_GROUP) ;Knöpfe
$Button2 = GUICtrlCreateButton("Reboot", 104, 41, 85, 28, $WS_GROUP)
$Button3 = GUICtrlCreateButton("PowerOff", 201, 42, 85, 28, $WS_GROUP)
;Gui Online Status
$Label1 = GUICtrlCreateLabel("NAS-Server is:", 11, 10, 92, 20)
GUICtrlSetFont(-1, 10, 400, 0, "MS Sans Serif")
$Label2 = GUICtrlCreateLabel("Online", 110, 10, 42, 20)
GUICtrlSetFont(-1, 10, 400, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0x008000)
GUISetState(@SW_SHOW)
#EndRegion ### Gui section ###

While 1
	$i = 0
	$i = $i + 1
	If $i > 20 Then ;nur bei allen 20 mal den Server pingen, sonst wird es zu viel ;)
		$ping = Ping("nasaamm.int", 250)
		if $ping Then ;antwort true
			GUICtrlSetData($Label2, "Online")
			GUICtrlSetColor($Label2, 0x008000)
		Else ;antowort nicht true, daher nicht erreichbahr
			GUICtrlSetData($Label2, "Offline")
			GUICtrlSetColor($Label2, 0x800000)
		EndIf
	Else
		$nMsg = GUIGetMsg() ;abfangen des Drücken Events
		Select
			Case $nMsg = $GUI_EVENT_CLOSE ;X wird gedrückt
				UDPCloseSocket($Broadcast)
				UDPShutdown()
				Exit
			Case $nMsg = $Button1 ;Start
				UDPSend($Broadcast, _MagicPacket($Mac))
			Case $nMsg = $Button2 ;Reboot
				Run("C:\Putty\plink -ssh -P 22 -pw passwort admin@0.0.0.0 reboot")
			Case $nMsg = $Button3 ;PowerOff
				Run("C:\Putty\plink -ssh -P 22 -pw passwort admin@0.0.0.0 poweroff")
		EndSelect
	EndIf
WEnd
