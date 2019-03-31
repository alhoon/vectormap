;----------------------------------------------------------------------;
; This script converts NLS Topographic Database packets shared via     ;
; their open data platform into D3.js compatible Javascript injection, ;
; usable by the web-based Vector Map application.                      ;
;----------------------------------------------------------------------;

KeyWait, Control, D

; Variables
loopVar := "temp"
i := 0
Classifications := []

; Delete previous folders and their contents
FileRemoveDir, L4132L, 1
FileRemoveDir, %A_WorkingDir%\..\Site\js, 1

; Creating necessary folders
FileCreateDir, L4132L\data\output
FileCreateDir, %A_WorkingDir%\..\Site\js


ConvertSHAPEtoJson()

; Main loop for reading the Excel, repeated until
; Excel A-row value is null
while(loopVar != "")
{
	; Save return values as objects into an array
	Classifications[i] := ExportFromExcel() 
	Sleep 50
	Send ^c
	ClipWait
	loopVar := RegExReplace(clipboard, "\R")
	i += 1
}

ExtractDataFromJson(Classifications)

ConvertJsonToSvg()

GenerateJs(Classifications)


; Converts ESRI Shapefile into GeoJson via mapshaper tool
ConvertSHAPEtoJson()
{
	RunWait, ms.bat
	RunWait, del.bat
	return
}

; Main function for reading Excel
; Reads every relevant line and saves them in an object,
; returning this object.
ExportFromExcel()
{
	exportedJsonMid := "L4132L"
	
	clipboard =  
	Send ^c
	ClipWait
	exportedName := RegExReplace(clipboard, "\R")
	Sleep 50
	
	clipboard =  
	SendInput {Right}
	Sleep 50
	Send ^c
	ClipWait
	exportedId := RegExReplace(clipboard, "\R")
	Sleep 50
	
	clipboard =  
	SendInput {Right}
	Sleep 50
	Send ^c
	ClipWait
	exportedJsonEnd := RegExReplace(clipboard, "\R")
	Sleep 50
	
	clipboard = 
	SendInput {Right}
	Sleep 50
	Send ^c
	ClipWait
	exportedColor := RegExReplace(clipboard, "\R")
	Sleep 50
	
	clipboard = 
	Sleep 50
	SendInput {Right}
	Sleep 50
	SendInput {Right}
	Sleep 50
	Send ^c
	ClipWait
	exportedThickness := RegExReplace(clipboard, "\R")
	Sleep 50
	
	clipboard = 
	SendInput {Right}
	Sleep 50
	Send ^c
	ClipWait
	exportedJsonStart := RegExReplace(clipboard, "\R")
	Sleep 50
	
	clipboard = 
	SendInput {Right}
	Sleep 50
	Send ^c
	ClipWait
	exportedGroup := RegExReplace(clipboard, "\R")
	Sleep 50
	
	clipboard = 
	SendInput {Right}
	Sleep 50
	Send ^c
	ClipWait
	exportedClass := RegExReplace(clipboard, "\R")
	Sleep 50
	
	clipboard = 
	SendInput {Right}
	Sleep 50
	Send ^c
	ClipWait
	exportedRenderStyle := RegExReplace(clipboard, "\R")
	Sleep 50
	
	clipboard = 
	SendInput {Right}
	Sleep 50
	Send ^c
	ClipWait
	exportedMultiFile := RegExReplace(clipboard, "\R")
	Sleep 50
	
	SendInput {Down}
	SendInput {Home}
	
	Out := {name: exportedName, id: exportedId, jsonStart: exportedJsonStart, jsonMid: exportedJsonMid, jsonEnd: exportedJsonEnd, thickness: exportedThickness, group: exportedGroup, class: exportedClass, colorHex: exportedColor, renderStyle: exportedRenderStyle, multiFile: exportedMultiFile}
	return Out
}

