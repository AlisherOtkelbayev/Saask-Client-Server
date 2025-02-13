Option Explicit

Dim objFSO, objArgs, bookFile, topN
Dim dictCounts, dictBaseForms, dictSkippedForms
Dim textLine, wordList, i, w
Dim processedCount, topWords

Set objArgs = WScript.Arguments
If objArgs.Count < 2 Then
    WScript.Echo "USAGE: cscript books.vbs <bookFile> <topN>"
    WScript.Quit 1
End If

bookFile = objArgs(0)
topN = CInt(objArgs(1))

Set objFSO = CreateObject("Scripting.FileSystemObject")
If Not objFSO.FileExists(bookFile) Then
    WScript.Echo "File not found: " & bookFile
    WScript.Quit 1
End If

Set dictCounts = CreateObject("Scripting.Dictionary")
dictCounts.CompareMode = vbTextCompare

Set dictBaseForms = CreateObject("Scripting.Dictionary")
dictBaseForms.CompareMode = vbTextCompare
dictBaseForms("don't") = "do not"
dictBaseForms("can't") = "can not"
dictBaseForms("won't") = "will not"
dictBaseForms("i'll")  = "i will"
dictBaseForms("i'd")   = "i would"
dictBaseForms("it's")  = "it is"
dictBaseForms("that's")= "that is"
dictBaseForms("ain't") = "am not"
dictBaseForms("his")   = "he"
dictBaseForms("her")   = "she"
dictBaseForms("he's")  = "he is"
dictBaseForms("she's") = "she is"
dictBaseForms("isn't") = "is not"
dictBaseForms("you're")= "you are"
dictBaseForms("they're") = "they are"

Set dictSkippedForms = CreateObject("Scripting.Dictionary")
dictSkippedForms.CompareMode = vbTextCompare

Dim file, lineWords
Set file = objFSO.OpenTextFile(bookFile, 1, False)

Do Until file.AtEndOfStream
    textLine = file.ReadLine
    lineWords = Split(Replace(Replace(Replace(textLine, vbTab, " "), ",", ""), ".", ""), " ")
    For i = 0 To UBound(lineWords)
        w = Trim(LCase(lineWords(i)))
        If w <> "" Then
            w = CleanWord(w)
            If dictBaseForms.Exists(w) Then
                w = dictBaseForms(w)
            ElseIf IsShortForm(w) Then
                If Not dictSkippedForms.Exists(w) Then
                    dictSkippedForms(w) = 0
                End If
                dictSkippedForms(w) = dictSkippedForms(w) + 1
            End If
            If w <> "" Then
                If Not dictCounts.Exists(w) Then
                    dictCounts(w) = 0
                End If
                dictCounts(w) = dictCounts(w) + 1
            End If
        End If
    Next
Loop
file.Close

Dim allWords, sortedWords
allWords = dictCounts.Keys
ReDim sortedWords(0 To dictCounts.Count - 1)
For i = 0 To UBound(allWords)
    sortedWords(i) = allWords(i)
Next

Dim j, temp
For i = 0 To UBound(sortedWords) - 1
    For j = i+1 To UBound(sortedWords)
        If dictCounts(sortedWords(j)) > dictCounts(sortedWords(i)) Then
            temp = sortedWords(i)
            sortedWords(i) = sortedWords(j)
            sortedWords(j) = temp
        End If
    Next
Next

WScript.Echo "CHECKING THE ZIPF's LAW"
WScript.Echo "The first column is the number of corresponding words in the text and the second column is the number of words which should occur in the text according to the Zipf's law."
WScript.Echo "The most popular words in " & objFSO.GetFileName(bookFile) & " are:"

Dim topWordFreq
If dictCounts.Count > 0 Then
    topWordFreq = dictCounts(sortedWords(0))
Else
    topWordFreq = 1
End If

Dim wordRank, actualFreq, predictedFreq
For i = 0 To topN-1
    If i > UBound(sortedWords) Then Exit For
    wordRank = i + 1
    actualFreq = dictCounts(sortedWords(i))
    predictedFreq = Fix(topWordFreq / wordRank)
    WScript.Echo sortedWords(i) & " " & actualFreq & " " & predictedFreq
Next

WScript.Echo
WScript.Echo "The most popular still remaining short forms in " & objFSO.GetFileName(bookFile) & " are:"

Dim skippedKeys, sortedSkipped
skippedKeys = dictSkippedForms.Keys
ReDim sortedSkipped(0 To dictSkippedForms.Count - 1)
For i = 0 To UBound(skippedKeys)
    sortedSkipped(i) = skippedKeys(i)
Next

For i = 0 To UBound(sortedSkipped) - 1
    For j = i+1 To UBound(sortedSkipped)
        If dictSkippedForms(sortedSkipped(j)) > dictSkippedForms(sortedSkipped(i)) Then
            temp = sortedSkipped(i)
            sortedSkipped(i) = sortedSkipped(j)
            sortedSkipped(j) = temp
        End If
    Next
Next

For i = 0 To topN-1
    If i > UBound(sortedSkipped) Then Exit For
    WScript.Echo sortedSkipped(i) & " " & dictSkippedForms(sortedSkipped(i))
Next

WScript.Echo "--------------------------------"

Function CleanWord(strWord)
    Dim s
    s = strWord
    s = Replace(s, "'", "")
    s = Replace(s, """", "")
    s = Replace(s, ",", "")
    s = Replace(s, ".", "")
    s = Replace(s, "?", "")
    s = Replace(s, "!", "")
    s = Replace(s, ":", "")
    s = Replace(s, ";", "")
    CleanWord = Trim(s)
End Function

Function IsShortForm(strWord)
    IsShortForm = InStr(strWord, "'") > 0
End Function
