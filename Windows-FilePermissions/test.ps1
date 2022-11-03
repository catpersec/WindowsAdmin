$word = New-Object -ComObject Word.application
$documentPath = "C:\Users\tomek\Desktop\test.docx"
$document = $word.Documents.Open($documentPath)
$FirstParagraph = $document.Paragraphs[1].range.Text
$document.Tables | ft
$document.Tables | get-member
$Table1Row2Col1 = $document.Tables[1].Cell(2,1).range.text
$document.close()
$word.Quit()





