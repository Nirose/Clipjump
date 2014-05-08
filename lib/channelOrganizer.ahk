/* *****************
  Channel Organizer
 * *****************
*/

channelOrganizer:
	channelOrganizer()
	return

channelOrganizer(){
	static chOrg_Lb, chOrg_search, chOrg_Lv
	static Width, Height 	; // Needed to make widths and hts save

	wt := ini_read("Organizer", "w") , ht := ini_read("Organizer", "h")
	if !wt
		wt := A_ScreenWidth>1200 ? 800 : 700
	if !ht
		ht := A_ScreenHeight>800 ? 450 : 400
	w_ofSearch := getControlInfo("button", TXT.HST_search, "w", "s10")

	Gui, chOrg:New
	Gui, +Resize +MinSize625x400
	Gui, Color, D2D2D2
	Gui, Font, s10
	Gui, Add, Text, % "x" wt - w_ofSearch - 200 " y10", % TXT.HST_search
	Gui, Font, s9
	Gui, Add, Edit, % "x" wt-200 " yp w200 vchOrg_search gchOrg_search", 		; width of EDIT is fixed = 200
	Gui, Font, s10

	Gui, Add, ListBox, section x5 y+10 w115 h%ht% gchOrg_Lb vchOrg_Lb -LV0X10 AltSubmit, ;% "|" chList 	; width of LB is fixed = 115
	gosub chOrg_addChList

	Gui, Font, s12, Wingdings
	Gui, Add, Button, x+4 yp+20 w30 +Disabled, % chr(231)
	Gui, Add, Button, xp y+20 w30 gchOrgUp, % chr(233) 			; buttons width = 30
	Gui, Add, Button, xp y+2 w30 gchOrgDown, % chr(234)
	Gui, Add, Button, xp y+2 w30 gchorg_openPastemode, % chr(49)
	Gui, Add, Button, xp y+2 w30 gchOrg_props, % chr(50)
	Gui, Add, Button, xp y+2 w30 gchOrgCut, % chr(34)
	Gui, Add, Button, xp y+2 w30 gchOrgCopy, % chr(52)
	Gui, Add, Button, xp y+2 w30 gchOrgDelete, % chr(251)
	; x = 5+115 + 4 + 30 = 154 + 4
	Gui, Font
	Gui, Add, ListView, % "x+4 ys w" wt-158 " h" ht " HWNDchOrg_Lv vchOrg_Lv gchOrg_Lv", % "Ch|#|" TXT.HST_clip
	LV_ModifyCol(1, "30 Integer") , LV_ModifyCol(2, "30 Integer") , LV_ModifyCol(3, wt-158 -60 -10)
	Gui, Add, StatusBar
	SB_SetParts(5+115)
	Gui, chOrg:Show,, % TXT.ORG__name

	GuiControl, chOrg:Choose, chOrg_Lb, % CN.NG+2
	gosub chOrg_Lb
	GuiControl, chOrg:+AltSubmit, chOrg_Lv
	; Gui Done

	; // MENU LV
	Menu, chOrgLVMenu, Add, % TXT.HST_m_prev, chOrg_preview
	Menu, chOrgLVMenu, Add
	Menu, chOrgLVMenu, Add, % TXT.ORG_m_insta, chOrg_paste
	Menu, chOrgLVMenu, Add, % TXT.PLG_properties, chOrg_props
	Menu, chOrgLVMenu, Add, % TXT.ORG_m_openPst, chOrg_openPasteMode
		Menu, chOrgSubM, Add, % TXT.ORG_m_inc , chOrgUp
		Menu, chOrgSubM, Add, % TXT.ORG_m_dec , chOrgDown
		Menu, chOrgSubM, Add, % TXT.TIP_move "    (" TXT["_!x"] ")", chOrgCut
		Menu, chOrgSubM, Add, % TXT.TIP_copy "    (" TXT["_!c"] ")" , chOrgCopy
	Menu, chOrgLVMenu, Add, % TXT._more_options, :chOrgSubM
	Menu, chOrgLVMenu, Add
	Menu, chOrgLVMenu, Add, % TXT.HST_m_del, chOrgDelete
	Menu, chOrgLVMenu, Default, % TXT.HST_m_prev

	; // MENU LB
	Menu, chOrgLBMenu, Add, % TXT.ORG_m_inc, chOrgUp
	Menu, chOrgLBMenu, Add, % TXT.ORG_m_dec, chOrgDown
	Menu, chOrgLBMenu, Add, % TXT._rename " (F2)", chOrg_renameCh
	Menu, chOrgLBMenu, Add, % TXT.HST_m_del, chOrgDelete

	; Hotkeys
	Hotkey, IfWinActive, % TXT.ORG__name " ahk_class AutoHotkeyGUI"
	hkZ("F5", "chOrg_refresh")
	Hotkey, If
	Hotkey, If, IsPasteModeNotActive()
	hkZ("^f", "chOrg_searchfocus")
	Hotkey, If
	Hotkey, If, IsChOrgLVActive()
	hkZ("Enter", "chOrg_preview")
	hkZ("Space", "chOrg_paste")
	hkZ("!Enter", "chOrg_props")
	hkZ("^o", "chOrg_openPasteMode")
	hkZ("Del", "chOrgDelete")
	hkZ("!Up", "chOrgUp")
	hkZ("!Down", "chOrgDown")
	hkZ("!x", "chOrgCut")
	hkZ("!c", "chOrgCopy")
	Hotkey, If
	Hotkey, If, IsChOrgLBActive()
	hkZ("Del", "chOrgDelete")
	hkZ("!Up", "chOrgUp")
	hkZ("!Down", "chOrgDown")
	hkZ("F2", "chOrg_renameCh")
	Hotkey, If
	Hotkey, If, IsPrevActive()
	hkZ("^f", "prevSearchfocus")
	Hotkey, If
	return

chOrg_addChList:
	chList := RegexReplace( Trim( channel_find(), "`n" ), "`n", "|" )
	Sort, chList, D| N
	GuiControl, chOrg:, ListBox1, % "||" chList
	return

chOrgGuiSize:
	if (A_EventInfo != 1){
		Anchor("SysListView321", "wh", "chOrg:")
		Anchor("ListBox1", "h", "chOrg:")
		Anchor("Edit1", "x", "chOrg:")
		Anchor("Static1", "x", "chOrg:")
		Gui, chOrg:Default
		ControlGetPos, , , Width,, SysListView321
		ControlGetPos, , , , Height, ListBox1
		LV_ModifyCol(3, Width -60 -10)
	}
	return

chOrgGuiContextMenu:
	if (A_GuiControl == "chOrg_Lv")
		Menu, chOrgLVMenu, Show, %A_GuiX%, %A_GuiY%
	else if (A_GuiControl == "chOrg_Lb")
		Menu, chOrgLBMenu, Show, %A_GuiX%, %A_GuiY%
	return

chOrgGuiEscape:
chOrgGuiClose:
	Ini_write("Organizer", "w", width+158, 0) , Ini_write("Organizer", "h", height, 0)
	Gui, chOrg:Destroy
	Menu, chOrgLVMenu, DeleteAll
	Menu, chOrgLBMenu, DeleteAll
	Menu, chOrgSubM, DeleteAll
	EmptyMem()
	return

chOrgUp:
chOrgDown: 	; dont make these labels critical
	Gui, chorg:Default
	t_Up := A_ThisLabel="chOrgUp" ? 1 : 0
	gosub chOrg_isChActive
	if !isChActive {
		temp_row_s := LV_GetNext(0) ;0
		;while (temp_row_s := LV_GetNext(temp_row_s)) {
			LV_GetText(fch, temp_row_s, 1) , LV_GetText(fcl, temp_row_s, 2)
			spRow := t_Up ? temp_row_s-1 : temp_row_s+1
			sch := scl := ""
			LV_GetText(sch, spRow, 1) , LV_GetText(scl, spRow, 2)
			if (sch != "") {
				chOrg_clipSwap(fch, fcl, sch, scl)
				LV_GetText(ftxt, temp_row_s, 3) , LV_GetText(stxt, spRow, 3)
				Gui, chOrg:Default
				LV_Modify(temp_row_s, "", fch, fcl, stxt) 		; // change only 3rd col.. 
				LV_Modify(SprOW,"", sch, scl, ftxt)
				LV_Modify(temp_row_s, "-Select -Focus")
				LV_Modify(spRow, "Select")
			}
		;}
	} else {
		gosub chorg_getChSelected
		nCh := chSel + (t_Up ? -1 : 1)
		if chOrg_clipFolderSwap(chSel, nCh)
			gosub chOrg_addChList
	}
	return


chOrgDelete:
	gosub chOrg_isChActive
	if !isChActive {
		gosub chOrg_getSelected
		if Instr(rSel, "`n")
		{
			chOrg_notification(TXT.ORG_error)
			return
		}
		API.deleteClip( ch := Substr(rSel, 1, Instr(rSel, "-")-1) , cl := Substr(rSel, Instr(rSel, "-")+1) )
		chOrg_notification("Selected Clip Deleted")
		LV_Delete(last_Row)
		loop % LV_GetCount()
		{
			LV_GetText(out_ch, A_index, 1)
			if ( out_ch == ch )
			{
				LV_GetText(out_cl, A_index, 2)
				if (out_cl>cl)
					LV_Modify(A_index, "", out_ch, out_cl-1)
			}
		}
	}
	else {
		if (chOrg_Lb != "") && (chOrg_Lb>1) {
			gosub chorg_getChSelected
			MsgBox, 67, % TXT.ORG_delCnlMsgTitle, % TXT.ORG_delCnlMsg
			IfMsgBox, Yes
			{
				manageChannel(chSel)
				gosub chOrg_addChList
			}
			IfMsgBox, No
				API.emptyChannel(chSel)
			IfMsgBox, Cancel
				chOrg_notification( TXT.TIP_cancelled)
			else chOrg_notification("Channel Operation Done")
		}
	}
	return

chOrgCut:
chOrgCopy:
; single cut/ multi copy supported
	gosub chOrg_getSelected
	flag := A_ThisLabel="chOrgCut" ? 0 : 1
	chOrg_notification(flag ? "Copying selected clip(s)" : "Moving selected clip(s)", 99999999)
	if (A_ThisLabel="chOrgCut") && Instr(rSel, "`n")
	{
		chOrg_notification(TXT.ORG_error)
		return
	}
	ret := chooseChannelGui(TXT._destChannel)
	if ret=
	{
		chOrg_notification(TXT.TIP_cancelled)
		return
	}
	Gui, chOrg:Default
	loop, parse, rSel, `n
	{
		API.manageClip(ret, Substr(A_LoopField, 1, Instr(A_LoopField, "-")-1) , Substr(A_LoopField, Instr(A_LoopField, "-")+1) , flag )
		chOrg_notification("In Process")
	}
	chOrg_notification("Done")
	gosub chOrg_refresh
	return

chorg_getChSelected:
	Gui, chorg:Submit, nohide
	chSel := chOrg_Lb-2
	chSelname := ini_read("Channels", chSel)
	return

chOrg_isChActive:
	Gui, chorg:Default
	GuiControlGet, isChActive, chOrg:Enabled, Button4 		; Cut button not enabled when LB is active
	isChActive := !isChActive
	return

chOrg_getSelected:
	Gui, chOrg:Default
	temp_row_s := 0 , rSel := ""
	while ( temp_row_s := LV_GetNext(temp_row_s) )
	{
		LV_GetText(out_ch, temp_row_s, 1) , LV_GetText(out_cl, temp_row_s, 2)
		rSel .= out_ch "-" out_cl "`n"
		last_Row := temp_row_s
	}
	rSel := Trim(rSel, "`n")
	return

