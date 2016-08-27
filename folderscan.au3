
#cs
   This application will scan a set of folders, and remove old files. Keeps "temp" folders tidy.

   Public domain, no rights reserved. It might not work for you, use at your own risk, etc.
#ce

#include <Array.au3>
#include <File.au3>
#include <Date.au3>
#include <WinAPI.au3>

ProcessSetPriority(@AutoItExe,1) ; Set process to below normal priority, so it won't steal too much CPU

Global Const $_SysDate = _Date_Time_SystemTimeToDateStr(_Date_Time_GetSystemTime(),1)
Const $_SysDateTime = @YEAR&@MON&@MDAY&@HOUR&@MIN&@SEC


;init settings from ini
$ini = @ScriptDir & "\settings.ini"
Global Const $_LOGLEVEL = IniRead($ini,"Settings","Log","0")
Global Const $_DeleteLevel = IniRead($ini,"Settings","DeleteLevel","Recycle")
Global Const $_arFolderPaths = IniReadSection($ini,"FolderPaths")
Global Const $_intOutdate = IniRead($ini,"Settings","outdate","15")
Global $hLog

if $_DeleteLevel="Delete" Then
   Global Const $_deleteverb="deleting"
else
   Global Const $_deleteverb="recycling"
EndIf

if $_LOGLEVEL>0 then $hLog = FileOpen("log_"&$_SysDateTime&".txt",10)

if not StringIsInt($_intOutdate) Then
	If $_LOGLEVEL>0 then _FileWriteLog($hLog,"Error: outdate must be an integer. Exiting...")
	Exit
EndIf

; here we go...
for $i = 1 to $_arFolderPaths[0][0]
	$folderpath = $_arFolderPaths[$i][1]
	if StringRight($folderpath,1) <> "\" Then $folderpath = $folderpath & "\"

	;get array of filetree
	$files = _FileListToArrayRec($folderpath, "*", 0,1,1)
	if $files="" and $_LOGLEVEL>0 Then
	  _FileWriteLog($hLog,"Cannot get list of files, skipping to next folder. Error"&@extended&"::"&$folderpath)
	  ContinueLoop
    Elseif $_LOGLEVEL>1 then
	  _FileWriteLog($hLog,"Traversing "& $folderpath)
    EndIf
	_ArrayReverse($files,1) ; reverse array, so it will be ordered as deepest directory first, allowing us to remove empty folders
	if $_LOGLEVEL>1 then _FileWriteLog($hLog,"Got "&$files[0]&" files")

	for $j=1 to $files[0]

		$filepath = $folderpath & $files[$j]

		if StringRight($filepath, 1) = "\" Then ;if this is a folder
			_FileListToArray ($filepath)
			if @error=4 then ; if folder empty, junk it.
			   _DeleteItem($filepath)
			Elseif @error<>0 and $_LOGLEVEL>0 Then
			   _FileWriteLog($hLog,"Error getting folder contents. Error"&@error&"::"&$filepath)
			EndIf

		Else ;if this is a file

			; Get all three file access dates (modified/created/accessed)
			$hFile = _WinAPI_CreateFile($filepath, 2)
			If $hFile=0 and $_LOGLEVEL>0 then
			   _FileWriteLog($hLog,"Error opening file "&_WinAPI_GetLastErrorMessage( )&_WinAPI_GetLastError()&"::"&$filepath)
			Else ; go ahead if file opened OK
			   $arFiledates = _Date_Time_GetFileTime($hFile)
			   _WinAPI_CloseHandle($hFile)

			   $isfileoutdated=0
			   for $k = 0 to 2 ;check file against all three dates
				   $filedate = _Date_Time_FileTimeToStr($arFiledates[$k],1)
				   if $_LOGLEVEL>2 then _FileWriteLog($hLog,"name:"&$filepath&", date:"&$filedate)
				   $datediff = _DateDiff("D",$filedate,$_SysDate)
				   if $datediff > $_intOutdate Then $isfileoutdated = $isfileoutdated + 1
				   if $_LOGLEVEL>2 then _FileWriteLog($hLog,"Datediff "&$datediff)
			   Next
			   ;if file is outdated in all three dates, recycle/delete file
			   If $isfileoutdated = 3 Then
				  _DeleteItem($filepath)
			   EndIf
			EndIf
		EndIf
	Next

Next

if $_LOGLEVEL>0 then FileClose($hLog)
;-----

Func _DeleteItem($filepath)

   if $_DeleteLevel="Delete" then
	  $returncode = FileDelete($filepath)
   Else
	  $returncode = FileRecycle($filepath)
   EndIf

   if $returncode=1 and $_LOGLEVEL>1 then
	  _FileWriteLog($hLog,$_DeleteLevel&"d "& $filepath)
   elseif $_LOGLEVEL>0 then
	  _FileWriteLog($hLog,"Error "&$_deleteverb&" "&$filepath)
   EndIf

EndFunc