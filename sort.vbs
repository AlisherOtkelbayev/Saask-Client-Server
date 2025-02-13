Option Explicit

Dim objFSO, objArgs
Dim sourceFolder, targetFolder
Dim fileCount, folderCount
Dim movedFilesDict

Set objArgs = WScript.Arguments
If objArgs.Count < 2 Then
    WScript.Echo "USAGE: cscript sort.vbs <sourceFolder> <targetFolder>"
    WScript.Quit 1
End If

sourceFolder = objArgs(0)
targetFolder = objArgs(1)

Set objFSO = CreateObject("Scripting.FileSystemObject")

If Not objFSO.FolderExists(sourceFolder) Then
    WScript.Echo "Source folder does not exist: " & sourceFolder
    WScript.Quit 1
End If

If Not objFSO.FolderExists(targetFolder) Then
    objFSO.CreateFolder targetFolder
End If

fileCount = 0
folderCount = 0

Set movedFilesDict = CreateObject("Scripting.Dictionary")
movedFilesDict.CompareMode = vbTextCompare

RecurseFolder sourceFolder

WScript.Echo fileCount & " picture" & PluralS(fileCount) & " sorted into " & folderCount & " folder" & PluralS(folderCount) & "."

Dim key
Dim i, arr
For Each key In movedFilesDict.Keys
    arr = Split(key, "|")
    Dim fullPath, countOfFiles, subFiles, sPlural, wasPlural
    fullPath = arr(0)
    countOfFiles = CInt(arr(1))
    Set subFiles = movedFilesDict(key)
    sPlural = PluralS(countOfFiles)
    wasPlural = PluralWas(countOfFiles)
    WScript.Echo "--------"
    WScript.Echo countOfFiles & " file" & sPlural
    If countOfFiles = 1 Then
        WScript.Echo subFiles(0)
    Else
        Dim joinedFiles
        joinedFiles = Join(subFiles, ", ")
        WScript.Echo joinedFiles
    End If
    WScript.Echo wasPlural & " moved to folder"
    WScript.Echo fullPath
Next

Sub RecurseFolder(folderPath)
    Dim folder, file, subfolder
    Set folder = objFSO.GetFolder(folderPath)
    For Each file In folder.Files
        If IsJpeg(file) Then
            MoveJpeg file
        End If
    Next
    For Each subfolder In folder.SubFolders
        RecurseFolder subfolder.Path
    Next
End Sub

Function IsJpeg(fileObj)
    Dim ext
    ext = LCase(objFSO.GetExtensionName(fileObj.Name))
    If ext = "jpg" Or ext = "jpeg" Then
        IsJpeg = True
    Else
        IsJpeg = False
    End If
End Function

Sub MoveJpeg(fileObj)
    Dim dt, yearPart, monthPart, dayPart
    Dim folderName, finalFolder, key
    dt = fileObj.DateLastModified
    yearPart = Year(dt)
    monthPart = Right("0" & Month(dt), 2)
    dayPart = Right("0" & Day(dt), 2)
    folderName = yearPart & "\" & yearPart & "-" & monthPart & "-" & dayPart
    finalFolder = targetFolder & "\" & folderName
    CreateFolderIfNotExist targetFolder & "\" & yearPart
    CreateFolderIfNotExist finalFolder
    Dim newPath
    newPath = finalFolder & "\" & fileObj.Name
    On Error Resume Next
    fileObj.Move newPath
    If Err.Number <> 0 Then
        On Error GoTo 0
    Else
        On Error GoTo 0
        fileCount = fileCount + 1
        key = finalFolder & "|" & GetFolderCount(finalFolder)
        If Not movedFilesDict.Exists(key) Then
            Dim tempList
            Set tempList = CreateObject("System.Collections.ArrayList")
            movedFilesDict.Add key, tempList
            folderCount = folderCount + 1
        End If
        Dim filesList
        Set filesList = movedFilesDict(key)
        filesList.Add fileObj.Name
        movedFilesDict.Remove key
        key = finalFolder & "|" & (CInt(Split(key, "|")(1)) + 1)
        movedFilesDict.Add key, filesList
    End If
End Sub

Sub CreateFolderIfNotExist(pathName)
    If Not objFSO.FolderExists(pathName) Then
        objFSO.CreateFolder pathName
    End If
End Sub

Function GetFolderCount(folderPath)
    Dim k, arr
    GetFolderCount = 0
    For Each k In movedFilesDict.Keys
        arr = Split(k, "|")
        If arr(0) = folderPath Then
            GetFolderCount = CInt(arr(1))
            Exit For
        End If
    Next
End Function

Function PluralS(countVal)
    If countVal = 1 Then
        PluralS = ""
    Else
        PluralS = "s"
    End If
End Function

Function PluralWas(countVal)
    If countVal = 1 Then
        PluralWas = "was"
    Else
        PluralWas = "were"
    End If
End Function
