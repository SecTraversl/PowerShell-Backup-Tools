
<#
.SYNOPSIS
    The "Backup-PyFilesScript" function is a specific deployment of the 'Backup-Files.ps1' function used to create an archive copy of the 'py_files' directory.

.EXAMPLE
  PS C:\> Backup-PyFilesScript -RunScript

  Creating compressed archive: 'py_files.zip'

  PS C:\> ls

      Directory: C:\Users\Jannus.Fugal\Documents\Temp\temp\delete-when-finished

  Mode                 LastWriteTime         Length Name
  ----                 -------------         ------ ----
  -a----        12/14/2021   1:10 PM        1452017 py_files.zip



  Here we run the function and in return we get a compressed copy of the 'py_files' directory.

.NOTES
  Name:  Backup-PyFilesScript.ps1
  Author:  Travis Logue
  Version History:  1.2 | 2021-12-14 | Improved documentation
  Dependencies:  Backup-Files.ps1
  Notes:
  - I had some errors initially when trying to Compress-Archive...
    - The particular Error I looked up:
        "ZipArchiveHelper $subDirFiles.ToArray() $destinationPath"
        
        "Compress-Archive error: PermissionDenied"

    - The remedy for those Errors was found from a comment here in this post: 
        https://stackoverflow.com/questions/48684948/compress-archive-error-permissiondenied

    - Particularly this comment: 
        I have the same issue, anyone has the solution. – lsborg Apr 16 at 21:01
        My folder was in a long path, after moving it to user home it worked. I assume it has to do with long paths. – lsborg Apr 16 at 21:12

    - I had a long file name of:
      Filename:
        title_chap1_partA__IPython_range_list_if-elif-else_for-loops_while-loops_Bash-commands-with-IPython_Using-QuestionMark-for-help_re-match_list-comprehensions_Handling-Exceptions_Class-FancyCar.txt

      Under this path:
        C:\Users\Jannus.Fugal\Documents\Temp\py_files\notebooks\py_devops

    - Changed the name of the text file to something shorter and then the Compress-Archive cmdlet worked
      New name:
        title_chap1_partA.txt


  .
#>
function Backup-PyFilesScript {
  [CmdletBinding()]
  param (
    [Parameter(HelpMessage = 'This is a script. If you want to run the script, use this $RunScript switch parameter')]
    [switch]
    $RunScript
  )
  
  begin {}
  
  process {

    if ($RunScript) {

      $DirectoryPath = "$HOME\Documents\Temp\py_files"

      if ( Test-Path $DirectoryPath -PathType Container ) {
        Backup-Files -Directory $DirectoryPath    
      }
      else {
        Write-Host "`nCould not find the following path: '$DirectoryPath'`n" -BackgroundColor Black -ForegroundColor Yellow
      }

    }

  }
  
  end {}

}

