' Script name : zuip.vbs
' author : skyte
' A simple vbscript for zipping a folder or unzip a Zip File.
'
' By : http://www.Sec-Articles.net		03/2015
'
' credits :  peter mortensen for zipping function.(http://www.superuser.com/users/517/peter-mortensen)
'
' Usage :-
'
' For Zipping   :  cscript zuip.vbs C [path_to_folder] [path_to_zip_file]
'
' For Unzipping :  cscript zuip.vbs E [path_to_Zip_Archive] [path_to _Extract]
'

Option Explicit

Dim ObjArgs
Set ObjArgs = Wscript.Arguments

IF (ObjArgs.Count <> 3) Then
		Wscript.echo "??.. Something Error in Arguments..!!"
		Wscript.echo "Options : "
		Wscript.echo "For Zipping -"
		Wscript.echo "cscript zuip.vbs C [path_to_folder] [path_to_zip_file] "
		Wscript.echo "For Unzipping -"
		Wscript.echo "cscript zuip.vbs E [path_to_Zip_Archive] [path_to _Extract]"
		Wscript.quit
End IF

Select Case ObjArgs(0)
	Case "C"
		Zipper ObjArgs(1), ObjArgs(2)
	Case "c"
		Zipper ObjArgs(1), ObjArgs(2)
	Case "E"
		Unzipper ObjArgs(1), ObjArgs(2)
	Case "e"
		Unzipper ObjArgs(1), ObjArgs(2)
	Case Else
		Wscript.echo "No Match Found..!!!"
		Wscript.echo "Options : "
		Wscript.echo "For Zipping -"
		Wscript.echo "cscript zuip.vbs C [path_to_folder] [path_to_zip_file] "
		Wscript.echo "For Unzipping -"
		Wscript.echo "cscript zuip.vbs E [path_to_Zip_Archive] [path_to _Extract]"
End Select


'
' Zipping Function
'
Function Zipper(SrcF, DestF)

	Dim fsys
	set fsys = Wscript.CreateObject("Scripting.FileSystemObject")
	
	IF Not (fsys.FolderExists(SrcF)) then
		Wscript.echo " Source Folder Could not found..!! Please Check the path Again."
		Exit Function
	End IF 
	
	IF (fsys.FileExists(DestF)) then
		Wscript.echo " Zip file Already Exists..!! Deleting it..?"
		fsys.DeleteFile DestF
		Wscript.echo " Zip file Deleted SuccessFully."
	End IF 

	' create an empty zip file
	CreateObject("Scripting.FileSystemObject").CreateTextFile(DestF, True).Write "PK" & chr(5) & chr(6) & String(18, 0)
	
	dim objshell, src, des
	
	Set objshell = CreateObject("Shell.Application")
	Set src = objshell.NameSpace(SrcF)
	Set des = objshell.NameSpace(DestF)
	
	des.CopyHere(src.Items)
	
	Do Until des.Items.Count = src.Items.Count
		Wscript.Sleep(200)
	Loop

	Wscript.echo "INFO: File/s has been SuccessFully Zipped...!!!"	
		
	Set fsys = Nothing
	Set objshell = Nothing
	Set src = Nothing
	Set des = Nothing

End Function 


'
' Unzipping Function 
'
Function Unzipper(zipF, extrF)

	Dim fsys
	set fsys = Wscript.CreateObject("Scripting.FileSystemObject")
	
	IF Not (fsys.FileExists(zipF)) Then
		Wscript.echo "Could not Found Zip Archive..!! please Check the Path Again."
		Exit Function
	End IF
	
	IF Not (fsys.FolderExists(extrF)) Then
		Wscript.echo "Could not Found Folder To Extract..!! Creating Folder..."
		fsys.CreateFolder(extrF)
		Wscript.echo "Folder Created SuccessFully."
	End IF
	
	Dim objshell, zip, extr
	
	Set objshell = CreateObject("Shell.Application")
	Set zip = objshell.NameSpace(zipF)
	Set extr = objshell.NameSpace(extrF)
	
	extr.CopyHere(zip.Items)
	
	Do Until extr.Items.Count = zip.Items.Count
		Wscript.Sleep(200)
	Loop
	
	Wscript.echo "SuccessFully Extracted.!!"
	
	Set fsys = Nothing
	Set objshell = Nothing
	Set zip = Nothing
	Set extr = Nothing
	
End Function