chOrg_openPasteMode:
	gosub chOrg_getSelected
	;WinGetPos, x, y,,, % TXT.ORG__name " ahk_class AutoHotkeyGUI"
	API.showPasteTipAt(out_ch, out_cl) ;, x+100, y+160)
	return

chOrg_paste:
	gosub chOrg_getSelected
	gosub chOrgGuiClose
	WinWaitClose, % TXT.ORG__name
	loop, parse, rSel, `n
		API.paste( Substr(A_LoopField, 1, Instr(A_LoopField, "-")-1) , Substr(A_LoopField, Instr(A_LoopField, "-")+1) )
	return

chOrg_props:
	gosub chOrg_getSelected
	out_cl := API.getChStrength(out_ch)-out_cl+1
	ClipPref_makeKeys(out_ch, out_cl)
	SB_SetText(TXT._editing, 2)
	CPS[out_ch][out_cl] := ObjectEditor(CPS[out_ch][out_cl], "Edit Clip properties", "chOrg", "Hit Save when you're done.", 150)
	prefs2Ini()
	chOrg_notification(blank, 10)
	return

chOrg_preview:
	gosub chOrg_getSelected
	out_cl := API.getChStrength(out_ch) - out_cl + 1
	out_ch := out_ch ? out_ch : ""
	if FileExist(clippath := "cache\thumbs" out_ch "\" out_cl ".jpg")
		gui_Clip_preview(clippath, blank, "chOrg")
	else {
		LV_GetText(clipdata, last_Row, 3)
		genHTMLforPreview(clipdata)
		gui_Clip_preview(PREV_FILE, chOrg_search, "chOrg")
	}
	return

chOrg_renameCh:
	gosub chorg_getChSelected
	InputBox, outName, % TXT.ORG__name, % TXT.ORG_renameAsk " -> " chSel,, 500, 200,,,,, % chSelname
	if (ErrorLevel=1) or (outName="")
		return
	renameChannel(chSel, outName)
	gosub chOrg_addChList
	return

chOrg_Lv:
	Gui, chOrg:Default
	GuiControl, , Button1, % chr(232)
	loop 7
		GuiControl, Enable, % "Button"  A_index+1
	if A_GuiEvent = DoubleClick
		gosub chOrg_preview
	return

chOrg_refresh:
chOrg_search:
chOrg_Lb:
	Gui, chOrg:submit, nohide
	GuiControl, , Button1, % chr(231)

	if chOrg_Lb=1
		loop 7 		; in case all channels are selected
			GuiControl, Disable, % "Button"  A_index+1
	else {
		loop 4
			GuiControl, Disable, % "Button"  A_index+3
		loop 2
			GuiControl, Enable,  % "Button"  A_Index+1
		GuiControl, Enable, % "Button8"
	}
	chOrgLV_update(chOrg_search, chOrg_Lb>1 ? chOrg_Lb-2 : "")
	return

}

chOrg_searchfocus:
	GuiControl, chOrg:Focus, Edit1
	return

chOrg_clipFolderSwap(orig_ch, new_ch){
	if (new_ch<0) or ( new_ch >= CN.Total )
		return 0

	origch := orig_ch ? orig_ch : "" , newch := new_ch ? new_ch : ""
	ClipFolderTransfer(newch, newch "_a", 0, "R")
	ClipFolderTransfer(origch, newch, 0, "R")
	ClipFolderTransfer(newch "_a", origch, 0, "R")

	obj_orig := CDS[orig_ch] , obj_new := CDS[new_ch] 	; update cached datas
	CDS[orig_ch] := obj_new , CDS[new_ch] := obj_orig
	obj_orig := CPS[orig_ch] , obj_new := CPS[new_ch] 	; update prefs
	CPS[orig_ch] := obj_new , CPS[new_ch] := obj_orig

	CN["TEMPSAVE" CN.N] := TEMPSAVE , CN["CURSAVE" CN.N] := CURSAVE 	; submit active values
	ts_orig := CN["TEMPSAVE" origch] , cs_orig := CN["CURSAVE" origch] ; update cursave values
	CN["TEMPSAVE" origch] := CN["TEMPSAVE" newch] , CN["CURSAVE" origch] := CN["CURSAVE" newch]
	CN["TEMPSAVE" newch] := ts_orig , CN["CURSAVE" newch] := cs_orig

	orig_name := ini_read("Channels", orig_ch) , Ini_write("Channels", orig_ch, ini_read("Channels", new_ch), 0)
	ini_write("Channels", new_ch, orig_name, 0)

	if ( CN.NG == orig_ch )
		changeChannel(new_ch, 0) 	; 0 for dont save prev values is neccesary
	return 1
}

chOrg_clipSwap(fch, fcl, sch, scl){
	f_sub := (fch?fch:"") , s_sub := (sch?sch:"")
	f_cno := API.getChStrength(fch)-fcl+1 , s_cno := API.getChStrength(sch)-scl+1

	ClipTransfer(s_sub, s_cno, s_sub, s_cno "_a", 0)
	ClipTransfer(f_sub, f_cno, s_sub, s_cno, 0)
	ClipTransfer(s_sub, s_cno "_a", f_sub, f_cno, 0)
	bk := CDS[sch][s_cno] , CDS[sch][s_cno] := CDS[fch][f_cno] , CDS[fch][f_cno] := bk
	bk := CPS[sch][s_cno] , CPS[sch][s_cno] := CPS[fch][f_cno] , CPS[fch][f_cno] := bk
}

chOrg_notification(text, time=800){
	Gui, chOrg:Default
	SB_SetText(text, 2)
	SetTimer, chOrg_notification, % time
}

chOrg_notification:
	SetTimer, chOrg_notification, Off
	Gui, chOrg:Default
	SB_SetText(empty, 2)
	return

IsChOrgLVActive(){
	return IsActive("SysListView321", "classnn") && WinActive(TXT.ORG__name " ahk_class AutoHotkeyGUI") && ctrlRef==""
}
IsChOrgLBActive(){
	return IsActive("ListBox1", "classnn") && WinActive(TXT.ORG__name " ahk_class AutoHotkeyGUI") && ctrlRef==""
}

; // UPDATES the ListView with current search
chOrgLV_update(term="", channel=""){
	Gui, chOrg:Default
	LV_Delete() , term := Trim(term) , ct := 0
	if channel=
	{
		for k,v in CDS
		{
			maxindex := API.getChStrength(k)
			loop % maxindex
				if SuperInstr( (v2 := getRealCD( v[maxIndex-A_index+1] )) " " CPS[k][maxIndex-A_index+1]["Tags"] , term, 1)
					LV_Add("", k, A_index, v2) , ct++
		}
	}
	else {
		maxIndex := API.getChStrength(channel)
		loop % maxIndex
			if SuperInstr( (v := getRealCD( CDS[channel][maxIndex-A_index+1] )) " " CPS[channel][maxIndex-A_index+1]["Tags"] , term, 1)
				LV_Add("", channel, A_index, v) , ct++
	}
	SB_SetText(TXT.ORG_countStatus " - " ct, 1)
}


#If IsChOrgLVActive()
#If
#If IsChOrgLBActive()
#If

; /// EDITED VERSION
Anchor(i, a = "", guiName="") {
; i = ClassNN OR variable
	r := 1 ;redraw
	static c, cs = 12, cx = 255, cl = 0, g, gs = 8, gl = 0, gpi, gw, gh, z = 0, k = 0xffff
	If z = 0
		VarSetCapacity(g, gs * 99, 0), VarSetCapacity(c, cs * cx, 0), z := true

	GuiControlGet, t, %guiName%HWND, %i%
	i := t

	VarSetCapacity(gi, 68, 0), DllCall("GetWindowInfo", "UInt", gp := DllCall("GetParent", "UInt", i), "UInt", &gi)
		, giw := NumGet(gi, 28, "Int") - NumGet(gi, 20, "Int"), gih := NumGet(gi, 32, "Int") - NumGet(gi, 24, "Int")
	If (gp != gpi) {
		gpi := gp
		Loop, %gl%
			If (NumGet(g, cb := gs * (A_Index - 1)) == gp) {
				gw := NumGet(g, cb + 4, "Short"), gh := NumGet(g, cb + 6, "Short"), gf := 1
				Break
			}
		If (!gf)
			NumPut(gp, g, gl), NumPut(gw := giw, g, gl + 4, "Short"), NumPut(gh := gih, g, gl + 6, "Short"), gl += gs
	}
	ControlGetPos, dx, dy, dw, dh, , ahk_id %i%
	Loop, %cl%
		If (NumGet(c, cb := cs * (A_Index - 1)) == i) {
			If a =
			{
				cf = 1
				Break
			}
			giw -= gw, gih -= gh, as := 1, dx := NumGet(c, cb + 4, "Short"), dy := NumGet(c, cb + 6, "Short")
				, cw := dw, dw := NumGet(c, cb + 8, "Short"), ch := dh, dh := NumGet(c, cb + 10, "Short")
			Loop, Parse, a, xywh
				If A_Index > 1
					av := SubStr(a, as, 1), as += 1 + StrLen(A_LoopField)
						, d%av% += (InStr("yh", av) ? gih : giw) * (A_LoopField + 0 ? A_LoopField : 1)
			DllCall("SetWindowPos", "UInt", i, "Int", 0, "Int", dx, "Int", dy
				, "Int", InStr(a, "w") ? dw : cw, "Int", InStr(a, "h") ? dh : ch, "Int", 4)
			If r != 0
				DllCall("RedrawWindow", "UInt", i, "UInt", 0, "UInt", 0, "UInt", 0x0101) ; RDW_UPDATENOW | RDW_INVALIDATE
			Return
		}
	If cf != 1
		cb := cl, cl += cs
	bx := NumGet(gi, 48), by := NumGet(gi, 16, "Int") - NumGet(gi, 8, "Int") - gih - NumGet(gi, 52)
	If cf = 1
		dw -= giw - gw, dh -= gih - gh
	NumPut(i, c, cb), NumPut(dx - bx, c, cb + 4, "Short"), NumPut(dy - by, c, cb + 6, "Short")
		, NumPut(dw, c, cb + 8, "Short"), NumPut(dh, c, cb + 10, "Short")
	Return, true
}