; Exracts path data and structures it
; according to NLS metadata in GeoJson files.
ExtractDataFromJson(Classifications)
{
	for k, v in Classifications
	{
		; GeoJson file start definitions
		buffer := "{""type"":""FeatureCollection""`, ""features"": [`n"
		buffer .= "{""type"":""Feature"",""geometry"":{""type"":""Polygon"",""coordinates"":"
		
		; Create a box along the borders of the map tile
		; This is required when converting to SVG later on,
		; because SVG does not use geographic coordinates.
		buffer .= "[[[356000,6678000],[356000,6690000],[368000,6690000],[368000,6678000],[356000,6678000]]]}},`n"

		; Path and file name for a file in question
		inputJson := "L4132L\data\" . v.jsonStart . "_" . v.jsonMid . "_" . v.jsonEnd . ".json"

		; Main loop, which reads the file in question line by line
		Loop, read, %inputJson%
		{
			Loop, parse, A_LoopReadLine, %A_Tab%
			{
				; If RYHMÄ and LUOKKA match...
				If InStr(A_LoopField, """RYHMA"":" . v.group) and InStr(A_LoopField, """LUOKKA"":" . v.class)
				{
					; ... and multiFile definition equals null, save a line in buffer
					if (v.multiFile = null)
					{
						buffer .= A_LoopField . "`n"
					}
					
					; If multiFile definition is not null,
					; lines need to be handled separately.
					; These are the lines where RYHMÄ and LUOKKA
					; alone are not enough to define the rendering style.
					else if (v.multiFile = 1)
					{
						If InStr(A_LoopField, """KARTOGLK"":36200") or InStr(A_LoopField, """KARTOGLK"":36211") or InStr(A_LoopField, """KARTOGLK"":36313")
						{
							buffer .= A_LoopField . "`n"
						}
					}
					else if (v.multiFile = 2)
					{
						If InStr(A_LoopField, """KARTOGLK"":32421") or InStr(A_LoopField, """KARTOGLK"":32500") or InStr(A_LoopField, """KARTOGLK"":32611") or InStr(A_LoopField, """KARTOGLK"":32800") or InStr(A_LoopField, """KARTOGLK"":33000") or InStr(A_LoopField, """KARTOGLK"":33100") or InStr(A_LoopField, """KARTOGLK"":38900")
						{
							buffer .= A_LoopField . "`n"
						}
					}
					else if (v.multiFile >= 3) and (v.multiFile <= 7)
					{
						pos1 := InStr(A_LoopField, """KORARV"":") + 9
						pos2 := InStr(A_LoopField, ",""KULKUTAPA"":")
						
						If (v.multiFile = 3) and (v.class = 52100) and (Mod(SubStr(A_LoopField, pos1, pos2 - pos1),2.5) = 0) and (Mod(SubStr(A_LoopField, pos1, pos2 - pos1),5) != 0) and (Mod(SubStr(A_LoopField, pos1, pos2 - pos1),20) != 0)
						{
							buffer .= A_LoopField . "`n"
						}
						else if (v.multiFile = 4) and (v.class = 52100) and (Mod(SubStr(A_LoopField, pos1, pos2 - pos1),5) = 0) and (Mod(SubStr(A_LoopField, pos1, pos2 - pos1),20) != 0)
						{
							buffer .= A_LoopField . "`n"
						}
						else if (v.multiFile = 5) and (v.class = 52100) and (Mod(SubStr(A_LoopField, pos1, pos2 - pos1),20) = 0)
						{
							buffer .= A_LoopField . "`n"
						}
						else if (v.multiFile = 6) and (v.class = 54100) and (Mod(SubStr(A_LoopField, pos1, pos2 - pos1),1.5) = 0) (Mod(SubStr(A_LoopField, pos1, pos2 - pos1),3) != 0)
						{
							buffer .= A_LoopField . "`n"
						}
						else if (v.multiFile = 7) and (v.class = 54100) and (Mod(SubStr(A_LoopField, pos1, pos2 - pos1),3) = 0)
						{
							buffer .= A_LoopField . "`n"
						}
					}
				}
			}
		}
	
		; In GeoJson the lines containing path elements are
		; separated by a comma, except for the last line.
		; Remove the comma from the last line if one exists.
		if(SubStr(buffer, 0, 1) = ",")
			buffer := SubStr(buffer, 1, -2)
		
		; GeoJson end of file definition
		buffer .= "`n]}"
		
		; Test buffer length, if under 200 characters
		; (meaning it has no data except the predefined lines),
		; the buffer is discarded.
		; This happens when the map tile does not have any features of desired type.
		; Otherwise write buffer to a new GeoJson file.
		if (strLen(buffer) > 199) and ((v.jsonEnd = "p") or (v.jsonEnd = "v"))
		{
			group := v.group
			class := v.class
			multiFile := v.multiFile
			
			if (v.multiFile = null)
				FileAppend, %buffer%, L4132L\data\output\%group%_%class%.json
			else
				FileAppend, %buffer%, L4132L\data\output\%group%_%class%_%multiFile%.json
		}
	}
	return
}

; Converts GeoJson into SVG via mapshaper tool
ConvertJsonToSvg()
{
	RunWait, ms2.bat
	return
}

; Generates JavaScript files that inject the SVG data into HTML DOM
GenerateJs(Classifications)
{
	for k, v in Classifications
	{
		identifier := v.group . "_" . v.class
		mf_identifier := identifier . "_" . v.multiFile

		if (v.multiFile = null)
			FileRead, contents, L4132L\data\output\%identifier%.svg
		else
			FileRead, contents, L4132L\data\output\%mf_identifier%.svg

		; Check if the variable is null.
		; Null variable here means the corresponding SVG file does not exist
		if (contents != null)
		{
			; Handle data files containing polygons
			if (v.jsonEnd = "p")
			{
				; Create a comment line that includes the name of the feature
				outputP .= "`r`n`r`n//" . v.name . "`r`n"
				
				; Create JavaScript variable that defines the rendering properties
				outputP .= "var c_" . identifier . " = container.append(""g"").attr(""id"",""" . v.id . """).on(""click"",""doClick(this)"")"
				
				; Define the rendering properties based on Excel definitions
				if (v.renderStyle = "fill")
					outputP .= ".attr(""fill"",""#" . v.colorHex . """);`r`n`r`n"
				else if (v.renderStyle = "l_fill")
					outputP .= ".attr(""style"",""fill:url(#s_" . identifier . ")"");`r`n`r`n"
				else if (v.renderStyle = "s_fill")
					outputP .= ".attr(""fill"",""#" . v.colorHex . """);`r`n`r`n"
				else if (v.renderStyle = "b_fill")
					outputP .= ".attr(""fill"",""#" . v.colorHex . """).attr(""stroke"",""#000000"").attr(""stroke-width"",""0.08"");`r`n`r`n"
				else if (v.renderStyle = "custom")
				{
					if (v.class = 40200)
						outputP .= ".attr(""fill"",""#" . v.colorHex . """);`r`n`r`n"
					else
						outputP .= ".attr(""fill"",""#" . v.colorHex . """);`r`n`r`n"
				}
					
				; Loop that parses the file per row
				Loop, Parse, contents, `n, `r
				{
					; Skip to the part of the file where the data starts
					If (A_Index > 4)
					{
						; Bypass SVG specific definitions and only read part that contain the coordinates
						path_coords := SubStr(A_LoopField, 10)
						path_coords := SubStr(path_coords, 1, -2)
						
						; If the line is not empty, create an SVG injection with the coordinates
						if (path_coords != null)
							outputP .= "c_" . identifier . ".append(""path"").attr(""d"",""" . path_coords . ")`r`n"
					}
				}
			}
			
			; Handle data files containing vectors
			; Refer to the comments on the "if" sentence above
			else if (v.jsonEnd = "v")
			{
				outputV .= "`r`n`r`n//" . v.name . "`r`n"
				
				outputV .= "var c_" . identifier . " = container.append(""g"").attr(""id"",""" . v.id . """).on(""click"",""doClick(this)"")"
				
				if (v.renderStyle = "seg_line")
					outputV .= ".attr(""fill"",""blue"").attr(""fill-opacity"",""0"").attr(""stroke"",""#" . v.colorHex . """).attr(""stroke-width"",""" . v.thickness/8 . """).attr(""stroke-dasharray"",""1,1"");`r`n`r`n"
				else
					outputV .= ".attr(""fill"",""blue"").attr(""fill-opacity"",""0"").attr(""stroke"",""#" . v.colorHex . """).attr(""stroke-width"",""" . v.thickness/8 . """);`r`n`r`n"
					
				Loop, Parse, contents, `n, `r
				{
					If (A_Index > 7)
					{
						path_coords := SubStr(A_LoopField, 10)
						path_coords := SubStr(path_coords, 1, -2)
						
						if (path_coords != null)
							outputV .= "c_" . identifier . ".append(""path"").attr(""d"",""" . path_coords . ")`r`n"
					}
				}
			}
		}
	}
	
	jsonMid := Classifications[0].jsonMid
	
	; Write a Javascript file
	FileAppend %outputP%, %A_WorkingDir%\..\Site\js\svgPData_%jsonMid%.js
	FileAppend %outputV%, %A_WorkingDir%\..\Site\js\svgVData_%jsonMid%.js
	return
}