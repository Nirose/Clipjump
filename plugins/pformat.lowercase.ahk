;@Plugin-Name LowerCase
;@Plugin-Description Paste Text in Sentence Case
;@Plugin-Author Nirose
;@Plugin-Tags pformat
;@Plugin-version 0.0.1
;@Plugin-Previewable 1

;@Plugin-param1 Text to convert to Lower case

plugin_pformat_lowercase(zin){
	zCS := getClipboardFormat()
	if (zCS== "[" TXT.TIP_text "]")
	{
		zin_copy := zin , STORE.ClipboardChanged := 1
		loop, parse, zin, `.?!`n`r
		{
			zChanged := plugin_pformat_lower(A_LoopField)
			StringReplace, zin_copy, zin_copy, % A_LoopField, % zChanged
		}
		return zin_copy
	}
	else return zin
}

plugin_pformat_lower(zin){
	StringLower, zin, zin
	return zin
}
